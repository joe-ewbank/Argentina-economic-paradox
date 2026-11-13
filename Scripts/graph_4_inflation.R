# ------------------------------------------------------------
# Graph 4: Annual consumer price inflation, 2000–2025
# Argentina highlighted; Brazil, Chile and Uruguay in grey
# Data: IMF DataMapper export (downloaded 31 October 2026)
# Output: output/graph4_inflation_2000_2025.png
# ------------------------------------------------------------

library(tidyverse)
library(scales)
library(readxl)   # needed to open .xls files

# --- 1. Load the data ---------------------------------------
# The IMF file writes "no data" for missing years, so tell R
# to treat that as a blank (NA) rather than as text
inflation <- read_xls(
  "data/imf-dm-export-20261031.xls",
  na = c("no data", "")
)

# --- 2. Clean the data --------------------------------------
inflation_clean <- inflation %>%
  
  # The first column holds the country names, so call it Country
  rename(Country = 1) %>%
  
  # Turn the year columns (2000, 2001, ...) into rows
  pivot_longer(
    cols = matches("^(19|20)[0-9]{2}$"),
    names_to = "Year",
    values_to = "Inflation",
    values_transform = list(Inflation = as.character)
  ) %>%
  
  # Make sure Year and Inflation are numbers
  mutate(
    Year = as.numeric(Year),
    Inflation = as.numeric(Inflation)
  ) %>%
  
  # Keep the four countries and the years we want
  filter(
    Country %in% c("Argentina", "Brazil", "Chile", "Uruguay"),
    Year >= 2000,
    Year <= 2025
  )

# --- 3. Checks on the data ----------------------------------
# How many years of data each country has
inflation_clean %>%
  group_by(Country) %>%
  summarise(
    observations = sum(!is.na(Inflation)),
    first_year = min(Year[!is.na(Inflation)]),
    last_year = max(Year[!is.na(Inflation)])
  )

# Which years are missing for Argentina
# (the gap matches the period when the IMF censured Argentina
# over the quality of its official statistics)
inflation_clean %>%
  filter(Country == "Argentina", is.na(Inflation)) %>%
  select(Year)

# --- 4. Find Argentina's peak year --------------------------
# Worked out from the data, so the label updates itself
# if the data ever changes
peak <- inflation_clean %>%
  filter(Country == "Argentina") %>%
  slice_max(Inflation, n = 1, with_ties = FALSE)

peak   # shows the peak year and value (2024, 219.9%)

# --- 5. The graph -------------------------------------------
graph4 <- ggplot(inflation_clean,
                 aes(x = Year, y = Inflation, group = Country)) +
  
  # Other countries in grey
  geom_line(
    data = inflation_clean %>% filter(Country != "Argentina"),
    colour = "grey65",
    linewidth = 0.8,
    alpha = 0.7
  ) +
  
  # Argentina highlighted
  geom_line(
    data = inflation_clean %>% filter(Country == "Argentina"),
    colour = "#0072B2",
    linewidth = 1.4
  ) +
  
  # Dot on the peak
  geom_point(
    data = peak,
    colour = "#0072B2",
    size = 2.8
  ) +
  
  # Label next to the peak
  annotate(
    "text",
    x = peak$Year - 0.5,
    y = peak$Inflation + 5,
    label = paste0(peak$Year, " inflation peak (", peak$Inflation, "%)"),
    hjust = 1,
    size = 3.5,
    colour = "#0072B2"
  ) +
  
  scale_x_continuous(
    breaks = seq(2000, 2025, by = 5)
  ) +
  
  scale_y_continuous(
    breaks = seq(0, 250, by = 50),
    labels = label_percent(scale = 1)
  ) +
  
  coord_cartesian(
    xlim = c(2000, 2025),
    ylim = c(0, 240)
  ) +
  
  labs(
    title = "Argentina's inflation crisis",
    subtitle = "Annual consumer price inflation, 2000–2025",
    x = NULL,
    y = "Inflation (%)",
    caption = paste(
      "Source: IMF. Grey lines: Brazil, Chile and Uruguay.",
      "Gaps show years with no official IMF data for Argentina."
    )
  ) +
  
  theme_minimal(base_size = 12) +
  
  theme(
    plot.title = element_text(size = 17, face = "bold"),
    plot.subtitle = element_text(size = 11),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "none",
    axis.title.y = element_text(size = 11)
  )

graph4

# --- 6. Save the graph --------------------------------------
ggsave("output/graph4_inflation_2000_2025.png", graph4,
       width = 9, height = 5.5, dpi = 300, bg = "white")