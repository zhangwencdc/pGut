#!/usr/bin/perl
use strict;
use warnings;

my $file=$ARGV[0];#HMP.txt
open(F,$file);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	if($a[5]=~/[0-9a-zA-Z]/){
		my $link="https://downloads.hmpdacc.org/".$a[5];
		system "wget -c $link --no-check-certificate\n";
	}
}
close F;