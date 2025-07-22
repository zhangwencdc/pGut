#!/usr/bin/perl
use strict;
#use warnings;

#Usage:统计galah结果

my $file=$ARGV[0];#cluster97.csv

open(FILE,"Plasmid.score");my %score;
while(1){
	my $l=<FILE>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split",",$l;
	my $b=$a[0]."_".$a[1];
	$score{$b}=$a[6];
	
}
close FILE;

open(FILE,"PlasmidScore_seq.ANI");my %ani;
while(1){
	my $l=<FILE>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	$ani{$a[0]}{$a[1]}=$a[2];
}
close F;

open(F,$file);my %cluster;my %n;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	$cluster{$a[0]}++;
	$n{$a[0]}+=$ani{$a[0]}{$a[1]};
}

close F;

my @k=sort {$cluster{$b}<=>$cluster{$a}} keys %cluster;
print "Plasmid_cluster\tScore\tNum of plasmid\tAverage ANI\n";
foreach my $k (@k) {
	my $b=substr($k,17,length($k)-23);
	#print "$b\n";
	#if($score{$b}>=3){
		my $avg=$n{$k}/$cluster{$k};
	print "$b\t$score{$b}\t$cluster{$k}\t$avg\n";
	#}
}