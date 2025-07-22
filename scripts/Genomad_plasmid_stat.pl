#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;

#ͳ��genomadԤ����������
#������length>=1kb��cov>=10�Ľ��

my $f=$ARGV[0];#/home/zhangwen/project/2024Time/Analysis/Genomad/Out

my @file=glob "$f/*_summary/*_plasmid_summary.tsv";

foreach my $file (@file) {
	my $name=basename($file);
	$name=substr($name,0,length($name)-20);
	if($name=~/.assembled/){$name=substr($name,0,length($name)-10);}
	open(F,$file);
	while(1){
		my $l=<F>;
		unless($l){last;}
		chomp $l;
		my @a=split"\t",$l;
			my @b=split"_",$a[0];
			if($b[3]>=1000 && $b[5]>=10){
			print "$name\t$a[0]\t$b[3]\t$b[5]\n";
			}
		
	}
	close F;
}
