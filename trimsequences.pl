#!/usr/bin/env perl

use strict;
use warnings;

my $path = "/data/kayce/Marmotini_UCE/Dataset2/mult_probe_consensus/*.aligned.fasta"; 
my @filenames = glob($path);  

### edit the fasta file
for my $file(@filenames) {
	$file =~ s/\.fasta.aligned.fasta//g;
	open OUT, ">$file.aligned.ed.fasta";
	open FH, "<$file.fasta.aligned.fasta";
	while (<FH>) {
		if (/^>(\S+)/) { 	my $name=$1; 	print OUT "\n>$name\n"; }
		elsif (/(\S+)/) {	my $seq=$1; print OUT "$seq";}
	}
}

my $path2 = "/data/kayce/Marmotini_UCE/Dataset2/mult_probe_consensus/*.ed.fasta"; 
my @newfiles = glob($path2);  

for my $file (@newfiles) { #print "$file\n";
	$file =~ s/\.ed.fasta//g;
	my $numtax=`grep ">" -c  $file.ed.fasta`;
	$numtax =~ s/(\d+)\s+\S+/$1/g;
	my $half = $numtax/2;
	print "$file\t$numtax\t$half\n";
	open FHX, "<$file.ed.fasta";
	my @begarray=();
	my @endarray=();
	my @wholearray=();
	while (<FHX>) {
		if (/(\S+)/ && ! /^>/) {
			my $seq=$1;
			chomp $seq;
			my $whole=length($seq);
			#print "$seq\n";
			$seq =~ s/^-*(\S+)$/$1/g;
			#print "$seq\n";
			my $begl = length($seq);
			my $beg = $whole - $begl;
			$seq =~ s/^(\S+?)\-*$/$1/g;
			my $endl = length($seq) + $beg;;
			my $end = $whole - $endl;
			#print "$seq\n";
			push @wholearray, $whole;
			push @endarray, $end;
			push @begarray, $beg; 
			print "$file\t$whole\t$beg\t$end\n";
		}

	}
	close FHX;
	for my $each(@endarray) { print "$each\n";}
	print "END OF FIRST\n";
	my @begsorted = sort { $a <=> $b } @begarray;  
	my @endsorted = sort { $a <=> $b } @endarray;   for my $each (@endsorted) { print "$each\n";}
	my $midend = $endsorted[$half];
	my $midbeg = $begsorted[$half];
	my $alignmentlength = $wholearray[0];
	print "median beginning gap $midbeg\t median end gap $midend\n";
 	my $targetlength=$alignmentlength - $midend - $midbeg;
	open FH2, "<$file.ed.fasta";
	open OUT2, ">$file.trimmed.fasta";
	while (<FH2>) {
		if (/^>/) { print OUT2; }
		elsif (/(\S+)/) {
			my $seq=$1;
			chomp $seq;
			$seq =~ s/^.{$midbeg}(\S+?).{$midend}$/$1/;
			my $newlength=length($seq);	
			print "Target length $targetlength\tActual length $newlength\n";
			print OUT2 "$seq\n";
		}
	}
}
