# ------------------------------------------------------------
# Graph 1: GDP per capita, 1860–1929
# Argentina compared with Spain, France, Italy and Japan
# Data: Maddison Project Database 2023 (via Our World in Data)
# Output: output/graph1_gdp_1860_1929.png
# ------------------------------------------------------------

library(tidyverse)
library(scales)

# --- 1. Load the data ---------------------------------------
gdp <- read_csv("data/gdp-per-capita-with-spain-1860-1929.csv")

# --- 2. Clean the data --------------------------------------
gdp_clean <- gdp %>%
  
  # Keep the five countries and the years we want
  filter(
    Entity %in% c("Argentina", "Spain", "France", "Italy", "Japan"),
    Year >= 1860,
    Year <= 1929
  ) %>%
  
  # Give the columns simpler names
  rename(
    Country = Entity,
    GDP = `GDP per capita`
  )

# --- 3. Check the claim in the article ----------------------
# "In 1913, Argentina's GDP per capita exceeded that of
#  France, Italy and Japan"
gdp_clean %>%
  filter(Year == 1913) %>%
  select(Country, GDP) %>%
  arrange(desc(GDP))

# --- 4. The graph -------------------------------------------
graph1 <- ggplot(gdp_clean,
                 aes(x = Year, y = GDP, colour = Country)) +
  
  # Other countries: thinner and slightly faded
  geom_line(
    data = gdp_clean %>% filter(Country != "Argentina"),
    linewidth = 0.8,
    alpha = 0.7
  ) +
  
  # Argentina highlighted
  geom_line(
    data = gdp_clean %>% filter(Country == "Argentina"),
    linewidth = 1.4
  ) +
  
  scale_colour_manual(
    values = c(
      "Argentina" = "#0072B2",  # Blue (highlight, same as other graphs)
      "Spain"     = "#009E73",  # Green
      "France"    = "#D55E00",  # Orange
      "Italy"     = "#CC79A7",  # Pink
      "Japan"     = "#E69F00"   # Golden yellow
    ),
    breaks = c("Argentina", "Spain", "France", "Italy", "Japan")  # Argentina first
  ) +
  
  scale_x_continuous(
    breaks = c(seq(1860, 1920, by = 10), 1929)
  ) +
  
  scale_y_continuous(
    breaks = seq(0, 8000, by = 1000),
    labels = label_dollar()
  ) +
  
  coord_cartesian(xlim = c(1860, 1929)) +
  
  labs(
    title = "When Argentina was among the world's richest",
    subtitle = "GDP per capita, 1860–1929 (international dollars, 2011 prices)",
    x = NULL,
    y = "GDP per capita",
    colour = NULL,
    caption = "Source: Maddison Project Database 2023, via Our World in Data"
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

graph1

# --- 5. Save the graph --------------------------------------
ggsave("output/graph1_gdp_1860_1929.png", graph1,
       width = 9, height = 5.5, dpi = 300, bg = "white")