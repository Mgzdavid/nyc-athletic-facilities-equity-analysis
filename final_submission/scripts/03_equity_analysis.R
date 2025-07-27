library(dplyr)
library(janitor)
library(readr)
library(sf)
# ============================================================================
# NYC Athletic Facilities Equity Analysis - Equity Analysis
# Step 3: Perform equity and demographic group analysis
# ============================================================================

cat("Starting equity analysis...\n")

# ---- 1. Load Data ----
cat("Loading main analysis dataset...\n")
tracts_with_facilities <- read_csv("output/facility_equity_analysis.csv")

# ---- 2. Income Group Analysis ----
cat("Analyzing facility access by income quartile...\n")
tracts_with_facilities <- tracts_with_facilities %>%
  mutate(
    income_quartile = ntile(total_pop, 4),
    has_facility = facility_n > 0
  )

income_quartile_summary <- tracts_with_facilities %>%
  group_by(income_quartile) %>%
  summarise(
    avg_facilities = mean(facilities_per_1000_youth, na.rm = TRUE),
    tracts_with_facilities = sum(has_facility),
    total_tracts = n(),
    facility_rate = tracts_with_facilities / total_tracts,
    .groups = 'drop'
  )

write_csv(income_quartile_summary, "output_new/income_quartile_summary.csv")

cat("Income quartile summary saved.\n")

# ---- 3. Coverage Rate by Borough ----
cat("Calculating facility coverage rate by borough...\n")
census_tracts <- st_read("data/nyct2020.shp")
census_tracts <- st_transform(census_tracts, crs = 4326)
census_tracts$GEOID <- as.character(census_tracts$GEOID)

borough_info <- census_tracts %>% st_drop_geometry() %>% select(GEOID, BoroName)
tracts_with_facilities <- tracts_with_facilities %>% mutate(GEOID = as.character(GEOID))
tracts_with_facilities <- tracts_with_facilities %>% left_join(borough_info, by = "GEOID")

borough_coverage <- tracts_with_facilities %>%
  group_by(BoroName) %>%
  summarise(
    total_tracts = n(),
    tracts_with_facilities = sum(facility_n > 0),
    coverage_rate = tracts_with_facilities / total_tracts,
    .groups = 'drop'
  )

write_csv(borough_coverage, "output_new/borough_coverage.csv")
cat("Borough coverage summary saved.\n")

cat("Equity analysis complete.\n") 