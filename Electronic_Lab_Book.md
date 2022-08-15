# Analyses

In the spirit of open and repeatable science, we provide the electronic lab book associated with this project. This serves as: 

1) A record of the decisions made during data processing and analysis

2) A clear guide to the analyses including links to data, scripts, and final figures and tables. 


## Analyses: 

1. Genome assembly
    
    1a. ST genome assembly
    
    1b. SR genome assembly
    
2. Genome annotation

3. Mapping Structural Variants

4. Mapping repeat elements




# 1. Genome assembly

## 1a. ST genome assembly

### Data

Two sets of HiFi reads were generated from pooled larvae which were inbred for X (IBD) but not the autosomes. Individuals were all female, thus we expect no difference in coverage between the X chromosome and autosomes. 


### HiFiasm

#### De novo assembly

Each set of raw reads was submitted to HiFiasm for de novo assembly using [HiFiasm_INPUT1](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/HiFiasm_INPUT1.sh) and [HiFiasm_INPUT2](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/HiFiasm_INPUT2.sh)


#### Checks




### Purge duplicates


#### purge duplicates


#### checks


### Assess final genome


#### Blobtools


## 1b. SR genome assembly


### Assess final genome

#### Checks






## 2. Genome annotation

### Data processing

Isoseq

### Pipeline

link to Sade's pipeline and paper


### Final genome figures, tables, and accession numbers. 



# 3. Map Structural variants

Pipeline

## Alignment


## Sniffles


## Filtering


## Machine learning approaches


## Re-sequencing


## Genes associated


## Age of inversions


Based on Ruff paper


# 4. Map repeat elements

## RepeatModeler


## Filter


## Final outputs







