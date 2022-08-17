
#!/bin/bash
#$ -S /bin/bash
#$ -N ST._minimap  ##job name
#$ -l tmem=32G #RAM
#$ -l h_vmem=32G #enforced limit on shell memory usage
#$ -l h_rt=1:00:00 ##wall time.
#$ -j y  #concatenates error and output files (with prefix job1)

## Self alignment of ST genome
## 1. Split genome into contigs
## 2. Align with minimap2

#Run on working directory
cd $SGE_O_WORKDIR 

#Software
split_fa=/SAN/ugi/StalkieGenomics/software/purge_dups/bin/split_fa
minimap2=/SAN/ugi/StalkieGenomics/software/minimap2-2.24_x64-linux/minimap2


#Variables
REF=/SAN/ugi/StalkieGenomics/STgenome/STgenome_220510.asm.p_ctg.fas


## Step1: Split reference by contig
echo "Step1: Split reference by contig"  >> SelfAln.log
echo ""  >> SelfAln.log
echo "$split_fa $REF > $REF.split" >> SelfAln.log
$split_fa $REF > $REF.split


## Step2: Self-alignment
echo "Step2: Self-alignment"  >> SelfAln.log
echo ""  >> SelfAln.log
echo "$minimap2 -xasm5 -DP $REF.split $REF.split | gzip -c - > $REF.split.self.paf.gz" >> SelfAln.log
$minimap2 -xasm5 -DP $REF.split $REF.split | gzip -c - > $REF.split.self.paf.gz
