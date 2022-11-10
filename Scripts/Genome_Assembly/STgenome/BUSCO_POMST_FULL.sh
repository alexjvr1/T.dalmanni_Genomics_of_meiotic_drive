#!/bin/bash
#$ -S /bin/bash
#$ -N Busco.ST  ##job name
#$ -l tmem=16G #RAM
#$ -l h_vmem=16G #enforced limit on shell memory usage
#$ -l h_rt=10:00:00 ##wall time.
#$ -j y  #concatenates error and output files (with prefix job1)
#$ -l tscratch=10G
#$ -l avx2=yes

#Run on working directory
cd $SGE_O_WORKDIR 

#Software
busco=/SAN/ugi/StalkieGenomics/software/busco/bin/busco
metaeuk=/share/apps/genomics/metaeuk/bin/metaeuk
Metaeuk=metaeuk
export PATH=/share/apps/python-3.8.5-shared/bin:$PATH
export LD_LIBRARY_PATH=/share/apps/python-3.8.5-shared/lib:$LD_LIBRARY_PATH
export PATH=/share/apps/genomics/hmmer-3.3.2/bin:$PATH
export PATH=/share/apps/genomics/metaeuk/bin:$PATH
export PATH=/share/apps/genomics/augustus-3.4.0/bin:$PATH
export PATH=/share/apps/genomics/sepp/bin:$PATH


#Variables
SHAREDPATH=/SAN/ugi/StalkieGenomics
GENOME=$SHAREDPATH/RefGenome/POM_genomes/ST_FINAL.fa
DATABASE=diptera_odb10
OUTFILE=BUSCO_POM_ST_FINAL



busco -i $GENOME \
-l $DATABASE \
-o $OUTFILE \
-m genome -f --offline
