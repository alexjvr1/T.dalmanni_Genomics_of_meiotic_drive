# Filtering short reads

Basic Filter set: 

1. All reads with PHRED scores <20

2. Check depth distribution 

3. Filter for min depth of 10x (preferably, or 6X minimum)

4. Max depth filter (for duplicates)

5. Check missingness distribution (loci and individuals)

6. Remove poorly sequenced loci (<50%)

7. Remove individuals that sequenced poorly (<60% genotyping rate)

8. Remove multi-allelic SNPs


Dataset 1: 

Basic filter set


Dataset 2: 

For PCA, so minimise missingness. Keep only loci genotyped in 90% of individuals. 

Thin? 


## Filtering Script


```
#!/bin/bash
#$ -S /bin/bash
#$ -N SR_FilterSNPs  ##job name
#$ -l tmem=16G #RAM
#$ -l h_vmem=16G #enforced limit on shell memory usage
#$ -l h_rt=5:00:00 ##wall time.  
#$ -j y  #concatenates error and output files (with prefix job1)
#$ -t 1-3


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

```
