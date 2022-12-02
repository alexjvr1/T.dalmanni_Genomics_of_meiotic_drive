#!/bin/bash
#$ -S /bin/bash
#$ -N ST.MarkDups  ##job name
#$ -l tmem=16G #RAM
#$ -l h_vmem=16G #enforced limit on shell memory usage
#$ -l h_rt=1:00:00 ##wall time. 
#$ -l tscratch=20G
#$ -j y  #concatenates error and output files (with prefix job1)
#$ -t 1-50

#Mark duplicates in the bam file


#Run on working directory
cd $SGE_O_WORKDIR 

#Call software
export PATH=/share/apps/java/bin:$PATH
export LD_LIBRARY_PATH=/share/apps/java/lib:$LD_LIBRARY_PATH
PICARD=/share/apps/genomics/picard-2.20.3/bin/picard.jar


#Define variables
USERNAME=ajansen
SHAREDFOLDER=/SAN/ugi/StalkieGenomics/ShortRead_Analysis
REF=$SHAREDFOLDER/$SPECIES/RefGenome/GCA_937612035.1_ilAriArta2.1_genomic.fna
INPUT=$SHAREDFOLDER/Mapped_ST
OUTPUT=$SHAREDFOLDER/Mapped_ST
TAIL="RG.bam"

#Set up ARRAY job
#ls $INPUT/*RG.bam | awk -F "/" '{print $NF}' | awk -F "." '{print $1}' >> modc.names
NAME=$(sed "${SGE_TASK_ID}q;d" ST.names1)


echo "java -Xmx4g -Xms4g -Djava.io.tmpdir=/scratch0/$USERNAME/$JOB_ID.$SGE_TASK_ID -jar $PICARD MarkDuplicates \
INPUT=$INPUT/${NAME}.$TAIL \
OUTPUT=$OUTPUT/${NAME}.rmdup.bam \
METRICS_FILE=$OUTPUT/${NAME}.dup.txt \
REMOVE_DUPLICATES=false \
VALIDATION_STRINGENCY=SILENT \
CREATE_INDEX=true" >> 02b.1_MarkDup.log



time java -Xmx4g -Xms4g -Djava.io.tmpdir=/scratch0/$USERNAME/$JOB_ID.$SGE_TASK_ID -jar $PICARD MarkDuplicates \
INPUT=$INPUT/${NAME}.$TAIL \
OUTPUT=$OUTPUT/${NAME}.rmdup.bam \
METRICS_FILE=$OUTPUT/${NAME}.dup.txt \
REMOVE_DUPLICATES=false \
VALIDATION_STRINGENCY=SILENT \
CREATE_INDEX=true



function finish {
    rm -rf /scratch0/$USERNAME/$JOB_ID.$SGE_TASK_ID
}

trap finish EXIT ERR INT TERM
