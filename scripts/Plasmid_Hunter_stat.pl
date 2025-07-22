#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename dirname);

#统计PlasmidHunter预测的质粒结果
#仅保留length>=1kb且cov>=10的结果
#仅保留plasmid得分>=0.9的结果

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
