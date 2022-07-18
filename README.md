README
================

# Single-cell RNAseq

Single-cell RNA sequencing (scRNAseq) is a relatively new technology
that allows investigators to extract and analyze genome-wide
transcriptome data at the level of the individual cell. The technique
has grown rapidly in popularity in recent years due to its advantages
over more traditional transcriptomic analysis methods such as bulk
RNAseq. Principal among these advantages is the ability to analyze
individual cells in the context of their specific environment, allowing
the identification of novel cell types from gene expression profiles,
and the detection of differential gene expression between specific
subpopulations of cells (e.g. tumor and normal cells from the same
tissue).

# Objective

Given the rapid growth of the scRNAseq field, the SigSci bioinformatics
team should build capacity in this area, both to expand our ability to
respond to funding opportunities, and to enable rapid affirmative
response to inquiries from potential clients.

Our objective is to replicate the bioinformatics steps of an existing
scRNAseq analysis using a publicly available dataset. This will give us
an entry point for becoming experts the state-of-the-art software
toolset that exists in this field, and enhancing our understanding of
the underlying study designs and tatistical analyses necessary to avoid
common pitfalls and successfully perform meaningful scRNAseq analyses.

## Analysis replicated

We intend to replicate the scRNAseq analysis described in [Speranza *et
al.*](https://www.science.org/doi/full/10.1126/scitranslmed.abe8146)
which uses scRNAseq to identify the specific cell types in which most
SARS-CoV-2 replication was occurring in the lungs of African Green
Monkeys. This specific paper has the advantages of being recent,
topically relevant, containing a detailed methods section, and a
publicly available dataset.  
This THSR will support the development of bioinformatics knowledge and
tool expertise in the scRNAseq domain, building SicSci’s capacity to
cogently discuss, explain, and perform analyses to prospective clients
in a rapidly expanding subfield of genomics and bioinformatics.

## Analysis steps

1.  Retrieve the data used in the Speranza et al. analysis from
    [GEO](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE156755).
2.  Conduct a documentation review of the bioinformatics tools utilized
    in the original analysis, and research potential alternatives based
    on developments in the field. This step will also include a review
    of statistical approaches to clustering cell types, including PCA,
    UMAP, and t-SNE.
3.  Demultiplex samples, align reads, and generate counts, using
    [CellRanger](https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/what-is-cell-ranger)
    as in the original analysis. Data files at various stages are
    available on GEO which could obviate the need for some of these
    steps, particularly demultiplexing, should problems arise. However,
    to the extent possible we would like to start from raw data.  
4.  Import the count table into
    [Seurat](https://github.com/satijalab/seurat/), an R package for
    scRNAseq analysis , and use the functions of that package to
    integrate samples, quality filter, and de-duplicate the data
    following the original analysis.
5.  Perform PCA and UMAP clustering and analyze differential gene
    expression between cell types. Generate visualizations.
6.  If time allows, experiment with alternative software
    tools/algorithms and compare results.  
7.  Write a short whitepaper describing analysis

# Procedures Summary

## Software installation

All software installed to darwin server.

### SRA Toolkit Install (v3.0.0)

Used for downloading the data and dumping to FASTQ format.

    #Install SRA toolkit
    # DOWNLOAD
    wget --output-document sratoolkit.tar.gz https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-centos_linux64.tar.gz
    # EXTRACT
    tar -vxzf sratoolkit.tar.gz
    # ADD TO PATH
    export PATH=$PATH:$PWD/sratoolkit.3.0.0-centos_linux64/bin
    # TEST
    which fastq-dump
    # ~/software/sratoolkit.3.0.0-centos_linux64/bin/fastq-dump

### Bioawk

Used for checks on the downloaded FASTQ files.

    conda install -c bioconda bioawk

### Seurat

Seurat is an R package for scRNAseq analysis. Because the current
version (Seurat 4.1.1) is only compatible with R 4.0 or greater, we rand
into a compatibility issue with the darwin server’s R install (R
v3.6.0).

## Data acquisition

-   Data files for Sperenza *et al.* SRA project SRP278622 were
    downloaded using SRA Toolkit v3.0.0, using the `prefetch` and
    `fasterq-dump` commands (see [get\_data.sh](./data/raw/get_data.sh))
-   SRA accession list (for batch download), downloaded from: [SRA
    Project Page -
    SRP278622](https://www.ncbi.nlm.nih.gov/sra?term=SRP278622)
-   SRA Run Info (file/run metadata) downloaded from [SRA Experiment
    link for Project -
    PRJNA658976](https://www.ncbi.nlm.nih.gov/sra?linkname=bioproject_sra_all&from_uid=658976)
