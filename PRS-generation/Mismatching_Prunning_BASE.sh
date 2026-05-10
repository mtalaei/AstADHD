#################### 2nd Script: Mismatching alleles, prunning and input for PRS ####################
#####  Creator: Dr. Panagiota Pagoni
#####  Date: 14-11-2022


### Set directories

TARGET_DIR=/your/directory/target_data

# Directory of base data 

BASE_DIR=/your/directory/base_data

# Directory of Scripts

SCRIPT_DIR=/your/directory/scripts


####### Mismatching SNPs & Clumping & PRS BASE inputs ######### 

echo Identify mismatching SNPs and remove them from Base GWAS

module load lang/r/3.6.1
Rscript --vanilla $SCRIPT_DIR/mismacthing_SNPs_BASE.R

## 1.Remove mismatching SNPs (separately for mothers &  children)

# MOTHERS #

# Include genetic variants with matching in SNP ID, CHR, BP in Base and Target data

awk 'NR==FNR{a[$1];next}($2 in a){print}' $BASE_DIR/BASE.QC.common.variants.mothers $BASE_DIR/BASE.QC > $BASE_DIR/BASE.QC.new.1

# Exclude genetic variants due to mismatchinh alleles between Base and Target data

awk 'NR==FNR{a[$1];next}!($2 in a){print}' $BASE_DIR/BASE.QC.mismatching.alleles.mothers $BASE_DIR/BASE.QC.new.1 > $BASE_DIR/BASE.QC.new.2
(head -1 $BASE_DIR/BASE; tail -n+1 $BASE_DIR/BASE.QC.new.2) > $BASE_DIR/BASE.QC.mothers
rm $BASE_DIR/BASE.QC.new.1 $BASE_DIR/BASE.QC.new.2

# Print the number of genetic variants excluded from the Base data after checking for mismatching SNPS ID, CHR, BP, mismatching alleles

awk 'END{print "Number of genetic variants excluded due to mismatch in SNP ID, CHR, BP (Target mothers): " NR }' $BASE_DIR/BASE.QC.noncommon.variants.mothers
awk 'END{print "Number of genetic variants remaining after exclulding SNPs based on mismatching SNP ID, CHR, BP (Target mothers): " NR }' $BASE_DIR/BASE.QC.common.variants.mothers

awk 'END{print "Number of genetic variants excluded due to mismatching alleles (Target mothers): " NR }' $BASE_DIR/BASE.QC.mismatching.alleles.mothers
awk 'END{print "Number of genetic variants remaining after exclulding SNPs due to mismatching alleles (Target mothers): " NR-1 }' $BASE_DIR/BASE.QC.mothers

rm $BASE_DIR/BASE.QC.noncommon.variants.mothers $BASE_DIR/BASE.QC.common.variants.mothers $BASE_DIR/BASE.QC.mismatching.alleles.mothers $BASE_DIR/BASE.QC.matching.alleles.mothers

# Exclude non common and mismatching alleles genetic variants from mothers

awk '(NR>1){print $2}' $BASE_DIR/BASE.QC.mothers > $BASE_DIR/BASE.QC.mothers.PLINK

module load apps/plink/1.90

plink \
--bfile $TARGET_DIR/mothers_ALSPAC_14112022.QC \
--extract $BASE_DIR/BASE.QC.mothers.PLINK \
--make-bed \
--out $TARGET_DIR/mothers_BASE_ALSPAC.QC


# CHILDREN #

# Include genetic variants with matching in SNP ID, CHR, BP in Base and Target data

awk 'NR==FNR{a[$1];next}($2 in a){print}' $BASE_DIR/BASE.QC.common.variants.children $BASE_DIR/BASE.QC > $BASE_DIR/BASE.QC.new.1

# Exclude genetic variants due to mismatchinh alleles between Base and Target data

awk 'NR==FNR{a[$1];next}!($2 in a){print}' $BASE_DIR/BASE.QC.mismatching.alleles.children $BASE_DIR/BASE.QC.new.1 > $BASE_DIR/BASE.QC.new.2
(head -1 $BASE_DIR/BASE; tail -n+1 $BASE_DIR/BASE.QC.new.2) > $BASE_DIR/BASE.QC.children
rm $BASE_DIR/BASE.QC.new.1 $BASE_DIR/BASE.QC.new.2

# Print the number of genetic variants excluded from the Base data after checking for mismatching SNPS ID, CHR, BP, mismatching alleles

awk 'END{print "Number of genetic variants excluded due to mismatch in SNP ID, CHR, BP (Target children): " NR }' $BASE_DIR/BASE.QC.noncommon.variants.children
awk 'END{print "Number of genetic variants remaining after exclulding SNPs based on mismatching SNP ID, CHR, BP (Target children): " NR }' $BASE_DIR/BASE.QC.common.variants.children

awk 'END{print "Number of genetic variants excluded due to mismatching alleles (Target children): " NR }' $BASE_DIR/BASE.QC.mismatching.alleles.children
awk 'END{print "Number of genetic variants remaining after exclulding SNPs due to mismatching alleles (Target children): " NR-1 }' $BASE_DIR/BASE.QC.children

rm $BASE_DIR/BASE.QC.noncommon.variants.children $BASE_DIR/BASE.QC.common.variants.children $BASE_DIR/BASE.QC.mismatching.alleles.children $BASE_DIR/BASE.QC.matching.alleles.children


# Exclude non common and mismatching alleles genetic variants from children

awk '(NR>1){print $2}' $BASE_DIR/BASE.QC.children > $BASE_DIR/BASE.QC.children.PLINK

module load apps/plink/1.90

plink \
--bfile $TARGET_DIR/children_ALSPAC_14112022.QC \
--extract $BASE_DIR/BASE.QC.children.PLINK \
--make-bed \
--out $TARGET_DIR/children_BASE_ALSPAC.QC

## 2. Remove highly correlated SNPs (Clumping)

echo Identify highly correlated SNPs and remove them from Base and Target data

# Create a list with SNPs after removing highly correlated SNPs

# MOTHERS #

module load apps/plink/1.90

plink \
    --bfile $TARGET_DIR/mothers_BASE_ALSPAC.QC \
    --clump-p1 0.5 \
    --clump-r2 0.25 \
    --clump-kb 500 \
    --clump $BASE_DIR/BASE.QC.mothers \
    --clump-snp-field SNP \
    --clump-field P \
    --out $BASE_DIR/mothers_BASE_ALSPAC.QC

# CHILDREN #

module load apps/plink/1.90

plink \
    --bfile $TARGET_DIR/children_BASE_ALSPAC.QC \
    --clump-p1 0.5 \
    --clump-r2 0.25 \
    --clump-kb 500 \
    --clump $BASE_DIR/BASE.QC.children \
    --clump-snp-field SNP \
    --clump-field P \
    --out $BASE_DIR/children_BASE_ALSPAC.QC

# Remove correlated SNPs from Target data. 

# MOTHERS #

module load apps/plink/1.90

plink \
--bfile $TARGET_DIR/mothers_BASE_ALSPAC.QC \
--extract $BASE_DIR/mothers_BASE_ALSPAC.QC.clumped \
--make-bed \
--out $TARGET_DIR/mothers_BASE_ALSPAC.QC.final

# CHILDREN #

module load apps/plink/1.90

plink \
--bfile $TARGET_DIR/children_BASE_ALSPAC.QC \
--extract $BASE_DIR/children_BASE_ALSPAC.QC.clumped \
--make-bed \
--out $TARGET_DIR/children_BASE_ALSPAC.QC.final

awk 'END{print "Number of genetic variants remaining after exclulding SNPs due to being highly correlated (Target mothers): " NR }' $TARGET_DIR/mothers_BASE_ALSPAC.QC.final.bim
awk 'END{print "Number of genetic variants remaining after exclulding SNPs due to being highly correlated (Target children): " NR }' $TARGET_DIR/children_BASE_ALSPAC.QC.final.bim

# Remove highly correlated SNPs from Base data

# Include genetic variants which are not highly correlated (clumped) in Base data

# MOTHERS #

awk 'NR==FNR{a[$3];next}($2 in a){print}' $BASE_DIR/mothers_BASE_ALSPAC.QC.clumped $BASE_DIR/BASE.QC.mothers > $BASE_DIR/BASE.QC.new
mv $BASE_DIR/BASE.QC.new $BASE_DIR/BASE.QC.mothers

# CHILDREN # 

awk 'NR==FNR{a[$3];next}($2 in a){print}' $BASE_DIR/children_BASE_ALSPAC.QC.clumped $BASE_DIR/BASE.QC.children > $BASE_DIR/BASE.QC.new
mv $BASE_DIR/BASE.QC.new $BASE_DIR/BASE.QC.children

awk 'END{print "Number of genetic variants remaining after exclulding SNPs due to being highly correlated (Base mothers): " NR-1 }' $BASE_DIR/BASE.QC.mothers
awk 'END{print "Number of genetic variants remaining after exclulding SNPs due to being highly correlated (Base children): " NR-1 }' $BASE_DIR/BASE.QC.children

## 3. Create PRS inputs based on Base data

echo Calculate weights to be used in PRS analysis based on Base data

# Columns in BASE GWAS dataset 
# $1:CHR, $2:SNP, $3:BP, $4:A1, $5:A2, $6:EAF/MAF, $7:INFO, $8:OR/BETA		
# $9:SE, $10:P, $11:A1.Trans, $12:A2.Trans, $13:EAF/MAF.Trans, $14:BETA.Trans, $15:OR.Trans

# MOTHERS #

# Create a unheaded file that containes SNP ID, Effect Allele (A1) and BETA

awk 'NR>1{print $2" "$11" "$14}'  $BASE_DIR/BASE.QC.mothers  > $BASE_DIR/BASE.QC.mothers.weights

# Create a unheaded file that containes SNP ID and Pvalue

awk 'NR>1{print $2" "$10}'  $BASE_DIR/BASE.QC.mothers  > $BASE_DIR/BASE.QC.mothers.pval

# CHILDREN #

# Create a unheaded file that containes SNP ID, Effect Allele (A1) and BETA

awk 'NR>1{print $2" "$11" "$14}'  $BASE_DIR/BASE.QC.children  > $BASE_DIR/BASE.QC.children.weights

# Create a unheaded file that containes SNP ID and Pvalue

awk 'NR>1{print $2" "$10}'  $BASE_DIR/BASE.QC.children  > $BASE_DIR/BASE.QC.children.pval

echo END OF MISMATCHING, PRUNNING AND INPUTS FOR PRS ANALYSIS

