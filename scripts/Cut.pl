#!/usr/bin/perl  
use strict;  
use warnings;  
use File::Basename qw(basename);  
use File::Path qw(make_path);  
#perl Cut.pl prokka/ Cut/
# 检查是否提供了参数  
if (@ARGV != 2) {  
    die "Usage: perl cut.pl <input_dir> <output_dir>\n";  
}  

# 确保输出目录存在  
make_path($ARGV[1]);  

# 获取输入目录中的所有 .fasta 文件  
my @file = glob "$ARGV[0]/*.fasta";  

foreach my $file (@file) {  
    my $name = basename($file);  
    
    # 运行 seqkit 命令  
    system "seqkit amplicon -F GCGAAACTTGCGAAACCACT -R GTAGGCTGCGAGAGCTTCAT $file >$ARGV[1]/$name";  
    
    # 检查输出文件是否为空  
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