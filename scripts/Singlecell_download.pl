#!/usr/bin/perl
use strict;
use warnings;

my $file=$ARGV[0];

open(F,$file);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless($l=~/_Sample_14/){next;}#������һ��������2000���ϸ��������
	my @a=split",",$l;
	my $id=$a[0];
	system "prefetch $id \n";
	system "fastq-dump $id/$id.sra\n";
	system "rm -rf $id\n";
	
}

close F;