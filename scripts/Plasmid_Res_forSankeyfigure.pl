#!/usr/bin/perl
use strict;
use warnings;
#剔除仅含有一个耐药基因，或者仅存在一个质粒上的ARG，缩减数据，用于绘制桑葚图

my $file="Plasmid_cluster.res.v2";

my %sample;my %arg;

open(F,$file);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	$sample{$a[0]}++;
	$arg{$a[1]}++;

}
close F;


open(OUT,">Plasmid_cluster.res.v3");

open(F,$file);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	if($sample{$a[0]}==1 || $arg{$a[1]}==1){next;}
	print OUT "$l\n";
}
close F;
close OUT;