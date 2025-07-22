# 加载必要的包
library(vegan)
library(ggplot2)
library(ggpubr)
library(ape)
library(dplyr)
library(tidyr)
#统计方法与分析流程描述
#1. 组间差异分析方法
#Bray-Curtis距离比较（小提琴图）
#
#组内/组间划分：通过遍历所有样本对，根据样本的分组标签（如Project、Region_People等）将两两样本的Bray-Curtis距离划分为“组内”（同一分组）或“组间”（不同分组）。
#
#非参数检验：使用 Wilcoxon秩和检验（Mann-Whitney U检验） 比较组内与组间距离的显著性差异，检验结果通过ggpubr::stat_compare_means标注p值于小提琴图上。
#
#效应量计算：基于p值计算Cohen’s *r* 效应量（公式：用于量化差异的实际意义。
#
#2. 群落结构差异分析（PCoA图）
#主坐标分析（PCoA）：基于Bray-Curtis距离矩阵，使用ape::pcoa计算样本在主坐标空间的投影，前两轴解释的方差百分比标注于坐标轴标签。
#
#PERMANOVA检验：通过vegan::adonis2执行 多元方差分析（PERMANOVA），评估分组变量对群落结构的解释力，结果中提取 R²值（解释方差比例） 和 p值，并标注于图注。
#
#可视化优化：添加95%置信椭圆增强组间分布的可视化对比。
#
#3. 数据预处理
#严格过滤无效样本：剔除分组变量为NA或空字符串的样本，确保分析仅基于有效分组。
#
#子集距离矩阵：根据有效样本索引重构距离矩阵，避免无效数据干扰统计结果。
#
#异常处理：自动跳过有效分组数小于2的变量，防止单组或无比较意义的情况。
#
#4. 可视化实现
#工具依赖：基于ggplot2绘制小提琴图和PCoA图，ggpubr辅助添加统计标注。
#
#图形标注：
#
#小提琴图：标注Wilcoxon检验p值及效应量。
#
#PCoA图：右上角标注PERMANOVA的R²和p值，使用annotate确保文本位置自适应图形边界。
# (1) 计算Bray-Curtis距离
# 读取质粒矩阵
plasmid_matrix <- read.delim("Merge_Metaphlan_Genus_v2.txt", header=TRUE, row.names=1)
sample_plasmid <- t(plasmid_matrix)  # 转置为样本×质粒矩阵

# 计算Bray-Curtis距离
bc_dist <- vegdist(sample_plasmid, method="bray")
write.csv(as.matrix(bc_dist), "bray_curtis_distance.csv")

# 读取样本信息
sample_info <- read.delim("SampleID.txt", header=TRUE)
samples <- rownames(sample_plasmid)
sample_info <- sample_info[match(samples, sample_info$ID), ]

# (2) 分组比较与小提琴图
group_vars <- c("Project", "Region","People", "Time", "Group")

for (var in group_vars) {
  # 剔除空值样本（包含NA和空字符串）
  filtered_info <- sample_info %>%
    filter(!is.na(!!sym(var)) & !!sym(var) != "") %>%
    mutate(across(all_of(var), as.character))
  
  # 当有效分组数小于2时跳过
  if (n_distinct(filtered_info[[var]]) < 2) {
    message(paste("Skipping", var, "- less than 2 valid groups"))
    next
  }
  
  # 获取有效样本索引
  valid_samples <- filtered_info$ID
  keep_idx <- which(rownames(sample_plasmid) %in% valid_samples)
  
  # 子集距离矩阵
  sub_dist <- as.dist(as.matrix(bc_dist)[keep_idx, keep_idx])
  dist_matrix <- as.matrix(sub_dist)
  
  # 生成组内/组间标签
  groups <- filtered_info[[var]]
  n <- nrow(dist_matrix)
  labels <- character(n*(n-1)/2)
  dist_values <- numeric(n*(n-1)/2)
  idx <- 1
  
  for (i in 1:(n-1)) {
    for (j in (i+1):n) {
      dist_values[idx] <- dist_matrix[i, j]
      labels[idx] <- ifelse(groups[i] == groups[j], "Within", "Between")
      idx <- idx + 1
    }
  }
  
  # 创建数据框
  df_plot <- data.frame(
    Distance = dist_values,
    Comparison = factor(labels, levels = c("Within", "Between")),
    GroupVar = var
  )
  
  # 统计检验（当存在两组比较时）
  if (length(unique(labels)) > 1) {
    test_result <- wilcox.test(Distance ~ Comparison, data = df_plot)
    p_value <- test_result$p.value
    eff_size <- abs(qnorm(p_value)) / sqrt(nrow(df_plot))  # 计算效应量
  } else {
    p_value <- NA
    eff_size <- NA
  }
  
  # 绘制小提琴图
  p <- ggplot(df_plot, aes(x = Comparison, y = Distance, fill = Comparison)) +
    geom_violin(trim = FALSE) +
    geom_boxplot(width = 0.2) +
    scale_fill_manual(values = c("#00AFBB", "#E7B800")) +
    labs(title = paste("Bray-Curtis Distance by", var),
         x = "", y = "Bray-Curtis Distance") +
    theme_minimal()
  
  if (!is.na(p_value)) {
    p <- p + 
      stat_compare_means(
        method = "wilcox.test", 
        label = "p.format",
        comparisons = list(c("Within", "Between")),
        label.x = 1.5
      ) +
      annotate("text", x = 1.5, y = max(df_plot$Distance)*0.95,
               label = paste("Effect size:", round(eff_size, 3)),
               color = "darkred", size = 3)
  }
  
  ggsave(paste0("Violin_", var, ".pdf"), plot = p, width = 6, height = 6)
}

# (3) PCoA分析
for (var in group_vars) {
  # 剔除空值样本（包含NA和空字符串）
  filtered_info <- sample_info %>%
    filter(!is.na(!!sym(var)) & !!sym(var) != "") %>%
    mutate(across(all_of(var), as.factor))
  
  # 当有效分组数小于2时跳过
  if (nlevels(filtered_info[[var]]) < 2) {
    message(paste("Skipping PCoA for", var, "- less than 2 valid groups"))
    next
  }
  
  # 获取有效样本索引
  valid_samples <- filtered_info$ID
  keep_idx <- which(rownames(sample_plasmid) %in% valid_samples)
  
  # 子集距离矩阵
  sub_dist <- as.dist(as.matrix(bc_dist)[keep_idx, keep_idx])
  groups <- filtered_info[[var]]
  
  # 执行PERMANOVA检验
  set.seed(123)
  permanova <- adonis2(sub_dist ~ groups, data = filtered_info)
  p_value <- permanova$`Pr(>F)`[1]
  r_squared <- round(permanova$R2[1], 3)
  
  # 生成统计标注文本
  if (!is.na(p_value)) {
    stat_text <- paste0("PERMANOVA\nR²=", r_squared, 
                       "\np=", signif(p_value, 3))
  } else {
    stat_text <- "No valid comparison"
  }
  
  # PCoA分析
  pcoa_result <- pcoa(sub_dist)
  scores <- pcoa_result$vectors[, 1:2]
  var_exp <- pcoa_result$values$Relative_eig[1:2] * 100
  
  df_pcoa <- data.frame(
    PC1 = scores[, 1],
    PC2 = scores[, 2],
    Group = groups
  )
  
  # 绘制PCoA图
  p <- ggplot(df_pcoa, aes(x = PC1, y = PC2, color = Group)) +
    geom_point(size = 3, alpha = 0.8) +
    stat_ellipse(level = 0.95, linewidth = 0.8) +
    labs(
      x = paste0("PC1 (", round(var_exp[1], 2), "%)"),
      y = paste0("PC2 (", round(var_exp[2], 2), "%)"),
      title = paste("PCoA Plot by", var)
    ) +
    theme_minimal() +
    scale_color_viridis_d() +
    annotate("text", 
             x = Inf, y = Inf,
             label = stat_text,
             hjust = 1.1, vjust = 1.1,
             size = 4.5,
             color = "black",
             fontface = "bold") +
    theme(
      legend.position = "right",
      panel.grid.major = element_line(color = "grey90"),
      plot.margin = unit(c(1, 3, 1, 1), "cm")  # 增加右边距防止文字截断
    )
  
  ggsave(paste0("PCoA_", var, ".pdf"), plot = p, width = 9, height = 7)
}