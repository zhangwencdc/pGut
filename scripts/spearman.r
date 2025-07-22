# 加载必要的库（如果需要的话）  
# install.packages("ggplot2")  # Uncomment if you need it  

# 设置工作目录（根据需要修改）  
# setwd("your_directory_path")  

# 1. 读取质粒阳性率数据  
plasmid_data <- read.delim("Plasmid_cluster_positive_rate.txt", header = TRUE, stringsAsFactors = FALSE)  

# 2. 设置行名，并去掉重复质粒名  
plasmid_data <- plasmid_data[!duplicated(plasmid_data[[1]]), ]  
rownames(plasmid_data) <- plasmid_data[[1]]  
plasmid_data <- plasmid_data[, -1]  

# 3. 查看质粒数据结构  
print("Plasmid Data:")  
print(head(plasmid_data))  

# 4. 读取基因表达数据（请根据实际文件进行更改）  
# 假设文件名为 "gene_expression_data.txt"  
filtered_data <- read.delim("gene_expression_data.txt", header = TRUE, stringsAsFactors = FALSE)  

# 5. 检查基因数据结构  
print("Filtered Data:")  
print(head(filtered_data))  

# 6. 去掉基因名中的前缀 “X”  
plasmids <- gsub("^X", "", rownames(filtered_data))  
print("Processed Plasmids:")  
print(head(plasmids))  

# 7. 提取质粒阳性率  
plasmid_rates_vec <- plasmid_data[match(plasmids, rownames(plasmid_data)), "Pos"]  

# 8. 检查提取结果  
print("Plasmid Rates Vector:")  
print(plasmid_rates_vec)  

# 9. 确保没有 NA 值  
if(any(is.na(plasmid_rates_vec))) {  
    warning("存在未匹配的质粒名，请检查质粒名。")  
}  

# 10. 创建一个数据框用于后续处理  
plasmid_rates <- data.frame(Gene = plasmids, Pos = plasmid_rates_vec, row.names = NULL)  

# 11. 计算 Spearman 相关性及 p 值  
correlation_results <- data.frame(Gene = character(),   
                                   Spearman_Correlation = numeric(),   
                                   P_Value = numeric(),   
                                   stringsAsFactors = FALSE)  

# 遍历基因计算 Spearman 相关性和 p 值  
for (gene in filtered_data[[1]]) {  # 假设第一列是基因名  
    # 获取当前基因的数据（去掉基因名）  
    gene_data <- as.numeric(filtered_data[filtered_data[[1]] == gene, -1])  
    
    # 计算 Spearman 相关性和 p 值  
    test_result <- cor.test(gene_data, plasmid_rates$Pos, method = "spearman", use = "pairwise.complete.obs")  
    
    # 记录结果  
    correlation_results <- rbind(correlation_results,   
                                  data.frame(Gene = gene,   
                                             Spearman_Correlation = test_result$estimate,   
                                             P_Value = test_result$p.value))  
}  

# 12. 保存相关性结果到文件  
write.table(correlation_results, "gene_plasmid_spearman_correlation_results.txt", sep = "\t", row.names = FALSE, quote = FALSE)  

# 13. 打印结果以确认  
print("Correlation Results:")  
print(head(correlation_results))  
