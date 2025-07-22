#!/usr/bin/perl  
use strict;  
use warnings;  
use File::Basename;  
use File::Path 'make_path';  
#conda activate prokka
# 设置FASTA文件所在的路径  
my $input = "/home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq.list";  #/home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq

open(F,$input)||die;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my $seq="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/".$l;
	my $name=basename($l);
	$name=substr($name,0,length($name)-6);
	$name=substr($name,0,20);
	#print "$name\n";
	open(SEQ,$seq);
	open(OUT,">tmp");
	while(1){
		my $l=<SEQ>;
		unless($l){last;}
		chomp $l;
		if(substr($l,0,1) eq ">"){print OUT ">$name\n";}else{print OUT "$l\n";}
	}
	close SEQ;
	close OUT;
	system "prokka tmp    --outdir  $name  --prefix  $name     --noanno \n";
	
}
close F;
