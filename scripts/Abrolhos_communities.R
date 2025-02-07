#Meu
setwd("C:/Users/clara/OneDrive/MICROBIOMAS_CORAIS/Resultados/analises_ecologicas/level-7")
# Yara
setwd("/home/clarapires/Documents/inventario")
lvl7 <- read.table("Villela_in_prep_rareado-987.level-7.csv", header=T, sep=',', stringsAsFactors=F)

#### !!! Tempo 3

lvl7$Tempo3[lvl7$Tempo2 == "May-21"] <- "2021-05"
lvl7$Tempo3[lvl7$Tempo2 == "Sep-21"] <- "2021-09"
lvl7$Tempo3[lvl7$Tempo2 == "Apr-22"] <- "2022-04"

### SUBSETS
#

controles <- subset(lvl7, lvl7$tratamento == "controle" | lvl7$tratamento == "controle_agua")
coral <- subset(controles, controles$environment == "coral")
agua <- subset(controles, controles$environment == "H2O")

# retirar macro ##### TESTE ########
names(controles)
palavras_remover <- c("Phaeophyceae", "Bryopsis", "Caulerpella", "Codium", 
                      "Acrosiphonia", "Erythrotrichia", "Callithamniaceae", 
                      "Antithamnionella", "Wrangeliaceae", "Palmaria", 
                      "Corallinales", "Calliarthron", "Pterocladiella", 
                      "Grateloupia", "Embryophyceae", "Ectocarpus", 
                      "Fucus", "Saccharina", "Vaucheria")

library(dplyr)
df_filtrado <- controles %>%
  select(-matches(paste(palavras_remover, collapse = "|")))

colunas_para_manter <- !grepl(paste(palavras_remover, collapse = "|"), names(controles))
df_filtrado2 <- controles[, colunas_para_manter]

coral <- subset(df_filtrado, df_filtrado$environment == "coral")
agua <- subset(df_filtrado, df_filtrado$environment == "H2O")


### DIV ALFA (DIV_SHANNON) ##############

# ANOVA entre recifes e entre coral/agua


### environment ###
environment_shannon <- aov(Diversity_Shannon ~ environment, data = controles)
summary(environment_shannon)
"            Df Sum Sq Mean Sq F value   Pr(>F)    
environment  1  13.38  13.378    44.3 5.67e-08 ***
Residuals   40  12.08   0.302"


# comparando cada combinação recife tempo independentemente NO CORAL

environment_shannon <- aov(Diversity_Shannon ~ sampling_reef * Tempo3, data = coral)
summary(environment_shannon)
"                     Df Sum Sq Mean Sq F value  Pr(>F)   
sampling_reef         2  2.360  1.1801   5.226 0.01702 * 
Tempo3                2  0.363  0.1817   0.805 0.46361   
sampling_reef:Tempo3  2  4.085  2.0423   9.044 0.00211 **
Residuals            17  3.839  0.2258"

# na AGUA
environment_a_shannon <- aov(Diversity_Shannon ~ sampling_reef * Tempo3, data = agua)
summary(environment_a_shannon)
"                     Df Sum Sq Mean Sq F value   Pr(>F)    
sampling_reef         2 0.3109  0.1555   22.63 0.000126 ***
Tempo3                2 0.3189  0.1595   23.21 0.000113 ***
sampling_reef:Tempo3  2 0.7266  0.3633   52.89 2.28e-06 ***
Residuals            11 0.0756  0.0069"


# grafico div agua X coral por recife
library(ggplot2)

facet_labels <- c("coral" = "Coral tissue", 
                  "H2O" = "Water")

div_transp <- ggplot(data = controles, aes(x = sampling_reef, y= Diversity_Shannon, fill = Tempo3, color = Tempo3)) +
  geom_boxplot() +
  facet_wrap(vars(environment), labeller = labeller(environment = facet_labels)) +
  scale_fill_manual(values = c("2021-05" = "lightblue", 
                               "2021-09" = "lightgreen",
                               "2022-04" = "coral"),
                    labels = c("2021-05" = "May 2021", 
                               "2021-09" = "September 2021",
                               "2022-04" = "April 2022"),
                    name =  " ") +
  scale_color_manual(values = c("2021-05" = "darkblue", 
                                "2021-09" = "darkgreen",
                                "2022-04" = "darkred")) +
  guides(color = "none") +
  xlab(" ") +
  ylab("Shannon Diversity") +
  theme(legend.position = "bottom",
        axis.text.x = element_text(hjust = 1, size = 10), 
        axis.title.x = element_text(size = 10),                       
        axis.title.y = element_text(size = 12),               
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 10))

div_transp

#ggsave("Fig.3_.teste.png", plot = div_transp, width = 100, height = 30, 
#       units = "px", device = "png", dpi = 300, limitsize = FALSE)

setwd("C:/Users/clara/OneDrive/MICROBIOMAS_CORAIS/ressubmissão_revisão/figuras")

svg("div_abrolhos.svg", 4, 4)
div_transp
dev.off()


#### EMMEANS ############

library(emmeans)

lvl7$Tempo4[lvl7$Tempo2 == "May-21"] <- "May 21"
lvl7$Tempo4[lvl7$Tempo2 == "Sep-21"] <- "Sep 21"
lvl7$Tempo4[lvl7$Tempo2 == "Apr-22"] <- "Apr 22"

controles <- subset(lvl7, lvl7$tratamento == "controle" | lvl7$tratamento == "controle_agua")
coral <- subset(controles, controles$environment == "coral")
agua <- subset(controles, controles$environment == "H2O")

environment_shannon <- aov(Diversity_Shannon ~ sampling_reef * Tempo4, data = coral)
summary(environment_shannon)
# igual ao Tempo3

env_means <- emmeans(environment_shannon, specs = pairwise ~ Tempo4 | sampling_reef)
env_means

"$emmeans
sampling_reef = ESQ:
 Tempo3  emmean    SE df lower.CL upper.CL
 2021-05  0.755 0.274 17    0.176     1.33
 2021-09  0.444 0.274 17   -0.135     1.02
 2022-04 nonEst    NA NA       NA       NA

sampling_reef = PAB:
 Tempo3  emmean    SE df lower.CL upper.CL
 2021-05  1.557 0.274 17    0.978     2.14
 2021-09  1.859 0.274 17    1.281     2.44
 2022-04  0.776 0.238 17    0.275     1.28

sampling_reef = SG:
 Tempo3  emmean    SE df lower.CL upper.CL
 2021-05 nonEst    NA NA       NA       NA
 2021-09  0.798 0.238 17    0.297     1.30
 2022-04  1.818 0.238 17    1.316     2.32

Confidence level used: 0.95 

$contrasts
sampling_reef = ESQ:
 contrast              estimate    SE df t.ratio p.value
 (2021-05) - (2021-09)    0.311 0.388 17   0.802  0.4337
 (2021-05) - (2022-04)   nonEst    NA NA      NA      NA
 (2021-09) - (2022-04)   nonEst    NA NA      NA      NA

sampling_reef = PAB:
 contrast              estimate    SE df t.ratio p.value
 (2021-05) - (2021-09)   -0.303 0.388 17  -0.781  0.7196
 (2021-05) - (2022-04)    0.781 0.363 17   2.151  0.1091
 (2021-09) - (2022-04)    1.084 0.363 17   2.986  0.0215 .

sampling_reef = SG:
 contrast              estimate    SE df t.ratio p.value
 (2021-05) - (2021-09)   nonEst    NA NA      NA      NA
 (2021-05) - (2022-04)   nonEst    NA NA      NA      NA
 (2021-09) - (2022-04)   -1.020 0.336 17  -3.035  0.0075 **

Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

P value adjustment: tukey method for varying family sizes "


env_means_tempo <- emmeans(environment_shannon, specs = pairwise ~ sampling_reef | Tempo4)

"$emmeans
Tempo4 = Apr22:
 sampling_reef emmean    SE df lower.CL upper.CL
 ESQ           nonEst    NA NA       NA       NA
 PAB            0.776 0.238 17    0.275     1.28
 SG             1.818 0.238 17    1.316     2.32

Tempo4 = May21:
 sampling_reef emmean    SE df lower.CL upper.CL
 ESQ            0.755 0.274 17    0.176     1.33
 PAB            1.557 0.274 17    0.978     2.14
 SG            nonEst    NA NA       NA       NA

Tempo4 = Sep21:
 sampling_reef emmean    SE df lower.CL upper.CL
 ESQ            0.444 0.274 17   -0.135     1.02
 PAB            1.859 0.274 17    1.281     2.44
 SG             0.798 0.238 17    0.297     1.30

Confidence level used: 0.95 

$contrasts
Tempo4 = Apr22:
 contrast  estimate    SE df t.ratio p.value
 ESQ - PAB   nonEst    NA NA      NA      NA
 ESQ - SG    nonEst    NA NA      NA      NA
 PAB - SG    -1.042 0.336 17  -3.101  0.0065 **

Tempo4 = May21:
 contrast  estimate    SE df t.ratio p.value
 ESQ - PAB   -0.802 0.388 17  -2.066  0.0544 .
 ESQ - SG    nonEst    NA NA      NA      NA
 PAB - SG    nonEst    NA NA      NA      NA

Tempo4 = Sep21:
 contrast  estimate    SE df t.ratio p.value
 ESQ - PAB   -1.416 0.388 17  -3.649  0.0053 **
 ESQ - SG    -0.354 0.363 17  -0.976  0.6012
 PAB - SG     1.061 0.363 17   2.925  0.0244 .

Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

P value adjustment: tukey method for varying family sizes "


tukey <- TukeyHSD(environment_shannon)
# por ter NA tava dando erro.
#### ## #
#https://stackoverflow.com/questions/74517204/how-to-compute-tukeyhsd-letters-for-ggplot2-with-multcompletters2-when-interacti
# substituir os NA por zero
tukey$`sampling_reef:Tempo4`[!complete.cases(tukey$`sampling_reef:Tempo4`),] <- 0

library(multcompView)
cld.rr <- multcompLetters4(environment_shannon, tukey)

"$sampling_reef
PAB  SG ESQ 
"a" "a" "b" 

$Tempo4
$Tempo4$Letters
Apr22 May21 Sep21 
  "a"   "a"   "a" 

$Tempo4$LetterMatrix
         a
Apr22 TRUE
May21 TRUE
Sep21 TRUE


$`sampling_reef:Tempo4`
PAB:Sep21  SG:Apr22 PAB:May21  SG:Sep21 PAB:Apr22 ESQ:May21 ESQ:Sep21 ESQ:Apr22  SG:May21 
      "a"       "a"      "ab"      "ab"      "ab"      "ab"       "b"       "c"       "d" "


###### #
# tentando sem tempo
##### #
# anova pouquíssimo significativo
# tukey tudo igual!!! mierda



# agua
environment_a_shannon <- aov(Diversity_Shannon ~ sampling_reef * Tempo4, data = agua)
summary(environment_a_shannon)

env_a_means <- emmeans(environment_a_shannon, specs = pairwise ~ Tempo4 | sampling_reef)
env_a_means

"$emmeans
sampling_reef = ESQ:
 Tempo3  emmean     SE df lower.CL upper.CL
 2021-05   2.61 0.0479 11     2.51     2.72
 2021-09   2.24 0.0829 11     2.06     2.42
 2022-04 nonEst     NA NA       NA       NA

sampling_reef = PAB:
 Tempo3  emmean     SE df lower.CL upper.CL
 2021-05   1.84 0.0479 11     1.74     1.95
 2021-09   2.60 0.0479 11     2.49     2.70
 2022-04   2.29 0.0479 11     2.19     2.40

sampling_reef = SG:
 Tempo3  emmean     SE df lower.CL upper.CL
 2021-05 nonEst     NA NA       NA       NA
 2021-09   2.06 0.0479 11     1.96     2.17
 2022-04   2.32 0.0586 11     2.19     2.44

Confidence level used: 0.95 

$contrasts
sampling_reef = ESQ:
 contrast              estimate     SE df t.ratio p.value
 (2021-05) - (2021-09)    0.371 0.0957 11   3.873  0.0026 *
 (2021-05) - (2022-04)   nonEst     NA NA      NA      NA
 (2021-09) - (2022-04)   nonEst     NA NA      NA      NA

sampling_reef = PAB:
 contrast              estimate     SE df t.ratio p.value
 (2021-05) - (2021-09)   -0.754 0.0677 11 -11.149  <.0001 ***
 (2021-05) - (2022-04)   -0.453 0.0677 11  -6.691  0.0001 ***
 (2021-09) - (2022-04)    0.302 0.0677 11   4.458  0.0025 **

sampling_reef = SG:
 contrast              estimate     SE df t.ratio p.value
 (2021-05) - (2021-09)   nonEst     NA NA      NA      NA
 (2021-05) - (2022-04)   nonEst     NA NA      NA      NA
 (2021-09) - (2022-04)   -0.254 0.0757 11  -3.354  0.0064 **

Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1


P value adjustment: tukey method for varying family sizes 
"

env_a_means_tempo <- emmeans(environment_a_shannon, specs = pairwise ~ sampling_reef | Tempo4)
env_a_means_tempo

"$emmeans
Tempo4 = Apr22:
 sampling_reef emmean     SE df lower.CL upper.CL
 ESQ           nonEst     NA NA       NA       NA
 PAB             2.29 0.0479 11     2.19     2.40
 SG              2.32 0.0586 11     2.19     2.44

Tempo4 = May21:
 sampling_reef emmean     SE df lower.CL upper.CL
 ESQ             2.61 0.0479 11     2.51     2.72
 PAB             1.84 0.0479 11     1.74     1.95
 SG            nonEst     NA NA       NA       NA

Tempo4 = Sep21:
 sampling_reef emmean     SE df lower.CL upper.CL
 ESQ             2.24 0.0829 11     2.06     2.42
 PAB             2.60 0.0479 11     2.49     2.70
 SG              2.06 0.0479 11     1.96     2.17

Confidence level used: 0.95 

$contrasts
Tempo4 = Apr22:
 contrast  estimate     SE df t.ratio p.value
 ESQ - PAB   nonEst     NA NA      NA      NA
 ESQ - SG    nonEst     NA NA      NA      NA
 PAB - SG   -0.0225 0.0757 11  -0.298  0.7715

Tempo4 = May21:
 contrast  estimate     SE df t.ratio p.value
 ESQ - PAB   0.7724 0.0677 11  11.414  <.0001 ***
 ESQ - SG    nonEst     NA NA      NA      NA
 PAB - SG    nonEst     NA NA      NA      NA

Tempo4 = Sep21:
 contrast  estimate     SE df t.ratio p.value
 ESQ - PAB  -0.3527 0.0957 11  -3.685  0.0092 **
 ESQ - SG    0.1802 0.0957 11   1.883  0.1894
 PAB - SG    0.5329 0.0677 11   7.875  <.0001 ***

Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1


P value adjustment: tukey method for varying family sizes "

agua_tukey <- TukeyHSD(environment_a_shannon)
# por ter NA tava dando erro.
#### ## #
#https://stackoverflow.com/questions/74517204/how-to-compute-tukeyhsd-letters-for-ggplot2-with-multcompletters2-when-interacti
# substituir os NA por zero
agua_tukey$`sampling_reef:Tempo4`[!complete.cases(agua_tukey$`sampling_reef:Tempo4`),] <- 0

library(multcompView)
cld.rr_agua <- multcompLetters4(environment_a_shannon, agua_tukey)


###### FAZENDO PLOT COM RESULTADO EMMEANS #####

library(ggplot2)
library(dplyr)
library(ggpubr)
library(rstatix)

setwd("C:/Users/clara/OneDrive/MICROBIOMAS_CORAIS/Resultados/analises_ecologicas/level-7")
lvl7 <- read.table("Villela_in_prep_rareado-987.level-7.csv", header=T, sep=',', stringsAsFactors=F)

lvl7$Tempo4[lvl7$Tempo2 == "May-21"] <- "May 21"
lvl7$Tempo4[lvl7$Tempo2 == "Sep-21"] <- "Sep 21"
lvl7$Tempo4[lvl7$Tempo2 == "Apr-22"] <- "Apr 22"

controles <- subset(lvl7, lvl7$tratamento == "controle" | lvl7$tratamento == "controle_agua")
coral <- subset(controles, controles$environment == "coral")

coral$sampling_reef <- factor(coral$sampling_reef)

unique(coral$sampling_reef)

# Criação de um dataframe com os p-valores para cada comparação
p_values <- data.frame(
  Tempo4 = c("Apr 22", "May 21", "Sep 21", "Sep 21"),
  group1 = c("PAB", "ESQ", "ESQ", "PAB"),
  group2 = c("SG", "PAB", "PAB", "SG"),
  p.value = c(0.0065, 0.0544, 0.0053, 0.0244),
  y.position = c(2.3, 2.1, 2.3, 2.5) # Altura onde o p-valor será exibido
)

stat.test <- tibble::tribble(
  ~group1, ~group2,   ~p.adj,
  "0.5",     "1", 2.54e-07,
  "0.5",     "2", 1.32e-13,
  "1",     "2", 1.91e-05
)
stat.test

p_values$group1 <- factor(p_values$group1)
p_values$group2 <- factor(p_values$group2)


stat.test <- data.frame(
  Tempo4 = c("Apr 22", "May 21", "Sep 21", "Sep 21"),
  .y. = "Diversity_Shannon", # Variável de resposta
  group1 = c("PAB", "ESQ", "ESQ", "PAB"),
  group2 = c("SG", "PAB", "PAB", "SG"),
  p.adj = c(0.0065, 0.0544, 0.0053, 0.0244), # p-valor ajustado
  p.adj.signif = c("**", ".", "**", "*"),
  y.position = c(3.0, 3.3, 3.5, 3.8)
  )
bxp <- ggboxplot(coral, x = "Tempo4", y = "Diversity_Shannon", color = "sampling_reef") +
  stat_pvalue_manual(
    stat.test,   label = "p.adj.signif", tip.length = 0.01)

# Gráfico com as comparações e p-valores adicionados
library(ggplot2)

facet_labels <- c("coral" = "Coral tissue", 
                  "H2O" = "Water")

# Converter Tempo3 em um fator ordenado
controles$Tempo4 <- factor(controles$Tempo4, levels = c("May 21", "Sep 21", "Apr 22"))


div_transp_coral <- ggplot(data = controles, aes(x = Tempo4, y = Diversity_Shannon, fill = sampling_reef, color = sampling_reef)) +
  geom_boxplot() +
  facet_wrap(vars(environment), labeller = labeller(environment = facet_labels)) +
  scale_fill_manual(values = c("ESQ" = "indianred2", 
                               "PAB" = "springgreen3", 
                               "SG" = "mediumslateblue"),
                    name =  " ") +
  scale_color_manual(values = c("ESQ" = "darkred", 
                                "PAB" = "darkgreen", 
                                "SG" = "darkblue")) +
guides(color = "none") +
  xlab(" ") +
  ylab("Shannon Diversity") +
  ylim(0,3) +
  theme(legend.position = "bottom",
        axis.text.x = element_text(hjust = 1, size = 10), 
        axis.title.x = element_text(size = 10),                       
        axis.title.y = element_text(size = 12),               
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 10))
div_transp_coral


# SALVAR
setwd("C:/Users/clara/OneDrive/MICROBIOMAS_CORAIS/ressubmissão_revisão/figuras")

svg("div_abrolhos_semlegenda.svg", 4, 4)
div_transp_coral
dev.off()


######## COMPOSIÇÃO #############

library(tidyr)

transposto <- controles %>%
  pivot_longer(cols = 1:77, names_to = "Classificacao_Taxonomica_Genero", values_to = "Abundance")

total_gen <- tapply(transposto$Abundance, list(transposto$Classificacao_Taxonomica_Genero), sum)

(total_gen[order(total_gen, decreasing = TRUE)])

#lista 10 primeiras + conjunto outros
d6 <- transposto
limite <- 560 


# Encontre os índices dos taxons na lista que têm soma menor que o limite
indices_taxons <- names(total_gen[total_gen < limite])

# Substitua os taxons na coluna "Abundance" pelo valor "outros" se estiverem na lista de índices
d6$Genera <- d6$Classificacao_Taxonomica_Genero
d6$Genera[d6$Genera %in% indices_taxons] <- "Others"

#deixar so nome classe

# Carregue a biblioteca dplyr
library(dplyr)

# Substitua 'df' pelo nome do seu dataframe
d7 <- d6 %>%
  mutate(Genera = ifelse(Genera != "Others", gsub(".+\\.(\\w+)$", "\\1", Genera), Genera))

#d7$Genero <- sub(".+\\.(.+)", "\\1", d7$Classificacao_Taxonomica_Genero)

#Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.__
d7$Genera[d7$Classificacao_Taxonomica_Genero == "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.__"] <- "Raphid.pennate.__"
#Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Raphid.pennate_X
d7$Genera[d7$Classificacao_Taxonomica_Genero == "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Raphid.pennate_X"] <- "Raphid.pennate_X"


#Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.__.__
d7$Genera[d7$Classificacao_Taxonomica_Genero == "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.__.__"] <- "Bacillariophyta_X.__.__"

#Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.__.__.__
d7$Genera[d7$Classificacao_Taxonomica_Genero == "Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.__.__.__"] <- "Florideophyceae.__.__.__"

#Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.Corallinales.Corallinales_X.__
d7$Genera[d7$Classificacao_Taxonomica_Genero == "Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.Corallinales.Corallinales_X.__"] <- "Corallinales_X.__"

#Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Polar.centric.Mediophyceae.__
d7$Genera[d7$Classificacao_Taxonomica_Genero == "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Polar.centric.Mediophyceae.__"] <- "Mediophyceae.__"

unique(d7$Genera)

[1] "Others"                   "Colpodellidae"            "Bryopsidales_XX"         
[4] "Ostreobium"               "Florideophyceae.__.__.__" "Corallinales_X.__"       
[7] "Calliarthron"             "Teleaulax"                "Phaeocystis"             
[10] "Bacillariophyta_X.__.__"  "Bacillariophyta_XXX"      "Mediophyceae.__"         
[13] "Mediophyceae_X"           "Thalassiosira"            "Proboscia"               
[16] "Rhizosolenia"             "Raphid.pennate.__"        "Cylindrotheca"           
[19] "Navicula"                 "Raphid.pennate_X"         "Dictyochophyceae_XXX"    
[22] "Aureococcus" 

# cores pro gênero de acordo com CLASSE
cores_genero <- c("Others" = "#333333",
  "Colpodellidae" = "#FF9900",
  "Pyramimonas" = "#666600",
  "Bryopsidales_XX" = "#669900",
  "Ostreobium"  = "#33CC00",
  "Florideophyceae.__.__.__" = "#990000",
  "Corallinales_X.__" = "#FF6666",
  "Calliarthron" = "#FF0033",
  "Teleaulax" = "#FFFF00",
  "Phaeocystis" = "#FF99CC",
  "Prymnesiaceae_X" = "#FF3399",
  "Bacillariophyta_X.__.__" = "#9966CC",
  "Bacillariophyta_XXX" = "#333366",
  "Mediophyceae.__" = "#3366FF",
  "Chaetoceros" = "#9999FF",
  "Mediophyceae_X"  = "#0000FF",
  "Thalassiosira" = "#99CCFF",
  "Proboscia" = "#33FFFF",
  "Rhizosolenia" = "#3300CC",
  "Raphid.pennate.__" = "#660099",
  "Cylindrotheca" = "#CC33CC",
  "Navicula" = "#9900CC",
  "Raphid.pennate_X" = "#660066",
  "Dictyochophyceae_XXX" = "#CC9933",
  "Aureococcus" = "#663300")

# fazer coral e água separado e depois juntar

# coral
d7_coral <- subset(d7, d7$environment == "coral")

#legenda
unique(d7_coral$name)
d7_coral$legenda[d7_coral$name == "ESQ_t0_C1"] <- "ESQ_May 21 (1)"
d7_coral$legenda[d7_coral$name == "ESQ_t1_C2"] <- "ESQ_Sep 21 (2)"
d7_coral$legenda[d7_coral$name == "ESQ_t1_C4"] <- "ESQ_Sep 21 (4)"
d7_coral$legenda[d7_coral$name == "PAB_t0_C2"] <- "PAB_May 21 (2)"
d7_coral$legenda[d7_coral$name == "PAB_t0_C3"] <- "PAB_May 21 (3)"
d7_coral$legenda[d7_coral$name == "PAB_t0_C4"] <- "PAB_May 21 (4)"
d7_coral$legenda[d7_coral$name == "ESQ_t0_C2"] <- "ESQ_May 21 (2)"
d7_coral$legenda[d7_coral$name == "PAB_t1_C2"] <- "PAB_Sep 21 (2)"
d7_coral$legenda[d7_coral$name == "PAB_t1_C3"] <- "PAB_Sep 21 (3)"
d7_coral$legenda[d7_coral$name == "PAB_t1_C4"] <- "PAB_Sep 21 (4)"
d7_coral$legenda[d7_coral$name == "PAB_t1_B_C1"] <- "PAB_Apr 22 (1)"
d7_coral$legenda[d7_coral$name == "PAB_t1_B_C2"] <- "PAB_Apr 22 (2)"
d7_coral$legenda[d7_coral$name == "PAB_t1_B_C3"] <- "PAB_Apr 22 (3)"
d7_coral$legenda[d7_coral$name == "PAB_t1_B_C4"] <- "PAB_Apr 22 (4)"
d7_coral$legenda[d7_coral$name == "SG_t0_C1"] <- "SG_Sep 21 (1)"
d7_coral$legenda[d7_coral$name == "SG_t0_C2"] <- "SG_Sep 21 (2)"
d7_coral$legenda[d7_coral$name == "SG_t0_C3"] <- "SG_Sep 21 (3)"
d7_coral$legenda[d7_coral$name == "SG_t0_C4"] <- "SG_Sep 21 (4)"
d7_coral$legenda[d7_coral$name == "ESQ_t0_C4"] <- "ESQ_May 21 (4)"
d7_coral$legenda[d7_coral$name == "SG_t1_C1"] <- "SG_Apr 22 (1)"
d7_coral$legenda[d7_coral$name == "SG_t1_C2"] <- "SG_Apr 22 (2)"
d7_coral$legenda[d7_coral$name == "SG_t1_C3"] <- "SG_Apr 22 (3)"
d7_coral$legenda[d7_coral$name == "SG_t1_C4"] <- "SG_Apr 22 (4)"
d7_coral$legenda[d7_coral$name == "ESQ_t1_C1"] <- "ESQ_Sep 21 (1)"


#### chat gpt - FUNCIONA

# Converter Tempo3 em um fator ordenado
d7_coral$Tempo3 <- factor(d7_coral$Tempo3, levels = c("2021-05", "2021-09", "2022-04"))

# Reordenar a legenda com base no fator ordenado Tempo3
d7_coral$legenda <- with(d7_coral, reorder(legenda, as.numeric(Tempo3)))

# Verificar se a reordenação foi aplicada corretamente
d7_coral <- d7_coral[order(d7_coral$Tempo3, d7_coral$legenda), ]

# GRAFICO
library(ggplot2)
ab_coral_7 <- ggplot(data = d7_coral, aes(fill=Genera, y=Abundance, x=legenda)) + 
  geom_bar(position="fill", stat="identity") +
  scale_fill_manual(values = cores_genero) +
  facet_wrap(~ sampling_reef, scales = "free_x") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ylab("Relative Abundance") +
  xlab(" ") +
  scale_x_discrete(labels = function(x) {
    x <- gsub("^(ESQ_|PAB_|SG_)", "", x)
    substr(x, 1, nchar(x) - 3)
    }) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 0.5, size = 7),
        axis.title.y = element_text(size = 12), 
        legend.text = element_text(size = 10)) +
  guides(fill = "none")


ab_coral_7



####

# agua
d7_agua <- subset(d7, d7$environment == "H2O")

#legenda
unique(d7_agua$name)

d7_agua$legenda[d7_agua$name == "ESQ_t0_A1"] <- "ESQ_May 21 1"
d7_agua$legenda[d7_agua$name == "ESQ_t1_A2"] <- "ESQ_Sep 21 2"
d7_agua$legenda[d7_agua$name == "PAB_t0_A1"] <- "PAB_May 21 1"
d7_agua$legenda[d7_agua$name == "PAB_t0_A2"] <- "PAB_May 21 2"
d7_agua$legenda[d7_agua$name == "PAB_t0_A3"] <- "PAB_May 21 3"
d7_agua$legenda[d7_agua$name == "ESQ_t0_A2"] <- "ESQ_May 21 2"
d7_agua$legenda[d7_agua$name == "PAB_t1_A1"] <- "PAB_Sep 21 1"
d7_agua$legenda[d7_agua$name == "PAB_t1_A2"] <- "PAB_Sep 21 2"
d7_agua$legenda[d7_agua$name == "PAB_t1_A3"] <- "PAB_Sep 21 3"
d7_agua$legenda[d7_agua$name == "PAB_tB_A1"] <- "PAB_Apr 22 1"
d7_agua$legenda[d7_agua$name == "PAB_tB_A2"] <- "PAB_Apr 22 2"
d7_agua$legenda[d7_agua$name == "PAB_tB_A3"] <- "PAB_Apr 22 3"
d7_agua$legenda[d7_agua$name == "SG_t0_A1"] <- "SG_Sep 21 1"
d7_agua$legenda[d7_agua$name == "SG_t0_A2"] <- "SG_Sep 21 2"
d7_agua$legenda[d7_agua$name == "SG_t0_A3"] <- "SG_Sep 21 3"
d7_agua$legenda[d7_agua$name == "ESQ_t0_A3"] <- "ESQ_May 21 3"
d7_agua$legenda[d7_agua$name == "SG_t1_A1"] <- "SG_Apr 22 1"
d7_agua$legenda[d7_agua$name == "SG_t1_A2"] <- "SG_Apr 22 2"

# Converter Tempo3 em um fator ordenado
d7_agua$Tempo3 <- factor(d7_agua$Tempo3, levels = c("2021-05", "2021-09", "2022-04"))

# Reordenar a legenda com base no fator ordenado Tempo3
d7_agua$legenda <- with(d7_agua, reorder(legenda, as.numeric(Tempo3)))

# Verificar se a reordenação foi aplicada corretamente
d7_agua <- d7_agua[order(d7_agua$Tempo3, d7_agua$legenda), ]


ab_agua_7 <- ggplot(data = d7_agua, aes(fill=Genera, y=Abundance, x = legenda)) + 
  geom_bar(position="fill", stat="identity") +
  scale_fill_manual(values = cores_genero) +
  facet_wrap(~ sampling_reef, scales = "free_x") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7),
        legend.text = element_text(size = 10)) +
  ylab(" ") +
  xlab(" ") +
  scale_x_discrete(labels = function(x) {
    x <- gsub("^(ESQ_|PAB_|SG_)", "", x)
    substr(x, 1, nchar(x) - 1)
    }) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  guides(fill = "none")
  
ab_agua_7

# juntar agua e coral

library(patchwork)

combined_plot <- (ab_coral_7 | ab_agua_7 + theme(legend.position = "right")) + 
  plot_layout(guides = 'collect') & 
  theme(legend.position = "right", legend.key.size = unit(0.5, "cm"), legend.text = element_text(size = 6.5), legend.title = element_text(size = 10))

# PDF
setwd("C:/Users/clara/OneDrive/MICROBIOMAS_CORAIS/ressubmissão_revisão/figuras")
pdf("composicao_abrolhos_ressub_6-5.pdf", 7, 5)
combined_plot
dev.off() 

#aa

########### MDS #####################
library(vegan)

## TESTE MDS COM ELIPSE

# coluna pras elipses:
# agrupa corais e água em cada um de seus recifes
controles$samp_elipses[controles$sampling_reef == "ESQ" & controles$environment == "coral"] <- "ESQ"
controles$samp_elipses[controles$sampling_reef == "PAB" & controles$environment == "coral"] <- "PAB"
controles$samp_elipses[controles$sampling_reef == "SG" & controles$environment == "coral"] <- "SG"
controles$samp_elipses[controles$sampling_reef == "ESQ" & controles$environment == "H2O"] <- "ESQa"
controles$samp_elipses[controles$sampling_reef == "PAB" & controles$environment == "H2O"] <- "PABa"
controles$samp_elipses[controles$sampling_reef == "SG" & controles$environment == "H2O"] <- "SGa"


c_matriz_ra <- vegdist(controles[,1:100], method="robust.aitchison")
c_mds_ra <- cmdscale(c_matriz_ra, k=3, eig=TRUE)

#preparando o df
c_mds_ra_points <- as.data.frame(c_mds_ra$points)
#quais metadados quero avaliar?
c_mds_ra_points$tratamento <- controles$tratamento
c_mds_ra_points$code <- controles$code
c_mds_ra_points$name <- controles$name
c_mds_ra_points$sampling_reef <- controles$sampling_reef
c_mds_ra_points$Tempo3 <- controles$Tempo3
c_mds_ra_points$samp_elipses <- controles$samp_elipses


names(c_mds_ra_points)[1:2] <- c("MDS1", "MDS2")

#ver qual a variação total de cada mds
c_mds_ra.exp.var<-c_mds_ra$eig/sum(c_mds_ra$eig)
print(c_mds_ra.exp.var)
#20%
#10.7%

library(ggplot2)

elipsesmds <- ggplot() + 
  geom_point(data = c_mds_ra_points, aes(x = MDS1, y = MDS2, shape = tratamento, colour = sampling_reef), size = 3) + 
  stat_ellipse(data = c_mds_ra_points, aes(x = MDS1, y = MDS2, colour = samp_elipses), 
               level = 0.95, type = "t", linetype = 2, show.legend = FALSE) +  
  ylab("MDS 2 (10.7%)") +
  xlab("MDS 1 (20%)") +
  theme(legend.position = "bottom", 
        legend.text = element_text(size = 10), 
        axis.text = element_text(size = 10),
        axis.title.y = element_text(size = 12), 
        axis.title.x = element_text(size = 12),
        axis.title = element_text(size = 10),
        legend.box = "horizontal",
        legend.box.margin = margin(t = 0, r = 0, b = 0, l = 0),
        legend.margin = margin(t = 0, r = 0, b = 0, l = 0)) +
  guides(colour = "none", 
          shape = "none") +
  scale_shape_manual(name = " ",
                     labels = c("controle" = "Coral tissue", 
                                "controle_agua" = "Water"),
                     values = c("controle" = 16, 
                                "controle_agua" = 17)) +
  scale_color_manual(values = c("ESQ" = "indianred2", "ESQa" = "indianred2", 
                                "PAB" = "springgreen3", "PABa" = "springgreen3", 
                                "SG" = "mediumslateblue", "SGa" = "mediumslateblue"))

elipsesmds



setwd("C:/Users/clara/OneDrive/MICROBIOMAS_CORAIS/Resultados/Figuras")
svg("MDS_trans_elipse.svg", 4, 3.1)
elipsesmds
dev.off() 

#a

############# PERMANOVA ################

#df_filtrado todos
#
library(vegan)
c_matriz_ra <- vegdist(df_filtrado[,1:77], method="robust.aitchison")

adonis2(formula = c_matriz_ra ~ environment + sampling_reef * Tempo3, data = df_filtrado, method = "robust.aitchison")
"                    Df SumOfSqs      R2       F Pr(>F)    
environment           1   189.80 0.18097 10.2075  0.001 ***
sampling_reef         2   101.47 0.09674  2.7284  0.002 ** 
Tempo3                2    61.39 0.05853  1.6507  0.029 *  
sampling_reef:Tempo3  2    63.94 0.06097  1.7194  0.026 *  
Residual             34   632.21 0.60279                   
Total                41  1048.81 1.00000
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1"

#df_filtrado coral
#
coral_matriz_ra <- vegdist(coral[,1:77], method="robust.aitchison")

adonis2(coral_matriz_ra ~ sampling_reef * Tempo3, data = coral, method = "robust.aitchison")

"                     Df SumOfSqs      R2      F Pr(>F)    
sampling_reef         2   102.32 0.25213 3.5449  0.001 ***
Tempo3                2    21.12 0.05205 0.7319  0.809    
sampling_reef:Tempo3  2    37.04 0.09127 1.2833  0.180    
Residual             17   245.34 0.60455                  
Total                23   405.82 1.00000  "



#df_filtrado água
#
H2O_matriz_ra <- vegdist(agua[,1:77], method="robust.aitchison")

adonis2(H2O_matriz_ra ~ sampling_reef * Tempo3, data = agua, method = "robust.aitchison")

"                    Df SumOfSqs      R2      F Pr(>F)    
sampling_reef         2   106.76 0.23557 3.6681  0.001 ***
Tempo3                2   102.38 0.22590 3.5175  0.001 ***
sampling_reef:Tempo3  2    83.98 0.18530 2.8853  0.001 ***
Residual             11   160.08 0.35322                  
Total                17   453.19 1.00000 "


################ ESPECIES INDICADORAS ##########

library("indicspecies")

# SP IND CORAL / RECIFE

indval <- multipatt(coral[,1:77], coral$sampling_reef, 
                    control = how(nperm=999)) 
summary(indval)

#nao salvei ainda
s_indval <- indval$sign
write.table(s_indval, "indval.coral_agua.tsv", sep= "\t")
write.table(indval, "indval.coral.tsv", sep= "\t")


" Multilevel pattern analysis
 ---------------------------

 Association function: IndVal.g
 Significance level (alpha): 0.05

 Total number of species: 100
 Selected number of species: 5 
 Number of species associated to 1 group: 2 
 Number of species associated to 2 groups: 3 

 List of species associated to each combination: 

 Group ESQ  #sps.  2 
                                                                                                 stat p.value    
Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.Corallinales.Corallinales_X.__              0.971   0.001 ***
Eukaryota.Archaeplastida.Chlorophyta.Chloropicophyceae.Chloropicales.Chloropicaceae.Chloropicon 0.691   0.019 *  

 Group PAB+SG  #sps.  3 
                                                                                              stat p.value   
Eukaryota.Archaeplastida.Chlorophyta.Ulvophyceae.Bryopsidales.Bryopsidales_X.Ostreobium      0.987   0.002 **
Eukaryota.Alveolata.Apicomplexa.Colpodellidea.Colpodellida.Colpodellaceae.Colpodellidae      0.909   0.015 * 
Eukaryota.Archaeplastida.Chlorophyta.Ulvophyceae.Bryopsidales.Bryopsidales_X.Bryopsidales_XX 0.881   0.005 **
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1 "

# transf tabela
# Definindo os dados
data <- data.frame(
  Group = c(rep("ESQ", 2), rep("PAB+SG", 3)),
  Species = c(
    "Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.Corallinales.Corallinales_X.__",
    "Eukaryota.Archaeplastida.Chlorophyta.Chloropicophyceae.Chloropicales.Chloropicaceae.Chloropicon",
    "Eukaryota.Archaeplastida.Chlorophyta.Ulvophyceae.Bryopsidales.Bryopsidales_X.Ostreobium",
    "Eukaryota.Alveolata.Apicomplexa.Colpodellidea.Colpodellida.Colpodellaceae.Colpodellidae",
    "Eukaryota.Archaeplastida.Chlorophyta.Ulvophyceae.Bryopsidales.Bryopsidales_X.Bryopsidales_XX"
  ),
  Stat = c(0.971, 0.691, 0.987, 0.909, 0.881),
  P.value = c(0.001, 0.019, 0.002, 0.015, 0.005),
  Significance = c("***", "*", "**", "*", "**")
)

# Salvar como CSV
write.csv(data, "indval_coral-reef.csv", row.names = FALSE)


### SP IND AGUA / RECIFE

indval_agua <- multipatt(agua[,1:77], agua$sampling_reef, 
                    control = how(nperm=999)) 
summary(indval_agua)

" Multilevel pattern analysis
 ---------------------------

 Association function: IndVal.g
 Significance level (alpha): 0.05

 Total number of species: 100
 Selected number of species: 14 
 Number of species associated to 1 group: 9 
 Number of species associated to 2 groups: 5 

 List of species associated to each combination: 

 Group ESQ  #sps.  5 
                                                                                                               stat p.value   
Eukaryota.Archaeplastida.Chlorophyta.Chloropicophyceae.Chloropicales.Chloropicaceae.Chloroparvula             0.866   0.007 **
Eukaryota.Stramenopiles.Ochrophyta.Pelagophyceae.Sarcinochrysidales.Sarcinochrysidaceae.Sarcinochrysidaceae_X 0.866   0.007 **
Eukaryota.__.__.__.__.__.__                                                                                   0.707   0.038 * 
Eukaryota.Hacrobia.__.__.__.__.__                                                                             0.707   0.043 * 
Eukaryota.Stramenopiles.Ochrophyta.Chrysophyceae.Chrysophyceae_X.__.__                                        0.707   0.039 * 

 Group PAB  #sps.  4 
                                                                                                                            stat p.value   
Eukaryota.Stramenopiles.Ochrophyta.Pinguiophyceae.Pinguiochrysidales.Pinguiochrysidaceae.Phaeomonas                        0.888   0.007 **
Eukaryota.Hacrobia.Cryptophyta.Cryptophyceae.Cryptomonadales.Cryptomonadales_X.Proteomonas                                 0.816   0.016 * 
Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Radial.centric.basal.Coscinodiscophyceae.Rhizosolenia 0.816   0.022 * 
Eukaryota.Archaeplastida.Chlorophyta.Chlorodendrophyceae.Chlorodendrales.Chlorodendraceae.Tetraselmis                      0.796   0.019 * 

 Group ESQ+SG  #sps.  5 
                                                                                                   stat p.value    
Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Cylindrotheca 0.990   0.001 ***
Eukaryota.Stramenopiles.Ochrophyta.Xanthophyceae.Xanthophyceae_X.Xanthophyceae_XX.Vaucheria       0.985   0.001 ***
Eukaryota.Archaeplastida.Chlorophyta.Chloropicophyceae.Chloropicales.Chloropicaceae.Chloropicon   0.900   0.041 *  
Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.__            0.858   0.014 *  
Eukaryota.Hacrobia.Haptophyta.Prymnesiophyceae.Prymnesiophyceae_X.__.__                           0.739   0.046 *  
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1 "
data_agua <- data.frame(
  Group = c(rep("ESQ", 5), rep("PAB", 4), rep("ESQ+SG", 5)),
  Species = c(
    "Eukaryota.Archaeplastida.Chlorophyta.Chloropicophyceae.Chloropicales.Chloropicaceae.Chloroparvula",
    "Eukaryota.Stramenopiles.Ochrophyta.Pelagophyceae.Sarcinochrysidales.Sarcinochrysidaceae.Sarcinochrysidaceae_X",
    "Eukaryota.__.__.__.__.__.__",
    "Eukaryota.Hacrobia.__.__.__.__.__",
    "Eukaryota.Stramenopiles.Ochrophyta.Chrysophyceae.Chrysophyceae_X.__.__",
    "Eukaryota.Stramenopiles.Ochrophyta.Pinguiophyceae.Pinguiochrysidales.Pinguiochrysidaceae.Phaeomonas",
    "Eukaryota.Hacrobia.Cryptophyta.Cryptophyceae.Cryptomonadales.Cryptomonadales_X.Proteomonas",
    "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Radial.centric.basal.Coscinodiscophyceae.Rhizosolenia",
    "Eukaryota.Archaeplastida.Chlorophyta.Chlorodendrophyceae.Chlorodendrales.Chlorodendraceae.Tetraselmis",
    "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Cylindrotheca",
    "Eukaryota.Stramenopiles.Ochrophyta.Xanthophyceae.Xanthophyceae_X.Xanthophyceae_XX.Vaucheria",
    "Eukaryota.Archaeplastida.Chlorophyta.Chloropicophyceae.Chloropicales.Chloropicaceae.Chloropicon",
    "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.__",
    "Eukaryota.Hacrobia.Haptophyta.Prymnesiophyceae.Prymnesiophyceae_X.__.__"
  ),
  Stat = c(0.866, 0.866, 0.707, 0.707, 0.707, 0.888, 0.816, 0.816, 0.796, 0.990, 0.985, 0.900, 0.858, 0.739),
  P.value = c(0.007, 0.007, 0.038, 0.043, 0.039, 0.007, 0.016, 0.022, 0.019, 0.001, 0.001, 0.041, 0.014, 0.046),
  Significance = c("**", "**", "*", "*", "*", "**", "*", "*", "*", "***", "***", "*", "*", "*")
)

# Salvar como CSV
write.csv(data_agua, "indval_agua_reef.csv", row.names = FALSE)



# avaliar sp ind em cada ambiente

indval_df_filtrado <- multipatt(df_filtrado[,1:100], df_filtrado$environment, 
                         control = how(nperm=999)) 

summary(indval_df_filtrado)

"Multilevel pattern analysis
 ---------------------------

 Association function: IndVal.g
 Significance level (alpha): 0.05

 Total number of species: 100
 Selected number of species: 40 
 Number of species associated to 1 group: 40 

 List of species associated to each combination: 

 Group coral  #sps.  11 
                                                                                                      stat p.value    
Eukaryota.Archaeplastida.Chlorophyta.Ulvophyceae.Bryopsidales.Bryopsidales_X.Ostreobium              0.957   0.001 ***
Eukaryota.Alveolata.Apicomplexa.Colpodellidea.Colpodellida.Colpodellaceae.Colpodellidae              0.842   0.001 ***
Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.Corallinales.Corallinales_X.Calliarthron         0.842   0.001 ***
Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Raphid.pennate_X 0.842   0.001 ***
Eukaryota.Archaeplastida.Chlorophyta.Ulvophyceae.Bryopsidales.Bryopsidales_X.Bryopsidales_XX         0.791   0.001 ***
Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Navicula         0.744   0.004 ** 
Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.Corallinales.Corallinales_X.__                   0.645   0.002 ** 
Eukaryota.Stramenopiles.Ochrophyta.Phaeophyceae.Phaeophyceae_X.Phaeophyceae_XX.Ectocarpus            0.575   0.019 *  
Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.__.__.__                                         0.540   0.040 *  
Eukaryota.Archaeplastida.Chlorophyta.Ulvophyceae.Bryopsidales.Bryopsidales_X.Bryopsis                0.500   0.042 *  
Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Amphora          0.500   0.041 *  

 Group H2O  #sps.  29 
                                                                                                                              stat p.value    
Eukaryota.Stramenopiles.Ochrophyta.Pelagophyceae.Pelagomonadales.Pelagomonadaceae.Aureococcus                                0.998   0.001 ***
Eukaryota.Hacrobia.Cryptophyta.Cryptophyceae.Cryptomonadales.Cryptomonadales_X.Teleaulax                                     0.996   0.001 ***
Eukaryota.Stramenopiles.Ochrophyta.Dictyochophyceae.Dictyochophyceae_X.Dictyochophyceae_XX.Dictyochophyceae_XXX              0.994   0.001 ***
Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Polar.centric.Mediophyceae.__                           0.958   0.001 ***
Eukaryota.Hacrobia.Haptophyta.Prymnesiophyceae.Phaeocystales.Phaeocystaceae.Phaeocystis                                      0.931   0.001 ***
Eukaryota.Stramenopiles.Ochrophyta.Chrysophyceae.Chrysophyceae_X.Chrysophyceae_XX.Chrysophyceae_XXX                          0.913   0.001 ***
Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Bacillariophyta_XX.Bacillariophyta_XXX                  0.892   0.001 ***
Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Polar.centric.Mediophyceae.Thalassiosira                0.888   0.001 ***
Eukaryota.Archaeplastida.Chlorophyta.Pyramimonadales.Pyramimonadales_X.Pyramimonadales_XX.Pyramimonas                        0.850   0.001 ***
Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Polar.centric.Mediophyceae.Chaetoceros                  0.848   0.001 ***
Eukaryota.Stramenopiles.Ochrophyta.Xanthophyceae.Xanthophyceae_X.Xanthophyceae_XX.Vaucheria                                  0.846   0.001 ***
Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Cylindrotheca                            0.825   0.001 ***
Eukaryota.Hacrobia.Haptophyta.Prymnesiophyceae.Prymnesiales.Prymnesiaceae.Prymnesiaceae_X                                    0.816   0.001 ***
Eukaryota.Archaeplastida.Chlorophyta.Chloropicophyceae.Chloropicales.Chloropicaceae.Chloropicon                              0.786   0.002 ** 
Eukaryota.Archaeplastida.Chlorophyta.Mamiellophyceae.Mamiellales.Bathycoccaceae.Ostreococcus                                 0.782   0.001 ***
Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Polar.centric.Mediophyceae.Polar.centric.Mediophyceae_X 0.772   0.001 ***
Eukaryota.Stramenopiles.Ochrophyta.Pinguiophyceae.Pinguiochrysidales.Pinguiochrysidaceae.Phaeomonas                          0.705   0.001 ***
Eukaryota.Archaeplastida.Chlorophyta.Nephroselmidophyceae.Nephroselmidales.Nephroselmidales_X.Nephroselmis                   0.667   0.001 ***
Eukaryota.Archaeplastida.Chlorophyta.Palmophyllophyceae.Prasinococcales.Prasinococcales.Clade.B.Prasinoderma                 0.667   0.001 ***
Eukaryota.Stramenopiles.Ochrophyta.Eustigmatophyceae.Eustigmatophyceae_X.Eustigmatophyceae_XX.Nannochloropsis                0.642   0.005 ** 
Eukaryota.Archaeplastida.Chlorophyta.Chlorodendrophyceae.Chlorodendrales.Chlorodendraceae.Tetraselmis                        0.619   0.002 ** 
Eukaryota.Excavata.Discoba.Euglenozoa.Euglenida.Eutreptiales.Eutreptiella                                                    0.577   0.003 ** 
Eukaryota.Hacrobia.Cryptophyta.Cryptophyceae.Cryptomonadales.Cryptomonadales_X.Proteomonas                                   0.577   0.004 ** 
Eukaryota.Hacrobia.Haptophyta.Prymnesiophyceae.Prymnesiophyceae_X.__.__                                                      0.577   0.007 ** 
Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Radial.centric.basal.Coscinodiscophyceae.Rhizosolenia   0.577   0.002 ** 
Eukaryota.Stramenopiles.Ochrophyta.Dictyochophyceae.Dictyochophyceae_X.Florenciellales.Florenciella                          0.527   0.013 *  
Eukaryota.Archaeplastida.Chlorophyta.Mamiellophyceae.Mamiellales.Mamiellaceae.Mantoniella                                    0.515   0.030 *  
Eukaryota.Hacrobia.Haptophyta.Pavlovophyceae.Pavlovales.Pavlovaceae.Pavlova                                                  0.505   0.036 *  
Eukaryota.Stramenopiles.Ochrophyta.Dictyochophyceae.Dictyochophyceae_X.Pedinellales.Mesopedinella                            0.471   0.031 *  
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1 "

# Definindo os dados
data_controles <- data.frame(
  Group = c(rep("coral", 11), rep("H2O", 29)),
  Species = c(
    "Eukaryota.Archaeplastida.Chlorophyta.Ulvophyceae.Bryopsidales.Bryopsidales_X.Ostreobium",
    "Eukaryota.Alveolata.Apicomplexa.Colpodellidea.Colpodellida.Colpodellaceae.Colpodellidae",
    "Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.Corallinales.Corallinales_X.Calliarthron",
    "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Raphid.pennate_X",
    "Eukaryota.Archaeplastida.Chlorophyta.Ulvophyceae.Bryopsidales.Bryopsidales_X.Bryopsidales_XX",
    "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Navicula",
    "Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.Corallinales.Corallinales_X.__",
    "Eukaryota.Stramenopiles.Ochrophyta.Phaeophyceae.Phaeophyceae_X.Phaeophyceae_XX.Ectocarpus",
    "Eukaryota.Archaeplastida.Rhodophyta.Florideophyceae.__.__.__",
    "Eukaryota.Archaeplastida.Chlorophyta.Ulvophyceae.Bryopsidales.Bryopsidales_X.Bryopsis",
    "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Amphora",
    "Eukaryota.Stramenopiles.Ochrophyta.Pelagophyceae.Pelagomonadales.Pelagomonadaceae.Aureococcus",
    "Eukaryota.Hacrobia.Cryptophyta.Cryptophyceae.Cryptomonadales.Cryptomonadales_X.Teleaulax",
    "Eukaryota.Stramenopiles.Ochrophyta.Dictyochophyceae.Dictyochophyceae_X.Dictyochophyceae_XX.Dictyochophyceae_XXX",
    "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Polar.centric.Mediophyceae.__",
    "Eukaryota.Hacrobia.Haptophyta.Prymnesiophyceae.Phaeocystales.Phaeocystaceae.Phaeocystis",
    "Eukaryota.Stramenopiles.Ochrophyta.Chrysophyceae.Chrysophyceae_X.Chrysophyceae_XX.Chrysophyceae_XXX",
    "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Bacillariophyta_XX.Bacillariophyta_XXX",
    "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Polar.centric.Mediophyceae.Thalassiosira",
    "Eukaryota.Archaeplastida.Chlorophyta.Pyramimonadales.Pyramimonadales_X.Pyramimonadales_XX.Pyramimonas",
    "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Polar.centric.Mediophyceae.Chaetoceros",
    "Eukaryota.Stramenopiles.Ochrophyta.Xanthophyceae.Xanthophyceae_X.Xanthophyceae_XX.Vaucheria",
    "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Raphid.pennate.Cylindrotheca",
    "Eukaryota.Hacrobia.Haptophyta.Prymnesiophyceae.Prymnesiophyceae_X.Prymnesiaceae",
    "Eukaryota.Archaeplastida.Chlorophyta.Chloropicophyceae.Chloropicales.Chloropicaceae.Chloropicon",
    "Eukaryota.Archaeplastida.Chlorophyta.Mamiellophyceae.Mamiellales.Bathycoccaceae.Ostreococcus",
    "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Polar.centric.Mediophyceae.Polar.centric.Mediophyceae_X",
    "Eukaryota.Stramenopiles.Ochrophyta.Pinguiophyceae.Pinguiochrysidales.Pinguiochrysidaceae.Phaeomonas",
    "Eukaryota.Archaeplastida.Chlorophyta.Nephroselmidophyceae.Nephroselmidales.Nephroselmidales_X.Nephroselmis",
    "Eukaryota.Archaeplastida.Chlorophyta.Palmophyllophyceae.Prasinococcales.Prasinococcales.Clade.B.Prasinoderma",
    "Eukaryota.Stramenopiles.Ochrophyta.Eustigmatophyceae.Eustigmatophyceae_X.Eustigmatophyceae_XX.Nannochloropsis",
    "Eukaryota.Archaeplastida.Chlorophyta.Chlorodendrophyceae.Chlorodendrales.Chlorodendraceae.Tetraselmis",
    "Eukaryota.Excavata.Discoba.Euglenozoa.Euglenida.Eutreptiales.Eutreptiella",
    "Eukaryota.Hacrobia.Cryptophyta.Cryptophyceae.Cryptomonadales.Cryptomonadales_X.Proteomonas",
    "Eukaryota.Hacrobia.Haptophyta.Prymnesiophyceae.Prymnesiophyceae_X.__.__",
    "Eukaryota.Stramenopiles.Ochrophyta.Bacillariophyta.Bacillariophyta_X.Radial.centric.basal.Coscinodiscophyceae.Rhizosolenia",
    "Eukaryota.Stramenopiles.Ochrophyta.Dictyochophyceae.Dictyochophyceae_X.Florenciellales.Florenciella",
    "Eukaryota.Archaeplastida.Chlorophyta.Mamiellophyceae.Mamiellales.Mamiellaceae.Mantoniella",
    "Eukaryota.Hacrobia.Haptophyta.Pavlovophyceae.Pavlovales.Pavlovaceae.Pavlova",
    "Eukaryota.Stramenopiles.Ochrophyta.Dictyochophyceae.Dictyochophyceae_X.Pedinellales.Mesopedinella"
  ),
  Stat = c(
    0.957, 0.842, 0.842, 0.842, 0.791, 0.744, 0.645, 0.575, 0.540, 0.500, 0.500,
    0.998, 0.996, 0.994, 0.958, 0.931, 0.913, 0.892, 0.888, 0.850, 0.848, 0.846, 0.825, 0.816, 0.786, 0.782, 0.772,
    0.705, 0.667, 0.667, 0.642, 0.619, 0.577, 0.577, 0.577, 0.577, 0.527, 0.515, 0.505, 0.471
  ),
  P.value = c(
    0.001, 0.001, 0.001, 0.001, 0.001, 0.004, 0.002, 0.019, 0.040, 0.042, 0.041,
    0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.002, 0.001, 0.001,
    0.001, 0.001, 0.001, 0.005, 0.002, 0.003, 0.004, 0.007, 0.002, 0.013, 0.030, 0.036, 0.031
  ),
  Significance = c(
    "***", "***", "***", "***", "***", "**", "**", "*", "*", "*", "*",
    "***", "***", "***", "***", "***", "***", "***", "***", "***", "***", "***", "***", "***", "**", "***", "***",
    "***", "***", "***", "**", "**", "**", "**", "**", "**", "*", "*", "*", "*"
  )
)

# Salvar como CSV
write.csv(data_controles, "indval_controles-ambiente.csv", row.names = FALSE)




##################### JUNTAR GRÁFICOS ############

install.packages("patchwork")
library(patchwork)

# Combine os gráficos
resultados_trans <- combined_plot / (div_transp + plot_c_7)


# PDF
setwd("C:/Users/clara/OneDrive/MICROBIOMAS_CORAIS/Resultados/Figuras")
pdf("resultados_trans_teste.pdf", 7, 10)
resultados_trans
dev.off() 
