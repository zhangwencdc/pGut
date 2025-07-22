#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename dirname);
#conda activate prokka

my $list=$ARGV[0];#pGut.list
my $file=$ARGV[1];#"clusters97.tsv";
my $out=$ARGV[2];

open(FILE,$list);
my $line=<FILE>;chomp $line;
while(1){
	my $line=<FILE>;
	unless($line){last;}
	chomp $line;$line =~ s/[^0-9a-zA-Z]+$//;
	my @b=split"\t",$line;
	my $query=$b[1];
	open(F,$file);
	my %cluster;my $num=0;my %cn;
	system "mkdir $out/$b[0]\n";system "cp /home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq/$query $out/$b[0]/$b[0].fasta \n";
	while(1){
		my $l=<F>;
		unless($l){last;}
		chomp $l;#print "$file\n$l\n";
		$l =~ s/[^0-9a-zA-Z]+$//;
		if($l=~/Plasmid_cluster/){next;}
		my @a=split"\t",$l;
		my $name=basename($a[1]);
		if(basename($a[0])=~/$query/){
			print "$query\n";
			my $n=substr($name,0,20);
			system "prokka /home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq/$name --centre $n  --compliant  --outdir  $out/$b[0]/$n  --prefix  $n	 \n";
		system "cp /home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq/$name $out/$b[0] \n";
		}
	}
	close F;
	#system "seqkit $out/$b[0]/* >$out/$b[0].stat\n";
}
close FILE;
