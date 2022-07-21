#!/bin/bash

#Script to show code/steps for preparing the data for cell-ranger, and running the alignments
# and counts.

#Set working directory
WDIR="/data/home/akoeppel/cag/projects/scrnaseq_thsr"

#Per https://kb.10xgenomics.com/hc/en-us/articles/115003802691-How-do-I-prepare-Sequence-Read-Archive-SRA-data-from-NCBI-for-Cell-Ranger-
# Fastq files must follow a specific naming convention to be read in by Cell Ranger.
# e.g.
#incompatible file name: SRR9291388_1.fastq.gz
#compatible file name: SRR9291388_S1_L001_R1_001.fastq.gz
# Based on the read lengths, the 3 files dumped from the SRA for each run were:
#  _1:  8bp -> I1
#  _2: 28bp -> R1
#  _3: 91bp -> R2
# Only R1 and R1 are required, the index read is optional, but we will keep it.
# Since we have 20 samples, with either 8 or 12 fastq files per sample, we will
# create separate directories for each sample.
# We will do this with the help of the sample table created using make_samp_table.R (sra_sample_data.tsv)

#Set up directories
mkdir -p $WDIR/data/processed/fastq
#Make a list of samples
SAMPLIST=$(cat $WDIR/data/raw/sra_sample_data.tsv | cut -f 3 | sort | uniq | grep -v sample)
for SAMP in $SAMPLIST
do
SAMPDIR="${WDIR}/data/processed/fastq/${SAMP}"
mkdir $SAMPDIR
RUNLIST=$(cat $WDIR/data/raw/sra_sample_data.tsv | grep $SAMP | cut -f 1)
for RUN in $RUNLIST
do
cp $WDIR/data/raw/fastq/${RUN}_1.fastq.gz $SAMPDIR/${RUN}_S1_L001_I1_001.fastq.gz
cp $WDIR/data/raw/fastq/${RUN}_2.fastq.gz $SAMPDIR/${RUN}_S1_L001_R1_001.fastq.gz
cp $WDIR/data/raw/fastq/${RUN}_3.fastq.gz $SAMPDIR/${RUN}_S1_L001_R2_001.fastq.gz
done
done

#Cell Ranger count test run
#This will confirm whether our reads and reference files are set up correctly
# If it works, and looks good, I'll proceed with the other samples.
TESTFQS="$WDIR/data/processed/fastq/GSM4743527"
REF="/data/projects/cag/users/akoeppel/reference_genomes/ChlSab1.1_and_SARS_CoV2"
mkdir $WDIR/data/processed/cellranger
cd $WDIR/data/processed/cellranger
#Run Cellranger
cellranger count --id=TEST1 --fastqs=${TESTFQS} --sample=SRR12507652 --transcriptome=$REF --localmem 600
#This run appears to have been at least nominally successful.  Test with multi-sample run
cellranger count --id=TEST2 --fastqs=${TESTFQS} --sample=SRR12507652,SRR12507653 --transcriptome=$REF --localmem 600

#Run for all samples
#PWD must be $WDIR/data/processed/cellranger
for SAMP in $SAMPLIST
do
SAMPFQ="$WDIR/data/processed/fastq/$SAMP"
RUNLIST=$(cat $WDIR/data/raw/sra_sample_data.tsv | grep $SAMP | cut -f 1 | tr "\n" "," | sed -e "s/,$//g")
cellranger count --id=$SAMP --fastqs=${SAMPFQ} --sample=$RUNLIST --transcriptome=$REF --localmem 600
done

#Aggregate the samples by tissue type using cellranger aggr
#RUN AFTER RUNNING make_aggr_table.R.  Table linking samples to file paths is required.
cellranger aggr --id Lung --csv $WDIR/data/processed/lung_aggr.csv
cellranger aggr --id MediLymphNode --csv $WDIR/data/processed/mln_aggr.csv

#Given the differences in the custom reference, we don't expect a perfect match,
#But let's do some sanity checking against the original analysis counts vs. our counts.
#zcat $WDIR/data/processed/cellranger/GSM4743546/outs/filtered_feature_bc_matrix/matrix.mtx.gz | wc -l
#3826862
#zcat $WDIR/data/processed/cellranger/GSM4743546/outs/filtered_feature_bc_matrix/features.tsv.gz | wc -l
#19194
#zcat ../../raw/sperenza_counts/16451_filtered_feature_bc_matrix/matrix.mtx.gz | wc -l
#4049089
#zcat ../../raw/sperenza_counts/16451_filtered_feature_bc_matrix/features.tsv.gz | wc -l
#19176


