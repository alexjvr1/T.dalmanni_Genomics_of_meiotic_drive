#!/bin/bash
#$ -S /bin/bash
#$ -N minimap_SR_SVs  ##job name
#$ -l tmem=32G #RAM
#$ -l h_vmem=32G #enforced limit on shell memory usage
#$ -l h_rt=10:00:00 ##wall time.
#$ -j y  #concatenates error and output files (with prefix job1)

#Map POM SR long reads to POM ST genome

#Run on working directory
cd $SGE_O_WORKDIR 

#Software
minimap2=/SAN/ugi/StalkieGenomics/software/minimap2-2.24_x64-linux/minimap2

#variables
REF=/SAN/ugi/StalkieGenomics/RefGenome/POM_genomes/ST_FINAL.fa
INPUTREADS=/SAN/ugi/StalkieGenomics/SRgenome_rawdata/m54154_191030_153428.subreads.fasta
OUT=POMSRrawdata_POMST_forSVs.minimap

time $minimap2 -ax map-pb $REF $INPUTREADS > $OUT.aln1.sam
