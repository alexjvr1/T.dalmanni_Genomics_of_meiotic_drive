# Analyses

To make our research accessible, transparent, and repeatable, we provide this electronic lab book as: 

1) A record of the decisions made during data processing and analysis

2) A clear record of the analyses including links to data, scripts, and final outputs


## Analyses: 

1. [Genome assembly](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Electronic_Lab_Book.md#1-genome-assembly)
    
    1a. [ST genome assembly](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Electronic_Lab_Book.md#1a-st-genome-assembly)
    
    1b. [SR genome assembly](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Electronic_Lab_Book.md#1b-sr-genome-assembly)
    
2. [Genome annotation](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Electronic_Lab_Book.md#2-genome-annotation)

3. [Short Reads](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Electronic_Lab_Book.md#3-short-reads)

4. [Mapping Structural Variants](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Electronic_Lab_Book.md#3-map-structural-variants)

5. [Mapping repeat elements](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Electronic_Lab_Book.md#4-map-repeat-elements)




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

We extensively tested different parameteres in HiFiasm to reduce erronious concatenation of contigs. These all created more fragmented draft genomes, but the inversion in autosome 2 persisted. 

We abandoned these tests and instead decided to scaffold these contigs using Hi-C data generated for ST individuals by [Reinhardt *et al.* 2022](). The contact maps would provide the best contig order map. 


### Scaffold 

We've used the Hi-C data generated by [Reinhardt *et al.* 2022]() and available here: [SRX9103577: Chromatin capture of Teleopsis dalmanni pupal cells for genome scaffolding](https://www.ncbi.nlm.nih.gov/sra?LinkName=biosample_sra&from_uid=16093132)

"Design: Intact cells from unsexed pupae from the 2A inbred line were crosslinked using a formaldehyde solution, digested using the Sau3AI restriction enzyme, and proximity-ligated with biotinylated nucleotides to create chimeric molecules composed of fragments from different regions of the genome that were physically proximal in vivo, but not necessarily genomically proximal. Molecules were pulled down with streptavidin beads and processed into an Illumina-compatible sequencing library"


#### Step 1: Map

Map Hi-C reads to reference using the [Arima Mapping pipeline](https://github.com/ArimaGenomics/mapping_pipeline/blob/master/Arima_Mapping_UserGuide_A160156_v02.pdf)

[Map_HiC.sh](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/Map_HiC.sh)

Mapping runs for ~24 hours using the resources in the script. 

[Process_mapped_HiC.sh](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/Process_mapped_HiC.sh)


#### Step 2: Scaffold

##### *Step1*

Scaffold with [YAHS](https://github.com/c-zhou/yahs)

Use the script [Yahs_Step1.sh](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/Yahs_Step1.sh)

This runs in 7mins

Output log found [here](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/Yahs_Step1.log) 




##### *Step2*

Create a contact map using [juicer-tools](https://github.com/aidenlab/juicer/wiki/Juicer-Tools-Quick-Start). 

Download the jar file [here](https://github.com/aidenlab/juicer/wiki/Download)

*NB* This is different from juicer provided with yahs, and needs to be installed independently. 

*NB* We've used v. 1.9.9. Versions 2.xx are unstable with the desktop version of Juicebox. 


The following runs in a few minutes:
```
(java -jar -Xmx32G juicer_tools.1.9.9_jcuda.0.8.jar pre alignments_sorted.txt out.hic.part scaffolds_final.chrom.sizes) && (mv out.hic.part out.hic)
```

1. alignments_sorted.txt = sorted alignment file created in first part of the script

2. out.hic.part = temporary outfile to be moved to out.hic in second part of the script

3. scaffolds_final.chrom.sizes = file with two columns: scaffold name and scaffold size. These can be found from the .fai index file for the genome. 


##### *Step 3*

Create .hic contact map file that can be visualised in Juicebox

```
juicer pre -a -o out_JBAT hic-to-contigs.bin scaffolds_final.agp contigs.fa.fai >out_JBAT.log 2>&1

```
*NB* This uses juicer from Yahs. 

And create .hic file:
```
(java -jar -Xmx32G juicer_tools.1.9.9_jcuda.0.8.jar pre out_JBAT.txt out_JBAT.hic.part <(cat out_JBAT.log  | grep PRE_C_SIZE | awk '{print $2" "$3}')) && (mv out_JBAT.hic.part out_JBAT.hic)
```


##### *Step4*

Visualise the heatmap in Juicebox Desktop by importing the .hic and .assembly files generated in the previous step. 

See [here](https://www.youtube.com/watch?v=Nj7RhQZHM18) for a video on how to edit the scaffold map in Juicebox. 

Save the edited version as your final genome. 

Our initial heatmap showed one large chromosome and several small unplaced scaffolds. We identified the three chromosomes. Some further changes could be made to Chr 1, but given the ambiguity of the assembly at this location (~center of Chr1) we made no changes. 

The problematic inversion on Chr 2 is no longer apparent. 

The edited assembly will be saved as filename.review.assembly


##### *Step5*

Convert Juicebox output to fasta

Use the yahs juicer function to convert the modified assembly to the final fasta. 
```
juicer post -o out_JBAT out_JBAT.review.assembly out_JBAT.liftover.agp contigs.fa

```

Final ST genome saved as ST_FINAL.fa

*Both Yahs and Juicer developers are very responsive on their respective google groups/github pages.* 



### Assess final genome

#### Size & fragmentedness

3 Chromosomes (394 Mb) + 980 unplaced scaffolds (64 Mb)

#### Completeness

BUSCO [Script](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/STgenome/BUSCO_POMST_FULL.sh)


C:97.0%[S:95.2%,D:1.8%],F:0.4%,M:2.6%,n:3285	   
	
    3184	Complete BUSCOs (C)			   
	
    3126	Complete and single-copy BUSCOs (S)	   
	
    58	Complete and duplicated BUSCOs (D)	   
	
    14	Fragmented BUSCOs (F)			   
	
    87	Missing BUSCOs (M)			   
	
    3285	Total BUSCO groups searched	
    
    

#### Blobtools




## 1b. SR genome assembly


*Details to be obtained from Helen*


### Assess final genome

#### Size and fragmentation

3 Chromosomes (400 Mb) + 1504 unplaced scaffolds (24 Mb)


#### BUSCO

Chromosomes only! 

***** Results: *****

	C:89.6%[S:88.8%,D:0.8%],F:4.0%,M:6.4%,n:3285	   
	
	2944	Complete BUSCOs (C)			   
	
	2917	Complete and single-copy BUSCOs (S)	   
	
	27	Complete and duplicated BUSCOs (D)	   
	
	130	Fragmented BUSCOs (F)			   
	
	211	Missing BUSCOs (M)			   
	
	3285	Total BUSCO groups searched



#### Checks

We checked to see if we could rescue any of the unplaced contigs based on alignment with our newly assembled ST_FINAL.fa

Alignment with minimap showed now obvious positions within the chromosomes for any of the unplaced contigs, thus we left the SRgenome as is. 


#### Location of diagnostic primers

There are four sets of primers that can be used to distinguish SR and ST. 

From Meade *et al.* 2019

![alt_txt][Fig1]

[Fig1]:https://user-images.githubusercontent.com/12142475/203520468-fe1b13ed-8b0c-4627-9c93-98bc79f71d0c.png


And the frequency with which the large and small alleles are found in each morph:

![alt_txt][Fig2]

[Fig2]:https://user-images.githubusercontent.com/12142475/203520479-9b87143c-2615-4e0d-86d7-39d4e584a8db.png


We identified the location of the four diagnostic primers using bowtie2: 
```
#diagnostic_primers.fa is a fasta file containing primer sequences
bowtie2 -x SR_FINAL -f diagnostic_primers.fa
bowtie2 -x ST_FINAL -f diagnostic_primers.fa
```


See bowtie2 ST results [here](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Data/bowtie2_ST_diagnosticPrimers.md)

See bowtie2 SR results [here](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Data/bowtie2_SR_diagnosticPrimers.md)


Final positions on each reference genome


|Genome|Primer|F|R|length|
|:-:|:-:|:-:|:-:|:-:|
|ST|m395|50590890|50591072|182|
|ST|comp162710|81244488|81244219|269|
|ST|cnv395|50554915|50554574|341|
|ST|cnv125|84697274|not mapped|N/A|
|SR|m395|50140221|50139999|222|
|SR|comp162710|35368864|35368681|183|
|SR|cnv395|50174607|50174918|311|
|SR|cnv125|38852130|38852017|113|


## 2. Genome annotation

### Data processing

Isoseq data was generated from pools 

Initially, the isoseq3 pipeline was run with default settings via the University of Liverpool Sequencing facility up to the final polishing step. 

The data received from Liverpool that we will use. These were created using the isoseq3 pipeline to the step just before collapsing: 
```
Sample1.polished.hq.bam
Sample2.polished.hq.bam
```


Install isoseq3 to run the collapse step. This was previously run by Liverpool using the Wilkinson v2 genome, but we want to rerun the step using our genomes. 

See here for more information on [isoseq3 collapse](https://isoseq.how/classification/isoseq-collapse.html) 
```
## Package Plan ##

  environment location: /home/ajansen/.conda/envs/btk_env/bin/Miniconda3

  added / updated specs:
    - isoseq3


The following packages will be downloaded:

    package                    |            build
    ---------------------------|-----------------
    ca-certificates-2022.10.11 |       h06a4308_0         124 KB
    certifi-2022.9.24          |   py39h06a4308_0         154 KB
    conda-22.9.0               |   py39h06a4308_0         884 KB
    isoseq3-3.8.1              |       h9ee0642_0         1.6 MB  bioconda
    openssl-1.1.1s             |       h7f8727e_0         3.6 MB
    toolz-0.12.0               |   py39h06a4308_0         105 KB
    ------------------------------------------------------------
                                           Total:         6.4 MB
```


Run the following step for Sample1_SR and Sample2_ST - each collapsing by mapping to the correct draft genome assembly: 

```
#Genome assemblies to use
/SAN/ugi/StalkieGenomics/RefGenome/POM_genomes/SR_FINAL.fasta
/SAN/ugi/StalkieGenomics/RefGenome/POM_genomes/ST_FINAL.fa


#Map the reads using pbmm2

pbmm2 align --preset ISOSEQ --sort <input.bam> <ref.fa> <mapped.bam>

##SR
pbmm2 align --preset ISOSEQ --sort Sample1.polished.hq.bam /SAN/ugi/StalkieGenomics/RefGenome/POM_genomes/SR_FINAL.fasta SR_isoseq_pbmm2mapped_to_POMSR.bam

##ST
pbmm2 align --preset ISOSEQ --sort Sample2.polished.hq.bam /SAN/ugi/StalkieGenomics/RefGenome/POM_genomes/ST_FINAL.fa ST_isoseq_pbmm2mapped_to_POMST.bam


#Collapse the reads

isoseq3 collapse <mapped.bam> <collapse.gff>

##SR
isoseq3 collapse SR_isoseq_pbmm2mapped_to_POMSR.bam SR_isoseq_pbmm2mapped_to_POMSR_collapse.gff

##ST
isoseq3 collapse ST_isoseq_pbmm2mapped_to_POMST.bam ST_isoseq_pbmm2mapped_to_POMST_collapse.gff
```

We now have reads that are collapsed according to where they map on the reference genome. Has this reduced the total transcripts?:

```
#Previous collapsed fasta based on mapping to the Wilkinson genome: 85645
grep ">" SR_isoseq_pbmm2mapped_to_POMSR_collapse.fasta |wc -l
60208

#Previous collapsed fasta based on mapping to the Wilkinson genome: 113461
grep ">" ST_isoseq_pbmm2mapped_to_POMST_collapse.fasta |wc -l
71438
```

A big improvement, even on my previous attempt to run tama collapse on the isoseq3, cd-hit-est collapsed files. Thus the correct genome makes a big difference. 


##### Next things we can do: 

1. BLAST to Diptera and remove all non dipteran sequences. 

2. cd-est collapse (used by Liverpool)

3. Tama collapse



#### 1. BLASTn to Diptera

See script and setup here: [BLASTn_IsoSeq.sh](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/Isoseq/BLASTn_IsoSeq.md) for SR

And here: [BLASTn_IsoSeq_ST.sh](https://github.com/alexjvr1/T.dalmanni_Genomics_of_meiotic_drive/blob/main/Scripts/Genome_Assembly/Isoseq/BLASTn_IsoSeq_ST.md) for ST

We ran into a memory mapping error when submitting to queue, but this runs well in the interactive node. Request more time for the interactive
node to make sure it runs to completion. 

It takes ~3hours using qrsh -l tmem=5G, h_vmem=5G, h_rt=3600

Started 15:17


Process the output from BLASTn to identify the transcripts that should be removed from the fasta file: 
```
#How many transcripts are we starting with? 
#From above
#SR = 60208

#The blastn output: 
head SR_isoseq_BLAST 
PB.1.1|PB.1.1:88017-90118(-)|transcript_73383	139649	1677	PB.1.1|PB.1.1:88017-90118(-)|transcript_73383	XM_038084718.1	100.000	908	0	0	2	909	14	921	0.0
PB.1.2|PB.1.2:88124-90118(-)|transcript_76103	139649	1677	PB.1.2|PB.1.2:88124-90118(-)|transcript_76103	XM_038084718.1	100.000	908	0	0	2	909	14	921	0.0
#Col 6 shows the proportion match to a sequence in the diptera database. 
#Let's see how much variance there is in the matches: 
awk '{a[i++]=$6;} END {print a[int(i/2)];}' SR_isoseq_BLAST
99.225

#To see the lowest values:
awk '{print $6}'  SR_isoseq_BLAST |sort |tail
99.988
99.988
99.988
99.988
99.988
99.988
99.988
99.988
99.988
99.989

#Similarly the e-values are all really low: 
awk '{print $14}'  SR_isoseq_BLAST |sort |tail
9.99e-32
9.99e-32
9.99e-36
9.99e-60
9.99e-65
9.99e-72
9.99e-97
9.99e-97
9.99e-97
9.99e-97
(base) awk '{print $14}'  SR_isoseq_BLAST |sort |head
0.0
0.0
0.0
0.0
0.0
0.0
0.0
0.0
0.0
0.0

#So we're happy to keep all these transcripts. Let's find a non-redundant set of their names: 
awk '{print $1}' SR_isoseq_BLAST |sort |uniq > SR_BLAST_uniq
wc -l SR_BLAST_uniq
58369 SR_BLAST_uniq

#So that's 1839 transcripts that don't blast to diptera. Or about 3% of our isoseq dataset

#Let's intersect these names with the names from the isoseq fasta file, and find the transcript names that need to be removed. 
grep ">" SR_isoseq_pbmm2mapped_to_POMSR_collapse.fasta | awk -F ">" '{print $2}' |sort |uniq > SR_fasta_uniq
#Check that this is the expected length (see above for the number of transcripts in the isoseq fasta)
wc -l SR_fasta_uniq 
60208 SR_fasta_uniq

#Intersect and write all lines that appear in SR_allTranscripts_isoseqfasta but not in SR_allBLASTtranscripts_uniq
#Check that the files are sorted (as above)
#Write the transcript names in the fasta file that isn't in the BLAST file
diff SR_fasta_uniq SR_BLAST_uniq |grep "<" |sed 's:<\ ::g' > diff_fasta_BLAST_SR 
wc -l diff_fasta_BLAST_SR 
1839 diff_fasta_BLAST_SR

#Because we want to extract these headers + the sequence following the name, it's easier to work with the list of transcripts to keep.
#Find lines in common between files using comm. -1 suppresses lines unique to file 1, and -2 for file 2
comm -12 SR_BLAST_uniq SR_fasta_uniq > shared_BLAST_fasta_SR
wc -l shared_BLAST_fasta_SR 
58369 shared_BLAST_fasta_SR

#Extract sequences from the fasta file: 
grep -A 1 -f shared_BLAST_fasta_SR SR_isoseq_pbmm2mapped_to_POMSR_collapse.fasta > SR_isoseq_pbmm2mapped_to_POMSR_collapse_diptera.fasta

#This writes some lines "--" at the end of each extracted transcript. Remove these: 
sed -i '/--/d' SR_isoseq_pbmm2mapped_to_POMSR_collapse_diptera.fasta

```

And do the same for ST

```
#How many transcripts are we starting with? 
#From above
#ST=71438

#The blastn output: 
head SR_isoseq_BLAST 
PB.1.1|PB.1.1:65228-347364(+)|transcript_64308	139649	2375	PB.1.1|PB.1.1:65228-347364(+)|transcript_64308	XM_038072565.1	99.922	1289	1	0	461	1749	1	1289	0.0
PB.1.1|PB.1.1:65228-347364(+)|transcript_64308	139649	977	PB.1.1|PB.1.1:65228-347364(+)|transcript_64308	XM_038075142.1	99.812	532	1	0	1748	2279	319	850	0.0
PB.1.2|PB.1.2:67495-191233(+)|transcript_94016	139649	2069	PB.1.2|PB.1.2:67495-191233(+)|transcript_94016	XM_038072565.1	100.000	1120	0	0	31	1150	1	1120	0.0
PB.1.2|PB.1.2:67495-191233(+)|transcript_94016	139649	994	PB.1.2|PB.1.2:67495-191233(+)|transcript_94016	XM_038075142.1	99.275	552	1	3	1376	1927	319	867	0.0


#Col 6 shows the proportion match to a sequence in the diptera database. 
#Let's see how much variance there is in the matches: 
awk '{a[i++]=$6;} END {print a[int(i/2)];}' ST_isoseq_BLAST
99.377

#To see the lowest values:
awk '{print $6}'  ST_isoseq_BLAST |sort |tail
99.987
99.987
99.987
99.987
99.987
99.987
99.987
99.987
99.988
99.989

#Similarly the e-values are all really low: 
awk '{print $14}'  ST_isoseq_BLAST |sort |tail
9.99e-60
9.99e-66
9.99e-67
9.99e-72
9.99e-72
9.99e-72
9.99e-75
9.99e-93
9.99e-99
9.99e-99
(base) awk '{print $14}'  ST_isoseq_BLAST |sort |head
0.0
0.0
0.0
0.0
0.0
0.0
0.0
0.0
0.0
0.0

#So we're happy to keep all these transcripts. Let's find a non-redundant set of their names: 
awk '{print $1}' ST_isoseq_BLAST |sort |uniq > ST_BLAST_uniq
wc -l ST_BLAST_uniq
68744 ST_BLAST_uniq

#So that's 2694 transcripts that don't blast to diptera. Or about 3.8% of our isoseq dataset

#Let's intersect these names with the names from the isoseq fasta file, and find the transcript names that need to be removed. 
grep ">" ST_isoseq_pbmm2mapped_to_POMST_collapse.fasta | awk -F ">" '{print $2}' |sort |uniq > ST_fasta_uniq
#Check that this is the expected length (see above for the number of transcripts in the isoseq fasta)
wc -l ST_fasta_uniq 
71438 ST_fasta_uniq

#Intersect and write all lines that appear in SR_allTranscripts_isoseqfasta but not in SR_allBLASTtranscripts_uniq
#Check that the files are sorted (as above)
#Write the transcript names in the fasta file that isn't in the BLAST file
diff ST_fasta_uniq ST_BLAST_uniq |grep "<" |sed 's:<\ ::g' > diff_fasta_BLAST_ST 
wc -l diff_fasta_BLAST_ST 
2694 diff_fasta_BLAST_ST

#Because we want to extract these headers + the sequence following the name, it's easier to work with the list of transcripts to keep.
#Find lines in common between files using comm. -1 suppresses lines unique to file 1, and -2 for file 2
comm -12 ST_BLAST_uniq ST_fasta_uniq > shared_BLAST_fasta_ST
wc -l shared_BLAST_fasta_ST 
68744 shared_BLAST_fasta_ST

#Extract sequences from the fasta file: 
grep -A 1 -f shared_BLAST_fasta_ST ST_isoseq_pbmm2mapped_to_POMST_collapse.fasta > ST_isoseq_pbmm2mapped_to_POMST_collapse_diptera.fasta

#This writes some lines "--" at the end of each extracted transcript. Remove these: 
sed -i '/--/d' ST_isoseq_pbmm2mapped_to_POMST_collapse_diptera.fasta

```

###### 2. Tama collapse


### Pipeline

link to Sade's pipeline and paper


### Final genome figures, tables, and accession numbers. 




# 3. Short Reads

Short read whole genome sequence data was produced for 100 individuals. These data are available on the Short Read Archive (SRA) on NCBI: [LINK]()



## 3a. Assess raw data


## 3b. Map to ST and SR genomes

105 samples (100 WGS + 5 negative controls) were mapped to ST and SR respectively using the following pipeline: 

1. Add Read group information: [02b.0_AddRGs_ARRAY1.sh]()

2. Mark duplicates: [02b.1_MarkDups_ARRAY1.sh]()

3. Local realignment: [02b.2_LocalRealignment_ARRAY1.sh]()

4. Check final bams: [02b.3_ValidateBamFile_ARRAY1.sh]()



## 3c. Assess mapping

samtools flagstat


## 3d. PCA to assign individuals to ST/SR


How many were incorrectly assigned before sequencing? 



# 4. Map Structural variants

Pipeline

## Alignment


## Sniffles


## Filtering



## Re-sequencing


## Genes associated


## Age of inversions


Based on Ruff paper


# 5. Map repeat elements

## RepeatModeler


## Filter


## Final outputs







