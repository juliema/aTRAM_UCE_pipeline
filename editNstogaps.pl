#!usr/bin/env perl

use strict;
use warnings;

### after the getlongest script move the longest files to a new directory.

my $path = "/data/kayce/Marmotini_UCE/Dataset2/mult_probe_consensus/*.fasta"; 
my @filenames = glob($path);  

for my $files (@filenames) {
	if ($files =~ m/NoNs.fasta/) {}
	else {
		$files =~ s/\.fasta//g;
		open OUT, ">$files.NoNs.fasta";
		open FH1, "<$files.fasta";
		while (<FH1>) {
			if (/^>/) {
				print OUT;
			}
			elsif (/(\S+)/) {
				my $seq=$1;
				chomp $seq;
				$seq =~ s/N/-/g;
				$seq = uc($seq);
				print OUT "$seq\n";
			}
		}
	}
}
