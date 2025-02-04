####### 2024-05-15 #############################################################
# Mapa das amostras no inventario de plastideos
# Duas amostras com lat-long NA na tabela do inventario (Fernando2015, Garcia2013)
# substituidos pela media das latLongs em cada trabalho
# corrigida inconsistencia em Fernando2015
################################################################################
# pacote rgeos utilizado para Ilhas do Rio, mas foi descontinuado 
# rgeos substituido por 'terra' e 'sf'
# terra melhor para modelagem de processoas espaciais
# Aqui apenas uma visualizacao simples com 'sp'/sf'
################################################################################
#install.packages("scatterpie")

rm(list=ls())

library(tidyr)
library(scatterpie)
library(sf)
library(rgdal)
library(ggplot2)
#projecoes
sf::sf_use_s2(FALSE)



setwd("/home/arthurw/Documents/Corais/BIOM_Database/Mapa/")

################################################################################
# Preparando o contorno do Brasil a partir da base cartografica do IBGE
#
# wget(ftp://geoftp.ibge.gov.br/cartas_e_mapas/bases_cartograficas_continuas/bc250/versao2017/shapefile/Limites_v2017.zip)
# gunzip ./Limites_v2017.zip
# shapefile baixado do IBGE, e bem pesado
# a pasta shapefile precisa conter os arquivos auxiliares
# 
# Avaliar posteriormente a biblioteca map_data() 
# worldmap <- map_data ("world")
################################################################################

IBGE <- readOGR(dsn = "/home/arthurw/Documents/PMBA/shapefile/", layer="lim_pais_a")

# Original data as sf objects
dt_sf <- st_as_sf(IBGE)
dt_sf <- sf::st_buffer(dt_sf, dist = 0)


################################################################################

d0 <- readxl::read_xlsx("inventario_plastideos-7.24-02-17.mapa.xlsx")
d0$lat <- as.numeric(as.character(d0$lat))
d0$long <- as.numeric(as.character(d0$long))
range(d0$lat)
#[1] -23.800000   0.916667

range(d0$long)
#[1] -45.130 -20.345

################################################################################
# Selecionando so as variaveis a serem plotadas
################################################################################

d <- subset(d0, environment=='coral' & situ=='in_situ')
unique(d$host_species)
#[1] "MHIS"              "MBR"               "MHAR"              "MUS"               "SST"              
#[6] "SST, MHIS"         "T_TAG"             "PO_AS"             "MI_AL"             "Scolymia"   
#[11] "Madracis_decactis"
d$host_genus <- d$host_species
d$host_genus [d$host_species=='MHIS'] <- 'Mussismilia'
d$host_genus [d$host_species=='MBR'] <- 'Mussismilia'
d$host_genus [d$host_species=='MHAR'] <- 'Mussismilia'
d$host_genus [d$host_species=='MUS'] <- 'Mussismilia'
d$host_genus [d$host_species=='SST'] <- 'Siderastrea'
d$host_genus [d$host_species=='SST, MHIS'] <- 'Siderastrea'
d$host_genus [d$host_species=='T_TAG'] <- 'Tubastrea'
d$host_genus [d$host_species=='PO_AS'] <- 'Porites'
d$host_genus [d$host_species=='MI_AL'] <- 'Millepora'
d$host_genus [d$host_species=='Scolymia'] <- 'Scolymia'
d$host_genus [d$host_species=='Madracis_decactis'] <- 'Madracis'

dd.lat <- aggregate(d$lat, list(d$sampling_site), mean)
names(dd.lat)[2] <-'lat2' 
dd.long <- aggregate(d$long, list(d$sampling_site), mean)
names(dd.long)[2] <-'long2' 

dd.M <- merge(dd.lat, dd.long)
names(dd.M)[1] <-'sampling_site'

d2 <- merge(d, dd.M, by='sampling_site')

names(d2)
d2.simp <- d2[,c(1,28,29,30)]
d2.wide <- pivot_wider(d2.simp, names_from =host_genus, values_from = host_genus, values_fn = length, values_fill=0)
d2.wide$Total <- rowSums(d2.wide[,names(d2.wide)[4:10]])

################################################################################
# Plot
# Menos eficiente, mas por enquanto plotando o Brasil todo e cortando as cordenadas no ggplot
################################################################################

p1 <- ggplot(data=dt_sf) +
  geom_sf(data=dt_sf, fill="gray75", colour="black")+
  coord_sf(xlim = c(-49, -28), ylim = c(-30, 2), expand = FALSE)+
  geom_scatterpie(aes(x=long2, y=lat2, group= sampling_site, r=log10(Total)), 
                  cols=names(d2.wide)[4:10], data=d2.wide, alpha=0.9, legend_name = expression("Genus"))+
  geom_scatterpie_legend(log10(d2.wide$Total), labeller = function(x) round(10 ^ x,0), x=-33, y=-25)+
  ylab("")+xlab("")+
  theme_bw()


svg("Mapa.plastideos.Coral.svg", 5,8)
p1
dev.off()
