#!/usr/bin/perl  
use strict;  
use warnings;  
use File::Basename;  
use File::Path 'make_path';  
#conda activate plasmidfinder
# ����FASTA�ļ����ڵ�·��  
my $input_dir = $ARGV[0];  
# ����PlasmidFinder���ݿ�·��  
my $plasmidfinder_db = '/home/zhangwen/bin/PlasmidFinder/plasmidfinder_db/';  

# ������Ŀ¼  
opendir(my $dh, $input_dir) or die "Cannot open directory: $!";  

# ��������Ŀ¼�µ�����FASTA�ļ�  
while (my $filename = readdir($dh)) {  
    if ($filename =~ /\.fasta$/) {  
        # ������Ӧ���ļ���  
        my $folder_name = basename($filename, '.fasta');  
        my $folder_path = $folder_name;  print "$folder_name\n";
        make_path($folder_path) unless -d $folder_path;  

        # ��������  
        my $input_file = "$input_dir/$filename";  
        my $output_dir = $folder_path;  

        # ִ������  
        my $command = "plasmidfinder.py -i $input_file -o $output_dir -p $plasmidfinder_db -x";  
        system($command) == 0 or warn "System command failed: $!";  
		system "rm -rf $output_dir/tmp\n";
    }  
}  

closedir($dh);