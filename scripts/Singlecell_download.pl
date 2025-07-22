#!/usr/bin/perl
use strict;
use warnings;

my $file=$ARGV[0];

open(F,$file);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless($l=~/_Sample_14/){next;}#仅下载一个样本的2000余个细胞的数据
	my @a=split",",$l;
	my $id=$a[0];
	system "prefetch $id \n";
	system "fastq-dump $id/$id.sra\n";
	system "rm -rf $id\n";
	
}

close F;