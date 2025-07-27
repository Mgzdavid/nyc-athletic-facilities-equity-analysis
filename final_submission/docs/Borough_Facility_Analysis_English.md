# Borough Facility Density Analysis - English Version

## Executive Summary

This analysis examines the distribution of athletic facilities per 1,000 youth across New York City's five boroughs, revealing significant disparities in access to sports infrastructure.

## Key Findings

### 1. Manhattan Leads in Facility Density
- **Median facilities per 1,000 youth**: 1.76
- **NTAs analyzed**: 28
- **Total youth population**: 207,576
- **Total facilities**: 447

Manhattan shows the highest median facility density, indicating relatively good access to athletic facilities for youth in this borough.

### 2. Queens Shows Consistent but Lower Density
- **Median facilities per 1,000 youth**: 1.34
- **NTAs analyzed**: 56
- **Total youth population**: 453,162
- **Total facilities**: 551

Queens has the largest youth population but shows moderate facility density, suggesting potential underinvestment relative to population size.

### 3. Brooklyn Demonstrates Moderate Access
- **Median facilities per 1,000 youth**: 1.26
- **NTAs analyzed**: 49
- **Total youth population**: 569,736
- **Total facilities**: 738

Brooklyn has the largest youth population and facility count, but moderate per-capita density indicates room for improvement.

### 4. Staten Island Shows Varied Distribution
- **Median facilities per 1,000 youth**: 1.19
- **NTAs analyzed**: 16
- **Total youth population**: 99,592
- **Total facilities**: 129

Staten Island has the smallest youth population and shows moderate facility density with high variability.

### 5. Bronx Faces Significant Challenges
- **Median facilities per 1,000 youth**: 0.67
- **NTAs analyzed**: 38
- **Total youth population**: 359,389
- **Total facilities**: 288

The Bronx shows the lowest median facility density, indicating the greatest need for investment in athletic infrastructure.

## Data Quality Notes

- **Data cleaning**: Removed infinite values and extreme outliers (99th percentile)
- **Sample size**: 187 NTAs with valid data across all boroughs
- **Outliers**: Some NTAs show extremely high facility density due to very small youth populations

## Policy Implications

### 1. Investment Priorities
- **Bronx**: Highest priority for new facility development
- **Queens**: Consider population size when allocating resources
- **Brooklyn**: Focus on underserved NTAs within the borough

### 2. Equity Considerations
- The analysis reveals clear geographic disparities in youth athletic facility access
- Borough-level differences suggest systemic inequities in resource allocation
- Population density should be considered alongside facility density

### 3. Planning Recommendations
- Target capital investments in the Bronx and underserved areas of Queens
- Consider youth population growth trends in facility planning
- Implement borough-specific strategies based on local needs

## Methodology

### Data Sources
- NYC Parks Athletic Facilities Dataset
- ACS 2022 5-Year Estimates for youth population
- NTA boundary definitions

### Analysis Approach
- Calculated facilities per 1,000 youth for each NTA
- Grouped by borough using NTA codes
- Applied statistical cleaning to remove outliers
- Generated summary statistics and visualizations

### Limitations
- Facility data represents point-in-time inventory
- Youth population estimates from 2022 ACS
- Does not account for facility quality or accessibility factors
- Some NTAs may have zero youth population (industrial/commercial areas)

## Visualizations Generated

1. **Boxplot**: Shows distribution of facility density by borough
2. **Density Curves**: Illustrates the shape of distributions
3. **Summary Statistics**: Provides numerical comparisons

## Files Created

- `borough_facility_density_english.png`: Main boxplot visualization
- `borough_facility_density_curves_english.png`: Density distribution curves
- `borough_facility_summary_english.csv`: Statistical summary data

---

*Analysis conducted using R with ggplot2, dplyr, and janitor packages*
*Data sources: NYC Open Data and U.S. Census Bureau* 