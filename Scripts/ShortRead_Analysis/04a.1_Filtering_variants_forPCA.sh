#!/bin/bash
#$ -S /bin/bash
#$ -N SR_FilterSNPs  ##job name
#$ -l tmem=16G #RAM
#$ -l h_vmem=16G #enforced limit on shell memory usage
#$ -l h_rt=5:00:00 ##wall time.  
#$ -j y  #concatenates error and output files (with prefix job1)
#$ -t 1-3

#Filter for PCA analysis
#bcf.names is file with one chromosome name per line


#Run on working directory
cd $SGE_O_WORKDIR 

##Software

export PATH=/share/apps/genomics/bcftools-1.15/bin:$PATH

#Define variables
INPUT=/SAN/ugi/StalkieGenomics/ShortRead_Analysis/Mapped/FINISHED/Variant_calling_SR

#Set up ARRAY job for three bcf files (one for each chromosome)
NAME=$(sed "${SGE_TASK_ID}q;d" bcf.names)


## 1. Stats for the raw bcf files

bcftools stats ${NAME} > ${NAME}.raw.stats

## 2. Filter by quality and minimum depth per sample

bcftools filter -Ob -i 'FMT/DP>10 & FMT/GQ>20' {NAME} -o ${NAME}_DP10GQ20.bcf

## 3. Get missingness per individual, and per site
vcftools --bcf ${NAME}_DP10GQ20.bcf --missing-indv > ${NAME}_DP10GQ20_missing_indv
vcftools --bcf ${NAME}_DP10GQ20.bcf --missing-ldepth > ${NAME}_DP10GQ20_missing_site

