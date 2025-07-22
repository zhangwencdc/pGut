#!/usr/bin/perl
use strict;
#use warnings;
use File::Basename qw(basename dirname);
use List::Util 'shuffle';

my $input=$ARGV[0];#SampleID.txt
my $cluster=$ARGV[1];#clusters97.tsv
my $size=10;#随机取10次;
my %sample;
open(F,$input);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split" ",$l;

	if($l=~/ProjectA/ || $l=~/CMP_Region/){
		$sample{$a[0]}++;

	}
}

close F;

my @sample=keys %sample;
my $samplen=@sample;
open(OUT,">PlasmidCluster_sparse_curve.txt");
print OUT "SampleNum\tRepeat\tPlasmidNum\tClusterNum\tSampleName\n";
foreach  (1..($samplen-1)) {
	my $sn=$_;
	foreach  (1..$size) {
		my @random = (shuffle(@sample))[0..($sn-1)];
		my %random;
		foreach my $random (@random) {
			$random{$random}++;
		}
		open(F,$cluster);my %plasmid;my %cluster;
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
			unless(exists $random{$sample}){next;} #仅考虑被随机选中的样本
			$plasmid{$name}++;
			$cluster{$cluster}++;
	
		}
		close F;
		my @plasmid=sort keys %plasmid;
		my $pln=@plasmid;
		my @cluster=sort keys %cluster;
		my $cn=@cluster;
		print  "$sn\t$_\t$pln\t$cn\t@random\n";
		print OUT "$sn\t$_\t$pln\t$cn\t@random\n";
	}
}

