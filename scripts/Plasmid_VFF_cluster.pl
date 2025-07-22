#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use File::Basename qw(basename dirname);
#统计VFF基因存在于哪些plasmid cluster里

my $file=$ARGV[0];#Plasmid_VFF.txt
my $cluster=$ARGV[1];#clusters97.tsv

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
open(O,">Plasmid_cluster.VFF");my %VFF;my %gene;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	if($l=~/^FileName/){next;}
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split"\t",$l;
	my $name=basename($a[0]);
	print OUT "$l\t$cluster{$name}\t$num{$cluster{$name}}\n";
	$VFF{$cluster{$name}}{$a[1]}++;$gene{$a[1]}++;
	
}
close F;
close OUT;

my @gene=keys %gene;my @cluster=keys %VFF;
print O "Cluster\tNum of Plasmid\tVFF Gene\tPlasmid Num with VFF\n";
foreach my $cluster (@cluster) {
	foreach my $gene (@gene) {
		#unless($gene=~/[0-9a-zA-Z]/){next;}
		#print "$gene,$cluster,$VFF{$cluster}{$gene}\n";
		if(exists $VFF{$cluster}{$gene}){print O "$cluster\t$num{$cluster}\t$gene\t$VFF{$cluster}{$gene}\n";}
	}
}