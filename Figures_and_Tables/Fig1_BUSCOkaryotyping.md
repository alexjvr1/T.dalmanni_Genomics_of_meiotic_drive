# Busco karyotyping figure

Goal: To create a figure of the BUSCO gene alignments between ST and SR genome. 

We'll create an additional figure including the Drosophila melanogaster aligntments. 

#### *Step 1*

BUSCO assessment of all three genomes (D. melanogaster, ST and SR). The two T.dalmanni genomes were assessed above. Modify the BUSCO script for the D. melanogaster genome downloaded from NCBI: [GCF_000001215.4_Release_6_plus_ISO1_MT_genomic.fna](https://www.ncbi.nlm.nih.gov/assembly/GCF_000001215.4/)

Create an alignment of BUSCO genes between ST and SR genomes and D. melanogaster

Taken from [BUSCO_karyotyping](https://github.com/swomics/BUSCO_karyotyping) by Sam Whiteford

In BUSCO 5.0.0 there is a bug in formatting for the "Sequence" column where a few loci contain the loci "Sequence:start-end format". Use awk to filter these out. 

Where "Species" is the folder name for the genome that was assessed with BUSCO. 
```
awk 'BEGIN{FS="\t";OFS=FS}($3 !~ /:/){print}' Species/run_diptera_odb10/full_table.tsv > Species_name_busco.tsv

```


#### *Step 2*

Use awk to select only the first 8 columns of each BUSCO file: 

```
awk '{print $1, $2, $3, $4, $5, $6, $7, $8, sep="\"}' Species_name_busco.tsv > Species_name_busco_forR.tsv
```

#### *Step 3*

Use grep to select only the Complete genes

```
grep "Complete" Species_name_busco_forR.tsv > Species_name_busco_forR_COMPLETEonly.tsv
```

#### *Step 4*

Read into R and check that the headers are identical
```
TdelSR <- read.table(Tdel_SR_busco_forR_COMPLETEonly.tsv, header=T)

head(TdelSR)

head(TdelSR)
    Buscoid   Status Sequence GeneStart   GeneEnd Strand   Score Length
1  20at7147 Complete     Chr2  65275711  65359704      - 10756.3   6910
2  29at7147 Complete     Chr2    370997    407072      +  9026.6   4252
3  51at7147 Complete     Chr1  33765339  33787842      -  6931.3   3460
4  80at7147 Complete     Chr2 110195194 110273805      +  6629.7   4141
5  94at7147 Complete     Chr2 119885155 119906673      -  4156.1   2864
6 158at7147 Complete     Chr1  68017939  68037704      +  3490.3   2827

```



Combine the three datasets by Buscoid to select only the overlapping genes
```
library(dplyr)
join <- dplyr::inner_join(Dmel_Complete, TdelSR_overlap_complete, by="Buscoid")
join2 <- dplyr::inner_join(join, TdelST_Complete, by="Buscoid")

Dmel_overlap <- dplyr::select(join2, Buscoid, Status.x, Sequence.x, GeneStart.x, GeneEnd.x, Strand.x, Score.x, Length.x)
TdelSR_overlap <- dplyr::select(join2, Buscoid, Status.y, Sequence.y, GeneStart.y, GeneEnd.y, Strand.y, Score.y, Length.y)
TdelST_overlap <- dplyr::select(join2, Buscoid, Status, Sequence, GeneStart, GeneEnd, Strand, Score, Length)

colnames(Dmel_overlap) <- colnames(TdelST_overlap)
colnames(TdelSR_overlap) <- colnames(TdelST_overlap)
```

Adjust the GeneStart relative to the start of the genome. Get these numbers from the genome index file (.fa.fai)
```
#For STgenome, scaffold 1= ChrX, scaffold 2= Chr2, scaffold 3= Chr1
TdelST_overlap$GeneStart <- as.numeric(TdelST_overlap$GeneStart)
#TdelST_overlap_relativeStart <- TdelST_overlap %>% mutate(Pos=case_when(Sequence %in% "Chr1" ~ GeneStart, Sequence %in% "Chr2" ~ GeneStart+143175544, Sequence %in% "ChrX" ~ GeneStart+294389338))
#ST is in the opposite orientation to SR, so we need to subtract the GeneStart from the expected length of the genome at that point: 
TdelST_overlap_relativeStart <- TdelST_overlap %>% mutate(Pos=case_when(Sequence %in% "Chr1" ~ 143175544-GeneStart, Sequence %in% "Chr2" ~ 294389338-GeneStart, Sequence %in% "ChrX" ~ 394804183-GeneStart))


TdelSR_overlap$GeneStart <- as.numeric(TdelSR_overlap$GeneStart)
TdelSR_overlap_relativeStart <- TdelSR_overlap %>% mutate(Pos=case_when(Sequence %in% "Chr1" ~ GeneStart, Sequence %in% "Chr2" ~ GeneStart+159530236, Sequence %in% "ChrX" ~ GeneStart+307948524))

Dmel_overlap$GeneStart <- as.numeric(Dmel_overlap$GeneStart)
Dmel_overlap_relativeStart <- Dmel_overlap %>% mutate(Pos=case_when(Sequence %in% "Chr2L" ~ GeneStart, Sequence %in% "Chr2R" ~ GeneStart+23513712, Sequence %in% "Chr3L" ~ GeneStart+48800648, Sequence %in% "Chr3R" ~ GeneStart+76910875, Sequence %in% "Chr4" ~ GeneStart+108990206, Sequence %in% "ChrX" ~ GeneStart+110338337))
Dmel_overlap_relativeStart2 <- Dmel_overlap_relativeStart
Dmel_overlap_relativeStart2$Pos <- as.numeric(Dmel_overlap_relativeStart$Pos*5)

```

Add a Species column to each dataset
```
TdelST_overlap_relativeStart$Species <- "TdelST"
TdelSR_overlap_relativeStart$Species <- "TdelSR"
Dmel_overlap_relativeStart$Species <- "Dmel"

```

rescale position because D.mel is much smaller than T.dal
```
library(scales)
Dmel_overlap_relativeStart$RescaledPos <- rescale(Dmel_overlap_relativeStart$Pos, to =c(0,600))
TdelSR_overlap_relativeStart$RescaledPos <- rescale(TdelSR_overlap_relativeStart$Pos, to =c(0,600))
TdelST_overlap_relativeStart$RescaledPos <- rescale(TdelST_overlap_relativeStart$Pos, to =c(0,600))
```



Join the three datasets
```
TdelSR_Dmel_ST_joined <- dplyr::bind_rows(TdelSR_overlap_relativeStart, Dmel_overlap_relativeStart, TdelST_overlap_relativeStart)

#Make sure we have only chromosomes in the final dataset
TdelSR_Dmel_ST_joined2 <- TdelSR_Dmel_ST_joined %>% filter(grepl("Chr", Sequence)) 

#To keep species order
#TdelSR_Dmel_W_joined2$Species <- factor(TdelSR_Dmel_W_joined2$Species, levels=c("Dmel", "TdelSR", "TdelW"))

#Tdel only
TdelSR_ST_joined <- dplyr::bind_rows(TdelSR_overlap_relativeStart, TdelST_overlap_relativeStart)


```

Plot
```
library(ggplot2)

ggplot(TdelSR_Dmel_ST_joined, aes(x=Species, y=RescaledPos))+geom_point()+geom_line(aes(group=Buscoid, colour=Sequence), alpha=0.4)

#Tdal X only
pdf("Tdal_BUSCO_ChrXaln.pdf")
ggplot(Tdel_joined[which(Tdel_joined$Sequence=="ChrX"),], aes(x=Species, y=GeneStart))+geom_point()+geom_line(aes(group=Buscoid, colour=Sequence), alpha=0.4)
dev.off()
```

