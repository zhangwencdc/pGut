#!/usr/bin/perl  
use strict;  
use warnings;  
use File::Basename qw(basename);  
use File::Spec::Functions qw(catfile);  

# ���峣���������޸�  
my $PROJECT_DIR = "/home/zhangwen/project/2024Time/Analysis/PlasmidScore";  
my $MOB_SUITE_IMAGE = "quay.io/biocontainers/mob_suite:3.1.9--pyhdfd78af_1";  
my $PLASMID_SCORE_DIR = "/test/PlasmidScore_seq"; # Docker �����ڵ�·��  
my $MOB_SUITE_OUTPUT_DIR = "/test/Mob-suite";   # Docker �����ڵ�·��  

# �������л�ȡ�����ļ�  
my $cluster_file = shift @ARGV;  
die "Usage: perl $0 <clusters97.tsv>\n" unless defined $cluster_file;  

# ���ݽṹ  
my %cluster_counts;  
my %plasmid_total;  
my $plasmid_count = 0;  

# ��ȡ cluster �ļ�  
open(my $fh, "<", $cluster_file) or die "Could not open file '$cluster_file': $!";  
open(O,">Mob_suite.sh");
while (my $line = <$fh>) {  
    chomp $line;  
    $line =~ s/[^0-9a-zA-Z]+$//;  # ȥ����β�ķ���ĸ�����ַ�  

    my ($cluster_id, $sequence_id) = split "\t", $line, 2;  
    next unless defined $cluster_id && defined $sequence_id;  # ȷ��������  

    $cluster_id = basename($cluster_id);  
    $sequence_id = basename($sequence_id);  

    my @sample = split "_", $sequence_id;  
    my $sample_name = shift @sample;  

    $plasmid_count++;  
    $plasmid_total{$sequence_id}++;  
    $cluster_counts{$cluster_id}++;  
}  

close $fh;  

print "Total plasmids processed: $plasmid_count\n";  

# ���� mob_recon  
foreach my $cluster_id (sort keys %cluster_counts) {  
    my $input_path = catfile($PLASMID_SCORE_DIR, $cluster_id);  
    my $output_path = catfile($MOB_SUITE_OUTPUT_DIR, $cluster_id);  

    # ���� Docker ����  
    my $docker_cmd = "docker run --privileged=true -v $PROJECT_DIR:/test $MOB_SUITE_IMAGE mob_recon --infile '$input_path' --outdir '$output_path'";  

    print "Running command: $docker_cmd\n";  
   # system($docker_cmd) == 0 or die "Error running mob_recon for cluster '$cluster_id': $!";  
   print O "$docker_cmd ;docker system prune -f\n";
}  

print "Script finished successfully!\n";