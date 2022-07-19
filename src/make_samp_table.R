# Alex Koeppel
# Signature Science
# 07/19/2022
# make_samp_table.R: Using the SRA Run Info csv file, and the information from GEO
#                     set up a sample table.

#Load modules
library("tidyverse")
library("rsnps")

# Load SRA data
sra_dat <- read_csv(here::here("data/raw","SraRunInfo.csv"))

#Select only the needed columns
sra_df <-
  sra_dat %>%
  select(run=Run, reads=spots, sample=SampleName) %>%
  mutate(type = case_when(
    sample == "GSM4743527" ~ "AGM1_Lung",
    sample == "GSM4743528" ~ "AGM2_Lung",
    sample == "GSM4743529" ~ "AGM3_Lung",
    sample == "GSM4743530" ~ "AGM4_Lung",
    sample == "GSM4743531" ~ "AGM5_Lung",
    sample == "GSM4743532" ~ "AGM6_Lung",
    sample == "GSM4743533" ~ "AGM7_Lung",
    sample == "GSM4743534" ~ "AGM8_Lung",
    sample == "GSM4743535" ~ "AGM9_Lung",
    sample == "GSM4743536" ~ "AGM10_Lung",
    sample == "GSM4743537" ~ "AGM1_Medialstinal Lymph Node",
    sample == "GSM4743538" ~ "AGM2_Medialstinal Lymph Node",
    sample == "GSM4743539" ~ "AGM3_Medialstinal Lymph Node",
    sample == "GSM4743540" ~ "AGM4_Medialstinal Lymph Node",
    sample == "GSM4743541" ~ "AGM5_Medialstinal Lymph Node",
    sample == "GSM4743542" ~ "AGM6_Medialstinal Lymph Node",
    sample == "GSM4743543" ~ "AGM7_Medialstinal Lymph Node",
    sample == "GSM4743544" ~ "AGM8_Medialstinal Lymph Node",
    sample == "GSM4743545" ~ "AGM9_Medialstinal Lymph Node",
    sample == "GSM4743546" ~ "AGM10_Medialstinal Lymph Node",
    TRUE ~ "NA"
  )) %>%
  separate(type, into=c("monkey","tissue"), sep="_")

#Write to file
sra_df %>%
  write_tsv(here::here("data/raw","sra_sample_data.tsv"))

