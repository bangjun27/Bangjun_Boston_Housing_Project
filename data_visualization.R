library(tidyverse)
library(plotly)
library(corrplot)
library(knitr)
houseprice <- read.csv("Boston-house-price-data.csv")
head(houseprice)

#Descriptive statistics
desc_stats <- houseprice %>%
  summarise(across(
    everything(),
    list(
      Mean = ~mean(.),
      SD = ~sd(.),
      Min = ~min(.),
      Median = ~median(.),
      Max = ~max(.)
    )
  )) %>%
  pivot_longer(
    cols = everything(),
    names_to = c("Variable", "Statistic"),
    names_sep = "_",
    values_to = "Value"
  ) %>%
  pivot_wider(
    names_from = Statistic,
    values_from = Value
  ) %>%
  mutate(across(where(is.numeric), round, 2))
desc_stats

kable(desc_stats, format = "markdown")

summary(houseprice$MEDV)

# Distribution of House Prices
pricep <- ggplot(houseprice, aes(x = MEDV)) +
  geom_histogram(bins = 30, fill = "skyblue", color = "white") +
  labs(title = "Distribution of House Prices",
       x = "Median House Value ($1000)",
       y = "Count") +
  theme(plot.title = element_text(hjust = 0.5))
ggsave("figures/medv_distribution.png", plot = pricep, width = 6, height = 5)
ggplotly(pricep)

# Distribution of Charles River Dummy Variabl
chas_count <- houseprice %>%
  count(CHAS) %>%
  mutate(
    CHAS_Label = ifelse(CHAS == 1, "Bounds Charles River", "Does Not Bound Charles River"),
    Percentage = n / sum(n) * 100
  )
chas_plot <- ggplot(chas_count, aes(x = "", y = n, fill = CHAS_Label)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  geom_text(
    aes(label = paste0(round(Percentage, 1), "%")),
    position = position_stack(vjust = 0.5)
  ) +
  labs(
    title = "Distribution of Charles River Dummy Variable",
    fill = "CHAS"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5)
  )
ggsave("figures/chas_pie_chart.png",plot = chas_plot,width = 6,height = 4)

#Correlation
png("figures/correlation_heatmap.png", width = 1000, height = 800, res = 120)

corrplot(
  cor_matrix,
  method = "color",
  type = "upper",
  tl.cex = 0.8,
  addCoef.col = "black",
  number.cex = 0.6,
  mar = c(0, 0, 2, 0)
)
title("Correlation Heatmap", line = 0.5, cex.main = 1.5)

dev.off()

#Relationship between Variables and House Prices
houseprice_long <- houseprice %>%
  pivot_longer(
    cols = -MEDV,
    names_to = "Variable",
    values_to = "Value"
  )
ggplot(houseprice_long, aes(x = Value, y = MEDV)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  facet_wrap(~ Variable, scales = "free_x") +
  labs(
    title = "Relationship between Variables and House Prices",
    x = "Variable Value",
    y = "Median House Value (in $1000s)"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5),
    strip.text = element_text(face = "bold")
  )
ggsave("figures/all_variables_vs_medv.png",width = 12,height = 8)
