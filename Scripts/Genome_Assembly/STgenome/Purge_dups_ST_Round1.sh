#!/bin/bash
#$ -S /bin/bash
#$ -N ST.purgeDups_R1  ##job name
#$ -l tmem=32G #RAM
#$ -l h_vmem=32G #enforced limit on shell memory usage
#$ -l h_rt=1:00:00 ##wall time.
#$ -j y  #concatenates error and output files (with prefix job1)

#Run on working directory
cd $SGE_O_WORKDIR 

#Software
purge_dups=/SAN/ugi/StalkieGenomics/software/purge_dups/bin/purge_dups
get_seqs=/SAN/ugi/StalkieGenomics/software/purge_dups/bin/get_seqs 

#Variables
REF=/SAN/ugi/StalkieGenomics/STgenome/STgenome_220510.asm.p_ctg.fas
SPLITREF=STgenome_220510.asm.p_ctg_split.fas

## Step1: Create a bed file of all duplicate reads
$purge_dups -2 -T cutoffs -c PB.base.cov $REF.split.self.paf.gz > dups.bed 2> purge_dups.log


## Step2: Edit the fas file to remove any colons from the contig names 
sed 's/:.*//' $SPLITREF > $SPLITREF_renamed

## Step3: extract all non-duplicated reads from the original reference
$get_seqs -e dups.bed $SPLITREF 

