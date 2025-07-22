#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Cwd 'abs_path';

# ======================
# 脚本功能：提取双端测序中单端比对的序列并进行组装
# 使用方法：perl script.pl fq1 fq2 backbone key
# 示例：perl pGut1_Cut_Mix.pl R1.fq R2.fq pGUT1_v3.fasta sample01
# ======================

# 参数校验
#die "Usage: $0 <fq1> <fq2> <backbone> <key>\n" if @ARGV != 4;

my ($fq1, $fq2, $backbone, $key) = @ARGV;

# 检查输入文件存在性
foreach ($fq1, $fq2, $backbone) {
    die "Error: Missing input file $_\n" unless -f $_;
}

# 配置工具路径（推荐通过环境变量设置）
my $bowtie2_bin = $ENV{BOWTIE2_HOME} ? 
    "$ENV{BOWTIE2_HOME}/bowtie2" : 
    "/home/zhangwen/bin/bowtie2-2.4.4-linux-x86_64/bowtie2";

# 临时文件定义
my $sam_file = "tmp.$key.sam";
my @temp_files = (
    "tmp1.$key.list", 
    "tmp2.$key.list",
    "$key.fq1.filter.fastq",
    "$key.fq2.filter.fastq"
);

# ======================
# 比对阶段
# ======================
sub run_command {
    my $cmd = shift;
    system($cmd) == 0 or die "Command failed: $cmd\nError: $!\n";
}

# 执行bowtie2比对
run_command("$bowtie2_bin -x $backbone -1 $fq1 -2 $fq2 -S $sam_file");

# ======================
# 提取单端比对序列
# ======================
# FLAG 73:  read1比对成功，read2未比对
# FLAG 137: read2比对成功，read1未比对
run_command("awk '\$2 == 73' $sam_file | cut -f1 > $temp_files[0]");
run_command("awk '\$2 == 137' $sam_file | cut -f1 > $temp_files[1]");

# 提取反向未比对序列
run_command("seqkit grep -f $temp_files[0] $fq2 > $temp_files[2]");
run_command("seqkit grep -f $temp_files[1] $fq1 > $temp_files[3]");

# ======================
# 组装阶段
# ======================
my @assemblies = (
    { input => $temp_files[2], output => "$key.fq2.fasta" },
    { input => $temp_files[3], output => "$key.fq1.fasta" }
);

foreach my $asm (@assemblies) {
    my $outdir = "tmp_assembly_$$";  # 使用PID保证唯一性
    run_command("megahit -r $asm->{input} -o $outdir");
    run_command("mv $outdir/final.contigs.fa $asm->{output}");
    run_command("rm -rf $outdir");
}

# ======================
# 清理临时文件
# ======================
unlink($sam_file, @temp_files) or warn "Cleanup failed: $!";

exit 0;