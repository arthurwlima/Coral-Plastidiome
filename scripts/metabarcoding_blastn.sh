################# 2021-12-01 ###########################################
# Qiime script for dereplication of metabarcoding/Illumina samples
#
# 1 - Pre-processing: Cutadapt and DEMUX
# 2 - Dereplication with DADA2:
# 3 - Taxonomic classification of representative sequences
# 
# In this script, 16S-V4 metabarcoding data from the manuscript below are used as ana example:
#
# Vilela CL, Villela HD, Rachid CT, Carmo FL, Vermelho AB, Peixoto RS. Exploring the diversity 
# and biotechnological potential of cultured and uncultured coral-associated bacteria. 
# Microorganisms. 2021 Oct 27;9(11):2235.results from the 
########################################################################

########################################################################
# CUTADAPT - Tool to remove primers from amplicons
# 
# 16S-V4 Primer Sequences 515F/806R
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

########################################################################
# 20220125 - AUTOMATING CUTADAPT WITH A 'for' LOOP IN bash
# Removing temporary files in each loop to save disk space
########################################################################

# FORWARD READS
for i in *_1.fastq; 
  do 
    echo $i;
    cutadapt -g "GTGYCAGCMGCCGCGGTAA" $i -o temp.$i > "${i}.log";
    cutadapt -a "TTACCGCGGCKGCTGRCAC" temp.$i -o temp1.$i >> "${i}.log1";
    cutadapt -a "GGACTACNVGGGTWTCTAAT" temp1.$i -o temp2.$i >> "${i}.log2";
    cutadapt -a "ATTAGAWACCCBNGTAGTCC" temp2.$i -o "${i}.cutadapt.R1.fastq" >> "${i}.log3";
    rm temp*;
  done

# REVERSE READS
for j in *_2.fastq; 
  do 
    echo $j;
    cutadapt -a "GTGYCAGCMGCCGCGGTAA" $j -o temp.$j > "${j}.log";
    cutadapt -a "TTACCGCGGCKGCTGRCAC" temp.$j -o temp1.$j >> "${j}.log1";
    cutadapt -g "GGACTACNVGGGTWTCTAAT" temp1.$j -o temp2.$j >> "${j}.log2";
    cutadapt -a "ATTAGAWACCCBNGTAGTCC" temp2.$j -o "${j}.cutadapt.R2.fastq" >> "${j}.log3";
    rm temp*;
  done

## VIEW QUALITY with DEMUX
## in QIIME 2

conda activate qiime2-2020.11

qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path Vilela.microorganism.manifest.pe \
  --input-format PairedEndFastqManifestPhred33V2 \
  --output-path Vilela.microorganism-bruto-pe.qza &

# View quality - similar to fastqc
qiime demux summarize --i-data Vilela.microorganism-pe.cutadat.qza --o-visualization Vilela.microorganism-pe.cutadat.qzv

###### DADA2 - Denoising ###############################################
# DADA2 has issues with too many threads, limiting to 20
# https://github.com/benjjneb/dada2/issues/273
######### FILTERING FASTQC #############################################

nohup qiime dada2 denoise-paired --i-demultiplexed-seqs Vilela.microorganism-bruto-pe.qza \
   --p-trunc-len-f 230 \
   --p-trunc-len-r 210 \
   --p-trim-left-r 20 \
   --p-trim-left-f 20 \
   --verbose \
   --p-n-threads 20 \
   --output-dir dada2_filter.fastqc_output

qiime metadata tabulate \
  --m-input-file denoising_stats.qza \
  --o-visualization stats-dada2-filter.fastqc.qzv

qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.filter.fastqc.qzv
  
qiime feature-table tabulate-seqs \
  --i-data representative_sequences.qza \
  --o-visualization rep-seqs.filter.fastqc.qzv

########################################################################
### Assign Taxonomy - Consensus Blastn #################################
# Consensus Blastn

cd dada2_filter.fastqc_output

qiime feature-classifier classify-consensus-blast \
  --i-query representative_sequences.qza \
  --i-reference-reads /media/HD2/Coral16SDB/SILVA_132_rep_99_16S.qza \
  --i-reference-taxonomy /media/HD2/Coral16SDB/SILVA_132_rep_99_16S_taxonomy7.qza \
  --o-classification Vilela.microorganism2021.Silva132.blastn.qza \
  --verbose  &

########################################################################
# Filter CHLOROPLAST sequences to classify with phytoREF/PR2 database
qiime taxa filter-seqs \
  --i-sequences ./representative_sequences.qza \
  --i-taxonomy ./Vilela.microorganism2021.Silva132.blastn.qza \
  --p-include "Chloroplast","Unassigned" \
  --o-filtered-sequences Vilela.microorganism2021.Silva132.plastid-sequences.qza

########################################################################
########### Taxonomic Classification - Microalgae ######################
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
