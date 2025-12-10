# pGut - Plasmid Detection and Analysis Tool

## Overview

pGut is a comprehensive Perl-based tool for detecting and analyzing plasmid sequences in genomic data using similarity search and alignment-based methods. It supports both assembled genomes and raw sequencing data, providing detailed reports on plasmid presence and coverage.

## Features

- **Dual Analysis Modes**: Process both assembled genomes and raw sequencing reads
- **Multiple Input Formats**: Single files, sample lists, paired-end or single-end reads
- **Comprehensive Detection**: Uses BLAT for assembly similarity search and bowtie2 for read alignment
- **Detailed Reporting**: Generates sample-specific and summary reports
- **Flexible Parameters**: Adjustable coverage thresholds, alignment lengths, and thread usage
- **Quality Control**: Built-in format conversion and quality checks

## System Requirements

### Software Dependencies
- **Perl** (v5.10 or higher)
- **BLAT** (v36 or higher)
- **seqkit** (v0.10 or higher)
- **bowtie2** (v2.3 or higher)
- **samtools** (v1.9 or higher)
- **bcftools** (v1.9 or higher)

### Hardware Requirements
- Minimum 4GB RAM (8GB recommended)
- Multi-core processor for parallel processing
- Sufficient disk space for temporary files and results

## Installation

### Method 1: Direct Download
```bash
# Download the script
curl -O https://raw.githubusercontent.com/username/pGut/main/pGut.pl
chmod +x pGut.pl

### Method 2: Clone Repository
```bash
git clone https://github.com/zhangwen/pGut.git
cd pGut
chmod +x pGut.pl
```



## Quick Start

### Basic Usage with Assembled Genome
```bash
./pGut.pl -G genome.fasta -d plasmid_db/plasmids.fasta -o results/sample1
```

### Process Multiple Samples
```bash
./pGut.pl -L sample_list.txt -d plasmid_db/plasmids.fasta -o results/all_samples
```

### Analyze Raw Sequencing Data
```bash
# Paired-end reads
./pGut.pl -fq1 sample_R1.fastq -fq2 sample_R2.fastq -d plasmid_db -o results/raw_sample

# Single-end reads
./pGut.pl -fq1 sample.fastq -d plasmid_db -o results/single_end
```

## Detailed Usage

### Command Line Parameters

| Parameter | Short | Description | Required | Default |
|-----------|-------|-------------|----------|---------|
| `--genome` | `-G` | Single genome FASTA file | Conditional | - |
| `--list` | `-L` | List file containing genome FASTA paths | Conditional | - |
| `--fq1` | - | Raw sequencing read 1 | Conditional | - |
| `--fq2` | - | Raw sequencing read 2 (optional for single-end) | No | - |
| `--raw_list` | `-R` | Raw data list file (2-3 columns: sample, fq1, [fq2]) | Conditional | - |
| `--database` | `-d` | Plasmid FASTA file | Yes | - |
| `--output` | `-o` | Output prefix for results | Yes | - |
| `--threads` | `-t` | Number of threads | No | 4 |
| `--coverage` | `-c` | Minimum coverage percentage | No | 70 |
| `--min_length` | `-m` | Minimum alignment length | No | 300 |
| `--debug` | - | Enable debug mode | No | Disabled |
| `--help` | `-h` | Show help message | No | - |

**Note**: Use exactly one of `-G`, `-L`, `-fq1`, or `-R` to specify input type.

### Input File Formats

#### 1. Single Genome FASTA
```
>contig_1
ATCGATCGATCG...
>contig_2
GCTAGCTAGCTA...
```

#### 2. Genome List File
```
/path/to/genome1.fasta
/path/to/genome2.fasta
/path/to/genome3.fasta
```

#### 3. Raw Data List File
```
# 2-column format (single-end)
sample1    sample1_R1.fastq
sample2    sample2_R1.fastq

# 3-column format (paired-end)
sample3    sample3_R1.fastq    sample3_R2.fastq
sample4    sample4_R1.fastq    sample4_R2.fastq
```

#### 4. Database
- **Target** containing FASTA files (`.fa`, `.fasta`, `.fna`)
- **Single FASTA file** with plasmid reference sequences

## Examples

### Example 1: Single Assembly Analysis
```bash
./pGut.pl -G isolates/strainA.fasta -d databases/plasmids.fasta -o results/strainA -t 8
```

### Example 2: Batch Processing of Assemblies
```bash
# Create a list file
ls assemblies/*.fasta > assembly_list.txt

# Run pGut
./pGut.pl -L assembly_list.txt -d plasmid_db -o batch_results -t 16 -c 80 -m 500
```

### Example 3: Metagenomic Read Analysis
```bash
./pGut.pl -fq1 metagenome_R1.fastq.gz -fq2 metagenome_R2.fastq.gz \
          -d plasmid_db/plasmids.fasta \
          -o metagenome_plasmid_analysis \
          -t 12 -c 60
```

### Example 4: Multiple Raw Samples
```bash
# raw_samples.list content:
# sampleA    sampleA_R1.fastq.gz    sampleA_R2.fastq.gz
# sampleB    sampleB_R1.fastq.gz
# sampleC    sampleC_R1.fastq.gz    sampleC_R2.fastq.gz

./pGut.pl -R raw_samples.list -d plasmid_db -o all_raw_results -t 8
```

## Output Files

### For Each Sample
- `{output}.{sample}.result.txt`: Tab-separated detection results
- `{output}.{sample}.detailed_report.txt`: Detailed analysis summary
- `{output}.{sample}.blat.psl`: BLAT alignment results (assembly mode)
- `{output}.{sample}.sorted.bam`: Sorted alignment file (raw data mode)
- `{output}.{sample}.report.txt`: Comprehensive sample report

### Summary Files
- `{output}.summary.tsv`: Merged results from all samples
- `{output}.final_report.txt`: Comprehensive summary of all analyses
- `{output}.log`: Complete execution log

### Result File Format (example)
```
Sample      Plasmid     QueryLength  TargetLength  Coverage  AlignmentLength  PercentIdentity
sample1     pABC123     15000        20000         85.25     12787            98.76
sample1     pDEF456     15000        18000         72.33     10850            95.45
```

## Interpretation of Results

### Key Metrics
1. **Coverage**: Percentage of plasmid sequence covered by the query
2. **Depth**: Average read depth across covered regions (raw data only)
3. **Identity**: Percentage sequence identity in aligned regions
4. **Alignment Length**: Length of the aligned region in base pairs

### Thresholds
- Default minimum coverage: 70%
- Default minimum alignment length: 300 bp
- Adjust using `-c` and `-m` parameters

## Advanced Features

### Custom Database Building
```bash
# Create custom plasmid database
cat plasmid1.fasta plasmid2.fasta > custom_plasmid_db.fasta

# Run pGut with custom database
./pGut.pl -G genome.fasta -d custom_plasmid_db.fasta -o results/custom_db
```

### Parallel Processing
```bash
# Utilize multiple cores for faster processing
./pGut.pl -L large_list.txt -d plasmid_db -o results -t 32
```

### Debug Mode
```bash
# Enable debug mode to keep temporary files
./pGut.pl -G genome.fasta -d plasmid_db -o results -t 4 --debug
```

## Troubleshooting

### Common Issues

1. **"Command not found" errors**
   - Ensure all dependencies are installed and in PATH
   - Use `which blat` to check availability

2. **Memory issues with large datasets**
   - Increase system memory
   - Process samples individually instead of in batch
   - Use `-t` to control thread usage

3. **Empty result files**
   - Check input file formats
   - Verify database contains relevant sequences
   - Adjust coverage threshold with `-c`

4. **Slow performance**
   - Use fewer threads if memory is limited
   - Ensure input files are not excessively large
   - Consider pre-filtering reads

### Log File Examination
Check the log file (`{output}.log`) for detailed error messages and execution traces.

## Performance Considerations

- **Assembly mode**: Typically faster, suitable for batch processing
- **Raw data mode**: More resource-intensive, benefits from parallel processing
- **Memory usage**: Approximately 2-4GB per thread for raw data alignment
- **Disk space**: Temporary files can be up to 2x input size

## Citation

If you use pGut in your research, please cite:

```
Zhang, W. Plasmidome in the Human Gut Microbiome: Unveiling the Stealth Vectors of Antibiotic Resistance. Under Review [URL]
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

- **Author**: Wen Zhang
- **Email**: zhangwen@icdc.cn
- **Issues**: [GitHub Issues](https://github.com/zhangwen/pGut/issues)

## Acknowledgments

- Thanks to the developers of BLAT, bowtie2, samtools, bcftools, and seqkit
- Inspired by the need for comprehensive plasmid detection tools
- Built with support from the research community

## Version History

- **v2.0.0** (Current): Enhanced features, improved error handling, detailed reporting
- **v1.0.0**: Initial release with basic plasmid detection functionality



---

**Note**: This tool is designed for research purposes. 
```
