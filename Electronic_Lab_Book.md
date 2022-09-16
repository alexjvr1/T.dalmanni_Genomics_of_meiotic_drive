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

Step 0: Convert gfa (default HiFiasm output) to fasta
```
awk '/^S/{print ">"$2;print $3}' test.p_ctg.gfa > test.p_ctg.fa
```

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

#Coverage for homozygote sites in genome: 47X
#Therefore expected coverage for heterozygote sites: 23.5X
```

The peak is at 47X - exactly what we'd expect with a low heterozygosity (i.e. homozygous) diploid assembly based on our data. 


Step 1e: Manually adjust the cut-offs: 

Since we expect only a single peak, we need to adjust the cut-offs. See [here](https://github.com/dfguan/purge_dups/issues/14) for a discussion on how to choose cut-offs. 

We've chosen: 
```
# l: lower cut-off. Everything below this coverage is removed as junk
# m: heterozygous cut-off. 47X/2
# u: coverage of duplications. 47X*3

purge_dups/bin/calcuts -l 7 -m 23 -u 140 PB.stat > cutoffs_adjusted

cat cutoffs_adjusted
5	22	22	23	23	140
```


We also tested: 

l=7, m=23, u=140 [BUSCO](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/BUSCO_ST_HiFiasm_purged_l7m23u140.txt)

l=7, m=23, u=70 [BUSCO](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/BUSCO_ST_HiFiasm_purged_l7m23u70.txt)

But they had slightly worse BUSCO scores. 


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

1. Size of the purged genome matches the expectation (438Mb)
```
198M	hap.fa
431M	purged.fa
```


2. Coverage plot: 

<img width="832" alt="Screen Shot 2022-09-08 at 11 21 22" src="https://user-images.githubusercontent.com/12142475/189098587-478d34f0-9a8a-4648-a574-0f115310833b.png">


A BLAST search of a subset of the <5X reads that remain found that 90% match *T. dalmanni* RNA reads. We'll keep them and see if they can be incorporated with the scaffolding step. 

[Update BLAST nt database](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Functions_and_General/update_NCBInt.sh)

[BLASTn script](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/BLASTn_lowcovreads.sh)

InputFile generated by extracting all contigs with <5X coverage based on the dups.bed file generated during the purge_dups pipeline
```
awk -F"\t" '{print $1}' > contigs.toblast
for line in $(cat contigs.toblast); do grep -A 1 $line > contigs.toblast.fas; done
```

[BLASTn Results]()



3. BUSCO scores: 

[BUSCO_purged.sh](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/BUSCO_purgedups_Round1.sh)

C:96.9%[S:95%;D:1.9%]

[Results](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/BUSCO_purgedups_Round1_output_summary.txt): 


Wilkinson genome: C:96.7%[S:95%;D:2.0%]




#### purge duplicates round 2

The authors recommend concatenating the purged hap.fa and alt assembly and repeating the whole process. After running this we obtained much poorer BUSCO scores: 


Initial depth distribution: 

<img width="883" alt="Screen Shot 2022-09-09 at 16 31 21" src="https://user-images.githubusercontent.com/12142475/189387428-f94b1756-82c2-443c-a904-733ac8b30b4b.png">


Based on the low depth reads in these two fasta files, we decided not to pursue these data further. 


### Compare draft genomes

For an initial look at the genome assemblies, we used [D-genies](https://dgenies.toulouse.inra.fr). This web application uses minimap2 to quickly align two genomes (2-6 minutes for our assemblies)

1. Wilkinson ST genome vs our ST genome

![Screen Shot 2022-09-09 at 16 36 44](https://user-images.githubusercontent.com/12142475/189388515-3b2f9c16-9cd5-47b8-9542-2e12ee3cdc22.png)




2. Our ST draft vs our SR draft

![Screen Shot 2022-09-09 at 16 37 36](https://user-images.githubusercontent.com/12142475/189388554-4032a3cf-bfcf-4dcd-9396-b76c0b8a984a.png)



It looks like at least one of our large contigs in the ST genome has an error as it shows an inversion on autosome 2 in both comparisons. 


### Check for errors in contigs




### Scaffold 

We've used the Hi-C data generated by [Reinhardt *et al.* 2022]().

#### Step 1: Map

Map Hi-C reads to reference using the [Arima Mapping pipeline](https://github.com/ArimaGenomics/mapping_pipeline/blob/master/Arima_Mapping_UserGuide_A160156_v02.pdf)

[Map_HiC.sh]()

Mapping runs for ~24 hours using the resources in the script. 

[Process_mapped_HiC.sh]()


#### Step 2: Scaffold

Scaffold with [YAHS](https://github.com/c-zhou/yahs)





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







