#!/usr/bin/perl
use strict;
use warnings;

open(F,"/home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq.list");
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	
	my $seq="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/".$l;	
	my $b=substr($l,17,length($l)-23);
	print "perl /home/zhangwen/bin/VFF_blat.pl -input $seq -Key $b\n";
	system "perl /home/zhangwen/bin/VFF_blat.pl -input $seq -Key $b\n";

}

close F;