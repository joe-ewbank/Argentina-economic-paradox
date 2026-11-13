# import dataset

fdi <- read.csv("~/R/Tribune/API_BX.KLT.DINV.WD.GD.ZS_DS2_en_csv_v2_259843.csv", skip = 4)

library(tidyverse)

fdi_clean <- fdi %>%
  filter(Country.Code %in% c("ARG", "BRA", "CHL", "MEX"))

fdi_clean <- fdi_clean %>%
  pivot_longer(
    cols = starts_with("X20"),
    names_to = "Year",
    values_to = "FDI"
  ) %>%
  mutate(
    Year = as.numeric(str_remove(Year, "X")),
    FDI = as.numeric(FDI)
  ) %>%
  filter(Year >= 2000, Year <= 2025)

ggplot(fdi_clean,
       aes(x = Year, y = FDI, colour = Country.Code)) +
  
  geom_line(linewidth = 1.2) +
  
  scale_colour_manual(
    values = c(
      "ARG" = "#0072B2",
      "BRA" = "#009E73",
      "CHL" = "#E69F00",
      "MEX" = "#CC79A7"
    ),
    labels = c(
      "ARG" = "Argentina",
      "BRA" = "Brazil",
      "CHL" = "Chile",
      "MEX" = "Mexico"
    )
  ) +
  
  scale_x_continuous(
    breaks = c(seq(2000, 2020, by = 5), 2025)
  ) +
  
  labs(
    title = "Foreign direct investment in Latin America",
    subtitle = "Net FDI inflows (% of GDP), 2000–2025",
    x = "Year",
    y = "FDI inflows (% of GDP)",
    colour = "Country",
    caption = "Source: World Bank"
  ) +
  
  theme_minimal() +
  
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

fdi_clean %>%
  group_by(Country.Code) %>%
  summarise(
    mean_fdi = mean(FDI, na.rm = TRUE),
    median_fdi = median(FDI, na.rm = TRUE),
    .groups = "drop"
  )

fdi_clean %>%
  filter(!is.na(FDI)) %>%
  group_by(Year) %>%
  filter(n_distinct(Country.Code) == 4) %>%
  slice_min(FDI, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  count(Country.Code)

# Inflation graph

#import inflation dataset:
inflation <- read_xls("~/R/Tribune/imf-dm-export-20261031.xls")

library(tidyverse)

inflation_clean <- inflation %>%
  
  # Rename the first column to Country
  rename(Country = 1) %>%
  
  # Convert all year columns into rows
  pivot_longer(
    cols = matches("^(19|20)[0-9]{2}$"),
    names_to = "Year",
    values_to = "Inflation",
    values_transform = list(Inflation = as.character)
  ) %>%
  
  # Convert to numeric values
  mutate(
    Year = as.numeric(Year),
    Inflation = as.numeric(Inflation)
  ) %>%
  
  # Keep the countries and years we want
  filter(
    Country %in% c("Argentina", "Brazil", "Chile", "Uruguay"),
    Year >= 2000,
    Year <= 2025
  )

names(inflation_clean)

unique(inflation_clean$Country)

inflation_clean %>%
  group_by(Country) %>%
  summarise(
    observations = sum(!is.na(Inflation)),
    first_year = min(Year[!is.na(Inflation)], na.rm = TRUE),
    last_year = max(Year[!is.na(Inflation)], na.rm = TRUE)
  )

ggplot(inflation_clean,
       aes(x = Year, y = Inflation, colour = Country)) +
  
  geom_line(linewidth = 1.1) +
  
  scale_colour_manual(values = c(
    "Argentina" = "#0072B2",
    "Brazil" = "#009E73",
    "Chile" = "#E69F00",
    "Uruguay" = "#CC79A7"
  )) +
  
  scale_x_continuous(
    breaks = seq(2000, 2025, by = 5)
  ) +
  
  labs(
    title = "Inflation in Latin America",
    subtitle = "Annual consumer price inflation, 2000–2025",
    x = "Year",
    y = "Inflation (%)",
    colour = "Country",
    caption = "Source: IMF"
  ) +
 
   # Label the peak
  annotate(
    "text",
    x = 2023.5,
    y = 225,
    label = "2024 inflation peak (219.9%)",
    hjust = 1,
    size = 3.5,
    colour = "#0072B2"
  ) +
  
  theme_minimal() +
  
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

# investigate the missing data:
inflation_clean %>%
  filter(Country == "Argentina",
         Year >= 2010,
         Year <= 2018) %>%
  select(Year, Inflation)

# cleaner graph, with argentina highlighted:
library(tidyverse)
library(scales)

ggplot(inflation_clean,
       aes(x = Year, y = Inflation,
           group = Country)) +
  
  # Other countries in grey
  geom_line(
    data = inflation_clean %>%
      filter(Country != "Argentina"),
    colour = "grey65",
    linewidth = 0.8,
    alpha = 0.7
  ) +
  
  # Argentina highlighted
  geom_line(
    data = inflation_clean %>%
      filter(Country == "Argentina"),
    colour = "#0072B2",
    linewidth = 1.4
  ) +
  
  # Highlight the 2024 peak
  geom_point(
    data = inflation_clean %>%
      filter(Country == "Argentina", Year == 2024),
    colour = "#0072B2",
    size = 2.8
  ) +
  
  # Label the peak
  annotate(
    "text",
    x = 2023.5,
    y = 225,
    label = "2024 inflation peak (219.9%)",
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
    title = "Argentina's inflation problem",
    subtitle = "Annual consumer price inflation, 2000–2025",
    x = NULL,
    y = "Inflation (%)",
    caption = "Source: IMF. Grey lines: Brazil, Chile and Uruguay."
  ) +
  
  theme_minimal(base_size = 12) +
  
  theme(
    plot.title = element_text(
      size = 17, face = "bold"
    ),
    plot.subtitle = element_text(size = 11),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "none",
    axis.title.y = element_text(size = 11)
  )

# our world in data graph:
new_inflation <- read.csv("~/R/Tribune/inflation-of-consumer-prices.csv")

ggplot(inflation_of_consumer_prices,
       aes(x = Year,
           y = `Inflation, consumer prices (annual %)`)) +
  
  # Other countries: thin, lighter lines
  geom_line(
    data = inflation_of_consumer_prices %>%
      filter(Entity != "Argentina"),
    aes(colour = Entity, group = Entity),
    linewidth = 0.8,
    alpha = 0.7
  ) +
  
  # Argentina: bold, dark-blue line
  geom_line(
    data = inflation_of_consumer_prices %>%
      filter(Entity == "Argentina"),
    aes(colour = Entity),
    linewidth = 1.8
  ) +
  
  # Country colours
  scale_colour_manual(
    values = c(
      "Argentina" = "#003B73",
      "Brazil" = "#009E73",
      "Chile" = "#E69F00",
      "Uruguay" = "#CC79A7"
    ),
    breaks = c("Argentina", "Brazil", "Chile", "Uruguay")
  ) +
  
  scale_x_continuous(
    breaks = 2018:2024
  ) +
  
  scale_y_continuous(
    breaks = seq(0, 250, by = 50),
    labels = label_percent(scale = 1)
  ) +
  
  coord_cartesian(
    xlim = c(2018, 2024),
    ylim = c(0, 240)
  ) +
  
  labs(
    title = "Argentina's inflation crisis",
    subtitle = "Annual consumer price inflation, 2018–2024",
    x = NULL,
    y = "Inflation (%)",
    colour = NULL,
    caption = "Source: International Monetary Fund (IMF) International Financial Statistics, via World Bank (2026)"
  ) +
  
  theme_minimal(base_size = 12) +
  
  theme(
    plot.title = element_text(size = 18, face = "bold"),
    plot.subtitle = element_text(size = 11),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "bottom",
    axis.title.y = element_text(size = 11)
  ) +
  annotate(tate(
      "text",
      x = 2023.7,
      y = 230,
      label = "2024: 220%",
      hjust = 1,
      size = 3.5,
      colour = "#003B73"
    )
    
# Lets try this FDI graph again:

# ------------------------------------------------------------
# Graph 3: Foreign direct investment, 2000–2025
# Argentina compared with Brazil, Chile and Mexico
# Data: World Bank, World Development Indicators
#       (indicator BX.KLT.DINV.WD.GD.ZS)
# Output: output/graph3_fdi_2000_2025.png
# ------------------------------------------------------------

library(tidyverse)
library(scales)

# --- 1. Load the data ---------------------------------------
# The World Bank file has 4 lines of notes at the top, so skip them
fdi <- read_csv(
  "data/API_BX.KLT.DINV.WD.GD.ZS_DS2_en_csv_v2_259843.csv",
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
ggsave("output/graph3_fdi_2000_2025.png", graph3,
       width = 9, height = 5.5, dpi = 300, bg = "white")

