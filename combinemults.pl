#!/usr/bin/env perl

use strict;
use warnings;

###  THis script DOes a few things.

my $pathtoconsensus='/data/kayce/Marmotini_UCE/Dataset2/mult_probe_consensus/MULT_*.con';

my $taxcount=0;
my @taxarray=();
my %taxhash=();
#### get all of the taxa in an array
open FH, "</data/kayce/Marmotini_UCE/Dataset2/taxa_list.txt";
while (<FH>) {
	if (/(\S+)/) {
		my $tax=$1; push @taxarray, $tax; $taxhash{$tax}=0; $taxcount++;
	}
}
close FH;
print "There are $taxcount taxa in this dataset\n";

## get all of the UCEs and determine which have duplicates
my $probecount=0; my $uniqueprobecount=0; my $UCEnumber=0;
my %ucehash=(); my @ucearray=(); my %ucenumberhash=(); 
### dont need to change this line.
open UCE, "</data/kayce/Marmotini_UCE/5472_UCE_TamCytb.fasta";
while (<UCE>) {
	if (/^>uce-(\d+)_p\d+\s+.*probes-id:\d+,/) {
		my $uceid=$1; #  THIS IS THE UCE NAME WE WANT!  NEED TO CORRELATE IT WITH THE ONE KAYCE GAVE US
		$probecount++;
		if (! exists $ucehash{$uceid}) { 
			$ucehash{$uceid}=1; push @ucearray, $uceid; $uniqueprobecount++; $ucenumberhash{$UCEnumber} = $uceid;}
		else {$ucehash{$uceid}++;  $ucenumberhash{$UCEnumber}=$uceid;}
		$UCEnumber++;
	}
}
close UCE;
print "There are $UCEnumber  uces\n";  # right this should be the number of uces in total

### makes a list of all the multiple probe files.
my $countsingles=0; my $countmultiples=0; my $total=0;
my @singleucearray=(); my @multipleucearray=();
for my $uce (@ucearray) {
	if ($ucehash{$uce} == 1) { $countsingles++; $total=$total+1; push @singleucearray, $uce;}
	elsif ($ucehash{$uce} > 1) {$countmultiples++; $total=$total+$ucehash{$uce}; push @multipleucearray, $uce;}
}

print "There are $probecount probes\n";	
print "There are $countsingles singles and $countmultiples with more than one probe\n";
print "The number of taxa for each multiple probe will be printed to a table called Multiple_UCE_Probe_Table.txt\n";

### combine all the consensus files for each multiple  UCE and print out the total taxa for each UCE. 

my %totalucenumberhash=(); my @newmultucearray=();
my %newucehash=(); my $countnewuce=0; my $countuniqueUCEs=0;
open TABLE, ">Multiple_UCE_Probe_Table.txt";
my @filelistarray = glob($pathtoconsensus);
for my $file(@filelistarray) {
	if ($file =~ m/\S+MULT_PROBE\.(\d+)\.\S+.cat.fasta.con/) {
		my $uce=$1;
  	      	if (! exists $newucehash{$uce}) { $countuniqueUCEs++; push @newmultucearray, $uce; $newucehash{$uce}=1;}
        	else {$newucehash{$uce}++;}
	}
}

print "there are $countuniqueUCEs  multiple uces in this folder\n";

for my $uce (@newmultucearray) {
	my $counttax=0;
	open UCE, ">uce.$uce.fasta";
	for my $file(@filelistarray) { #print "$file\n";
        	if ($file =~ m/\S+MULT_PROBE\.$uce\.(\S+).cat.fasta.con/) {
			my $tax=$1; $counttax++;
			open X, "<$file";
			while (<X>) { 
				if (/^>(\S+)/) { my $contig=$1; print UCE ">$tax\_$uce\_$contig\n"; }
				else { print UCE; }
			}
		}
	}
	print "The number of taxa in this UCE $uce is $counttax\n";
	print TABLE "MULT\_$uce\t$newucehash{$uce}\n";
}
