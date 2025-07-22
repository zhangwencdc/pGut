#!/usr/bin/perl
use strict;
#use warnings;
use File::Basename qw(basename dirname); 
my $list=$ARGV[0];
open(FILE,$list);
my $db=$ARGV[1];#pGut1-v3.fasta
open(OUT,">>$ARGV[2]");#pGut1_pathogen_out.txt
while(1){
	my $line=<FILE>;
	unless($line){last;}
	my @a=split" ",$line;
	my $query=pop @a;
	my $qname=basename($query);
	print "$qname\n";
	system "blat $db /tmpPathogen/$query $qname.out\n";
	 open(F,"$qname.out");my %match;my $size;
	 my $l=<F>;chomp $l;  my $l=<F>;chomp $l; my $l=<F>;chomp $l;  my $l=<F>;chomp $l;my $l=<F>;chomp $l;#Ìø¹ýheader
                while(1){
                        my $l=<F>;
                        unless($l){last;}
                        chomp $l;
                        my @a=split"\t",$l;
                        if($a[0]>300){$size=$a[14];
                                foreach($a[15]..$a[16]){
                                        $match{$_}++;
                                }
                        }
                }
                my @k=sort keys %match;my $kn;
                foreach my $k (@k) {
                        $kn++;
                }
                if($size>0){
					if(($kn/$size)>=0.7){
					system "cat $qname.out >>blat.cat\n";
					print OUT "$qname\t$kn\t$size\n";
					}
                }
					system "rm -rf $qname.out\n";
				
                close F;

}
close FILE;
