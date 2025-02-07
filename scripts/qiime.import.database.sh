########################################################################
# Importing Silva and PR2 databases into qiime2 objects
########################################################################

conda activate qiime2-2020.2

########################################################################
### Classificacao taxonomica - Bacterias (Silva132) ####################
# Arquivo silva_132_99_16S.fna baixado do silva, sob o protocolo descrito em   #
# https://www.arb-silva.de/fileadmin/silva_databases/qiime/Silva_128_notes.txt #
# https://docs.qiime2.org/2020.2/data-resources/                       #       
# Contem 369953 sequencias - 504M
#	- 350452 Bacteria
#	-  19501 Archaea
#
# Arquivo silva-138-99-seqs.qza baixado diretamente do qiime, 2021.04  #
# https://docs.qiime2.org/2021.4/data-resources/
# Contem 436680 Sequencias - 615M
# 	- 369895 Bacteria
#	-  19121 Archaea
#	-  47664 Eukaryota (18S)
########################################################################

########################################################################
# Importing sequences
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path silva_132_99_16S.fna \
  --output-path SILVA_132_rep_set_99_16S.qza

########################################################################
# Importing taxonomies
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path taxonomy_7_levels.txt \
  --output-path SILVA_132_rep_set_99_16S_taxonomy7.qza


########################################################################
### PR2 Database: https://github.com/pr2database/pr2database/releases/tag/v4.12.0
### https://pr2-database.org/

qiime tools import \
--type 'FeatureData[Sequence]' \
--input-path pr2_version_4.12.0_16S_mothur.fasta \
--output-path PR2_4.12.0.mothur.qza

qiime tools import \
--type 'FeatureData[Taxonomy]' \
--input-format HeaderlessTSVTaxonomyFormat \
--input-path  pr2_version_4.12.0_16S_mothur.tax \
--output-path PR2_4.12.0.mothur.taxonomy.qza

