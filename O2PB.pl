#!/usr/bin/perl
#
#   Packages and modules
#
use strict;
use warnings;
use version;         our $VERSION = qv('5.16.0');   # This is the version of Perl to be used
use Statistics::R;
use Text::CSV  1.32;

my $COMMA = q{,};
my $csv          = Text::CSV->new({ sep_char => $COMMA});
my $infilename;
my $pdffilename;
my $crime;
my @year;
my $region;
my @stat;
my $violation;
my $census;
my $numEntries = 0;

if ($#ARGV != 0 ) {
    print "Usage: <Region>\n" or
    die "Print failure\n";
    exit;
} else {
    $region = $ARGV[0];
}

open my $inputFILE, '<', "in.txt"
or die "Unable to open names file: in.txt\n";
my @graphData = <$inputFILE>;
close $inputFILE or
die "Unable to closeinput file.\n";

foreach my $graph ( @graphData ) {
    if ( $csv->parse($graph) ) {
        my @master_fields2 = $csv->fields();
        $year[$numEntries] = $master_fields2[0];
        $stat[$numEntries] = $master_fields2[1];
        $numEntries++;
    }
}

print("What would you like to call the PDF: ");
my $fname = <STDIN>;
chomp($fname);

$infilename = "in.txt";
$pdffilename = $fname.'.pdf';

$crime = $stat[1];
#FIRST STAT
for(my $i = 0; $i < $numEntries; $i++) {
	if($stat[1] ne $stat[$i]) {
		$census = $stat[$i];
		#SECOND STAT
	}
}
#census stat in file
#crime type in VALUE

print "Exporting $pdffilename...\n";

# Create a communication bridge with R and start R
my $R = Statistics::R->new();

# Name the PDF output file for the plot  
# my $Rplots_file = "./Rplots_file.pdf";

# Pass perl variables to R
$R->run(qq`crimeTitle <- c("$crime")`);
$R->run(qq`yearTitle <- c("$year[1]")`);
$R->run(qq`regionTitle <- c("$region")`);
$R->run(qq`censusTitle <- c("$census")`);

# Set up the PDF file for plots
$R->run(qq`pdf("$pdffilename" , paper="letter")`);

# Load the plotting library
$R->run(q`library(ggplot2)`);

# read in data from a CSV file
$R->run(qq`data <- read.csv("$infilename")`);

# plot the data as a line plot with each point outlined
# When determining the scale to put on the graph, take max number and divide it by a number and so on...
$R->run(q`ggplot(data=data, aes(x=yearTitle, y=Value, colour=Stat, group=Stat, fill=Stat)) + xlab("Year")+ scale_x_discrete(labels=c(yearTitle)) + geom_text(aes(label = Value), colour = "black", size = 3, position=position_dodge(width=0.9), vjust=-0.25) + geom_bar(stat="identity", position="dodge") + scale_x_discrete(labels=yearTitle) + labs(title = paste(crimeTitle,"and",censusTitle,"statistics for the year",yearTitle,"\nin the region",regionTitle)) + theme(plot.title = element_text(hjust = 0.5, size=10)) `);

# close down the PDF device
$R->run(q`dev.off()`);

$R->stop();
