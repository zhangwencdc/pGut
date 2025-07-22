#!/usr/bin/perl
use strict;
use warnings;

my $file=$ARGV[0];#Seq.list

my $phagebox="/home/zhangwen/project/2024Time/Analysis/Phabox/Phabox_result";
my $data="/home/zhangwen/project/2024Time/Data/CMP/";
my $outdir1="/home/zhangwen/project/2024Time/Analysis/Phabox/virulent_Phage_seq";
my $outdir2="/home/zhangwen/project/2024Time/Analysis/Phabox/temperate_Phage_seq";
open(F,$file);my %genome;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;my @a=split"\t",$l;
	$genome{$a[0]}=$a[2];
}

close F;

my @genome=sort keys %genome;
open(OUT,">Phagebox.summary");
print OUT "Sample,ID,Accession,Length,PhaMer,PhaMer_score,PhaTYP,PhaTYP_score,PhaGCN,PhaGCN_score,CHERRY,CHERRY_score,CHERRY_type\n";
foreach my $genome (@genome) {
	my $file=$phagebox."/".$genome."/prediction_summary.csv";
	my $seq=$data."/".$genome{$genome};
	open(FILE,$file);
	while(1){
		my $l=<FILE>;
		unless($l){last;}
		chomp $l;
		my @a=split",",$l;
		if($a[0] eq "ID"){next;}
		unless($a[0]=~/[0-9a-zA-Z]/){next;}
		unless($a[4]>=0.8){next;}
		print OUT "$genome,$l\n";
		
		my $name=$genome."_".$a[1].".fasta";
		if($a[5]=~/temperate/){
		print "seqkit grep -n -p $a[1]  $seq >$outdir2/$name\n";
		system "seqkit grep -n -p $a[1]  $seq >$outdir2/$name\n";
		}elsif($a[5]=~/virulent/){
		print "seqkit grep -n -p $a[1]  $seq >$outdir1/$name\n";
		system "seqkit grep -n -p $a[1]  $seq >$outdir1/$name\n";
		}
	}
	close FILE;
}