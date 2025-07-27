library(dplyr)
library(janitor)
library(readr)
library(sf)
library(purrr)
library(tidycensus)
library(tidyr)
# ============================================================================
# NYC Athletic Facilities Equity Analysis - Data Preparation
# Step 1: Load, clean, and prepare data for analysis
# ============================================================================

cat("Starting data preparation...\n")

# ---- 1. Load and Clean Athletic Facilities Data ----
cat("Loading athletic facilities data...\n")

facilities <- read_csv("data/NYC_Athletic_Selected.csv") %>% 
  clean_names()

cat("Original facilities data has", nrow(facilities), "records\n")

# Filter for recreational facilities
athletic_facilities <- facilities

cat("Filtered to", nrow(athletic_facilities), "athletic facilities\n")

# Check for missing values
cat("Missing values in athletic facilities data:\n")
print(colSums(is.na(athletic_facilities)))

# ---- 2. Convert to Spatial Object ----
cat("Converting facilities to spatial object...\n")

athletic_sf <- st_as_sf(athletic_facilities, wkt = "multipolygon", crs = 4326)

# Fix any geometry issues
athletic_sf_clean <- st_make_valid(athletic_sf)

# Get centroids for spatial analysis
facility_centroids <- st_centroid(athletic_sf_clean)

cat("Successfully created", nrow(facility_centroids), "facility centroids\n")

# ---- 3. Load Census Tract Boundaries ----
cat("Loading census tract boundaries...\n")

census_tracts <- st_read("data/nyct2020.shp")
census_tracts <- st_transform(census_tracts, crs = 4326)

cat("Loaded", nrow(census_tracts), "census tracts\n")

# Ensure GEOID is character type
census_tracts$GEOID <- as.character(census_tracts$GEOID)

# ---- 4. Download Population Data ----
cat("Downloading population data from Census API...\n")

# Check if Census API key is set
if (Sys.getenv("CENSUS_API_KEY") == "") {
  stop("Census API key not set. Please run: census_api_key('YOUR_API_KEY', install = TRUE, overwrite = TRUE)")
}

# Set up Census variables
nyc_counties <- c("Bronx", "Kings", "New York", "Queens", "Richmond")
nyc_vars <- c(total_pop = "B01003_001", under18 = "B09001_001")

# Download population data for each county
pop_data <- map_dfr(nyc_counties, function(county) {
  cat("Downloading data for", county, "County...\n")
  get_acs(geography = "tract", variables = nyc_vars, 
          state = "NY", county = county, geometry = TRUE, year = 2022)
})

cat("Downloaded population data for", nrow(pop_data), "census tracts\n")

# Reshape population data to wide format
pop_wide <- pop_data %>% 
  select(GEOID, variable, estimate) %>% 
  pivot_wider(names_from = variable, values_from = estimate)

# Ensure GEOID is character type
pop_wide$GEOID <- as.character(pop_wide$GEOID)

# ---- 5. Data Quality Checks ----
cat("Performing data quality checks...\n")

# Check for duplicate GEOIDs
duplicate_geoids <- pop_wide$GEOID[duplicated(pop_wide$GEOID)]
if (length(duplicate_geoids) > 0) {
  cat("WARNING: Found", length(duplicate_geoids), "duplicate GEOIDs\n")
} else {
  cat("No duplicate GEOIDs found ✓\n")
}

# Check for missing population data
missing_pop <- sum(is.na(pop_wide$total_pop))
missing_youth <- sum(is.na(pop_wide$under18))

cat("Missing total population data:", missing_pop, "tracts\n")
cat("Missing youth population data:", missing_youth, "tracts\n")

# Replace missing values with 0
pop_wide <- pop_wide %>% 
  mutate(
    total_pop = replace_na(total_pop, 0),
    under18 = replace_na(under18, 0)
  )

# ---- 6. Save Intermediate Data ----
cat("Saving intermediate data...\n")

# Save cleaned facility data
write_csv(athletic_facilities, "output_new/cleaned_athletic_facilities.csv")

# Save population data
write_csv(pop_wide, "output/population_data.csv")

# Save facility centroids as CSV (without geometry)
facility_centroids_csv <- facility_centroids %>% 
  st_drop_geometry()
write_csv(facility_centroids_csv, "output/facility_centroids.csv")

# ---- 7. Summary Statistics ----
cat("Generating summary statistics...\n")

cat("Population Data Summary:\n")
cat("Total census tracts:", nrow(pop_wide), "\n")
cat("Total population:", sum(pop_wide$total_pop, na.rm = TRUE), "\n")
cat("Total youth population:", sum(pop_wide$under18, na.rm = TRUE), "\n")
cat("Average youth per tract:", mean(pop_wide$under18, na.rm = TRUE), "\n")

cat("Facility Data Summary:\n")
cat("Total athletic facilities:", nrow(facility_centroids), "\n")
cat("Facilities by borough:\n")
print(table(facility_centroids_csv$borough))

# ---- 8. Create Data Dictionary ----
cat("Creating data summary for documentation...\n")

data_summary <- list(
  population_data = list(
    total_tracts = nrow(pop_wide),
    total_population = sum(pop_wide$total_pop, na.rm = TRUE),
    total_youth = sum(pop_wide$under18, na.rm = TRUE),
    variables = c("GEOID", "total_pop", "under18")
  ),
  facility_data = list(
    total_facilities = nrow(facility_centroids),
    boroughs = unique(facility_centroids_csv$borough),
    variables = names(athletic_facilities)
  ),
  spatial_data = list(
    census_tracts = nrow(census_tracts),
    coordinate_system = "WGS84 (EPSG:4326)",
    geometry_types = c("facility_polygons", "facility_centroids", "census_tract_boundaries")
  )
)

# Save data summary
saveRDS(data_summary, "output/data_summary.rds")

# 替换分隔线输出
cat(paste(rep('=', 50), collapse = ''), "\n")
cat("DATA PREPARATION COMPLETE\n")
cat(paste(rep('=', 50), collapse = ''), "\n")
cat("Files created:\n")
cat("- output/cleaned_athletic_facilities.csv\n")
cat("- output/population_data.csv\n")
cat("- output/facility_centroids.csv\n")
cat("- output/data_summary.rds\n")
cat("\nNext step: Run scripts/02_spatial_analysis.R\n")
cat(paste(rep('=', 50), collapse = ''), "\n") 