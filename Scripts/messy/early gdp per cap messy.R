# read csv dataset
read.csv("~/R/Argentina Tribune project/Tribune/gdp per cap 1870-1929.csv")

# create a graph of gdp per capita over time for the countries in the dataset

# libraries first:
library(tidyverse)
library(scales)

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
  
  theme_minimal()
+
  theme(
    plot.title = element_text(size = 18, face = "bold"),
    plot.subtitle = element_text(size = 11),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.title = element_text(size = 11)
  )

