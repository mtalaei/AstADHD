
#################### 3rd Script: CALCULATION OF POLYGENIC RISK SCORES ####################
#####  Creator: Panagiota Pagoni
#####  Last update:14-11-2022


### Set directories

# Directory of analysis scripts

SCRIPT_DIR=/your/directory/script

# Directory of target data. Target data for mothers and children after excluding based on relatedness and withdrawal of consents,

TARGET_DIR=/your/directory/target_data

# Directory of base data 

BASE_DIR=/your/directory/base_data

# Directory of calculated PRS for the phenotype of interest

PRS_DIR=/your/directory/prs


####### CALCULATION OF POLYGENIC RISK SCORES ######### 

## MOTHERS ##

echo Calculate polygenic risk scores for mothers in ALSPAC

module load apps/plink/1.90

plink \
--bfile $TARGET_DIR/mothers_BASE_ALSPAC.QC \
--score $BASE_DIR/BASE.QC.mothers.weights \
--q-score-range $SCRIPT_DIR/prs_thresholds.txt $BASE_DIR/BASE.QC.mothers.pval \
--out $PRS_DIR/PRS_BASE_mothers

echo Calculation of PRS for mothers in ALSPAC completed

## CHILDREN ##

echo Calculate polygenic risk scores for children in ALSPAC

module load apps/plink/1.90

plink \
--bfile $TARGET_DIR/children_BASE_ALSPAC.QC \
--score $BASE_DIR/BASE.QC.children.weights \
--q-score-range $SCRIPT_DIR/prs_thresholds.txt $BASE_DIR/BASE.QC.children.pval \
--out $PRS_DIR/PRS_BASE_children

echo Calculation of PRS for children in ALSPAC completed

# Check how many genetic variants are included in each PRS threshold

# MOTHERS #

awk '( $2 <= 0.5 ) { count++ } END { print "Number of genetic variants included in PRS for threshold S1 (mothers):" count }'  $BASE_DIR/BASE.QC.mothers.pval
awk '( $2 <= 0.1 ) { count++ } END { print "Number of genetic variants included in PRS for threshold S2 (mothers):" count }'  $BASE_DIR/BASE.QC.mothers.pval
awk '( $2 <= 0.05 ) { count++ } END { print "Number of genetic variants included in PRS for threshold S3 (mothers):" count }'  $BASE_DIR/BASE.QC.mothers.pval
awk '( $2 <= 0.01 ) { count++ } END { print "Number of genetic variants included in PRS for threshold S4 (mothers):" count }'  $BASE_DIR/BASE.QC.mothers.pval
awk '( $2 <= 0.005 ) { count++ } END { print "Number of genetic variants included in PRS for threshold S5 (mothers):" count }'  $BASE_DIR/BASE.QC.mothers.pval
awk '( $2 <= 0.001 ) { count++ } END { print "Number of genetic variants included in PRS for threshold S6 (mothers):" count }'  $BASE_DIR/BASE.QC.mothers.pval
awk '( $2 <= 0.00000005 ) { count++ } END { print "Number of genetic variants included in PRS for threshold S7 (mothers):" count }'  $BASE_DIR/BASE.QC.mothers.pval

# CHILDREN #

awk '( $2 <= 0.5 ) { count++ } END { print "Number of genetic variants included in PRS for threshold S1 (children):" count }'  $BASE_DIR/BASE.QC.children.pval
awk '( $2 <= 0.1 ) { count++ } END { print "Number of genetic variants included in PRS for threshold S2 (children):" count }'  $BASE_DIR/BASE.QC.children.pval
awk '( $2 <= 0.05 ) { count++ } END { print "Number of genetic variants included in PRS for threshold S3 (children):" count }'  $BASE_DIR/BASE.QC.children.pval
awk '( $2 <= 0.01 ) { count++ } END { print "Number of genetic variants included in PRS for threshold S4 (children):" count }'  $BASE_DIR/BASE.QC.children.pval
awk '( $2 <= 0.005 ) { count++ } END { print "Number of genetic variants included in PRS for threshold S5 (children):" count }'  $BASE_DIR/BASE.QC.children.pval
awk '( $2 <= 0.001 ) { count++ } END { print "Number of genetic variants included in PRS for threshold S6 (children):" count }'  $BASE_DIR/BASE.QC.children.pval
awk '( $2 <= 0.00000005 ) { count++ } END { print "Number of genetic variants included in PRS for threshold S7 (children):" count }'  $BASE_DIR/BASE.QC.children.pval

