#!/usr/bin/perl
use strict;
#use warnings;

#Usage:Plasmid 共享质粒筛查

my $file="PlasmidScore_seq.ANI";
open(O,">$file.99");
open(F,$file);my %value;my %tmp;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	if($a[0] eq $a[1]){next;}
	unless($a[2]>=99){next;}
	print O "$l\n";
	#if($a[3]>=90 && $a[4]>=90){next;}
	if(exists $tmp{$a[1]}{$a[0]}){next;}
	$tmp{$a[0]}{$a[1]}++;
	if($a[3]>=90){$value{$a[0]}++;}
	if($a[4]>=90){$value{$a[1]}++;}
}
close F;close O;

my @k=sort {$value{$b}<=>$value{$a}} keys %value;my %num;
foreach my $k (@k) {
	print "$k\t$value{$k}\n";
	$num{$value{$k}}++;
}

my @t=sort {$b<=>$a} keys  %num;
foreach my $t (@t) {

	print "$t,$num{$t}\n";
}

open(O,">$file.99.filter");#仅保留大于100个以上比对结果的plasmid和其他质粒的关系，精简结果
open(F,$file);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	if($a[0] eq $a[1]){next;}
	unless($a[2]>=99){next;}
	if($value{$a[0]}>200 || $value{$a[1]}>=200){print O "$l\n";}
}
close F;close O;