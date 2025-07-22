#!/usr/bin/perl
use strict;
use warnings;

#docker run -it --privileged=TRUE -v /home/zhangwen/:/test localhgt:v1

my $file=$ARGV[0];
open(F,$file);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my @a=split"\t",$l;
	system " localhgt bkp -r /test/bin/LocalHGT/UHGG_v2.0.2_representative.fasta --fq1 $a[1] --fq2 $a[2] -s $a[0] -o $a[0]\n";
}

close F;

#后续需跟localhgt event分析，汇总结果

#https://kkgithub.com/deepomicslab/LocalHGT