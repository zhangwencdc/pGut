#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename dirname);

#ͳ��PlasmidHunterԤ����������
#������length>=1kb��cov>=10�Ľ��
#������plasmid�÷�>=0.9�Ľ��

my $f=$ARGV[0];#/home/zhangwen/project/2024Time/Analysis/PlasmidHunter

my @file=glob "$f/*/predictions.tsv";

foreach my $file (@file) {
	my $name=dirname($file);
	#$name=substr($name,0,length($name)-20);
	if($name=~/.assembled/){$name=substr($name,0,length($name)-10);}
	open(F,$file);
	while(1){
		my $l=<F>;
		unless($l){last;}
		chomp $l;
		my @a=split"\t",$l;
		unless($a[1]>=0.9){next;}
			my @b=split"_",$a[0];
			if($b[3]>=1000 && $b[5]>=10){
			print "$name\t$a[0]\t$b[3]\t$b[5]\n";
			}
		
	}
	close F;
}
