#!/bin/bash
#$ -S /bin/bash
#$ -N ST.PurgeDups_R2  ##job name
#$ -l tmem=32G #RAM
#$ -l h_vmem=32G #enforced limit on shell memory usage
#$ -l h_rt=1:00:00 ##wall time.
#$ -j y  #concatenates error and output files (with prefix job1)

# Goal: Second round of purge_dups as recommended by developers
# Steps in this script:
# 4.1 - Merge purged assemblies
# 4.2 - Map raw HiFi reads back to merged assembly, calculate read depth and base level depth
# 4.3 - Split merged assembly by contig and self align
# 4.4 - Purge duplicates and extract purged contigs from merged assembly.


#Run on working directory
cd $SGE_O_WORKDIR 

#Software
minimap2=/SAN/ugi/StalkieGenomics/software/minimap2-2.24_x64-linux/minimap2
pbcstat=/SAN/ugi/StalkieGenomics/software/purge_dups/bin/pbcstat
calcuts=/SAN/ugi/StalkieGenomics/software/purge_dups/bin/calcuts
split_fa=/SAN/ugi/StalkieGenomics/software/purge_dups/bin/split_fa
purge_dups=/SAN/ugi/StalkieGenomics/software/purge_dups/bin/purge_dups
get_seqs=/SAN/ugi/StalkieGenomics/software/purge_dups/bin/get_seqs 


#Variables
REF=ST_Round1_Merged
PURGEDREF=
PURGEDHAP=
INPUTREADS=/SAN/ugi/StalkieGenomics/STgenome_rawdata/HiFi

# Step 4.1: Merge purged assemblies

cat $PURGEDREF $PURGEDHAP > $REF


# Step 4.2: Map raw HiFi reads back to merged assembly, calculate read depth and base level depth

for i in $(ls $INPUTREADS/*fastq.gz) 
do time $minimap2 -xasm20 $REF  $i | gzip -c - > $REF_$i.aln.paf.gz
done


# Step 4.3: Split merged assembly by contig and self align

## Split into contiges
$split_fa $REF > $REF.split.fas

## Self-alignment
$minimap2 -xasm5 -DP $REF.split.fas $REF.split.fas | gzip -c - > $REF.split.self.paf.gz


# Step 4.4: Purge duplicates and extract purged contigs from merged assembly.

#Variables

## Step1: Create a bed file of all duplicate reads
$purge_dups -2 -T cutoffs -c PB.base.cov $REF.split.self.paf.gz > dups.bed 2> purge_dups.log


## Step2: Edit the fas file to remove any colons from the contig names 
sed 's/:.*//' $REF.split.fas > $REF.split.fas_renamed

## Step3: extract all non-duplicated reads from the original reference
$get_seqs -e dups.bed $REF.split.fas
