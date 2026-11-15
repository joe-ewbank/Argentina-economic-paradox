
# ------------------------------------------------------------
# Graph 3: Foreign direct investment, 2000–2025
# Argentina compared with Brazil, Chile and Mexico
# Data: World Bank, World Development Indicators
#       (indicator BX.KLT.DINV.WD.GD.ZS)
# Output: Output/graph3_fdi_2000_2025.png
# ------------------------------------------------------------

library(tidyverse)
library(scales)

# --- 1. Load the data ---------------------------------------
# The World Bank file has 4 lines of notes at the top, so skip them
fdi <- read_csv(
  "Data/API_BX.KLT.DINV.WD.GD.ZS_DS2_en_csv_v2_259843.csv",
  skip = 4
)

# --- 2. Clean the data --------------------------------------
fdi_clean <- fdi %>%
  
  # Keep the four countries we want
  filter(`Country Code` %in% c("ARG", "BRA", "CHL", "MEX")) %>%
  
  # Turn the year columns (2000, 2001, ...) into rows
  pivot_longer(
    cols = matches("^(19|20)[0-9]{2}$"),
    names_to = "Year",
    values_to = "FDI"
  ) %>%
  
  # Make sure Year and FDI are numbers, and tidy the column name
  mutate(
    Year = as.numeric(Year),
    FDI = as.numeric(FDI)
  ) %>%
  rename(Country = `Country Name`) %>%
  select(Country, Year, FDI) %>%
  
  # Keep 2000–2025
  filter(Year >= 2000, Year <= 2025)

# --- 3. The numbers quoted in the article -------------------
# Average FDI inflows (% of GDP) for each country, 2000–2025
fdi_clean %>%
  group_by(Country) %>%
  summarise(
    mean_fdi = mean(FDI, na.rm = TRUE),
    median_fdi = median(FDI, na.rm = TRUE),
    .groups = "drop"
  )

# How many years each country had the lowest inflows of the four
fdi_clean %>%
  filter(!is.na(FDI)) %>%
  group_by(Year) %>%
  filter(n_distinct(Country) == 4) %>%
  slice_min(FDI, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  count(Country)

# --- 4. The graph -------------------------------------------
graph3 <- ggplot(fdi_clean,
                 aes(x = Year, y = FDI, colour = Country)) +
  
  # Zero line (FDI can occasionally be negative)
  geom_hline(yintercept = 0, colour = "grey40", linewidth = 0.4) +
  
  # Other countries: thinner and slightly faded
  geom_line(
    data = fdi_clean %>% filter(Country != "Argentina"),
    linewidth = 0.8,
    alpha = 0.7
  ) +
  
  # Argentina highlighted
  geom_line(
    data = fdi_clean %>% filter(Country == "Argentina"),
    linewidth = 1.4
  ) +
  
  scale_colour_manual(
    values = c(
      "Argentina" = "#0072B2",  # Blue (highlight, same as other graphs)
      "Brazil"    = "#009E73",  # Green
      "Chile"     = "#E69F00",  # Golden yellow
      "Mexico"    = "#CC79A7"   # Pink
    ),
    breaks = c("Argentina", "Brazil", "Chile", "Mexico")  # Argentina first
  ) +
  
  scale_x_continuous(
    breaks = c(seq(2000, 2020, by = 5), 2025)
  ) +
  
  scale_y_continuous(
    labels = label_percent(scale = 1)
  ) +
  
  coord_cartesian(xlim = c(2000, 2025)) +
  
  labs(
    title = "The missing investment",
    subtitle = "Net foreign direct investment inflows (% of GDP), 2000–2025",
    x = NULL,
    y = "FDI inflows (% of GDP)",
    colour = NULL,
    caption = "Source: World Bank, World Development Indicators"
  ) +
  
  theme_minimal(base_size = 12) +
  
  theme(
    plot.title = element_text(size = 17, face = "bold"),
    plot.subtitle = element_text(size = 11),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "bottom",
    axis.title.y = element_text(size = 11)
  )

graph3

# --- 5. Save the graph --------------------------------------
ggsave("Output/graph3_fdi_2000_2025.png", graph3,
       width = 9, height = 5.5, dpi = 300, bg = "white")