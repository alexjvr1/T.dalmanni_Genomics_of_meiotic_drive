#!/bin/bash
#$ -S /bin/bash
#$ -N SR.VariantCalling  ##job name
#$ -l tmem=16G #RAM
#$ -l h_vmem=16G #enforced limit on shell memory usage
#$ -l h_rt=24:00:00 ##wall time.  
#$ -l tscratch=10G
#$ -j y  #concatenates error and output files (with prefix job1)
#$ -t 1-3


#Run on working directory
cd $SGE_O_WORKDIR 

#Call software
export PATH=/share/apps/genomics/bcftools-1.15/bin:$PATH
export PATH=/share/apps/genomics/samtools-1.16.1/bin:$PATH

#Define variables
USERNAME=ajansen
SHAREDFOLDER=/SAN/ugi/StalkieGenomics
ANALYSIS=ShortRead_Analysis/
REF=$SHAREDFOLDER/RefGenome/POM_genomes/SR_FINAL.fasta
INPUT=$SHAREDFOLDER/$ANALYSIS/Mapped/FINAL
OUTPUT=$SHAREDFOLDER/$ANALYSIS/Mapped/Variant_calling_SR

#Set up ARRAY job
NAME=$(sed "${SGE_TASK_ID}q;d" regions)

#Script
time bcftools mpileup -Ou -f $REF -r ${NAME} -b bamlist | bcftools call -mv -Ob -o ${NAME}.bcf

#bcftools mpileup -Ou -f reference.fa alignments.bam | bcftools call -mv -Ob -o calls.bcf

function finish {
    rm -rf /scratch0/ajansen/$JOB_ID.$SGE_TASK_ID
}

trap finish EXIT ERR INT TERM
