#!/bin/bash
#$ -S /bin/bash
#$ -N BLASTn.IsoSeqdraft  ##job name
#$ -l tmem=32G #RAM
#$ -l h_vmem=32G #enforced limit on shell memory usage
#$ -l h_rt=20:00:00 ##wall time.
#$ -j y  #concatenates error and output files (with prefix job1)



#Run on working directory
cd $SGE_O_WORKDIR 

#Software
export PATH=/share/apps/genomics/blast-2.10.0+/bin:$PATH


#Variables
SHAREDPATH=/SAN/ugi/StalkieGenomics/Blobtools_STgenome
GENOME=$SHAREDPATH/SR_isoseq_pbmm2mapped_to_POMSR_collapse.fasta
NT=$SHAREDPATH/ncbi_nt/nt
OUTFILE=ST_isoseq_BLAST



#Set up for script: 
#1) Identify taxid and 2) extract the list of taxon ids from NCBI
#1) To identify the higher order taxid number, either look it up on NCBI (e.g. search for Diptera and the first line on 
#the page will give the taxon id (https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=7147)
#Or use the blast tool to retrieve the number: 
#/share/apps/genomics/blast-2.10.0+/bin/get_species_taxids.sh -n Diptera
#2) Extract the list of taxids to file: 
#/share/apps/genomics/blast-2.10.0+/bin/get_species_taxids.sh -t 7147 > 7147.txids

#Run BLAST
blastn -db $NT \
       -taxidlist 7147.taxids \
       -query $GENOME \
       -outfmt "6 qseqid staxids bitscore std" \
       -max_target_seqs 10 \
       -max_hsps 1 \
       -evalue 1e-25 \
       -num_threads 1 \
       -out $OUTFILE
