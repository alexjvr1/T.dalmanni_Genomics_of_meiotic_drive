#!/bin/bash
#$ -S /bin/bash
#$ -N Busco.STpurged.fa  ##job name
#$ -l tmem=16G #RAM
#$ -l h_vmem=16G #enforced limit on shell memory usage
#$ -l h_rt=20:00:00 ##wall time.
#$ -j y  #concatenates error and output files (with prefix job1)
#$ -t 1-4
#$ -l tscratch=10G
#$ -l avx2=yes

###############
# Run Busco analysis as an array for multiple fasta inputs. 
# Array numbers can be adjusted to the number of inputs
# genome_list is a text file listing all fasta files to be processed in a single column
###############


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
GENOMEPATH=STgenome/SEPARATE
DATABASE=$SHAREDPATH/RefGenome/busco_downloads/lineages/diptera_odb10

GENOME=$(sed "${SGE_TASK_ID}q;d" genome_list)


busco -i $SHAREDPATH/$GENOMEPATH/${GENOME} \
-l $DATABASE \
-o BUSCOout_${GENOME} \
-m genome -f --offline
