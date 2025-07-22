# ���ر�Ҫ�Ŀ⣨�����Ҫ�Ļ���  
# install.packages("ggplot2")  # Uncomment if you need it  

# ���ù���Ŀ¼��������Ҫ�޸ģ�  
# setwd("your_directory_path")  

# 1. ��ȡ��������������  
plasmid_data <- read.delim("Plasmid_cluster_positive_rate.txt", header = TRUE, stringsAsFactors = FALSE)  

# 2. ������������ȥ���ظ�������  
plasmid_data <- plasmid_data[!duplicated(plasmid_data[[1]]), ]  
rownames(plasmid_data) <- plasmid_data[[1]]  
plasmid_data <- plasmid_data[, -1]  

# 3. �鿴�������ݽṹ  
print("Plasmid Data:")  
print(head(plasmid_data))  

# 4. ��ȡ���������ݣ������ʵ���ļ����и��ģ�  
# �����ļ���Ϊ "gene_expression_data.txt"  
filtered_data <- read.delim("gene_expression_data.txt", header = TRUE, stringsAsFactors = FALSE)  

# 5. ���������ݽṹ  
print("Filtered Data:")  
print(head(filtered_data))  

# 6. ȥ���������е�ǰ׺ ��X��  
plasmids <- gsub("^X", "", rownames(filtered_data))  
print("Processed Plasmids:")  
print(head(plasmids))  

# 7. ��ȡ����������  
plasmid_rates_vec <- plasmid_data[match(plasmids, rownames(plasmid_data)), "Pos"]  

# 8. �����ȡ���  
print("Plasmid Rates Vector:")  
print(plasmid_rates_vec)  

# 9. ȷ��û�� NA ֵ  
if(any(is.na(plasmid_rates_vec))) {  
    warning("����δƥ�����������������������")  
}  

# 10. ����һ�����ݿ����ں�������  
plasmid_rates <- data.frame(Gene = plasmids, Pos = plasmid_rates_vec, row.names = NULL)  

# 11. ���� Spearman ����Լ� p ֵ  
correlation_results <- data.frame(Gene = character(),   
                                   Spearman_Correlation = numeric(),   
                                   P_Value = numeric(),   
                                   stringsAsFactors = FALSE)  

# ����������� Spearman ����Ժ� p ֵ  
for (gene in filtered_data[[1]]) {  # �����һ���ǻ�����  
    # ��ȡ��ǰ��������ݣ�ȥ����������  
    gene_data <- as.numeric(filtered_data[filtered_data[[1]] == gene, -1])  
    
    # ���� Spearman ����Ժ� p ֵ  
    test_result <- cor.test(gene_data, plasmid_rates$Pos, method = "spearman", use = "pairwise.complete.obs")  
    
    # ��¼���  
    correlation_results <- rbind(correlation_results,   
                                  data.frame(Gene = gene,   
                                             Spearman_Correlation = test_result$estimate,   
                                             P_Value = test_result$p.value))  
}  

# 12. ��������Խ�����ļ�  
write.table(correlation_results, "gene_plasmid_spearman_correlation_results.txt", sep = "\t", row.names = FALSE, quote = FALSE)  

# 13. ��ӡ�����ȷ��  
print("Correlation Results:")  
print(head(correlation_results))  
