library(tidyverse)
library(scales)

# Export/copy your original World Bank FDI CSV into data/fdi.csv.
# Expected columns include Country.Code and X2000, X2001, etc.
fdi <- read_csv("~/R/Argentina project/Tribune/FDI.csv", show_col_types = FALSE)

fdi <- read_csv(
  "~/R/Argentina project/Tribune/FDI.csv",
  skip = 1
)
# ---------------------------------
# 1. Clean the FDI data
# ---------------------------------

fdi_clean <- fdi %>%
  filter(Country.Code %in% c("ARG", "BRA", "CHL", "MEX")) %>%
  pivot_longer(
    cols = matches("^X20[0-9]{2}$"),
    names_to = "Year",
    values_to = "FDI"
  ) %>%
  mutate(
    Year = as.numeric(str_remove(Year, "X")),
    FDI = as.numeric(FDI)
  ) %>%
  filter(Year >= 2000, Year <= 2025)

# ---------------------------------
# 2. Create the graph
# ---------------------------------

fdi_plot <- ggplot(
  fdi_clean,
  aes(
    x = Year,
    y = FDI,
    colour = Country.Code,
    group = Country.Code
  )
) +
  
  # Argentina bold, other countries thinner
  geom_line(
    aes(linewidth = Country.Code == "ARG")
  ) +
  
  scale_linewidth_manual(
    values = c("TRUE" = 1.8, "FALSE" = 0.8),
    guide = "none"
  ) +
  
  # Same colour scheme as historical GDP
  scale_colour_manual(
    values = c(
      "ARG" = "#0072B2",
      "BRA" = "#7A9E50",
      "CHL" = "#C59A62",
      "MEX" = "#B49ACB"
    ),
    breaks = c("ARG", "BRA", "CHL", "MEX"),
    labels = c("Argentina", "Brazil", "Chile", "Mexico")
  ) +
  
  scale_x_continuous(
    breaks = seq(2000, 2025, by = 5)
  ) +
  
  scale_y_continuous(
    labels = label_number(suffix = "%")
  ) +
  
  labs(
    title = "Foreign investment in Latin America",
    subtitle = "Net FDI inflows as a share of GDP, 2000–2025",
    x = NULL,
    y = "FDI inflows (% of GDP)",
    colour = NULL,
    caption = "Source: World Bank"
  ) +
  
  theme_minimal(base_size = 12) +
  
  theme(
    plot.title = element_text(
      size = 17,
      face = "bold"
    ),
    plot.subtitle = element_text(
      size = 11,
      colour = "grey35"
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "bottom",
    legend.title = element_blank(),
    plot.caption = element_text(
      size = 9,
      colour = "grey45"
    ),
    axis.title.y = element_text(size = 10),
    plot.margin = margin(15, 20, 15, 15)
  )

# Display graph
fdi_plot

# ---------------------------------
# 3. Save the graph
# ---------------------------------

ggsave(
  "graphs/fdi_comparison.png",
  plot = fdi_plot,
  width = 9,
  height = 5,
  dpi = 300
)

# ---------------------------------
# 4. Calculate summary statistics
# ---------------------------------

fdi_summary <- fdi_clean %>%
  group_by(Country.Code) %>%
  summarise(
    mean_fdi = mean(FDI, na.rm = TRUE),
    median_fdi = median(FDI, na.rm = TRUE),
    .groups = "drop"
  )

print(fdi_summary)

# ---------------------------------
# 5. Which country had the lowest FDI?
# ---------------------------------

lowest_fdi <- fdi_clean %>%
  filter(!is.na(FDI)) %>%
  group_by(Year) %>%
  filter(n_distinct(Country.Code) == 4) %>%
  slice_min(FDI, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  count(Country.Code)

print(lowest_fdi)

names(fdi)
head(fdi)