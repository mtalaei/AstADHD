#################### 1st Script: QC of Base GWAS ####################
#####  Creator: Dr. Panagiota Pagoni
#####  Date: 14-11-2022


### Set directories 

# Directory of analysis scripts

SCRIPT_DIR=/your/directory/scripts

# Directory of base data 

BASE_DIR=/your/directory/base_data

######### Quality Control of Base data ######### 

echo Start Quality Control of Base data

## 1.File transfer: Ensure that Base (GWAS) data have been downloaded correctly and are not corrupted.
# md5sum $BASE_DIR/BASE_14112022.meta.gz
# gunzip $BASE_DIR/BASE_14112022.meta.gz > BASE_14112022

# Print the number of genetic variants included in the Base data beore QC 

awk 'END{print "Number of genetic variants, before any QC (Base data) : " NR-1 }' $BASE_DIR/BASE_14112022

## 2.Genomic build: Ensure that the base and target data SNPs have genomic positions assigned on the same genome build.

## 3.Standard GWAS Quality Control: This can be checked in Base data by reading the paper or if information are provided in base data. In Target data quality control has already been applied centrally in ALSPAC.
# Recommended QC criteria:
# genotyping rate > 0.99
# sample missingness < 0.02
# Hardy-Weinberg Equilibrium P > 1 × 10−6
# heterozygosity within 3 standard deviations of the mean
# minor allele frequency (MAF) > 1%
# imputation ‘info score’ > 0.8. 

# Columns in BASE GWAS dataset 

#$1:CHR, $2:SNP, $3:BP, $4:A1, $5:A2, $6:EAF/MAF, $7:INFO, $8:OR/BETA		
#$9:SE, $10:P

# Identify SNPs with MAF <= 0.01 or INFO <= 0.8
# MAF not available

awk '(($7 <= 0.8)) {print}' $BASE_DIR/BASE_14112022 > $BASE_DIR/BASE.QC.MAF.INFO

# Exclude SNPs with MAF <= 0.01 OR INFO<= 0.8 from BASE GWAS
# No genetic variants were identified with low MAF

cp $BASE_DIR/BASE $BASE_DIR/BASE.QC

# Print the number of genetic variants excluded from the Base data after checking for (MAF, INFO)

awk 'END{print "Number of genetic variants, excluded based on low MAF and INFO (Base data) : " NR }' $BASE_DIR/BASE.QC.MAF.INFO
awk 'END{print "Number of genetic variants, after excluding based on low MAF and INFO (Base data) : " NR-1 }' $BASE_DIR/BASE.QC

## 4. Identify ambiguous SNPs. We recommend removing all ambiguous SNPs to avoid introducing this potential source of systematic error. Non ambiguous SNPs can be retained using the following
# Identify ambiguous SNPs - create a file without heading

awk '(($4=="A" && $5=="T") || ($4=="T" && $5=="A") || ($4=="G" && $5=="C") || ($4=="C" && $5=="G")) {print}' $BASE_DIR/BASE.QC > $BASE_DIR/BASE.QC.ambiguous

# Exclude ambiguous SNPs from BASE.QC

awk 'NR==1 || NR==FNR{a[$2];next} !($2 in a){print}' $BASE_DIR/BASE.QC.ambiguous $BASE_DIR/BASE.QC > $BASE_DIR/BASE.QC.new
mv $BASE_DIR/BASE.QC.new $BASE_DIR/BASE.QC

# Print the number of genetic variants excluded from the Base data after checking for ambiguity

awk 'END{print "Number of genetic variants, excluded based on ambiguity (Base data) : " NR }' $BASE_DIR/BASE.QC.ambiguous
awk 'END{print "Number of genetic variants, after excluding based on ambiguity (Base data) : " NR-1 }' $BASE_DIR/BASE.QC

## 5. Identify duplicate SNPs in Base dataset.

module load lang/r/3.6.1
Rscript --vanilla $SCRIPT_DIR/duplicated_SNPs.R

mv $BASE_DIR/BASE.QC.new $BASE_DIR/BASE.QC

# Print the number of genetic variants excluded from the Base data due to duplicated SNPs

awk 'END{print "Number of genetic variants, excluded based duplicates (Base data) : " NR }' $BASE_DIR/BASE.QC.duplicates
awk 'END{print "Number of genetic variants, after excluding based on duplicates (Base data) : " NR-1 }' $BASE_DIR/BASE.QC

## 6.Remove The Major Histocompatibility Complex (MHC) region on chromosome 6 (28,477,797 - 33,448,354) due to its complex linkage disequilibrium (LD) structure. 

awk '( ($1==6) && ($3>=28477797 && $3<=33448354) ) {print}' $BASE_DIR/BASE.QC > $BASE_DIR/BASE.QC.MHC_REGION

# Exclude MHC region from BASE.QC

awk 'NR==1 || NR==FNR{a[$2];next} !($2 in a){print}' $BASE_DIR/BASE.QC.MHC_REGION $BASE_DIR/BASE.QC > $BASE_DIR/BASE.QC.new
mv $BASE_DIR/BASE.QC.new $BASE_DIR/BASE.QC

# Print the number of genetic variants excluded from the Base data due to being in the MHC region

awk 'END{print "Number of genetic variants, excluded due to being in the MHC region (Base data) : " NR }' $BASE_DIR/BASE.QC.MHC_REGION
awk 'END{print "Number of genetic variants, after excluding due to being in the MHC region (Base data) : " NR-1 }' $BASE_DIR/BASE.QC

# 7. Remove multi-allelic genetic variants
# Find multi-allelic SNPs

awk 'NR==1 || (length($4) > 1 || length($5) > 1 ) {print}' $BASE_DIR/BASE.QC > $BASE_DIR/BASE.QC.multiallelic.headings
(tail -n+2 $BASE_DIR/BASE.QC.multiallelic.headings) > $BASE_DIR/BASE.QC.multiallelic
rm $BASE_DIR/BASE.QC.multiallelic.headings

# Exclude multi-allelic SNPs from BASE.QC

awk 'NR==1 || NR==FNR{a[$2];next} !($2 in a){print}' $BASE_DIR/BASE.QC.multiallelic $BASE_DIR/BASE.QC > $BASE_DIR/BASE.QC.new
mv $BASE_DIR/BASE.QC.new $BASE_DIR/BASE.QC

# Print the number of genetic variants excluded from the Base data due to being multi-allelic

awk 'END{print "Number of genetic variants, excluded due to being multi-allelic (Base data) : " NR }' $BASE_DIR/BASE.QC.multiallelic
awk 'END{print "Number of genetic variants, after excluding due to being multi-allelic (Base data) : " NR-1 }' $BASE_DIR/BASE.QC

echo End of Quality Control of Base data

#### END OF SCRIPT ####

