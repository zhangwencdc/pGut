#!/usr/bin/perl  
use strict;  
use warnings;  
use File::Basename;  
use File::Path 'make_path';  
#conda activate pmlst
# 设置FASTA文件所在的路径  
my $input = "/home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq.list";  #/home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq
# 设置PlasmidFinder数据库路径  
my $pmlst_db = '/home/zhangwen/bin/pmlst/pmlst_db//';  
my @scheme=("incac","incf","inchi1","inchi2","inci1","incn","pbssb1-family","shigella");
system "mkdir incac incf inchi1 inchi2 inci1 incn pbssb1-family shigella\n";
open(F,$input)||die;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	foreach my $scheme (@scheme) {
		system "python /home/zhangwen/bin/pmlst/pmlst.py -s $scheme -i /home/zhangwen/project/2024Time/Analysis/PlasmidScore/$l -p /home/zhangwen/bin/pmlst/pmlst_db/ -q -x\n";
		my @b=split"/",$l;
		my $out=$b[1]."_".$scheme."_pMLST";
		#print "$out\n";
		print "mv results_tab.tsv $scheme/$out\n";
		#system "mv results_tab.tsv $scheme/$out\n";
	}
}
close F;
