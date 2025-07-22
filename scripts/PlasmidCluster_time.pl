#!/usr/bin/perl
use strict;
#use warnings;
use File::Basename qw(basename dirname);
my $input=$ARGV[0];#SampleID.txt
my $cluster=$ARGV[1];#clusters97.tsv

my %group;my %people;my %time;my %p2;
open(F,$input);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split" ",$l;

	if($l=~/CMP_multitime/){
		$group{$a[0]}++;
		$people{$a[2]}++;
		$p2{$a[0]}=$a[2];#print "$a[0]\t$a[2]\n";
		$time{$a[0]}=$a[3];
	}
}

close F;


open(F,$cluster);my %plasmid;my %plasmid_people;my %cluster;my %cluster_people;my %cluster_sample;my %sample;
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
	unless(exists $group{$sample}){next;} #仅考虑CMP_multitime的样本
	$sample{$sample}++;
	$plasmid{$name}++;
	my $people=$p2{$sample};
	
	unless(exists $cluster_sample{$cluster}{$sample}){$cluster_people{$cluster}{$people}++;$plasmid_people{$people}{$name}++;
	$cluster{$cluster}++;}
	$cluster_sample{$cluster}{$sample}++;
	#print "$l\n$name\t$sample\t$people\n";
}

my @plasmid=sort keys %plasmid;
my $pln=@plasmid;
my @cluster=sort keys %cluster;
my $cn=@cluster;
my @people=sort keys %people;
my $pn=@people;
print "Plasmid Num:$pln\n";
print "Cluster Num:$cn\n";
print "People Num:$pn\n";

my $out="Plasmid_cluster.multitime";
open(OUT,">$out");
print OUT "PlasmidCluter\tNum\t";
foreach my $p (@people) {
	print OUT "$p\t";
}
print OUT "\n";
foreach my $cluster (@cluster) {
	print OUT "$cluster\t$cluster{$cluster}\t";
	foreach my $p (@people) {
		print OUT "$cluster_people{$cluster}{$p}\t";
	}
	print OUT "\n";
}

open(O,">Plasmid_sample.multitime");
print O "PlasmidCluter\tNum\t";
my @sample=sort keys %sample;
foreach my $p (@sample) {
	print O "$p\t";
}
print O "\n";
print O "People\t";
foreach my $p (@sample) {
	print O "$p2{$p}\t";
}
print O "\n";
foreach my $cluster (@cluster) {
	print O "$cluster\t$cluster{$cluster}\t";
	foreach my $p (@sample) {
		print O "$cluster_sample{$cluster}{$p}\t";
		if($cluster_sample{$cluster}{$p}>1){print "$p\t$p2{$p}\t$cluster\t$cluster_sample{$cluster}{$p}\n";}  #输出一个样本中存在某个cluster多条序列的情况，待检测
	}
	print O "\n";
}