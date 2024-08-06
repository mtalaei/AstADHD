*===========================================================================
* Project: Asthma-ADHD
* Purpose: other supporting analysis
* By Dr Mohammad Talaei 
* Launch date: 07 Nov 2022
* Last update: 05 Jun 2024
*===========================================================================

*QMUL
cd "C:\Users\hmy431\OneDrive - Queen Mary, University of London\ALSPAC"

*Home
cd "C:\Users\mtala\OneDrive - Queen Mary, University of London\ALSPAC"

*Open
use "Data\ALSPAC_Ast&ADHD.dta", clear


*===Profile flow (Figure S3)
codebook cidB3569												/*13,770*/
dis 13782 - 13770=12											/*28 withdrawn -> 28+12=40*/
count if missing(ast8y)											/*5,745*/
count if !missing(ast8y)										/*8,025*/
count if missing(ADHD7y) & !missing(ast8y)						/*860*/
count if !missing(ast8y, ADHD7y)								/*7,165*/
count if !missing(ast8y,ADHD7y) & missing(atopy)				/*2,204 missing atopy*/
count if !missing(ast_at8y, ADHD7y)								/*4,961*/


count if missing(PCA1_children)									/*6,293*/
count if !missing(PCA1_children)								/*7,477*/

count if missing(ast8y) & !missing(PCA1_children)				/*2,052*/
count if !missing(ast8y, PCA1_children)							/*5,425*/

count if missing(ADHD7y) & !missing(PCA1_children)				/*1,974*/
count if !missing(ADHD7y, PCA1_children)						/*5,425*/

*Test final PRS sample sizes
count if !missing(Asthma_Z_SCORE_children_S1, ADHD7y)			/*5,503*/
count if !missing(ADHD_Z_SCORE_children_S1, ast8y)				/*5,425*/


*=========================================== Ast-ADHD models
*===Crude analyses (Text)
*ADHD @7
logistic ADHD7y i.ast8y, cformat(%9.2f) 		/*7,165 1.35*/ 
logistic ADHD7y i.ast_at8y, cformat(%9.2f) 		/*4,961 1.51*/ 

foreach ee in ast8y atopy i.ast_at8y ecz8y hay8y lIgE {
	logistic ADHD7y `ee', cformat(%9.2f) 
}

*ADHD @9
logistic ADHD9y i.ast8y, cformat(%9.2f)  		/*6,703 1.42*/
logistic ADHD9y i.ast_at8y, cformat(%9.2f)  	/*4,770 1.31*/

foreach ee in ast8y atopy i.ast_at8y ecz8y hay8y lIgE {
	logistic ADHD9y `ee', cformat(%9.2f) 
}
*

*===Adjusted models 1by1 (Table S4)
do AstADHD\codes\Models_Ast-ADHD_1by1.do

set more off
forvalues i = 1(1)17  {
display "*************************************************** " "model `i'"
local model: display "model_" `i'
logistic ADHD7y i.ast8y $`model' if !missing(bweight, m_energy, im_BMI), cformat(%9.2f)
display " "
}
*

*===Cumulitive adjustment ADHD@7 (Table S5, Fig 1) 
do AstADHD\codes\Models_Ast-ADHD.do

*Asthma
set more off
forvalues i = 1(1)12  {
display "*************************************************** " "model `i'"
local model: display "model_" `i'
logistic ADHD7y i.ast8y $`model' if !missing(bweight, m_energy, im_BMI), cformat(%9.2f)
display " "
}
*
*Asthma endotypes
set more off
forvalues i = 1(1)12  {
display "*************************************************** " "model `i'"
local model: display "model_" `i'
logistic ADHD7y i.ast_at8y $`model' if !missing(bweight, m_energy, im_BMI), cformat(%9.2f)
display " "
}
*

*===Sensitivity analysis for ADHD@9 (Table S6)
*Note:	In above section, ADHD7y --> ADHD9y



*=========================================== PRS analysis
*======================Correlation	
*Asthma PRS			from 0.91 to 0.14
pwcorr 	Asthma_Z_SCORE_children_S1 Asthma_Z_SCORE_children_S2 ///
		Asthma_Z_SCORE_children_S3 Asthma_Z_SCORE_children_S4 ///
		Asthma_Z_SCORE_children_S5 Asthma_Z_SCORE_children_S6 ///
		Asthma_Z_SCORE_children_S7		
* ADHD PRS			from 0.93 to 0.13
pwcorr	ADHD_Z_SCORE_children_S1 ADHD_Z_SCORE_children_S2 ///
		ADHD_Z_SCORE_children_S3 ADHD_Z_SCORE_children_S4 ///
		ADHD_Z_SCORE_children_S5 ADHD_Z_SCORE_children_S6 ///
		ADHD_Z_SCORE_children_S7		
*Cross-trait PRSs 	from  -0.015 to 0.046
forv i=1(1)7 {
	display " "
	display "*************************************************** " "Threshold `i'"
	pwcorr 	Asthma_Z_SCORE_children_S`i' ADHD_Z_SCORE_children_S`i'
}	


*======================Validation: PRS-same trait & GOF
*===Ast.PRS-Ast(bi) (Table S7)
global model "PCA1_children PCA2_children PCA3_children PCA4_children PCA5_children PCA6_children PCA7_children PCA8_children PCA9_children PCA10_children"
set more off
forv i=1(1)7 {
	logistic ast8y Asthma_Z_SCORE_children_S`i' $model, cformat(%9.2f) 
	estat ic
	matrix mtx_t = r(S)
	if `i'==1 matrix mtx = r(S)
	else matrix mtx = (mtx\mtx_t)
	fitstat
	matrix mtx_t=r(r2_cu)
	if `i'==1 matrix mtx2 = r(r2_cu)
	else matrix mtx2 = (mtx2\mtx_t)
	predict tt, p
	roctab ADHD7y tt, nograph
	matrix mtx_t=r(area)		
	if `i'==1 matrix mtx3 = r(area)
	else matrix mtx3 = (mtx3\mtx_t)		
	drop tt		
}
matlist mtx	
matlist mtx2 
matlist mtx3


*===Ast.PRS-Ast(cat) (Table S8)
global model "PCA1_children PCA2_children PCA3_children PCA4_children PCA5_children PCA6_children PCA7_children PCA8_children PCA9_children PCA10_children"
set more off
foreach i of num 1/7 {
	display "*************************************************** " "Asthma_Z_SCORE_children_S`i'"
	mlogit ast_at8y Asthma_Z_SCORE_children_S`i' $model, rrr cformat(%9.2f) 
}
*
set more off
forv i=1(1)7 {
	mlogit ast_at8y Asthma_Z_SCORE_children_S`i' $model, rrr cformat(%9.2f) 
	estat ic
	matrix mtx_t = r(S)
	if `i'==1 matrix mtx = r(S)
	else matrix mtx = (mtx\mtx_t)
	fitstat
	matrix mtx_t=r(r2_cu)
	if `i'==1 matrix mtx2 = r(r2_cu)
	else matrix mtx2 = (mtx2\mtx_t)
	predict tt, p
	roctab ADHD7y tt, nograph
	matrix mtx_t=r(area)		
	if `i'==1 matrix mtx3 = r(area)
	else matrix mtx3 = (mtx3\mtx_t)		
	drop tt		
}
matlist mtx	
matlist mtx2 
matlist mtx3


*===ADHD.PRS-ADHD (Table S9)
global model "PCA1_children PCA2_children PCA3_children PCA4_children PCA5_children PCA6_children PCA7_children PCA8_children PCA9_children PCA10_children"
set more off
forv i=1(1)7 {
	logistic ADHD7y ADHD_Z_SCORE_children_S`i' $model, cformat(%9.2f) 
	estat ic
	matrix mtx_t = r(S)
	if `i'==1 matrix mtx = r(S)
	else matrix mtx = (mtx\mtx_t)
	fitstat
	matrix mtx_t=r(r2_cu)
	if `i'==1 matrix mtx2 = r(r2_cu)
	else matrix mtx2 = (mtx2\mtx_t)
	predict tt, p
	roctab ADHD7y tt, nograph
	matrix mtx_t=r(area)		
	if `i'==1 matrix mtx3 = r(area)
	else matrix mtx3 = (mtx3\mtx_t)		
	drop tt		
}
matlist mtx	
matlist mtx2 
matlist mtx3


*===ADHD.PRS-ADHD@9 (Table S10)
global model "PCA1_children PCA2_children PCA3_children PCA4_children PCA5_children PCA6_children PCA7_children PCA8_children PCA9_children PCA10_children"
set more off
forv i=1(1)7 {
	logistic ADHD9y ADHD_Z_SCORE_children_S`i' $model, cformat(%9.2f) 
	estat ic
	matrix mtx_t = r(S)
	if `i'==1 matrix mtx = r(S)
	else matrix mtx = (mtx\mtx_t)
	fitstat
	matrix mtx_t=r(r2_cu)
	if `i'==1 matrix mtx2 = r(r2_cu)
	else matrix mtx2 = (mtx2\mtx_t)
	predict tt, p
	roctab ADHD7y tt, nograph
	matrix mtx_t=r(area)		
	if `i'==1 matrix mtx3 = r(area)
	else matrix mtx3 = (mtx3\mtx_t)		
	drop tt		
}
matlist mtx	
matlist mtx2 
matlist mtx3


*======================Shared genetics: PRS-other trait & GOF
*===Ast.PRS-ADHD (Table 2)
global model "PCA1_children PCA2_children PCA3_children PCA4_children PCA5_children PCA6_children PCA7_children PCA8_children PCA9_children PCA10_children"
foreach i of num 1/7 {
	logistic ADHD7y Asthma_Z_SCORE_children_S`i' $model, cformat(%9.2f) 
}

*Variance Explained & GOF
set more off
forv i=1(1)7 {
	logistic ADHD7y Asthma_Z_SCORE_children_S`i' $model, cformat(%9.2f) 
	estat ic
	matrix mtx_t = r(S)
	if `i'==1 matrix mtx = r(S)
	else matrix mtx = (mtx\mtx_t)
	fitstat
	matrix mtx_t=r(r2_cu)
	if `i'==1 matrix mtx2 = r(r2_cu)
	else matrix mtx2 = (mtx2\mtx_t)
	predict tt, p
	roctab ADHD7y tt, nograph
	matrix mtx_t=r(area)		
	if `i'==1 matrix mtx3 = r(area)
	else matrix mtx3 = (mtx3\mtx_t)		
	drop tt		
}
matlist mtx	
matlist mtx2 
matlist mtx3


*===ADHD.PRS-Ast(bi) (Table 2)
global model "PCA1_children PCA2_children PCA3_children PCA4_children PCA5_children PCA6_children PCA7_children PCA8_children PCA9_children PCA10_children"
foreach i of num 1/7 {
	logistic ast8y ADHD_Z_SCORE_children_S`i' $model, cformat(%9.2f) 
}
*Variance Explained & GOF
set more off
forv i=1(1)7 {
	logistic ast8y ADHD_Z_SCORE_children_S`i' $model, cformat(%9.2f) 
	estat ic
	matrix mtx_t = r(S)
	if `i'==1 matrix mtx = r(S)
	else matrix mtx = (mtx\mtx_t)
	fitstat
	matrix mtx_t=r(r2_cu)
	if `i'==1 matrix mtx2 = r(r2_cu)
	else matrix mtx2 = (mtx2\mtx_t)
	predict tt, p
	roctab ADHD7y tt, nograph
	matrix mtx_t=r(area)		
	if `i'==1 matrix mtx3 = r(area)
	else matrix mtx3 = (mtx3\mtx_t)		
	drop tt		
}
matlist mtx	
matlist mtx2 
matlist mtx3


*===ADHD.PRS-Ast(cat) (Table 3)
global model "PCA1_children PCA2_children PCA3_children PCA4_children PCA5_children PCA6_children PCA7_children PCA8_children PCA9_children PCA10_children"
foreach i of num 1/7 {
	mlogit ast_at8y ADHD_Z_SCORE_children_S`i' $model, rrr cformat(%9.2f) 
}
*Variance Explained & GOF
set more off
foreach i of num 1/7 {
	display "*************************************************** " "Asthma_Z_SCORE_children_S`i'"
	mlogit ast_at8y ADHD_Z_SCORE_children_S`i' $model, rrr cformat(%9.2f) 
}
*
set more off
forv i=1(1)7 {
	mlogit ast_at8y ADHD_Z_SCORE_children_S`i' $model, rrr cformat(%9.2f) 
	estat ic
	matrix mtx_t = r(S)
	if `i'==1 matrix mtx = r(S)
	else matrix mtx = (mtx\mtx_t)
	fitstat
	matrix mtx_t=r(r2_cu)
	if `i'==1 matrix mtx2 = r(r2_cu)
	else matrix mtx2 = (mtx2\mtx_t)
	predict tt, p
	roctab ADHD7y tt, nograph
	matrix mtx_t=r(area)		
	if `i'==1 matrix mtx3 = r(area)
	else matrix mtx3 = (mtx3\mtx_t)		
	drop tt		
}
matlist mtx	
matlist mtx2 
matlist mtx3


*===Ast.PRS-ADHD@9 (Table S11)
global model "PCA1_children PCA2_children PCA3_children PCA4_children PCA5_children PCA6_children PCA7_children PCA8_children PCA9_children PCA10_children"
foreach i of num 1/7 {
	logistic ADHD9y Asthma_Z_SCORE_children_S`i' $model, cformat(%9.2f) 
}
*



*=========================================== Atopic phenotypes
*AP-ADHD (Text)
do AstADHD\codes\Models_Ast-ADHD.do
foreach ee in atopy ecz8y hay8y lIgE {
	logistic ADHD7y `ee' $model_3, cformat(%9.2f) 
}


*===========PRS analysis
global model "PCA1_children PCA2_children PCA3_children PCA4_children PCA5_children PCA6_children PCA7_children PCA8_children PCA9_children PCA10_children"

*===Ecz.PRS-Ecz (Table S13)
*validation
foreach i of num 1/7 {
	logistic ecz8y Eczema_Z_SCORE_children_S`i' $model, cformat(%9.2f) 
}
*Main
foreach i of num 1/7 {
	logistic ADHD7y Eczema_Z_SCORE_children_S`i' $model, cformat(%9.2f) 
}


*===Hay.PRS-Hay (Table S13)
*validation
foreach i of num 1/7 {
	logistic hay8y Hay_fever_Z_SCORE_children_S`i' $model, cformat(%9.2f) 
}
*Main
foreach i of num 1/7 {
	logistic ADHD7y Hay_fever_Z_SCORE_children_S`i' $model, cformat(%9.2f) 
}


*===Atopy.PRS-ADHD (Table S13)
*validation
foreach i of num 1/7 {
	logistic atopy AS_Z_SCORE_children_S`i' $model, cformat(%9.2f) 
}
*Main
foreach i of num 1/7 {
	logistic ADHD7y AS_Z_SCORE_children_S`i' $model, cformat(%9.2f) 
}



