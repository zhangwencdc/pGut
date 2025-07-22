#!/usr/bin/perl
use strict;
#use warnings;
use File::Basename qw(basename dirname);
#Usage:将含有耐药基因的质粒 和 同cluster的其余序列比对，证实是否会存在基因的缺失和获得两种状态


my $file="/home/zhangwen/project/2024Time/Analysis/Plasmid_Res.txt.cluster";
my $cluster="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/clusters97.tsv";

my $blat="/home/zhangwen/project/2024Time/Analysis/Plasmid_Res/blat/";#耐药基因的比对结果
my $seq="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq/";
open(F,$file);
my %plasmid;my %clu;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;#print "$l\n$a[8]\n";
	$clu{$a[8]}++;
	$plasmid{$a[2]}=$a[8];

}

close F;



my @clu=sort keys %clu;
my @pla=sort keys %plasmid;
open(OUT,">Candidate.list");
foreach my $clu (@clu) {
	foreach my $pla (@pla) {
		unless($plasmid{$pla} eq $clu){next;}
		#确认质粒上耐药基因的位置
		my $f=$blat."/".$pla.".blat";
		open(B,$f);my $min=-1;my $max=0;
		while(1){
			 my $l=<B>;
             unless($l){last};
             chomp $l;
             my @c=split"\t",$l;
             unless($c[10]>100){next;}
             my $m=$c[0]/$c[10];
             if($m<0.8){next;}  #coverage <80% 
			 if($c[16]>$max){$max=$c[16];}
			 if($min==-1){$min=$c[15];}elsif($min>=0 && $min<$c[15]){$min=$c[15];}
			 
		}
		close B;
		#print "$pla,Min:$min,Max:$max\n";
		my $query=$seq."/".$pla.".fasta";
		#与同cluster的其他质粒序列依次比较
		open(F,$cluster);my %cluster;my %num;
		while(1){
			my $l=<F>;
			unless($l){last;}
			chomp $l;
			unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
			my @a=split"\t",$l;
			my $name=basename($a[1]);
			my $cluster=basename($a[0]);
			unless($cluster eq $clu){next;}
			my $target=$seq."/".$name;
			#print "$name,$cluster,$clu\n";
			system "blat $target $query tmp >tmp.log\n";
			open(T,"tmp");my %match;my $end;
				while(1){
					my $line=<T>;
					unless($line){last;}
					chomp $line;
					my @b=split"\t",$line;
					unless($b[0]>=500){next;} #仅考虑align>500bp的比对结果
					$end=$b[10];
					foreach  ($b[11]..$b[12]) {
						$match{$_}++;
					}
				}
			close T;
			my $lstart;my $rend;

			if(($min-2000)<0){$lstart=0;}else{$lstart=$min-2000;}
			if(($max+2000)>$end){$rend=$end;}else{$rend=$max+2000;}
			my @site=sort keys %match; my $m1;my $m2;my $m3;
			foreach my $site (@site) {
				if($site>=$lstart && $site<$min){
					$m1++;
				}elsif($site >=$min && $site <=$max){
					$m2++;
				}elsif($site>$max && $site <= $rend){
					$m3++;
				}

			}
			if(($min-$lstart)>0 && ($rend-$max)>0){##不考虑耐药基因位于两侧边缘的情况，这种情况无法判断
			my $p1=$m1/($min-$lstart);
			my $p2=$m2/($max-$min+1);
			my $p3=$m3/($rend-$max);
			print  "$clu\t$pla\t$name\t$cluster\t$m1:$p1\t$m2:$p2\t$m3:$p3\n";
			if($p1>=0.5 && $p3>=0.5 && $p2<=0.3){
				print OUT "$pla\t$name\t$cluster\t$p1\t$p2\t$p3\n";
				system "cat tmp >>blat.out\n";
				#NGenomeSyn画图
				my $prefix=$pla."_".$name;
				system "perl /home/zhangwen/bin/NGenomeSyn/bin/GetTwoGenomeSyn.pl -InGenomeA $query  -InGenomeB $target  -OutPrefix $prefix   -MappingBin  minimap2    -BinDir    /home/zhangwen/miniconda3/bin/    -MinLenA  200  -MinLenB 200 --MinAlnLen 200\n";
			}
			}
		}
		close F;
	}
}
close OUT;