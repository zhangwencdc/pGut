#!/usr/bin/perl
use strict;
use warnings;

#ͳ��plasmid cluster�ķֲ���Ϣ �γɾ����б�
my $file="SampleID.txt";
my %project;my %region;my %time;
open(F,$file);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	$project{$a[0]}=$a[1];
	$region{$a[0]}=$a[1];
	$time{$a[0]}=$a[1];
}
close F;