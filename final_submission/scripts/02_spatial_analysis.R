library(dplyr)
library(sf)
library(readr)
library(tidyr)
# ============================================================================
# NYC Athletic Facilities Equity Analysis - Spatial Analysis
# Step 2: Perform spatial joins and calculate facility density metrics
# ============================================================================

cat("Starting spatial analysis...\n")

# ---- 1. Load Prepared Data ----
cat("Loading prepared data...\n")

# Load population data
pop_wide <- read_csv("output/population_data.csv")
pop_wide$GEOID <- as.character(pop_wide$GEOID)

# 读取最新设施数据
athletic_facilities <- read_csv("data/NYC_Athletic_Selected.csv")
athletic_sf <- st_as_sf(athletic_facilities, wkt = "multipolygon", crs = 4326)
facility_centroids <- st_centroid(athletic_sf)

# Load census tract boundaries
census_tracts <- st_read("data/nyct2020.shp")
census_tracts <- st_transform(census_tracts, crs = 4326)
census_tracts$GEOID <- as.character(census_tracts$GEOID)

# Convert facility centroids back to spatial object
facility_centroids_sf <- st_as_sf(facility_centroids, 
                                 wkt = "multipolygon", 
                                 crs = 4326)

cat("Loaded data:\n")
cat("- Population data:", nrow(pop_wide), "tracts\n")
cat("- Facility centroids:", nrow(facility_centroids_sf), "facilities\n")
cat("- Census tract boundaries:", nrow(census_tracts), "tracts\n")

# ---- 2. Perform Spatial Join ----
cat("Performing spatial join...\n")

# 后续分析用facility_centroids和census_tracts做空间join
facilities_joined <- st_join(facility_centroids_sf, census_tracts, left = FALSE)

cat("Spatial join completed. Facilities assigned to tracts.\n")

# Count facilities per tract
facility_count <- facilities_joined %>% 
  st_drop_geometry() %>% 
  group_by(GEOID) %>% 
  summarise(facility_n = n(), .groups = 'drop')

cat("Facilities successfully assigned to", nrow(facility_count), "census tracts\n")

# ---- 3. Merge Population and Facility Data ----
cat("Merging population and facility data...\n")

tracts_with_facilities <- pop_wide %>% 
  left_join(facility_count, by = "GEOID") %>% 
  mutate(
    facility_n = replace_na(facility_n, 0),
    facilities_per_1000_youth = ifelse(under18 > 0, 
                                      facility_n / under18 * 1000, 0)
  )

cat("Data merged successfully. Total tracts:", nrow(tracts_with_facilities), "\n")

# ---- 4. Calculate Summary Statistics ----
cat("Calculating summary statistics...\n")

# Overall statistics
total_tracts <- nrow(tracts_with_facilities)
tracts_with_facilities_count <- sum(tracts_with_facilities$facility_n > 0)
total_facilities <- sum(tracts_with_facilities$facility_n)
avg_facilities_per_1000_youth <- mean(tracts_with_facilities$facilities_per_1000_youth, na.rm = TRUE)
median_facilities_per_1000_youth <- median(tracts_with_facilities$facilities_per_1000_youth, na.rm = TRUE)

# Print summary
cat("Summary Statistics:\n")
cat("Total census tracts analyzed:", total_tracts, "\n")
cat("Census tracts with facilities:", tracts_with_facilities_count, "\n")
cat("Total athletic facilities:", total_facilities, "\n")
cat("Average facilities per 1,000 youth:", round(avg_facilities_per_1000_youth, 3), "\n")
cat("Median facilities per 1,000 youth:", round(median_facilities_per_1000_youth, 3), "\n")
cat("Percentage of tracts with facilities:", round(tracts_with_facilities_count/total_tracts*100, 1), "%\n")

# ---- 5. Borough-Level Analysis ----
cat("Performing borough-level analysis...\n")

# Get borough information from census tracts
borough_info <- census_tracts %>% 
  st_drop_geometry() %>% 
  select(GEOID, BoroName)

# Merge with facility data
tracts_with_boroughs <- tracts_with_facilities %>% 
  left_join(borough_info, by = "GEOID")

# Calculate borough summaries
borough_summary <- tracts_with_boroughs %>%
  group_by(BoroName) %>%
  summarise(
    total_tracts = n(),
    tracts_with_facilities = sum(facility_n > 0),
    total_facilities = sum(facility_n, na.rm = TRUE),
    total_youth = sum(under18, na.rm = TRUE),
    avg_facilities_per_1000_youth = mean(facilities_per_1000_youth, na.rm = TRUE),
    median_facilities_per_1000_youth = median(facilities_per_1000_youth, na.rm = TRUE),
    facility_coverage_rate = tracts_with_facilities / total_tracts,
    .groups = 'drop'
  )

cat("Borough-level summary:\n")
print(borough_summary)

# ---- 6. Income-Based Analysis ----
cat("Performing income-based analysis...\n")

# Create income quartiles based on total population
tracts_with_facilities_filtered <- tracts_with_facilities %>%
  filter(under18 > 0) %>%
  mutate(
    income_quartile = ntile(total_pop, 4),
    has_facility = facility_n > 0
  )

# Calculate summary by income quartile
quartile_summary <- tracts_with_facilities_filtered %>%
  group_by(income_quartile) %>%
  summarise(
    avg_facilities = mean(facilities_per_1000_youth, na.rm = TRUE),
    tracts_with_facilities = sum(has_facility),
    total_tracts = n(),
    facility_rate = tracts_with_facilities / total_tracts,
    .groups = 'drop'
  )

cat("Facility access by population quartile:\n")
print(quartile_summary)

# ---- 7. Spatial Data for Mapping ----
cat("Preparing spatial data for mapping...\n")

# Merge facility data with census tracts for mapping
tracts_choropleth <- census_tracts %>%
  left_join(tracts_with_facilities, by = "GEOID") %>%
  mutate(
    facility_n = replace_na(facility_n, 0),
    facilities_per_1000_youth = replace_na(facilities_per_1000_youth, 0)
  )

# ---- 8. Save Results ----
cat("Saving analysis results...\n")

# Save main analysis dataset
write_csv(tracts_with_facilities, "output/facility_equity_analysis.csv")

# Save borough summary
write_csv(borough_summary, "output/borough_summary.csv")

# Save quartile summary
write_csv(quartile_summary, "output/income_quartile_summary.csv")

# Save spatial data
st_write(tracts_choropleth, "output/tracts_with_facilities.geojson", delete_dsn = TRUE)

# Save facility centroids for mapping
st_write(facility_centroids_sf, "output/facility_centroids.geojson", delete_dsn = TRUE)

# ---- 9. Create Analysis Summary ----
cat("Creating analysis summary...\n")

analysis_summary <- list(
  overall_stats = list(
    total_tracts = total_tracts,
    tracts_with_facilities = tracts_with_facilities_count,
    total_facilities = total_facilities,
    avg_facilities_per_1000_youth = avg_facilities_per_1000_youth,
    median_facilities_per_1000_youth = median_facilities_per_1000_youth,
    coverage_rate = tracts_with_facilities_count / total_tracts
  ),
  borough_analysis = borough_summary,
  income_analysis = quartile_summary,
  spatial_data = list(
    tracts_with_facilities = nrow(tracts_choropleth),
    facility_centroids = nrow(facility_centroids_sf)
  )
)

# Save analysis summary
saveRDS(analysis_summary, "output/analysis_summary.rds")

# ---- 10. Quality Checks ----
cat("Performing quality checks...\n")

# Check for any tracts with facilities but no youth population
tracts_with_facilities_no_youth <- tracts_with_facilities %>%
  filter(facility_n > 0, under18 == 0)

if (nrow(tracts_with_facilities_no_youth) > 0) {
  cat("WARNING: Found", nrow(tracts_with_facilities_no_youth), "tracts with facilities but no youth population\n")
} else {
  cat("No tracts with facilities but no youth population ✓\n")
}

# Check for extreme values
extreme_values <- tracts_with_facilities %>%
  filter(facilities_per_1000_youth > 10)

if (nrow(extreme_values) > 0) {
  cat("Found", nrow(extreme_values), "tracts with extremely high facility density (>10 per 1000 youth)\n")
} else {
  cat("No extreme facility density values found ✓\n")
}

cat(paste(rep('=', 50), collapse = ''), "\n")
cat("SPATIAL ANALYSIS COMPLETE\n")
cat(paste(rep('=', 50), collapse = ''), "\n")
cat("Files created:\n")
cat("- output/facility_equity_analysis.csv (main dataset)\n")
cat("- output/borough_summary.csv\n")
cat("- output/income_quartile_summary.csv\n")
cat("- output/tracts_with_facilities.geojson\n")
cat("- output/facility_centroids.geojson\n")
cat("- output/analysis_summary.rds\n")
cat("\nNext step: Run scripts/03_equity_analysis.R\n")
cat(paste(rep('=', 50), collapse = ''), "\n") 