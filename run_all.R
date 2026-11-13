# ------------------------------------------------------------
# Run all four scripts in order.
# Recreates every graph in the output/ folder.
# ------------------------------------------------------------

source("scripts/01_gdp_1860_1929.R")
source("scripts/02_gdp_vs_uk.R")
source("scripts/03_fdi.R")
source("scripts/04_inflation.R")

message("Done! All four graphs are saved in the output/ folder.")
