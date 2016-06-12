#!/usr/bin/env perl

use strict;
use warnings;


my $taxcount=0;
my @taxarray=();
my %taxhash=();

### assumes all the best files are unzipped in a folder. 

# Change this path and file to the next taxon list 
open FH, "</data/kayce/Marmotini_UCE/Dataset1/taxa_list.txt";
#open FH, "<tax_list.txt";
while (<FH>) {
	if (/(\S+)/) {
		my $tax=$1;
		push @taxarray, $tax;
		$taxhash{$tax}=0;
		$taxcount++;
	}
}

print "there are $taxcount taxa in this dataset\n";

#for each taxon goes into the best file nad finds the longest sequence rather than the top sequene.
my $counttax=0;
for my $tax(@taxarray) { print "$counttax\t$tax\n"; $counttax++;
	`ls -l /data/kayce/Marmotini_UCE/Dataset1/Dataset1/best/*.$tax.* >filenames.txt`;
	open FH1, "<filenames.txt";
	while (<FH1>) {
		### customize for the best files
		if (/(\S+)\/UlamV5.(\S+).best.fasta/) {
			my $path=$1;
			my $file=$2;  #print "path $path\n";
			#print "file $file\n";
			$taxhash{$tax}++;
			open FH2, "<$path\/UlamV5.$file.best.fasta";
			$file =~ s/.fasta//g;
			$file =~ s/.out//g;
			open OUTx, ">$file.longest.fasta";
			my $length=0;
			my %contighash=();
			my @contigarray=();
			my @lengtharray=();
			my $contig;
			while (<FH2>) {
				if (/^>(.*)/) {  #print;
					$contig=$1;
					$contighash{$contig}=0;
					push @contigarray, $contig;
				}
				else {
					my $seq=$_;
					$contighash{$contig}=$seq;
					my $length=length($seq);
					push @lengtharray, $length;
				}
			}
			my $pos=0;							
			for my $len (@lengtharray) {
				# 2 13 472
				if ($len > $length) {
					$length = $len;
					$contig = $contigarray[$pos];
				}
				$pos++;
			}
			print OUTx ">$contig\n$contighash{$contig}\n";
		}
	}
}


open TABLE, ">Num.BestFiles.taxa";
print TABLE "Taxa\tTotalnumberofBestFiles\n";
for my $tax(@taxarray) {
	print "$tax\t$taxhash{$tax}\n";
	print TABLE "$tax\t$taxhash{$tax}\n";
} 
