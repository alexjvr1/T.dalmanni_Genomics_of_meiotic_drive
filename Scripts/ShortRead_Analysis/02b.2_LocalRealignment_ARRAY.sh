#!/bin/bash
#$ -S /bin/bash
#$ -N ST.LocalRealignment  ##job name
#$ -l tmem=16G #RAM
#$ -l h_vmem=16G #enforced limit on shell memory usage
#$ -l h_rt=10:00:00 ##wall time.
#$ -l tscratch=20G
#$ -j y  #concatenates error and output files (with prefix job1)
#$ -t 1-50

#Local realignment of reads after the initial mapping step. 

#Run on working directory
cd $SGE_O_WORKDIR 

#Call software
export PATH=/share/apps/jdk1.8.0_131/bin:$PATH
export LD_LIBRARY_PATH=/share/apps/jdk1.8.0_131/lib:$LD_LIBRARY_PATH
export PATH=/share/apps/genomics/samtools-1.9/bin:$PATH
export LD_LIBRARY_PATH=/share/apps/genomics/samtools-1.9/lib:$LD_LIBRARY_PATH


# Define variables
USERNAME=ajansen
SHAREDFOLDER=/SAN/ugi/StalkieGenomics
REF=$SHAREDFOLDER/RefGenome/POM_genomes/ST_FINAL.fa
INPUT=$SHAREDFOLDER/ShortRead_Analysis/Mapped_ST
OUTPUT=$SHAREDFOLDER/ShortRead_Analysis/Mapped_ST

GenomeAnalysisTK=/share/apps/genomics/GenomeAnalysisTK-3.8.1.0/GenomeAnalysisTK.jar


#Set up ARRAY job
#ls $INPUT/*rmdup.bam |awk -F "/" '{print $NF}' | awk -F "." '{print $1}' > modc.names 
NAME=$(sed "${SGE_TASK_ID}q;d" ST.names1)

#Step 1: 
# Identify targets to realign
java -Xmx4g -Xms4g -Djava.io.tmpdir=/scratch0/$USERNAME/$JOB_ID.$SGE_TASK_ID -jar $GenomeAnalysisTK -T RealignerTargetCreator \
-R $REF \
-o $OUTPUT/${NAME}.intervals \
-I $INPUT/${NAME}.rmdup.bam

#Step 2: 
# use IndelRealigner to realign the regions found in the RealignerTargetCreator step
java -Xmx4g -Xms4g -Djava.io.tmpdir=/scratch0/$USERNAME/$JOB_ID.$SGE_TASK_ID -jar $GenomeAnalysisTK -T IndelRealigner \
-R $REF \
-targetIntervals $INPUT/${NAME}.intervals \
-I $INPUT/${NAME}.rmdup.bam \
-o $OUTPUT/${NAME}.realn.bam

#Step 3: Index
samtools index ${NAME}.realn.bam

function finish {
    rm -rf /scratch0/$USERNAME/$JOB_ID.$SGE_TASK_ID
}

trap finish EXIT ERR INT TERM
