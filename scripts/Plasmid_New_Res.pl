#!/usr/bin/perl
use strict;
#use warnings;

#Usage:查找质粒上携带的，潜在的新的耐药基因

my $file=$ARGV[0];#/home/zhangwen/project/2024Time/Analysis/Plasmid_Res.txt.cluster
my $cutoff=$ARGV[1];#snp 个数，用于判断是否是新的耐药基因
my $blat="/home/zhangwen/project/2024Time/Analysis/Plasmid_Res/blat";
my $seq="";
open(O,">Plasmid_New_Res_Gene.txt");
open(F,$file);my %gene;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	my @gene=split"_",$a[1];
	my $gene=shift @gene;
	my @d = split /\(/, $gene;
	$gene=shift @d;
	my $b=$blat."/".$a[2].".blat";
	open(B,$b)||print "$b\n";my $type=1;my $start;my $end;my $strand;
	while(1){
		my $line=<B>;
		unless($line){last;}
		chomp $line;
		
		my @b=split"\t",$line;
		if($b[9]=~/\Q$gene\E/ && $b[1]<$cutoff){$type=0;}
		#print "$line,$b[9],$gene,$b[1],$type\n";
		if($a[1] eq $b[9] ){$start=$b[15];$end=$b[16];$strand=$b[8];}
	}
	close B;
	if($type==1){
		print O "$l\n";
		$gene{$gene}++;
		if($strand eq "+"){
		system "seqkit subseq -r $start:$end $a[0] >>$gene.fasta";
		}elsif($strand eq "-"){
			system "seqkit subseq -r $start:$end $a[0] | seqkit seq -r -p >>$gene.fasta";
		}
	}

}

my @g=sort {$gene{$b}<=>$gene{$a}} keys %gene;
foreach my $g (@g) {
	print "$g,$gene{$g}\n";
}