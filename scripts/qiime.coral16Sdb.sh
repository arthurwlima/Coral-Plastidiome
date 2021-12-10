########################################################################
# Script para classificar as sequencias de microalgas em resultados de 
# microbiomas de corais
# 
# Para executar copie e cole cada comando no terminal
#
# Os comandos que comecam com qiime sao em multiplas linhas - so vao  
#
# ToDo List - 2021-01-27: 
#  - Separar as sequencias de acordo com a metodologia usada (Sanger, Illumina)
#  - Avaliar Deblur/vsearch para delimitar OTUs em arquivos fasta
#  - Preparar arquivos de metadados com as sequencias
########################################################################

ssh -p 65000 clarapires@146.164.75.194
# Passwd


# Mudar de diretorio
cd /media/HD2/Coral16SDB

# Ativar o ambiente qiime2
# Dentro desse ambiebte é possivel rodar os programas
conda activate qiime2-2020.2


########################################################################
### Simplificar a descricao das sequencias
# awk '{print $1}' MED_rep_set_no_gaps_fixed_headers.fna > Pollock2018.fasta
### Separar a amostra de origem da sequencia
# grep '>' Castro2013.fasta | awk '{print $1, $5}' > Castro2013.header.sample.tsv

# Listar ferramentas disponiveis no qiime
qiime --help

qiime tools import --help

########################################################################
### Importar as sequencias de Castro2013 para o formato qiime2 (qza)
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path Pollock2018.fasta \
  --output-path Pollock2018.qza &

########################################################################
### Classificacao taxonomica - Bacterias (SIlva132) ####################
#                         20210728                                     #
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
### Consensus Blastn ###################################################
# Preparar qza objects - Importar sequencias do banco de dados Silva
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path silva_132_99_16S.fna \
  --output-path SILVA_132_rep_set_99_16S.qza

# Preparar qza objects - Importar taxonomia das sequencias do Silva
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path taxonomy_7_levels.txt \
  --output-path SILVA_132_rep_set_99_16S_taxonomy7.qza

# Consensus Blastn - Classificacao dos resultados em Castro2013
# Esse e um processo demorado (acho que umas 2 horas). 
# Importante o simbolo '&' no fim do comando
# O programa vai rodar em segundo plano. Pode deixar o computador trabalhar sozinho :)

qiime feature-classifier classify-consensus-blast \
  --i-query Pollock2018.qza \
  --i-reference-reads ./../SILVA_132_rep_set_99_16S.qza \
  --i-reference-taxonomy ./../SILVA_132_rep_set_99_16S_taxonomy7.qza \
  --o-classification Pollock2018-blastn-Silva132.qza \
  --verbose &

########################################################################
# Separar os eucariotos dos procariotos
# Filtrar as sequencias que nao sao procarioticas
# Separar para blastn com phytoREF/PR2 database
qiime taxa filter-seqs \
  --i-sequences ./Pollock2018.qza \
  --i-taxonomy ./Pollock2018-blastn-Silva132.qza \
  --p-include "Chloroplast","Unassigned" \
  --o-filtered-sequences Pollock2018.plastid-sequences.qza



########### Classificacao Taxonomica - Microalgas ######################
### Assign Taxonomy - Consensus Blastn #################################
### PR2 Database: https://github.com/pr2database/pr2database/releases/tag/v4.12.0
### https://pr2-database.org/

# Prepare qza objects
qiime tools import \
--type 'FeatureData[Sequence]' \
--input-path pr2_version_4.12.0_16S_mothur.fasta \
--output-path PR2_4.12.0.mothur.qza

qiime tools import \
--type 'FeatureData[Taxonomy]' \
--input-format HeaderlessTSVTaxonomyFormat \
--input-path  pr2_version_4.12.0_16S_mothur.tax \
--output-path PR2_4.12.0.mothur.taxonomy.qza

# Consensus Blastn
qiime feature-classifier classify-consensus-blast \
  --i-query Pollock2018.plastid-sequences.qza \
  --i-reference-reads ./../PR2_4.12.0.mothur.qza \
  --i-reference-taxonomy ./../PR2_4.12.0.mothur.taxonomy.qza \
  --o-classification Pollock2018.plastid-sequences.PR2_4.12.0.blastn.qza \
  --verbose --p-maxaccepts 3 &

# Importar Biom
qiime tools import \
  --input-path MED_otu_table.biom \
  --type 'FeatureTable[Frequency]' \
  --output-path Pollock2018.biom.qza


qiime taxa barplot \
  --i-table Pollock2018.biom.qza \
  --i-taxonomy  Pollock2018.plastid-sequences.PR2_4.12.0.blastn.qza \
  --m-metadata-file ./gcmp16S_map_r25.reduzido.tsv \
  --o-visualization ./Pollock2018.plastid-sequences.PR2_4.12.0.blastn.barplot.mothur.qzv


