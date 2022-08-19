#!/bin/bash
#$ -S /bin/bash
#$ -N ST._minimap  ##job name
#$ -l tmem=32G #RAM
#$ -l h_vmem=32G #enforced limit on shell memory usage
#$ -l h_rt=1:00:00 ##wall time.
#$ -j y  #concatenates error and output files (with prefix job1)
#$ -t 1-2  #Set up an array

#Run on working directory
cd $SGE_O_WORKDIR 

#Software
minimap2=/SAN/ugi/StalkieGenomics/software/minimap2-2.24_x64-linux/minimap2
pbcstat=/SAN/ugi/StalkieGenomics/software/purge_dups/bin/pbcstat
calcuts=/SAN/ugi/StalkieGenomics/software/purge_dups/bin/calcuts

#variables
REF=/SAN/ugi/StalkieGenomics/STgenome/purged.fas
INPUTREADS=/SAN/ugi/StalkieGenomics/STgenome_rawdata/HiFi
OUT=/SAN/ugi/StalkieGenomics/STgenome/purged_aln

#Input files in raw_HiFi: m64157e_210730_141553.hifi_reads.fastq.gz; m64157e_211024_013127.hifi_reads.fastq.gz

NAME=$(sed "${SGE_TASK_ID}q;d" raw_HiFi)


# map
mkdir -p $OUT
time $minimap2 -xasm20 $REF  $INPUTREADS/${NAME} | gzip -c - > $OUT/${NAME}.aln.paf.gz
