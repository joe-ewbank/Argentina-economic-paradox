library(tidyverse)
library(scales)

# Place the original CSV in the project's data folder.
# The graph expects columns: Entity, Year, GDP per capita.
gdp_per_cap_1870_1929 <- read_csv("~/R/Argentina project/Tribune/gdp per cap 1870-1929.csv", show_col_types = FALSE)

ggplot(gdp_per_cap_1870_1929, aes(x = Year,
y = `GDP per capita`,
colour = Entity)) +
geom_line(
aes(linewidth = Entity == "Argentina")
) +
scale_linewidth_manual(
values = c("TRUE" = 2, "FALSE" = 0.8),
guide = "none"
) +
labs(
title = "GDP per capita (1870–1929)",
subtitle = "Argentina, France, Italy and Japan",
x = "Year",
y = "GDP per capita ($)",
colour = "Country",
caption = "Source: Maddison Project Database 2023"
) +
scale_y_continuous(
breaks = seq(0, 8000, by = 1000),
labels = dollar_format()
) +
scale_x_continuous(
breaks = c(seq(1870, 1920, by = 10), 1930)
) +
coord_cartesian(xlim = c(1870, 1930)) +
theme_minimal() +
theme(
plot.title = element_text(size = 18, face = "bold"),
plot.subtitle = element_text(size = 11),
panel.grid.minor = element_blank(),
legend.position = "bottom",
axis.title = element_text(size = 11)
)

# suggested cleaner graph, thicker blue line for arg and grey. added in spain too:

gdp_per_cap_1870_1929_with_spain <- read_csv("~/R/Argentina project/Tribune/gdp per cap 1870-1929.csv", show_col_types = FALSE)

library(tidyverse)
library(scales)

# Select the five countries
gdp_plot_data <- gdp_per_cap_1870_1929 %>%
  filter(
    Entity %in% c(
      "Argentina", "France", "Italy",
      "Japan", "Spain"
    ),
    Year >= 1870,
    Year <= 1929
  )

# Check that Spain is included
unique(gdp_plot_data$Entity)

# Create graph
gdp_plot <- ggplot(
  gdp_plot_data,
  aes(
    x = Year,
    y = `GDP per capita`,
    colour = Entity,
    group = Entity
  )
) +
  geom_line(
    aes(linewidth = Entity == "Argentina")
  ) +
  
  scale_linewidth_manual(
    values = c("TRUE" = 1.8, "FALSE" = 0.8),
    guide = "none"
  ) +
  
  scale_colour_manual(
    values = c(
      "Argentina" = "#0072B2",
      "France" = "#7A9E50",
      "Italy" = "#6B9DA8",
      "Japan" = "#B49ACB",
      "Spain" = "#C59A62"
    ),
    breaks = c(
      "Argentina", "France", "Italy",
      "Japan", "Spain"
    )
  ) +
  
  scale_y_continuous(
    labels = dollar_format(),
    breaks = seq(0, 8000, by = 1000)
  ) +
  
  scale_x_continuous(
    breaks = seq(1870, 1930, by = 10)
  ) +
  
  coord_cartesian(
    xlim = c(1870, 1929)
  ) +
  
  labs(
    title = "When Argentina was among\nthe world's richest",
    subtitle = "GDP per capita, 1870–1929",
    x = NULL,
    y = "GDP per capita",
    colour = NULL,
    caption = "Source: Maddison Project Database 2023"
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
    axis.title.y = element_text(size = 10)
  )

# Display
gdp_plot

# Save high-resolution version
ggsave(
  "graphs/historical_gdp.png",
  plot = gdp_plot,
  width = 9,
  height = 5,
  dpi = 300
)

ggsave(
  "graphs/historical_gdp.png",
  plot = gdp_plot,
  width = 11,
  height = 5.5,
  dpi = 300
)