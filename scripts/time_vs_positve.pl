#!/usr/bin/perl
use strict;
use warnings;

#��ֲʱ���positive%��Ĺ�ϵ
open(F,"plasmid_postive_rate.txt");
my %pos;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	$pos{$a[0]}=$a[2];

}
close F;

my %n;my %t;
open(F,"Plasmid_question2_time.txt");

while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	$n{$a[0]}++;
	$t{$a[0]}+=$a[7];
}
close F;
my @p=sort keys %n;
open(OUT,">Plasmid_question2_time_vs_positve.txt");
foreach my  $p(@p) {
	if(exists $pos{$p}){
		print OUT "$p,$pos{$p},";
		my $v=$t{$p}/$n{$p};
		print OUT "$v\n";
	}
}