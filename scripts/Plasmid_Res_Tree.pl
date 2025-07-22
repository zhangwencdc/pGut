#!/usr/bin/perl
use strict;
#use warnings;
use File::Basename qw(basename dirname);
#Usage:基于galah的90%聚类结果得到的res gene cluster，用ska方法构建tree
#conda activate ska
my $file=$ARGV[0];#clusters90.tsv


my $cut=$ARGV[1];#20
my $outdir=$ARGV[2];#/home/zhangwen/project/2024Time/Analysis/Plasmid_Res/Res_seq_tree


open(F,$file);my %cluster;my $num=0;my %cn;my %target;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	
	my @a=split"\t",$l;
	my $n0=basename($a[0]);
	$n0=~ s/[(){}]//g;
	my $n1=basename($a[1]);
	$n1=~ s/[(){}]//g;
	$cluster{$n1}=$n0;
	$cn{$n0}++;
	unless($n1=~/^res/){$target{$n0}++;}

}
close F;
my @cluster=sort keys %cn;my %res;
foreach my $c (@cluster) {
	if($cn{$c}>=$cut && $target{$c}>0){
		$res{$c}++;
	}
}

my @res=sort keys %res;
#生成plasmid cluster list


foreach my $key (@res) {
	system "mkdir $outdir/$key\n";

	open(F,$file);
	while(1){
		my $l=<F>;
		unless($l){last;}
		chomp $l;
		my @a=split"\t",$l;
		my $n=basename($a[0]);
		my $n3=basename($a[1]);
		$n =~ s/[(){}]//g; 
		$n3 =~ s/[(){}]//g; 
		if($n eq $key){
		system("cp \"$a[1]\" \"$outdir/$key/$n3\"");  ;
		system "ska fasta -c $outdir/$key/$n3 -o $outdir/$key/$n3 \n";
		}
	}
	system "ska merge $outdir/$key/*.skf -o $outdir/$key \n";
	system "ska align -v -o $outdir/$key $outdir/$key.skf \n";
	my $a1=$outdir."/".$key."_variants.aln";
	system "fasttree -gtr -nt $a1 > $a1.nwk\n";
	system "cat $outdir/$key/*.fasta $outdir/$key/*.fas >$outdir/$key.all.fasta\n ";
	system "sed -i 's/[()]//g' $outdir/$key.all.fasta";
	system "mafft --auto $outdir/$key.all.fasta >$outdir/$key.all.fasta.aln\n";
	system "fasttree -gtr -nt $outdir/$key.all.fasta.aln >$outdir/$key.all.fasta.aln.nwk";
	close OUT;
}
