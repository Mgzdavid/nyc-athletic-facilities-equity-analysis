# NTA Service Coverage Analysis: 0.5-Mile Buffer
# Calculates, for each NTA, the number and proportion of youth (PopU18_2E) within 0.5 miles of at least one athletic facility

library(sf)
library(dplyr)
library(readr)
library(readxl)
library(tmap)
library(janitor)

# 1. Read NTA boundaries
nta <- st_read('data/geo_export_c44553b9-43a2-4e68-ab41-e143c1638c26_proj.shp')
nta <- st_transform(nta, 4326)

# 2. Read NTA population data
nta_pop <- read_excel('data/Dem_1822_NTA.xlsx') %>% clean_names()
# 保证NTA编码字段一致
nta_pop <- nta_pop %>% rename(nta2010 = geo_id)

# 3. Read facility data and get valid geometry
athletic_sf <- readRDS('data/athletic_sf_final_centroidok.rds')
athletic_sf <- st_make_valid(athletic_sf)
athletic_sf <- athletic_sf[!st_is_empty(athletic_sf), ]
athletic_sf <- athletic_sf[st_is_valid(athletic_sf), ]
facility_centroids <- st_point_on_surface(athletic_sf)

# 4. Create 0.5-mile (804.67m) buffer around each facility
facility_centroids_proj <- st_transform(facility_centroids, 32618)
facility_buffers <- st_buffer(facility_centroids_proj, dist = 804.67)
facility_buffers_geo <- st_transform(facility_buffers, 4326)

# 5. Union all buffers to get total service area
service_area <- st_union(facility_buffers_geo)

# 6. Calculate intersection between NTA and service area
nta$covered_area <- as.numeric(st_area(st_intersection(nta, service_area)))
nta$total_area <- as.numeric(st_area(nta))
nta$coverage_ratio <- nta$covered_area / nta$total_area
nta$coverage_ratio[is.na(nta$coverage_ratio)] <- 0

# 7. Merge population data
nta <- left_join(nta, nta_pop, by = 'nta2010')
nta$popu18_2e[is.na(nta$popu18_2e)] <- 0

# 8. Estimate covered youth: assume uniform distribution, covered_youth = coverage_ratio * popu18_2e
nta$covered_youth <- nta$coverage_ratio * nta$popu18_2e
nta$covered_youth_pct <- ifelse(nta$popu18_2e > 0, nta$covered_youth / nta$popu18_2e * 100, 0)

# 9. Output results
write_csv(st_drop_geometry(nta), 'output_nta/nta_service_coverage_summary.csv')

# 10. Map: percent of youth covered by facilities (0.5 mile)
map_cov <- tm_shape(nta) +
  tm_polygons('covered_youth_pct', palette = 'YlGnBu', style = 'quantile', n = 5,
              title = '% Youth within 0.5 Mile of Facility') +
  tm_layout(title = 'NTA Youth Service Coverage (0.5-Mile Buffer)', legend.outside = TRUE)
tmap_save(map_cov, 'output_nta/nta_service_coverage_map.png', width = 12, height = 10, dpi = 300) 