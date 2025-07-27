# ============================================================================
# NYC Athletic Facilities Equity Analysis - Visualizations
# Step 4: Create statistical charts and graphs
# ============================================================================

cat("Starting visualization creation...\n")
library(ggplot2)
library(readr)
library(dplyr)
library(janitor)
library(sf)

# ---- 1. Load Data ----
tracts_with_facilities <- read_csv("output/facility_equity_analysis.csv")
income_quartile_summary <- read_csv("output/income_quartile_summary.csv")
borough_coverage <- read_csv("output_new/borough_coverage.csv")

# ---- 2. Top 20 Neighborhoods Bar Chart ----
cat("Creating top 20 neighborhoods bar chart...\n")
top20 <- tracts_with_facilities %>%
  filter(facility_n > 0) %>%
  arrange(desc(facilities_per_1000_youth)) %>%
  head(20)

top20$label <- top20$GEOID

p1 <- ggplot(top20, aes(x = reorder(label, facilities_per_1000_youth), y = facilities_per_1000_youth)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 20 Neighborhoods by Facilities per 1,000 Youth",
       x = "Census Tract",
       y = "Facilities per 1,000 Youth") +
  theme_minimal()
ggsave("output/top_facility_tracts_named.png", p1, width = 12, height = 8)

# ---- 3. Facility Density Histogram ----
cat("Creating facility density histogram...\n")
p2 <- ggplot(tracts_with_facilities, aes(x = facilities_per_1000_youth)) +
  geom_histogram(bins = 30, fill = "lightblue", color = "black") +
  coord_cartesian(xlim = c(0, 2)) +
  labs(title = "Distribution of Facilities per 1,000 Youth (Zoomed In)",
       x = "Facilities per 1,000 Youth",
       y = "Number of Census Tracts") +
  theme_minimal()
ggsave("output_new/facility_distribution_histogram.png", p2, width = 10, height = 6)

# ---- 4. Income Group Comparison ----
cat("Creating income group comparison chart...\n")
p3 <- ggplot(income_quartile_summary, aes(x = factor(income_quartile), y = avg_facilities)) +
  geom_bar(stat = "identity", fill = "orange") +
  labs(title = "Average Facilities per 1,000 Youth by Income Quartile",
       x = "Income Quartile",
       y = "Avg Facilities per 1,000 Youth") +
  theme_minimal()
ggsave("output/income_analysis.png", p3, width = 8, height = 6)

# ---- 5. Borough Coverage Rate ----
cat("Creating borough coverage rate chart...\n")
p4 <- ggplot(borough_coverage, aes(x = BoroName, y = coverage_rate)) +
  geom_bar(stat = "identity", fill = "purple") +
  labs(title = "Facility Coverage Rate by Borough",
       x = "Borough",
       y = "Coverage Rate") +
  theme_minimal()
ggsave("output_new/facility_coverage_rate.png", p4, width = 8, height = 6)

cat("Visualization creation complete.\n") 