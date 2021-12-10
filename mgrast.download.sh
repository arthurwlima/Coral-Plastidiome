#https://help.mg-rast.org/api.html
#https://api-ui.mg-rast.org/api.html#overview
#https://adina-howe.readthedocs.io/en/latest/mgrast/index.html

#Retrieve information formatted as a JSON object about all the files available for download for metagenome mgm4447943.3 with information about the files and sequence statistics where applicable. Each file listed has a URL included which can be used to download the file, e.g.
# file 050.1 - uploaded files {"data_type":"sequence","file_size":334253012,"file_name":"mgm4516541.3.050.upload.fna","stage_name":"upload","id":"mgm4516541.3","node_id":"30bbcadd-8fc0-436e-873a-f44e5df0ca54","seq_format":"bp","statistics":
	#{"length_min":100,"average_ambig_chars":0.056,"length_max":1101,"average_length":453.251,"ambig_sequence_count":31970,"standard_deviation_length":203.347,"bp_count":296013683,"ambig_char_count":36455,"average_gc_content":45.935,"sequence_count":653090,"standard_deviation_gc_ratio":0.355,"average_gc_ratio":1.228,"standard_deviation_gc_content":6.714},"url":"https://api.mg-rast.org/download/mgm4516541.3?file=050.1","file_format":"fna","file_id":"050.1","stage_id":"050","file_md5":"6c36e1735d33460c48811683e43d097c"},

########################################################################
# Arquivos de upload (050.1) nao estavam disponiveis para os dados de 
# ion torrent de Moreira 2015 (mgm4584423.3, mgm4584424.3).
# Foram baixados os arquivos 299.1
# Estrutura de arquivos/analises do MG-Rast
# 050.1 - Upload
# 	100.1 - Passed Adapter Trimming, Denoising and normalization
# 	100.2 - Failed Adapter Trimming, Denoising and normalization
# 		150.1 - Passed Removal of sequencing artifacts (shotgun metagenomics - DRISREE)
# 		150.2 - Failed Removal of sequencing artifacts (shotgun metagenomics - DRISREE)
# 			299.1 - Passed Host DNA contamination removal
#
########################################################################
	
########################################################################
# Carlos 2014
# Madracis  	4516541.3 
# Mussismilia 	4516694.3
########################################################################

curl "https://api.mg-rast.org/1/download/mgm4516541.3" > mgm4516541.3.json
curl "https://api.mg-rast.org/1/download/mgm4516541.3?file=050.1" > 4516541.3.fasta

curl "https://api.mg-rast.org/1/download/mgm4516694.3" > mgm4516694.3.json
curl "https://api.mg-rast.org/1/download/mgm4516694.3?file=050.1" > 4516694.3.fasta


########################################################################
#https://www.biostars.org/p/94875/

while read line
do
curl -X GET -H "auth: 8X8GAcZhq7M9xGRJS8EcxWJik" https://api.mg-rast.org/1/download/"$line"  > $line.json
curl -X GET -H "auth: 8X8GAcZhq7M9xGRJS8EcxWJik" https://api.mg-rast.org/1/download/"$line"?file=050.1 --keepalive-time 2 > $line.fasta
done < Garcia2013.MG-rast.metagenomeId.txt


while read line
do
curl  https://api.mg-rast.org/1/download/"$line"  > $line.json
curl  https://api.mg-rast.org/1/download/"$line"?file=050.1 --keepalive-time 2 > $line.fasta
done < ./../Meirelles2014.metagenomeId.txt
