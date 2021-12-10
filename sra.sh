#!/bin/bash 

error=SRAnaoEncontrado
while read LINE; do
echo this_is_one_iteration
QZ1=$(echo $LINE|awk -F "," '{print (!$2)}')
if [[ $QZ1 -eq 0 ]] ; then
 echo $LINE
 echo $error
else
 echo $LINE
 prefetch -X 99999999 $LINE
 fastq-dump /home/arthurw/ncbi/public/sra/$LINE.sra --split-3
fi
done < Bayer2012.SymbA.sra.txt

fastq-dump /home/arthurw/ncbi/public/sra/DRR119200.sra --split-3

#prefetch -X 99999999 DRR119201
#fastq-dump /home/arthurw/ncbi/public/sra/DRR119200.sra
cache-mgr --report

bowtie2 -x /media/HD2/database/Symbiodinium/ITS2-IGV/ITS2db/Chen_ITS2.fasta -U SRR278693.fastq --al Bayer2012.SRR278693.fastq.ITS2.al -S tmp.sam -p 20 -local



samtools view -S -b ITS2.CCMR0100.1182MUBR.rna.sam > ITS2.CCMR0100.1182MUBR.rna.bam
samtools sort ITS2.CCMR0100.1182MUBR.rna.bam -o ITS2.CCMR0100.1182MUBR.rna.sorted.bam
samtools index ITS2.CCMR0100.1182MUBR.rna.sorted.bam



bedtools bamtobed [OPTIONS] -i <BAM>

bedtools getfasta [OPTIONS] -fi <input FASTA> -bed <BED/GFF/VCF> -fo <output FASTA>

