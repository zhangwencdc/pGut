#!/usr/bin/perl
use strict;
#use warnings;

#Usage:提取指定cluster序列,assemble,重新定位环化起点
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
		system "cat $a[1] >>tmp1.fasta\n";
	}
}

close F;

#system "circlator assemble tmp1.fasta tmp2\n";

#system "circlator clean tmp2/scaffolds.fasta tmp3\n";
#system "circlator fixstart tmp3.fasta tmp4\n";
#system "mv tmp4.fasta $out\n";
#system "rm -rf tmp*\n";