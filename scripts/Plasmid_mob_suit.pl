#!/usr/bin/perl
use strict;
use warnings;

my $PROJECT_DIR="/home/zhangwen/project/2024Time/Analysis/PlasmidScore";
my $cluster=$ARGV[0];#clusters97.tsv
	open(F,$cluster);my $plasmidn;my %clustern;
		while(1){
			my $l=<F>;
			unless($l){last;}
			chomp $l;
			unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
			my @a=split"\t",$l;
			my $n=basename($a[1]);
			my $cl=basename($a[0]);
			my @sample=split"_",$n;
			my $s=shift @sample;
			#unless($s eq $name){next;} #仅考虑被选中的样本
			$plasmidn++;
			$ptotal{$a[1]}++;
			$clustern{$cl}++;
	
		}

		my @cluster=sort keys %cluster;
		foreach my $cluster (@cluster) {
			my $input="/test/PlasmidScore_seq/".$cluster;
			system "docker run --privileged=true -v $PROJECT_DIR:/test quay.io/biocontainers/mob_suite:3.1.9--pyhdfd78af_1 mob_recon --infile $input --outdir /test/Mob-suite/$cluster \n";
		}