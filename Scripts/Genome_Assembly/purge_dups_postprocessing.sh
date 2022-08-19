#!/bin/bash

#Goal generate coverage statistics, estimate coverage, and write histogram plot to *.png
# User supplies input file and outfolder
# Eg ./purged_dups_postprocessing.sh *paf.gz test

read input outfile

IN=$input
OUT=$outfile
pbcstat=/SAN/ugi/StalkieGenomics/software/purge_dups/bin/pbcstat
calcuts=/SAN/ugi/StalkieGenomics/software/purge_dups/bin/calcuts

echo "Calculate coverage statistics"
echo ""
echo "$pbcstat $OUT/$IN"
$pbcstat $OUT/$IN
echo ""
echo "estimate cutoffs"
echo ""
echo "$calcuts $OUT/PB.stat > cutoffs 2> calcuts.log"
$calcuts $OUT/PB.stat > cutoffs 2> calcuts.log

