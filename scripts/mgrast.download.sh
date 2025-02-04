#https://help.mg-rast.org/api.html
#https://api-ui.mg-rast.org/api.html#overview
#https://adina-howe.readthedocs.io/en/latest/mgrast/index.html
#https://www.biostars.org/p/94875/

########################################################################
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
