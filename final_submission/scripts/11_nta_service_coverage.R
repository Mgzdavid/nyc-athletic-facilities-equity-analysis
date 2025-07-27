# Step 3: NTA Service Coverage Analysis (0.5-mile buffer)
library(sf)
library(dplyr)
library(readxl)
library(tmap)
library(janitor)

# 1. 读取修复后的NTA边界
nta <- st_read('data/nta_fixed.shp')
st_crs(nta) <- 4326  # 手动指定CRS为WGS84

# 2. 读取NTA人口数据
nta_pop <- read_excel('data/Dem_1822_NTA.xlsx') %>% clean_names()
nta_pop <- nta_pop %>% rename(nta2010 = geo_id)

# 3. 读取0.5英里缓冲区
facility_buffers <- st_read('data/facility_buffers_0_5mile.shp')
st_crs(facility_buffers) <- 4326

# 4. 合并所有缓冲区为一个服务区
service_area <- st_union(st_make_valid(facility_buffers))

# 5. 计算NTA与服务区的交集面积（单独循环，避免批量错位）
nta <- st_make_valid(nta)
nta$covered_area <- sapply(seq_len(nrow(nta)), function(i) {
  tryCatch({
    as.numeric(st_area(st_intersection(nta[i, ], service_area)))
  }, error = function(e) 0)
})
nta$total_area <- as.numeric(st_area(nta))
nta$covered_area <- as.numeric(nta$covered_area)
nta$total_area <- as.numeric(nta$total_area)
nta$covered_area[is.na(nta$covered_area)] <- 0
nta$total_area[is.na(nta$total_area)] <- 0
nta$coverage_ratio <- ifelse(nta$total_area > 0, nta$covered_area / nta$total_area, 0)

# 6. 合并人口数据
nta <- left_join(nta, nta_pop, by = 'nta2010')
nta$pop_u18_2e[is.na(nta$pop_u18_2e)] <- 0

# 7. 估算被服务青少年人口及比例
nta$covered_youth <- nta$coverage_ratio * nta$pop_u18_2e
nta$covered_youth_pct <- ifelse(nta$pop_u18_2e > 0, nta$covered_youth / nta$pop_u18_2e * 100, 0)

# 8. 输出结果表格
write.csv(st_drop_geometry(nta), 'output_nta/nta_service_coverage_summary.csv', row.names = FALSE)

# 9. 输出服务覆盖比例地图
map_cov <- tm_shape(nta) +
  tm_polygons('covered_youth_pct', palette = 'YlGnBu', style = 'quantile', n = 5,
              title = '% Youth within 0.5 Mile of Facility') +
  tm_layout(title = 'NTA Youth Service Coverage (0.5-Mile Buffer)', legend.outside = TRUE)
tmap_save(map_cov, 'output_nta/nta_service_coverage_map.png', width = 12, height = 10, dpi = 300)
cat('NTA service coverage analysis complete. Results saved to output_nta/.\n') 