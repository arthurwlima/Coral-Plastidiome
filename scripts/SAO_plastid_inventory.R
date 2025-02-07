#### CODES USED IN THE ARTICLE:
#
# Hidden microalgae diversity in reef systems: exploring plastid communities in Southwestern Atlantic Ocean coral microbiomes
#
# Clara Paiva Pires, Livia Bonetti Villela, Rodrigo Leão Moura, Paulo Sergio Salomon, Arthur Weiss da Silva-Lima
#
# IN THE SESSION REGARDING THE INVENTORY OF PLASTIDS IN THE SAO
######################################################################## ### ### ### #

#### Merge individual studies #######

# Merging metabarcoding
ddZanoti2021LeiteEcol2018 <- merge(dZanoti2021, dLeiteEcol2018, all=T)
ddZanoti2020Leite2017 <- merge(dZanoti2020, dLeite2017, all=T)
ddVilelas <- merge(dVilela.microrganisms2021, dVilela2021, all=T)
ddZanotisLeites <- merge(ddZanoti2021LeiteEcol2018, ddZanoti2020Leite2017, all=T)
dFerPau <- merge(dFernando2015, dPaulino2022, all=T)
dFerPauSan <- merge(dFerPau, dSantoro2021, all=T)
dZLV <- merge(ddVilelas, ddZanotisLeites, all=T)
dZLVFPS <- merge(dZLV, dFerPauSan, all=T)
dTodos <- merge(dVillelainprep, dZLVFPS, all=T)

# shotgun and bacterial cloning
shotclon <- merge(shotgun, clonagem, all=T)
d <- merge(shotclon, dTodos, all=T)

# Remove redundant dataframes
rm(dPaulino2022, dSantoro2021, dFernando2015, dFerPauSan, dFerPau, dZanoti2020, dZanoti2021, 
   dLeite2017, dLeiteEcol2018, dVilela.microrganisms2021, dVilela2021, ddVilelas,
   ddZanotisLeites, ddZanoti2020Leite2017, ddZanoti2021LeiteEcol2018, dVillelainprep, dZLV,
   shotgun, clonagem, dZLVFPS, shotclon, dTodos)

# Sort in alphabetical order
names(d)
d2 <- d[,order(names(d))]
# order: taxonomy followed by metadata
d3 <- d2[,c(2:197,1,198:223)]
# Apply is.na only to tax columns
d3[,1:161][is.na(d3[,1:196])] <- 0

##### Fig. 2A - MAP ########

####### 2024-05-15 ############################################################ #
# Sample map in the plastid inventory
# Two samples with NA lat-long in the inventory table (Fernando2015, Garcia2013)
# replaced by the mean lat-long for each study
# corrected inconsistency in Fernando2015
############################################################################### #
# rgeos package replaced by 'terra' and 'sf'
# terra is better for spatial process modeling
# Here, just a simple visualization using 'sp'/'sf'
############################################################################### #
#install.packages("scatterpie")

rm(list=ls())

library(tidyr)
library(scatterpie)
library(sf)
library(rgdal)
library(ggplot2)
# projections
sf::sf_use_s2(FALSE)

############################################################################### #
# Preparing the contour of Brazil from the IBGE cartographic base
#
# wget(ftp://geoftp.ibge.gov.br/cartas_e_mapas/bases_cartograficas_continuas/bc250/versao2017/shapefile/Limites_v2017.zip)
# gunzip ./Limites_v2017.zip
# shapefile downloaded from IBGE, it’s quite heavy
# the shapefile folder needs to contain the auxiliary files
# 
# Later evaluate the map_data() library 
# worldmap <- map_data ("world")
############################################################################### #

IBGE <- readOGR(dsn = "/home/arthurw/Documents/PMBA/shapefile/", layer="lim_pais_a")

# Original data as sf objects
dt_sf <- st_as_sf(IBGE)
dt_sf <- sf::st_buffer(dt_sf, dist = 0)


###############################################################################  #

d0 <- readxl::read_xlsx("inventario_plastideos-7.24-02-17.mapa.xlsx")
d0$lat <- as.numeric(as.character(d0$lat))
d0$long <- as.numeric(as.character(d0$long))
range(d0$lat)
#[1] -23.800000   0.916667

range(d0$long)
#[1] -45.130 -20.345

############################################################################## ##
# Selecting only the variables to be plotted
############################################################################## ##

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

############################################################################# ###
# Plot
# Less efficient, but for now plotting the whole of Brazil and cutting coordinates in ggplot
############################################################################ ### #

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

##################################### #
##### Fig. 2B - GENUS PREVALENCE ####
##################################### #
setwd("C:/Users/clara/OneDrive/MICROBIOMAS_CORAIS/submissão")

lvl7 <-  read.table("Table_S2.csv", header=T, sep=',', stringsAsFactors=F)

# prevalent genera in situ
insitu <- subset(lvl7, situ == "in_situ")
coral <- subset(insitu, environment == "coral")
agua <- subset(insitu, environment == "H2O")

library("vegan")

#coral
prev_c <- decostand(coral[,1:196], method = "pa")
soma_col <- colSums(prev_c)
freq_c <- soma_col/nrow(coral)
freq_c <- data.frame(Classificacao_Taxonomica_Genero = names(soma_col), Prevalencia_Genero_Coral = freq_c)
freq_coral <- subset(freq_c, Prevalencia_Genero_Coral != "0")

#top 15 in coral samples
prev_coral <- freq_coral[order(freq_coral$Prevalencia_Genero_Coral, decreasing = TRUE), ]
prev_coral <- head(prev_coral, 15)


#water
prev_a <- decostand(agua[,1:196], method = "pa")
soma_col <- colSums(prev_a)
freq_a <- soma_col/nrow(agua)
freq_a <- data.frame(Classificacao_Taxonomica_Genero = names(soma_col), Prevalencia_Genero_Agua = freq_a)
freq_agua <- subset(freq_a, Prevalencia_Genero_Agua != "0")

#top 15 in water samples
prev_agua <- freq_agua[order(freq_agua$Prevalencia_Genero_Agua, decreasing = TRUE), ]
prev_agua <- head(prev_agua, 15)


rm(prev_a, prev_c, soma_col, freq_a, freq_c, freq_agua, freq_coral)


# ONLY CORAL SAMPLES

prev_coral$Genero <- sub(".+\\.(.+)", "\\1", prev_coral$Classificacao_Taxonomica_Genero)

# FIXING CLASSIFICATIONS
#
#Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.__
prev_coral$Genero[prev_coral$Classificacao_Taxonomica_Genero == "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.__"] <- "Raphid.pennate.__"
#Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Raphid.pennate_X
prev_coral$Genero[prev_coral$Classificacao_Taxonomica_Genero == "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Raphid.pennate_X"] <- "Raphid.pennate_X"
#Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Polar.centric.Mediophyceae.__
prev_coral$Genero[prev_coral$Classificacao_Taxonomica_Genero == "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Polar.centric.Mediophyceae.__"] <- "Mediophyceae.__"
#Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.__.__
prev_coral$Genero[prev_coral$Classificacao_Taxonomica_Genero == "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.__.__"] <- "Bacillariophyta_X.__.__"
#Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.__.__.__
prev_coral$Genero[prev_coral$Classificacao_Taxonomica_Genero == "Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.__.__.__"] <- "Florideophyceae.__.__.__"
#

unique(prev_coral$Genero)

# remove classification for transposition
df1 <- subset(prev_coral, select = -c(Classificacao_Taxonomica_Genero))


# transposition
df_melted <- reshape2::melt(df1, id.vars = "Genero", variable.name = "Tipo_Prevalencia", value.name = "Porcentagem")
# remove NA
df_melted <- subset(df_melted, Porcentagem != 0)


# CLASS NAMES
# centric diatoms
df_melted$Classe[df_melted$Genero == "Thalassiosira"] <- "Bacillariophyta (centric)"
df_melted$Classe[df_melted$Genero == "Mediophyceae_X" | df_melted$Genero == "Mediophyceae.__"] <- "Bacillariophyta (centric)"
df_melted$Classe[df_melted$Genero == "Chaetoceros"] <- "Bacillariophyta (centric)"
# penate diatoms
df_melted$Classe[df_melted$Genero == "Raphid.pennate_X" | df_melted$Genero == "Raphid.pennate.__"] <- "Bacillariophyta (pennate)"
df_melted$Classe[df_melted$Genero == "Cylindrotheca"] <- "Bacillariophyta (pennate)"
df_melted$Classe[df_melted$Genero == "Amphora"] <- "Bacillariophyta (pennate)"
df_melted$Classe[df_melted$Genero == "Navicula"] <- "Bacillariophyta (pennate)"

df_melted$Classe[df_melted$Genero == "Bacillariophyta_X.__.__" | df_melted$Genero == "Bacillariophyta_XXX"] <- "Bacillariophyta"
df_melted$Classe[df_melted$Genero == "Ostreobium" | df_melted$Genero == "Bryopsidales_XX"] <- "Ulvophyceae"
df_melted$Classe[df_melted$Genero == "Ectocarpus"] <- "Phaeophyceae"
df_melted$Classe[df_melted$Genero == "Phaeocystis"] <- "Prymnesiophyceae"
df_melted$Classe[df_melted$Genero == "Colpodellidae"] <- "Colpodellidea"
df_melted$Classe[df_melted$Genero == "Calliarthron" | df_melted$Genero == "Florideophyceae.__.__.__"] <- "Florideophyceae"
df_melted$Classe[df_melted$Genero == "Aureococcus"] <- "Pelagophyceae"
df_melted$Classe[df_melted$Genero == "Chloropicon"] <- "Chloropicophyceae"
df_melted$Classe[df_melted$Genero == "Teleaulax"] <- "Cryptophyceae"
df_melted$Classe[df_melted$Genero == "Dictyochophyceae_XXX"] <- "Dictyochophyceae"
df_melted$Classe[df_melted$Genero == "Chrysophyceae_XXX"] <- "Chrysophyceae"
df_melted$Classe[df_melted$Genero == "Ostreococcus"] <- "Mamiellophyceae"
df_melted$Classe[df_melted$Genero == "Pyramimonas"] <- "Pyramimonadales"
df_melted$Classe[df_melted$Genero == "Prymnesiaceae_X"] <- "Prymnesiophyceae"

# environment
df_melted$environment[df_melted$Tipo_Prevalencia == "Prevalencia_Genero_Coral"] <- "coral"

df_coral <- df_melted

cores <- c("Chloropicophyceae" = "#669900", 
           "Mamiellophyceae" = "#9467bd", 
           "Pyramimonadales" = "#CC9933", 
           "Cryptophyceae" = "#ff9896", 
           "Prymnesiophyceae" = "#660066", 
           "Bacillariophyta" = "#17becf", 
           "Chrysophyceae" = "gold", 
           "Dictyochophyceae" = "#e377c2", 
           "Pelagophyceae" = "#8c564b", 
           "Colpodellidea" = "#ff7f0e", 
           "Ulvophyceae" = "chartreuse2", 
           "Florideophyceae" = "#990000", 
           "Phaeophyceae" = "#FF6666",
           "Bacillariophyta (centric)" = "#333366",
           "Bacillariophyta (pennate)" = "#aec7e8")

library("ggplot2")


gb_coral <- ggplot(df_coral, aes(x = Porcentagem, y = reorder(Genero, -Porcentagem), fill = Classe)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = cores) +
  labs(x = "Taxon prevalence in coral samples", y = " ", fill = "Class") +
  ggtitle(" ") +
  theme_minimal() +
  scale_x_continuous(limits = c(0,1.0))+
  theme(legend.position = "right",
        legend.key.size = unit(0.5, "cm"), 
        legend.text = element_text(size = 7), 
        legend.title = element_text(size = 7),
        axis.text = element_text(size = 7),
        axis.title.x = element_text(size = 8))
gb_coral

#
#### ONLY WATER SAMPLES
#

prev_agua$Genero <- sub(".+\\.(.+)", "\\1", prev_agua$Classificacao_Taxonomica_Genero)

# FIXING CLASSIFICATION
#
#Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.__
prev_agua$Genero[prev_agua$Classificacao_Taxonomica_Genero == "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.__"] <- "Raphid.pennate.__"
#Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Raphid.pennate_X
prev_agua$Genero[prev_agua$Classificacao_Taxonomica_Genero == "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Raphid.pennate_X"] <- "Raphid.pennate_X"
#Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Polar.centric.Mediophyceae.__
prev_agua$Genero[prev_agua$Classificacao_Taxonomica_Genero == "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Polar.centric.Mediophyceae.__"] <- "Mediophyceae.__"
#Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.__.__
prev_agua$Genero[prev_agua$Classificacao_Taxonomica_Genero == "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.__.__"] <- "Bacillariophyta_X.__.__"
#Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.__.__.__
prev_agua$Genero[prev_agua$Classificacao_Taxonomica_Genero == "Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.__.__.__"] <- "Florideophyceae.__.__.__"
#

unique(prev_agua$Genero)

# remove classification for transposition
df1 <- subset(prev_agua, select = -c(Classificacao_Taxonomica_Genero))


# transposition
df_melted <- reshape2::melt(df1, id.vars = "Genero", variable.name = "Tipo_Prevalencia", value.name = "Porcentagem")
# remove NA
df_melted <- subset(df_melted, Porcentagem != 0)


# CLASS NAMES
# centric diatoms
df_melted$Classe[df_melted$Genero == "Thalassiosira"] <- "Bacillariophyta (centric)"
df_melted$Classe[df_melted$Genero == "Mediophyceae_X" | df_melted$Genero == "Mediophyceae.__"] <- "Bacillariophyta (centric)"
df_melted$Classe[df_melted$Genero == "Chaetoceros"] <- "Bacillariophyta (centric)"
# penate diatoms
df_melted$Classe[df_melted$Genero == "Raphid.pennate_X" | df_melted$Genero == "Raphid.pennate.__"] <- "Bacillariophyta (pennate)"
df_melted$Classe[df_melted$Genero == "Cylindrotheca"] <- "Bacillariophyta (pennate)"
df_melted$Classe[df_melted$Genero == "Amphora"] <- "Bacillariophyta (pennate)"
df_melted$Classe[df_melted$Genero == "Navicula"] <- "Bacillariophyta (pennate)"

df_melted$Classe[df_melted$Genero == "Bacillariophyta_X.__.__" | df_melted$Genero == "Bacillariophyta_XXX"] <- "Bacillariophyta"
df_melted$Classe[df_melted$Genero == "Ostreobium" | df_melted$Genero == "Bryopsidales_XX"] <- "Ulvophyceae"
df_melted$Classe[df_melted$Genero == "Ectocarpus"] <- "Phaeophyceae"
df_melted$Classe[df_melted$Genero == "Phaeocystis"] <- "Prymnesiophyceae"
df_melted$Classe[df_melted$Genero == "Colpodellidae"] <- "Colpodellidea"
df_melted$Classe[df_melted$Genero == "Calliarthron" | df_melted$Genero == "Florideophyceae.__.__.__"] <- "Florideophyceae"
df_melted$Classe[df_melted$Genero == "Aureococcus"] <- "Pelagophyceae"
df_melted$Classe[df_melted$Genero == "Chloropicon"] <- "Chloropicophyceae"
df_melted$Classe[df_melted$Genero == "Teleaulax"] <- "Cryptophyceae"
df_melted$Classe[df_melted$Genero == "Dictyochophyceae_XXX"] <- "Dictyochophyceae"
df_melted$Classe[df_melted$Genero == "Chrysophyceae_XXX"] <- "Chrysophyceae"
df_melted$Classe[df_melted$Genero == "Ostreococcus"] <- "Mamiellophyceae"
df_melted$Classe[df_melted$Genero == "Pyramimonas"] <- "Pyramimonadales"
df_melted$Classe[df_melted$Genero == "Prymnesiaceae_X"] <- "Prymnesiophyceae"


# environment
df_melted$environment[df_melted$Tipo_Prevalencia == "Prevalencia_Genero_Agua"] <- "agua"

df_agua <- df_melted

gb_agua <- ggplot(df_agua, aes(x = Porcentagem, y = reorder(Genero, -Porcentagem), fill = Classe)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = cores) +
  labs(x = "Taxon prevalence in water samples", y = "", fill = "Class") +
  ggtitle(" ") +
  theme_minimal() +
  scale_x_continuous(limits = c(0,1.0))+
  theme(legend.position = "right",
        legend.key.size = unit(0.5, "cm"), 
        legend.text = element_text(size = 7), 
        legend.title = element_text(size = 7),
        axis.text = element_text(size = 7),
        axis.title.x = element_text(size = 8))
gb_agua

# patchwork both environment plots
library(patchwork)

res_prev <- (gb_agua / gb_coral) +
  theme(legend.position = "right",
        legend.key.size = unit(0.5, "cm"), 
        legend.text = element_text(size = 7), 
        legend.title = element_text(size = 7),
        axis.text = element_text(size = 7))

setwd("C:/Users/clara/OneDrive/MICROBIOMAS_CORAIS/ressubmissão_revisão/figuras")
pdf("prev_inv.pdf", 6,5)
res_prev
dev.off()


##### Fig. S1 - PREVALENT CLASSES #####
#
######################## ######## #
# Counting prevalence
######################## ######## #

# using an inventory constructed in the same way as the published one, but at the class level.

library("vegan")

# total prevalence of classes (41 classes in total)
prev_t <- decostand(insitu[,1:41], method = "pa")
soma_col <- colSums(prev_t)
freq_t <- soma_col/nrow(insitu)
freq_t <- data.frame(Classificacao_Taxonomica_Classe = names(soma_col), Prevalencia_Classe_Total = freq_t)
freq_total <- subset(freq_t, Prevalencia_Classe_Total != "0")

freq_total$Classe <- sapply(strsplit(freq_total$Classificacao_Taxonomica_Classe, "\\."), function(x) x[4])


# only coral samples

prev_c <- decostand(coral[,1:41], method = "pa")
soma_col <- colSums(prev_c)
freq_c <- soma_col/nrow(coral)
freq_c <- data.frame(Classificacao_Taxonomica_Classe = names(soma_col), Prevalencia_Classe_Coral = freq_c)
freq_coral <- subset(freq_c, Prevalencia_Classe_Coral != "0")

freq_coral$Classe <- sapply(strsplit(freq_coral$Classificacao_Taxonomica_Classe, "\\."), function(x) x[4])


# only water samples

prev_a <- decostand(agua[,1:41], method = "pa")
soma_col <- colSums(prev_a)
freq_a <- soma_col/nrow(agua)
freq_a <- data.frame(Classificacao_Taxonomica_Classe = names(soma_col), Prevalencia_Classe_Agua = freq_a)
freq_agua <- subset(freq_a, Prevalencia_Classe_Agua != "0")

freq_agua$Classe <- sapply(strsplit(freq_agua$Classificacao_Taxonomica_Classe, "\\."), function(x) x[4])

rm(prev_a,prev_c,prev_t,soma_col,freq_a,freq_c,freq_t)

#merge
merged_df <- merge(freq_total, freq_coral, all=T)
prev1 <- merge(merged_df, freq_agua, all=T)

#save
write.table(prev1, "prev_4_merge.csv", row.names = F, sep=',')

######################## ######## #
# Prepping for the graph
######################## ######## #

classe_prev <-  read.table("prev_4_merge.csv", header=T, sep=',', stringsAsFactors=F)

library(ggplot2)

# remove collumns
df1 <- subset(classe_prev, select = -c(Classificacao_Taxonomica_Classe, Prevalencia_Classe_Total))
# List of wanted names
nomes_classe_desejados <- c("Bacillariophyta", "Ulvophyceae", "Florideophyceae", "Prymnesiophyceae", "Colpodellidea", 
                            "Phaeophyceae", "Chloropicophyceae", "Phaeophyceae", "Dictyochophyceae", "Mamiellophyceae", 
                            "Cryptophyceae", "Pelagophyceae")

# Mantaining these wanted lines
df2 <- df1[df1$Classe %in% nomes_classe_desejados, ]


df_melted <- reshape2::melt(df2, id.vars = "Classe", variable.name = "Tipo_Prevalencia", value.name = "Porcentagem")

library(ggplot2)

# Labels
labels_matrix <- c("Coral", "Water")

# Colors
cores <- c("coral", "#6baed6")

# Rename labels
df_melted$Tipo_Prevalencia <- factor(df_melted$Tipo_Prevalencia, 
                                     levels = c("Prevalencia_Classe_Coral", "Prevalencia_Classe_Agua"),
                                     labels = labels_matrix)


ordem_classes <- c("Ulvophyceae", "Florideophyceae", 
                   "Bacillariophyta", "Colpodellidea", "Phaeophyceae", 
                   "Chloropicophyceae", "Prymnesiophyceae", "Pelagophyceae", 
                   "Cryptophyceae", "Mamiellophyceae", "Dictyochophyceae")

# class prevalence graph:
barplot_prev_classe <- ggplot(df_melted, aes(x = factor(Classe, levels = ordem_classes), y = Porcentagem, fill = Tipo_Prevalencia)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  labs(x = " ", y = " ", fill = "Matrix") +
  scale_fill_manual(values = cores, labels = labels_matrix) +  # Definir cores e rótulos
  theme(legend.position = "bottom") + # Mover a legenda para baixo
  coord_flip()


