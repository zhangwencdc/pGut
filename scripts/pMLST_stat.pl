#!/usr/bin/perl  
use strict;  
use warnings;  
use File::Basename;  
use File::Path 'make_path';  

my $input = "Plasmid.score";  #/home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq
# 设置PlasmidFinder数据库路径  
my $pmlst_db = '/home/zhangwen/bin/pmlst/pmlst_db//';  
my @scheme=("incac","incf","inchi1","inchi2","inci1","incn","pbssb1-family","shigella");

open(F,$input)||die;
open(OUT,">pMLST.stat");
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split",",$l;
	
	unless($a[6]>=2){next;}
	my $name=$a[0]."_".$a[1];
	system "cat */$name* >tmp\n";
	open(FILE,"tmp");my %value;
	while(1){
		my $line=<FILE>;
		unless($line){last;}
		chomp $line;
		if($line=~/^Locus/){next;}
		my @b=split "\t",$line;
		$value{$b[0]}=$b[6];
	}
	close FILE;system "rm -rf tmp\n";
	my @g=sort keys %value;
	print OUT "$l,";
	foreach my $g (@g) {
		print OUT "$g:$value{$g},";
	}
	print OUT "\n";
	
}
close F;
