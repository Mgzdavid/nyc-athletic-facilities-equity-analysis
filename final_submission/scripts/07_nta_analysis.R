# NTA-level Sports Facility Equity Analysis & Visualization
library(sf)
library(dplyr)
library(ggplot2)
library(tmap)
library(readr)
library(readxl)
library(tidyr)

# Read NTA boundaries
nta <- st_read('data/geo_export_c44553b9-43a2-4e68-ab41-e143c1638c26_proj.shp')
# Read statistics
nta_stats <- read_csv('output_new/nta_facility_stats.csv')
# Add income quartile (assuming Pop_1E is median household income)
nta_stats <- nta_stats %>% mutate(
  income_quartile = ntile(Pop_1E, 4)
)
# Join attributes to spatial object
nta <- left_join(nta, nta_stats, by = 'nta2010')
# Replace NA and Inf with 0 to avoid tmap/ggplot errors
nta <- nta %>% mutate(
  facility_n = replace_na(facility_n, 0),
  PopU18_2E = replace_na(PopU18_2E, 0),
  Pop_1E = replace_na(Pop_1E, 0),
  facilities_per_1000_youth = replace_na(facilities_per_1000_youth, 0),
  facilities_per_1000_youth = ifelse(is.infinite(facilities_per_1000_youth), 0, facilities_per_1000_youth)
)

# 1. Choropleth map: Facilities per 1,000 youth
map1 <- tm_shape(nta) +
  tm_polygons('facilities_per_1000_youth', palette = 'YlOrRd', style = 'quantile', n = 5,
              title = 'Facilities per 1,000 Youth') +
  tm_layout(title = 'NYC NTA Sports Facility Equity Map', legend.outside = TRUE)
tmap_save(map1, 'output_nta/nta_facility_equity_map_en.png', width = 12, height = 10, dpi = 300)

# 2. Histogram: Distribution of facilities per 1,000 youth
p1 <- ggplot(nta_stats, aes(x = facilities_per_1000_youth)) +
  geom_histogram(bins = 30, fill = '#3182bd', color = 'white') +
  labs(title = 'Distribution of Facilities per 1,000 Youth', x = 'Facilities per 1,000 Youth', y = 'Number of NTAs') +
  theme_minimal()
ggsave('output_nta/nta_facility_per1000_hist_en.png', p1, width = 8, height = 6, device = 'png')

# 3. Bar chart: Top 20 NTAs by facility count (use neighborhood name)
nta_names <- nta %>% st_drop_geometry() %>% select(nta2010, ntaname201)
nta_top20 <- nta_stats %>% left_join(nta_names, by = 'nta2010') %>% arrange(desc(facility_n)) %>% slice(1:20)
p2 <- ggplot(nta_top20, aes(x = reorder(ntaname201, facility_n), y = facility_n)) +
  geom_bar(stat = 'identity', fill = '#1f77b4') +
  coord_flip() +
  labs(title = 'Top 20 Neighborhoods by Sports Facility Count', x = 'Neighborhood', y = 'Facility Count') +
  theme_minimal()
ggsave('output_nta/nta_top20_facility_bar_en.png', p2, width = 12, height = 8, device = 'png')

# 4. Boxplot: Facilities per 1,000 youth by income quartile (improved color)
p3 <- ggplot(nta_stats, aes(x = factor(income_quartile), y = facilities_per_1000_youth, fill = factor(income_quartile))) +
  geom_boxplot(outlier.shape = 21, outlier.fill = 'black', outlier.color = 'black', alpha = 0.8) +
  labs(title = 'Facilities per 1,000 Youth by Income Quartile', x = 'Income Quartile (1=Lowest, 4=Highest)', y = 'Facilities per 1,000 Youth', fill = 'Income Quartile') +
  theme_minimal(base_size = 15) +
  scale_fill_manual(values = c('#e41a1c','#377eb8','#4daf4a','#984ea3'))
ggsave('output_nta/nta_facility_per1000_box_income_en.png', p3, width = 8, height = 6, device = 'png')

# 5. Grouped histogram: Facilities per 1,000 youth by income quartile (improved color)
p4 <- ggplot(nta_stats, aes(x = facilities_per_1000_youth, fill = factor(income_quartile))) +
  geom_histogram(position = 'identity', alpha = 0.5, bins = 30, color = 'black') +
  labs(title = 'Distribution of Facilities per 1,000 Youth by Income Quartile', x = 'Facilities per 1,000 Youth', y = 'Number of NTAs', fill = 'Income Quartile') +
  theme_minimal(base_size = 15) +
  scale_fill_manual(values = c('#e41a1c','#377eb8','#4daf4a','#984ea3'))
ggsave('output_nta/nta_facility_per1000_hist_by_income_en.png', p4, width = 8, height = 6, device = 'png')

# 6. Output group means
income_group_means <- nta_stats %>% group_by(income_quartile) %>% summarise(mean_facilities_per_1000_youth = mean(facilities_per_1000_youth, na.rm = TRUE), n = n())
write_csv(income_group_means, 'output_nta/nta_facility_per1000_income_group_means_en.csv')

# 7. Coverage analysis: percentage of NTAs with at least 1 facility, by borough (fixed)
nta_names_full <- nta %>% st_drop_geometry() %>% select(nta2010, ntaname201)
nta_names_full <- nta_names_full %>% mutate(borough = substr(nta2010, 1, 2))
borough_map <- c('BX' = 'Bronx', 'BK' = 'Brooklyn', 'MN' = 'Manhattan', 'QN' = 'Queens', 'SI' = 'Staten Island')
nta_names_full$borough <- borough_map[nta_names_full$borough]
# Merge all NTA with stats, fill missing facility_n as 0
nta_stats_full <- left_join(nta_names_full, nta_stats, by = 'nta2010') %>% mutate(facility_n = replace_na(facility_n, 0))
coverage <- nta_stats_full %>% group_by(borough) %>% summarise(
  n_nta = n(),
  n_with_facility = sum(facility_n > 0),
  pct_with_facility = 100 * n_with_facility / n_nta
)
p5 <- ggplot(coverage, aes(x = borough, y = pct_with_facility, fill = borough)) +
  geom_bar(stat = 'identity', width = 0.7) +
  labs(title = 'Coverage Analysis: % of NTAs with Athletic Facilities by Borough',
       x = 'Borough', y = 'Percent of NTAs with Facilities (%)') +
  theme_minimal(base_size = 15) +
  scale_fill_brewer(palette = 'Set2')
ggsave('output_nta/nta_coverage_by_borough_en.png', p5, width = 8, height = 6, device = 'png')

# 8. Output analysis results csv (still in English)
write_csv(nta_stats, 'output_nta/nta_facility_stats_en.csv') 