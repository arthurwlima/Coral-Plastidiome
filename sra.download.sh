########################################################################
# Script para download de arquivos SRA do NCBI
# Download pode ser feito um a um, ou fazer um loop na lista de codigos
# de acesso
#
# Conferir em cada trabalho como foi feito o sequenciamento
# Single-end data
# fastq-dump /home/arthurw/ncbi/public/sra/DRR119200.sra -O ./
#
# Paired-end data
# fastq-dump /home/arthurw/ncbi/public/sra/DRR119200.sra --split-3 -O ./
########################################################################

# Baixar o arquivo SRA para a pasta /home/arthurw/ncbi/public/sra
prefetch -X 99999999 SRR3740771
# Transformar o arquivo binario SRA em fastq
fastq-dump /home/arthurw/ncbi/public/sra/SRR3740771.sra


while read line
do
prefetch -X 99999999 $line
fastq-dump /home/arthurw/ncbi/public/sra/$line.sra -O ./ --split-3
done < lista.sra.txt & 


# reportar os arquivos no cache da pasta /home/arthurw/ncbi/public/sra
cache-mgr --report
# limpar o cache
cache-mgr -c
