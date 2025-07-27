# Data Files - NYC Athletic Facilities Equity Analysis

## Overview

This directory contains all the data files required to reproduce the NYC Athletic Facilities Equity Analysis.

## Data Files

### 1. Athletic Facilities Data
- **NYC_Athletic_Selected.csv** - Main athletic facilities dataset in CSV format
  - Source: NYC Parks Department via NYC Open Data
  - Contains: 2,593 facilities with 45 fields
  - Format: CSV (converted from GeoPackage)
  - Used by: All analysis scripts

- **NYC_Athletic_Selected_final.gpkg** - Athletic facilities dataset in GeoPackage format
  - Source: NYC Parks Department via NYC Open Data
  - Contains: 2,593 facilities with spatial geometry
  - Format: GeoPackage (original format)
  - Used by: Spatial analysis scripts

### 2. Geographic Boundaries
- **nyct2020.shp** - NYC Census Tract boundaries (2020)
  - Source: NYC Department of City Planning
  - Contains: Census tract polygons for NYC
  - Format: Shapefile (.shp, .dbf, .shx, .prj, .xml)
  - Used by: Spatial analysis and mapping

### 3. Census Data (5-yr ACS 2022)
- **CityCouncilDistrict/** - City Council District level data
- **CommunityDistrict-PUMA/** - Community District and PUMA level data
- **Neighborhood-NTA/** - Neighborhood Tabulation Area level data
- **NYC-Borough/** - Borough level data

Each directory contains demographic, economic, housing, and social data from the American Community Survey 2022 5-Year Estimates.

## Data Sources

### Primary Sources
1. **NYC Parks Athletic Facilities**
   - URL: https://data.cityofnewyork.us/Recreation/NYC-Parks-Athletic-Facilities/6nca-7ph6
   - Provider: NYC Parks Department
   - Last Updated: 2022

2. **NYC Census Tract Boundaries**
   - URL: https://www1.nyc.gov/site/planning/data-maps/open-data.page
   - Provider: NYC Department of City Planning
   - Year: 2020

3. **American Community Survey**
   - URL: https://www.census.gov/programs-surveys/acs/
   - Provider: US Census Bureau
   - Period: 2022 5-Year Estimates

## Data Processing

### Athletic Facilities Data
- Original data cleaned and filtered for recreational facilities
- Geometry validated and repaired
- Coordinate system standardized to WGS84 (EPSG:4326)
- Duplicate facilities removed
- Missing values handled appropriately

### Census Data
- Downloaded via tidycensus R package
- Variables selected for equity analysis
- Geocoded to census tract level
- Missing values imputed where appropriate

## File Formats

- **CSV**: Tabular data for statistical analysis
- **Shapefile**: Geographic boundaries for mapping
- **GeoPackage**: Modern spatial data format
- **Excel**: Census data summaries

## Usage

1. **For R Analysis**: Use CSV files for statistical analysis
2. **For Mapping**: Use Shapefile and GeoPackage files for spatial visualization
3. **For Census Analysis**: Use ACS data files for demographic analysis

## Data Dictionary

For detailed field descriptions, see `../docs/data_dictionary.md`

## Notes

- All spatial data uses WGS84 coordinate system (EPSG:4326)
- Data files are compressed where possible to reduce size
- Original data sources are preserved for reference
- Processed data files are optimized for analysis workflow

---

**Last Updated**: December 2024
**Data Version**: 2022 ACS 5-Year Estimates
**Facilities Count**: 2,593 athletic facilities
**Geographic Coverage**: New York City (5 boroughs) 