#!/bin/bash

#Download data from Speranza et al. using SRA toolkit

#Install SRA toolkit
#pwd
#/data/home/akoeppel/software
# DOWNLOAD
# wget --output-document sratoolkit.tar.gz https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-centos_linux64.tar.gz
# EXTRACT
# tar -vxzf sratoolkit.tar.gz
# ADD TO PATH
# export PATH=$PATH:$PWD/sratoolkit.3.0.0-centos_linux64/bin
# TEST
# which fastq-dump
# ~/software/sratoolkit.3.0.0-centos_linux64/bin/fastq-dump

#Additional downloads
#Accession list file (SraAccList.txt) (downloaded from https://www.ncbi.nlm.nih.gov/sra?term=SRP278622)
#SRA Run Info (SraRunInfo.csv) (downloaded from https://www.ncbi.nlm.nih.gov/sra?linkname=bioproject_sra_all&from_uid=658976)

#Download data
#pwd
#/data/home/akoeppel/cag/projects/scrnaseq_thsr/data/raw
# Set prefetch to current directory
vdb-config --prefetch-to-cwd
#Prefetch all SRR numbers in accession list.
prefetch $(<SraAccList.txt)
#Dump fastq files from .sralite files. (included tech. reads until I'm certain they're not needed).
fasterq-dump --include-technical -S  $(<SraAccList.txt)
#Compress dumped fastq files
gzip *fastq

#Clean up
mkdir fastq
mkdir sra
mv *fastq.gz fastq
mv SRR* sra

#Confirm download integrity (read counts)
mkdir ctab
find * | grep sra | cut -f 2 -d "/" | sort | uniq | grep -v sra | parallel -j 20 --dry-run bioawk -t -c fastx \'END {print NR}\' fastq/{}_3.fastq.gz \> ctab/{}.txt
#bioawk -t -c fastx 'END {print NR}' fastq/SRR12507652_3.fastq.gz > ctab/SRR12507652.txt
#bioawk -t -c fastx 'END {print NR}' fastq/SRR12507653_3.fastq.gz > ctab/SRR12507653.txt
#bioawk -t -c fastx 'END {print NR}' fastq/SRR12507654_3.fastq.gz > ctab/SRR12507654.txt
#bioawk -t -c fastx 'END {print NR}' fastq/SRR12507655_3.fastq.gz > ctab/SRR12507655.txt
#bioawk -t -c fastx 'END {print NR}' fastq/SRR12507656_3.fastq.gz > ctab/SRR12507656.txt
#...
^--dry-run^^
#Put counts in table
SAMPLIST=$(find * | grep ctab | grep txt | cut -f 2 -d "/" | cut -f 1 -d ".")
for SAMP in $SAMPLIST
do
ID=$(echo $SAMP)
CT=$(cat ctab/${SAMP}.txt)
echo $ID $CT | sed -e "s/ /\t/g" >> fastq_ctable.txt
done
cat fastq_ctable.txt | sort -k1 > temp
mv temp fastq_ctable.txt
cat SraRunInfo.csv | grep -v spots | cut -f 1,4 -d "," | sed -e "s/,/\t/g" | sort -k 1 > info_counts.txt
#Check ID ordering
paste fastq_ctable.txt info_counts.txt | awk '$1!=$3{print $1,$2,$3,$4}'
#Check count match
paste fastq_ctable.txt info_counts.txt | awk '$2!=$4{print $1,$2,$3,$4}'
#No mismatches
