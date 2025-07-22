#!/usr/bin/perl
use strict;
#use warnings;
use File::Basename qw(basename); 
#对于重复两次的序列，剔除尾巴

my @file=glob "/home/zhangwen/project/2024Time/Analysis/PlasmidScore/21ZYF2_NODE_3640_length_4789/fixstart2//*.fasta";
my $query="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/21ZYF2_NODE_3640_length_4789/pGut1_start.fasta";

foreach my $f (@file) {
	system "blat $f $query tmp.blat\n";
	open(F,"tmp.blat");my $t=0;my $s=0;my $ch;
	while(1){
		my $l=<F>;
		unless($l){last;}
		chomp $l;
		my @a=split" ",$l;
		if($a[0]>=1000){$t++;
		print "$l\n$a[15]\n";
			if($a[15]>$s){$s=$a[15];$ch=$a[13];}
		}
	}
	if($t>1){
		$s++;
		my $re="1:".$s;
		my $fname=basename($f);
		print"seqkit subseq --chr $ch --region $re $f >/home/zhangwen/project/2024Time/Analysis/PlasmidScore/21ZYF2_NODE_3640_length_4789/fixstart3/$fname\n";
		system "seqkit subseq --chr $ch --region $re $f >/home/zhangwen/project/2024Time/Analysis/PlasmidScore/21ZYF2_NODE_3640_length_4789/fixstart3/$fname\n";
	}else{
		system "cp $f /home/zhangwen/project/2024Time/Analysis/PlasmidScore/21ZYF2_NODE_3640_length_4789/fixstart3/ \n";
	}
	close F;
}