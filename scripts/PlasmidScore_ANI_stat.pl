#!/usr/bin/perl
use strict;
use warnings;

my $file=$ARGV[0];#PlasmidScore_seq.ANI

my $anicut=$ARGV[1];#97

my $aligncut=$ARGV[2];#90

my $out=$ARGV[3];

open(F,$file);
open(OUT,">$out");
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	if($a[0] eq $a[1]){next;}
	if($a[2]<$anicut){next;}
	if($a[3]<$aligncut || $a[4]<$aligncut){next;}
	print OUT "$l\n";

}
close F;
