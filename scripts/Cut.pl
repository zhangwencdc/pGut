#!/usr/bin/perl  
use strict;  
use warnings;  
use File::Basename qw(basename);  
use File::Path qw(make_path);  
#perl Cut.pl prokka/ Cut/
# ����Ƿ��ṩ�˲���  
if (@ARGV != 2) {  
    die "Usage: perl cut.pl <input_dir> <output_dir>\n";  
}  

# ȷ�����Ŀ¼����  
make_path($ARGV[1]);  

# ��ȡ����Ŀ¼�е����� .fasta �ļ�  
my @file = glob "$ARGV[0]/*.fasta";  

foreach my $file (@file) {  
    my $name = basename($file);  
    
    # ���� seqkit ����  
    system "seqkit amplicon -F GCGAAACTTGCGAAACCACT -R GTAGGCTGCGAGAGCTTCAT $file >$ARGV[1]/$name";  
    
    # �������ļ��Ƿ�Ϊ��  
    my $output_file = "$ARGV[1]/$name";  
    if (-e $output_file && -z $output_file) {  
        system "seqkit restart -i -1000 $file | seqkit amplicon -F GCGAAACTTGCGAAACCACT -R GTAGGCTGCGAGAGCTTCAT  >$ARGV[1]/$name";
		if (-e $output_file && -z $output_file) {  
		system "seqkit restart -i -2000 $file | seqkit amplicon -F GCGAAACTTGCGAAACCACT -R GTAGGCTGCGAGAGCTTCAT  >$ARGV[1]/$name";
			if (-e $output_file && -z $output_file) {  
			system "seqkit restart -i -3000 $file | seqkit amplicon -F GCGAAACTTGCGAAACCACT -R GTAGGCTGCGAGAGCTTCAT  >$ARGV[1]/$name";
				if (-e $output_file && -z $output_file) {  
				system "seqkit restart -i -4000 $file | seqkit amplicon -F GCGAAACTTGCGAAACCACT -R GTAGGCTGCGAGAGCTTCAT  >$ARGV[1]/$name";
				}
			}
		}
    }  
}  