# Alex Koeppel
# Signature Science
# 07/21/2022
# make_aggr_table.R: Set up table for aggregating samples using cellranger aggr.

#Load modules
library("tidyverse")

#Read in previous sample table
sra_df <- read_tsv(here::here("data/raw","sra_sample_data.tsv"))

#Aggr Table, linking sample to molecule_info.h5 file.
aggr <-
  sra_df %>%
    select(sample_id = sample, tissue) %>%
    distinct() %>%
    mutate(molecule_h5=paste0(here::here("data/processed/cellranger/"),sample_id,"/outs/molecule_info.h5"))


#Write out lung table.
aggr %>%
  filter(tissue=="Lung") %>%
  select(-tissue) %>%
  write_csv(here::here("data/processed","lung_aggr.csv"))

#Write out Medialstinal Lymph Node table.
aggr %>%
  filter(tissue=="Medialstinal Lymph Node") %>%
  select(-tissue) %>%
  write_csv(here::here("data/processed","mln_aggr.csv"))
