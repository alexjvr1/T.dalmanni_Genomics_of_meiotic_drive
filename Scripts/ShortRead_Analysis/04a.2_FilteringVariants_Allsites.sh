#!/bin/bash
#$ -S /bin/bash
#$ -N STfilter  ##job name
#$ -l tmem=16G #RAM
#$ -l h_vmem=16G #enforced limit on shell memory usage
#$ -l h_rt=10:00:00 ##wall time.  
#$ -j y  #concatenates error and output files (with prefix job1)
#$ -t 1-3

#Run on working directory
cd $SGE_O_WORKDIR 

#software
export PATH=/share/apps/genomics/bcftools-1.15/bin:$PATH
export PATH=/share/apps/genomics/vcftools-0.1.16/bin/:$PATH

#Define Variables
SHAREDPATH=/SAN/ugi/StalkieGenomics/ShortRead_Analysis/Mapped_ST/FINAL/Variant_calling_ST_allsites
REMOVE=indivs.toremove

#Set up Array job to run each chromosome
NAME=$(sed "${SGE_TASK_ID}q;d" bcf.names)


#Filter for min depth and quality in bcftools
bcftools filter -Ob -i 'FMT/DP>10 & FMT/GQ>20' ${NAME} -o ${NAME}_DP10GQ20.bcf

#Remove problematic individuals
vcftools --bcf ${NAME}_DP10GQ20.bcf --remove $REMOVE --recode --recode-INFO-all --out ${NAME}.s2_n83


#Filter to remove multi-allelic loci, and loci genotyped in <90% of individuals. 
vcftools --vcf ${NAME}.s2_n83.recode.vcf --max-alleles 2 --max-missing 0.9 --recode --recode-INFO-all --out ${NAME}.s3_n83_2alleles_maxmiss0.9
