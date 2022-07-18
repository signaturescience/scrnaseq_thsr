#!/bin/bash

# Code for building Cell Ranger reference.
# This is a combined reference file that includes both the African Green Monkey
# and the COVID reference genomes.

#Download *Chlorocebus sabaeus* (African Green Monkey) reference genome (ChlSab1.1) FASTA
wget http://ftp.ensembl.org/pub/release-107/fasta/chlorocebus_sabaeus/dna/Chlorocebus_sabaeus.ChlSab1.1.dna_rm.toplevel.fa.gz
#Download *Chlorocebus sabaeus* (African Green Monkey) reference genome (ChlSab1.1) Annotation GTF
wget http://ftp.ensembl.org/pub/release-107/gtf/chlorocebus_sabaeus/Chlorocebus_sabaeus.ChlSab1.1.107.gtf.gz

build="ChlSab1_107_build"
mkdir -p "$build"
source="reference_sources"
mkdir -p "$source"
mv Chlorocebus_sabaeus.ChlSab1.1.* reference_sources/
fasta_in="reference_sources/Chlorocebus_sabaeus.ChlSab1.1.dna_rm.toplevel.fa.gz"

#Modify FASTA per instructions at https://support.10xgenomics.com/single-cell-gene-expression/software/release-notes/build#grch38_#{files.refdata_GRCh38.version}

#Skip the modification step (chr already match GTF) but still unzip.
monkey_fasta="$build/Chlorocebus_sabaeus.ChlSab1.1.dna_rm.toplevel.fa"
zcat "$fasta_in"> "$monkey_fasta"
#GTF Filtering
BIOTYPE_PATTERN=\
"(protein_coding|lncRNA|\
IG_C_gene|IG_D_gene|IG_J_gene|IG_LV_gene|IG_V_gene|\
IG_V_pseudogene|IG_J_pseudogene|IG_C_pseudogene|\
TR_C_gene|TR_D_gene|TR_J_gene|TR_V_gene|\
TR_V_pseudogene|TR_J_pseudogene)"
GENE_PATTERN="gene_biotype \"${BIOTYPE_PATTERN}\""
TX_PATTERN="transcript_biotype \"${BIOTYPE_PATTERN}\""
zcat reference_sources/Chlorocebus_sabaeus.ChlSab1.1.107.gtf.gz | awk '$3 == "transcript"' | grep -E "$GENE_PATTERN" | grep -E "$TX_PATTERN" | cut -f 9 | cut -f 1 -d ";" | cut -f 2 -d " " | sed -e "s/\"//g" | sort | uniq > "${build}/gene_allowlist"
monkey_gtf="$build/Chlorocebus_sabaeus.ChlSab1.1.107.gtf"
zcat reference_sources/Chlorocebus_sabaeus.ChlSab1.1.107.gtf.gz | grep -E "^#" > $monkey_gtf
zcat reference_sources/Chlorocebus_sabaeus.ChlSab1.1.107.gtf.gz | grep -Ff "${build}/gene_allowlist" >> "$monkey_gtf"

#Add SARS-CoV-2 genomic info:
FASTA and GTF downloaded from : git@github.com:broadinstitute/rna_seq_sars_cov_2.git
covid_fasta="reference_sources/SARSCoV2.fa"
covid_gtf="reference_sources/SARSCoV2.gtf"

# Create reference package
# Following instruction for multi-genome referece at:
#    https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/advanced/references#multi
genome="ChlSab1.1"
cellranger mkref --genome="$genome" --fasta="$monkey_fasta" --genes="$monkey_gtf" --genome="SARS_CoV2" --fasta="$covid_fasta" --genes="$covid_gtf"  



#DEFUNCT CODE - COVID REF IN BAD FORMAT
#FASTA downloaded from: https://www.ncbi.nlm.nih.gov/nuccore/1798174254
# GFF3 downloaded from: https://www.ncbi.nlm.nih.gov/nuccore/NC_045512.2
#covid_fasta="reference_sources/SARS_CoV2_NC_045512.2.fa"
#cat reference_sources/SARS_CoV2_NC_045512.2.gff | awk '$3 == "gene"' > reference_sources/SARS_CoV2_NC_045512.2.gtf
#covid_gtf="reference_sources/SARS_CoV2_NC_045512.2.gtf"
