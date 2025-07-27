# 技术说明 - NYC Athletic Facilities Equity Analysis

## 代码架构

### 脚本组织结构

项目采用模块化设计，将分析过程分解为独立的脚本文件：

```
scripts/
├── 00_setup.R                    # 环境设置和依赖管理
├── 01_data_preparation.R         # 数据加载和预处理
├── 02_spatial_analysis.R         # 空间数据处理
├── 03_equity_analysis.R          # 公平性分析
├── 04_visualizations.R           # 图表制作
├── 05_maps.R                     # 地图制作
├── 07_nta_analysis.R             # NTA社区分析
├── 08_nta_service_coverage.R     # 服务覆盖分析
├── 11_nta_service_coverage.R     # 改进的服务覆盖分析
├── 12_nta_facility_density.R     # 设施密度分析
├── 13_nta_facility_type_density.R # 设施类型密度分析
├── 14_nta_income_equity_analysis.R # 收入公平性分析
└── 15_nta_ethnicity_equity_analysis.R # 种族公平性分析
```

### 数据流设计

```
原始数据 → 数据清理 → 空间处理 → 统计分析 → 可视化 → 输出
```

## 关键技术实现

### 1. 空间数据处理

#### 坐标系统管理
```r
# 统一坐标系统为WGS84
census_tracts <- st_transform(census_tracts, crs = 4326)
facility_centroids <- st_transform(facility_centroids, crs = 4326)

# 验证坐标系统一致性
st_crs(census_tracts) == st_crs(facility_centroids)
```

#### 几何有效性检查
```r
# 检查并修复无效几何
invalid_geometries <- !st_is_valid(athletic_sf)
if (sum(invalid_geometries) > 0) {
  athletic_sf_clean <- st_make_valid(athletic_sf)
  cat("Fixed", sum(invalid_geometries), "invalid geometries\n")
}
```

#### 空间连接优化
```r
# 使用空间索引提高性能
facility_centroids_indexed <- st_sf(
  geometry = st_geometry(facility_centroids),
  data = st_drop_geometry(facility_centroids)
)

# 执行空间连接
spatial_join <- st_join(
  census_tracts, 
  facility_centroids_indexed,
  join = st_intersects
)
```

### 2. 缓冲区分析实现

#### 精确距离计算
```r
# 0.5英里 = 804.672米 (精确转换)
buffer_distance <- 804.672

# 创建缓冲区
facility_buffers <- st_buffer(
  facility_centroids, 
  dist = buffer_distance,
  nQuadSegs = 30  # 平滑度参数
)
```

#### 服务覆盖计算
```r
# 计算每个社区的服务覆盖
coverage_analysis <- census_tracts %>%
  mutate(
    facility_count = lengths(st_intersects(geometry, facility_buffers)),
    coverage_status = facility_count > 0,
    coverage_area = st_area(st_intersection(geometry, st_union(facility_buffers)))
  )
```

### 3. 密度计算算法

#### 标准化密度计算
```r
# 每1000人口设施密度
nta_density <- nta_data %>%
  mutate(
    facility_density_per1000 = (facility_count / total_pop) * 1000,
    facility_density_per_sqkm = facility_count / (st_area(geometry) / 1000000)
  )
```

#### 加权密度计算
```r
# 考虑人口权重的密度
weighted_density <- nta_data %>%
  group_by(borough) %>%
  mutate(
    pop_weight = total_pop / sum(total_pop),
    weighted_density = facility_density_per1000 * pop_weight
  ) %>%
  summarise(
    borough_weighted_density = sum(weighted_density, na.rm = TRUE)
  )
```

### 4. 公平性分析实现

#### 收入四分位数分析
```r
# 动态四分位数计算
income_quartiles <- nta_data %>%
  filter(!is.na(median_income)) %>%
  mutate(
    income_quartile = ntile(median_income, 4),
    quartile_label = case_when(
      income_quartile == 1 ~ "Lowest Income",
      income_quartile == 2 ~ "Lower Middle",
      income_quartile == 3 ~ "Upper Middle", 
      income_quartile == 4 ~ "Highest Income"
    )
  )
```

#### 种族群体分析
```r
# 主要种族群体识别
ethnicity_analysis <- nta_data %>%
  mutate(
    total_ethnicity = white + black + hispanic + asian + other,
    white_pct = white / total_ethnicity * 100,
    black_pct = black / total_ethnicity * 100,
    hispanic_pct = hispanic / total_ethnicity * 100,
    asian_pct = asian / total_ethnicity * 100,
    dominant_ethnicity = case_when(
      white_pct >= 50 ~ "White",
      black_pct >= 50 ~ "Black",
      hispanic_pct >= 50 ~ "Hispanic",
      asian_pct >= 50 ~ "Asian",
      TRUE ~ "Mixed"
    )
  )
```

### 5. 可视化技术

#### tmap地图制作
```r
# 专业地图样式设置
facility_density_map <- tm_shape(nta_data) +
  tm_fill(
    "facility_density_per1000",
    title = "Facilities per 1000 Population",
    palette = "viridis",
    breaks = c(0, 0.5, 1, 2, 5, 10),
    labels = c("0-0.5", "0.5-1", "1-2", "2-5", "5+")
  ) +
  tm_borders(col = "white", lwd = 0.5) +
  tm_layout(
    title = "NYC Athletic Facility Density by NTA",
    title.position = c("center", "top"),
    legend.position = c("right", "center"),
    frame = FALSE
  ) +
  tm_compass(type = "arrow", position = c("right", "top")) +
  tm_scale_bar(position = c("left", "bottom"))
```

#### ggplot2统计图表
```r
# 专业图表样式
income_boxplot <- ggplot(nta_data, aes(x = factor(income_quartile), 
                                       y = facility_density_per1000,
                                       fill = factor(income_quartile))) +
  geom_boxplot(alpha = 0.7, outlier.shape = 21) +
  geom_jitter(width = 0.2, alpha = 0.5, size = 1) +
  scale_fill_viridis_d(name = "Income Quartile") +
  labs(
    title = "Athletic Facility Density by Income Quartile",
    subtitle = "NYC Neighborhood Tabulation Areas",
    x = "Income Quartile",
    y = "Facilities per 1000 Population",
    caption = "Source: NYC Parks Department & US Census ACS 2022"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12, color = "gray50"),
    axis.title = element_text(size = 12),
    legend.position = "none"
  )
```

## 性能优化

### 1. 内存管理

#### 大型数据集处理
```r
# 分块处理大型数据集
chunk_size <- 1000
total_rows <- nrow(large_dataset)
chunks <- seq(1, total_rows, by = chunk_size)

results <- lapply(chunks, function(start) {
  end <- min(start + chunk_size - 1, total_rows)
  chunk_data <- large_dataset[start:end, ]
  # 处理逻辑
  return(processed_chunk)
})
```

#### 空间索引优化
```r
# 创建空间索引
st_geometry(facility_centroids) <- st_geometry(facility_centroids)
st_crs(facility_centroids) <- 4326

# 使用空间索引进行连接
spatial_join <- st_join(
  census_tracts,
  facility_centroids,
  join = st_intersects,
  left = TRUE
)
```

### 2. 计算优化

#### 并行处理
```r
# 使用并行计算
library(parallel)
library(doParallel)

# 设置并行核心数
num_cores <- detectCores() - 1
cl <- makeCluster(num_cores)
registerDoParallel(cl)

# 并行处理
results <- foreach(i = 1:n_chunks, .packages = c("sf", "dplyr")) %dopar% {
  # 处理逻辑
}

stopCluster(cl)
```

#### 向量化操作
```r
# 避免循环，使用向量化操作
nta_data <- nta_data %>%
  mutate(
    facility_density_per1000 = (facility_count / total_pop) * 1000,
    income_quartile = ntile(median_income, 4),
    coverage_status = facility_count > 0
  )
```

## 错误处理

### 1. 数据验证

#### 输入数据检查
```r
# 验证数据完整性
validate_data <- function(data, required_columns) {
  missing_cols <- setdiff(required_columns, names(data))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # 检查数据类型
  if (!is.numeric(data$total_pop)) {
    stop("total_pop must be numeric")
  }
  
  # 检查数值范围
  if (any(data$total_pop < 0, na.rm = TRUE)) {
    stop("total_pop contains negative values")
  }
}
```

#### 空间数据验证
```r
# 验证空间数据
validate_spatial_data <- function(sf_data) {
  # 检查坐标系统
  if (is.na(st_crs(sf_data))) {
    stop("Spatial data missing coordinate reference system")
  }
  
  # 检查几何有效性
  invalid_geoms <- !st_is_valid(sf_data)
  if (any(invalid_geoms)) {
    warning(sum(invalid_geoms), " invalid geometries found")
  }
  
  # 检查空几何
  empty_geoms <- st_is_empty(sf_data)
  if (any(empty_geoms)) {
    warning(sum(empty_geoms), " empty geometries found")
  }
}
```

### 2. 异常处理

#### 优雅的错误处理
```r
# 安全的函数执行
safe_execute <- function(expr, error_message = "An error occurred") {
  tryCatch({
    eval(expr)
  }, error = function(e) {
    cat("Error:", error_message, "\n")
    cat("Details:", e$message, "\n")
    return(NULL)
  }, warning = function(w) {
    cat("Warning:", w$message, "\n")
  })
}
```

## 代码质量保证

### 1. 代码规范

#### 命名约定
- 变量名使用小写字母和下划线
- 函数名使用动词_名词格式
- 常量使用大写字母

#### 注释规范
```r
# ============================================================================
# 函数名称: calculate_facility_density
# 功能描述: 计算每1000人口的设施密度
# 输入参数: 
#   - nta_data: NTA社区数据框
#   - facility_count_col: 设施数量列名
#   - population_col: 人口数量列名
# 返回值: 包含密度计算的数据框
# ============================================================================
```

### 2. 测试验证

#### 单元测试
```r
# 测试密度计算函数
test_density_calculation <- function() {
  test_data <- data.frame(
    facility_count = c(5, 10, 0),
    total_pop = c(1000, 2000, 500)
  )
  
  result <- calculate_facility_density(test_data)
  
  # 验证结果
  expected_density <- c(5, 5, 0)
  stopifnot(all.equal(result$density_per1000, expected_density))
  
  cat("Density calculation test passed\n")
}
```

#### 结果验证
```r
# 验证分析结果
validate_results <- function(results) {
  # 检查数值范围
  if (any(results$facility_density_per1000 < 0, na.rm = TRUE)) {
    stop("Negative density values found")
  }
  
  # 检查缺失值
  missing_count <- sum(is.na(results$facility_density_per1000))
  if (missing_count > 0) {
    warning(missing_count, " missing density values")
  }
  
  # 检查异常值
  outliers <- boxplot.stats(results$facility_density_per1000)$out
  if (length(outliers) > 0) {
    warning(length(outliers), " outlier values detected")
  }
}
```

## 部署和分发

### 1. 环境配置

#### 依赖管理
```r
# 创建依赖列表
dependencies <- c(
  "tidyverse",
  "sf", 
  "tmap",
  "tidycensus",
  "janitor",
  "purrr"
)

# 安装依赖
install_dependencies <- function() {
  for (pkg in dependencies) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      install.packages(pkg, repos = "https://cloud.r-project.org")
    }
  }
}
```

#### 配置文件
```r
# 配置文件示例
config <- list(
  census_api_key = Sys.getenv("CENSUS_API_KEY"),
  data_path = "data/",
  output_path = "output/",
  buffer_distance = 804.672,  # 0.5英里
  coordinate_system = 4326
)
```

### 2. 文档生成

#### 自动文档生成
```r
# 使用roxygen2生成文档
#' Calculate facility density per 1000 population
#' 
#' @param nta_data Data frame containing NTA data
#' @param facility_count_col Name of facility count column
#' @param population_col Name of population column
#' @return Data frame with density calculations
#' @export
calculate_facility_density <- function(nta_data, facility_count_col, population_col) {
  # 函数实现
}
```

---

**注意**: 本技术说明应与代码脚本配合使用，确保技术实现的正确理解和维护。 