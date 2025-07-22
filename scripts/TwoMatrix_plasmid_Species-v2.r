#Usage:Plasmid cluster矩阵 计算多个plasmid cluster之间的共线性
if (!require("psych"))
  install.packages("psych") 
 
if (!require("optparse"))
  install.packages("optparse") 

library(psych)
library(optparse)
if (!require("phyloseq"))
  install.packages("phyloseq") 
  library(phyloseq)

## Usage: 计算两个矩阵间的关系，用于绘制共现网络  
## clean R environment  
rm(list = ls())  
setwd('./')  

## parsing arguments  
args <- commandArgs(trailingOnly=TRUE)  
option_list <- list(  
  make_option(c("-i", "--input"), type="character", help="Input file: colnames is SampleID [Required]"),   
  make_option(c("-m", "--meta"), type="character", help="Input file 2: colnames is SampleID [Required]")  
)  

opts <- parse_args(OptionParser(option_list=option_list), args=args)  

# parameter checking  
if(is.null(opts$input)) stop('Please input a table1!')  
if(is.null(opts$meta)) stop('Please input a table2!')  

matrixfile <- opts$input  
mapfile <- opts$meta  

otutab <- read.delim(matrixfile, row.names=1)  
resinfo <- read.table(mapfile, row.names=1, header=TRUE)  

# Creating phyloseq objects  
ps1 <- phyloseq(otu_table(as.matrix(otutab), taxa_are_rows=TRUE))  
ps2 <- phyloseq(otu_table(as.matrix(resinfo), taxa_are_rows=TRUE))  

# 计算总样本数  
total_samples <- nsamples(ps1)  

# Filtering the phyloseq objects  
threshold <- total_samples * 0.30  # 计算大于30%总样本数的阈值  
ps3 <- filter_taxa(ps1, function(x) sum(x > 0) >= threshold, TRUE)  # 仅保留存在超过30%总样本数的OTU  
ps4 <- filter_taxa(ps2, function(x) sum(x > 0) >= threshold, TRUE)  # 保持一致的过滤条件  

# Extracting filtered OTU tables  
otufilter <- otu_table(ps3)  
resfilter <- otu_table(ps4)  

# 确保在 p3 和 p4 中都存在的列  
common_cols <- intersect(colnames(otufilter), colnames(resfilter))  

# 输出新文件  
filtered_data <- otufilter[, common_cols]  
filtered_res <- resfilter[, common_cols]  

# 保存过滤后的数据到文件  
#write.table(as.data.frame(filtered_data), "filtered_otu_table.txt", sep="\t", quote=FALSE, col.names=NA)  
#write.table(as.data.frame(filtered_res), "filtered_species_table.txt", sep="\t", quote=FALSE, col.names=NA)

CorrDF <- function(cormat, pmat) {
  ut <- upper.tri(cormat) 
  data.frame(
    from = rownames(cormat)[row(cormat)[ut]],
    to = colnames(cormat)[col(cormat)[ut]],
    cor = (cormat)[ut],
    p = pmat[ut]
  )
}
result<-corr.test(t(filtered_data),t(filtered_res),method="spearman",adjust="fdr")
cor_df <- CorrDF(result$r , result$p)
cor_df
#cor_df <- cor_df[which(abs(cor_df$cor) >= 0.6),] # 保留spearman相关性绝对值>0.6的边
#cor_df <- cor_df[which(cor_df$p < 0.05),] # 保留p-value < 0.05 or 0.001的边
write.csv(cor_df,"Psych_result_Plasmid_Species.csv",quote = FALSE,row.names = FALSE)
