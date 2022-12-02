#!/bin/bash
#$ -S /bin/bash
#$ -N ST.FixMate.Picard  ##job name
#$ -l tmem=16G #RAM
#$ -l h_vmem=16G #enforced limit on shell memory usage
#$ -l h_rt=1:00:00 ##wall time.  
#$ -j y  #concatenates error and output files (with prefix job1)
#$ -t 1-19

#Fixmate on any individuals that were flagged in the previous step


#Run on working directory
cd $SGE_O_WORKDIR 

#Call software
export PATH=/share/apps/java/bin:$PATH
export LD_LIBRARY_PATH=/share/apps/java/lib:$LD_LIBRARY_PATH
PICARD=/share/apps/genomics/picard-2.20.3/bin/picard.jar
export PATH=/share/apps/genomics/samtools-1.9/bin:$PATH
export LD_LIBRARY_PATH=/share/apps/genomics/samtools-1.9/lib:$LD_LIBRARY_PATH


#Define variables
SHAREDFOLDER=/SAN/ugi/StalkieGenomics
SPECIES=ShortRead_Analysis/Mapped_ST
INPUT=$SHAREDFOLDER/$SPECIES
OUTPUT=$SHAREDFOLDER/$SPECIES
TAIL="realn.bam"

#Set up ARRAY job
#ls *bam | awk -F "." '{print $1}' >> modc.names
NAME=$(sed "${SGE_TASK_ID}q;d" tofix)

#java -jar picard.jar FixMateInformation \ I=input.bam \ O=fixed_mate.bam \ ADD_MATE_CIGAR=true

#Step 1: Fix mate
echo "java -jar $PICARD FixMateInformation \
INPUT=$INPUT/${NAME}.realn.bam \
OUTPUT=$OUTPUT/${NAME}.fixed.bam \
ADD_MATE_CIGAR=true" >> 02b.3_ValidateSamFile.log


time java -Xmx4g -Xms4g -Djava.io.tmpdir=/scratch0/$USERNAME/$JOB_ID.$SGE_TASK_ID -jar $PICARD FixMateInformation \
INPUT=$INPUT/${NAME}.realn.bam \
OUTPUT=$OUTPUT/${NAME}.fixed.bam \
ADD_MATE_CIGAR=true 


#Step2: Index
samtools index ${NAME}.fixed.bam
