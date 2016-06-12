#!usr/bin/env perl

use strict;
use warnings;

### after the getlongest script move the longest files to a new directory.

my $path = "/data/kayce/Marmotini_UCE/Dataset1/Dataset1/best/*.fasta";
my @filenames = glob($path);  

for my $files (@filenames) {
	`mv $files /data/kayce/Marmotini_UCE/Dataset1/best/`;
}


