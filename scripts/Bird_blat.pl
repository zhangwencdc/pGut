#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename);

my $file=$ARGV[0];#clusters.list
my $data="/home/zhangwen/Data/Assemble_Data/Bird//";

my @target=glob "$data/*.fasta";
open(OUT,">Bird.plasmid.result");
	print OUT "Query,Total,Match\n";
open(FILE,$file);
while(1){
	my $line=<FILE>;
	unless($line){last;}
	chomp $line;
	unless(substr($line,length($line)-1,1)=~/[0-9a-zA-Z]/){$line=substr($line,0,length($line)-1);}
	my $input="/home/zhangwen/project/2024Time/Analysis/PlasmidScore/PlasmidScore_seq/".$line;
	my $name=basename($input);my $total;my $match;
	foreach my $target (@target) {
		my $t=basename($target);
		my $out=$name."_".$t.".blat";
		system "blat $input $target $out\n";
		open(F,$out);$total++;my %match;my $size;
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
		if(($kn/$size)>=0.7){$match++;}
		}
		close F;
	}
	system "cat *.blat >$name.blat.cat\n";
	system "rm -rf *.blat\n";

	print OUT "$line,$total,$match\n";

}