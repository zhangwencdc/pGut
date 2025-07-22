#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Cwd 'abs_path';

# ======================
# �ű����ܣ���ȡ˫�˲����е��˱ȶԵ����в�������װ
# ʹ�÷�����perl script.pl fq1 fq2 backbone key
# ʾ����perl pGut1_Cut_Mix.pl R1.fq R2.fq pGUT1_v3.fasta sample01
# ======================

# ����У��
#die "Usage: $0 <fq1> <fq2> <backbone> <key>\n" if @ARGV != 4;

my ($fq1, $fq2, $backbone, $key) = @ARGV;

# ��������ļ�������
foreach ($fq1, $fq2, $backbone) {
    die "Error: Missing input file $_\n" unless -f $_;
}

# ���ù���·�����Ƽ�ͨ�������������ã�
my $bowtie2_bin = $ENV{BOWTIE2_HOME} ? 
    "$ENV{BOWTIE2_HOME}/bowtie2" : 
    "/home/zhangwen/bin/bowtie2-2.4.4-linux-x86_64/bowtie2";

# ��ʱ�ļ�����
my $sam_file = "tmp.$key.sam";
my @temp_files = (
    "tmp1.$key.list", 
    "tmp2.$key.list",
    "$key.fq1.filter.fastq",
    "$key.fq2.filter.fastq"
);

# ======================
# �ȶԽ׶�
# ======================
sub run_command {
    my $cmd = shift;
    system($cmd) == 0 or die "Command failed: $cmd\nError: $!\n";
}

# ִ��bowtie2�ȶ�
run_command("$bowtie2_bin -x $backbone -1 $fq1 -2 $fq2 -S $sam_file");

# ======================
# ��ȡ���˱ȶ�����
# ======================
# FLAG 73:  read1�ȶԳɹ���read2δ�ȶ�
# FLAG 137: read2�ȶԳɹ���read1δ�ȶ�
run_command("awk '\$2 == 73' $sam_file | cut -f1 > $temp_files[0]");
run_command("awk '\$2 == 137' $sam_file | cut -f1 > $temp_files[1]");

# ��ȡ����δ�ȶ�����
run_command("seqkit grep -f $temp_files[0] $fq2 > $temp_files[2]");
run_command("seqkit grep -f $temp_files[1] $fq1 > $temp_files[3]");

# ======================
# ��װ�׶�
# ======================
my @assemblies = (
    { input => $temp_files[2], output => "$key.fq2.fasta" },
    { input => $temp_files[3], output => "$key.fq1.fasta" }
);

foreach my $asm (@assemblies) {
    my $outdir = "tmp_assembly_$$";  # ʹ��PID��֤Ψһ��
    run_command("megahit -r $asm->{input} -o $outdir");
    run_command("mv $outdir/final.contigs.fa $asm->{output}");
    run_command("rm -rf $outdir");
}

# ======================
# ������ʱ�ļ�
# ======================
unlink($sam_file, @temp_files) or warn "Cleanup failed: $!";

exit 0;