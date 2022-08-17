#!/bin/bash
#$ -S /bin/bash
#$ -N SR._minimap  ##job name
#$ -l tmem=32G #RAM
#$ -l h_vmem=32G #enforced limit on shell memory usage
#$ -l h_rt=1:00:00 ##wall time.
#$ -j y  #concatenates error and output files (with prefix job1)

#Run on working directory
cd $SGE_O_WORKDIR 

#Software
minimap2=/SAN/ugi/StalkieGenomics/software/minimap2-2.24_x64-linux/minimap2
pbcstat=/SAN/ugi/StalkieGenomics/software/purge_dups/bin/pbcstat
calcuts=/SAN/ugi/StalkieGenomics/software/purge_dups/bin/calcuts

#variables
REF=/SAN/ugi/StalkieGenomics/STgenome/STgenome_220510.asm.p_ctg.fas
INPUTREADS=/SAN/ugi/StalkieGenomics/STgenome_rawdata/HiFi
OUT=/SAN/ugi/StalkieGenomics/STgenome/STgenome_vs_HiFi

#Input files: m64157e_210730_141553.hifi_reads.fastq.gz; m64157e_211024_013127.hifi_reads.fastq.gz


for i in $(ls $INPUTREADS/*fastq.gz) 
do time $minimap2 -xasm20 $REF -d $REF.mmi $i | gzip -c - > $OUT_$i.aln.paf.gz
done

$pcbstat $OUT/*aln.paf.gz 
$calcuts $OUT/PB.stat > cutoffs 2> $OUT/calcuts.log
