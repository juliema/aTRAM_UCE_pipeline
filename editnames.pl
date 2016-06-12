#!usr/bin/env perl

use strict;
use warnings;
my $input = $ARGV[0];
#'RAxML_bestTree.uce-1127.NoNs.aligned.trimmed.fasta.out';
my $output = $ARGV[1];
#RAxML_bestTree.uce-1127.NoNs.aligned.trimmed.fasta.names.out';


my @namearray=();
my %namehash=();
my $count=0;

open NAME, "<taxa_list.txt";
while (<NAME>) {
	if (/(\S+)/) {
		my $name=$1;
		if ($name =~ s/\s+/_/g) {}
		$namehash{$name}=$name;
		$count++;
		push @namearray, $name;
	}
}
print "$count\n";

open OUT, ">$output";
open TRE, "<$input";
while (<TRE>) {
	my  $line=$_;
	for my $name (@namearray) {
		if ($line =~ m/^>/) {
			#chomp $line;
			$line =~ s/>$name\_\d+_\d+\.\d+_len_\d+_cov_\d+\.\d+([:,;])/>$name$1/g;
			$line =~ s/>$name\_\S+_MULT_PROBE.\S+/>$name/g;
		}
		else {
			$line =~ s/$name\_\d+_\d+\.\d+_len_\d+_cov_\d+\.\d+([:,;])/$name$1/g;
			#Tanimus_ZM11420_77_MULT_PROBE.77.Tminimus_ZM11420.cat.fasta,
			$line =~ s/$name\_\d+_MULT_PROBE.\d+.$name.cat.fasta/$name/g;
		}
	}
	print OUT "$line"
}
