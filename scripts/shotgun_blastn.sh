####################### 20210813 #######################################
# Script to classify microalgae sequences in coral microbiome results - 
# metagenomic SHOTGUN sequencing results. 
# Example from: 
# Garcia GD, Gregoracci GB, de O. Santos E, Meirelles PM, Silva GG, Edwards R, Sawabe T, 
# Gotoh K, Nakamura S, Iida T, de Moura RL. Metagenomic analysis of healthy and white 
# plague-affected Mussismilia braziliensis corals. Microbial ecology. 2013 May;65:1076-86.
##############################################################

# Concatenate all samples into a single fasta file
cat *.fna > Garcia2013.fasta
rm *.fna

########################################################################
# In shotgun studies, random genome fragments are sequenced.
# Select sequences containing ribosomal genes (16S and 18S) 
#    with 'sortmerna'                                       
# Afterward, separate processing is required:                
#  	16S: Bacteria and Eukaryotes (plastids)                 
#		18S: Eukaryotes (nuclear)                              
########################################################################

sortmerna --ref "$DATA_DIR/silva138/seqs/dna-sequences.fasta" --idx-dir "$DATA_DIR/shotgun/silva138db/idx/" --reads "$DATA_DIR/shotgun/Garcia2013/Garcia2013.fasta"  --workdir "$DATA_DIR/shotgun/Garcia2013/workdir" --aligned "$DATA_DIR/shotgun/Garcia2013/Garcia2013.silva138" --threads 25 --fastx &

###################################################################################################
# Activate the qiime2 environment
conda activate qiime2-2020.11

########################################################################
### Taxonomic classification - Silva138 (16S+18S) ######################
# Consensus Blastn
# This is a long process (about 2 hours).
# Important: the '&' symbol at the end of the command
# The program will run in the background. You can leave the computer working alone :)

### Import sequences into qiime2 format (qza)
qiime tools import  --type 'FeatureData[Sequence]' \
  --input-path Garcia2013.silva138.fa \
  --output-path Garcia2013.silva138.full.qza &

qiime feature-classifier classify-consensus-blast \
  --i-query Silveira2017.silva138.full.qza \
  --i-reference-reads "$DATA_DIR/silva138/silva-138-99-seqs.qza" \
  --i-reference-taxonomy "$DATA_DIR/silva138/silva-138-99-tax.qza" \
  --o-classification Garcia2013.silva138.full.Silva138.tax.qza \
  --verbose &

########################################################################
# Separate eukaryotes from prokaryotes
# Filter OTU occurrence tables based on taxonomies
########################################################################
qiime taxa filter-seqs \
  --i-sequences ./Garcia2013.silva138.full.qza \
  --i-taxonomy ./Garcia2013.silva138.full.Silva138.tax.qza \
  --p-include "d__Eukaryota;" \
  --o-filtered-sequences Garcia2013.silva138.Eukarya.18S.full.Silva138.seqs.qza

qiime taxa filter-seqs \
  --i-sequences ./Garcia2013.silva138.full.qza \
  --i-taxonomy ./Garcia2013.silva138.full.Silva138.tax.qza \
  --p-include "d__Bacteria;","d__Archaea;" \
  --o-filtered-sequences Garcia2013.silva138.Prokaryota.16S.full.Silva138.seqs.qza

########################################################################
# Filter plastid SEQUENCES for classification with phytoREF/PR2 database
qiime taxa filter-seqs \
  --i-sequences ./Garcia2013.silva138.full.qza \
  --i-taxonomy ./Garcia2013.silva138.full.Silva138.tax.qza \
  --p-include "o__Chloroplast;" \
  --o-filtered-sequences Garcia2013.silva138.full.Eukarya.16S.plastid-sequences.qza

########################################################################
########### Taxonomic Classification - Microalgae ######################
### Assign Taxonomy - Consensus Blastn #################################
### PR2 Database: https://github.com/pr2database/pr2database/releases/tag/v4.12.0
### https://pr2-database.org/
# Consensus Blastn
qiime feature-classifier classify-consensus-blast \
  --i-query Garcia2013.silva138.full.Eukarya.16S.plastid-sequences.qza \
  --i-reference-reads "$DATA_DIR/PR2_4.12.0.mothur.qza" \
  --i-reference-taxonomy "$DATA_DIR/PR2_4.12.0.mothur.taxonomy.qza" \
  --o-classification Garcia2013.silva138.full.Eukarya.16S.plastid-sequences.PR2_4.12.0.blastn.qza \
  --verbose --p-maxaccepts 3 &

########################################################################
########### Taxonomic Classification - Bacteria ########################
# Run again with Silva 132 for consistency with other studies

qiime feature-classifier classify-consensus-blast \
  --i-query Garcia2013.silva138.Prokaryota.16S.full.Silva138.seqs.qza \
  --i-reference-reads "$DATA_DIR/SILVA_132_rep_99_16S.qza" \
  --i-reference-taxonomy "$DATA_DIR/SILVA_132_rep_99_16S_taxonomy7.qza" \
  --o-classification Garcia2013.silva138.full.Prokaryota.16S.Silva132.blastn.qza \
  --verbose &

############################# END ######################################
