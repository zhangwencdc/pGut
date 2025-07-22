#!/usr/bin/perl
use strict;
#use warnings;
use File::Basename qw(basename dirname);
#Usage:clusters to matrix待后续psych做关联分析

my $cluster="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/clusters97.tsv";
my $stat="/home/zhangwen/project/2024Time/Analysis/Plasmid_matrix/stat.txt";

my %read;
open(F,$stat);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split"\t",$l;
	$read{$a[0]}=$a[6];
}
close F;

open(F,$cluster);my %cluster;my %num;my %dep;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split"\t",$l;
	my $name=basename($a[1]);
	$name=substr($name,0,length($name)-6);#去除.fasta
	my @b=split"cov_",$name;
	my $depth=pop @b;
	my $cluster=basename($a[0]);
	$cluster=substr($cluster,0,length($cluster)-6);
	my @sample=split"_",$name;
	my $sample=shift @sample;
	$cluster{$name}=$cluster;
	$num{$cluster}++;
	$dep{$sample}{$cluster}=$depth;
}
close F;

my @sample=keys %dep;
my $sample=@sample;
print "Sample Num:$sample\n";
my @cluster=keys %num;
open(OUT,">Plasmid_cluster.matrix");
print OUT "ID";
foreach my $s (@sample) {
	if(exists $read{$s}){
	print OUT "\t$s";
	}else{print "$s\n";}
}
print OUT "\n";

foreach my $cluster (@cluster) {
	if($num{$cluster}<=5){next;}##仅考虑在5个以上样本中存在的cluster
	print OUT "$cluster";
	foreach my $s (@sample) {
		if(exists $read{$s}){
			my $new=$dep{$s}{$cluster}/$read{$s}*1000000; #均一化为每一百万条reads里的depth
		print OUT "\t$new";
		}
	}
	print OUT "\n";
}

close OUT