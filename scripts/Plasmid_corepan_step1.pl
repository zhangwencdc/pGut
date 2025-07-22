#!/usr/bin/perl
use strict;
#use warnings;
use File::Basename qw(basename dirname);

#Usage:提取指定cluster序列,prokka，为后续roary作准备
#conda activate prokka

my $file=$ARGV[0];#clusters97.tsv

my $name=$ARGV[1];#20ZYF1_NODE_4119_length_2807_cov_1433.789608

my $out=$ARGV[2];#plasmid1

system "mkdir $out\n";
open(F,$file);my %cluster;my %n;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	if($a[0]=~/$name/){
		my $seq="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/".$a[1];
		system "cp $seq $out/\n";
	}
}

close F;

my @file=glob "$out/*.fasta";

foreach my $file (@file) {
	my $key=substr(basename($file),0,length(basename($file))-6);
	system "prokka $file --prefix $key --outdir $out --centre X --compliant --force\n";
}
