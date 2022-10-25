#!/bin/bash
#$ -S /bin/bash
#$ -N ST.yahs_s1  ##job name
#$ -l h_rt=1:00:00
#$ -l tmem=6G
#$ -l h_vmem=6G
#$ -j y

##YAHS step 1: Make Hi-C links between scaffolds. 
##Runs in ~7min with 1 core and 5G RAM

HOMEDIR=/SAN/ugi/StalkieGenomics/STGENOME/FINAL_PURGEDDUPS/PURGE_l5m23u140/SCAFFOLDING_Hi-C
YAHS=/SAN/ugi/StalkieGenomics/software/yahs/yahs


$YAHS $HOMEDIR/STpurged.fa $HOMEDIR/BAM/DEDUP/STassembly_rep1.bam
