#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename);  
print "Hello, World...\n";
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
			#$ptotal{$a[1]}++;
			$clustern{$cl}++;
	
		}

		my @cluster=sort keys %clustern;
		foreach my $cluster (@cluster) {
			my $input="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq/".$cluster;
			system "blat pBI143.fasta $input $cluster.blat\n";
		}
