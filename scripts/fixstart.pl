#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename); 
my $target="pGut1.fas";
my @q=glob "$ARGV[0]/*.fasta";

foreach my $q (@q) {
	print"blat $target $q tmp.blat\n";
	system "blat $target $q tmp.blat\n";
	open(F,"tmp.blat");
	my $start=-1;my $e=-1;my $strand;my $chr;
	while(1){
		my $l=<F>;
		unless($l){last;}
		chomp $l;
		unless($l=~/^[0-9]/){next;}
		
		my @a=split" ",$l;unless($a[0]>300){next;}
		if($start==-1){
			$start=$a[11];$e=$a[12];$strand=$a[8];$chr=$a[9];
		}else{
			if($a[11]<$start){$start=$a[11];$strand=$a[8];}
			if($a[12]>$e){$e=$a[12];$strand=$a[8];}
		}
	}
	close F;my $f=basename($q);
	if($strand eq "+"){
		$start=$start+1;$e=$e+1;
		my $re=$start.":".$e;
		print "seqkit subseq --chr $chr --region $re $q >$ARGV[1]/$f\n";
		system "seqkit subseq --chr $chr --region $re $q >$ARGV[1]/$f\n";
	}elsif($strand eq "-"){
		$start=$start+1;$e=$e+1;my $re=$start.":".$e;
		print "seqkit subseq --chr $chr --region $re $q  |seqkit seq -r -p >$ARGV[1]/$f\n";
		system "seqkit subseq --chr $chr --region $re $q  |seqkit seq -r -p >$ARGV[1]/$f\n";
	}
}