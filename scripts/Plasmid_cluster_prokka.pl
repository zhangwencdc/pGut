#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename dirname);
my $file="clusters97.tsv";
open(F,$file);
open(F,$file);my %cluster;my $num=0;my %cn;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	if($l=~/Plasmid_cluster/){next;}
	my @a=split"\t",$l;
	my $name=basename($a[0]);
	$name=substr($name,0,length($name)-6);
	$name=substr($name,0,20);
	system "cp /home/zhangwen/project/2024Time/Analysis/PlasmidScore/prokka/$name/*.gff Cluster97_roary/gff/ \n";
}
close F;
