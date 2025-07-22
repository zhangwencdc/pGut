#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;  
#conda activate eggnog

my $file=$ARGV[0];#faa.list

open(F,$file);
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	unless(substr($l,length($l)-1,1)=~/[0-9a-zA-Z]/){$l=substr($l,0,length($l)-1);}
	my $name=basename($l);
	$name=substr($name,0,length($name)-4);
	my $an=$name.".emapper.annotations";
	if(-e $an){print "$an skip";next;}else{print "$name doing\n";}
	system "emapper.py -i $l --output  $name  -m diamond --data_dir /home/zhangwen/Data/Eggnog/ \n";
}

close F;