# ------------------------------------------------------------
# Graph 2: Argentina's GDP per capita as a % of the UK's, 1930–2000
# Shaded bands mark three broad (simplified) policy periods
# Data: Maddison Project Database 2023 (via Our World in Data)
# Output: output/graph2_gdp_vs_uk_1930_2000.png
# ------------------------------------------------------------

library(tidyverse)
library(scales)

# --- 1. Load the data ---------------------------------------
arg_and_uk <- read_csv("data/arg_and_uk.csv")

# --- 2. Clean the data --------------------------------------
arg_uk_clean <- arg_and_uk %>%
  
  # Keep the two countries and the years we want
  filter(
    Entity %in% c("Argentina", "United Kingdom"),
    Year >= 1930,
    Year <= 2000
  ) %>%
  select(Entity, Year, `GDP per capita`) %>%
  
  # Put each country in its own column, one row per year
  pivot_wider(
    names_from = Entity,
    values_from = `GDP per capita`
  ) %>%
  
  # Argentina's GDP per capita as a percentage of the UK's
  mutate(
    gdp_relative_uk = (Argentina / `United Kingdom`) * 100
  )

# --- 3. Check the claim in the article ----------------------
# "Argentina's GDP per capita fell from approximately 75% of
#  Britain's in 1930 to around 40% by 2000"
arg_uk_clean %>%
  filter(Year %in% c(1930, 2000)) %>%
  select(Year, gdp_relative_uk)

# --- 4. The graph -------------------------------------------
graph2 <- ggplot(arg_uk_clean,
                 aes(x = Year, y = gdp_relative_uk)) +
  
  # Shaded policy periods (drawn first so they sit behind the line)
  
  # Import substitution
  annotate(
    "rect",
    xmin = 1930, xmax = 1976,
    ymin = -Inf, ymax = Inf,
    fill = "#E8DCC4",
    alpha = 0.35
  ) +
  
  # Financial liberalisation
  annotate(
    "rect",
    xmin = 1976, xmax = 1983,
    ymin = -Inf, ymax = Inf,
    fill = "#C7DDEB",
    alpha = 0.35
  ) +
  
  # Market reforms
  annotate(
    "rect",
    xmin = 1991, xmax = 2000,
    ymin = -Inf, ymax = Inf,
    fill = "#E8D3DF",
    alpha = 0.35
  ) +
  
  # Argentina's GDP relative to the UK
  geom_line(
    colour = "#0072B2",
    linewidth = 1.4
  ) +
  
  # Labels for the policy periods
  annotate(
    "text",
    x = 1953, y = 82,
    label = "Import\nsubstitution",
    size = 3.2,
    colour = "grey30"
  ) +
  
  annotate(
    "text",
    x = 1979.5, y = 82,
    label = "Financial\nliberalisation",
    size = 3,
    colour = "grey30"
  ) +
  
  annotate(
    "text",
    x = 1995.5, y = 82,
    label = "Market\nreforms",
    size = 3.2,
    colour = "grey30"
  ) +
  
  scale_x_continuous(
    breaks = seq(1930, 2000, by = 10)
  ) +
  
  scale_y_continuous(
    breaks = seq(30, 80, by = 10),
    labels = label_number(suffix = "%")
  ) +
  
  coord_cartesian(
    xlim = c(1930, 2000),
    ylim = c(30, 85)
  ) +
  
  labs(
    title = "Argentina's relative economic decline",
    subtitle = "GDP per capita as a percentage of the UK's, 1930–2000",
    x = NULL,
    y = "GDP per capita (% of UK)",
    caption = paste0(
      "Source: Maddison Project Database 2023, via Our World in Data.\n",
      "Note: The UK is used as a benchmark for comparison. ",
      "Changes reflect the performance of both economies.\n",
      "Shaded periods represent simplified policy classifications."
    )
  ) +
  
  theme_minimal(base_size = 12) +
  
  theme(
    plot.title = element_text(size = 17, face = "bold"),
    plot.subtitle = element_text(size = 11),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "none",
    axis.title.y = element_text(size = 11),
    
    # Longer caption: smaller, grey and left-aligned
    plot.caption = element_text(
      size = 9,
      colour = "grey45",
      hjust = 0,
      lineheight = 1.2
    )
  )

graph2

# --- 5. Save the graph --------------------------------------
ggsave("output/graph2_gdp_vs_uk_1930_2000.png", graph2,
       width = 9, height = 5.5, dpi = 300, bg = "white")