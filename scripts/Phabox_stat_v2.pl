#!/usr/bin/perl
use strict;
use warnings;

my $file=$ARGV[0];#Seq.list

my $phagebox="/home/zhangwen/project/2024Time/Analysis/Phabox2/Phabox_result";
my $data="/home/zhangwen/project/2024Time/Data/CMP/";
my $outdir1="/home/zhangwen/project/2024Time/Analysis/Phabox2/virulent_Phage_seq";
my $outdir2="/home/zhangwen/project/2024Time/Analysis/Phabox2/temperate_Phage_seq";
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
print OUT "Sample\tAccession	Length	Pred	Proportion	PhaMerScore	PhaMerConfidence	Lineage	PhaGCNScore	Genus	GenusCluster	Prokaryoticvirus	TYPE	PhaTYPScore	Host	CHERRYScore	Method	Host_NCBI_lineage	Host_GTDB_lineage\n";
foreach my $genome (@genome) {
	my $file=$phagebox."/".$genome."/final_prediction/final_prediction_summary.tsv";
	my $seq=$data."/".$genome{$genome};
	open(FILE,$file);print "$file\n";
	while(1){
		my $l=<FILE>;
		unless($l){last;}
		chomp $l;
		my @a=split"\t",$l;
		if($a[0] eq "ID"){next;}
		unless($a[0]=~/[0-9a-zA-Z]/){next;}
		unless($a[4]>=0.8 && $a[5]=~/high/){next;}
		print OUT "$genome,$l\n";
		
		my $name=$genome."_".$a[0].".fasta";
		if($a[11]=~/temperate/){
		print "seqkit grep -p $a[0]  $seq >$outdir2/$name\n";
		system "seqkit grep -p $a[0]  $seq >$outdir2/$name\n";
		}elsif($a[11]=~/virulent/){
		print "seqkit grep -p $a[0]  $seq >$outdir1/$name\n";
		system "seqkit grep  -p $a[0]  $seq >$outdir1/$name\n";
		}
	}
	close FILE;
}