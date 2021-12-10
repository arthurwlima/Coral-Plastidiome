################# 2021-12-01 ###########################################
# Script qiime para dereplicacao de amostras de metabarcoding/Illumina
#
# 1 - Pre-tratamento: Cutadapt e demux
# 2 - De-replicacao, denoising e chimera check com DADA2: 
# https://benjjneb.github.io/dada2/tutorial.html
# Our starting point is a set of Illumina-sequenced paired-end fastq 
# files that have been split (or “demultiplexed”) by sample and from 
# which the barcodes/adapters have already been removed. 
#
# 3 - Classificacao taxonomica das representative-sequences, analogo ao 
# processamento de clonagem.
########################################################################

########################################################################
# CUTADAPT - Ferramenta para retirar os primers dos amplicons
# OBS: Nao foi usado para Vilela.microorganism.2021, mas eh uma possivel
# causa para a grande perda de sequencias na ultima biblioteca (SRR9071783)
# OBS2: Como cortamos os 20 primeiros nucleotideos, poderiamos tambem ter
# cortado o primer. Testado o corte nos 25 primeiros nucleotideos 
# (8.1% -> 8.6%)
# OBS3: Primer presente nos reverso-complementares!!!
# 
# Sequencia dos Primers 16S-V4 515F/806R
#>forward (515F)
#GTGYCAGCMGCCGCGGTAA
#
#>forward_revcomp
#TTACCGCGGCKGCTGRCAC
#
#>reverse (806R)
#GGACTACNVGGGTWTCTAAT
#
#>reverse_revcomp
#ATTAGAWACCCNNGTAGTCC
########################################################################
#READ 1
cutadapt -g "GTGYCAGCMGCCGCGGTAA" SRR9071783_1.fastq -o 1FR1.temp.fastq
cutadapt -a "TTACCGCGGCKGCTGRCAC" 1FR1.temp.fastq -o 1FR1.temp1.fastq
cutadapt -a "GGACTACNVGGGTWTCTAAT" 1FR1.temp1.fastq -o 1FR1.temp2.fastq
cutadapt -a "ATTAGAWACCCBNGTAGTCC" 1FR1.temp2.fastq -o SRR9071783.cutadapt.R1.fastq

#READ2
cutadapt -a "GTGYCAGCMGCCGCGGTAA" SRR9071783_2.fastq -o 1FR2.temp.fastq
cutadapt -a "TTACCGCGGCKGCTGRCAC" 1FR2.temp.fastq -o 1FR2.temp1.fastq
cutadapt -g "GGACTACNVGGGTWTCTAAT" 1FR2.temp1.fastq -o 1FR2.temp2.fastq
cutadapt -a "ATTAGAWACCCBNGTAGTCC" 1FR2.temp2.fastq -o SRR9071783.cutadapt.R2.fastq

rm *temp*fastq


### FASTQC  ############################################################
# Vizualizando o controle de qualidade do sequenciamento
# Importante pra definir onde fazer o corte das sequencias e retirar 
# regioes/sequencias com baixa qualidade/muitos erros
#
# FASTQC GERA UM REPORT EM HTML -> PODE SER ABERTO EM NAVEGADOR DE INTERNET
#
# 2021-12-01: Substituir Fastqc por demux do qiime2
#
# fastqc SRR9071774_2.fastq
# fastqc *.fastq &
#
########################################################################
## QIIME 2

conda activate qiime2-2020.11

qiime tools import  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path Vilela.microorganism.manifest.pe \
  --input-format PairedEndFastqManifestPhred33V2 \
  --output-path Vilela.microorganism-bruto-pe.qza &

# Visualizar qualidade - analogo ao fastqc
qiime demux summarize --i-data Vilela.microorganism-pe.cutadat.qza  --o-visualization Vilela.microorganism-pe.cutadat.qzv

###### DADA2 - Denoising ###############################################
# DADA2 dando erro com muitos threads, limitando em 20
# https://github.com/benjjneb/dada2/issues/273
######### FILTERING FASTQC #############################################

nohup qiime dada2 denoise-paired --i-demultiplexed-seqs Vilela.microorganism-bruto-pe.qza \
   --p-trunc-len-f 180 \
   --p-trunc-len-r 180 \
   --p-trim-left-r 20 \
   --p-trim-left-f 20 \
   --verbose \
   --p-n-threads 25 \
   --output-dir dada2_filter.fastqc_output &


cd dada2_filter.fastqc_output


qiime metadata tabulate \
  --m-input-file denoising_stats.qza \
  --o-visualization stats-dada2-filter.fastqc.qzv

qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.filter.fastqc.qzv \
  
qiime feature-table tabulate-seqs \
  --i-data representative_sequences.qza \
  --o-visualization rep-seqs.filter.fastqc.qzv

########################################################################
### Assign Taxonomy - Consensus Blastn #################################
# Consensus Blastn

qiime feature-classifier classify-consensus-blast \
  --i-query representative_sequences.qza \
  --i-reference-reads /media/HD2/Coral16SDB/SILVA_132_rep_99_16S.qza \
  --i-reference-taxonomy /media/HD2/Coral16SDB/SILVA_132_rep_99_16S_taxonomy7.qza \
  --o-classification Vilela.microorganism2021.Silva132.blastn.qza \
  --verbose  &
 

########################################################################
# Filtrar as SEQUENCIAS de plastideos para classificar com phytoREF/PR2 database
qiime taxa filter-seqs \
  --i-sequences ./representative_sequences.qza \
  --i-taxonomy ./Vilela.microorganism2021.Silva132.blastn.qza \
  --p-include "Chloroplast","Unassigned" \
  --o-filtered-sequences Vilela.microorganism2021.Silva132.plastid-sequences.qza


########################################################################
########### Classificacao Taxonomica - Microalgas ######################
### Assign Taxonomy - Consensus Blastn #################################
### PR2 Database: https://github.com/pr2database/pr2database/releases/tag/v4.12.0
### https://pr2-database.org/
# Consensus Blastn
qiime feature-classifier classify-consensus-blast \
  --i-query Vilela.microorganism2021.Silva132.plastid-sequences.qza \
  --i-reference-reads /media/HD2/Coral16SDB/PR2_4.12.0.mothur.qza \
  --i-reference-taxonomy /media/HD2/Coral16SDB/PR2_4.12.0.mothur.taxonomy.qza \
  --o-classification Vilela.microorganism2021.Silva132.plastid-sequences.PR2_4.12.0.blastn.qza \
  --verbose --p-maxaccepts 3 &

