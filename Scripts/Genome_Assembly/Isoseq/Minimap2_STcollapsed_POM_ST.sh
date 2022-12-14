#!/bin/bash
#$ -S /bin/bash
#$ -N ST_isoseq_minimap2  ##job name
#$ -l tmem=16G #RAM
#$ -l h_vmem=16G #enforced limit on shell memory usage
#$ -l h_rt=10:00:00 ##wall time.
#$ -j y  #concatenates error and output files (with prefix job1)

#Run on working directory
cd $SGE_O_WORKDIR 


#Software
export PATH=/share/apps/genomics/minimap2:$PATH
export PATH=/share/apps/genomics/samtools-1.16.1/bin:$PATH

#Define variables
SHAREDPATH=/SAN/ugi/StalkieGenomics
STREF=$SHAREDPATH/RefGenome/POM_genomes/ST_FINAL.fa
FASTA=$SHAREDPATH/Blobtools_STgenome/ST_shared.fasta

#Step1: Mapping
time minimap2 -x splice $STREF $FASTA -a -o ST_isoseq_BLASTshared.sam


#Step2: sort

time samtools sort -o ST_isoseq_BLASTshared.sorted.sam ST_isoseq_BLASTshared.sam


