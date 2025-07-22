#!/usr/bin/perl
use strict;
#use warnings;
use Data::Dumper;
use File::Basename qw(basename dirname);
#统计res基因存在于哪些plasmid cluster里

my $file=$ARGV[0];#Plasmid_Res.txt
my $cluster=$ARGV[1];#clusters97.tsv
my $circular="PlasmidScore/Circular_stat.v2";
my %cir;
open(F,$circular);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split"\t",$l;
	my $name=$a[0]."_".$a[1];
	#print "$name\n";
	$cir{$name}++;
}
close F;

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

open(F,$file);
open(OUT,">$file.cluster");
open(O,">Plasmid_cluster.res");my %res;my %gene;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	if($l=~/^FileName/){next;}
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split"\t",$l;
	my $name=basename($a[0]);
	print OUT "$l\t$cir{$a[2]}\t$cluster{$name}\t$num{$cluster{$name}}\n";
	$res{$cluster{$name}}{$a[1]}++;$gene{$a[1]}++;
	
}
close F;
close OUT;

my @gene=keys %gene;my @cluster=keys %res;
print O "Cluster\tNum of Plasmid\tRes Gene\tPlasmid Num with Res\n"; my %cn;
foreach my $cluster (@cluster) {
	foreach my $gene (@gene) {
		#unless($gene=~/[0-9a-zA-Z]/){next;}
		#print "$gene,$cluster,$res{$cluster}{$gene}\n";
		if(exists $res{$cluster}{$gene}){print O "$cluster\t$num{$cluster}\t$gene\t$res{$cluster}{$gene}\n";
		$cn{$cluster}++;
		}
	}
}
print O "Cluster\tARG Num\tARG Genes\n";
my @c=keys %cn;
foreach my $c (@c) {
	print O "$c\t$cn{$c}\t";
	foreach my $gene (@gene) {
		if(exists $res{$c}{$gene}){print O "$gene,"}
	
	}
	print O "\n";
}