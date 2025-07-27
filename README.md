# NYC Athletic Facilities Equity Analysis

## Project Overview

This project analyzes the spatial distribution equity of athletic facilities in New York City, focusing on disparities in facility accessibility among different income levels and ethnic/racial groups. The research employs spatial analysis techniques to provide data-driven insights for urban planning policies.

## 🎯 Key Findings

- **Income Disparity**: Highest income quartile communities have 2.5x more facilities than lowest income communities
- **Racial Differences**: Significant variations in facility accessibility by ethnicity
- **Service Coverage**: ~30% of communities lack facilities within 0.5-mile walking distance
- **Spatial Inequality**: Clear evidence of uneven facility distribution across NYC

## 📊 Analysis Scope

- **2,593 athletic facilities** analyzed across NYC
- **2,325 census tracts** included in analysis
- **0.5-mile walking distance** used for accessibility analysis
- **Multi-dimensional equity analysis** (income, race, geography)

## 🚀 Quick Start

### Prerequisites

1. **R Environment**: R 4.0+ with required packages
2. **Census API Key**: Get free key from [Census API](https://api.census.gov/data/key_signup.html)
3. **Data Files**: All data included in `data/` directory

### Installation

```r
# Run setup script to install dependencies
source("scripts/00_setup.R")
```

### Data Validation

```r
# Validate all data files
Rscript validate_data.R
```

### Run Analysis

```r
# Setup environment
source("scripts/00_setup.R")

# Prepare data
source("scripts/01_data_preparation.R")

# Spatial analysis
source("scripts/02_spatial_analysis.R")

# Equity analysis
source("scripts/03_equity_analysis.R")

# Visualizations
source("scripts/04_visualizations.R")
source("scripts/05_maps.R")
```

## 📁 Repository Structure

```
├── README.md                    # Project documentation
├── SUBMISSION_CHECKLIST.md      # Submission checklist
├── PROJECT_SUMMARY.md          # Project summary
├── validate_data.R             # Data validation script
├── qgis_workflow.md            # QGIS operation workflow
├── scripts/                     # R analysis scripts (13 files)
│   ├── 00_setup.R              # Environment setup
│   ├── 01_data_preparation.R   # Data preparation
│   ├── 02_spatial_analysis.R   # Spatial analysis
│   ├── 03_equity_analysis.R    # Equity analysis
│   ├── 04_visualizations.R     # Visualizations
│   ├── 05_maps.R              # Map creation
│   ├── 07_nta_analysis.R      # NTA analysis
│   ├── 08_nta_service_coverage.R # Service coverage
│   ├── 11_nta_service_coverage.R # Improved service coverage
│   ├── 12_nta_facility_density.R # Facility density
│   ├── 13_nta_facility_type_density.R # Facility type density
│   ├── 14_nta_income_equity_analysis.R # Income equity
│   └── 15_nta_ethnicity_equity_analysis.R # Ethnicity equity
├── docs/                        # Documentation (7 files)
│   ├── methodology.md          # Methodology documentation
│   ├── data_dictionary.md      # Data dictionary
│   ├── technical_notes.md      # Technical implementation notes
│   ├── Medium_Blog_Personal_Story.md # Personal story blog
│   ├── Medium_Blog_Enhanced_Version.md # Enhanced blog version
│   └── Borough_Facility_Analysis_English.md # English analysis report
├── data/                        # Data files
│   ├── NYC_Athletic_Selected.csv # Athletic facilities (2,593 records)
│   ├── NYC_Athletic_Selected_final.gpkg # Athletic facilities (spatial)
│   ├── nyct2020.shp            # Census tract boundaries (2,325 tracts)
│   └── 5-yr ACS 2022/          # Census data directories
└── output/                      # Analysis results (30+ files)
    ├── charts/                 # Visualization charts
    ├── maps/                   # Geographic maps
    └── tables/                 # Data tables
```

## 🔧 Technical Implementation

### Spatial Analysis
- **Coordinate System**: WGS84 (EPSG:4326)
- **Buffer Analysis**: 0.5-mile walking distance
- **Density Calculation**: Facilities per 1,000 population
- **Service Coverage**: Spatial intersection analysis

### Statistical Methods
- **Income Quartiles**: Four-tier income classification
- **Ethnicity Analysis**: Major racial/ethnic group identification
- **Descriptive Statistics**: Comprehensive summary statistics
- **Equity Assessment**: Multi-dimensional fairness analysis

### Visualization
- **Maps**: 7 professional geographic visualizations
- **Charts**: 10 statistical charts and graphs
- **Tables**: 15 detailed data summaries

## 📚 Data Sources

### Primary Data
1. **NYC Parks Athletic Facilities** (NYC Open Data)
   - Source: https://data.cityofnewyork.us/Recreation/NYC-Parks-Athletic-Facilities/6nca-7ph6
2. **US Census ACS 2022 5-Year Estimates**
   - Source: https://www.census.gov/programs-surveys/acs/
3. **NYC Census Tract Boundaries** (2020)
   - Source: https://www1.nyc.gov/site/planning/data-maps/open-data.page

## 🎨 Key Outputs

### Core Visualizations
- `borough_facility_density_english.png` - Borough comparison
- `nta_facility_per1000_box_income_final.png` - Income analysis
- `ethnicity_facility_distribution_final.png` - Ethnicity analysis

### Geographic Maps
- `nta_facility_density_map.png` - Overall density
- `nta_basketball_density_map.png` - Basketball courts
- `nta_soccer_density_map.png` - Soccer fields
- `nta_baseball_density_map.png` - Baseball fields
- `nta_service_coverage_map.png` - Service coverage

### Data Tables
- `nta_facility_stats_en.csv` - Facility statistics
- `income_quartile_summary_final.csv` - Income analysis
- `ethnicity_summary_final.csv` - Ethnicity analysis

## 📖 Documentation

### Complete Documentation Suite
- **methodology.md**: Detailed methodology documentation
- **data_dictionary.md**: Complete data field descriptions
- **technical_notes.md**: Technical implementation details
- **qgis_workflow.md**: QGIS operation procedures

### Blog Posts
- **Medium_Blog_Personal_Story.md**: Personal narrative version
- **Medium_Blog_Enhanced_Version.md**: Comprehensive analysis version
- **Borough_Facility_Analysis_English.md**: English analysis report

## 🛠️ Required R Packages

```r
# Core packages
library(tidyverse)    # Data manipulation and visualization
library(sf)           # Spatial data handling
library(tmap)         # Map creation
library(tidycensus)   # Census data access
library(janitor)      # Data cleaning
library(purrr)        # Functional programming
```

## 📋 Quality Assurance

### Code Quality
- ✅ All scripts have detailed comments
- ✅ Modular design for easy maintenance
- ✅ Error handling mechanisms implemented
- ✅ Reproducible analysis workflow

### Data Validation
- ✅ All data files present and readable
- ✅ Spatial data integrity confirmed
- ✅ Statistical results validated
- ✅ Output files quality checked

## 🎯 Project Impact

### Academic Value
- Demonstrates complete spatial data analysis workflow
- Provides reproducible research methodology
- Contributes to urban equity research literature

### Policy Relevance
- Identifies specific areas needing investment
- Supports evidence-based urban planning
- Provides data for equity policy development

## 📞 Contact & Support

For questions about this project:
- Review the documentation in `docs/` directory
- Check the data validation script: `validate_data.R`
- Refer to the submission checklist: `SUBMISSION_CHECKLIST.md`

## 🙏 Acknowledgments

Thanks to:
- NYC Parks Department for facility data
- US Census Bureau for demographic data
- NYC Department of City Planning for geographic boundaries
- Open source community for R packages and tools

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Project Completed**: December 2024  
**Analysis Period**: 2022 ACS 5-Year Estimates  
**Geographic Coverage**: New York City (5 boroughs)  
**Facilities Analyzed**: 2,593 athletic facilities  
**Census Tracts**: 2,325 tracts  

*This project demonstrates how personal experiences can be transformed into meaningful policy analysis through rigorous spatial data science methods.* 
