#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename dirname);
my $outdir="Res_seq";
system "mkdir $outdir\n";
#预测耐药基因
open(F,"/home/zhangwen/project/2024Time/Analysis/Res/Assemble.list");
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	
	my $seq=$l;	
	my $b=substr(basename($l),0,length(basename($l))-6);
	#system "perl /home/zhangwen/bin/Resistance/Genome_Target_Resistance-v3-micro.pl -input $seq -Key $b\n";

}

close F;

#提取耐药基因序列

my $seq="/home/zhangwen/project/2024Time/Data/";


my @blat=glob "Blat/*.blat";
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
                                                if($m<0.8){next;}  #coverage <80% 剔除
                                 my $gene=substr($c[9],0,3);
							
								 my $contig=$c[13];$contig{$contig}++;
								 if(exists $min{$gene}{$contig}){
									 if($c[15]<$min{$gene}{$contig}){$min{$gene}{$contig}=$c[15];$strand{$gene}{$contig}=$c[8];}
								 }else{
									 $min{$gene}{$contig}=$c[15];$strand{$gene}{$contig}=$c[8];
								 }
								 if(exists $max{$gene}{$contig}){
									if($c[16]>$max{$gene}{$contig}){$max{$gene}{$contig}=$c[16];$strand{$gene}{$contig}=$c[8];}
								 }else{
									 $max{$gene}{$contig}=$c[16];$strand{$gene}{$contig}=$c[8];
								 }
									  
									
                }
                close B;
				my @g=keys %strand;my @contig=keys %contig;
				foreach my $g (@g) {
					foreach my $contig (@contig) {
						if(exists $strand{$g}{$contig}){
								my @d=split"_",$contig;
								 my $c=$d[0]."_".$d[1];
							my $out=$outdir."/".$name."_".$g."_".$c.".fasta";
							my $s=$min{$g}{$contig}+1;my $e=$max{$g}{$contig}+1;
							if($strand{$g}{$contig} eq "+"){
								print "seqkit subseq --chr $contig -r $s:$e $seq/$name.fasta -o $out\n";
							system "seqkit subseq --chr $contig -r $s:$e $seq/$name.fasta -o $out\n";
							}elsif($strand{$g}{$contig} eq "-"){
								print "seqkit subseq --chr $contig -r $s:$e $seq/$name.fasta |seqkit seq -r -p -o $out\n";
								system "seqkit subseq --chr $contig -r $s:$e $seq/$name.fasta |seqkit seq -r -p -o $out\n";
							}
						}
					}
				}

}

#后续需要结合galah  构建tree
#ls ResData/*fas >ResSeq.list ; ls Res_seq/*fasta >>ResSeq.list; nohup galah cluster --genome-fasta-list ResSeq.list --ani 90 --min-aligned-fraction 70 --output-cluster-definition clusters90.tsv  --output-representative-fasta-directory-copy Cluster90 & perl Plasmid_Res_Tree.pl clusters90.tsv 20 /home/zhangwen/project/2024Time/Analysis/Plasmid_Res/Res_seq_tree