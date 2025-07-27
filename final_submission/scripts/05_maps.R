# ============================================================================
# NYC Athletic Facilities Equity Analysis - Maps
# Step 5: Create spatial maps (dot map, choropleth)
# ============================================================================

cat("Starting map creation...\n")
library(sf)
library(tmap)
library(readr)
library(dplyr)
library(janitor)
library(tidyr)

# 设置tmap为绘图模式
 tmap_mode("plot")

# ---- 1. 读取数据 ----
census_tracts <- st_read("data/nyct2020.shp")
census_tracts <- st_transform(census_tracts, crs = 4326)
tracts_with_facilities <- read_csv("output/facility_equity_analysis.csv")
tracts_with_facilities$GEOID <- as.character(tracts_with_facilities$GEOID)
census_tracts$GEOID <- as.character(census_tracts$GEOID)

# ---- 2. 设施点 ----
cat("Creating facility dot map...\n")
facilities <- read_csv("data/NYC_Athletic_Selected.csv") %>% clean_names()
athletic_facilities <- facilities
athletic_sf <- st_as_sf(athletic_facilities, wkt = "multipolygon", crs = 4326)
athletic_sf_clean <- st_make_valid(athletic_sf)
facility_centroids <- st_centroid(athletic_sf_clean)

dot_map <- tm_shape(census_tracts) +
  tm_polygons(col = "lightgray", border.col = "white", lwd = 0.5) +
  tm_shape(facility_centroids) +
  tm_dots(col = "red", size = 0.5, alpha = 0.8, border.col = "black", border.lwd = 0.2) +
  tm_layout(title = "NYC Athletic Facilities Distribution",
            legend.outside = TRUE,
            legend.position = c("right", "bottom")) +
  tm_scale_bar(position = c("left", "top"), text.size = 0.8)
tmap_save(dot_map, "output_new/nyc_facility_dot_map.png", width = 12, height = 10, dpi = 300)

# ---- 3. 分级色块地图 ----
cat("Creating facilities per 1,000 youth choropleth map...\n")
tracts_choropleth <- census_tracts %>%
  left_join(tracts_with_facilities, by = "GEOID") %>%
  mutate(
    facility_n = replace_na(facility_n, 0),
    facilities_per_1000_youth = replace_na(facilities_per_1000_youth, 0)
  )

# 自定义分级
breaks <- c(0, 0.5, 1, 2, 5, 10, 20, Inf)
labels <- c("0.0 to 0.5", "0.5 to 1.0", "1.0 to 2.0", "2.0 to 5.0", "5.0 to 10.0", "10.0 to 20.0", ">20.0")

choropleth_map <- tm_shape(tracts_choropleth) +
  tm_polygons(
    col = "facilities_per_1000_youth",
    palette = "Blues",
    title = "Facilities per 1,000 Youth",
    breaks = breaks,
    labels = labels,
    border.col = "gray70",
    border.lwd = 0.3,
    alpha = 0.85
  ) +
  tm_shape(facility_centroids) +
  tm_dots(col = "red", size = 0.6, alpha = 0.85, border.col = "black", border.lwd = 0.3) +
  tm_layout(
    title = "NYC Athletic Facilities per 1,000 Youth by Census Tract",
    legend.outside = TRUE,
    legend.position = c("right", "bottom"),
    legend.text.size = 0.9,
    legend.title.size = 1.1,
    frame = FALSE
  ) +
  tm_scale_bar(position = c("left", "top"), text.size = 0.8) +
  tm_compass(position = c("right", "top"), text.size = 0.9)

tmap_save(choropleth_map, "output_new/nyc_facilities_choropleth.png", width = 14, height = 12, dpi = 300)

cat("Map creation complete.\n") 