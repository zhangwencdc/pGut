#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename dirname);
#conda activate prokka

my $query=$ARGV[0];#21ZYF2_NODE_3640_length_4789
my $file=$ARGV[1];#"clusters97.tsv";
my $out=$ARGV[2];
open(F,$file);
open(F,$file);my %cluster;my $num=0;my %cn;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	if($l=~/Plasmid_cluster/){next;}
	my @a=split"\t",$l;
	my $name=basename($a[1]);
	if($a[0]=~/$query/){
		print "$query\n";
		my $n=substr($name,0,20);
		system "prokka /home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq/$name --centre $n  --compliant  --outdir  $out/$n  --prefix  $n	  --noanno  \n";
	system "cp /home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq/$name $out/ \n";
	}
}
close F;
