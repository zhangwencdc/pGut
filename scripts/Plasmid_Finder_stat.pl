#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename dirname);

#统计PlasmidFinder预测的质粒结果
#仅保留length>=1kb且cov>=10的结果
#

my $f=$ARGV[0];#/home/zhangwen/project/2024Time/Analysis/PlasmidFinder

my @file=glob "$f/*/results_tab.tsv";

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
		
			my @b=split"_",$a[4];
			if($b[3]>=1000 && $b[5]>=10){
			print "$name\t$a[4]\t$b[3]\t$b[5]\t$l\n";
			}
		
	}
	close F;
}
