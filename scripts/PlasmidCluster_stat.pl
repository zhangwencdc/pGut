#!/usr/bin/perl
use strict;
use warnings;

#统计plasmid cluster的分布信息 形成矩阵列表
my $file="SampleID.txt";
my %project;my %region;my %time;
open(F,$file);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	$project{$a[0]}=$a[1];
	$region{$a[0]}=$a[1];
	$time{$a[0]}=$a[1];
}
close F;