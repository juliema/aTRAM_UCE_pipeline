#!/usr/bin/env perl

use strict;
use warnings;

my $taxcount=0;
my @taxarray=();
my %taxhash=();
#### get all of the taxa in an array
my $probecount=0; my $uniqueprobecount=0; my $UCEnumber=1;
my %ucehash=(); my @ucearray=(); my %ucenumberhash=(); 
open UCE, "</data/kayce/Marmotini_UCE/5472_UCE_TamCytb.fasta";
while (<UCE>) {
	if (/^>uce-(\d+)_p\d+\s+.*probes-id:\d+,/) {
			my $uceid=$1;
			$probecount++;
			if (! exists $ucehash{$uceid}) { 
				$ucehash{$uceid}=1; push @ucearray, $uceid; $uniqueprobecount++; $ucenumberhash{$UCEnumber} = $uceid;}
			else {$ucehash{$uceid}++;  $ucenumberhash{$UCEnumber}=$uceid;}
			$UCEnumber++;
	}
	elsif (/^>/) { print; }
}
my $totalnumberedfiles = $UCEnumber-1;
#print "There are $totalnumberedfiles uce numbered files\n";

my $countsingles=0; my $countmultiples=0; my $total=0;
my @singleucearray=(); my @multipleucearray=();
for my $uce (@ucearray) {
#	print OUTU "$uce\t$ucehash{$uce}\n";	
	if ($ucehash{$uce} == 1) { $countsingles++; $total=$total+1; push @singleucearray, $uce;}
	elsif ($ucehash{$uce} > 1) {$countmultiples++; $total=$total+$ucehash{$uce}; push @multipleucearray, $uce;}
	else { print "$uce\n"; }
}

print "There are $probecount probes\n";	
print "There are $countsingles singles and $countmultiples with more than one probe\n";
print "making a total of $total  The numbers for each probe have been printed to a table called UCE_Probe_Table.txt\n";


