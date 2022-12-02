#!/bin/bash
#$ -S /bin/bash
#$ -N ST1.ValidateBamFile  ##job name
#$ -l tmem=16G #RAM
#$ -l h_vmem=16G #enforced limit on shell memory usage
#$ -l h_rt=1:00:00 ##wall time.  
#$ -j y  #concatenates error and output files (with prefix job1)
#$ -t 1-50

#Check the final bam. Any corruption or errors will be flagged by samtools and should be corrected with the next script. 

#Run on working directory
cd $SGE_O_WORKDIR 

#Call software
export PATH=/share/apps/java/bin:$PATH
export LD_LIBRARY_PATH=/share/apps/java/lib:$LD_LIBRARY_PATH
PICARD=/share/apps/genomics/picard-2.20.3/bin/picard.jar


#Define variables
USERNAME=ajansen
SHAREDFOLDER=/SAN/ugi/StalkieGenomics
SPECIES=ShortRead_Analysis/
REF=$SHAREDFOLDER/$SPECIES/RefGenome/GCA_902806685.1_iAphHyp1.1_genomic.fna
INPUT=$SHAREDFOLDER/$SPECIES/Mapped_ST
OUTPUT=$SHAREDFOLDER/$SPECIES/Mapped_ST
TAIL="RG.bam"

#Set up ARRAY job
#ls *bam | awk -F "." '{print $1}' >> modc.names
NAME=$(sed "${SGE_TASK_ID}q;d" ST.names1)

echo "java -Xmx4g -Xms4g -Djava.io.tmpdir=/scratch0/$USERNAME/$JOB_ID.$SGE_TASK_ID -jar $PICARD ValidateSamFile \
INPUT=$INPUT/${NAME}.realn.bam \
OUTPUT=$OUTPUT/${NAME}.realn.validatesam
MODE=SUMMARY" >> 02b.3_ValidateSamFile.log


time java -Xmx4g -Xms4g -Djava.io.tmpdir=/scratch0/$USERNAME/$JOB_ID.$SGE_TASK_ID -jar $PICARD ValidateSamFile \
INPUT=$INPUT/${NAME}.realn.bam \
OUTPUT=$OUTPUT/${NAME}.realn.validatesam \
MODE=SUMMARY

