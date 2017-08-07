#!/usr/bin/perl
#
#   Packages and modules
#
use strict;
use version;         our $VERSION = qv('5.16.0');   # This is the version of Perl to be used
use Statistics::R;
use Text::CSV  1.32;

my $COMMA = q{,};
my $csv          = Text::CSV->new({ sep_char => $COMMA});
my $infilename;
my $pdffilename;
my $crime;
my $region;
my $numEntries = 0;
my $year1 = 0;
my $year2 = 0;
my @yearArray;
my @regionArray;

if ($#ARGV != 0 ) {
    print "Usage: <Crime Violation (Ex. Murder)>\n" or
    die "Print failure\n";
    exit;
} else {
    $crime = $ARGV[0];
}

open my $inputFILE, '<', "in.txt"
or die "Unable to open names file: in.txt\n";
my @graphData = <$inputFILE>;
close $inputFILE or
die "Unable to closeinput file.\n";

foreach my $graph ( @graphData ) {
    if ( $csv->parse($graph) ) {
        my @master_fields2 = $csv->fields();
        $yearArray[$numEntries] = $master_fields2[0];
        $regionArray[$numEntries] = $master_fields2[1];
        $numEntries++;
    }
} 

$region = $regionArray[1];
$year1 = $yearArray[1];
$year2 = $yearArray[$numEntries - 1];
my $fname;

print("What would you like to call the PDF: ");
my $fname = <STDIN>;
chomp($fname);

$infilename = "in.txt";
$pdffilename = $fname.'.pdf';

print "Exporting $pdffilename...\n";

# Create a communication bridge with R and start R
my $R = Statistics::R->new();

# Name the PDF output file for the plot  
#my $Rplots_file = "./Rplots_file.pdf";

# Pass perl variables R
$R->run(qq`year1 <- c("$year1")`);
$R->run(qq`year2 <- c("$year2")`);
$R->run(qq`crimeTitle <- c("$crime")`);
$R->run(qq`regionTitle <- c("$region")`);

# Set up the PDF file for plots
$R->run(qq`pdf("$pdffilename" , paper="letter")`);

# Load the plotting library
$R->run(q`library(ggplot2)`);

# read in data from a CSV file
$R->run(qq`data <- read.csv("$infilename")`);

# plot the data as a line plot with each point outlined
# When determining the scale to put on the graph, take max number and divide it by a number and so on...
$R->run(q`ggplot(data=data, aes(x=Year, y=Value, colour=Region, fill=Region)) + geom_text(aes(label = Value), colour = "black", size = 3, position=position_dodge(width=0.9), vjust=-0.25) + scale_x_continuous(breaks = c(year1:year2)) + geom_bar(stat="identity") + labs(title = paste(crimeTitle,"Crime Data between the Years",year1,"and",year2,"\nfor the Region", regionTitle)) + theme(plot.title = element_text(hjust = 0.5, size = 12))`);

# close down the PDF device
$R->run(q`dev.off()`);

$R->stop();

