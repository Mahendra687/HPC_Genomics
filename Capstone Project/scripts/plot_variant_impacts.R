args <- commandArgs(trailingOnly = TRUE)
input_file <- normalizePath(args[1])
output_html <- normalizePath(args[2], mustWork = FALSE)

# Create output directory structure
output_dir <- dirname(output_html)
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE, showWarnings = TRUE)
}

library(readr)
library(dplyr)
library(ggplot2)
library(rmarkdown)

# Create plot directory within output
plot_dir <- file.path(output_dir, "plots")
dir.create(plot_dir, showWarnings = FALSE)

# Read and process data
data <- read_csv(input_file)

# Generate plot
p <- ggplot(data, aes(x = Sample, y = Count, fill = IMPACT)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Variant Impact Summary")

# Save plot
plot_file <- file.path(plot_dir, "variant_impacts.png")
ggsave(plot_file, plot = p, width = 10, height = 6, dpi = 300)

# Render report
render(
  input = "scripts/variant_report.Rmd",
  output_file = basename(output_html),
  output_dir = output_dir,
  params = list(
    data_path = input_file,
    plot_path = plot_file
  ),
  clean = TRUE
)
