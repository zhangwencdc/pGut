#!/usr/bin/perl
use strict;
#use warnings;
use File::Basename qw(basename dirname);
#问题2：如何变
#（1）有多少过路质粒
#（2）定植质粒的定植时间

#样本：仅考虑CMP_multitime样本，240个样本

my $input=$ARGV[0];#SampleID.txt
my $cluster=$ARGV[1];#clusters97.tsv
my $res="/home/zhangwen/project/2024Time/Analysis/Plasmid_cluster.res";
my $vff="/home/zhangwen/project/2024Time/Analysis/Plasmid_cluster.VFF";

##读取样本信息
my %sample;
open(F,$input);my %people;my %time;my %peoplen;my %pt;
my $l=<F>;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split" ",$l;

	if($l=~/ProjectA/ || $l=~/CMP_Region/){
		next;
	}
	$sample{$a[0]}++;
	$people{$a[0]}=$a[2];
	$peoplen{$a[2]}++;
	$time{$a[0]}=$a[3];$pt{$a[3]}++;
}
my @people=sort keys %peoplen;
my @time=sort keys %pt;
print @time;
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
open(OUT,">Plasmid_question2.txt");
print OUT "Sample\tPeople\tTime\tPlasmidNum\tClusterNum\n"; my %ptotal;
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
	print OUT "$name\t$people{$name}\t$time{$name}\t$plasmidn\t$cl\n";
}
my @pl=keys %ptotal;
my $pl=@pl;
print "Plasmid Total:$pl\n";
##计算来自于不同people的阳性率
print OUT "\nCluster\tPos Sample Num\tPos%\tRes\tVFF\t";
foreach my $people (@people) {
	print OUT "$people\t";
}
print OUT "\n";
open(O2,">Plasmid_question2_time.txt");
open(F,$cluster);my %plasmidn; my %pp;my %pcp;my %pcpt;
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
				$pcp{$cl}{$people{$s}}++;
				$pp{$cl}{$s}++;
				my $tt=$people{$s}."_".$time{$s};
				$pcpt{$cl}{$tt}++;
			}
			
	
		}
	close F;
	my @cl=keys %plasmidn;
	foreach my $cl (@cl) {
		my $pos=$plasmidn{$cl}/$sample;
		print OUT "$cl\t$plasmidn{$cl}\t$pos\t$res{$cl}\t$vff{$cl}\t";
		my $type="Transient";
		foreach my $people (@people) {
			my $posp=$pcp{$cl}{$people}/$peoplen{$people};
			print OUT "$posp\t";
			if(exists $pcp{$cl}{$people}){
			if($pcp{$cl}{$people}>1){
				$type="Non-transient";
				my @tmp;
				foreach my $time (@time) {
					my $tt=$people."_".$time;
					if(exists $pcpt{$cl}{$tt}){push @tmp,$time;}
				}
				my $last=pop @tmp;
				print O2 "$cl\t$people\t$pcp{$cl}{$people}\t$res{$cl}\t$vff{$cl}\t$tmp[0]\t$last\t";
				my @t1=split"_",$tmp[0];
				my @t2=split"_",$last;
				my $tl=12*($t2[0]-$t1[0])+($t2[1]-$t1[1]);
				print O2 "$tl\n";
			}
			}
		}
		print OUT "$type\n";
	}