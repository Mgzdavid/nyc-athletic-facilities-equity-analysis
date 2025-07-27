# ============================================================================
# NYC Athletic Facilities Equity Analysis - Setup Script
# Install and load required packages
# ============================================================================

# List of required packages
required_packages <- c(
  "tidyverse",    # Data manipulation and visualization
  "sf",           # Spatial data handling
  "tmap",         # Map creation
  "tidycensus",   # Census data access
  "janitor",      # Data cleaning
  "purrr",        # Functional programming
  "ggplot2",      # Plotting (included in tidyverse but explicit)
  "dplyr",        # Data manipulation (included in tidyverse but explicit)
  "readr"         # Data reading (included in tidyverse but explicit)
)

# Function to install packages if not already installed
install_if_missing <- function(packages) {
  for (package in packages) {
    if (!require(package, character.only = TRUE, quietly = TRUE)) {
      cat("Installing", package, "...\n")
      install.packages(package, repos = "https://cloud.r-project.org")
    } else {
      cat(package, "is already installed.\n")
    }
  }
}

# Install missing packages
cat("Checking and installing required packages...\n")
install_if_missing(required_packages)

# Load all packages
cat("Loading packages...\n")
library(tidyverse)
library(sf)
library(tmap)
library(tidycensus)
library(janitor)
library(purrr)

# Set tmap mode to static for consistent output
tmap_mode("plot")

# Create output directory if it doesn't exist
if (!dir.exists("output")) {
  dir.create("output")
  cat("Created output directory.\n")
}

# Set up Census API key (user needs to provide their own key)
cat("\nIMPORTANT: You need to set up your Census API key.\n")
cat("1. Get a free API key from: https://api.census.gov/data/key_signup.html\n")
cat("2. Run: census_api_key('YOUR_API_KEY', install = TRUE, overwrite = TRUE)\n")
cat("3. Or set it in your .Renviron file\n\n")

# Function to check if Census API key is set
check_census_key <- function() {
  key <- Sys.getenv("CENSUS_API_KEY")
  if (key == "") {
    cat("WARNING: Census API key not found. Please set it using:\n")
    cat("census_api_key('YOUR_API_KEY', install = TRUE, overwrite = TRUE)\n")
    return(FALSE)
  } else {
    cat("Census API key is set.\n")
    return(TRUE)
  }
}

# Check Census API key
census_key_ready <- check_census_key()

# Function to check if data files exist
check_data_files <- function() {
  required_files <- c(
    "data/Athletic_Facilities.csv",
    "data/nyct2020.shp"
  )
  
  missing_files <- c()
  for (file in required_files) {
    if (!file.exists(file)) {
      missing_files <- c(missing_files, file)
    }
  }
  
  if (length(missing_files) > 0) {
    cat("WARNING: Missing data files:\n")
    for (file in missing_files) {
      cat("  -", file, "\n")
    }
    cat("\nPlease ensure all data files are in the data/ directory.\n")
    return(FALSE)
  } else {
    cat("All required data files found.\n")
    return(TRUE)
  }
}

# Check data files
data_files_ready <- check_data_files()

# Summary
cat("\n" , "="*50, "\n")
cat("SETUP SUMMARY\n")
cat("="*50, "\n")
cat("Packages installed and loaded: ✓\n")
cat("Output directory created: ✓\n")
cat("Census API key ready:", ifelse(census_key_ready, "✓", "✗"), "\n")
cat("Data files ready:", ifelse(data_files_ready, "✓", "✗"), "\n")

if (census_key_ready && data_files_ready) {
  cat("\nSetup complete! You can now run the analysis scripts.\n")
  cat("Start with: source('scripts/01_data_preparation.R')\n")
} else {
  cat("\nSetup incomplete. Please address the warnings above before proceeding.\n")
}

cat("="*50, "\n") 