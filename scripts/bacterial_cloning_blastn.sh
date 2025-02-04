########################################################################
# Script to classify microalgae sequences in coral microbiome results
# 
# BACTERIAL CLONING SEQUENCES
#
# To execute, copy and paste each command into the terminal
#
# Sequences downloaded from NCBI accession numbers, as fasta files.
# If needed, sequence description can be simplified
# awk '{print $1}' Castro2013.fasta > Castro2013.simple.fasta
#
########################################################################

# Activate the qiime2 environment
conda activate qiime2-2020.11

########################################################################
### Import Castro2013 sequences into qiime2 format (qza)
qiime tools import  --type 'FeatureData[Sequence]' \
  --input-path Castro2013.simple.fasta \
  --output-path Castro2013.qza &

########################################################################
### Taxonomic classification - Bacteria (SIlva132) ####################

# Consensus Blastn - Classification of Castro2013 results
# This is a lengthy process (about 2 hours).
# The '&' symbol at the end of the command is important.
# The program will run in the background. You can let the computer work on its own :)

qiime feature-classifier classify-consensus-blast \
  --i-query Castro2013.qza \
  --i-reference-reads ./../SILVA_132_rep_set_99_16S.qza
  --i-reference-taxonomy ./../SILVA_132_rep_set_99_16S_taxonomy7.qza
  --o-classification Castro2013-blastn-Silva132.qza \
  --verbose &

########################################################################
# Separate eukaryotes from prokaryotes
# Filter out sequences that are not prokaryotic
# Separate for blastn with phytoREF/PR2 database
qiime taxa filter-seqs \
  --i-sequences ./Castro2013.qza \
  --i-taxonomy ./Castro2013-blastn-Silva132.qza \
  --p-include "Chloroplast","Unassigned" \
  --o-filtered-sequences Castro2013-plastid-sequences.qza


########### Taxonomic Classification - Microalgae ######################
### Assign Taxonomy - Consensus Blastn #################################
### PR2 Database: https://github.com/pr2database/pr2database/releases/tag/v4.12.0
### https://pr2-database.org/

qiime feature-classifier classify-consensus-blast \
  --i-query Castro2013-plastid-sequences.qza \
  --i-reference-reads ./../PR2_4.12.0.mothur.qza \
  --i-reference-taxonomy ./../PR2_4.12.0.mothur.taxonomy.qza \
  --o-classification Castro2013-plastid-sequences.PR2_4.12.0.blastn.qza \
  --verbose --p-maxaccepts 3 &

# Extract files within the qza (classification)
qiime tools export 
--input-path Castro2013-plastid-sequences.PR2_4.12.0.blastn.qza 
--output-path Castro2013-plastid-sequences.PR2_4.12.0.blastn
