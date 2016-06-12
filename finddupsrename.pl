#!/usr/bin/env perl

use strict;
use warnings;

###  THis script DOes a few things.

open TBLE, ">UCE_Num_table.txt";
print TBLE "UCE,Number of Taxa\n";
my $pathtolongest='/data/kayce/Marmotini_UCE/Dataset1/longest';
my $pathlongfiles = "/data/kayce/Marmotini_UCE/Dataset1/longest/*.longest.fasta";
my $pathmult = '/data/kayce/Marmotini_UCE/Dataset1/multipleuces';
my $pathsing = '/data/kayce/Marmotini_UCE/Dataset1/singluces';
#UCE1522.Ovariegatus_NK154108.longest.fasta

my $taxcount=0;
my @taxarray=();
my %taxhash=();
#### get all of the taxa in an array
open FH, "</data/kayce/Marmotini_UCE/Dataset1/taxa_list.txt";
while (<FH>) {
	if (/(\S+)/) {
		my $tax=$1; push @taxarray, $tax; $taxhash{$tax}=0; $taxcount++;
	}
}
close FH;
print "There are $taxcount taxa in this dataset\n";

## get all of the UCEs and determine which have duplicates
my $probecount=0; my $uniqueprobecount=0; my $UCEnumber=1;
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

my $totalnumberedfiles = $UCEnumber-1;  
print "There are $totalnumberedfiles uces\n";  # righ this should be the number of uces in total


### makes a list of all the multiple probe files.
my $countsingles=0; my $countmultiples=0; my $total=0;
my @singleucearray=(); my @multipleucearray=();
open OUTU, ">UCE_Probe_Table.txt";
print OUTU "ProbeName\tNumberofProbes\n";
for my $uce (@ucearray) {
	print OUTU "$uce\t$ucehash{$uce}\n";	
	if ($ucehash{$uce} == 1) { $countsingles++; $total=$total+1; push @singleucearray, $uce;}
	elsif ($ucehash{$uce} > 1) {$countmultiples++; $total=$total+$ucehash{$uce}; push @multipleucearray, $uce;}
}

print "There are $probecount probes\n";	
print "There are $countsingles singles and $countmultiples with more than one probe\n";
print "making a total of $total  The numbers for each probe have been printed to a table called UCE_Probe_Table.txt\n";

### print out the multiples to another file
open IDNumber, ">Multiple_UCEid_table.txt";
print IDNumber "UCE_probeID,Number of Probes, UCE assigned Numbers\n";
for my $uce (@multipleucearray) {
	my @numberarray=();
	#print "$uce\t$ucehash{$uce}\t";
	print IDNumber "$uce\t$ucehash{$uce}\t";
	for (1 .. $totalnumberedfiles) {
		my $num=$_;
	#	print "$uce\t$ucenumberhash{$num}\n";
		if ($ucenumberhash{$num} == $uce) {
			#print "$num\t";
			print IDNumber "$num\t";
		}
	}
	#print "\n";
	print IDNumber "\n";
}

close IDNumber;

###### first run through the multiples and sort them out
####   make cat files of all the individual sequences for the uces with multiples
for my $tax(@taxarray) {
	print "$tax\n";
	for my $uce (@multipleucearray) {
		my @numberarray=();
		open CAT, ">$pathmult\/MULT_PROBE.$uce.$tax.cat.fasta";
		for (1 .. $totalnumberedfiles) {
			my $num=$_;
			if ($ucenumberhash{$num} == $uce) {
				##UCE1522.Ovariegatus_NK154108.longest.fasta
				my $len = length($num);
				if ($len < 4) { #print "length is $len\n";
					if ($len == 3) { #print "length is three\n";
					#	print "$pathtolongest\/UCE0$num.$tax.longest.fasta\n";
						if (-e "$pathtolongest\/UCE0$num.$tax.longest.fasta" ) { open FHx, "<$pathtolongest\/UCE0$num.$tax.longest.fasta";
						while (<FHx>) { print CAT;  }     #print; }
					}}
					elsif ($len == 2) {  #print "length is two\n";
						if (-e "$pathtolongest\/UCE00$num.$tax.longest.fasta" ) { 
						open FHx, "<$pathtolongest\/UCE00$num.$tax.longest.fasta";
						while (<FHx>) { print CAT; }
					}}
					elsif ($len == 1) { #print "length is one\n";
						if (-e "$pathtolongest\/UCE000$num.$tax.longest.fasta" ) { 
						open FHx, "<$pathtolongest\/UCE000$num.$tax.longest.fasta";
						while (<FHx>) { print CAT; } #print; }
					}}
				}
				else {
					if (-e "$pathtolongest\/UCE$num.$tax.longest.fasta" ) { 
					open FHx, "<$pathtolongest\/UCE$num.$tax.longest.fasta";
					while (<FHx>) { print CAT; }
				}}
			}
		}
	}
}

### HERE!!!!
print "The multiple probes are all printed to files starting with the word MULT_PROBE.\n";
#for my $tax(@taxarray) { #print "$counttax\t$tax\n"; $counttax++;
#	`ls -l $pathtolongest\/*.$tax.* >filenames`;
#	open FH1, "<filenames";
#}
#Now need to get all the longest files and rename them.  Output one file per uce
my $counttax=0;
#my @filenames = glob($pathlong);
my %totalucenumberhash=();
my @listarray = glob($pathlongfiles);
for my $uce(@singleucearray) {
	$totalucenumberhash{$uce}=0;
	for (1 .. $totalnumberedfiles) {
		my $num=$_;
		my $len = length($num);
		if ($ucenumberhash{$num} == $uce) {
			open UCE, ">$pathsing\/uce-$uce.fasta";
			if ($len < 4) { #print "length is $len\n";
				if ($len == 3) { #print "length is three\n";
					for my $file (@listarray) { #print "$file\n";
						#UCE5472.Tsibiricus_NK224722.longest.fasta
						if ($file =~ m/\S+UCE0$num\.(\S+).longest.fasta/) {
							my $tax=$1;
							$totalucenumberhash{$uce}++;
							open X, "<$file";
							while (<X>) { 
								if (/^>(\S+)/) { my $contig=$1; print UCE ">$tax\_$uce\_$contig\n"; }
								else { print UCE; }
							}
						}
					}
				}
				elsif ($len == 2) { #print "length is three\n";
					for my $file (@listarray) { #print "$file\n";
						if ($file =~ m/\S+UCE00$num\.(\S+).longest.fasta/) {
							my $tax=$1;
							$totalucenumberhash{$uce}++;
							open X, "<$file";
							while (<X>) { 
								if (/^>(\S+)/) { my $contig=$1; print UCE ">$tax\_$uce\_$contig\n"; }
								else { print UCE; }
							}
							while (<X>) { print UCE; }
						}
					}
				}
				elsif ($len == 1) { #print "length is three\n";
				#	print "$pathtolongest\/UCE0$num.$tax.longest.fasta\n";
					for my $file (@listarray) { #print "$file\n";
						if ($file =~ m/\S+UCE000$num\.(\S+).longest.fasta/) {
							my $tax=$1;
							$totalucenumberhash{$uce}++;
							open X, "<$file";
							while (<X>) { 
								if (/^>(\S+)/) { my $contig=$1; print UCE ">$tax\_$uce\_$contig\n"; }
								else { print UCE; }
							}
						}
					}
				}
			}
			else {
				for my $file (@listarray) {
					if ($file =~ m/\S+UCE$num\.(\S+).longest.fasta/) {
						my $tax=$1;
						$totalucenumberhash{$uce}++;
						open X, "<$file";
						while (<X>) { 
							if (/^>(\S+)/) { my $contig=$1; print UCE ">$tax\_$uce\_$contig\n"; }
							else { print UCE; }
						}
					}
				}
			}
		}
	}
	print TBLE "UCE-$uce,$totalucenumberhash{$uce}\n";
}
