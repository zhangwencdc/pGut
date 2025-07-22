# Usage: OTU����/Species���� ����ҩ������� �Ƚ� Ѱ�����  
if (!require("psych"))  
  install.packages("psych")   

if (!require("optparse"))  
  install.packages("optparse")   

library(psych)  
library(optparse)  

if (!require("phyloseq"))  
  install.packages("phyloseq")   
library(phyloseq)  

# Usage: �������������Ĺ�ϵ�����ڻ��ƹ�������  
## clean R environment  
rm(list = ls())  
setwd('./')  

## parsing arguments  
args <- commandArgs(trailingOnly=TRUE)  

option_list <- list(  
  make_option(c("-i", "--input1"), type="character", help="Metaphlan Input file :colnames is SampleID[Required]"),  
  make_option(c("-g", "--input2"), type="character", help="Gene/Plasmid Input file: colnames is SampleID [Required]"),  
  make_option(c("-m", "--meta"), type="character", help="SampleInfo: row names are SampleID [Required]"),  
  make_option(c("-o", "--output"), type = "character", default = "Psych_output.csv",   
              help = "Output file name [default=Psych_output.csv]"),  
  make_option(c("-S", "--SampleN"), type = "integer", default = 10,  
              help = "Minimum number of samples where abundance > 0.01 to retain OTUs [default=10]")  ,
 make_option(c("-f", "--filter"), type="character", help="Filter characer[Required]")
)  

opts <- parse_args(OptionParser(option_list=option_list), args=args)  

# parameter checking  
if (is.null(opts$input1)) stop('Please input a table1 (-i1)')  
if (is.null(opts$input2)) stop('Please input a table2 (-i2)')  
if (is.null(opts$meta)) stop('Please input a meta file (-m)')  
if (is.null(opts$filter)) stop('Please input a key word for filter') 
matrixfile <- opts$input2  
otutab = read.delim(matrixfile, row.names=1)
bacterinfo <- read.delim(opts$input1, row.names = 1, header = TRUE)  
metafile <- opts$meta  
metainfo <- read.delim(metafile, row.names = 1, header = TRUE)  

# ��metainfo����ȡ��Ҫ����������  
exclude_samples <- rownames(metainfo)[metainfo[, 2] == opts$filter]  

# ����bacterinfo����exclude_samplesΪ��������  
bacterinfo_filtered <- bacterinfo[, (colnames(bacterinfo) %in% exclude_samples)]  
otutab_filtered<-otutab[, (colnames(otutab) %in% exclude_samples)]  
# ����phyloseq����  
ps1 <- phyloseq(otu_table(as.matrix(otutab_filtered), taxa_are_rows=TRUE))  
ps2 <- phyloseq(otu_table(as.matrix(bacterinfo_filtered), taxa_are_rows=TRUE))  

ps3<-prune_samples(sample_sums(ps1)>50,ps1)#�޳��ܷ��С��50%������
ps3 <- filter_taxa(ps1, function(x) sum(x > 0.01) > opts$SampleN, TRUE) # ��������opts$SampleN�����������з�ȴ���0.01��OTU  
ps4 <- filter_taxa(ps2, function(x) sum(x > 0) > opts$SampleN, TRUE) # ��������opts$SampleN�����������д��ڵ���ҩ����  

otufilter <- otu_table(ps3)  
resfilter <- otu_table(ps4)  

CorrDF <- function(cormat, pmat) {  
  ut <- upper.tri(cormat)   
  data.frame(  
    from = rownames(cormat)[row(cormat)[ut]],  
    to = colnames(cormat)[col(cormat)[ut]],  
    cor = (cormat)[ut],  
    p = pmat[ut]  
  )  
}  

# ���������Ĺ�ϵ  
filtered_data <- otufilter[, colnames(otufilter) %in% colnames(resfilter)]  
filtered_res <- resfilter[, colnames(resfilter) %in% colnames(filtered_data)]  

result <- corr.test(t(filtered_data), t(filtered_res), method="spearman", adjust="fdr")  
cor_df <- CorrDF(result$r, result$p)  
#cor_df <- cor_df[which(abs(cor_df$cor) >= 0.6),] # ����spearman����Ծ���ֵ>0.6�ı�
#cor_df <- cor_df[which(cor_df$p < 0.05),] # ����p-value < 0.05 or 0.001�ı�
# ���ļ�д����  
write.csv(cor_df, opts$output, quote = FALSE, row.names = FALSE)