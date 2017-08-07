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
my $crime1;
my $crime2;
my @year;
my @stat;
my @violation;
my $year1;
my $year2;
my $region;
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
        $violation[$numEntries] = $master_fields2[3];
        $numEntries++;
    }
}
print("What would you like to call the PDF: ");
my $fname = <STDIN>;
chomp($fname);

$infilename = "in.txt";
$pdffilename = $fname.'.pdf';

$year1 = $year[1];
$year2 = $year[$numEntries - 1];
$crime1 = $violation[1];

for(my $i = 0; $i < $numEntries; $i++) {
	if($violation[1] ne $violation[$i]) {
		$crime2 = $violation[$i];
		#SECOND STAT
	}
}

print "Exporting $pdffilename...\n";

# Create a communication bridge with R and start R
my $R = Statistics::R->new();

# Name the PDF output file for the plot  
# my $Rplots_file = "./Rplots_file.pdf";

# Pass perl variables to R
$R->run(qq`crime1 <- c("$crime1")`);
$R->run(qq`crime2 <- c("$crime2")`);
$R->run(qq`year1 <- c($year1)`);
$R->run(qq`year2 <- c($year2)`);
$R->run(qq`region <- c("$region")`);

# Set up the PDF file for plots
$R->run(qq`pdf("$pdffilename" , paper="letter")`);

# Load the plotting library
$R->run(q`library(ggplot2)`);

# read in data from a CSV file
$R->run(qq`data <- read.csv("$infilename")`);

# plot the data as a line plot with each point outlined
# When determining the scale to put on the graph, take max number and divide it by a number and so on...
$R->run(q`ggplot(data, aes(x=Year, y=Value, colour=Violation, group=Violation)) + scale_x_continuous(breaks = c(year1:year2))+ geom_line() + geom_point(size=2) + labs(title = paste(crime1, "and", crime2, "Crime Data Between the Years", year1,"and", year2, "\nfor the Region", region)) + ylab("Value") + theme(plot.title = element_text(hjust = 0.5, size = 12)) `);

# close down the PDF device
$R->run(q`dev.off()`);

$R->stop();
