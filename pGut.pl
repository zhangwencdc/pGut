#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd 'abs_path';
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempdir);
use POSIX qw(strftime);

# Author: Wen Zhang, zhangwen@icdc.cn 
# Version information
my $VERSION = "2.0.0";

# Global variables
my ($genome, $list, $fq1, $fq2, $raw_list, $db_dir, $output);
my $threads = 4;
my $min_coverage = 70;  # Minimum coverage percentage for plasmid detection
my $min_length = 300;   # Minimum alignment length
my $debug = 0;          # Debug mode

my %required_tools = (
    'blat'      => 1,
    'perl'      => 1,
    'seqkit'    => 1,
    'bowtie2'   => 1,
    'samtools'  => 1,
    'bcftools'  => 1
);

# Help information
sub usage {
    print <<"USAGE";

pGut.pl v$VERSION - Plasmid Detection and Analysis Tool

Description:
  Detects and analyzes plasmid sequences in genomic data using similarity search
  and alignment-based methods.

Usage:
  For assembled genomes:
    pGut.pl -G <genome.fasta> -d <database_dir> -o <output_prefix>
    pGut.pl -L <genome.list> -d <database_dir> -o <output_prefix>
  
  For raw sequencing data:
    pGut.pl -fq1 <read1.fq> [-fq2 <read2.fq>] -d <database_dir> -o <output_prefix>
    pGut.pl -R <raw.list> -d <database_dir> -o <output_prefix>

Parameters:
  -G STRING     Single genome FASTA file
  -L STRING     List file containing genome FASTA paths (one per line)
  -fq1 STRING   Raw sequencing read 1
  -fq2 STRING   Raw sequencing read 2 (optional for single-end)
  -R STRING     Raw data list file (2 or 3 columns: sample_name, fq1, [fq2])
  -d STRING     Target database directory (containing plasmid sequences)
  -o STRING     Output prefix for results
  -t INT        Number of threads (default: 4)
  -c FLOAT      Minimum coverage percentage (default: 70)
  -m INT        Minimum alignment length (default: 300)
  --debug       Enable debug mode
  -h, --help    Show this help message

Examples:
  Single assembly:   pGut.pl -G genome.fasta -d plasmid_db -o sample.result
  Assembly list:     pGut.pl -L samples.list -d plasmid_db -o all.result
  Paired-end reads:  pGut.pl -fq1 sample_R1.fq -fq2 sample_R2.fq -d plasmid_db -o sample.result
  Raw data list:     pGut.pl -R rawdata.list -d plasmid_db -o all.result

USAGE
    exit(0);
}

# Parse command line arguments
GetOptions(
    'G=s'       => \$genome,
    'L=s'       => \$list,
    'fq1=s'     => \$fq1,
    'fq2=s'     => \$fq2,
    'R=s'       => \$raw_list,
    'd=s'       => \$db_dir,
    'o=s'       => \$output,
    't=i'       => \$threads,
    'c=f'       => \$min_coverage,
    'm=i'       => \$min_length,
    'debug'     => \$debug,
    'h|help'    => \&usage,
) or usage();

# Check required parameters
unless (($genome || $list || $fq1 || $raw_list) && $db_dir && $output) {
    print "Error: Missing required parameters!\n";
    usage();
}

# Validate parameter combinations
if ($genome && $list) {
    die "Error: -G and -L parameters cannot be used together!\n";
}
if (($fq1 || $fq2) && ($genome || $list || $raw_list)) {
    die "Error: Raw data mode and assembly mode parameters cannot be mixed!\n";
}
if (($genome || $list) && $raw_list) {
    die "Error: Assembly mode and raw data list mode cannot be mixed!\n";
}

# Validate thread count
if ($threads < 1) {
    warn "Warning: Invalid thread count ($threads), using default (4)\n";
    $threads = 4;
}

# Validate coverage threshold
if ($min_coverage < 0 || $min_coverage > 100) {
    die "Error: Coverage percentage must be between 0 and 100!\n";
}

# Create output directory if it doesn't exist
my $output_dir = dirname($output);
if ($output_dir && !-d $output_dir) {
    make_path($output_dir) or die "Cannot create output directory $output_dir: $!\n";
}

# Main program
main();

sub main {
    my $start_time = time;
    print "pGut.pl v$VERSION - Starting plasmid detection analysis\n";
    print "Analysis started: " . localtime($start_time) . "\n";
    print "=" x 80 . "\n";
    
    # Create log file
    my $log_file = "$output.log";
    open my $LOG, '>', $log_file or die "Cannot create log file: $!\n";
    print $LOG "pGut.pl v$VERSION - Log file\n";
    print $LOG "Analysis started: " . localtime($start_time) . "\n";
    print $LOG "Command: " . join(' ', $0, @ARGV) . "\n\n";
    
    # Check for required tools
    check_required_tools($LOG);
    
    # Check database directory
    unless (-e $db_dir) {
        die "Error: Database directory '$db_dir' does not exist!\n";
    }
    
  
    
   
    # Select processing pipeline based on input type
    my @result_files;
    if ($genome) {
        my $result = process_assembly($genome, $LOG);
        push @result_files, $result if $result;
    }
    elsif ($list) {
        @result_files = process_assembly_list($list, $LOG);
    }
    elsif ($fq1) {
		 # Check for database index files
    my $db_index = "$db_dir";
    unless (-e "$db_index.1.bt2") {
        print "Building Bowtie2 index from database...\n";
        print $LOG "Building Bowtie2 index from database: $db_dir\n";
        my $build_cmd = "bowtie2-build --threads $threads $db_dir $db_index 2>&1";
        my $ret = run_command($build_cmd, "Bowtie2 index building", $LOG);
        if ($ret != 0) {
            die "Error: Failed to build Bowtie2 index!\n";
        }
    }
    
        my $result = process_raw_reads($fq1, $fq2, $LOG);
        push @result_files, $result if $result;
    }
    elsif ($raw_list) {
		 # Check for database index files
    my $db_index = "$db_dir";
    unless (-e "$db_index.1.bt2") {
        print "Building Bowtie2 index from database...\n";
        print $LOG "Building Bowtie2 index from database: $db_dir\n";
        my $build_cmd = "bowtie2-build --threads $threads $db_dir $db_index 2>&1";
        my $ret = run_command($build_cmd, "Bowtie2 index building", $LOG);
        if ($ret != 0) {
            die "Error: Failed to build Bowtie2 index!\n";
        }
    }
    
        @result_files = process_raw_list($raw_list, $LOG);
    }
    else {
        die "Error: No input file specified!\n";
    }
    
    # Merge results if multiple samples
    if (@result_files > 1) {
        merge_results(\@result_files, $LOG);
    }
    
    # Generate final summary report
    generate_final_report(\@result_files, $LOG);
    
    my $end_time = time;
    my $duration = $end_time - $start_time;
    print "=" x 80 . "\n";
    print "Analysis complete! Total time: " . format_duration($duration) . "\n";
    print "Results saved with prefix: $output\n";
    
    print $LOG "\nAnalysis completed: " . localtime($end_time) . "\n";
    print $LOG "Total duration: " . format_duration($duration) . "\n";
    close $LOG;
}

# Check if all required tools are available
sub check_required_tools {
    my ($log_handle) = @_;
    print "Checking required tools...\n";
    print $log_handle "Checking required tools...\n";
    
    my @missing_tools;
    
    foreach my $tool (keys %required_tools) {
        my $path = `which $tool 2>/dev/null`;
        chomp $path;
        
        if ($path && -x $path) {
            my $version = get_tool_version($tool);
            print "  ✓ $tool: $version\n";
            print $log_handle "  ✓ $tool: $version\n";
        } else {
            print "  ✗ $tool: NOT FOUND\n";
            print $log_handle "  ✗ $tool: NOT FOUND\n";
            push @missing_tools, $tool;
        }
    }
    
    if (@missing_tools) {
        die "Error: The following required tools are missing: " . 
            join(", ", @missing_tools) . "\n" .
            "Please install them and ensure they are in your PATH.\n";
    }
    
    print "All required tools are available.\n";
    print $log_handle "All required tools are available.\n";
}

# Get version information for tools
sub get_tool_version {
    my ($tool) = @_;
    my $version = "unknown";
    
    if ($tool eq 'blat') {
        $version = `blat -version 2>&1 | head -1` || "unknown";
    }
    elsif ($tool eq 'seqkit') {
        $version = `seqkit version 2>&1 | head -1` || "unknown";
    }
    elsif ($tool eq 'bowtie2') {
        $version = `bowtie2 --version 2>&1 | head -1` || "unknown";
    }
    elsif ($tool eq 'samtools') {
        $version = `samtools --version 2>&1 | head -1` || "unknown";
    }
    elsif ($tool eq 'bcftools') {
        $version = `bcftools --version 2>&1 | head -1` || "unknown";
    }
    elsif ($tool eq 'perl') {
        $version = `perl -v | grep 'This is' | head -1` || "unknown";
    }
    
    chomp $version;
    $version =~ s/^\s+|\s+$//g;
    return $version;
}


# Process single assembly result
sub process_assembly {
    my ($genome_file, $log_handle) = @_;
    
    print "Mode: Assembled genome (single input)\n";
    print "Genome: $genome_file\n";
    print $log_handle "Processing assembled genome: $genome_file\n";
    
    # Check input file
    check_file($genome_file);
    
    # Extract sample name
    my $sample_name = basename($genome_file, ('.fa', '.fasta', '.fna'));
    my $sample_output = "$output.$sample_name";
    
    # BLAT analysis
    print "Step 1: Similarity search with BLAT...\n";
    print $log_handle "Running BLAT against database...\n";
    
    my $blat_output = "$sample_output.blat.psl";
    my $result_file = "$sample_output.result.txt";
    
    # Run BLAT
    my $blat_cmd = "blat $db_dir $genome_file $blat_output 2>&1";
    my $ret = run_command($blat_cmd, "BLAT alignment", $log_handle);
    
    if ($ret != 0) {
        warn "Warning: BLAT command returned non-zero exit code: $ret\n";
    }
    
    # Parse BLAT results
    parse_blat_results($blat_output, $result_file, $sample_name);
    
    # Generate detailed report
    generate_detailed_report($blat_output, $sample_output, $sample_name);
    
    return $result_file;
}

# Parse BLAT results
sub parse_blat_results {
    my ($blat_file, $result_file, $sample_name) = @_;
    
    open my $IN, '<', $blat_file or die "Cannot open BLAT output file: $!\n";
    open my $OUT, '>', $result_file or die "Cannot create result file: $!\n";
    
    # Write header
    print $OUT "Sample\tTargetLength\tCoverage\tAlignmentLength\tPercentIdentity\n";
    
    my %matches;
    my $line_count = 0;
    
    while (my $line = <$IN>) {
        $line_count++;
        next if $line_count <= 5;  # Skip header lines
        
        chomp $line;
        my @fields = split /\t/, $line;
        
        # Check if we have enough fields
        next unless @fields >= 18;
        
        my ($matches, $misMatches, $repMatches, $nCount, $qNumInsert, $qBaseInsert,
            $tNumInsert, $tBaseInsert, $strand, $qName, $qSize, $qStart, $qEnd,
            $tName, $tSize, $tStart, $tEnd, $blockCount) = @fields[0..17];
        
        my $alignment_length = $qEnd - $qStart;
        
        # Skip if alignment is too short
        next if $alignment_length < $min_length;
        
        # Calculate coverage and identity
        my $coverage = ($alignment_length / $qSize) * 100;
        my $identity = 0;
        if (($matches + $misMatches + $repMatches) > 0) {
            $identity = ($matches + $repMatches) / ($matches + $misMatches + $repMatches) * 100;
        }
        
        # Store match information
        push @{$matches{$tName}}, {
            query_length => $qSize,
            target_length => $tSize,
            alignment_length => $alignment_length,
            coverage => sprintf("%.2f", $coverage),
            identity => sprintf("%.2f", $identity),
            q_start => $qStart,
            q_end => $qEnd,
            t_start => $tStart,
            t_end => $tEnd
        };
    }
    
    close $IN;
    
    # Process and output matches
    foreach my $plasmid (sort keys %matches) {
        my @hits = @{$matches{$plasmid}};
        
        # Find best hit (by coverage)
        my $best_hit = $hits[0];
        foreach my $hit (@hits) {
            if ($hit->{coverage} > $best_hit->{coverage}) {
                $best_hit = $hit;
            }
        }
        
        # Output if coverage meets threshold
        if ($best_hit->{coverage} >= $min_coverage) {
            print $OUT join("\t",
                $sample_name,
                
                $best_hit->{target_length},
                $best_hit->{coverage},
                $best_hit->{alignment_length},
                $best_hit->{identity}
            ) . "\n";
        }
    }
    
    close $OUT;
}

# Generate detailed report from BLAT results
sub generate_detailed_report {
    my ($blat_file, $output_prefix, $sample_name) = @_;
    
    my $report_file = "$output_prefix.detailed_report.txt";
    open my $REPORT, '>', $report_file or die "Cannot create detailed report: $!\n";
    
    print $REPORT "Detailed Plasmid Detection Report\n";
    print $REPORT "=" x 60 . "\n";
    print $REPORT "Sample: $sample_name\n";
    print $REPORT "Analysis date: " . localtime() . "\n";
    print $REPORT "Minimum coverage threshold: ${min_coverage}%\n";
    print $REPORT "Minimum alignment length: $min_length bp\n\n";
    
    # Parse and summarize BLAT results
    open my $IN, '<', $blat_file or die "Cannot open BLAT file: $!\n";
    
    my %summary;
    my $total_hits = 0;
    my $line_count = 0;
    
    while (my $line = <$IN>) {
        $line_count++;
        next if $line_count <= 5;
        
        chomp $line;
        my @fields = split /\t/, $line;
        next unless @fields >= 18;
        
        my ($matches, $tName, $qSize, $tSize, $qStart, $qEnd, $tStart, $tEnd) = 
            ($fields[0], $fields[13], $fields[10], $fields[14], $fields[11], 
             $fields[12], $fields[15], $fields[16]);
        
        my $alignment_length = $qEnd - $qStart;
        next if $alignment_length < $min_length;
        
        my $coverage = ($alignment_length / $qSize) * 100;
        
        if ($coverage >= $min_coverage) {
            $summary{$tName} = {
                count => ($summary{$tName}->{count} || 0) + 1,
                total_length => ($summary{$tName}->{total_length} || 0) + $alignment_length,
                max_coverage => ($summary{$tName}->{max_coverage} || 0) < $coverage ? $coverage : $summary{$tName}->{max_coverage}
            };
            $total_hits++;
        }
    }
    
    close $IN;
    
    # Print summary
    print $REPORT "Summary of significant hits:\n";
    print $REPORT "-" x 60 . "\n";
    
    if ($total_hits == 0) {
        print $REPORT "No significant plasmid matches found.\n";
    } else {
        print $REPORT sprintf("%-30s %10s %15s %15s\n", 
            "Plasmid", "Hits", "Max Coverage(%)", "Total Length(bp)");
        print $REPORT "-" x 60 . "\n";
        
        foreach my $plasmid (sort keys %summary) {
            print $REPORT sprintf("%-30s %10d %15.2f %15d\n",
                $plasmid,
                $summary{$plasmid}->{count},
                $summary{$plasmid}->{max_coverage},
                $summary{$plasmid}->{total_length}
            );
        }
    }
    
    close $REPORT;
}

# Process assembly list
sub process_assembly_list {
    my ($list_file, $log_handle) = @_;
    
    print "Mode: Assembled genomes (list input)\n";
    print "Sample list: $list_file\n";
    print $log_handle "Processing assembly list: $list_file\n";
    
    check_file($list_file);
    
    open my $fh, '<', $list_file or die "Cannot open file $list_file: $!\n";
    
    my $count = 0;
    my @result_files;
    
    while (my $line = <$fh>) {
        chomp $line;
        $line =~ s/^\s+|\s+$//g;  # Trim whitespace
        next if $line =~ /^\s*$/ || $line =~ /^#/;  # Skip empty lines and comments
        
        $count++;
        my $genome_file = abs_path($line);
        
        print "\nProcessing sample $count: $genome_file\n";
        print $log_handle "Processing sample $count: $genome_file\n";
        
        # Create unique output for each sample
        my $sample_output = "$output.sample$count";
        my $orig_output = $output;
        $output = $sample_output;
        
        my $result = process_assembly($genome_file, $log_handle);
        push @result_files, $result if $result;
        
        $output = $orig_output;
    }
    
    close $fh;
    
    print "\nProcessed $count samples from list.\n";
    return @result_files;
}

# Process raw sequencing reads (single sample)
sub process_raw_reads {
    my ($r1, $r2, $log_handle) = @_;
    
    my $sample_name = basename($r1, ('.fq', '.fastq', '.fq.gz', '.fastq.gz'));
    my $sample_output = "$output.$sample_name";
    
    if ($r2) {
        print "Mode: Raw sequencing data (paired-end)\n";
        print "Sample: $sample_name\n";
        print "Read1: $r1\n";
        print "Read2: $r2\n";
        print $log_handle "Processing paired-end data for $sample_name\n";
    } else {
        print "Mode: Raw sequencing data (single-end)\n";
        print "Sample: $sample_name\n";
        print "Read: $r1\n";
        print $log_handle "Processing single-end data for $sample_name\n";
    }
    
    # Check input files
    check_file($r1);
    check_file($r2) if $r2;
    
    # Create temporary directory
    my $temp_dir = tempdir("pGut_XXXXXX", CLEANUP => !$debug);
    
  
    
    # 1. Alignment with bowtie2
    print "Step 1: Alignment with bowtie2...\n";
    print $log_handle "Step 2: Bowtie2 alignment\n";
    
    my $sam_file = "$temp_dir/alignment.sam";
    my $bowtie_cmd = "bowtie2 -x $db_dir -p $threads --very-sensitive";
    
    if ($r2) {
        $bowtie_cmd .= " -1 $r1 -2 $r2";
    } else {
        $bowtie_cmd .= " -U $r1";
    }
    $bowtie_cmd .= " -S $sam_file 2>&1";
    
    run_command($bowtie_cmd, "bowtie2 alignment", $log_handle);
    
    # 3. SAM to BAM conversion and processing
    print "Step 2: Processing alignment results...\n";
    print $log_handle "Step 3: Processing BAM file\n";
    
    my $bam_file = "$sample_output.sorted.bam";
    my $sorted_bam = "$sample_output.sorted.bam";
    
    # Convert SAM to BAM, sort, and index
    run_command("samtools view -bS $sam_file 2>&1 | samtools sort -@ $threads -o $sorted_bam - 2>&1", 
                "samtools sort", $log_handle);
    run_command("samtools index $sorted_bam 2>&1", "samtools index", $log_handle);
    
    # Copy sorted BAM to output location
    run_command("cp $sorted_bam $bam_file 2>&1", "copy BAM file", $log_handle);
    run_command("cp $sorted_bam.bai $bam_file.bai 2>&1", "copy BAM index", $log_handle);
    
    # 4. Calculate coverage and generate results
    print "Step 3: Calculating coverage and generating results...\n";
    print $log_handle "Step 4: Coverage calculation\n";
    
    my $result_file = "$sample_output.result.txt";
    generate_coverage_report($sorted_bam, $result_file, $sample_name);
    
    # 5. Optional: Variant calling
    print "Step 4: Variant calling (if reference available)...\n";
    print $log_handle "Step 5: Variant calling\n";
    
   
    my $vcf_file = "$sample_output.variants.vcf";
    
    if (-e $db_dir) {
        my $bcftools_cmd = "bcftools mpileup -f $db_dir $sorted_bam | " .
                          "bcftools call -mv -o $vcf_file ";
		#print $bcftools_cmd;
        run_command($bcftools_cmd, "bcftools variant calling", $log_handle);
    }
    
    # 6. Generate comprehensive report
    generate_rawdata_report($sample_output, $sample_name, $r1, $r2, $bam_file, $vcf_file);
    
    # Clean up if not in debug mode
    unless ($debug) {
        unlink $sam_file if -e $sam_file;
        system "rm -rf $temp_dir\n";
    }
    
    return $result_file;
}

# Generate coverage report from BAM file
sub generate_coverage_report {
    my ($bam_file, $result_file, $sample_name) = @_;
    
    open my $OUT, '>', $result_file or die "Cannot create result file: $!\n";
    print $OUT "Sample\tMapLength\tDepth\tMappedReads\n";
    
    # Get plasmid names from database
  
    open my $DB, '<', $db_dir or die "Cannot open database fasta: $!\n";
    
    my %plasmids;
    my $current_seq = '';
    while (my $line = <$DB>) {
        chomp $line;
        if ($line =~ /^>(\S+)/) {
            $current_seq = $1;
            $plasmids{$current_seq} = 1;
        }
    }
    close $DB;
    
    # Calculate coverage for each plasmid
    foreach my $plasmid (sort keys %plasmids) {
        # Get coverage statistics
        my $coverage_cmd = "samtools depth -r $plasmid $bam_file 2>/dev/null | " .
                          "awk '{sum+=\$3} END {if (NR>0) print NR, sum/NR, sum; else print 0,0,0}'";
        #print "$coverage_cmd\n";
        my $result = `$coverage_cmd`;
        chomp $result;
        my ($covered_bases, $avg_depth, $total_depth) = split /\s+/, $result;
        
        # Get mapped read count
        my $read_count = `samtools view -c -F 4 $bam_file $plasmid 2>/dev/null`;
        chomp $read_count;
        $read_count ||= 0;
        
        # Get plasmid length from database
        my $length_cmd = "samtools faidx $db_dir $plasmid 2>/dev/null | " .
                        "seqkit stats -T 2>/dev/null | tail -1 | cut -f4";
        my $plasmid_length = `$length_cmd`;
        chomp $plasmid_length;
        $plasmid_length ||= 1;  # Avoid division by zero
        
        # Calculate coverage percentage
        my $coverage_percent = ($covered_bases / $plasmid_length) * 100;
        
        # Output if coverage meets threshold
        if ($coverage_percent >= $min_coverage) {
            print $OUT join("\t",
                $sample_name,             
                $covered_bases,
                sprintf("%.2f", $avg_depth),
                $read_count
            ) . "\n";
        }
    }
    
    close $OUT;
}

# Generate report for raw data analysis
sub generate_rawdata_report {
    my ($output_prefix, $sample_name, $r1, $r2, $bam_file, $vcf_file) = @_;
    
    my $report_file = "$output_prefix.report.txt";
    open my $REPORT, '>', $report_file or die "Cannot create report: $!\n";
    
    print $REPORT "Raw Data Analysis Report\n";
    print $REPORT "=" x 60 . "\n";
    print $REPORT "Sample: $sample_name\n";
    print $REPORT "Analysis date: " . localtime() . "\n";
    print $REPORT "Read1: $r1\n";
    print $REPORT "Read2: " . ($r2 || "Not provided") . "\n\n";
    
    # Alignment statistics
    print $REPORT "Alignment Statistics:\n";
    print $REPORT "-" x 60 . "\n";
    
    if (-e $bam_file) {
        my $stats = `samtools flagstat $bam_file 2>/dev/null`;
        print $REPORT $stats if $stats;
    }
    
    # Coverage summary
    print $REPORT "\nCoverage Summary:\n";
    print $REPORT "-" x 60 . "\n";
    
    my $result_file = "$output_prefix.result.txt";
    if (-e $result_file) {
        open my $RES, '<', $result_file or warn "Cannot open result file\n";
        my $header = <$RES>;
        my $count = 0;
        while (<$RES>) {
            $count++;
        }
        close $RES;
        
        print $REPORT "Plasmids with coverage >= ${min_coverage}%: $count\n";
        
        
            
            close $RES;
        
    }
    
    # Variant information
    if (-e $vcf_file && -s $vcf_file) {
        print $REPORT "\nVariant Summary:\n";
        print $REPORT "-" x 60 . "\n";
        
        my $variant_count = `grep -v '^#' $vcf_file | wc -l`;
        chomp $variant_count;
        print $REPORT "Total variants called: $variant_count\n";
    }
    
    close $REPORT;
}

# Process raw sequencing data list
sub process_raw_list {
    my ($list_file, $log_handle) = @_;
    
    print "Mode: Raw sequencing data (list input)\n";
    print "Raw data list: $list_file\n";
    print $log_handle "Processing raw data list: $list_file\n";
    
    check_file($list_file);
    
    open my $fh, '<', $list_file or die "Cannot open file $list_file: $!\n";
    
    my $count = 0;
    my @result_files;
    
    while (my $line = <$fh>) {
        chomp $line;
        $line =~ s/^\s+|\s+$//g;
        next if $line =~ /^\s*$/ || $line =~ /^#/;
        
        $count++;
        my @fields = split /\s+/, $line, 4;
        
        my $orig_output = $output;
        
        if (@fields >= 2) {
            my $sample_name = $fields[0];
            my $fq1_file = $fields[1];
            my $fq2_file = (@fields >= 3) ? $fields[2] : undef;
            
            print "\nProcessing sample $count ($sample_name)...\n";
            print $log_handle "Processing sample $count: $sample_name\n";
            
            my $sample_output = "$output.$sample_name";
            $output = $sample_output;
            
            my $result = process_raw_reads($fq1_file, $fq2_file, $log_handle);
            push @result_files, $result if $result;
            
            $output = $orig_output;
        } else {
            warn "Warning: Line $count has incorrect format, skipping\n";
            print $log_handle "Warning: Skipping malformed line: $line\n";
        }
    }
    
    close $fh;
    
    print "\nProcessed $count samples from raw data list.\n";
    return @result_files;
}

# Check if file exists and is readable
sub check_file {
    my ($file) = @_;
    return unless defined $file;  # Allow undefined for optional files
    
    unless (-e $file) {
        die "Error: File '$file' does not exist!\n";
    }
    unless (-r $file) {
        die "Error: File '$file' is not readable!\n";
    }
    unless (-s $file) {
        warn "Warning: File '$file' is empty!\n";
    }
}

# Execute external command with error checking
sub run_command {
    my ($cmd, $description, $log_handle) = @_;
    
    print "  Executing: $description\n";
    print $log_handle "Command [$description]: $cmd\n" if $log_handle;
    
    if ($debug) {
        print "  [DEBUG] Command: $cmd\n";
    }
    
    my $ret = system($cmd);
    
    if ($ret != 0) {
        warn "Warning: Command '$description' failed with exit code $ret\n";
        print $log_handle "Warning: Command failed with exit code $ret\n" if $log_handle;
    }
    
    return $ret;
}

# Merge results from multiple samples
sub merge_results {
    my ($result_files, $log_handle) = @_;
    
    print "\nMerging results from " . scalar(@$result_files) . " samples...\n";
    print $log_handle "\nMerging " . scalar(@$result_files) . " result files\n";
    
    my $merged_file = "$output.summary.tsv";
    open my $OUT, '>', $merged_file or die "Cannot create merged file: $!\n";
    
    # Write header (read from first file)
    if (open my $FIRST, '<', $result_files->[0]) {
        my $header = <$FIRST>;
        print $OUT $header;
        close $FIRST;
    }
    
    # Merge content from all files
    my $total_lines = 0;
    foreach my $file (@$result_files) {
        if (open my $IN, '<', $file) {
            my $header = <$IN>;  # Skip header
            while (my $line = <$IN>) {
                print $OUT $line;
                $total_lines++;
            }
            close $IN;
        } else {
            warn "Warning: Cannot open result file $file for merging\n";
        }
    }
    
    close $OUT;
    
    print "  Merged $total_lines hits into $merged_file\n";
    print $log_handle "  Created merged file: $merged_file ($total_lines hits)\n";
    
    return $merged_file;
}

# Generate final summary report
sub generate_final_report {
    my ($result_files, $log_handle) = @_;
    
    my $report_file = "$output.final_report.txt";
    open my $REPORT, '>', $report_file or die "Cannot create final report: $!\n";
    
    print $REPORT "pGut.pl Final Analysis Report\n";
    print $REPORT "=" x 80 . "\n";
    print $REPORT "Analysis completed: " . localtime() . "\n";
    print $REPORT "Program version: $VERSION\n";
    print $REPORT "Database directory: $db_dir\n";
    print $REPORT "Output prefix: $output\n";
    print $REPORT "Threads used: $threads\n";
    print $REPORT "Minimum coverage threshold: ${min_coverage}%\n";
    print $REPORT "Minimum alignment length: $min_length bp\n\n";
    
    my $total_samples = scalar(@$result_files);
    print $REPORT "Total samples processed: $total_samples\n\n";
    
    # Count positive samples
    my $positive_samples = 0;
    my %plasmid_counts;
    
    foreach my $file (@$result_files) {
        if (open my $IN, '<', $file) {
            my $header = <$IN>;
            my $hits_in_file = 0;
            while (my $line = <$IN>) {
                chomp $line;
                my @fields = split /\t/, $line;
                if (@fields >= 2) {
                    my $plasmid = $fields[1];
                    $plasmid_counts{$plasmid}++;
                    $hits_in_file++;
                }
            }
            close $IN;
            
            if ($hits_in_file > 0) {
                $positive_samples++;
            }
        }
    }
    
    print $REPORT "Samples with plasmid matches: $positive_samples ($total_samples total)\n\n";
    
    # Summary of plasmid frequencies
    print $REPORT "Plasmid Detection Summary:\n";
    print $REPORT "-" x 80 . "\n";
    
    if (keys %plasmid_counts > 0) {
        print $REPORT sprintf("%-40s %10s %15s\n", 
            "Plasmid", "Count", "Frequency(%)");
        print $REPORT "-" x 80 . "\n";
        
        foreach my $plasmid (sort {$plasmid_counts{$b} <=> $plasmid_counts{$a}} keys %plasmid_counts) {
            my $frequency = ($plasmid_counts{$plasmid} / $total_samples) * 100;
            print $REPORT sprintf("%-40s %10d %15.2f\n",
                $plasmid,
                $plasmid_counts{$plasmid},
                $frequency
            );
        }
    } else {
        print $REPORT "No plasmid matches found in any sample.\n";
    }
    
    print $REPORT "\nGenerated files:\n";
    print $REPORT "-" x 80 . "\n";
    
    # List generated files
    my @files = glob("$output*");
    foreach my $file (sort @files) {
        if (-e $file) {
            my $size = -s $file;
            my $size_str = format_file_size($size);
            my $mtime = localtime((stat($file))[9]);
            print $REPORT sprintf("  %-40s %12s  %s\n", 
                basename($file), $size_str, $mtime);
        }
    }
    
    close $REPORT;
    
    print "Final report generated: $report_file\n";
    print $log_handle "Final report created: $report_file\n";
}

# Format file size for human readability
sub format_file_size {
    my ($size) = @_;
    return '0 B' if $size == 0;
    
    my @units = ('B', 'KB', 'MB', 'GB', 'TB');
    my $unit_index = 0;
    
    while ($size >= 1024 && $unit_index < $#units) {
        $size /= 1024;
        $unit_index++;
    }
    
    return sprintf("%.2f %s", $size, $units[$unit_index]);
}

# Format duration in seconds to readable format
sub format_duration {
    my ($seconds) = @_;
    my $hours = int($seconds / 3600);
    my $minutes = int(($seconds % 3600) / 60);
    my $secs = $seconds % 60;
    
    if ($hours > 0) {
        return sprintf("%dh %dm %ds", $hours, $minutes, $secs);
    } elsif ($minutes > 0) {
        return sprintf("%dm %ds", $minutes, $secs);
    } else {
        return sprintf("%ds", $secs);
    }
}

1;