#!/usr/bin/perl
use strict;
use warnings;

#Replication protein

my $file="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/21ZYF2_NODE_3640_length_4789/roary/gene_presence_absence.csv";
my $query="group_72";
my $out="Replication_protein.fasta";
open(F,$file);
my $name=<F>;
chomp $name;$name =~ s/"//g;
my @name=split",",$name;my %name;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;$l =~ s/"//g;
	my @a=split",",$l;
	unless($a[0] eq $query){next;}
	my $n=@a;
	foreach  (1..($n-1)) {
		if($name[$_]=~/[0-9a-zA-Z]/){
			my @b=split" ",$a[$_];
		$name{$name[$_]}=$b[0];
		}
	}
}
close F;

my @key=sort keys %name;
my $dir="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/21ZYF2_NODE_3640_length_4789/prokka/";
foreach my $key (@key) {
	if(exists $name{$key} && $name{$key}=~/[0-9a-zA-Z]/){
	my $input=$dir.$key."/".$key.".ffn";
#	print "seqkit grep -p $name{$key} $input >>$out\n";
#	system "seqkit grep  -p $name{$key} $input >>$out \n";
	 system "seqkit grep -p $name{$key} $input | sed 's/^>/>$key /' >> $out";  # 修改序列名为文件名  
 
	}
}