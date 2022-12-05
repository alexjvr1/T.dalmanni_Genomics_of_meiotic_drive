#!/bin/bash
#$ -S /bin/bash
#$ -N tama_ST  ##job name
#$ -l tmem=16G #RAM
#$ -l h_vmem=16G #enforced limit on shell memory usage
#$ -l h_rt=1:00:00 ##wall time.
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
INPUT=$SHAREDPATH/$ISOSEQPATH/ST_isoseq_BLASTshared.sorted.sam
REF=$SHAREDPATH/RefGenome/POM_genomes/ST_FINAL.fa
PREFIX=ST_tamacollapsed
CAP=no_cap


python $TAMA/tama_collapse.py -s $INPUT -f $REF -p $PREFIX -x $CAP
