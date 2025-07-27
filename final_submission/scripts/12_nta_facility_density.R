# Step 4: NTA Facility Density Analysis
library(sf)
library(dplyr)
library(readxl)
library(tmap)
library(janitor)

# 读取NTA边界
nta <- st_read('data/nta_fixed.shp')
nta <- st_transform(nta, 4326)

# 读取设施点（多面体转为质心点）
athletic_sf <- st_read('data/athletic_facilities_fixed_crs.shp')
athletic_sf <- st_transform(athletic_sf, 4326)
facility_points <- st_centroid(athletic_sf)

# 读取NTA人口数据
nta_pop <- read_excel('data/Dem_1822_NTA.xlsx') %>% clean_names()
nta_pop <- nta_pop %>% rename(nta2010 = geo_id)

# 统计每个NTA内的设施数量（点落在哪个NTA内）
facility_with_nta <- st_join(facility_points, nta, join = st_within)
nta_facility_count <- facility_with_nta %>%
  st_drop_geometry() %>%
  group_by(nta2010) %>%
  summarise(facility_n = n())

# 合并人口和面积
nta <- left_join(nta, nta_facility_count, by = 'nta2010')
nta <- left_join(nta, nta_pop, by = 'nta2010')
nta$facility_n[is.na(nta$facility_n)] <- 0
nta$area_km2 <- as.numeric(st_area(nta)) / 1e6
nta$facility_density_km2 <- nta$facility_n / nta$area_km2
nta$facility_per_1000_youth <- ifelse(nta$pop_u18_2e > 0, nta$facility_n / nta$pop_u18_2e * 1000, 0)

# 输出地图
map_density <- tm_shape(nta) +
  tm_polygons('facility_density_km2', palette = 'YlOrRd', style = 'quantile', n = 5,
              title = 'Facilities per km²') +
  tm_layout(title = 'NTA Facility Density (per km²)', legend.outside = TRUE)
tmap_save(map_density, 'output_nta/nta_facility_density_map.png', width = 12, height = 10, dpi = 300)

# 输出统计表
write.csv(st_drop_geometry(nta), 'output_nta/nta_facility_density_summary.csv', row.names = FALSE)
cat('NTA facility density analysis complete. Results saved to output_nta/.\n') 