#!/bin/bash
#$ -S /bin/bash
#$ -N BLASTn.STlowcov  ##job name
#$ -l tmem=32G #RAM
#$ -l h_vmem=32G #enforced limit on shell memory usage
#$ -l h_rt=20:00:00 ##wall time.
#$ -j y  #concatenates error and output files (with prefix job1)

#Script: Blast low coverage reads against a local nt database
#GOAL: Are the low coverage reads contamination which should be removed? Or T.dalmanii reads that can be kept and potentially scaffolded in the next step?


#Run on working directory
cd $SGE_O_WORKDIR 

#Software
export PATH=/share/apps/genomics/blast-2.10.0+/bin:$PATH

#Variables
SHAREDPATH=/SAN/ugi/StalkieGenomics/Blobtools_STgenome
READS=/SAN/ugi/StalkieGenomics/STgenome/FINAL_PURGEDDUPS/lowcov.STdraft_contigs.to.blast.fas
NT=$SHAREDPATH/ncbi_nt/nt
OUTFILE=STlowcov_BLAST.out


time blastn -db $NT \
       -query $READS \
       -outfmt "6 qseqid staxids bitscore std" \
       -max_target_seqs 10 \
       -max_hsps 1 \
       -evalue 1e-25 \
       -num_threads 1 \
       -out $OUTFILE
