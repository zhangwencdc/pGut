#!/usr/bin/perl
use strict;
use warnings;

#Usage����������genomad
# conda activate genomad
#docker run -it --privileged=True -v /home/zhangwen:/test genomad:v1

my @file=glob "$ARGV[0]/*.fasta";#/test/project/2024Water/Data/WasteWater/Genome/

my $data="/test/Data/genomad/genomad_db";#genomad���ݿ�

foreach my $file (@file) {
	print "genomad end-to-end --cleanup --splits 8 $file Out $data --cleanup\n";
	system "genomad end-to-end --cleanup --splits 8 $file Out $data --cleanup\n";
}
