#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename dirname);
#Ѱ������cluster���Ƿ���С�����ṹ��Ҳ���ǳ�ͷ��ͬ��core seq������β��ͬ��Я������ͨ����
#����ANI���㣬ͬ��һ��cluster��plasmid���У�ani>97%,align <50% ���г�

my $file="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq.ANI";
my $cluster="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/clusters97.tsv";


open(F,$cluster);my %cluster;my %num;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split"\t",$l;
	my $name=basename($a[1]);
	my $cluster=basename($a[0]);
	my @sample=split"_",$name;
	my $sample=shift @sample;
	$cluster{$name}=$cluster;
	$num{$cluster}++;
}
close F;

open(FILE,$file);
my $out="truck.out";

open(OUT,">$out");my %candidate;
while(1){
	my $l=<FILE>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	my $q=basename($a[0]);
	my $t=basename($a[1]);
	unless($a[2]>=97){next;}
	unless($a[3]<=50 && $a[4]<=50){next;}
	unless($cluster{$q} eq $cluster{$t}){next;}
	print OUT "$cluster{$q}\t$num{$cluster{$q}}\t$l\n";
	$candidate{$q}++;
}
close FILE;

my @q=sort keys %candidate;
foreach my $q (@q) {
	print "$q\t$candidate{$q}\n";
}
