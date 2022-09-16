#!/bin/bash
#$ -S /bin/bash
#$ -N ST.Process_HiC_map  ##job name
#$ -l tmem=32G #RAM
#$ -l h_vmem=32G #enforced limit on shell memory usage
#$ -l h_rt=40:00:00 ##wall time.
#$ -j y  #concatenates error and output files (with prefix job1)


## Goal: Map Hi-C reads to draft ST genome. 


#Run on working directory
cd $SGE_O_WORKDIR 

#Software
BWA=/share/apps/genomics/bwa-0.7.17/bwa
export PATH=/share/apps/genomics/samtools-1.14/bin:$PATH
PICARD=/share/apps/genomics/picard-2.26.9/picard.jar

export PATH=/share/apps/java/bin:$PATH
export LD_LIBRARY_PATH=/share/apps/java/lib:$LD_LIBRARY_PATH
export PATH=/share/apps/perl-5.30.0/bin/perl5.30.0:$PATH


#Variables
SRA=SRR12620697
LABEL=STassembly
FILT_DIR=/SAN/ugi/StalkieGenomics/STgenome/FINAL_PURGEDDUPS/PURGE_l5m23u140/SCAFFOLDING_Hi-C/BAM/FILTERED
COMBINER=/SAN/ugi/StalkieGenomics/STgenome/FINAL_PURGEDDUPS/PURGE_l5m23u140/SCAFFOLDING_Hi-C/two_read_bam_combiner.pl
STATS=/SAN/ugi/StalkieGenomics/STgenome/FINAL_PURGEDDUPS/PURGE_l5m23u140/SCAFFOLDING_Hi-C/get_stats.pl
PAIR_DIR=/SAN/ugi/StalkieGenomics/STgenome/FINAL_PURGEDDUPS/PURGE_l5m23u140/SCAFFOLDING_Hi-C/BAM/PAIRED
REP_DIR=/SAN/ugi/StalkieGenomics/STgenome/FINAL_PURGEDDUPS/PURGE_l5m23u140/SCAFFOLDING_Hi-C/BAM/DEDUP
REP_LABEL=$LABEL\_rep1
MAPQ_FILTER=10


**TMP_DIR

echo "Processing of reads mapped using Map_HiC.sh"

echo "### Step 3: Pair reads & mapping quality filter"
time perl $COMBINER $FILT_DIR/$SRA.1.fastq.bam $FILT_DIR/$SRA.2.fastq.bam samtools $MAPQ_FILTER | \
samtools view -bS -t $FAIDX - | \
samtools sort -o $TMP_DIR/$SRA.bam -

echo "### Step 3.B: Add read group"
time java -Xmx4G -Djava.io.tmpdir=temp/ -jar $PICARD AddOrReplaceReadGroups INPUT=$TMP_DIR/$SRA.bam OUTPUT=$PAIR_DIR/$SRA.bam ID=$SRA LB=$SRA SM=$LABEL PL=ILLUMINA PU=none

echo "### Step 4: Mark duplicates"
time java -Xmx4G -XX:-UseGCOverheadLimit -Djava.io.tmpdir=temp/ -jar $PICARD MarkDuplicates \
INPUT=$PAIR_DIR/$SRA.bam \
OUTPUT=$REP_DIR/$REP_LABEL.bam \
METRICS_FILE=$REP_DIR/metrics.$REP_LABEL.txt \
TMP_DIR=$TMP_DIR \
ASSUME_SORTED=TRUE \
VALIDATION_STRINGENCY=LENIENT \
REMOVE_DUPLICATES=TRUE

time samtools index $REP_DIR/$REP_LABEL.bam

time perl $STATS $REP_DIR/$REP_LABEL.bam > $REP_DIR/$REP_LABEL.bam.stats

echo "Finished Mapping Pipeline through Duplicate Removal"
