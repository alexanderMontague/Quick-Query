#	Team Brockville W17

#	queryEngine.pl
#		Will take the user's input and search for their request from the crime and census files
#		based on the input. The queryEngine has pre-made forms to all for precise input and prevent
#		incorrect interpretaions/answers.
#

#!/usr/bin/perl

#
#   Packages and modules
#
use strict;
use warnings;
use version; our $VERSION = qv('5.16.0'); # This is the version of Perl to be used
use Text::CSV 1.32;   # We will be using the CSV module (version 1.32 or higher)

my $EMPTY = q{};
my $SPACE = q{ };
my $COMMA = q{,};
my $csv   = Text::CSV->new( { sep_char => $COMMA } );

#	valid input tables
my @validRegions;
my @validVios;
my @validStats;
my @validYrs;
my @valid2001Census;
my @valid2006Census;
my @valid2011Census;
my @validCenRegions;
my @temp;
my @crimeValues;
my @censusValues;
my @CrVAL;
my @CrLOC;
my @CenVAL;
my @CenLOC;

#
#	Vars and definitions
#
my $userIn;
my $region;
my $vio;
my $vio1;
my $stat;
my $cStat;
my $startYr;
my $endYr;
my $unkFlag;
my $valid;
my $record_count = 0;
my @result;

#
# Getting the tables that contain the valid inputs
# for each respective field. Also getting the help menu
#
open my $regionFH, '<', 'regionTable.csv'
  or die "ERROR, Unable to open file: regionTable.csv";
open my $vioFH, '<', 'violationTable.csv'
  or die "ERROR, Unable to open file: violationTable.csv";
open my $statFH, '<', 'statisticTable.csv'
  or die "ERROR, Unable to open file: statisticTable.csv";
open my $yrFH, '<', 'yearTable.csv'
  or die "ERROR, Unable to open file: yearTable.csv";
open my $census2001FH, '<', '2001CensusTable.csv'
  or die "ERROR, Unable to open file: 2001CensusTable.csv";
open my $census2006FH, '<', '2006CensusTable.csv'
  or die "ERROR, Unable to open file: 2006CensusTable.csv";
open my $census2011FH, '<', '2011CensusTable.csv'
  or die "ERROR, Unable to open file: 2011CensusTable.csv";
open my $censusRegionFH, '<', 'censusRegionTable.csv'
  or die "ERROR, Unable to open file: censusRegionTable.csv";

@temp = <$regionFH>;
foreach my $rec (@temp) {
    if ( $csv->parse($rec) ) {
        my @master_fields = $csv->fields();
        $validRegions[$record_count] = $master_fields[0];
        $record_count++;
    }
    else {
        #warn "Line/record could not be parsed: $records[$record_count]\n";
        #my $a = <>;
    }
}
$record_count = 0;
@temp         = <$vioFH>;
foreach my $rec (@temp) {
    if ( $csv->parse($rec) ) {
        my @master_fields = $csv->fields();
        $validVios[$record_count] = $master_fields[0];
        $record_count++;
    }
    else {
        #warn "Line/record could not be parsed: $records[$record_count]\n";
        #my $a = <>;
    }
}
$record_count = 0;
@temp         = <$statFH>;
foreach my $rec (@temp) {
    if ( $csv->parse($rec) ) {
        my @master_fields = $csv->fields();
        $validStats[$record_count] = $master_fields[0];
        $record_count++;
    }
    else {
        #warn "Line/record could not be parsed: $records[$record_count]\n";
        #my $a = <>;
    }
}
$record_count = 0;

@temp = <$yrFH>;
foreach my $rec (@temp) {
    if ( $csv->parse($rec) ) {
        my @master_fields = $csv->fields();
        $validYrs[$record_count] = $master_fields[0];
        $record_count++;
    }
    else {
        #warn "Line/record could not be parsed: $records[$record_count]\n";
        #my $a = <>;
    }
}
$record_count = 0;

@temp = <$census2001FH>;
foreach my $rec (@temp) {
    if ( $csv->parse($rec) ) {
        my @master_fields = $csv->fields();
        $valid2001Census[$record_count] = $master_fields[0];
        $record_count++;
    }
    else {
        #warn "Line/record could not be parsed: $records[$record_count]\n";
        #my $a = <>;
    }
}
$record_count = 0;

@temp = <$census2006FH>;
foreach my $rec (@temp) {
    if ( $csv->parse($rec) ) {
        my @master_fields = $csv->fields();
        $valid2006Census[$record_count] = $master_fields[0];
        $record_count++;
    }
    else {
        #warn "Line/record could not be parsed: $records[$record_count]\n";
        #my $a = <>;
    }
}
$record_count = 0;

@temp = <$census2011FH>;
foreach my $rec (@temp) {
    if ( $csv->parse($rec) ) {
        my @master_fields = $csv->fields();
        $valid2011Census[$record_count] = $master_fields[0];
        $record_count++;
    }
    else {
        #warn "Line/record could not be parsed: $records[$record_count]\n";
        #my $a = <>;
    }
}
$record_count = 0;

@temp = <$censusRegionFH>;
foreach my $rec (@temp) {
    if ( $csv->parse($rec) ) {
        my @master_fields = $csv->fields();
        $validCenRegions[$record_count] = $master_fields[0];
        $record_count++;
    }
    else {
        #warn "Line/record could not be parsed: $records[$record_count]\n";
        #my $a = <>;
    }
}

close $regionFH
  or die "ERROR, Unable to close file: regionTable.csv";
close $vioFH
  or die "ERROR, Unable to close file: violationTable.csv";
close $statFH
  or die "ERROR, Unable to close file: statisticTable.csv";
close $yrFH
  or die "ERROR, Unable to close file: yearTable.csv";
close $census2001FH
  or die "ERROR, Unable to close file: 2001CensusTable.csv";
close $census2006FH
  or die "ERROR, Unable to close file: 2006CensusTable.csv";
close $census2011FH
  or die "ERROR, Unable to close file: 2011CensusTable.csv";
close $censusRegionFH
  or die "ERROR, Unable to close file: censusRegionTable.csv";

#
#	getIn subroutine
#		Simply gets user imput and chomps the \n
#
sub getIn {
    my $userIn = <STDIN>;
    chomp $userIn;
    return $userIn;
}

#
#	getNum subroutine
#		Forces the user input to be a number
#
sub getNum {
    my @temp = @_;
    my $err  = $temp[0];
    my $userIn;

    do {
        $userIn = <STDIN>;
        chomp $userIn;

        if ( $userIn !~ /^[+-]?\d+\.?\d*$/ ) {
            print $err;
        }
    } while ( $userIn !~ /^[+-]?\d+\.?\d*$/ );

    return $userIn;
}

#
#	gives suggestions by matching the words given
#	with the target
#
sub dym {
    my $num      = 0;
    my @temp     = @_;
    my $string   = $temp[0];
    my $matchRef = $temp[1];
    my @match    = @$matchRef;
    my @words    = split( /\s+/, $string );
    my $regex    = "(";
    $regex .= join "|", @words;
    $regex .= ")";

    foreach my $i (@match) {
        if ( $i =~ m/$regex/i ) {
            if ( $num == 0 ) {
                print("Did you mean?\n");
            }
            print "	$i\n";
            $num++;
        }
    }

}

#
# checkField subroutine
#		A generalized routine to check if the given input to any
#		abstract field meets a standard. The "standard" is given
#		as a reference to an array that contains all acceptable inputs.
#
#		Returns:
#			0 on failure (meaning that the target is invalid)
#			1 on success (meaning that the target is valid)
#
sub checkField {
    my @temp        = @_;
    my $target      = $temp[0];
    my $toSearchRef = $temp[1];
    my @toSearch    = @$toSearchRef;

    foreach my $cur (@toSearch) {

        #	checking if current equals target
        if ( uc($cur) eq uc($target) ) {
            return 1;
        }
    }

    #	if it exits the loop the search didn't find the target
    return 0;
}

#
#		question1 subroutine
#Pass over the question type one into function and it will return any values in the files relating to the question
#Parameters:
#	Takes 5 string as the parameter:	Region	Violation	Statistic	StartYear	EndYear
#	!!Must be in order else the program will not work!!
#Returns:
#	has multiple return depending on the input it is given (Where is the question mark)
#	Returns the lengh of the array
#Sample fucntion call:
#		my ($arrayRef, $arrayLen) = question1($region, $violation, $statistic, $StartYear, $EndYear);
#		my @array = @$arrayRef;
#
sub question1 {
    my @temp   = @_;
    my $region = lc( $temp[0] );
    my $vio    = lc( $temp[1] );
    my $stat   = lc( $temp[2] );
    my $SYear  = lc( $temp[3] );
    my $EYear  = lc( $temp[4] );

    my @foundVal;
    my $foundCount = 0;
    my @foundRegion;
    my @foundVio;

    if ( $EYear == 0 ) {
        $EYear = $SYear;
    }

    for ( my $i = $SYear ; $i <= $EYear ; $i++ ) {
        my $fName = $i . "Crime.csv";

        #my $fName = "t1.csv";
        #print("File name: $fName\n");

        my $csv = Text::CSV->new( { sep_char => $COMMA } );
        my @records;
        my $record_count = 0;
        my @GEO;
        my @violation;
        my @FStat;
        my @coordinate;
        my @value;

        open my $lineFH, '<', $fName
          or die "ERROR, Unable to open file";

        @records = <$lineFH>;

        close $lineFH
          or die "Unable to close file\n";    # Close the input file

        foreach my $rec (@records) {
            if ( $csv->parse($rec) ) {
                my @master_fields = $csv->fields();
                $GEO[$record_count]        = lc( $master_fields[1] );
                $violation[$record_count]  = lc( $master_fields[2] );
                $FStat[$record_count]      = lc( $master_fields[3] );
                $coordinate[$record_count] = lc( $master_fields[4] );
                $value[$record_count]      = lc( $master_fields[5] );
                $record_count++;
            }
            else {
                warn
                  "Line/record could not be parsed: $records[$record_count]\n";
                my $a = <>;
            }
        }

        for ( my $j = 0 ; $j < $record_count ; $j++ ) {
            if ( $region eq '?' ) {
                if ( $vio eq $violation[$j] ) {
                    if ( $stat eq $FStat[$j] ) {
                        $foundVal[$foundCount]    = $value[$j];
                        $foundRegion[$foundCount] = $GEO[$j];

                        #print("NO REGION: $value[$j]\n");
                        $foundCount++;
                    }
                }
            }
            else {
                if ( $vio eq '?' ) {
                    if ( $region eq $GEO[$j] ) {
                        if ( $stat eq $FStat[$j] ) {
                            $foundVal[$foundCount] = $value[$j];
                            $foundVio[$foundCount] = $violation[$j];
                            $foundCount++;

                            #print("NO VIOLATION: $value[$j]\n");
                        }
                    }
                }
                else {
                    if ( $region eq $GEO[$j] ) {
                        if ( $vio eq $violation[$j] ) {
                            if ( $stat eq $FStat[$j] ) {
                                $foundVal[$foundCount] = $value[$j];
                                $foundCount++;

                                #print("ALL PROVIDED: $value[$j]\n");
                            }
                        }
                    }
                }
            }
        }
    }

    if ( $region eq '?' ) {
        return ( \@foundVal, $foundCount, \@foundRegion );
    }
    elsif ( $vio eq '?' ) {
        return ( \@foundVal, $foundCount, \@foundVio );
    }
    else {
        return ( \@foundVal, $foundCount );
    }
}

sub question2a {
    my @temp   = @_;
    my $region = lc( $temp[0] );
    my $vio1   = lc( $temp[1] );
    my $vio2   = lc( $temp[2] );
    my $stat   = lc( $temp[3] );
    my $SYear  = lc( $temp[4] );
    my $EYear  = lc( $temp[5] );
    my @foundVal;

    my @Stat1Highest;
    my @Stat2Highest;
    my @HighestRegion1;
    my @HighestRegion2;

    if ( $EYear == 0 ) {
        $EYear = $SYear;
    }
    my $S1Count = 0;
    my $S2Count = 0;

    for ( my $i = $SYear ; $i <= $EYear ; $i++ ) {

        #$Stat1Highest[$i - $SYear] = 0;
        #$HighestRegion1[$i - $SYear] = 0;
        #$-Stat2Highest[$i - $SYear] = 0;
        #$HighestRegion2[$i - $SYear] = 0;

        my $fName = $i . "Crime.csv";

        #my $fName = "t1.csv";
        #print ("File name: $fName\n");

        my $csv = Text::CSV->new( { sep_char => $COMMA } );
        my @records;
        my $record_count = 0;

        #my @ref_date;
        my @GEO;
        my @violation;
        my @FStat;
        my @coordinate;
        my @value;

        open my $lineFH, '<', $fName
          or die "ERROR, Unable to open file";

        @records = <$lineFH>;

        close $lineFH
          or die "Unable to close file\n";    # Close the input file

        foreach my $rec (@records) {
            if ( $csv->parse($rec) ) {
                my @master_fields = $csv->fields();

                #$ref_date[$record_count] = $master_fields[0];
                $GEO[$record_count]        = lc( $master_fields[1] );
                $violation[$record_count]  = lc( $master_fields[2] );
                $FStat[$record_count]      = lc( $master_fields[3] );
                $coordinate[$record_count] = lc( $master_fields[4] );
                $value[$record_count]      = lc( $master_fields[5] );
                $record_count++;
            }
            else {
                warn
                  "Line/record could not be parsed: $records[$record_count]\n";
            }
        }

        #Find the highest of the two crimes
        for ( my $j = 0 ; $j < $record_count ; $j++ ) {
            if ( $region eq '?' ) {
                if ( $stat eq $FStat[$j] ) {
                    if ( $vio1 eq $violation[$j] ) {

      #Records the highest value for this violation and the region it occured in
                        if ( !( $value[$j] eq ".." ) ) {

                            #if($Stat1Highest[$i - $SYear] <= $value[$j]){
                            $Stat1Highest[$S1Count]   = $value[$j];
                            $HighestRegion1[$S1Count] = $GEO[$j];
                            $S1Count++;

                            #}
                        }
                    }
                    elsif ( $vio2 eq $violation[$j] ) {

      #Records the highest value for this violation and the region it occured in
                        if ( !( $value[$j] eq ".." ) ) {

                            #if($Stat2Highest[$i - $SYear] <= $value[$j]){
                            $Stat2Highest[$S2Count]   = $value[$j];
                            $HighestRegion2[$S2Count] = $GEO[$j];

                            #}
                            $S2Count++;
                        }
                    }
                }
            }
            else {
                if ( $region eq $GEO[$j] ) {
                    if ( $stat eq $FStat[$j] ) {
                        if ( $vio1 eq $violation[$j] ) {

      #Records the highest value for this violation and the region it occured in
                            if ( !( $value[$j] eq ".." ) ) {

                                #if($Stat1Highest[$i - $SYear] <= $value[$j]){
                                $Stat1Highest[$S1Count]   = $value[$j];
                                $HighestRegion1[$S1Count] = $GEO[$j];

                                #print("Violation 1: $GEO[$j], $value");
                                #}
                                $S1Count++;
                            }
                        }
                        elsif ( $vio2 eq $violation[$j] ) {

      #Records the highest value for this violation and the region it occured in
                            if ( !( $value[$j] eq ".." ) ) {

                                #if($Stat2Highest[$i - $SYear] <= $value[$j]){
                                $Stat2Highest[$S2Count]   = $value[$j];
                                $HighestRegion2[$S2Count] = $GEO[$j];

                                #}
                                $S2Count++;
                            }
                        }
                    }
                }
            }
        }    #End of inner for loop
         #print("Violation 1: $Stat1Highest[$i - $SYear], $HighestRegion1[$i - $SYear]\n");
         #print("Violation 2: $Stat2Highest[$i - $SYear], $HighestRegion2[$i - $SYear]\n");
    }    #End of outer for loop

    return ( \@Stat1Highest, \@HighestRegion1, $S1Count, \@Stat2Highest,
        \@HighestRegion2, $S2Count );

}    #End of sub

sub question2b {
    my @temp       = @_;
    my $region     = lc( $temp[0] );
    my $vio1       = lc( $temp[1] );
    my $stat       = lc( $temp[2] );
    my $CensusStat = lc( $temp[3] );
    my $Year       = lc( $temp[4] );

    my $fName = $Year . "Crime.csv";
    my $csv = Text::CSV->new( { sep_char => $COMMA } );
    my @records;
    my $record_count = 0;
    my @GEO;
    my @violation;
    my @FStat;
    my @coordinate;
    my @value;

    open my $lineFH, '<', $fName
      or die "ERROR, Unable to open file";

    @records = <$lineFH>;

    close $lineFH
      or die "Unable to close file\n";    # Close the input file

    foreach my $rec (@records) {
        if ( $csv->parse($rec) ) {
            my @master_fields = $csv->fields();
            $GEO[$record_count]        = lc( $master_fields[1] );
            $violation[$record_count]  = lc( $master_fields[2] );
            $FStat[$record_count]      = lc( $master_fields[3] );
            $coordinate[$record_count] = lc( $master_fields[4] );
            $value[$record_count]      = lc( $master_fields[5] );
            $record_count++;
        }
        else {
            warn "Line/record could not be parsed: $records[$record_count]\n";
        }
    }

    my @censusRecord;
    my $censusCount = 0;
    my @Geo_Code;
    my @Prov_Name;
    my @Topic;
    my @Characteristic;
    my @Note;
    my @Total;
    my @Flag_Total;
    my @Male;
    my @Flag_Male;
    my @Female;
    my @Flag_Female;
    my @Flag;

    my $crimeCount = 0;
    my $cenCount   = 0;
    my @CrimeVal;
    my @CensusVal;
    my @CrimeLoc;
    my @CensusLoc;
    if ( $Year == 2001 ) {

#"Geo_Code","Prov_Name","Topic","Characteristic","Note","Total","Male","Female","Flag"
        my $censusFile = "2001CensusData.csv";
        open my $lineFG, '<', $censusFile
          or die "ERROR, Unable to open file";

        @censusRecord = <$lineFG>;

        close $lineFG
          or die "Unable to close file\n";    # Close the input file

        foreach my $rec (@censusRecord) {
            if ( $csv->parse($rec) ) {
                my @master_fields = $csv->fields();
                $Geo_Code[$censusCount]  = lc( $master_fields[0] );
                $Prov_Name[$censusCount] = lc( $master_fields[1] );

                #printf("$Prov_Name[$censusCount]\n");
                $Topic[$censusCount]          = lc( $master_fields[2] );
                $Characteristic[$censusCount] = lc( $master_fields[3] );
                $Characteristic[$censusCount] =~ s/^\s+//;
                $Note[$censusCount]  = lc( $master_fields[4] );
                $Total[$censusCount] = lc( $master_fields[5] );
                $Total[$censusCount] =~ s/^\s+//;
                $Male[$censusCount]   = lc( $master_fields[6] );
                $Female[$censusCount] = lc( $master_fields[7] );
                $Flag[$censusCount]   = lc( $master_fields[8] );
                $censusCount++;
            }
            else {
                warn "Line/record could not be parsed: $censusRecord[$censusCount]\n";
            }
        }
        for ( my $j = 0 ; $j < $record_count ; $j++ ) {
            if ( $region eq "?" ) {
                if ( $stat eq $FStat[$j] ) {
                    if ( $vio1 eq $violation[$j] ) {
                        $CrimeVal[$crimeCount] = $value[$j];
                        $CrimeLoc[$crimeCount] = $GEO[$j];
                        $crimeCount++;
                    }
                }
            }
            else {
                if ( $region eq $GEO[$j] ) {
                    if ( $stat eq $FStat[$j] ) {
                        if ( $vio1 eq $violation[$j] ) {
                            $CrimeVal[$crimeCount] = $value[$j];
                            $crimeCount++;
                        }
                    }
                }
            }
        }

        #print("Reached the census part\n");
        for ( my $k = 0 ; $k < $censusCount ; $k++ ) {
            if ( $region eq "?" ) {
                if ( $CensusStat eq $Characteristic[$k] ) {

                    #print("What am i missing?\n");
                    $CensusVal[$cenCount] = $Total[$k];

                    #print("$Prov_Name[$k]\n");
                    $CensusLoc[$cenCount] = $Prov_Name[$k];
                    $cenCount++;
                }
            }
            else {
                #printf("pls help?\n");
                if ( $region eq $Prov_Name[$k] ) {
                    if ( $CensusStat eq $Characteristic[$k] ) {
                        $CensusVal[$cenCount] = $Total[$k];
                        $cenCount++;
                    }
                }
            }
        }

        #printf("2001\n");
        #print("$Prov_Name[5], $Topic[5], $Characteristic[5]\n");

# 				TO FINISH
#Statement to parse through the data, both census and crime (crime can most likely be copied from another subroutine)
#Storing the paresd data info a format suitable to be used

    }
    elsif ( $Year == 2006 ) {

#Geo_Code,Prov_Name,Topic,Characteristic,Note,Total,Flag_Total,Male,Flag_Male,Female,Flag_Female
        my $censusFile = "2006CensusData.csv";
        open my $lineFG, '<', $censusFile
          or die "ERROR, Unable to open file";

        @censusRecord = <$lineFG>;

        close $lineFG
          or die "Unable to close file\n";    # Close the input file

        foreach my $rec (@censusRecord) {
            if ( $csv->parse($rec) ) {
                my @master_fields = $csv->fields();
                $Geo_Code[$censusCount]       = lc( $master_fields[0] );
                $Prov_Name[$censusCount]      = lc( $master_fields[1] );
                $Topic[$censusCount]          = lc( $master_fields[2] );
                $Characteristic[$censusCount] = lc( $master_fields[3] );
                $Characteristic[$censusCount] =~ s/^\s+//;
                $Note[$censusCount]  = lc( $master_fields[4] );
                $Total[$censusCount] = lc( $master_fields[5] );
                $Total[$censusCount] =~ s/^\s+//;
                $Flag_Total[$censusCount]  = lc( $master_fields[6] );
                $Male[$censusCount]        = lc( $master_fields[7] );
                $Flag_Male[$censusCount]   = lc( $master_fields[8] );
                $Female[$censusCount]      = lc( $master_fields[9] );
                $Flag_Female[$censusCount] = lc( $master_fields[10] );
                $censusCount++;
            }
            else {
				#warn "Line/record could not be parsed: $censusRecord[$censusCount]\n";
            }
        }
        for ( my $j = 0 ; $j < $record_count ; $j++ ) {
            if ( $region eq "?" ) {
                if ( $stat eq $FStat[$j] ) {
                    if ( $vio1 eq $violation[$j] ) {
                        $CrimeVal[$crimeCount] = $value[$j];
                        $CrimeLoc[$crimeCount] = $GEO[$j];
                        $crimeCount++;
                    }
                }
            }
            else {
                if ( $region eq $GEO[$j] ) {
                    if ( $stat eq $FStat[$j] ) {
                        if ( $vio1 eq $violation[$j] ) {
                            $CrimeVal[$crimeCount] = $value[$j];
                            $crimeCount++;
                        }
                    }
                }
            }
        }
        for ( my $k = 0 ; $k < $censusCount ; $k++ ) {
            if ( $region eq "?" ) {
                if ( $CensusStat eq $Characteristic[$k] ) {
                    $CensusVal[$cenCount] = $Total[$k];
                    $CensusLoc[$cenCount] = $Prov_Name[$k];
                    $cenCount++;
                }
            }
            else {
                if ( $region eq $Prov_Name[$k] ) {
                    if ( $CensusStat eq $Characteristic[$k] ) {
                        $CensusVal[$cenCount] = $Total[$k];
                        $cenCount++;
                    }
                }
            }
        }

    }
    elsif ( $Year == 2011 ) {
	#"Geo_Code","Prov_Name","Topic","Characteristic","Note","Total","Flag_Total","Male","Flag_Male","Female","Flag_Female"
        my $censusFile = "2011CensusData.csv";
        open my $lineFG, '<', $censusFile
          or die "ERROR, Unable to open file";

        @censusRecord = <$lineFG>;

        close $lineFG
          or die "Unable to close file\n";    # Close the input file

        foreach my $rec (@censusRecord) {
            if ( $csv->parse($rec) ) {
                my @master_fields = $csv->fields();
                $Geo_Code[$censusCount]       = lc( $master_fields[0] );
                $Prov_Name[$censusCount]      = lc( $master_fields[1] );
                $Topic[$censusCount]          = lc( $master_fields[2] );
                $Characteristic[$censusCount] = lc( $master_fields[3] );
                $Characteristic[$censusCount] =~ s/^\s+//;
                $Note[$censusCount]  = lc( $master_fields[4] );
                $Total[$censusCount] = lc( $master_fields[5] );
                $Total[$censusCount] =~ s/^\s+//;
                $Flag_Total[$censusCount]  = lc( $master_fields[6] );
                $Male[$censusCount]        = lc( $master_fields[7] );
                $Flag_Male[$censusCount]   = lc( $master_fields[8] );
                $Female[$censusCount]      = lc( $master_fields[9] );
                $Flag_Female[$censusCount] = lc( $master_fields[10] );
                $censusCount++;
            }
            else {
         #warn "Line/record could not be parsed: $censusRecord[$censusCount]\n";
            }
        }
        for ( my $j = 0 ; $j < $record_count ; $j++ ) {
            if ( $region eq "?" ) {
                if ( $stat eq $FStat[$j] ) {
                    if ( $vio1 eq $violation[$j] ) {
                        $CrimeVal[$crimeCount] = $value[$j];
                        $CrimeLoc[$crimeCount] = $GEO[$j];
                        $crimeCount++;
                    }
                }
            }
            else {
                if ( $region eq $GEO[$j] ) {
                    if ( $stat eq $FStat[$j] ) {
                        if ( $vio1 eq $violation[$j] ) {
                            $CrimeVal[$crimeCount] = $value[$j];
                            $crimeCount++;
                        }
                    }
                }
            }
        }

        for ( my $k = 0 ; $k < $censusCount ; $k++ ) {

            if ( $region eq "?" ) {
                if ( $CensusStat eq $Characteristic[$k] ) {
                    $CensusVal[$cenCount] = $Total[$k];
                    $CensusLoc[$cenCount] = $Prov_Name[$k];
                    $cenCount++;
                }
            }
            else {
                if ( $region eq $Prov_Name[$k] ) {
                    if ( $CensusStat eq $Characteristic[$k] ) {
                        $CensusVal[$cenCount] = $Total[$k];
                        $cenCount++;
                    }
                }
            }
        }

        #printf("2011\n");
        #print("$Characteristic[5]\n");
    }

    if ( $region eq "?" ) {
        return (
            \@CrimeVal,  \@CrimeLoc,  $crimeCount,
            \@CensusVal, \@CensusLoc, $cenCount
        );
    }
    else {
        return ( \@CrimeVal, $crimeCount, \@CensusVal, $cenCount );
    }
}

do {
    print("Brockville QuickQuery - Powered by R\n");

    print("			1 - Basic Crime Statistic Query\n");
    print("			2 - Cross-referenced Stat Question\n");
    print("			3 - Help\n");
    print("			4 - Quit\n");

    print "Please choose an option [1-4]: ";
    $userIn = getNum("Please choose an option [1-4]: ");

    #
    #	Option 1: Purely looking at crime data
    #

    if ( $userIn == 1 ) {
        print "You chose to search for a crime statistic\n";
        
		$valid = 1;
		do {
			if ($valid == 0) {
				dym( $region, \@validRegions );
            }
			print "Region: ";
            $region = getIn();

            if ( $region eq '?' ) {
                $unkFlag = 1;
                $valid   = 1;
            }
            else {
                $valid = checkField( $region, \@validRegions );
            }
        } while ( $valid == 0 );
        do {
			if ($valid == 0) {
				dym( $vio, \@validVios );
            }
            print "Violation: ";
            $vio = getIn();

            if ( $vio eq '?' ) {
                if ( $region eq '?' ) {
                    $valid = 0;
                }
                else {
                    $valid = 1;
                }
            }
            else {
                $valid = checkField( $vio, \@validVios );
            }
        } while ( $valid == 0 );
        do {
			if ($valid == 0) {
				dym( $stat, \@validStats );
            }
            print "Statistic: ";
            $stat = getIn();

            $valid = checkField( $stat, \@validStats );
        } while ( $valid == 0 );
        do {
            print "Start Year [1998-2015]: ";
            my $err;
            $err     = ('Start Year [1998-2015]');
            $startYr = getNum($err.': ');

            $valid = checkField( $startYr, \@validYrs );
        } while ( $valid == 0 );
        
		do {
        	print "End Year [1998-2015]: ";
			my $err;
			$err   = ('End Year [1998-2015]');
			$endYr = getNum($err.': ');

			$valid = checkField( $endYr, \@validYrs );

			if ( $endYr < $startYr ) {
				print("End year cannot be before the start year!\n");
				$valid = 0;
			}
		} while ( $valid == 0 );
		
		my @c;
		my @d;
		
        if ( $region eq "?" ) {
            my ( $ref, $a, $ref2 ) =
              question1( $region, $vio, $stat, $startYr, $endYr );
            @c = @$ref;
            @d = @$ref2;
            
			print("How would you like the data to be displayed: (Raw, Highest, Lowest, Average): ");
            my $userInput = getIn();
			
			if(lc($userInput) eq "raw"){
				for ( my $m = 0 ; $m < $a ; $m++ ) {
					$d[$m] = uc($d[$m]);
					print("$d[$m], $c[$m]\n");
				}
			}elsif(lc($userInput) eq "highest"){
				my $highVal = 0;
				my $highLoc  = "Nothing found";
				for(my $m = 0; $m < $a; $m++){
					if($c[$m] ne ".."){
                        if($d[$m] ne 'canada'){
                            if($highVal <= $c[$m]){
                                $highVal = $c[$m];
                                $highLoc = $d[$m];
                            }
                        }
					}
				}
				
				print("Highest: $highVal, $highLoc\n");
			}elsif(lc($userInput) eq "lowest"){
				my $lowVal = $c[0];
				my $lowLoc  = "Nothing found";
				for(my $m = 0; $m < $a; $m++){
					if($c[$m] ne ".."){
						if($lowVal >= $c[$m]){
							$lowVal = $c[$m];
							$lowLoc = $d[$m];
						}
					}
				}
				
				print("Lowest: $lowVal, $lowLoc\n");
			}elsif(lc($userInput) eq "average"){
				my $avgVal = 0;
				for(my $m = 0; $m < $a; $m++){
					if($c[$m] ne ".."){
						$avgVal = $avgVal + $c[$m];
					}
				}
				$avgVal = $avgVal /  $a;
				print("Average: $avgVal\n");
			}
        }
        elsif ( $vio eq '?' ) {
            my ( $ref, $a, $ref2 ) =
              question1( $region, $vio, $stat, $startYr, $endYr );
            @c = @$ref;
            @d = @$ref2;
            
			print("How would you like the data to be displayed: (Raw, Highest, Lowest, Average): ");
            my $userInput = getIn();
			if(lc($userInput) eq "raw"){
				for ( my $m = 0 ; $m < $a ; $m++ ) {
					$d[$m] = uc($d[$m]);
					print("$d[$m], $c[$m]\n");
				}
			} elsif(lc($userInput) eq "highest"){
				my $highVal = 0;
				my $highVio = "Nothing found";
				for(my $m = 0; $m < $a; $m++){
					if($c[$m] ne ".."){
						if($highVal <= $c[$m]){
							$highVal = $c[$m];
							$highVio = $d[$m];
						}
					}
				}
				
				print("Highest: $highVal, $highVio\n");
			} elsif(lc($userInput) eq "lowest"){
				my $lowVal = $c[0];
				my $lowVio = "Nothing found";
				for(my $m = 0; $m < $a; $m++){
					if($c[$m] ne ".."){
						if($lowVal >= $c[$m]){
							$lowVal = $c[$m];
							$lowVio = $d[$m];
						}
					}
				}
				
				print("Lowest: $lowVal, $lowVio\n");
			} elsif(lc($userInput) eq "average"){
				my $avgVal = 0;
				for(my $m = 0; $m < $a; $m++){
					if($c[$m] ne ".."){
						$avgVal = $avgVal + $c[$m];
					}
				}
				$avgVal = $avgVal /  $a;
				print("Average: $avgVal\n");
			}
        }
        else {
            my ( $ref, $a ) = question1( $region, $vio, $stat, $startYr, $endYr );
            @c = @$ref;
            
			print("How would you like the data to be displayed: (Raw, Highest, Lowest, Average): ");
            my $userInput = getIn();
			if(lc($userInput) eq "raw"){
				for ( my $m = 0 ; $m < $a ; $m++ ) {
					print("$c[$m]\n");
				}
			}elsif(lc($userInput) eq "highest"){
				my $highVal = 0;
				for(my $m = 0; $m < $a; $m++){
					if($c[$m] ne ".."){
						if($highVal <= $c[$m]){
							$highVal = $c[$m];
						}
					}
				}
				
				print("Highest: $highVal\n");
			}elsif(lc($userInput) eq "lowest"){
				my $lowVal = $c[0];
				for(my $m = 0; $m < $a; $m++){
					if($c[$m] ne ".."){
						if($lowVal >= $c[$m]){
							$lowVal = $c[$m];
						}
					}
				}
				
				print("Lowest: $lowVal\n");
			}elsif(lc($userInput) eq "average"){
				my $avgVal = 0;
				for(my $m = 0; $m < $a; $m++){
					if($c[$m] ne ".."){
						$avgVal = $avgVal + $c[$m];
					}
				}
				$avgVal = $avgVal /  $a;
				print("Average: $avgVal\n");
			}
        }

        print("Would you like to graph the data [Yes/No]: ");
        $userIn = getIn();
        
        if (lc($userIn) eq 'yes' || lc($userIn) eq 'y') {
        	if ($region eq '?') {
				$valid = 1;
				do {
					if ($valid == 0) {
						dym( $region, \@validRegions );
					}
					print "Please enter the region you would like to graph: ";
					$region = getIn();

					$valid = checkField( $region, \@validRegions );
				} while ( $valid == 0 );
				
				my @gArgs;
				$gArgs[0] = uc($vio);
				my $j = $startYr;
				my $count = 0;

				open my $fh, '>', 'in.txt';
				print $fh "\"Year\",\"Region\",\"Value\"\n";
				foreach my $i (@c) {
					if (lc($d[$count]) eq lc($region)) {
						print $fh $j.",\"".uc($region)."\",".$i."\n";
						$j++;
					}
					$count++;
				}
				close $fh;
				system($^X,"O1PA.pl", @gArgs);
            			exit();
		} else {
				my @gArgs;
				$gArgs[0] = uc($vio);
				my $j = $startYr;

				open my $fh, '>', 'in.txt';
				print $fh "\"Year\",\"Region\",\"Value\"\n";
				foreach my $i (@c) {
					print $fh $j.",\"".uc($region)."\",".$i."\n";
					$j++;
				}
				close $fh;
				system($^X,"O1PA.pl", @gArgs);
				exit();
			}
        } $userIn = -1;

    #
    #	Option 2: Cross-referencing the crime data with other data points
    #
    }
    elsif ( $userIn == 2 ) {
        print("You chose to search for a cross-referenced crime statistic:\n");
        print("	a. Cross-reference data between two crimes\n");
        print("	b. Cross-reference data between a crime and a census statistic (only the years 2001, 2006 and 2011)\n");
        print("	c. Quit to menu\n");
        do {
        	print("What would you like to cross-reference: ");
        	$userIn = getIn();
	} while ((lc($userIn) ne 'a') && (lc($userIn) ne 'b') && (lc($userIn) ne 'c'));
        if ( lc($userIn) eq 'a' ) {
            print("You chose to cross-reference data between two crimes\n");
            
			$valid = 1;
			do {
				if ($valid == 0) {
					dym( $region, \@validRegions );
				}	
                print "Region: ";
                $region = getIn();

                if ( $region eq '?' ) {
                    $unkFlag = 1;
                    $valid   = 1;
                }
                else {
                    $valid = checkField( $region, \@validRegions );
                }
            } while ( $valid == 0 );
            do {
				if ($valid == 0) {
					dym( $vio, \@validVios );
				}	
                print "Violation 1: ";
                $vio = getIn();

                $valid = checkField( $vio, \@validVios );
            } while ( $valid == 0 );
            do {
				if ($valid == 0) {
					dym( $vio1, \@validVios );
				}
                print "Violation 2: ";
                $vio1 = getIn();
                if ( uc($vio) eq uc($vio1) ) {
                    $valid = 0;
                }
                else {
                    $valid = checkField( $vio1, \@validVios );
                }
            } while ( $valid == 0 );
            do {
				if ($valid == 0) {
					dym( $stat, \@validStats );
				}
                print "Statistic: ";
                $stat = getIn();

                $valid = checkField( $stat, \@validStats );
            } while ( $valid == 0 );
            do {
                print "Start Year [1998-2015]: ";
                my $err;
                $err     = ('Start Year [1998-2015]');
                $startYr = getNum($err.': ');

                $valid = checkField( $startYr, \@validYrs );
            } while ( $valid == 0 );
            do {
                print "End Year [1998-2015]: ";
                my $err;
                $err   = ('End Year [1998-2015]');
                $endYr = getNum($err.': ');

                $valid = checkField( $endYr, \@validYrs );

                if ( $endYr < $startYr ) {
                    print("End year cannot be before the start year!\n");
                    $valid = 0;
                }
            } while ( $valid == 0 );

            my ($w, $x, $stat1Count, $y, $z, $stat2Count) = question2a($region, $vio, $vio1, $stat, $startYr, $endYr);
            my @stat1 = @$w;
            my @HReg1 = @$x;
            my @stat2 = @$y;
            my @HReg2 = @$z;

            if($region eq "?"){
                print("How would you like the data to be displayed: (Raw, Highest, Lowest, Average): ");
                my $userInput = getIn();

                if(lc($userInput) eq "raw"){
                    for(my $f = 0; $f < ($stat1Count); $f++){
                      print("$vio:$stat1[$f], $HReg2[$f]\n");
                    }
                    for(my $f = 0; $f < ($stat2Count); $f++){
                      print("$vio1:$stat2[$f], $HReg2[$f]\n");
                    }
                }elsif(lc($userInput) eq "highest"){
					my $highVio1 = 0;
					my $highVio2 = 0;
					my $hLoc1 = "Nothing found";
					my $hLoc2 = "Nothing found";
					
					for(my $m = 0; $m < $stat1Count; $m++){
						if($stat1[$m] ne ".."){
							if($HReg1[$m] ne 'canada'){
								if($highVio1 <= $stat1[$m]){
									$highVio1 = $stat1[$m];
									$hLoc1 = $HReg1[$m];
								}
							}
						}
					}
					for(my $m = 0; $m < $stat2Count; $m++){
						if($stat2[$m] ne ".."){
							if($HReg2[$m] ne 'canada'){
								if($highVio2 <= $stat2[$m]){
									$highVio2 = $stat2[$m];
									$hLoc2 = $HReg2[$m];
								}
							}
						}
					}
					print("Highest: $highVio1, $hLoc1\n");
					print("Highest: $highVio2, $hLoc2\n");
                }elsif(lc($userInput) eq "lowest"){
					my $lowVio1 = $stat1[0];
					my $lowVio2 = $stat2[0];
					my $lLoc1 = "Nothing found";
					my $lLoc2 = "Nothing found";
					
					for(my $m = 0; $m < $stat1Count; $m++){
						if($stat1[$m] ne ".."){
							if($lowVio1 >= $stat1[$m]){
								$lowVio1 = $stat1[$m];
								$lLoc1 = $HReg1[$m];
							}
						}
					}
					for(my $m = 0; $m < $stat2Count; $m++){
						if($stat2[$m] ne ".."){
							if($lowVio2 >= $stat2[$m]){
								$lowVio2 = $stat2[$m];
								$lLoc2 = $HReg2[$m];
							}
						}
					}
					print("Lowest: $lowVio1, $lLoc1\n");
					print("Lowest: $lowVio2, $lLoc2\n");
                }elsif(lc($userInput) eq "average"){
					my $AVio1 = 0;
					my $AVio2 = 0;
					
					for(my $m = 0; $m < $stat1Count; $m++){
						if($stat1[$m] ne ".."){
                            $AVio1 = $AVio1 + $stat1[$m];
						}
					}
					for(my $m = 0; $m < $stat2Count; $m++){
						if($stat2[$m] ne ".."){
                            $AVio2 = $AVio1 + $stat2[$m];
						}
					}
                    $AVio1 = $AVio1 / $stat1Count;
					$AVio2 = $AVio2 /  $stat2Count;
                    
					print("Average: $AVio1\n");
					print("Average: $AVio2\n");
                }
            }else{
            	print("How would you like the data to be displayed: (Raw, Highest, Lowest, Average): ");
                my $userInput = getIn();
				
				if(lc($userInput) eq "raw"){
					for(my $f = 0; $f < ($stat1Count); $f++){
						print("$vio:$stat1[$f], $HReg2[$f]\n");
					}
					for(my $f = 0; $f < ($stat2Count); $f++){
						print("$vio1:$stat2[$f], $HReg2[$f]\n");
					}
                }elsif(lc($userInput) eq "highest"){
					my $highVio1 = 0;
					my $highVio2 = 0;
					
					for(my $m = 0; $m < $stat1Count; $m++){
						if($stat1[$m] ne ".."){
							if($highVio1 <= $stat1[$m]){
								$highVio1 = $stat1[$m];
							}
						}
					}
					for(my $m = 0; $m < $stat2Count; $m++){
						if($stat2[$m] ne ".."){
							if($highVio2 <= $stat2[$m]){
								$highVio2 = $stat2[$m];
							}
						}
					}
					print("Highest: $highVio1\n");
					print("Highest: $highVio2\n");
				}elsif(lc($userInput) eq "lowest"){
					my $lowVio1 = $stat1[1];
					my $lowVio2 = $stat2[1];
					
					for(my $m = 0; $m < $stat1Count; $m++){
						if($stat1[$m] ne ".."){
							if($lowVio1 >= $stat1[$m]){
								$lowVio1 = $stat1[$m];
							}
						}
					}
					for(my $m = 0; $m < $stat2Count; $m++){
						if($stat2[$m] ne ".."){
							if($lowVio2 >= $stat2[$m]){
								$lowVio2 = $stat2[$m];
							}
						}
					}
					print("Lowest: $lowVio1\n");
					print("Lowest: $lowVio2\n");
				}elsif(lc($userInput) eq "average"){
					my $AVio1 = 0;
					my $AVio2 = 0;
					
					for(my $m = 0; $m < $stat1Count; $m++){
						if($stat1[$m] ne ".."){
							$AVio1 = $AVio1 + $stat1[$m];
						}
					}
					for(my $m = 0; $m < $stat2Count; $m++){
						if($stat1[$m] ne ".."){
							$AVio2 = $AVio2 + $stat2[$m];
						}
					}
					$AVio1 = $AVio1 / $stat1Count;
					$AVio2 = $AVio2 /  $stat2Count;
					
					print("Average: $AVio1\n");
					print("Average: $AVio2\n");
				}
            }
            
          print("Would you like to graph the data [Yes/No]: ");
          $userIn = getIn();

          # @stat1 = @$w;
          # @HReg1 = @$x;
          # @stat2 = @$y;
          # @HReg2 = @$z;
          if (lc($userIn) eq 'yes' || lc($userIn) eq 'y') {
              if ($region eq '?') {
                  $valid = 1;
                  do {
                      if ($valid == 0) {
                          dym( $region, \@validRegions );
                      }
                      print "Please enter the region you would like to graph: ";
                      $region = getIn();

                      $valid = checkField( $region, \@validRegions );
                  } while ( $valid == 0 );

                  my @gArgs;
                  $gArgs[0] = uc($region);
                  my $j = $startYr;
                  my $count = 0;

                  open my $fh, '>', 'in.txt';
                  print $fh "\"Year\",\"Region\",\"Value\",\"Violation\"\n";
                  foreach my $i (@stat1) {
                      if (lc($HReg1[$count]) eq lc($region)) {
                          print $fh $j.",\"".$region."\",".$i.",\"".uc($vio)."\"\n";
                          $j++;
                      }
                      $count++;
                  } 
                  $count = 0;
                  $j = $startYr;
                  foreach my $i (@stat2) {
                      if (lc($HReg2[$count]) eq lc($region)) {
                          print $fh $j.",\"".$region."\",".$i.",\"".uc($vio1)."\"\n";
                          $j++;
                      }
                      $count++;
                  }
                  close $fh;
                  system($^X,"O2PA.pl", @gArgs);
		  exit();
              } else {
                  my @gArgs;
                  $gArgs[0] = uc($region);
                  my $j = $startYr;
                  my $count = 0;

                  open my $fh, '>', 'in.txt';
                  print $fh "\"Year\",\"Region\",\"Value\",\"Violation\"\n";
                  foreach my $i (@stat1) {
                      if (lc($HReg1[$count]) eq lc($region)) {
                          print $fh $j.",\"".$region."\",".$i.",\"".uc($vio)."\"\n";
                          $j++;
                      }
                      $count++;
                  } 
                  $count = 0;
                  $j = $startYr;
                  foreach my $i (@stat2) {
                      if (lc($HReg2[$count]) eq lc($region)) {
                          print $fh $j.",\"".$region."\",".$i.",\"".uc($vio1)."\"\n";
                          $j++;
                      }
                      $count++;
                  }
                  close $fh;
                  system($^X,"O2PA.pl", @gArgs);
              	  exit();
		}
          } $userIn = -1;

        }
        elsif ( $userIn eq 'b' ) {
            print("You chose to cross-reference data between crime and census data \n");
            
			$valid = 1;
            do {
				if ($valid == 0) {
					dym( $region, \@validCenRegions );
				}
                print "Region [Province or Canada]: ";
                $region = getIn();
                if ( $region eq '?' ) {
                    $unkFlag = 1;
                    $valid   = 1;
                }
                else {
                    $valid = checkField( $region, \@validCenRegions );
                }
            } while ( $valid == 0 );
            do {
                if ($valid == 0) {
					dym( $vio, \@validVios );
				}
                print "Violation: ";
                $vio = getIn();

                $valid = checkField( $vio, \@validVios );
            } while ( $valid == 0 );
            do {
				if ($valid == 0) {
					dym( $stat, \@validStats );
				}
                print "Crime Statistic: ";
                $stat = getIn();

                $valid = checkField( $stat, \@validStats );
            } while ( $valid == 0 );
            do {
                print "Year [2001, 2006, 2011]: ";
                my $err;
                $err     = ('Year [2001, 2006, 2011]');
                $startYr = getNum( $err . ': ' );

                if ( $startYr != 2001 && $startYr != 2006 && $startYr != 2011 ) {
                    $valid = 0;
                } else {
                    $valid = 1;
                }
            } while ( $valid == 0 );
            do {
			    if ( $startYr == 2001 && $valid == 0 ) {
                    dym( $cStat, \@valid2001Census );
                }
                elsif ( $startYr == 2006 && $valid == 0 ) {
                    dym( $cStat, \@valid2006Census );
                }
                elsif ( $startYr == 2011 && $valid == 0 ) {
                    dym( $cStat, \@valid2011Census );
                }
			
			
                print "Census Statistic: ";
                $cStat = getIn();

                if ( $startYr == 2001 ) {
                    $valid = checkField( $cStat, \@valid2001Census );
                }
                elsif ( $startYr == 2006 ) {
                    $valid = checkField( $cStat, \@valid2006Census );
                }
                elsif ( $startYr == 2011 ) {
                    $valid = checkField( $cStat, \@valid2011Census );
                }
            } while ( $valid == 0 );

            if ( $region eq "?" ) {
                my ( $CRVal, $CRLoc, $CRCount, $CenVal, $CenLoc, $CenCou ) =
                  question2b( $region, $vio, $stat, $cStat, $startYr );
                @CrVAL  = @$CRVal;
                @CrLOC  = @$CRLoc;
                @CenVAL = @$CenVal;
                @CenLOC = @$CenLoc;

                print("How would you like the data to be displayed: (Raw, Highest, Lowest, Average): ");
                my $userInput = getIn();
                if ( lc($userInput) eq "raw" ) {
                    for ( my $m = 0 ; $m < $CRCount ; $m++ ) {
                        print(" Crime: $CrVAL[$m], $CrLOC[$m]\n");
                    }
                    for ( my $n = 0 ; $n < $CenCou ; $n++ ) {
                        print("Census: $CenVAL[$n], $CenLOC[$n]\n");
                    }
                }
                elsif ( lc($userInput) eq "highest" ) {
                    my $tempHigh = 0;
                    my $HLoc = "Nothing found";
                    my $tempCHigh = 0;
                    my $CHLoc = "Nothing found";
					for ( my $m = 0 ; $m < $CRCount ; $m++ ) {
						if($CrVAL[$m] ne ".."){
                            if($CrLOC[$m] ne 'canada'){
                                if ( $tempHigh <= $CrVAL[$m] ) {
                                    $tempHigh = $CrVAL[$m];
                                    $HLoc     = $CrLOC[$m];
                                }
                            }
						}
                    }
                    for ( my $m = 0 ; $m < $CenCou ; $m++ ) {
                        if ( $tempCHigh <= $CenVAL[$m] ) {
                            $tempCHigh = $CenVAL[$m];
                            $CHLoc     = $CenLOC[$m];
                        }
                    }
                    print("Highest: $tempHigh, $HLoc\n");
                    print("Highest: $tempCHigh, $CHLoc\n");

                }
                elsif ( lc($userInput) eq "lowest" ) {
                    my $tempHigh = $CrVAL[0];
                    my $HLoc = "Nothing found";
                    my $tempCHigh = $CenVAL[0];
                    my $CHLoc = "Nothing found";
                    for ( my $m = 0 ; $m < $CRCount ; $m++ ) {
						if($CrVAL[$m] ne ".."){
							if ( $tempHigh >= $CrVAL[$m] ) {
								$tempHigh = $CrVAL[$m];
								$HLoc     = $CrLOC[$m];
							}
						}
                    }
                    for ( my $m = 0 ; $m < $CenCou ; $m++ ) {
                        if ( $tempCHigh >= $CenVAL[$m] ) {
                            $tempCHigh = $CenVAL[$m];
                            $CHLoc     = $CenLOC[$m];
                        }
                    }
                    print("Lowest: $tempHigh, $HLoc\n");
                    print("Lowest: $tempCHigh, $CHLoc\n");
                }
                elsif ( lc($userInput) eq "average" ) {
                      my $avgCrimeVal;
                      my $avgCensusVal;

                      for(my $m = 0; $m < $CRCount; $m++){
                          $avgCrimeVal += $CrVAL[$m];
                      }
                      for(my $m = 0; $m < $CenCou; $m++){
                          $avgCensusVal += $CenVAL[$m];
                      }
                      $avgCrimeVal = $avgCrimeVal /  $CRCount;
                      $avgCensusVal = $avgCensusVal /  $CenCou;

                      print("Average $vio value: $avgCrimeVal\n");
                      printf("Average $cStat value: $avgCensusVal\n");
                }
            }
            else {
              	my ($CRVal, $CRCount, $CenVal, $CenCou) = question2b($region, $vio, $stat, $cStat, $startYr);
				@crimeValues = @$CRVal;
				@censusValues = @$CenVal;
				
				for(my $m = 0; $m < $CRCount; $m++){
					print("Crime: $crimeValues[$m]\n");
				}
				for(my $m = 0; $m < $CenCou; $m++){
					print("Census: $censusValues[$m]\n");
				}
            }
        
	    print("Would you like to graph the data [Yes/No]: ");
            $userIn = getIn();

            if (lc($userIn) eq 'yes' || lc($userIn) eq 'y') {
               if ($region eq '?') {
               	 $valid = 1;
                do {
                    if ($valid == 0) {
                        dym( $region, \@validCenRegions );
                    }
                    print "Please enter the region [Province or Canada] you would like to graph: ";
                    $region = getIn();

                    $valid = checkField( $region, \@validCenRegions );
                } while ( $valid == 0 );

                my @gArgs;
                $gArgs[0] = uc($region);
                my $count = 0;

                open my $fh, '>', 'in.txt';
                print $fh "\"Year\",\"Stat\",\"Value\"\n";
                foreach my $i (@CrVAL) {
                    if (lc($CrLOC[$count]) eq lc($region)) {
                        print $fh $startYr.",\"".uc($vio)."\",".$i."\n";
                    }
                    $count++;
                } $count = 0;
                foreach my $i (@CenVAL) {
                    if (lc($CenLOC[$count]) eq lc($region)) {
                        print $fh $startYr.",\"".uc($cStat)."\",".$i."\n";
                    }
                    $count++;
                } 
                close $fh;
                system($^X,"O2PB.pl", @gArgs);
		exit();
            } else {
              my @gArgs;
              $gArgs[0] = uc($region);

              open my $fh, '>', 'in.txt';
              print $fh "\"Year\",\"Stat\",\"Value\"\n";
              print $fh $startYr.",\"".uc($vio)."\",".$crimeValues[0]."\n";
              print $fh $startYr.",\"".uc($cStat)."\",".$censusValues[0]."\n";
              close $fh;
              system($^X,"O2PB.pl", @gArgs);
	          exit();
            }
     	}
     }
        $userIn = -1;
#
     #	Option 3: The help menu which prints out important formatting information
     #	to the user. Contains the specifics about each of the options
     #
    }
    elsif ( $userIn == 3 ) {
        print("General Help\n");
        print("		- The program should generally give suggestions on the input it believes you gave\n");
        print("		- Enter ? in the *REGION* field in order to search the entirity of the region\n");
        print("		- If the data is graphed the program will create the appropraite graph\n");
        print("		- NOTE: If graphing is done, a region MUST be specified\n\n");
        
        print("Q1 Help\n");
        print("		- All fields are required (aside from region, which can be set to ALL using ?)\n");
        print("		- Q1 will present data on the given violation for the appropriate regions over time\n\n");
        
        print("Q2A Help\n");
        print("		- All fields are required (aside from region, which can be set to ALL using ?)\n");
        print("		- Q2A will present a comparision of the 2 given violations for a specific region over time\n\n");
        
        print("Q2B Help\n");
        print("		- All fields are required (aside from region, which can be set to ALL using ?)\n");
        print("		- Q2B will present a comparision of the given violation and statistic for a the given year.\n");
        print("     - NOTE: Due to limitations from the census data the only valid years are: 2001, 2006, 2011\n\n");

        #
        #	Option 4: Exit program
        #
    }
    elsif ( $userIn == 4 ) {
        print("Exiting...\n");
        exit;
        #
        #	Invalid Input; thus no processing
        #
    }
    else {
        print("Please enter a valid option\n");
    }
} while ( $userIn != 4 );

#end of script
