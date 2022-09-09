#Update a local NCBI nt database

#Run in interactive node
qrsh -l tmem=8G, h_vmem=8G


#Work in nt database directory
cd /SAN/ugi/StalkieGenomics/Blobtools_STgenome/ncbi_nt

#Software
export PATH=/share/apps/perl-5.30.0/bin:$PATH
export PATH=/share/apps/genomics/blast-2.10.0+/bin:$PATH

#Install any perl modules that are missing
#e.g., cpanm File::Which

#Script
update_blastdb.pl --decompress nt
