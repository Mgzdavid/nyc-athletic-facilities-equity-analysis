# Step 6: NTA Income Group Equity Analysis
library(dplyr)
library(readr)
library(ggplot2)

# 读取NTA密度统计表
nta <- read.csv('output_nta/nta_facility_density_summary.csv')

# 假设收入字段为pop_1e（如实际为median_income请修改）
nta <- nta %>% mutate(income_quartile = ntile(pop_1e, 4))

# 统计每组均值
income_group_means <- nta %>%
  group_by(income_quartile) %>%
  summarise(
    mean_facility_density_km2 = mean(facility_density_km2, na.rm = TRUE),
    mean_facility_per_1000_youth = mean(facility_per_1000_youth, na.rm = TRUE),
    n = n()
  )
write.csv(income_group_means, 'output_nta/nta_facility_density_income_group_means.csv', row.names = FALSE)

# 优化版箱线图：每千青少年设施数按收入分组
p1_opt <- ggplot(nta, aes(x = factor(income_quartile), y = facility_per_1000_youth, fill = factor(income_quartile))) +
  geom_boxplot(outlier.shape = 21, outlier.fill = 'black', outlier.color = 'black', alpha = 0.8, color = "black", lwd = 1) +
  labs(title = 'Facilities per 1,000 Youth by Income Quartile', x = 'Income Quartile (1=Lowest, 4=Highest)', y = 'Facilities per 1,000 Youth', fill = 'Income Quartile') +
  theme_minimal(base_size = 16) +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA),
    legend.background = element_rect(fill = "white", color = NA)
  ) +
  scale_fill_brewer(palette = "Set1")
ggsave('output_nta/nta_facility_per1000_box_income_optimized.png', p1_opt, width = 8, height = 6, dpi = 300)

# 分组均值柱状图
p2 <- ggplot(income_group_means, aes(x = factor(income_quartile), y = mean_facility_per_1000_youth, fill = factor(income_quartile))) +
  geom_bar(stat = 'identity') +
  labs(title = 'Mean Facilities per 1,000 Youth by Income Quartile', x = 'Income Quartile', y = 'Mean Facilities per 1,000 Youth', fill = 'Income Quartile') +
  theme_minimal(base_size = 15) +
  scale_fill_manual(values = c('#e41a1c','#377eb8','#4daf4a','#984ea3'))
ggsave('output_nta/nta_facility_per1000_mean_bar_income.png', p2, width = 8, height = 6)
cat('NTA income group equity analysis complete. Results saved to output_nta/.\n') 