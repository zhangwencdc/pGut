#!/usr/bin/perl
use strict;
#use warnings;
use File::Basename qw(basename dirname);
#问题1：有什么
#（1）质粒人均载量
#（2）质粒 阳性率

#样本：仅考虑CMP_Region和ProjectA样本，258个样本

my $input=$ARGV[0];#SampleID.txt
my $cluster=$ARGV[1];#clusters97.tsv
my $res="/home/zhangwen/project/2024Time/Analysis/Plasmid_cluster.res";
my $vff="/home/zhangwen/project/2024Time/Analysis/Plasmid_cluster.VFF";

##读取样本信息
my %sample;
open(F,$input);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split" ",$l;

	if($l=~/ProjectA/ || $l=~/CMP_Region/){
		$sample{$a[0]}++;

	}
}

close F;
#读取耐药信息
my %res;
open(F,$res);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split"\t",$l;
	if($a[1]>0){
	my $pos=$a[3]/$a[1];
	$res{$a[0]}=$pos;
	}

}

close F;

#读取毒力因子信息
#读取耐药信息
my %vff;
open(F,$vff);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split"\t",$l;
	if($a[1]>0){
	my $pos=$a[3]/$a[1];
	$vff{$a[0]}=$pos;
	}

}

close F;

##计算人均载量
my @s=keys %sample;
my $sample=@s;
open(OUT,">Plasmid_question1.txt");
print OUT "Samplet\tPlasmidNum\tClusterNum\tRes\tVFF\n"; my %ptotal;
foreach  (0..($sample-1)) {
	my $name=$s[$_];
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
			unless($s eq $name){next;} #仅考虑被选中的样本
			$plasmidn++;
			$ptotal{$a[1]}++;
			$clustern{$cl}++;
	
		}
	close F;
	my @cl=keys %clustern;
	my $cl=@cl;
	print OUT "$name\t$plasmidn\t$cl\n";
}
my @pl=keys %ptotal;
my $pl=@pl;
print "Plasmid Total:$pl\n";
##计算阳性率
print OUT "\nCluster\tPos Sample Num\tPos%\n";
open(F,$cluster);my %plasmidn; my %pp;
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
			unless(exists $sample{$s}){next;} #仅考虑被选中的样本
			if(exists $pp{$cl}{$s}){
				next;
			}else{
				$plasmidn{$cl}++;
				$pp{$cl}{$s}++;
			}
			
	
		}
	close F;
	my @cl=keys %plasmidn;
	foreach my $cl (@cl) {
		my $pos=$plasmidn{$cl}/$sample;
		print OUT "$cl\t$plasmidn{$cl}\t$pos\t$res{$cl}\t$vff{$cl}\n";
		
	}