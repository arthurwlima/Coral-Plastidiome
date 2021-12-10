####################### 20210813 #######################################
# Script para classificar as sequencias de microalgas em resultados de 
# microbiomas de corais - Resultados de SHOTGUN sequencing
# 
#
# Silva 132 (16S)/Silva 138 (16S+18S)
# PR2 4.12 (plastideos 16S)/ 4.14 (plastideos 16S + bacteria/Archeae +18S)
########################################################################


# Ajustar os headers de cada fasta, para conter informacao da amostra de onde vieram
# Substituir '>' por ">IDamostra_"
# Permite concatenar as sequencias, sem perder a das amostras de origem

sed 's/>/>W12_/' Agua_Dez_2010brazilA22.RL10.fasta > W12.fna
sed 's/>/>W02_/' Agua_Fev_2010brazilA25b.RL10.fasta > W02.fna
sed 's/>/>C1D_/' C1DbrazilNeb09.RL1.fasta > C1D.fna
sed 's/>/>C2D_/' C2DbrazilNeb09.RL2.fasta > C2D.fna
sed 's/>/>C3D_/' C3DbrazilNeb09.RL3.fasta > C3D.fna
sed 's/>/>P5S2_/' P5S2brazilNeb08.RL2.fasta > P5S2.fna
sed 's/>/>P5S4_/' P5S4brazilNeb08.RL3.fasta > P5S4.fna
sed 's/>/>P5S5_/' P5S5brazilNeb08.RL4.fasta > P5S5.fna
sed 's/>/>P5W2_/' P5W2brazilNeb09.RL5.fasta > P5W2.fna
sed 's/>/>P5W5_/' P5W5brazilNeb09.RL6.fasta > P5W5.fna
sed 's/>/>P5W6_/' P5W6.fasta > P5W6.fna
sed 's/>/>SGS1_/' SGS1brazilNeb07.RL1.fasta > SGS1.fna
sed 's/>/>SGS2_/' SGS2brazilNeb07.RL2.fasta > SGS2.fna
sed 's/>/>SGS3_/' SGS3.fasta > SGS3.fna
sed 's/>/>SGW1_/' SGW1.fasta > SGW1.fna
sed 's/>/>SGW4_/' SGW4brazilNeb07.RL11.fasta > SGW4.fna
sed 's/>/>SGW5_/' SGW5brazilNeb08.RL12.fasta > SGW5.fna

# Concatenar totos as amostras em unico arquivo fasta
cat *.fna > Garcia2013.fasta
rm *.fna

########################################################################
# Em estudos de shotgun, fragmentos aleatorios do genoma sao sequenciados
# Selecionar sequencias que contenham os genes ribossomais (16S e 18S) #
#    com 'sortmerna'                                                   #
# Depois, e preciso separar o processamento:                           #
#  		16S: Bacterias e Eucariotos (plastideos)                       #
#		18S: Eucariotos (nuclear)                                      #
########################################################################
# sortmerna - fragmentos de DNA possivelmente de origem ribossomal
# confirmar a identificacao com consensus-blastn no qiime2

# Primeira rodada do sortmerna, para indexar a base de dados silva 138 (18S + 16S)
# Nao e necessario rodar multiplas vezes
# sortmerna --ref /media/HD2/Coral16SDB/silva138/seqs/dna-sequences.fasta --workdir /media/HD2/Coral16SDB/shotgun/ &
# [build_index:1190] Begin indexing file /media/HD2/Coral16SDB/silva138/seqs/dna-sequences.fasta of size: 644389223 under index name /media/HD2/Coral16SDB/shotgun/idx/10083924775779930958

sortmerna --ref /media/HD2/Coral16SDB/silva138/seqs/dna-sequences.fasta 
    --idx-dir /media/HD2/Coral16SDB/shotgun/silva138db/idx/ 
    --workdir /media/HD2/Coral16SDB/shotgun/Garcia2013/workdir 
    --reads /media/HD2/Coral16SDB/shotgun/Garcia2013/Garcia2013.fasta  
    --aligned /media/HD2/Coral16SDB/shotgun/Garcia2013/Garcia2013.silva138 --threads 25 --fastx &


# Simplificar o cabecalho para importar no qiime
awk '{print $1}' Garcia2013.silva138.fa > Garcia2013.silva138.simples.fa

###################################################################################################
# Ativar o ambiente qiime2
# Dentro desse ambiente é possivel rodar os programas
conda activate qiime2-2020.11


# exportar um objeto qiime para inspecionar
qiime tools export --input-path ./Garcia2013.silva138.forcaBruta.Silva138.tax.qza --output-path taxonomia

########################################################################
### Classificacao taxonomica - Silva138 (16S+18S) ####################
# Consensus Blastn
# Esse e um processo demorado (acho que umas 2 horas). 
# Importante o simbolo '&' no fim do comando
# O programa vai rodar em segundo plano. Pode deixar o computador trabalhar sozinho :)


### Importar as sequencias para o formato qiime2 (qza)
qiime tools import  --type 'FeatureData[Sequence]' \
  --input-path Garcia2013.silva138.simples.fa \
  --output-path Garcia2013.silva138.forcaBruta.qza &

qiime feature-classifier classify-consensus-blast \
  --i-query Garcia2013.silva138.forcaBruta.qza \
  --i-reference-reads /media/HD2/Coral16SDB/silva138/silva-138-99-seqs.qza \
  --i-reference-taxonomy /media/HD2/Coral16SDB/silva138/silva-138-99-tax.qza \
  --o-classification Garcia2013.silva138.forcaBruta.Silva138.tax.qza \
  --verbose &


########################################################################
# Separar os eucariotos dos procariotos
# Filtrar as TABELAS de ocorrencia de OTUs, com base nas taxonomias
########################################################################
qiime taxa filter-seqs \
  --i-sequences ./Garcia2013.silva138.forcaBruta.qza \
  --i-taxonomy ./Garcia2013.silva138.forcaBruta.Silva138.tax.qza \
  --p-include "d__Eukaryota;" \
  --o-filtered-sequences Garcia2013.silva138.Eukarya.18S.forcaBruta.Silva138.seqs.qza

########## a partir daqui
qiime taxa filter-seqs \
  --i-sequences ./Silveira2017.silva138.forcaBruta.qza \
  --i-taxonomy ./Silveira2017.silva138.forcaBruta.Silva138.tax.qza \
  --p-include "d__Bacteria;","d__Archaea;" \
  --o-filtered-sequences Silveira2017.silva138.Prokaryota.16S.forcaBruta.Silva138.seqs.qza

  
########################################################################
# Filtrar as SEQUENCIAS de plastideos para classificar com phytoREF/PR2 database
qiime taxa filter-seqs \
  --i-sequences ./Silveira2017.silva138.forcaBruta.qza \
  --i-taxonomy ./Silveira2017.silva138.forcaBruta.Silva138.tax.qza \
  --p-include "o__Chloroplast;" \
  --o-filtered-sequences Silveira2017.silva138.forcaBruta.Eukarya.16S.plastid-sequences.qza

########################################################################
########### Classificacao Taxonomica - Microalgas ######################
### Assign Taxonomy - Consensus Blastn #################################
### PR2 Database: https://github.com/pr2database/pr2database/releases/tag/v4.12.0
### https://pr2-database.org/
# Consensus Blastn
qiime feature-classifier classify-consensus-blast \
  --i-query Silveira2017.silva138.forcaBruta.Eukarya.16S.plastid-sequences.qza \
  --i-reference-reads /media/HD2/Coral16SDB/PR2_4.12.0.mothur.qza \
  --i-reference-taxonomy /media/HD2/Coral16SDB/PR2_4.12.0.mothur.taxonomy.qza \
  --o-classification Silveira2017.silva138.forcaBruta.Eukarya.16S.plastid-sequences.PR2_4.12.0.blastn.qza \
  --verbose --p-maxaccepts 3 &


########################################################################
########### Classificacao Taxonomica - Bacteria ######################
# Rodar novamente com Silva 132, por consistencia com os demais trabalhos

qiime feature-classifier classify-consensus-blast \
  --i-query Silveira2017.silva138.Prokaryota.16S.forcaBruta.Silva138.seqs.qza \
  --i-reference-reads /media/HD2/Coral16SDB/SILVA_132_rep_99_16S.qza \
  --i-reference-taxonomy /media/HD2/Coral16SDB/SILVA_132_rep_99_16S_taxonomy7.qza \
  --o-classification Silveira2017.silva138.forcaBruta.Prokaryota.16S.Silva132.blastn.qza \
  --verbose  &


############################# FIM ######################################




########################################################################
################# Comandos antigos e Comentarios #######################
########################################################################
# Preparar qza objects - Importar sequencias do banco de dados Silva
qiime tools import \
--type 'FeatureData[Sequence]' \
--input-path ./../silva_132_99_16S.fna \
--output-path ./../SILVA_132_rep_set_99_16S.qza

# Preparar qza objects - Importar taxonomia das sequencias do Silva
qiime tools import \
--type 'FeatureData[Taxonomy]' \
--input-format HeaderlessTSVTaxonomyFormat \
--input-path ./../taxonomy_7_levels.txt \
--output-path ./../SILVA_132_rep_set_99_16S_taxonomy7.qza

########################################################################
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







########################### 20210811 ###################################
# Analise com --type 'SampleData[Sequences]' e dereplicacao esta gerando
# erros com dados de Silveira2017. As taxonomias geradas pelo consensus-
# blastn apresentavam valores duplicados para as rep.seqs -> possivel 
# erro/inconsistencia nos cabecalhos das sequencias.
# Alem disso, por ser shotgun, a dereplicacao estava diminuindo muito 
# pouco o universo dos dados.
# -> Partindo para um metodo de forca bruta entao, classificando todas as
# sequencias indetificadas pelo sortmeran no sequenciamento
#
# RESUMO:
#
# grep '>' Silveira2017.silva138.fasta -c
# 58339
# grep '>' Silveira2017.silva138.rep-seqs.dereplication/dna-sequences.fasta -c
# 57069
# wc Silveira2017.silva138.rep-seqs.Silva138.tax/taxonomy.tsv 
# 69287
# wc Silveira2017.silva138.rep-seqs.Silva138.tax/taxonomy.rmUnassinged.tsv 
# 12191
#
# 44852 FeatureIDs presentes na tabela biom, mas ausente na taxonomia
# "ValueError: All features ids must be present in taxonomy but the following feature ids are not"
#
# Amostras que tiveram alguma classificacao tb apresentaram uma classificacao 
# como Unassigned, mas com cabecalho diferente, contendo tb a sequencia de origem.
#
# Ex:
# grep '6b0464a3d8b9e728a9d51ace8ddcf69525eb223c' Silveira2017.silva138.rep-seqs.Silva138.tax/taxonomy.tsv 
#
# 6b0464a3d8b9e728a9d51ace8ddcf69525eb223c	d__Bacteria; p__Bacteroidota; c__Bacteroidia; o__Flavobacteriales; f__Flavobacteriaceae; g__Myroides; s__Myroides_odoratimimus	1.0
#
# 6b0464a3d8b9e728a9d51ace8ddcf69525eb223c CBL6_AMRN1:00862:00154	Unassigned	0.0
#
# Essa inconsistencia explica o numero maior de "sequencias" na 
# taxonomia (69287 = 57069 + 12191 (repetidas)) e tambem as FeatureIDs
# presentes na tabela biom (57069) e ausentes na taxonomia (44852 = 57069 - 12191)
########################################################################
########################################################################
### Importar as sequencias para o formato qiime2 (qza)
#qiime tools import  --type 'SampleData[Sequences]' \
#  --input-path ./../Silveira2017.silva138.fasta \
#  --output-path Silveira2017.silva138.qza &
#
### Dereplicacao 
### FASTA - vsearch 
### FASTAQ - DADA2 ou Deblur
#qiime vsearch dereplicate-sequences \
#  --i-sequences Silveira2017.silva138.qza \
#  --o-dereplicated-table Silveira2017.silva138.table.qza \
#  --o-dereplicated-sequences Silveira2017.silva138.rep-seqs.qza
#
# qiime feature-classifier classify-consensus-blast \
#  --i-query Silveira2017.silva138.rep-seqs.qza \
#  --i-reference-reads ./../../../../silva138/silva-138-99-seqs.qza \
#  --i-reference-taxonomy ./../../../../silva138/silva-138-99-tax.qza \
#  --o-classification Silveira2017.silva138.rep-seqs.Silva138.tax.qza \
#  --verbose &
#
# 
# qiime taxa filter-table \
#  --i-table ./Silveira2017.silva138.table.qza \
#  --i-taxonomy ./Silveira2017.silva138.rep-seqs.Silva138.tax.qza \
#  --p-include "d__Bacteria;","d__Archaea;" \
#  --o-filtered-table Silveira2017.silva138.Prokaryota.16S.table.qza
#
########################################################################
