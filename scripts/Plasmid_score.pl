#!/usr/bin/perl
use strict;
#use warnings;
use File::Basename qw(basename dirname);

my %plasmid;my @name;
foreach my $file (@ARGV) {
	open(F,$file);
	my $name=basename($file);
	push @name,$name;
	while(1){
		my $l=<F>;
		unless($l){last;}
		chomp $l;
		my @a=split"\t",$l;
		my $pn=$a[0].",".$a[1];
		$plasmid{$pn}{$name}=1;
	}

	close F;
}

my @p=sort keys %plasmid;
print "Sample,Plasmid,";
foreach my $n (@name) {
	print "$n,";
}
print "\n";
my $dir="/home/zhangwen/project/2024Time/Data";
foreach my $p (@p) {
	print "$p,";my $score=0;
	foreach my $n (@name) {
		print "$plasmid{$p}{$n},";
		$score+=$plasmid{$p}{$n};
	}
	
	print "$score\n";
	unless($score>=2){next;}
	my @s=split",",$p;
	my $f1=$s[0].".fasta";my $f2=$s[0].".assembled.fasta";
	open(FILE,"$dir/$f1")||open(FILE,"$dir/$f2");my $type=0;
	print "$s[0]\n";
		while(1){
			my $l=<FILE>;
			unless($l){if($type==1){print OUT "$l\n";};last;}
			chomp $l;
			if(substr($l,0,1) eq ">"){
				my $ln=substr($l,1);
				if($ln eq $s[1]){$type=1;
					my $out=$s[0]."_".$s[1].".fasta";
					
					print "OUT:$out\n";
					open(OUT,">$out");
					print OUT ">$s[0]";print OUT "_$s[1]\n";
				}else{$type=0;}
			}else{
				if($type==1){print OUT "$l\n";};
			}
		}

		close FILE;

}