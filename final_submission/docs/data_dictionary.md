# 数据字典 - NYC Athletic Facilities Equity Analysis

## 体育设施数据 (NYC_Athletic_Selected.csv)

### 基本信息字段
| 字段名 | 数据类型 | 描述 | 示例值 |
|--------|----------|------|--------|
| `objectid` | Integer | 唯一标识符 | 1, 2, 3... |
| `name` | String | 设施名称 | "Central Park Basketball Courts" |
| `facility_type` | String | 设施类型 | "Basketball Court", "Soccer Field" |
| `borough` | String | 所在行政区 | "Manhattan", "Brooklyn" |
| `address` | String | 设施地址 | "123 Main St, New York, NY" |

### 空间信息字段
| 字段名 | 数据类型 | 描述 | 坐标系统 |
|--------|----------|------|----------|
| `multipolygon` | Geometry | 设施几何形状 | WKT格式 |
| `longitude` | Float | 经度坐标 | WGS84 (EPSG:4326) |
| `latitude` | Float | 纬度坐标 | WGS84 (EPSG:4326) |

### 设施类型分类
- **Basketball Court**: 篮球场
- **Soccer Field**: 足球场
- **Baseball Field**: 棒球场
- **Tennis Court**: 网球场
- **Track**: 跑道
- **Swimming Pool**: 游泳池
- **Playground**: 游乐场

## 人口普查数据 (ACS 2022 5-Year Estimates)

### 人口统计字段
| 字段名 | Census变量 | 描述 | 数据类型 |
|--------|------------|------|----------|
| `total_pop` | B01003_001 | 总人口数 | Integer |
| `under18` | B09001_001 | 18岁以下人口数 | Integer |
| `median_income` | B19013_001 | 家庭收入中位数 | Integer |
| `poverty_rate` | B17001_002/B17001_001 | 贫困率 | Float |

### 种族/民族字段
| 字段名 | Census变量 | 描述 | 数据类型 |
|--------|------------|------|----------|
| `white` | B03002_003 | 白人人口 | Integer |
| `black` | B03002_004 | 非裔美国人人口 | Integer |
| `hispanic` | B03002_012 | 西班牙裔人口 | Integer |
| `asian` | B03002_006 | 亚裔人口 | Integer |
| `other` | B03002_005 + B03002_007 + B03002_008 + B03002_009 | 其他种族人口 | Integer |

### 地理标识字段
| 字段名 | 描述 | 数据类型 | 示例值 |
|--------|------|----------|--------|
| `GEOID` | 人口普查区唯一标识符 | String | "36061000100" |
| `NAME` | 人口普查区名称 | String | "Census Tract 1, Bronx County, New York" |
| `geometry` | 地理边界几何形状 | Geometry | Polygon |

## NTA (Neighborhood Tabulation Areas) 数据

### 社区信息字段
| 字段名 | 描述 | 数据类型 | 示例值 |
|--------|------|----------|--------|
| `ntacode` | NTA代码 | String | "BK01" |
| `ntaname` | NTA名称 | String | "Greenpoint" |
| `borough` | 所在行政区 | String | "Brooklyn" |

### 计算字段
| 字段名 | 描述 | 计算公式 | 数据类型 |
|--------|------|----------|----------|
| `facility_count` | 设施数量 | 空间连接计数 | Integer |
| `facility_density_per1000` | 每1000人口设施密度 | (facility_count / total_pop) * 1000 | Float |
| `income_quartile` | 收入四分位数 | ntile(median_income, 4) | Integer |
| `dominant_ethnicity` | 主要种族群体 | 最大比例种族 | String |
| `coverage_status` | 服务覆盖状态 | 0.5英里内是否有设施 | Boolean |

## 输出数据文件

### 设施密度摘要 (nta_facility_stats_en.csv)
| 字段名 | 描述 | 数据类型 |
|--------|------|----------|
| `ntacode` | NTA代码 | String |
| `ntaname` | NTA名称 | String |
| `borough` | 行政区 | String |
| `total_pop` | 总人口 | Integer |
| `facility_count` | 设施数量 | Integer |
| `facility_density_per1000` | 每1000人口设施密度 | Float |
| `median_income` | 收入中位数 | Integer |
| `income_quartile` | 收入四分位数 | Integer |
| `dominant_ethnicity` | 主要种族群体 | String |

### 收入分析摘要 (income_quartile_summary_final.csv)
| 字段名 | 描述 | 数据类型 |
|--------|------|----------|
| `income_quartile` | 收入四分位数 | Integer |
| `mean_density` | 平均设施密度 | Float |
| `median_density` | 中位数设施密度 | Float |
| `n_communities` | 社区数量 | Integer |
| `total_pop` | 总人口 | Integer |

### 种族分析摘要 (ethnicity_summary_final.csv)
| 字段名 | 描述 | 数据类型 |
|--------|------|----------|
| `dominant_ethnicity` | 主要种族群体 | String |
| `mean_density` | 平均设施密度 | Float |
| `median_density` | 中位数设施密度 | Float |
| `n_communities` | 社区数量 | Integer |
| `total_pop` | 总人口 | Integer |

## 空间数据文件

### 人口普查区边界 (nyct2020.shp)
| 字段名 | 描述 | 数据类型 |
|--------|------|----------|
| `GEOID` | 人口普查区标识符 | String |
| `NAME` | 人口普查区名称 | String |
| `COUNTYFP` | 县代码 | String |
| `TRACTCE` | 人口普查区代码 | String |
| `geometry` | 地理边界 | Polygon |

### 设施缓冲区 (facility_buffers_0_5mile.shp)
| 字段名 | 描述 | 数据类型 |
|--------|------|----------|
| `facility_id` | 设施标识符 | Integer |
| `facility_name` | 设施名称 | String |
| `facility_type` | 设施类型 | String |
| `geometry` | 0.5英里缓冲区 | Polygon |

## 数据质量说明

### 缺失值处理
- 人口数据缺失值用0填充
- 收入数据缺失值用中位数填充
- 几何数据缺失值从分析中排除

### 数据验证
- 坐标范围验证：确保在纽约市范围内
- 人口数据验证：确保非负值
- 几何有效性验证：确保多边形闭合

### 数据转换
- 坐标系统：统一转换为WGS84 (EPSG:4326)
- 字符编码：UTF-8
- 日期格式：YYYY-MM-DD

## 数据来源链接

### 原始数据
- **NYC Parks Athletic Facilities**: https://data.cityofnewyork.us/Recreation/NYC-Parks-Athletic-Facilities/6nca-7ph6
- **Census Tract Boundaries**: https://www1.nyc.gov/site/planning/data-maps/open-data.page
- **American Community Survey**: https://www.census.gov/programs-surveys/acs/

### 处理后的数据
- 所有处理后的数据文件保存在 `output/` 目录
- 中间结果保存在 `output/` 目录的RDS格式文件中
- 最终分析结果以CSV和PNG格式保存

---

**注意**: 本数据字典应与代码脚本配合使用，确保数据字段的正确理解和处理。 