#!/bin/bash
#$ -S /bin/bash
#$ -N ST_AddRG  ##job name
#$ -l tmem=16G #RAM
#$ -l h_vmem=16G #enforced limit on shell memory usage
#$ -l h_rt=1:00:00 ##wall time.  
#$ -l tscratch=20G
#$ -j y  #concatenates error and output files (with prefix job1)
#$ -t 1-50

#Add read groups to all samples in dataset


#Run on working directory
cd $SGE_O_WORKDIR 

#Call software
export PATH=/share/apps/java/bin:$PATH
export LD_LIBRARY_PATH=/share/apps/java/lib:$LD_LIBRARY_PATH
PICARD=/share/apps/genomics/picard-2.20.3/bin/picard.jar
export PATH=/share/apps/genomics/samtools-1.9/bin:$PATH
export LD_LIBRARY_PATH=/share/apps/genomics/samtools-1.9/lib:$LD_LIBRARY_PATH


#Define variables
USERNAME=ajansen
SHAREDFOLDER=/SAN/ugi/StalkieGenomics
REF=$SHAREDFOLDER/$SPECIES/RefGenome/GCA_937612035.1_ilAriArta2.1_genomic.fna
INPUT=$SHAREDFOLDER/ShortRead_Analysis/Mapped_ST
OUTPUT=$SHAREDFOLDER/ShortRead_Analysis/Mapped_ST

#Set up ARRAY job
#ls 02a_mapped_modern/*bam | awk -F "/" '{print $NF}' | awk -F "_" '{print $1}' > modc.names 
NAME=$(sed "${SGE_TASK_ID}q;d" ST.names1)


##Step 1: Add readgroups

#echo "java -Xmx4g -Xms4g -Djava.io.tmpdir=/scratch0/$USERNAME/$JOB_ID.$SGE_TASK_ID -jar $PICARD AddOrReplaceReadGroups \
       I=$INPUT/${NAME}.bam \
       O=$OUTPUT/${NAME}.RG.bam \
       RGID=ST \
       RGLB=ST01 \
       RGPL=ILLUMINA \
       RGPU=unit1 \
       RGSM=${NAME}" >> 02b.0_AddRG.log


#time java -Xmx4g -Xms4g -Djava.io.tmpdir=/scratch0/$USERNAME/$JOB_ID.$SGE_TASK_ID -jar $PICARD AddOrReplaceReadGroups \
       I=$INPUT/${NAME}.bam \
       O=$OUTPUT/${NAME}.RG.bam \
       RGID=ST \
       RGLB=ST01 \
       RGPL=ILLUMINA \
       RGPU=unit1 \
       RGSM=${NAME}

#Step 2: index bam file
samtools index ${NAME}.RG.bam
