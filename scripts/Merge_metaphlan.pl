#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;  
#Usage:Merge Metaphlan profiles
#merge_metaphlan.pyµÄperlÌæ´ú°æ

my @file=glob "$ARGV[0]/*.t*";
my $out1="Merge_Metaphlan_Species.txt";
my $out2="Merge_Metaphlan_Genus.txt";

my %species;my %genus;my %name;
foreach my $file (@file) {
	my $name=basename($file);$name{$name}++;
	open(F,$file);
	while(1){
		my $l=<F>;
		unless($l){last;}
		chomp $l;
		unless($l=~/g__/ ||$l=~/s__/){next;}
		my @a=split"\t",$l;
		
		if($l=~/s__/){
			my @b=split"s__",$a[0];
			my $sp=pop @b;
			$species{$sp}{$name}=$a[1];
		}else{
			if($l=~/g__/){
				my @b=split"g__",$a[0];
				my $ge=pop @b;
				$genus{$ge}{$name}=$a[1];
			}

		}
		
	}
	close F;
}

my @sample=sort keys %name;
open(OUT,">$out1");print OUT "Sample";
foreach my $sample (@sample) {
	print OUT "\t$sample";
}
print OUT "\n";
my @sp=sort keys %species;
foreach my $sp (@sp) {
	print OUT "$sp";
	foreach my $sample (@sample) {
		if(exists $species{$sp}{$sample}){
			print OUT "\t$species{$sp}{$sample}";
		}else{
			print OUT "\t0";
		}
	}
	print OUT "\n";
}
close OUT;

open(OUT,">$out2");print OUT "Sample";
foreach my $sample (@sample) {
	print OUT "\t$sample";
}
print OUT "\n";
@sp=sort keys %genus;
foreach my $sp (@sp) {
	print OUT "$sp";
	foreach my $sample (@sample) {
		if(exists $genus{$sp}{$sample}){
			print OUT "\t$genus{$sp}{$sample}";
		}else{
			print OUT "\t0";
		}
	}
	print OUT "\n";
}
close OUT;