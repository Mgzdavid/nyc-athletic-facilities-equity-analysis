# Step 7: NTA Ethnicity Group Equity Analysis
library(dplyr)
library(readr)
library(ggplot2)
library(readxl)
library(janitor)

# 读取NTA密度统计表
nta <- read.csv('output_nta/nta_facility_density_summary.csv')

# 读取NTA人口数据
nta_pop <- read_excel('data/Dem_1822_NTA.xlsx') %>% clean_names()
nta_pop <- nta_pop %>% rename(nta2010 = geo_id)

# 计算非西班牙裔白人比例
nta_pop <- nta_pop %>% mutate(white_pct = wt_nhe / pop_2e * 100)

# 合并族裔比例
nta <- left_join(nta, nta_pop, by = 'nta2010')

# 按非西班牙裔白人比例分组
nta <- nta %>%
  mutate(
    majority_minority = ifelse(white_pct < 50, "Majority-Minority", "Majority-White")
  )

# 统计每组均值
eth_group_means <- nta %>%
  group_by(majority_minority) %>%
  summarise(
    mean_facility_density_km2 = mean(facility_density_km2, na.rm = TRUE),
    mean_facility_per_1000_youth = mean(facility_per_1000_youth, na.rm = TRUE),
    n = n()
  )
write.csv(eth_group_means, 'output_nta/nta_facility_density_eth_group_means.csv', row.names = FALSE)

# 箱线图：每千青少年设施数按族裔分组
p1 <- ggplot(nta, aes(x = majority_minority, y = facility_per_1000_youth, fill = majority_minority)) +
  geom_boxplot(outlier.shape = 21, outlier.fill = 'black', outlier.color = 'black', alpha = 0.8, color = "black", lwd = 1) +
  labs(title = 'Facilities per 1,000 Youth by Ethnic Group', x = 'Group', y = 'Facilities per 1,000 Youth', fill = 'Group') +
  theme_minimal(base_size = 16) +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA),
    legend.background = element_rect(fill = "white", color = NA)
  ) +
  scale_fill_brewer(palette = "Set1")
ggsave('output_nta/nta_facility_per1000_box_eth.png', p1, width = 8, height = 6, dpi = 300)
cat('NTA ethnicity group equity analysis complete. Results saved to output_nta/.\n') 