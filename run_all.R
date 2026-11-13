# ------------------------------------------------------------
# Run all four scripts in order.
# Recreates every graph in the output/ folder.
# ------------------------------------------------------------

source("Scripts/graph_1_gdp_with_spain.R")
source("Scripts/graph_2_arg_and_uk.R")
source("Scripts/graph_3_fdi.R")
source("Scripts/graph_4_inflation.R")

message("Done! All four graphs are saved in the Output/ folder.")
  