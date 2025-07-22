#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;

my $f=$ARGV[0];#/home/zhangwen/project/2024Time/Analysis/Circular/
my @file=glob "$f/*.fasta";

foreach my $file (@file) {
	my $name=basename($file);
	if($name=~/.assembled.fasta/){$name=substr($name,9,length($name)-9-16);}
	if($name=~/.fasta/){$name=substr($name,9,length($name)-9-6);}
	#print "$name\n$file\n";
	open(F,$file);
	while(1){
		my $l=<F>;
		unless($l){last;}
		chomp $l;
		if(substr($l,0,1) eq ">"){
			my $seq=substr($l,1);
			my @a=split " ",$seq;
			my @b=split"_",$a[0];
			if($b[3]>=1000 && $b[5]>=10){
			print "$name\t$a[0]\t$b[3]\t$b[5]\n";
			}
		}
	}
	close F;
}