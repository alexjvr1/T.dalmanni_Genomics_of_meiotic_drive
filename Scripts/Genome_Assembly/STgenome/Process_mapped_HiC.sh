




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
