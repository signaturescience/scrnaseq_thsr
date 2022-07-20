# Alex Koeppel
# Signature Science
# 07/20/2022
# cr_summary.R: Combine the summary metrics for the alignments/counts into a single table.

#Load modules
library("tidyverse")

#List all samples
samp_list <- list.files("data/processed/cellranger")
#Remove test runs
samp_list <- samp_list[!str_detect(samp_list,"TEST")]

#Read in files to master table
metrics_df <- tibble()
for(samp in samp_list){
  samp_dat <- read_csv(here::here(paste0("data/processed/cellranger/",samp, "/outs/metrics_summary.csv"))) %>%
    mutate(sample = samp)
  metrics_df <- bind_rows(metrics_df, samp_dat)
}

#Write file
metrics_df %>%
  select(sample, everything()) %>%
  write_csv(here::here("data/processed","cell_ranger_metrics.csv"))

