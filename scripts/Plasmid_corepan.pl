#!/usr/bin/perl
use strict;
#use warnings;

#Usage:提取指定cluster序列,重新定位环化起点
#conda activate circlator

my $file=$ARGV[0];#clusters97.tsv

my $name=$ARGV[1];#20ZYF1_NODE_4119_length_2807_cov_1433.789608

my $out=$ARGV[2];#plasmid1.fasta

open(F,$file);my %cluster;my %n;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	if($a[0]=~/$name/){
		my $seq="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/".$a[1];
		my $ref="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/".$a[0];
		system "circlator fixstart --genes_fa $ref $seq tmp\n";
		open(FILE,"tmp.log");my $type=0;
		while(1){
			my $line=<FILE>;
			unless($line){last;}
			chomp $line;
			if($line=~/break_point/){next;}
			my @a=split" ",$line;
			if($a[2]=~/[0-9a-zA-Z]/){$type=1;}
		}
		close FILE;
		if($type==1){system "cat tmp.fasta >>$out\n";system "rm -rf tmp*\n";}
	}
}

close F;

