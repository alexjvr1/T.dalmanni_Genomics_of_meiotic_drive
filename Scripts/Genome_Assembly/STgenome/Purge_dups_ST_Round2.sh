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



