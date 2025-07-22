#!/usr/bin/perl
use strict;
#use warnings;

my $file="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/roary/gene_plasmid_spearman_correlation_results.txt";

open(F,$file);
my %gene;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	if($a[2]>=0.05){next;}
	$gene{$a[0]}=$a[1];
}
close F;

my $gene="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/roary/clustered_proteins";

open(F,$gene);
my %gname;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split":",$l;
	unless(exists $gene{$a[0]}){next;}
	#print "$a[0]\n";
	my @b=split" ",$a[1];
	foreach my $b (@b) {
		$gname{$b}=$a[0];
		#print "$b,$a[0]\n";
	}
}
close F;

my $egg="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/eggnog.sum";
open(O,">anno.filter");
open(F,"$egg");my %cog;my %anno;my %de;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	unless(exists $gname{$a[0]}){next;}
	if($a[5]=~/[0-9a-zA-Z]/){
		if(exists $anno{$gname{$a[0]}}&& $anno{$gname{$a[0]}} ne $a[5]){
			$anno{$gname{$a[0]}}=$anno{$gname{$a[0]}}."/".$a[5];
		}else{
		$anno{$gname{$a[0]}}=$a[5];
		}
	}
	if($a[6]=~/[0-9a-zA-Z]/){
		if(exists $cog{$gname{$a[0]}}&& $cog{$gname{$a[0]}} ne $a[6]){
			$cog{$gname{$a[0]}}=$cog{$gname{$a[0]}}."/".$a[6];
		}else{
		
		$cog{$gname{$a[0]}}=$a[6];}
	}
	if($a[7]=~/[0-9a-zA-Z]/){
		if(exists $de{$gname{$a[0]}}&& $de{$gname{$a[0]}} ne $a[7]){
			$de{$gname{$a[0]}}=$de{$gname{$a[0]}}."/".$a[7];
		}else{
		
		$de{$gname{$a[0]}}=$a[7];}
	}
	print O "$gname{$a[0]}\t$l\n";
}
close F;
my $out="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/eggnog.gene.result";
open(OUT,">$out");
my @g=sort keys %gene;
print OUT "Gene\tCorrelation\tAnno\tCog\n";
foreach my $g (@g) {
	print OUT "$g\t$gene{$g}\t$anno{$g}\t$cog{$g}\t$de{$g}\n";
}