## ----custom_functions, echo=FALSE, message=FALSE-------------------------
#Standard error function
std <- function(x) sd(x)/sqrt(length(x))

# ipak function: install and load multiple R packages.
# check to see if packages are installed. Install them if they are not, then load them into the R session.
# Source: https://gist.github.com/stevenworthington/3178163
ipak <- function(pkg){
new.pkg <- pkg[!(pkg %in% installed.packages()[,"Package"])]
if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
sapply(pkg, require, character.only = TRUE)
}

## ----libs and directory, echo=FALSE, message=FALSE-----------------------
packages <- c("ggplot2","RColorBrewer","grid","gridExtra","plyr","lme4","lsmeans","knitr","tidyr","dplyr", "MASS")
ipak(packages)

## ----data process--------------------------------------------------------
#Reading the file
seed <- read.csv("../data/clean/seed_rot.csv")

#Summarizing data using different parameters by plyr library
seed_sum <- ddply(seed, c("Species", "Temp"), summarise,
              N = length(DIx100),
              mean_DI = mean(DIx100), 
              sd_DI = sd(DIx100),
              se_DI = sd_DI/sqrt(N)
              )
  
#Setting limits for error bars
limits <- aes(ymax = mean_DI + se_DI, ymin=mean_DI - se_DI, col=Temp)

## ----seed_rot plot, fig.align='center', fig.width=12, fig.height=9-------
#Creating plot for DI mean values
(seed_temp <- ggplot(seed_sum, aes(x=reorder(Species, mean_DI,median), y=mean_DI)) + 
  geom_point(aes(colour=Temp), stat = "summary", fun.y="mean", size=2) + 
  theme_gray() +
  theme(axis.text.x=element_text(angle=90, hjust = 1, vjust = 0.5, face="italic")) +
  scale_color_manual(values=c("#80b1d3","#fb8072")) +
  geom_errorbar(limits, width=0.2) + 
  labs(x="Species", y="Disease Severity Index"))

## ----model eval at 20C, fig.align='center'-------------------------------
#Dataset for 20C for seed rot
Seed_20C <- subset(seed, seed$Temp=="20C")

#General model AOV
fit1_20C <- aov(DIx100 ~ Species, data=Seed_20C)
summary(fit1_20C, adjust="bon")

#Plotting diagnostic plots for fit1 model
par(mfrow=c(2,2)) # optional layout 
diag_plot_20C <- plot(fit1_20C)# diagnostic plots

#Plotting residuals
par(mfrow=c(1,1)) # optional layout 
hist_20C_res <- hist(fit1_20C$residuals)

#Test with random effect fit2 using aov
fit1.2_20C <- aov(DIx100 ~ Species + Species:Isolate + Error(Set), data=Seed_20C)
summary(fit1.2_20C, adjust="bon")


##Model 2 with fixed effect (species) and random effect (set)
fit2_20C <- lmer(DIx100 ~ Species + (1|Set), data=Seed_20C, REML = FALSE)
summary(fit2_20C)

#Model 2 fitting (fitted vs residuals)
fitvsres_20C <- plot(fit2_20C)

## ----lsmeans 20C model 2, fig.align='center', fig.width=8, fig.height=10----
#lsmeans for model 2
lsmeans_fit2_20C <- lsmeans(fit2_20C,"Species")

#Print summary for data including mean, SE, df, CIs, t-ratio and p.value
#summary(lsmeans_fit2_20C, infer=c(TRUE,TRUE), adjust="bon")

#plot(lsmeans_fit2_20C)

#Estimate confidence intervals for model 2
#confint(contrast(lsmeans_fit2, "trt.vs.ctrl", ref=3))

## ----lsmeans_model3_20C--------------------------------------------------
#Model 3 with fixed effect (species) and random effect (set) and nested effect (species:isolate)
fit3_20C <- lmer(DIx100 ~ Species + (1|Set) + (1|Species:Isolate), data=Seed_20C, REML = FALSE)
summary(fit3_20C)

#Model 3 fitting (fitted vs residuals)
plot(fit3_20C)

## ----model comparison, fig.align='center', fig.width=8, fig.height=10----
#lsmeans for model 3
lsmeans_fit3_20C <- lsmeans(fit3_20C, "Species")

#Print summary for data including mean, SE, df, CIs, t-ratio and p.value
#summary(lsmeans_fit3_20C, infer=c(TRUE,TRUE), adjust="bon")

plot(lsmeans_fit3_20C)

#Comparing models 2 and 3
anova(fit2_20C, fit3_20C)

## ----contrast for model 3------------------------------------------------
#Contrast for model 3
CvsA_fit3_20C <- contrast(lsmeans_fit3_20C, "trt.vs.ctrl", ref=3)
Results_fit3_20C <- summary(CvsA_fit3_20C, adjust="bon")
kable(Results_fit3_20C, digits = 3, format = "markdown")

## ----model eval at 13C, fig.align='center'-------------------------------
#Dataset for 20C for seed rot
Seed_13C <- subset(seed, seed$Temp=="13C")
#General model AOV
fit1_13C <- aov(DIx100 ~ Species, data=Seed_13C)
summary(fit1_13C, adjust="bon")

#Plotting diagnostic plots for fit1 model
par(mfrow=c(2,2)) # optional layout 
#plot(fit1_13C)# diagnostic plots

#Plotting residuals
par(mfrow=c(1,1)) # optional layout 
#hist(fit1_13C$residuals)

##Model 2 with fixed effect (species) and random effect (set)
fit2_13C <- lmer(DIx100 ~ Species + (1|Set), data=Seed_13C, REML = FALSE)
summary(fit2_13C)

#Model 2 fitting (fitted vs residuals)
#plot(fit2_13C)

## ----lsmeans 13C, fig.align='center', fig.width=8, fig.height=10---------
#lsmeans for model 2
lsmeans_fit2_13C <- lsmeans(fit2_13C,"Species")

#Print summary for data including mean, SE, df, CIs, t-ratio and p.value
#summary(lsmeans_fit2_13C, infer=c(TRUE,TRUE), adjust="bon")

#plot(lsmeans_fit2_13C)

#Estimate confidence intervals for model 2
#confint(contrast(lsmeans_fit2, "trt.vs.ctrl", ref=3))

## ----lsmeans_model3------------------------------------------------------
#Model 3 with fixed effect (species) and random effect (set) and nested effect (species:isolate)
fit3_13C <- lmer(DIx100 ~ Species + (1|Set) + (1|Species:Isolate), data=Seed_13C, REML = FALSE)
summary(fit3_13C)

#Model 3 fitting (fitted vs residuals)
#plot(fit3_13C)

## ----model comaprison, fig.align='center', fig.width=8, fig.height=10----
#lsmeans for model 3
lsmeans_fit3_13C <- lsmeans(fit3_13C, "Species")

#Print summary for data including mean, SE, df, CIs, t-ratio and p.value
#summary(lsmeans_fit3_13C, infer=c(TRUE,TRUE), adjust="bon")

#plot(lsmeans_fit3_13C)

#Comparing models 2 and 3
anova(fit2_13C, fit3_13C)

## ----Contrasts for model 3-----------------------------------------------
#Contrast for model 3
CvsA_fit3_13C <- contrast(lsmeans_fit3_13C, "trt.vs.ctrl", ref=3)
Results_fit3_13C <- summary(CvsA_fit3_13C, adjust="bon", level=.90)
kable(Results_fit3_13C, format = "markdown")

## ----Cluster analysis seed rot-------------------------------------------
#Sorting tables for seed rot at 13C and 20C
Seed_13C <- Seed_13C[order(Seed_13C[,1], Seed_13C[,2], Seed_13C[,3]),]
Seed_20C <- Seed_20C[order(Seed_20C[,1], Seed_20C[,2], Seed_20C[,3]),]

#Join tables using isolate, species, set and replicate
Seed_temps <- left_join(Seed_13C,Seed_20C,by=c("Isolate","Species","Set","Rep"))
Seed_temps <- Seed_temps %>% dplyr::select(Set, Isolate, Rep, Species, Temp.x, Temp.y, DIx100.x, DIx100.y)
#Sanity check
#dim(Seed_temps)

#Relabel columns for analysis
Seed_temps <- rename(Seed_temps, Temp13C=Temp.x, Temp_20C=Temp.y, DI_13C=DIx100.x,  DI_20C=DIx100.y)
head(Seed_temps)
#lda
#r <- lda(formula=Species ~ DI_13C + DI_20C, data=Seed_temps)

#Summarizing data using different parameters by plyr library
seed_lda_isol <- ddply(Seed_temps, c("Species"), summarise,
              N = length(DI_13C),
              mean_DI13 = mean(DI_13C),
              std_DI13 = std(DI_13C),
              mean_DI20 = mean(DI_20C),
              std_DI20 = std(DI_20C)
              )

library(car)
#Clustering by isolate
scatterplotMatrix(seed_lda_isol[c(3,5)])

#Hierarchical clustering
library(ape)
seed_cluster <- seed_lda_isol[,-c(2,4,6)]
rownames(seed_cluster) <- make.names(seed_cluster[,1], unique = TRUE)
seed_cluster <- seed_cluster[,-1]

d_isol <- dist(seed_cluster, method="euclidean")
fit_isol <- hclust(d_isol, method="ward.D")
#plot(fit_isol)
groups_isol <- cutree(fit_isol, k=3)
rect.hclust(fit_isol,k=3, border="red")

###Clustering with a different package
library(plyr)
seed_rot_isol <- cbind(seed_lda_isol,groups_isol)
cluster_seed_rot <- gather(seed_rot_isol, Temp, DI, c(mean_DI13, mean_DI20))
cluster_seed_rot$groups_isol <- as.factor(cluster_seed_rot$groups_isol)
#Change levels
cluster_seed_rot$groups_isol <- revalue(cluster_seed_rot$groups_isol, c("1" = "A", "2"="C", "3"="B")) 
#Reorder levels
cluster_seed_rot$groups_isol <- ordered(cluster_seed_rot$groups_isol, levels=c("A","B","C"))

library(ggplot2)
bp <- ggplot(data=cluster_seed_rot, aes(x=groups_isol, y=DI)) + 
  geom_boxplot(aes(fill=Temp), position=position_dodge(width=1)) +
  labs(x="Clusters", y="Disease Severity Index") +
  scale_fill_discrete(labels=c("13ºC","20ºC"))

# library(mclust)
# set.seed(0)
# fit2 <- Mclust(seed_lda)
# summary(fit2)

library(cluster)
#clusplot(seed_lda_isol,groups_isol, color = TRUE, shade = TRUE, labels=2, lines=0)
#kable(seed_lda_)


## ----plot_phylo, fig.height=8, fig.width=15, warning=FALSE, message=FALSE----
library(ggtree)
library(cowplot)
#mypal = c("#1a1a1a","#008837","#2b83ba")
#htree <- plot(as.phylo(fit_isol), cex=0.6, type="phylogram", tip.color = mypal[groups_isol])
P <- as.phylo(fit_isol)
P <- groupClade(P, node=c(90, 89, 87))
htree2 <- ggtree(P, aes(colour=group), size=0.5) + geom_text(aes(label=label), size=3, hjust=-0.05) + 
  scale_color_manual(values = c("#1a1a1a","#1a1a1a","#008837","#2b83ba"))

htree2.1 <- htree2 +
  geom_cladelabel(node=90, "Cluster A", offset.text = 20, offset = 400, color="#636363") + 
  geom_cladelabel(node=89, "Cluster B", offset.text = 20, offset = 400, color="#525252") +
  geom_cladelabel(node=87, "Cluster C", offset.text = 20, offset = 400, color="#252525")

plot_grid(htree2.1, bp, labels=c("A","B"), ncol=2)

#library(ggdendro)
#ggdendrogram(fit_isol, size=1, color="tomato")


## ----Final seed rot table------------------------------------------------

seed_spp <- ddply(Seed_temps, c("Species"), summarise,
              N = length(DI_13C)/9,
              mean_DI13 = mean(DI_13C),
              std_DI13 = std(DI_13C),
              mean_DI20 = mean(DI_20C),
              std_DI20 = std(DI_20C)
              )

#Transforming dataframes to remove " - " and split the column into species and control (reference for comparison)
library(reshape2)
DI_13C <- separate(Results_fit3_13C, contrast, into = c("Species", "Control"), " - ")
DI_20C <- separate(Results_fit3_20C, contrast, into = c("Species", "Control"), " - ")

#merge tables together
Seed_pvalue <- left_join(DI_13C,DI_20C,by="Species")

#Rename important columns
Seed_pvalue<- rename(Seed_pvalue, Control=Control.x, 
                     Estimate_13C=estimate.x, 
                     Pval_13C=p.value.x,    
                     Estimate_20C=estimate.y,
                     Pval_20C=p.value.y
                     )

#Merge last table
Seed_pvalue <- left_join(Seed_pvalue,seed_spp, by="Species")

Seed_rot_final <- Seed_pvalue %>% dplyr::select(Species,
                                                N,
                                                mean_DI13,
                                                std_DI13,
                                                Pval_13C,
                                                mean_DI20,
                                                std_DI20,
                                                Pval_20C
                                                )
kable(Seed_rot_final, format = "markdown")
