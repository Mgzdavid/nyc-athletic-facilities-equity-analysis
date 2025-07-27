# ============================================================================
# Data Validation Script - NYC Athletic Facilities Equity Analysis
# This script validates that all required data files are present and readable
# ============================================================================

cat("Starting data validation...\n\n")

# Load required libraries
library(sf)
library(readr)
library(dplyr)

# Function to check file existence
check_file <- function(file_path, description) {
  if (file.exists(file_path)) {
    file_size <- file.size(file_path)
    cat("✅", description, "-", file_path, "(", round(file_size/1024/1024, 2), "MB)\n")
    return(TRUE)
  } else {
    cat("❌", description, "-", file_path, "MISSING\n")
    return(FALSE)
  }
}

# Function to test file readability
test_readability <- function(file_path, description, test_function) {
  tryCatch({
    result <- test_function(file_path)
    cat("✅", description, "readable\n")
    return(TRUE)
  }, error = function(e) {
    cat("❌", description, "ERROR:", e$message, "\n")
    return(FALSE)
  })
}

cat("=== File Existence Check ===\n")

# Check main data files
files_to_check <- list(
  c("data/NYC_Athletic_Selected.csv", "Athletic Facilities CSV"),
  c("data/NYC_Athletic_Selected_final.gpkg", "Athletic Facilities GeoPackage"),
  c("data/nyct2020.shp", "Census Tract Boundaries Shapefile"),
  c("data/nyct2020.dbf", "Census Tract Boundaries DBF"),
  c("data/nyct2020.shx", "Census Tract Boundaries SHX"),
  c("data/nyct2020.prj", "Census Tract Boundaries PRJ"),
  c("data/README.md", "Data README")
)

all_files_exist <- TRUE
for (file_info in files_to_check) {
  if (!check_file(file_info[1], file_info[2])) {
    all_files_exist <- FALSE
  }
}

cat("\n=== Directory Structure Check ===\n")

# Check ACS data directories
acs_dirs <- c(
  "data/CityCouncilDistrict",
  "data/CommunityDistrict-PUMA", 
  "data/Neighborhood-NTA",
  "data/NYC-Borough"
)

for (dir_path in acs_dirs) {
  if (dir.exists(dir_path)) {
    file_count <- length(list.files(dir_path))
    cat("✅", basename(dir_path), "-", dir_path, "(", file_count, "files)\n")
  } else {
    cat("❌", basename(dir_path), "-", dir_path, "MISSING\n")
    all_files_exist <- FALSE
  }
}

cat("\n=== File Readability Test ===\n")

# Test CSV file readability
csv_readable <- test_readability(
  "data/NYC_Athletic_Selected.csv",
  "Athletic Facilities CSV",
  function(x) read_csv(x, n_max = 5)
)

# Test GeoPackage file readability
gpkg_readable <- test_readability(
  "data/NYC_Athletic_Selected_final.gpkg",
  "Athletic Facilities GeoPackage",
  function(x) { data <- st_read(x); return(nrow(data)) }
)

# Test Shapefile readability
shp_readable <- test_readability(
  "data/nyct2020.shp",
  "Census Tract Boundaries",
  function(x) { data <- st_read(x); return(nrow(data)) }
)

cat("\n=== Data Summary ===\n")

if (csv_readable) {
  facilities <- read_csv("data/NYC_Athletic_Selected.csv")
  cat("Athletic Facilities CSV:\n")
  cat("  - Rows:", nrow(facilities), "\n")
  cat("  - Columns:", ncol(facilities), "\n")
  cat("  - Memory usage:", round(object.size(facilities)/1024/1024, 2), "MB\n")
}

if (gpkg_readable) {
  facilities_sf <- st_read("data/NYC_Athletic_Selected_final.gpkg")
  cat("Athletic Facilities GeoPackage:\n")
  cat("  - Features:", nrow(facilities_sf), "\n")
  cat("  - Geometry type:", st_geometry_type(facilities_sf)[1], "\n")
  cat("  - CRS:", st_crs(facilities_sf)$input, "\n")
}

if (shp_readable) {
  tracts <- st_read("data/nyct2020.shp")
  cat("Census Tract Boundaries:\n")
  cat("  - Features:", nrow(tracts), "\n")
  cat("  - Geometry type:", st_geometry_type(tracts)[1], "\n")
  cat("  - CRS:", st_crs(tracts)$input, "\n")
}

cat("\n=== Validation Summary ===\n")

if (all_files_exist && csv_readable && gpkg_readable && shp_readable) {
  cat("🎉 ALL DATA FILES VALIDATED SUCCESSFULLY!\n")
  cat("✅ All required files are present\n")
  cat("✅ All files are readable\n")
  cat("✅ Data formats are correct\n")
  cat("✅ Ready for analysis\n")
} else {
  cat("⚠️  SOME ISSUES FOUND:\n")
  if (!all_files_exist) cat("- Missing files detected\n")
  if (!csv_readable) cat("- CSV file cannot be read\n")
  if (!gpkg_readable) cat("- GeoPackage file cannot be read\n")
  if (!shp_readable) cat("- Shapefile cannot be read\n")
  cat("Please check the errors above and fix them before proceeding.\n")
}

cat("\n=== Next Steps ===\n")
cat("If validation passed, you can now run:\n")
cat("1. source('scripts/00_setup.R')\n")
cat("2. source('scripts/01_data_preparation.R')\n")
cat("3. Continue with other analysis scripts\n")

cat("\n", paste(rep("=", 50), collapse=""), "\n")
cat("Data validation completed.\n")
cat(paste(rep("=", 50), collapse=""), "\n") 