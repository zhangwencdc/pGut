#!/usr/bin/perl
use strict;
#use warnings;
use File::Basename qw(basename dirname);
#Usage:基于galah的99%聚类结果得到的plasmid cluster，用ska方法构建tree
#conda activate ska
my $file=$ARGV[0];#clusters99.stat
my $list=$ARGV[1];#clusters99.txt

my $cut=$ARGV[2];#100

my %info;
open(F,"SampleID.txt");
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	$info{$a[0]}=$l;
}

close F;
my @sample=keys %info;
open(F,$file);my %cluster;my $num=0;my %cn;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	if($l=~/Plasmid_cluster/){next;}
	my @a=split"\t",$l;
	unless($a[2]>=$cut){next;}
	$num++;
	$cluster{$num}=$a[0];
	$cn{$a[0]}=$num;
	my $cn="PlasmidCluster".$num;
	print "$cn\n";
	system "mkdir $cn";
	print "$cn\t$a[0]\t$a[2]\n";
}
close F;

#生成plasmid cluster list
open(LIST,$list);
while(1){
	my $line=<LIST>;
	unless($line){last;}
	chomp $line;
	my @a=split "\t",$line;
	my $n1=basename($a[0]);
	my $n2=basename($a[1]);
	$n1=substr($n1,0,length($n1)-6);
	$n2=substr($n2,0,length($n2)-6);
	if(exists $cn{$n1}){$cn{$n2}=$cn{$n1};
		my $cn="PlasmidCluster".$cn{$n1};
		open(OUT,">>$cn/$cn.list");
		print OUT "$n2\n";close OUT;
	}
	
}
close LIST;

my @key =sort keys %cluster;

foreach my $key (@key) {
	my $cn="PlasmidCluster".$key;
	open(F,"$cn/$cn.list");open(O,">$cn/$cn.info");
	while(1){
		my $l=<F>;
		unless($l){last;}
		chomp $l;
		foreach my $sample (@sample) {
			if($l=~/^$sample/){
				print O "$l\t$sample\t$info{$sample}\n";
			}
		}
		system "cp /home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq/$l.fasta $cn/$l.fasta\n";
		system "ska fasta -c $cn/$l.fasta -o $cn/$l \n";
	}
	system "ska merge $cn/*.skf -o $cn/$cn \n";
	system "ska align -v -o $cn/$cn $cn/$cn.skf \n";
	my $a1=$cn."/".$cn."_variants.aln";
	system "fasttree -gtr -nt $a1 > $a1.newick\n";
	close OUT;
}
