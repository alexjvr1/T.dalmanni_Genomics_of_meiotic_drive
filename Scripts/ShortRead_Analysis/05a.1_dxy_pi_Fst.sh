#!/bin/bash
#$ -S /bin/bash
#$ -N pi_dxy_SR  ##job name
#$ -l tmem=32G #RAM
#$ -l h_vmem=32G #enforced limit on shell memory usage
#$ -l h_rt=40:00:00 ##wall time.  
#$ -l tscratch=10G
#$ -j y  #concatenates error and output files (with prefix job1)

#Run on working directory
cd $SGE_O_WORKDIR 


#Define Variables
SHAREDPATH=/SAN/ugi/StalkieGenomics/ShortRead_Analysis/Mapped/FINISHED/Variant_calling_SR_allsites
FILE=$SHAREDPATH/ChrX.s3_n83_2alleles_maxmiss0.9
OUTFILE=SR_div_stats.csv
POP1=SR
POP2=ST
POPFILE=pop_file

#software
export PATH=/share/apps/python-3.8.5-shared/bin:$PATH
export LD_LIBRARY_PATH=/share/apps/python-3.8.5-shared/lib:$LD_LIBRARY_PATH

export PATH=$SHAREDPATH/genomics_general:$PATH
export PATH=$SHAREDPATH/genomics_general/VCF_processing:$PATH

#Step 1: Convert vcf to geno
#parseVCF.py -i $FILE.recode.vcf -o $FILE.geno
#gzip $FILE.geno


#Step 2: Calculate dxy, pi and Fst
time popgenWindows.py -g $FILE.geno.gz -o $OUTFILE \
   -f phased -w 100000 -m 10 -s 25000 \
   -p $POP1 -p $POP2 \
   --popsFile $POPFILE \
   --writeFailedWindow
