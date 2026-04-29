####### 2-SAMPLE MR: ESTIMATE THE CAUSAL EFFECTS OF ADHD ON ASTHMA & ALLERGIC CONDITIONS

#### Author: Panagiota Pagoni
#### Date: 11/02/2022


setwd("your/directory")

# Install all packages needed #

#install.packages("devtools")
#install_github("MRCIEU/TwoSampleMR")
#install.packages("plyr")
#install.packages("ggplot2")
#install.packages("forestplot")
#install.packages("grid")
#install.packages("gridExtra")
#install.packages("MendelianRandomization")
#install.packages('phenoscanner')
#install.packages('ieugwasr')

# Load libraries #
library("devtools")
library("TwoSampleMR")
library("MRInstruments")
library("plyr")
library("ggplot2")
library('grid')
library('gridExtra')
library('forestplot')
library ('MendelianRandomization')
library("ieugwasr")

exp_list <- as.matrix( c('ADHD') )

for (k in 1:dim(exp_list)[1] ){
  
# load exposure data - this file includes only the genome wide significant genetic variants (P<=5x10-08)

exp_data <- read.delim(paste0( paste0( "your/directory/",exp_list[k]),".MR"), header = T, sep = "\t" )
head(exp_data)

exp_cl_data <- as.data.frame( matrix (NA, nrow = dim(exp_data)[1], ncol = 2))
colnames(exp_cl_data) <- c( 'rsid', 'pval')
exp_cl_data$rsid <- exp_data$SNP
exp_cl_data$pval <- exp_data$P

exp_clumped <- ld_clump( dat = exp_cl_data,
                         clump_kb = 10000,
                         clump_r2 = 0.01,
                         clump_p = 1,
                         access_token = NULL,
                         bfile = NULL,
                         plink_bin = NULL)

exp_data.form <-format_data(exp_data,
                            type = "exposure",
                            snps = exp_clumped$rsid,
                            header = TRUE,
                            phenotype_col = "Phenotype",
                            snp_col = "SNP",
                            beta_col = "BETA.trans",
                            se_col = "SE",
                            eaf_col = "MAF.trans",
                            effect_allele_col = "A1.trans",
                            other_allele_col = "A2.trans",
                            pval_col = "P",
                            chr_col = "CHR",
                            pos_col = "BP")

# Load outcome data

out_list <- as.matrix( c('Asthma', 'Eczema', 'Hay_fever','Broad_allergic_phenotype','Allergic_sensitization') )

for (j in 1:dim(out_list)[1] ){
  
  out_data <- read.delim( paste0 ( paste0 ( "your/directory/", out_list[j]), ".MR"), sep = "\t")
  
  out_data.form <-format_data(out_data,
                              type = "outcome",
                              snps = NULL,
                              header = TRUE,
                              phenotype_col = "Phenotype",
                              snp_col = "SNP",
                              beta_col = "BETA",
                              se_col = "SE",
                              eaf_col = "MAF",
                              effect_allele_col = "A1",
                              other_allele_col = "A2",
                              pval_col = "P")
  
  csv.out <- write.table ( out_data.form,paste0( paste0 ( "your/directory/",out_list[j]), ".csv"), row.names = F, sep =",")
  
  out_data.form <- read_outcome_data(paste0( paste0 ( "your/directory/",out_list[j]), ".csv"),
                                     snps = exp_clumped$rsid,
                                     sep = ",",
                                     phenotype_col = "Phenotype", 
                                     snp_col = "SNP", 
                                     beta_col = "beta.outcome",
                                     se_col = "se.outcome", 
                                     eaf_col = "eaf.outcome", 
                                     effect_allele_col = "effect_allele.outcome",
                                     other_allele_col = "other_allele.outcome", 
                                     pval_col = "pval.outcome")
  
  comb_data <-harmonise_data( exposure_dat = exp_data.form, outcome_dat = out_data.form, action = 2)
  no.palindromic_X1 <- table(comb_data$palindromic)['TRUE'] # count palindromic SNPs
  no.palindromic_X1
  head(comb_data)
  
  EXP_OUT_ALL_data <- data.frame ( matrix ( NA, nrow = dim(comb_data)[1] , ncol = 20 ))
  
  colnames(EXP_OUT_ALL_data) <- c( 'SNP' , 'CHR' ,'Effect_allele.X1' , 'Other_allele.X1' , 'BETA.X1' , 'SE.X1' , 'P.X1' , 'EAF.X1' ,
                                   'Proxy', 'Proxy.Effect_allele.X1','Proxy.Other_allele.X1', 'Proxy.EAF.X1', 
                                   'Effect_allele.Y' , 'Other_allele.Y' , 'BETA.Y' , 'SE.Y' , 'P.Y' , 'EAF.Y' ,
                                   'palindromic' , 'mr_keep')
  
  EXP_OUT_ALL_data$SNP <- comb_data$SNP
  EXP_OUT_ALL_data$CHR <- comb_data$chr.exposure
  
  EXP_OUT_ALL_data$Effect_allele.X1 <-comb_data$effect_allele.exposure
  EXP_OUT_ALL_data$Other_allele.X1 <-comb_data$other_allele.exposure
  EXP_OUT_ALL_data$BETA.X1 <-comb_data$beta.exposure
  EXP_OUT_ALL_data$SE.X1 <-comb_data$se.exposure
  EXP_OUT_ALL_data$P.X1 <-comb_data$pval.exposure
  EXP_OUT_ALL_data$EAF.X1 <-comb_data$eaf.exposure
  
  EXP_OUT_ALL_data$Effect_allele.Y <-comb_data$effect_allele.outcome
  EXP_OUT_ALL_data$Other_allele.Y <-comb_data$other_allele.outcome
  EXP_OUT_ALL_data$BETA.Y <-comb_data$beta.outcome
  EXP_OUT_ALL_data$SE.Y <-comb_data$se.outcome
  EXP_OUT_ALL_data$P.Y <-comb_data$pval.outcome
  EXP_OUT_ALL_data$EAF.Y <-comb_data$eaf.outcome
  
  EXP_OUT_ALL_data$palindromic <- comb_data$palindromic
  EXP_OUT_ALL_data$mr_keep <- comb_data$mr_keep
  
  #Exclusion of palindromic SNPs
  
  EXP_OUT_ALL_data <- EXP_OUT_ALL_data[ EXP_OUT_ALL_data$palindromic != 'TRUE' , ]
  head(EXP_OUT_ALL_data)
  
  # Harmonise alleles to express increased risk per allele increament in exposure
  
  my_harmonise_data <- function (EXP_OUT_ALL_data , SNP , Effect_allele.X1 , Other_allele.X1 , BETA.X1 , SE.X1 , P.X1 , EAF.X1 ,
                                 Effect_allele.Y , Other_allele.Y , BETA.Y , SE.Y , P.Y , EAF.Y) {
    
    harm_table <- as.data.frame(matrix(NA, nrow = dim(EXP_OUT_ALL_data)[1], ncol = 18))
    
    colnames(harm_table) <- c( 'SNP','CHR','Effect_allele.X1' , 'Other_allele.X1' , 'BETA.X1' , 'SE.X1' , 'P.X1' , 'EAF.X1', 'CHANGE.X1' , 'HARMONISED.X1',
                               'Effect_allele.Y' , 'Other_allele.Y' , 'BETA.Y' , 'SE.Y' , 'P.Y' , 'EAF.Y', 'CHANGE.Y' , 'HARMONISED.Y')
    
    for (i in 1:dim(EXP_OUT_ALL_data)[1]) {
      
      harm_table$SNP[i] <- as.character(EXP_OUT_ALL_data$SNP[i])
      harm_table$CHR[i]<-EXP_OUT_ALL_data$CHR[i]
      
      harm_table$SE.X1[i] <- EXP_OUT_ALL_data$SE.X1[i]
      harm_table$P.X1[i] <- EXP_OUT_ALL_data$P.X1[i]
      
      harm_table$SE.Y[i] <- EXP_OUT_ALL_data$SE.Y[i]
      harm_table$P.Y[i] <- EXP_OUT_ALL_data$P.Y[i]
      
      if ( EXP_OUT_ALL_data$BETA.X1 [i] < 0 ) {
        
        harm_table$BETA.X1 [i] <- (0-EXP_OUT_ALL_data$BETA.X1[i]) # change into absolute value 
        
        harm_table$Effect_allele.X1 [i] <- as.character(EXP_OUT_ALL_data$Other_allele.X1[i]) 
        harm_table$Other_allele.X1 [i] <- as.character(EXP_OUT_ALL_data$Effect_allele.X1[i]) 
        harm_table$EAF.X1 [i] <- (1 - EXP_OUT_ALL_data$EAF.X1[i]) # eaf new
        harm_table$CHANGE.X1 [i] <- 'TRUE'
        
      }
      
      else{
        
        harm_table$BETA.X1 [i] <- EXP_OUT_ALL_data$BETA.X1[i] 
        
        harm_table$Effect_allele.X1 [i] <- as.character(EXP_OUT_ALL_data$Effect_allele.X1[i]) 
        harm_table$Other_allele.X1 [i] <- as.character(EXP_OUT_ALL_data$Other_allele.X1[i]) 
        harm_table$EAF.X1 [i] <- EXP_OUT_ALL_data$EAF.X1[i] 
        harm_table$CHANGE.X1[i] <- 'FALSE'
        
      }
      
      harm_table$HARMONISED.X1 [i] <- 'TRUE'
      
      # harmonise outcome alleles according to exposure alleles 
      
      if ( as.character(harm_table$Effect_allele.X1[i]) != as.character(EXP_OUT_ALL_data$Effect_allele.Y[i]) & 
           as.character(harm_table$Other_allele.X1[i]) != as.character(EXP_OUT_ALL_data$Other_allele.Y[i]) ){
        
        
        harm_table$BETA.Y[i] <- (0-EXP_OUT_ALL_data$BETA.Y[i]) # change beta coefficient
        harm_table$Effect_allele.Y[i] <- as.character(EXP_OUT_ALL_data$Other_allele.Y[i]) # change alleles
        harm_table$Other_allele.Y[i] <- as.character(EXP_OUT_ALL_data$Effect_allele.Y[i]) # change alleles
        harm_table$EAF.Y[i] <- (1-EXP_OUT_ALL_data$EAF.Y[i]) # change EAF
        harm_table$CHANGE.Y[i] <- 'TRUE'
        
      }
      
      if ( as.character(harm_table$Effect_allele.X1[i]) == as.character(EXP_OUT_ALL_data$Effect_allele.Y[i]) & 
           as.character(harm_table$Other_allele.X1[i]) == as.character(EXP_OUT_ALL_data$Other_allele.Y[i]) ){
        
        
        harm_table$BETA.Y[i] <- EXP_OUT_ALL_data$BETA.Y[i]
        harm_table$Effect_allele.Y[i] <- as.character(EXP_OUT_ALL_data$Effect_allele.Y[i]) 
        harm_table$Other_allele.Y[i] <- as.character(EXP_OUT_ALL_data$Other_allele.Y[i]) 
        harm_table$EAF.Y[i] <- EXP_OUT_ALL_data$EAF.Y[i] # change EAF
        harm_table$CHANGE.Y[i] <- 'FALSE'
        
      }
      
      harm_table$HARMONISED.Y [i] <- 'TRUE'
      
    }
    
    return(harm_table)
  }
  
  harm_data <- my_harmonise_data(EXP_OUT_ALL_data)
  
  write.table( harm_data, paste( paste( paste ("your/directory/harm_data",exp_list[k], sep = "_" ),
                                        out_list[j], sep = "_"),"txt", sep = "."),  sep = "\t", quote = F, col.names = T, row.names = F)
  
  
  ### Estimation of causal effects ####
  
  res.all<-matrix(NA, nrow= 6, ncol=13) 
  colnames(res.all) <- c('Method', 'no.SNPS', 'b','se', 'Lci', 'Uci', 'pval', 'Qstat',  'Q_pval', 'I^2', 'EXP_BETA', 'EXP_Lci', 'EXP_Uci' )
  
  res.all[,1] <- c('IVW (random effects)' , 'Maximum Likelihood', 'MR_egger_intercept', 'MR_egger_Slope', 'Weighted Median', 'Weighted Mode')
  
  ## IVW - Inverse Variance Weighted Method (random effects)##
  
  MRObject.all<-mr_input(bx=harm_data$BETA.X1,bxse=harm_data$SE.X1,by=harm_data$BETA.Y,byse=harm_data$SE.Y,outcome=out_list[j],exposure = exp_list[k], snps=harm_data$SNP)
  
  mr_ivw(MRObject.all,model = 'random')
  
  ivw<-c(NA, mr_ivw(MRObject.all,model = 'random')@SNPs,
         mr_ivw(MRObject.all,model = 'random')@Estimate,
         mr_ivw(MRObject.all,model = 'random')@StdError,
         mr_ivw(MRObject.all,model = 'random')@CILower,
         mr_ivw(MRObject.all,model = 'random')@CIUpper, 
         mr_ivw(MRObject.all,model = 'random')@Pvalue,
         mr_ivw(MRObject.all,model = 'random')@Heter.Stat,NA,
         exp( mr_ivw(MRObject.all,model = 'random')@Estimate ),
         exp( mr_ivw(MRObject.all,model = 'random')@CILower ),
         exp( mr_ivw(MRObject.all,model = 'random')@CIUpper) ) 
  
  ## Maximul-likelihood Method ##

  mr_maxlik(MRObject.all,model = "random")
  
  maxlik<-c(NA, mr_maxlik(MRObject.all,model = "random")@SNPs,
            mr_maxlik(MRObject.all,model = "random")@Estimate,
            mr_maxlik(MRObject.all,model = "random")@StdError,
            mr_maxlik(MRObject.all,model = "random")@CILower,
            mr_maxlik(MRObject.all,model = "random")@CIUpper, 
            mr_maxlik(MRObject.all,model = "random")@Pvalue,
            mr_maxlik(MRObject.all,model = "random")@Heter.Stat,NA,
            exp( mr_maxlik(MRObject.all,model = "random")@Estimate ),
            exp( mr_maxlik(MRObject.all,model = "random")@CILower ),
            exp( mr_maxlik(MRObject.all,model = "random")@CIUpper) ) 
  
  if ( no.var == 1 ){
    
    for ( y in 2:dim(res.all)[2]) {
      
      res.all[1,y]<- ivw[[y]]
      res.all[2,y] <- maxlik[[y]]
      
    }
  } else if ( no.var > 1 & no.var < 3 ){
    
    ## Mode based method ##

    mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)
    
    mrmode<-c(NA,mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@SNPs,
              mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@Estimate,
              mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@StdError,
              mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@CILower,
              mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@CIUpper,
              mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@Pvalue,
              NA,NA,NA,
              exp(mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@Estimate ),
              exp(mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@CILower ),
              exp(mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@CIUpper))
    
    for ( y in 2:dim(res.all)[2]) {
      
      res.all[1,y]<- ivw[[y]]
      res.all[2,y] <- maxlik[[y]]
      res.all[6,y] <- mrmode[[y]]
      
    }
  } else {
    
    ## Mode based method ##

    mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)
    
    mrmode<-c(NA,mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@SNPs,
              mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@Estimate,
              mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@StdError,
              mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@CILower,
              mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@CIUpper,
              mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@Pvalue,
              NA,NA,NA,
              exp(mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@Estimate ),
              exp(mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@CILower ),
              exp(mr_mbe(MRObject.all, weighting = "weighted",stderror = "delta", phi = 1)@CIUpper))
    
    ## MR-Egger ##

    mr_egger(MRObject.all, distribution="normal")
    
    mr_egger(MRObject.all, distribution ="normal")@Causal.pval
    mr_egger(MRObject.all, distribution ="normal")@Pleio.pval
    
    mr_e_intercept<-c(NA,mr_egger(MRObject.all, distribution ="normal")@SNPs,
                      mr_egger(MRObject.all, distribution = "normal")@Intercept, #intercept beta
                      mr_egger(MRObject.all, distribution = "normal")@StdError.Int, #intercept SE
                      mr_egger(MRObject.all, distribution = "normal")@CILower.Int,
                      mr_egger(MRObject.all, distribution = "normal")@CIUpper.Int,
                      mr_egger(MRObject.all, distribution = "normal")@Pvalue.Int, #intercept pvalue
                      NA,NA,NA,
                      exp( mr_egger(MRObject.all, distribution = "normal")@Intercept ), #intercept beta
                      exp (mr_egger(MRObject.all, distribution = "normal")@CILower.Int ) ,
                      exp (mr_egger(MRObject.all, distribution = "normal")@CIUpper.Int) )
    
    mr_eslope<-c( NA, mr_egger(MRObject.all, distribution ="normal")@SNPs,
                  mr_egger(MRObject.all, distribution = "normal")@Estimate,  #slope beta
                  mr_egger(MRObject.all, distribution = "normal")@StdError.Est, #slope SE
                  mr_egger(MRObject.all, distribution = "normal")@CILower.Est,
                  mr_egger(MRObject.all, distribution = "normal")@CIUpper.Est,
                  mr_egger(MRObject.all, distribution = "normal")@Pvalue.Est, #slope pvalue
                  mr_egger(MRObject.all, distribution = "normal")@Heter.Stat,#slope pvalue
                  mr_egger(MRObject.all, distribution = "normal")@I.sq,  #I^2
                  exp( mr_egger(MRObject.all, distribution = "normal")@Estimate ),  #slope beta
                  exp( mr_egger(MRObject.all, distribution = "normal")@CILower.Est ),
                  exp (mr_egger(MRObject.all, distribution = "normal")@CIUpper.Est) )
    
    ## Weighted Median ##
    
    mr_median(MRObject.all, weighting = "weighted", distribution = "normal")
    
    mrmedian<-c(NA,mr_median(MRObject.all, weighting = "weighted", distribution = "normal")@SNPs,
                mr_median(MRObject.all, weighting = "weighted", distribution = "normal")@Estimate,
                mr_median(MRObject.all, weighting = "weighted", distribution = "normal")@StdError,
                mr_median(MRObject.all, weighting = "weighted", distribution = "normal")@CILower,
                mr_median(MRObject.all, weighting = "weighted", distribution = "normal")@CIUpper,
                mr_median(MRObject.all, weighting = "weighted", distribution = "normal")@Pvalue,
                NA,NA,NA,
                exp( mr_median(MRObject.all, weighting = "weighted", distribution = "normal")@Estimate ),
                exp( mr_median(MRObject.all, weighting = "weighted", distribution = "normal")@CILower ),
                exp( mr_median(MRObject.all, weighting = "weighted", distribution = "normal")@CIUpper))
    
    
    for ( i in 2:dim(res.all)[2]) {
      
      res.all[1,i]<- ivw[[i]]
      res.all[2,i] <- maxlik[[i]]
      res.all[3,i] <- mr_e_intercept[[i]]
      res.all[4,i] <- mr_eslope[[i]]
      res.all[5,i] <- mrmedian[[i]]
      res.all[6,i] <- mrmode[[i]]
      
    }
    
  }
  
  
  write.table( res.all, paste( paste( paste ("your/directory/MR_RES",exp_list[k], sep = "_" ),
                                      out_list[j], sep = "_"),"txt", sep = "."),
               sep = "\t", quote = F, col.names = T, row.names = F)
  

# Leave-one out analysis 

leave_one_out_fun <- function(x , BETA.X1 , SE.X1 , BETA.Y , SE.Y) {
  
  effect_estimates <- as.data.frame(matrix(NA, nrow= dim(x)[1], ncol=12))
  colnames(effect_estimates) <- c('SNP', 'no.SNPS', 'b','se', 'Lci', 'Uci', 'pval', 'Qstat',  'Q_pval',  'OR', 'OR_Lci', 'OR_Uci' )
  
  for ( i in 1:dim(x)[1]) {
    
    MRObject.fun<-mr_input(bx=x$BETA.X1[-i],bxse=x$SE.X1[-i],by=x$BETA.Y[-i],byse=x$SE.Y[-i],outcome="Alzheimer's disease" , exposure = "ADHD")
    mr.ivw.new <- mr_ivw (MRObject.fun, model ='random')
    
    effect_estimates[i,] <- c(x$SNP[i],
                              mr_ivw(MRObject.fun,model = 'random')@SNPs,
                              mr_ivw(MRObject.fun,model = 'random')@Estimate,
                              mr_ivw(MRObject.fun,model = 'random')@StdError,
                              mr_ivw(MRObject.fun,model = 'random')@CILower,
                              mr_ivw(MRObject.fun,model = 'random')@CIUpper, 
                              mr_ivw(MRObject.fun,model = 'random')@Pvalue,
                              mr_ivw(MRObject.fun,model = 'random')@Heter.Stat,
                              exp( mr_ivw(MRObject.fun,model = 'random')@Estimate ),
                              exp( mr_ivw(MRObject.fun,model = 'random')@CILower ),
                              exp( mr_ivw(MRObject.fun,model = 'random')@CIUpper) ) 
  }
  
  sort.var<-as.matrix(order(as.numeric(effect_estimates[,3]),decreasing=T))
  sort.loo<-as.matrix(effect_estimates[sort.var,])
  res.combined<-rbind(sort.loo,res.all[1,-10])

  char.intervals.beta<-matrix(NA,dim(res.combined)[1],ncol=1)
  colnames(char.intervals.beta)<-c('Effect estimates ( 95%CI )')
  
  for ( i in 1:dim(res.combined)[1]) {
    
    char.intervals.beta[i,]<-paste0(" ",format(round(as.numeric(res.combined[i,3]),digits=3),nsmall=2)," ","(",
                                    format(round(as.numeric(res.combined[i,5]),digits=2),nsmall=2),",",
                                    format(round(as.numeric(res.combined[i,6]),digits=2),nsmall=2),")")
    
  }
  
  forest.table<-cbind(res.combined,char.intervals.beta)
  return(forest.table)
}

res.loo <- leave_one_out_fun(x = harm_data , BETA.X1 = harm_data$BETA.X1 , SE.X1 = harm_data$SE.X1 , BETA.Y = harm_data$BETA.Y , SE.Y = harm_data$SE.Y) 
write.table(res.loo, paste0( paste( paste0("loo_",exp_list[k]),out_list[j],sep="_"),".txt"))

}

}
