#!/bin/bash
#$ -S /bin/bash
#$ -N ST.HiC_map  ##job name
#$ -l tmem=32G #RAM
#$ -l h_vmem=32G #enforced limit on shell memory usage
#$ -l h_rt=40:00:00 ##wall time.
#$ -j y  #concatenates error and output files (with prefix job1)
#$ -t 1-2

## Goal: Map Hi-C reads to draft ST genome. 


#Run on working directory
cd $SGE_O_WORKDIR 

#Software
BWA=/share/apps/genomics/bwa-0.7.17/bwa
export PATH=/share/apps/genomics/samtools-1.14/bin:$PATH
PICARDTOOLS=/share/apps/genomics/picard-2.26.9/picard.jar

export PATH=/share/apps/java/bin:$PATH
export LD_LIBRARY_PATH=/share/apps/java/lib:$LD_LIBRARY_PATH
export PATH=/share/apps/perl-5.30.0/bin/perl5.30.0:$PATH


#Set up	scratch	space
#mkdir -p /scratch0/$USERNAME/$JOB_ID
#TMP_DIR=/scratch0/$USERNAME/$JOB_ID

#ARRAY
TAIL1=$(sed "${SGE_TASK_ID}q;d" TAIL)

#Variables
SRA=SRR12620697
LABEL=STassembly
IN_DIR=/SAN/ugi/StalkieGenomics/Wilk_rawdata/Hi-C
REF=/SAN/ugi/StalkieGenomics/STgenome/FINAL_PURGEDDUPS/PURGE_l5m23u140/STpurged.fa
FAIDX=$REF.fai
PREFIX=STpurged
RAW_DIR=/SAN/ugi/StalkieGenomics/STgenome/FINAL_PURGEDDUPS/PURGE_l5m23u140/SCAFFOLDING_Hi-C/BAM
FILT_DIR=/SAN/ugi/StalkieGenomics/STgenome/FINAL_PURGEDDUPS/PURGE_l5m23u140/SCAFFOLDING_Hi-C/BAM/FILTERED
FILTER=/SAN/ugi/StalkieGenomics/STgenome/FINAL_PURGEDDUPS/PURGE_l5m23u140/SCAFFOLDING_Hi-C/filter_five_end.pl
COMBINER=/SAN/ugi/StalkieGenomics/STgenome/FINAL_PURGEDDUPS/PURGE_l5m23u140/SCAFFOLDING_Hi-C/two_read_bam_combiner.pl
STATS=/SAN/ugi/StalkieGenomics/STgenome/FINAL_PURGEDDUPS/PURGE_l5m23u140/SCAFFOLDING_Hi-C/get_stats.pl
PAIR_DIR=/SAN/ugi/StalkieGenomics/STgenome/FINAL_PURGEDDUPS/PURGE_l5m23u140/SCAFFOLDING_Hi-C/BAM/PAIRED
REP_DIR=/SAN/ugi/StalkieGenomics/STgenome/FINAL_PURGEDDUPS/PURGE_l5m23u140/SCAFFOLDING_Hi-C/BAM/DEDUP
REP_LABEL=$LABEL\_rep1
MAPQ_FILTER=10
CPU=1

#echo "### Step 0: Check output directories exist & create them as needed"
[ -d $RAW_DIR ] || mkdir -p $RAW_DIR
[ -d $FILT_DIR ] || mkdir -p $FILT_DIR
[ -d $TMP_DIR ] || mkdir -p $TMP_DIR
[ -d $PAIR_DIR ] || mkdir -p $PAIR_DIR
[ -d $REP_DIR ] || mkdir -p $REP_DIR
[ -d $MERGE_DIR ] || mkdir -p $MERGE_DIR

#echo "### Step 0: Index reference" # Run only once! Skip this step if you have already generated BWA index files
$BWA index -a bwtsw -p $PREFIX $REF

echo "### Step 1: FASTQ to BAM"
$BWA mem $REF $IN_DIR/$SRA.${TAIL1} | samtools view -Sb > $RAW_DIR/$SRA.${TAIL1}.bam

### Step 2: Runs for ~24 hours
echo "### Step 2: Filter 5' end"
samtools view -h $RAW_DIR/$SRA.${TAIL1}.bam | perl $FILTER | samtools view -Sb - > $FILT_DIR/$SRA.${TAIL1}.bam


#echo "Finished Mapping Pipeline. Next run Process_mapped_HiC.sh"

