#!/usr/bin/perl
use strict;
#use warnings;
use File::Basename qw(basename dirname);

my $blat="/home/zhangwen/project/2024Time/Analysis/Plasmid_Res/blat";
my $seq="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq";

my $outdir="/home/zhangwen/project/2024Time/Analysis/Plasmid_Res/Res_seq";
my @blat=glob "$blat/*.blat";
foreach my $b (@blat) {
	open(B,"$b");my %gene;my $l=<B>;chomp $l;my %match; my %contig;
	my $name=basename($b);
	$name=substr($name,0,length($name)-5);my $id=0;my %min;my %max;my %strand;
                  while(1){
                        my $l=<B>;
                        unless($l){last};
                        chomp $l;
                        my @c=split"\t",$l;
                                                unless($c[10]>100){next;}
                                                my $m=$c[0]/$c[10];
                                                if($m<0.8){next;}  #coverage <80% лчЁЩ
                                 my $gene=substr($c[9],0,3);
								 if(exists $min{$gene}){
									 if($c[15]<$min{$gene}){$min{$gene}=$c[15];$strand{$gene}=$c[8];}
								 }else{
									 $min{$gene}=$c[15];$strand{$gene}=$c[8];
								 }
								 if(exists $max{$gene}){
									if($c[16]>$max{$gene}){$max{$gene}=$c[16];$strand{$gene}=$c[8];}
								 }else{
									 $max{$gene}=$c[16];$strand{$gene}=$c[8];
								 }
									  
									
                }
                close B;
				my @g=keys %strand;
				foreach my $g (@g) {
					my $out=$outdir."/".$name."_".$g.".fasta";
					my $s=$min{$g}+1;my $e=$max{$g}+1;
					if($strand{$g} eq "+"){
					system "seqkit subseq -r $s:$e $seq/$name.fasta -o $out\n";
					}elsif($strand{$g} eq "-"){
						system "seqkit subseq -r $s:$e $seq/$name.fasta |seqkit seq -r -p -o $out\n";
					}
				}

}
