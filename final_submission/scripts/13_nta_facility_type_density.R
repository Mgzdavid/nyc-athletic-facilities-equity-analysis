# Step 6: NTA Facility Type Density Analysis
library(sf)
library(dplyr)
library(tidyr)
library(tmap)
library(readxl)
library(janitor)

# 读取NTA边界
nta <- st_read('data/nta_fixed.shp')
nta <- st_transform(nta, 4326)

# 读取设施点
athletic_sf <- st_read('data/athletic_facilities_fixed_crs.shp')
athletic_sf <- st_transform(athletic_sf, 4326)

# 读取NTA人口数据
nta_pop <- read_excel('data/Dem_1822_NTA.xlsx') %>% clean_names()
nta_pop <- nta_pop %>% rename(nta2010 = geo_id)

# 筛选篮球设施
basketball_facilities <- athletic_sf %>% filter(basketball == TRUE)

# 筛选足球设施（包括成人足球、青少年足球、旗标足球）
football_facilities <- athletic_sf %>% filter(adult_foot == TRUE | youth_foot == TRUE | flagfootba == TRUE)

# 筛选棒球设施
baseball_facilities <- athletic_sf %>% filter(adult_base == TRUE)

# 计算所有类型设施的最大密度值，用于统一图例范围
calculate_max_density <- function(facilities_sf) {
  facility_points <- st_centroid(facilities_sf)
  facility_nta <- st_join(facility_points, nta, join = st_within) %>%
    as.data.frame() %>%
    group_by(nta2010) %>%
    summarise(facility_count = n())
  
  nta_with_facilities <- nta %>%
    as.data.frame() %>%
    left_join(facility_nta, by = "nta2010") %>%
    mutate(facility_count = replace_na(facility_count, 0))
  
  nta_with_facilities <- nta_with_facilities %>%
    mutate(
      area_km2 = as.numeric(st_area(nta)) / 1000000,
      facility_density_km2 = facility_count / area_km2
    )
  
  return(max(nta_with_facilities$facility_density_km2, na.rm = TRUE))
}

# 计算所有类型的最大密度
basketball_max <- calculate_max_density(basketball_facilities)
football_max <- calculate_max_density(football_facilities)
baseball_max <- calculate_max_density(baseball_facilities)

# 使用更合适的密度范围，让颜色更分明
# 使用75%分位数作为上限，避免极值影响颜色分布
calculate_optimal_range <- function(facilities_sf) {
  facility_points <- st_centroid(facilities_sf)
  facility_nta <- st_join(facility_points, nta, join = st_within) %>%
    as.data.frame() %>%
    group_by(nta2010) %>%
    summarise(facility_count = n())
  
  nta_with_facilities <- nta %>%
    as.data.frame() %>%
    left_join(facility_nta, by = "nta2010") %>%
    mutate(facility_count = replace_na(facility_count, 0))
  
  nta_with_facilities <- nta_with_facilities %>%
    mutate(
      area_km2 = as.numeric(st_area(nta)) / 1000000,
      facility_density_km2 = facility_count / area_km2
    )
  
  # 使用75%分位数作为上限，让颜色分布更均匀
  return(quantile(nta_with_facilities$facility_density_km2, 0.75, na.rm = TRUE))
}

basketball_75 <- calculate_optimal_range(basketball_facilities)
football_75 <- calculate_optimal_range(football_facilities)
baseball_75 <- calculate_optimal_range(baseball_facilities)

# 使用75%分位数中的最大值作为统一范围
optimal_max_density <- max(basketball_75, football_75, baseball_75)
cat("优化密度范围：0 到", round(optimal_max_density, 2), "设施/平方公里\n")
cat("原始最大密度：篮球", round(basketball_max, 2), "足球", round(football_max, 2), "棒球", round(baseball_max, 2), "\n")

# 统计函数
type_density_analysis <- function(facilities_sf, type_name) {
  # 转换为点数据
  facility_points <- st_centroid(facilities_sf)
  
  # 空间连接
  facility_nta <- st_join(facility_points, nta, join = st_within) %>%
    as.data.frame() %>%
    group_by(nta2010) %>%
    summarise(facility_count = n())
  
  # 合并到NTA数据
  nta_with_facilities <- nta %>%
    as.data.frame() %>%
    left_join(facility_nta, by = "nta2010") %>%
    mutate(facility_count = replace_na(facility_count, 0))
  
  # 计算密度（每平方公里）
  nta_with_facilities <- nta_with_facilities %>%
    mutate(
      area_km2 = as.numeric(st_area(nta)) / 1000000,
      facility_density_km2 = facility_count / area_km2
    )
  
  # 保存统计结果
  write.csv(nta_with_facilities, paste0('output_nta/nta_', type_name, '_density_summary.csv'), row.names = FALSE)
  
  # 创建地图
  nta_map <- nta %>%
    left_join(nta_with_facilities %>% select(nta2010, facility_density_km2), by = "nta2010")
  
  # 使用统一的密度范围
  breaks <- seq(0, optimal_max_density, length.out = 6)
  
  tm <- tm_shape(nta_map) +
    tm_polygons(
      col = "facility_density_km2",
      title = paste0(ucfirst(type_name), " per km²"),
      style = "fixed",
      breaks = breaks,
      palette = "YlOrRd",
      textNA = "Missing"
    ) +
    tm_layout(title = paste0("NTA ", ucfirst(type_name), " Facility Density (per km²)"))
  
  tmap_save(tm, paste0('output_nta/nta_', type_name, '_density_map.png'), width = 12, height = 10, dpi = 300)
}
ucfirst <- function(x) paste0(toupper(substring(x, 1, 1)), substring(x, 2))
type_density_analysis(basketball_facilities, "basketball")
type_density_analysis(football_facilities, "soccer")
type_density_analysis(baseball_facilities, "baseball")
cat('NTA facility type density analysis complete. Results saved to output_nta/.\n') 