# Analyses

To make our research accessible, transparent, and repeatable, we provide this electronic lab book as: 

1) A record of the decisions made during data processing and analysis

2) A clear record of the analyses including links to data, scripts, and final outputs


## Analyses: 

1. [Genome assembly](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Electronic_Lab_Book.md#1-genome-assembly)
    
    1a. [ST genome assembly](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Electronic_Lab_Book.md#1a-st-genome-assembly)
    
    1b. [SR genome assembly](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Electronic_Lab_Book.md#1b-sr-genome-assembly)
    
2. [Genome annotation](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Electronic_Lab_Book.md#2-genome-annotation)

3. [Mapping Structural Variants](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Electronic_Lab_Book.md#3-map-structural-variants)

4. [Mapping repeat elements](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Electronic_Lab_Book.md#4-map-repeat-elements)




# 1. Genome assembly

## 1a. ST genome assembly

### Data

Two sets of HiFi reads were generated from pooled larvae which were inbred for X (IBD) but not the autosomes. Individuals were all female, thus we expect no difference in coverage between the X chromosome and autosomes. 


### HiFiasm

#### De novo assembly

Each set of raw reads was submitted to HiFiasm for de novo assembly using [HiFiasm_INPUT1](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/HiFiasm_INPUT1.sh) and [HiFiasm_INPUT2](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/HiFiasm_INPUT2.sh)


The assembly was assembled by combining two independent runs, and compared with a single HiFiasm run which included both input files. The results are the same based on the size, BUSCO scores and kmer distributions. The final assembly was based on the single command. 

#### Checks

1. Run BUSCO on the initial HiFiasm assembly using [BUSCO_ST_Hifiasm.sh](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/BUSCO_ST_Hifiasm.sh)

The results show a very complete genome, but with a high proportion of duplication: [BUSCO_ST_Hifiasm.txt](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/BUSCO_ST_Hifiasm.txt)

C:98.0%[S:65.0%,D:33.0%],F:0.4%,M:1.6%,n:3285


2. kmer distribution

Visualise the kmer distribution using [Jellyfish v.2.3.0](https://github.com/gmarcais/Jellyfish) and [GenomeScope](http://qb.cshl.edu/genomescope/)


The peak is indistinguishable from the error. Estimated heterozygosity is ~4%, and the genome size is much larger than expected (3.1Gb vs 438.2Mb)


![Screen Shot 2022-09-07 at 12 44 56](https://user-images.githubusercontent.com/12142475/188872308-7310843c-7bba-4ee6-a9da-a12201200d7b.png)


We suspect that HiFiasm hasn't purged enough duplicates. HiFiasm is run with the most stringent purging setting by default. The developers suggest [here](https://github.com/chhylp123/hifiasm/issues/70) that a combination of HiFiasm and [purge_dups](https://github.com/dfguan/purge_dups) might be necessary with high levels of duplication. 

The very large genome assembly also suggests a high level of duplication that was not properly purged: [HiFiasm FAQ](https://hifiasm.readthedocs.io/en/latest/faq.html#why-the-size-of-primary-assembly-or-partially-phased-assembly-is-much-larger-than-the-estimated-genome-size) 



### Purge duplicates round 1

Follow the [pipeline](https://github.com/dfguan/purge_dups#--pipeline-guide) described by the authors

Step 1a: Align PacBio reads to the primary assembly: [minimap2_STgenome_vs_HiFi.sh](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/minimap2_STgenome_vs_HiFi.sh)


Step 1b: Split the assembly into contigs and self align: [minimap2_STgenome_selfAln.sh](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/minimap2_STgenome_selfAln.sh)


Step 1c: Calculate cut-offs: 

Based on the depth estimates from above
```
purge_dups/bin/calcuts PB.stat > cutoffs 2>calcults.log
```

[calcuts.log](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/Round1_calcuts.log)


Step 1d: Inspect the automatic cut-offs: 

```
/purge_dups/scripts/hist_plot.py -c cutoffs PB.stat PB.cov.png
```

![Screen Shot 2022-09-07 at 13 43 47](https://user-images.githubusercontent.com/12142475/188881271-f66b64fa-b725-4581-a4fc-3d16ff70012d.png)

Check if the coverage is what we expect. If this is a completely homozygous genome we'd expect this primary assembly to be a haploid peak. The diploid peak (heterozygous sites) would be expected at about half the haploid coverage. 

```
zcat m64157e_210730_141553.hifi_reads.fasta.gz | grep -v ">" | awk '{x+=length($0)}END{print x}'
12769157425

zcat m64157e_211024_013127.hifi_reads.fasta.gz | grep -v ">" | awk '{x+=length($0)}END{print x}'
```

The expected coverage is: 
```
# Number of raw reads / expected genome size
(12769157425+7893963766)/438000000 = 47x

#Coverage for haploid genome: 47X
#Therefore expected coverage for diploid genome: 23.5X
```

The peak is at 47X - exactly what we'd expect with a low heterozygosity haploid assembly based on our data. 


Step 1e: Manually adjust the cut-offs: 

Since we expect only a single peak, we need to adjust the cut-offs. See [here](https://github.com/dfguan/purge_dups/issues/14) for a discussion on how to choose cut-offs. 

We've chosen: 
```
# l: lower cut-off. Everything below this coverage is removed as junk
# m: heterozygous cut-off. 47X/2
# u: coverage of duplications. 47X*3

purge_dups/bin/calcuts -l 7 -m 23 -u 140 PB.stat > cutoffs_adjusted

cat cutoffs_adjusted
7	22	22	23	23	140
```


Step 2: Purge haplotigs and overlaps

```
#Runs in a few seconds

purge_dups/bin/purge_dups -2 -T cutoffs_adjusted -c PB.base.cov STgenome_220510.asm.p_ctg.fas.split.self.paf.gz > dups.bed 2> purge_dups.log
```

Step 3: Retrieve the non-duplicated sequences from the primary assembly

```
#The "split" assembly has been split into contigs. 
#These were renamed to remove the sequence length from the contig names: 
#e.g., >ptg000001l:1-6752682 renamed to >ptg000001l

purge_dups/bin/get_seqs -e dups.bed STgenome_220510.asm.p_ctg_split.fas_renamed
```

#### Validate

Size of the purged genome matches the expectation (438Mb)
```
207M	hap.fa
421M	purged.fa
```


Coverage plot: 




BUSCO scores: 

[BUSCO_purged.sh](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/BUSCO_purgedups_Round1.sh)

[Results](): 




#### purge duplicates round 2

The authors recommend concatenating the purged hap.fa and purged.fa and repeating the whole process. After running this we obtained much poorer BUSCO scores: 




#### checks



### Scaffold 

We've used the Hi-C data generated by Reinhardt *et al.* 2022.



### Assess final genome


#### Blobtools


## 1b. SR genome assembly


### Assess final genome

#### Checks






## 2. Genome annotation

### Data processing

Isoseq

### Pipeline

link to Sade's pipeline and paper


### Final genome figures, tables, and accession numbers. 



# 3. Map Structural variants

Pipeline

## Alignment


## Sniffles


## Filtering


## Machine learning approaches


## Re-sequencing


## Genes associated


## Age of inversions


Based on Ruff paper


# 4. Map repeat elements

## RepeatModeler


## Filter


## Final outputs







