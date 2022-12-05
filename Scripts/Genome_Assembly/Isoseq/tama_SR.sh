#!/bin/bash
#$ -S /bin/bash
#$ -N tama_SR  ##job name
#$ -l tmem=32G #RAM
#$ -l h_vmem=32G #enforced limit on shell memory usage
#$ -l h_rt=10:00:00 ##wall time.
#$ -j y  #concatenates error and output files (with prefix job1)

#Run on working directory
cd $SGE_O_WORKDIR 

#Environment
export PATH=/share/apps/python-2.7.16-shared/bin:$PATH
export LD_LIBRARY_PATH=/share/apps/python-2.7.16-shared/lib:$LD_LIBRARY_PATH


#Variables
SHAREDPATH=/SAN/ugi/StalkieGenomics
ISOSEQPATH=Blobtools_STgenome
TAMA=$SHAREDPATH/software/tama 
INPUT=$SHAREDPATH/$ISOSEQPATH/SR_isoseq_BLASTshared.sorted.sam
REF=$SHAREDPATH/RefGenome/POM_genomes/SR_FINAL.fasta
PREFIX=SR_tamacollapsed
CAP=no_cap

#Run tama collapse
time python $TAMA/tama_collapse.py -s $INPUT -f $REF -p $PREFIX -x $CAP
