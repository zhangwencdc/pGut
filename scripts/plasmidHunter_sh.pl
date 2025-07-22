#!/usr/bin/perl  
use strict;  
use warnings;  
use File::Basename;  
use File::Path 'make_path';  
#conda activate plasmidfinder
# ����FASTA�ļ����ڵ�·��  
my $input_dir = $ARGV[0];  

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
        my $command = "plasmidhunter -i $input_file -o $output_dir -c 4";  
        system($command) == 0 or warn "System command failed: $!";  
		#system "rm -rf $output_dir/tmp\n";
    }  
}  

closedir($dh);