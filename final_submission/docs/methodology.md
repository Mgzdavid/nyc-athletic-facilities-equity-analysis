# NYC Athletic Facilities Equity Analysis - 方法论

## 研究概述

本研究旨在分析纽约市体育设施的空间分布公平性，重点关注不同收入水平和种族/民族群体之间的设施可及性差异。研究采用空间分析技术，结合人口统计学数据，为城市规划政策提供数据支持。

## 数据来源

### 1. 体育设施数据
- **来源**: NYC Parks Department via NYC Open Data
- **数据**: NYC_Athletic_Selected.csv
- **包含信息**: 设施位置、类型、名称、坐标等
- **时间范围**: 2022年

### 2. 人口统计学数据
- **来源**: US Census Bureau American Community Survey (ACS)
- **数据**: 5-Year Estimates 2022
- **包含信息**: 总人口、18岁以下人口、收入、种族/民族等
- **地理单位**: Census Tract

### 3. 地理边界数据
- **来源**: NYC Department of City Planning
- **数据**: nyct2020.shp (Census Tract boundaries)
- **坐标系统**: NAD83 / New York Long Island (EPSG:2263)

## 数据处理流程

### 1. 数据清理和准备

#### 体育设施数据
```r
# 读取设施数据
facilities <- read_csv("data/NYC_Athletic_Selected.csv") %>% 
  clean_names()

# 转换为空间对象
athletic_sf <- st_as_sf(facilities, wkt = "multipolygon", crs = 4326)

# 修复几何问题
athletic_sf_clean <- st_make_valid(athletic_sf)

# 计算质心用于空间分析
facility_centroids <- st_centroid(athletic_sf_clean)
```

#### 人口普查数据
```r
# 下载人口数据
pop_data <- get_acs(geography = "tract", 
                    variables = c(total_pop = "B01003_001", 
                                under18 = "B09001_001"),
                    state = "NY", 
                    county = c("Bronx", "Kings", "New York", "Queens", "Richmond"),
                    geometry = TRUE, 
                    year = 2022)
```

### 2. 空间分析技术

#### 坐标系统统一
所有数据统一转换为WGS84 (EPSG:4326)坐标系统：
```r
# 转换坐标系统
census_tracts <- st_transform(census_tracts, crs = 4326)
facility_centroids <- st_transform(facility_centroids, crs = 4326)
```

#### 缓冲区分析
创建0.5英里步行距离缓冲区：
```r
# 创建0.5英里缓冲区
facility_buffers <- st_buffer(facility_centroids, dist = 804.672) # 0.5英里 = 804.672米

# 计算服务覆盖
coverage_analysis <- st_intersection(census_tracts, facility_buffers)
```

#### 密度计算
计算每1000人口的设施密度：
```r
# 计算设施密度
nta_density <- nta_data %>%
  mutate(facility_density_per1000 = (facility_count / total_pop) * 1000)
```

### 3. 公平性分析方法

#### 收入四分位数分析
```r
# 计算收入四分位数
nta_income_quartiles <- nta_data %>%
  mutate(income_quartile = ntile(median_income, 4)) %>%
  group_by(income_quartile) %>%
  summarise(
    mean_density = mean(facility_density_per1000, na.rm = TRUE),
    median_density = median(facility_density_per1000, na.rm = TRUE),
    n_communities = n()
  )
```

#### 种族/民族群体分析
```r
# 分析主要种族群体
ethnicity_analysis <- nta_data %>%
  group_by(dominant_ethnicity) %>%
  summarise(
    mean_density = mean(facility_density_per1000, na.rm = TRUE),
    median_density = median(facility_density_per1000, na.rm = TRUE),
    n_communities = n()
  )
```

## 可视化方法

### 1. 地图制作

#### 使用tmap包创建专题地图
```r
# 设置地图模式
tmap_mode("plot")

# 创建设施密度地图
facility_density_map <- tm_shape(nta_data) +
  tm_fill("facility_density_per1000", 
          title = "Facilities per 1000 Population",
          palette = "viridis") +
  tm_borders() +
  tm_layout(title = "NYC Athletic Facility Density by NTA")
```

#### 服务覆盖地图
```r
# 创建服务覆盖地图
coverage_map <- tm_shape(nta_data) +
  tm_fill("coverage_status", 
          title = "Service Coverage",
          palette = c("red", "green")) +
  tm_borders() +
  tm_layout(title = "0.5 Mile Service Coverage")
```

### 2. 统计图表

#### 箱线图分析
```r
# 收入四分位数箱线图
income_boxplot <- ggplot(nta_data, aes(x = factor(income_quartile), 
                                       y = facility_density_per1000)) +
  geom_boxplot() +
  labs(title = "Facility Density by Income Quartile",
       x = "Income Quartile",
       y = "Facilities per 1000 Population")
```

#### 条形图
```r
# 种族群体密度条形图
ethnicity_bar <- ggplot(ethnicity_summary, 
                        aes(x = dominant_ethnicity, y = mean_density)) +
  geom_bar(stat = "identity") +
  labs(title = "Average Facility Density by Ethnicity",
       x = "Dominant Ethnicity",
       y = "Mean Facilities per 1000 Population")
```

## 质量控制

### 1. 数据验证
- 检查缺失值和异常值
- 验证坐标系统一致性
- 确认地理边界完整性

### 2. 空间数据质量
```r
# 检查几何有效性
valid_geometries <- st_is_valid(athletic_sf)
invalid_count <- sum(!valid_geometries)

# 修复无效几何
if (invalid_count > 0) {
  athletic_sf_clean <- st_make_valid(athletic_sf)
}
```

### 3. 统计验证
- 检查异常值和离群点
- 验证分布假设
- 确认计算准确性

## 局限性

### 1. 数据局限性
- 设施数据可能不完整或过时
- 人口数据基于普查估计，存在误差
- 设施类型分类可能不够详细

### 2. 方法局限性
- 缓冲区分析假设直线距离，未考虑实际道路网络
- 未考虑设施容量和使用率
- 未分析时间维度的变化

### 3. 空间分析局限性
- 生态谬误风险（从区域数据推断个体行为）
- 空间自相关可能影响统计推断
- 边界效应可能影响分析结果

## 技术栈

### 主要软件和包
- **R**: 主要分析环境
- **sf**: 空间数据处理
- **tmap**: 地图制作
- **tidycensus**: 人口普查数据访问
- **tidyverse**: 数据处理和可视化
- **ggplot2**: 统计图表制作

### 数据格式
- **CSV**: 表格数据
- **Shapefile**: 地理边界数据
- **GeoJSON**: 空间数据交换格式
- **PNG**: 地图和图表输出

## 可重现性

### 代码组织
- 模块化脚本设计
- 清晰的变量命名
- 详细的注释说明
- 版本控制管理

### 数据管理
- 原始数据保持不变
- 中间结果保存为RDS格式
- 输出文件标准化命名
- 数据字典完整记录

---

**注意**: 本方法论文档应与代码脚本配合使用，确保分析过程的可重现性和透明度。 