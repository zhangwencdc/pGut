#!/usr/bin/perl
use strict;
use warnings;

#”ÎPLSDB±»∂‘
my $list="Cluster97.list";
my $file="Cluster97_PLSDB.ani";
#my $out="Cluster97_PLSDB.ani.stat";

open(F,$file);my %match;
while(1){
	my $l=<F>;
	unless($l){last;}
	chomp $l;
	my @a=split"\t",$l;
	if($a[2]>=97 && $a[4]>=70){$match{$a[1]}++;}
}
close F;


open(FILE,$list);	my $yes;my $no;
while(1){
	my $l=<FILE>;
	unless($l){last;}
	chomp $l;
	if(exists $match{$l}){$yes++;}else{$no++;}

}
close FILE;

print "Match:$yes\n New:$no\n";