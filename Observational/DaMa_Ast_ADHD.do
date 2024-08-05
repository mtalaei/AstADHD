*===========================================================================
* Project: Asthma-ADHD
* Purpose: Data management
* By Dr Mohammad Talaei 
* Launch date: 07 Nov 2022
* Last update: 18 Oct 2023
*===========================================================================

*QMUL
cd "C:\Users\hmy431\OneDrive - Queen Mary, University of London\ALSPAC"
*Home
cd "C:\Users\mtala\OneDrive - Queen Mary, University of London\ALSPAC"

*Open
use "Data\ALSPAC_Ast&ADHD.dta", clear


*======Exclusions
use "C:\Users\hmy431\OneDrive - Queen Mary, University of London\ALSPAC\Data\Originals\B3569\B3569_Shaheen_24Jan2023.dta"


*==In core
codebook in_core
keep if in_core==1
count if cidB3569<. 	/*n=14,633*/
*==Alive @1
codebook kz011b
keep if kz011b==1
count if cidB3569<. 	/*n=13,948*/
*==Twins
tab qlet
keep if qlet=="A"
tab qlet 				/*n=13,770*/

save "Data\ALSPAC_Ast&ADHD.dta"


*||||||||||||||||||||||||||||||||||||||||||||||
*=============================================>Outcomes
*===========ADHD
*@81m (6.75y) 				kq346b
codebook kq346b
hist kq346b
gen ADHD7y=1 if kq346b>=7 & !missing(kq346b)
recode ADHD7y .=0 if kq346b<7 & kq346b!=-2 & !missing(kq346b) 
la var ADHD7y "Hyperactivity score≥7 @7y"
tab kq346b ADHD7y, missing
tab ADHD7y, missing


*@9y 						ku706b
codebook ku706b
hist ku706b
gen ADHD9y=1 if ku706b>=7 & !missing(ku706b)
recode ADHD9y .=0 if ku706b<7 & ku706b>=0 & !missing(ku706b) 
la var ADHD9y "Hyperactivity score≥7 @9y"
tab ku706b ADHD9y, missing
tab ADHD9y, missing


*@7y | 9y
*gen ADHD7_9y=max(ADHD7y, ADHD9y) if !missing(ADHD7y, ADHD9y)
gen ADHD7_9y=1 if ADHD7y==1 | ADHD9y==1
recode ADHD7_9y .=0 if !missing(ADHD7y, ADHD9y)
la var ADHD7_9y "Hyperactivity score≥7 @7y or @9y"
tab ADHD7_9y ADHD7y, missing
tab ADHD7_9y ADHD9y, missing
tab ADHD7_9y, missing

*@7y & 9y 					Avoiding misclassification in reference group
tab ADHD7y ADHD9y
gen ADHD7a9y_c=1 if ADHD7y==1 & ADHD9y==1
recode ADHD7a9y_c .=0 if ADHD7y==0 & ADHD9y==0
la var ADHD7a9y_c "Hyperactivity score≥7 @7y & @9y (clean Ref)"
tab ADHD7a9y_c ADHD7y, missing
tab ADHD7a9y_c ADHD9y, missing
tab ADHD7a9y_c

*@7y & 9y
tab ADHD7y ADHD9y, missing
gen ADHD7a9y=1 if ADHD7y==1 & ADHD9y==1
recode ADHD7a9y .=0 if !missing(ADHD7y, ADHD9y)
la var ADHD7a9y "Hyperactivity score≥7 @7y & @9y"
tab ADHD7a9y ADHD7y, missing
tab ADHD7a9y ADHD9y, missing
tab ADHD7a9y

*Incident @9y
tab ADHD7y ADHD9y
gen iADHD9y=1 if ADHD7y==0 & ADHD9y==1
recode iADHD9y .=0 if ADHD7y==0 & ADHD9y==0
la var iADHD9y "Incident hyperactivity score≥7 @9y"
tab ADHD7y iADHD9y, missing
tab ADHD9y iADHD9y, missing
tab iADHD9y


*===========Asthma 
*==@91m (7.6y)				kr050 kr031a kr041a kr105a
tab kr050, nolabel
tab kr031a, nolabel
tab kr041a, nolabel
tab kr105a, nolabel
tab kr050 kr105a

*DD Asthma with 12m Hx and Rx (asthcddrx91)
gen ast8y=1 if kr050==1 & (kr031a==1 | kr041a==1 | kr105a==1)
recode ast8y .=0 if kr050>0 & !missing(kr050) /*if simply kr050==2: clean control*/
label var ast8y "Current doctor-diagnosed asthma in past 12 months @91m"
tab kr050 ast8y, missing
tab ast8y 				/*n=1,089 /8,025*/

*==@128m (10y8m)			kv1070 kv1059 kv1050 kv1080 kv2220
codebook kv1070 /*DD asthma & eczema*/
codebook kv1059 /*Asthma*/
codebook kv1050 /*Wheezing*/
codebook kv1080 /*Wheezing*/
codebook kv2220 /*Asthma medicine*/
tab kv1050 kv1080, missing

*DD Asthma with 12m Hx and Rx (asthcddrx166) ever
gen ast11y=1 if (inlist(kv1070,1,3) | kr050==1) & ///
				(inlist(kv1059,1,2)|inlist(kv1050,1,2)|kv1080==1|kv2220==1)
recode ast11y .=0 if kv1070>=-1 & !missing(kv1070)
label var ast11y "Current doctor-diagnosed asthma in past 12 months @128m"
tab ast11y, missing
tab kv1070 ast11y, missing
tab kv1050 ast11y, missing

*==8-11y
tab ast8y ast11y, missing
 

*===========Atopy 
*							atopy2g
tab atopy2g, nolabel missing
recode atopy2g min/-1=., gen(atopy)
la var atopy "Atopy: positive reaction to DP, cat, or grass @91m"
tab atopy2g atopy, missing
tab atopy 				/*n=1,379 /6,421*/

*===========Atopic non-atopic Asthma @91m
tab ast8y atopy, missing
gen ast_at8y=ast8y if !missing(atopy)
recode ast_at8y 1=3 if atopy==1
recode ast_at8y 1=2 if atopy==0
recode ast_at8y 0=1 if atopy==1
la var ast_at8y "Asthma-Atopy phenotypes @91m"
la def astat4 0"None" 1"Atopy without asthma" 2"Nonatopic asthma" 3"Atopic asthma"
la val ast_at8y astat4
tab ast_at8y 			/*n=3,902/805/362/366*/
tab ast_at8y ast8y
tab ast_at8y atopy


*===========Eczema 
*@91m						kr042
codebook kr042
recode kr042 (min/0=.) (1/2=1) (3=0), gen(ecz8y)
la var ecz8y "Eczema in past 12 months @91m"
tab ecz8y, missing
tab ecz8y			/*n=1,322 /8,079*/


*===========Hay fever 
*@91m						kr043
codebook kr043
recode kr043 (min/0=.) (1/2=1) (3=0), gen(hay8y)
la var hay8y "Hay fever in past 12 months @91m"
tab hay8y, missing
tab hay8y			/*n=703 /8,059*/


*===========IgE
* 							IGE_F7
codebook IGE_F7
recode IGE_F7 min/-1=., gen(IgE)
la var IgE "IgE ku/l, Focus@7"
sum IgE
hist IgE 
gen lIgE=log(IgE)
la var lIgE "Log IgE, Focus@7"
hist lIgE



*||||||||||||||||||||||||||||||||||||||||||||||
*=============================================>Exposures
*==label 
la def ny 0"No" 1"Yes" 2 "missing"
la def yn 0"Yes" 1"No" 2 "missing"

*=====Maternal age
codebook mz028b 
recode mz028b (min/0=.), gen(m_age)
label variable m_age "Maternal age at delivery"
summ m_age mz028b
hist m_age

*=====Maternal education
codebook c645a
recode c645a min/0=6 .=6, gen(m_edu)
label variable m_edu "Maternal education"
la def edu 1"Certificate of Secondary Education" 2"Vocational" 3"O level" 4"A level" 5"Degree" 6"missing"
la val m_ed edu
tab m_edu c645a, missing
tab m_edu, missing

*=====IMD
codebook kqimd2000q5
tablab kqimd2000q5
recode kqimd2000q5 1=0 2=1 3=2 4=3 5=4 min/-1=5, gen(kqimdq5)
la var kqimdq5 "Quintiles of IMD score 2000"
la def kqimdq5 0"Q1: Least deprived" 1"Q2" 2"Q3" 3"Q4" 4"Q5: Most deprived" 5"Missing"  
la val kqimdq5 kqimdq5
tab kqimdq5 kqimd2000q5, missing
tab kqimdq5

*=====Maternal housing tenure at birth
codebook a006
tab a006, nolabel missing
recode a006 (0/1=1)(3/5=3)(6/.=4) (min/-1=4), gen(m_housing)
la var m_housing "Housing tenure at birth"
la def housing 1 "Mortgaged/owned" 2 "Council rented" 3 "Non-council rented" 4 "Unknown/missing" 
la val m_housing housing
tab m_housing, missing
tab a006 m_housing, missing

*=====Financial difficulty
codebook b594
gen m_findif=0 if b594==5 | e424==5
replace m_findif=1 if inrange(b594,1,4) | inrange(e424,1,4) 
recode m_findif .=2 
la var m_findif "Financial difficulty during pregnancy"
la val m_findif ny
tab m_findif, missing
table m_findif b594 e424, missing
tab e424 m_findif, missing
tab b594 m_findif, missing

*=====Smoking during pregnancy 
*a200(8wg) b670(1st Trim) b671(18wg) c483(38wg) e178(last2m)
*8wg
tab a200, nolabel
recode a200 (1/9=1) (10/19=2) (20/max=3) (min/-1=.), gen(m_smk8wg)
tab a200 m_smk8wg, missing
la var m_smk8wg "Maternal smoking at 8 weeks gestation" 
la def smk 0 "None" 1 "1-9/day" 2 "10-19/day" 3 "20+/day" 4 "missing", replace
la val m_smk8wg smk
tabstat a200, statistic(n min max) by(m_smk8wg)

*1st Trim
tab b670, nolabel
recode b670 (1/9=1) (10/19=2) (20/max=3) (min/-1=.), gen(m_smk1stT)
tab b670 m_smk1stT, missing
la var m_smk1stT "Maternal smoking in 1st trimester" 
la val m_smk1stT smk
tabstat b670, statistic(n min max) by(m_smk1stT)

*18wg
tab b671, nolabel
recode b671 (1/9=1) (10/19=2) (20/max=3) (min/-1=.), gen(m_smk18wg)
tab b671 m_smk18wg, missing
la var m_smk18wg "Maternal smoking at 18 weeks gestation" 
la val m_smk18wg smk
tabstat b671, statistic(n min max) by(m_smk18wg)

*38wg
tab c483, nolabel missing
recode c483 (min/-1=.), gen(m_smk38wg)
la var m_smk38wg "Maternal smoking at 38 weeks gestation" 
tab c483 m_smk38wg, missing
la val m_smk38wg smk
tab m_smk38wg

*last2m
tab e178, nolabel
recode e178 (1/9=1) (10/19=2) (20/max=3) (min/-1=.), gen(m_smklast2mg)
la var m_smklast2mg "Maternal smoking in the last 2 months gestation" 
tab e178 m_smklast2mg, missing
la val m_smklast2mg smk
tab m_smklast2mg

*The whole Pregnancy
gen m_smkpreg=max(m_smk8wg, m_smk1stT, m_smk18wg, m_smk38wg, m_smklast2mg)
recode m_smkpreg .=4
la var m_smkpreg "Maternal smoking during pregnancy"
la val m_smkpreg smk
tab m_smkpreg, missing

*Binary
recode m_smkpreg 2/4=1, gen(m_smkpregB)
la var m_smkpregB "Maternal smoking during pregnancy"
tab m_smkpreg m_smkpregB


*=====Gestation at completion			bestgest
codebook bestgest
gen gestage = bestgest
la var gestage "Gestational age"
sum gestage
hist gestage
*Categories
recode gestage (min/36=0)(37/40=1)(41/max=2), gen(gestage_g3)
label variable gestage_g3 "Gestational age categories"
label define gestageg 0 "<37 weeks" 1 "37-40 weeks" 2 ">40 weeks"
label values gestage_g3 gestageg 
tab gestage_g3
tabstat gestage, statistic(n min max) by(gestage_g3)


*=====Birth weight
codebook kz030
gen bweight=kz030 if kz030>0
la var bweight "Birth weight"
hist bweight


*=====Neurotic pathology (Crown-Crisp; PMID: 3179248)
*Note: Annabelle called it ANXIETY SCORE
codebook b358 c583 						/*Why not b352a & c574 ?*/
gen neurosis=max(b358,c583) 				/*? or average*/
recode neurosis (0/9=0)(10/14=1)(15/20=2)(21/max=3)(.=4)(min/-1=4), gen(neur_g4)
label variable neur_g4 "Overall score of neurotic pathology"
label define neurosis 0 "0-9" 1 "10-14" 2 "15-20" 3 "21+" 4 "missing" 
label values neur_g4 neurosis
tab neur_g4
tabstat b358, statistic(n  min  max) by(neur_g4)
tabstat c583, statistic(n  min  max) by(neur_g4)

*anxiety subscale
codebook b352a c574
gen anxiety=max(b352a,c574)
label variable anxiety "Anxiety score"
recode anxiety (0/3=0)(4/6=1)(7/9=2)(10/max=3)(.=4)(min/-1=4), gen(anx_g4)
label variable anx_g4 "Anxiety score categories"
label define anxiety 0 "0-3" 1 "4-6" 2 "7-9" 3 "10+" 4 "missing" 
label values anx_g4 anxiety
tab anx_g4

*depression subscale of CCEI in HAB
codebook b354a c580
gen depression=max(b354a,c580) 	
label variable depression "Depression score"		
recode depression (0/3=0)(4/6=1)(7/9=2)(10/max=3)(.=4)(min/-1=4), gen(dep_g4)
label variable dep_g4 "Depression score categories"
label define depression 0 "0-3" 1 "4-6" 2 "7-9" 3 "10+" 4 "missing" 
label values dep_g4 depression
tab dep_g4


*=====PARACETAMOL
*Note: Unknown Paracetamol_a & Paracetamol_b & Paracetamol_c in Annabel codes were discarded 
*Early
codebook b171  
gen paracearly=.
replace paracearly=1 if inlist(b171,1,2,3) 
replace paracearly=0 if b171==4 
label variable  paracearly "Any use of paracetamol in early pregnancy"
label values paracearly ny
table b171 paracearly, missing
tab Paracetamol_ab paracearly, missing
*missing category
replace paracearly=2 if paracearly==.
tab paracearly, missing

*Late
codebook c131  
gen paraclate=.
replace paraclate=1 if inlist(c131,1,2,3) 
replace paraclate=0 if c131==4 
label variable  paraclate "Any use of paracetamol in late pregnancy"
label values paraclate ny
table c131 paraclate, missing
*missing category
replace paraclate=2 if paraclate==.
tab paraclate, missing

tab paracearly paraclate, missing

*Whole
gen paracetamol= max(paracearly, paraclate)
label variable  paracetamol "Any use of paracetamol during pregnancy"
label values paracetamol ny
table paracetamol paracearly paraclate, missing
tab paracetamol


*=====Total energy intake
codebook c3804
gen m_energy=c3804 if c3804>0
la var m_energy "Maternal energy intake (kJ/d) @32w"
hist m_energy


*=====Sugar
*Note: free sugar does not include lactose
codebook c3816 c3828
sum c3816 c3828 if c3816>0 & c3828>0
gen m_sugar=c3816 if c3816>=0
la var m_sugar "Sugar intake (g/d), non-milk extrinsic, @32w"
sum c3816 m_sugar 
egen m_sugarq5=cut(m_sugar), g(5) icode
la var m_sugarq5 "Quintiles of free sugar intake (g/d) @32w"
tabstat m_sugar, st(median) by(m_sugarq5) format(%9.1f)
recode m_sugarq5 0=25.5 1=40.5 2=53.2 3=69.8 4=104, gen(m_sugarq5m)
tab m_sugarq5 m_sugarq5m

*==Residual (Energy adjusted sugar intake)
*==>define
gen tavar=m_sugar
gen energy=m_energy
*==run
pwcorr tavar energy, obs
regress tavar energy
matrix matt = r(table)
scalar coef=matt[1,1]
scalar cons=matt[1,2]
predict tavar_resid, residuals
hist tavar_resid, normal
sum energy
scalar mean_en=cons + coef*r(mean)
gen r_tavar=tavar_resid+mean_en
pwcorr r_tavar tavar energy, sig
drop tavar energy tavar_resid
*==>rename
rename r_tavar r_m_sugar
la var r_m_sugar "Energy adjusted free sugar intake (g/d) @32w"
sum m_sugar r_m_sugar

egen r_m_sugarq5=cut(r_m_sugar), g(5) icode
la var r_m_sugarq5 "Quintiles of energy adjusted free sugar intake (g/d) @32w"
tab r_m_sugarq5
tab m_sugarq5 r_m_sugarq5 
tabstat r_m_sugar, st(median) by(r_m_sugarq5) format(%9.1f)
recode r_m_sugarq5 0=33.0 1=46.8 2=56.9 3=69.0 4=91.1, gen(r_m_sugarq5m)
tab r_m_sugarq5 r_m_sugarq5m


*=====BMI
codebook dw042 
gen m_BMI=dw042 if dw042>0
la var m_BMI "BMI (kg/m2)"
sum m_BMI, d
replace m_BMI=. if m_BMI>60 | m_BMI<15			/*7 to missing*/
hist m_BMI
*BMI 3-cat
egen m_BMI_g3=cut(m_BMI), at(15, 25, 30, 60) icode
tabstat m_BMI, st(n min max) by(m_BMI_g3)
la var m_BMI_g3 "BMI, kg/m2"
la def bmi 0"<25" 1"25-30" 2">30"
la val m_BMI_g3 bmi 
tab m_BMI_g3
*BMI binary
recode m_BMI_g 2=1, gen(m_BMI_b)
la var m_BMI_b "BMI, kg/m2"
la def bmi2 0"<25" 1">=25" 
la val m_BMI_b bmi2 
tab m_BMI_b
*BMI 4-cat
egen m_BMI_g4=cut(m_BMI), at(15, 18.5, 25, 30, 60) icode
tabstat m_BMI, st(n min max) by(m_BMI_g4)
la var m_BMI_g4 "BMI, kg/m2"
la def bmi4 0"<18.5" 1"18.5-24.9" 2"25-29.9" 3">30"
la val m_BMI_g4 bmi4 
tab m_BMI_g4
*BMI 5-cat
egen m_BMI_g5=cut(m_BMI), at(15, 18.5, 22, 25, 30, 60) icode
tabstat m_BMI, st(n min max) by(m_BMI_g5)
la var m_BMI_g5 "BMI, kg/m2"
la def bmi5 0"<18.5" 1"18.5-21.9" 2"22-24.9" 3"25-29.9" 4">30"
la val m_BMI_g5 bmi5 
tab m_BMI_g5


*=====Preeclampsia
codebook preeclampsia sup_preeclampsia
tab preeclampsia sup_preeclampsia, missing
gen preecl=max(preeclampsia, sup_preeclampsia)
recode preecl .=2
la var preecl "Preeclampsia"
la val preecl ny
tab preecl, missing


*=====Maternal ethnicity
tab c800
tab c800, nolabel missing
recode c800 (2/max=2)(.=3) (min/0=3), gen(m_ethn)
la var m_ethn "Maternal ethnicity"
la def ethnicity 1 "White" 2 "Non-white" 3 "missing"
la val m_ethn ethnicity 
tab m_ethn
tab c800 m_ethn, missing


*=====sex
codebook kz021
recode kz021 2=0 1=1 min/0=., gen(sex)
la var sex "Sex"
la def sex 0"Female" 1"Male"
la val sex sex
tab sex kz021, missing


*=====Additional data (new ADHD PRS, BMI PRS, PhA)
use "Data\ALSPAC_Ast&ADHD.dta", clear
drop ADHD_SCORE_mothers_*
drop ADHD_Z_SCORE_mothers_*
drop ADHD_SCORE_children_*
drop ADHD_Z_SCORE_children_*

merge 1:1 cidB3569 qlet using "Data\Originals\B3569\B3569_Shaheen_04Aug2023\B3569_Shaheen_04Aug2023.dta", ///
keepusing(ADHD_SCORE_mothers_* ADHD_Z_SCORE_mothers_* ADHD_SCORE_children_* ADHD_Z_SCORE_children_* ///
prs_o_fto b840 b850 b851 b852 b853 b854 b855 b856 b857 b858 b859 b860 b861 b862)  

keep if _merge==3			/*1,875 observations deleted*/
drop _merge

use "Data\ALSPAC_Ast&ADHD.dta", clear
merge 1:1 cidB3569 qlet using "Data\Originals\B3569\B3569_Shaheen_04Aug2023\B3569_Shaheen_04Aug2023.dta", ///
keepusing(prs_o_lassosum prs_f_lassosum prs_m_lassosum)
keep if _merge==3			/*1,875 observations deleted*/
drop _merge


*=====Maternal BMI imputation
*==variables for imputation model
*Parity
codebook b032
recode b032 min/-1=., gen(Parity)
la var Parity "Parity"
tab Parity

*Leisure-time physical activity
codebook b862
recode b862 -9999=. -1=., gen(m_LPhA)
la var m_LPhA "Leisure-time physical activity"
sum m_LPhA

*Current travel mode
codebook b840
recode b840 -9999=. -7=. -1=., gen(m_travel)
la var m_travel "Travel mode"
tab m_travel 
tablab b840 if b840>=0
recode m_travel 0=11 3=0 11=0 12/max=11

*BMI PRS
codebook prs_m_lassosum
recode prs_m_lassosum -9999=., gen(m_BMI_PRS)
la var m_BMI_PRS "Maternal BMI PRS (lassosum)"
hist m_BMI_PRS
sum m_BMI_PRS
gen m_BMI_PRS_sd=m_BMI_PRS/r(sd)
la var m_BMI_PRS_sd "Maternal BMI PRS (lassosum) per SD"

*==stochastic regression imputation
*if !missing(ast8y, ADHD9y) & missing(m_BMI)
gen im_BMI=m_BMI
*declare the mi style
mi set wide
*register im_BMI as an imputation variable
mi register imputed im_BMI
*use the new method (naivereg) within mi impute
misstable sum m_age m_energy Parity kqimdq5 m_LPhA m_BMI_PRS_sd if missing(m_BMI)
misstable patterns m_age m_energy Parity kqimdq5 m_LPhA m_BMI_PRS_sd if missing(m_BMI)
sum im_BMI if !missing(ast8y, ADHD7y)			   /*n=6,583*/
sum im_BMI if !missing(ast8y, ADHD9y)			   /*n=6,158*/
*1st round
mi impute naivereg im_BMI m_age m_energy Parity i.kqimdq5 m_LPhA m_BMI_PRS_sd, add(2) force 	  /*n=645*/
list im_BMI _1_im_BMI _2_im_BMI if missing(m_BMI)
gen av_im_BMI=(_1_im_BMI+_2_im_BMI)/2
sum _1_im_BMI _2_im_BMI av_im_BMI
replace im_BMI=av_im_BMI if missing(im_BMI)
sum m_BMI im_BMI 								/*n=11,357-> 11,806*/
*2nd round
mi impute naivereg im_BMI m_energy Parity i.kqimdq5 m_LPhA, add(2) force 	  /*n=500*/
gen av2_im_BMI=(_3_im_BMI+_4_im_BMI)/2
sum _3_im_BMI _4_im_BMI av2_im_BMI
replace im_BMI=av2_im_BMI if missing(im_BMI)
sum m_BMI im_BMI 							   /*n=11,806 -> 12,451*/
*3rd round
misstable sum m_age kqimdq5 m_LPhA if missing(im_BMI)
mi impute naivereg im_BMI m_age i.kqimdq5 m_LPhA, add(2) force
gen av3_im_BMI=(_5_im_BMI+_6_im_BMI)/2
sum _5_im_BMI _6_im_BMI av3_im_BMI
replace im_BMI=av3_im_BMI if missing(im_BMI)
sum m_BMI im_BMI 								/*n=11,806-> 12,951*/
*4th round
misstable sum m_age kqimdq5 if missing(im_BMI)
mi impute naivereg im_BMI m_age i.kqimdq5, add(2) force	  /*n=819*/
gen av4_im_BMI=(_7_im_BMI+_8_im_BMI)/2
sum _7_im_BMI _8_im_BMI av4_im_BMI
replace im_BMI=av4_im_BMI if missing(im_BMI)
sum m_BMI im_BMI 								/*n=11,806-> 13,770*/
la var im_BMI "Maternal BMI (kg/m2), imputed"

drop _1_im_BMI _2_im_BMI av_im_BMI _3_im_BMI _4_im_BMI av2_im_BMI _5_im_BMI _6_im_BMI av3_im_BMI _7_im_BMI _8_im_BMI av4_im_BMI
*Note: _mi_miss matters

*Imputation numbers for Ast-ADHD association
sum m_BMI im_BMI if !missing(ast8y, ADHD7y)			/*n=6,583 -> 7,165*/

mi unregister im_BMI


*=====Birth weight imputation
misstable pattern bweight m_energy gesthyp
tab gesthyp, missing		
recode gesthyp .=2
la val gesthyp ny
tab gesthyp, missing		

misstable sum bweight m_age gestage gesthyp preecl m_smkpreg kqimdq5
misstable pattern bweight m_age gestage gesthyp preecl m_smkpreg kqimdq5
regress bweight sex m_age gestage i.gesthyp i.preecl i.m_smkpreg i.kqimdq5, cformat(%9.2f)
regress bweight sex m_age gestage i.m_smkpreg, cformat(%9.2f)
		
*==stochastic regression imputation
*if !missing(ast8y, ADHD9y) & missing(m_BMI)
gen ibweight=bweight
*declare the mi style
mi set wide
*register im_BMI as an imputation variable
mi register imputed ibweight
*use the new method (naivereg) within mi impute
misstable sum m_age gestage gesthyp preecl m_smkpreg kqimdq5 if missing(ibweight)
misstable patterns m_age gestage gesthyp preecl m_smkpreg kqimdq5 if missing(ibweight)
sum ibweight if !missing(ast8y, ADHD7y)			   /*n=7,081*/
sum ibweight if !missing(ast8y, ADHD9y)			   /*n=6,621*/
*1st round
mi impute naivereg ibweight sex m_age gestage i.gesthyp i.preecl i.m_smkpreg i.kqimdq5, add(2) force 	  /*n Imputed=174*/
sum _1_ibweight _2_ibweight _3_ibweight _4_ibweight _5_ibweight _6_ibweight _7_ibweight _8_ibweight _9_ibweight _10_ibweight
drop _1_ibweight _2_ibweight _3_ibweight _4_ibweight _5_ibweight _6_ibweight _7_ibweight _8_ibweight
list ibweight _9_ibweight _10_ibweight if missing(ibweight)
gen av_ibweight=(_9_ibweight+_10_ibweight)/2
sum _9_ibweight _10_ibweight av_ibweight
replace ibweight=av_ibweight if missing(ibweight)
sum bweight ibweight 								/*n=11,357-> 11,806*/
la var ibweight "Birth weight (g), imputed"
drop _9_ibweight _10_ibweight av_ibweight

*Imputation numbers for Ast-ADHD association
sum bweight ibweight if !missing(ast8y, ADHD7y)			/*n=7,081 -> 7,165*/
		
mi unregister ibweight


*=====m_energy imputation
misstable sum m_energy m_age gestage gesthyp preecl m_smkpreg Parity m_edu kqimdq5
recode Parity 6/max=6 .=7, gen(Parity_nm)
misstable sum m_energy m_age gestage gesthyp preecl m_smkpreg Parity_nm m_edu kqimdq5
misstable pattern m_energy m_age gestage gesthyp preecl m_smkpreg Parity_nm m_edu kqimdq5
regress m_energy m_age gestage i.gesthyp i.preecl i.m_smkpreg Parity_nm i.m_edu i.kqimdq5, cformat(%9.2f)
regress m_energy m_age gestage i.m_smkpreg i.Parity_nm i.m_edu, cformat(%9.2f)
		
*==stochastic regression imputation
*if !missing(ast8y, ADHD9y) & missing(m_BMI)
gen im_energy=m_energy
*declare the mi style
mi set wide
*register im_BMI as an imputation variable
mi register imputed im_energy
*use the new method (naivereg) within mi impute
misstable sum m_age gestage m_smkpreg Parity_nm m_edu if missing(im_energy)
misstable patterns m_age gestage m_smkpreg Parity_nm m_edu if missing(im_energy)
sum im_energy if !missing(ast8y, ADHD7y)			   /*n=6,860*/
sum im_energy if !missing(ast8y, ADHD9y)			   /*n=6,403*/
*1st round
mi impute naivereg im_energy m_age gestage i.m_smkpreg i.Parity_nm i.m_edu, add(2) force 	  /*n Imputed=1867*/
sum _1_im_energy _2_im_energy _3_im_energy _4_im_energy _5_im_energy _6_im_energy _7_im_energy _8_im_energy _9_im_energy _10_im_energy _11_im_energy _12_im_energy
drop _1_im_energy _2_im_energy _3_im_energy _4_im_energy _5_im_energy _6_im_energy _7_im_energy _8_im_energy _9_im_energy _10_im_energy 
list im_energy _11_im_energy _12_im_energy if missing(im_energy)
gen av_im_energy=(_11_im_energy+_12_im_energy)/2
sum _11_im_energy _12_im_energy av_im_energy
replace im_energy=av_im_energy if missing(im_energy)
sum m_energy im_energy 								/*n=11,903 -> 13,770*/
la var im_energy "Maternal energy intake (kJ/d) @32w, imputed"
drop _11_im_energy _12_im_energy av_im_energy Parity_nm

*Imputation numbers for Ast-ADHD association
sum m_energy im_energy if !missing(ast8y, ADHD7y)			/*n=6,860 -> 7,165*/
		
mi unregister im_energy


*=====r_m_sugar imputation
misstable sum r_m_sugar im_energy m_age gestage gesthyp preecl m_smkpreg Parity m_edu kqimdq5
recode Parity 6/max=6 .=7, gen(Parity_nm)
misstable sum r_m_sugar im_energy m_age gestage gesthyp preecl m_smkpreg Parity_nm m_edu kqimdq5
misstable pattern m_energy m_age gestage gesthyp preecl m_smkpreg Parity_nm m_edu kqimdq5
regress r_m_sugar im_energy m_age gestage i.gesthyp i.preecl i.m_smkpreg i.Parity_nm i.m_edu i.kqimdq5, cformat(%9.2f)
regress r_m_sugar m_age i.m_smkpreg i.Parity_nm i.m_edu, cformat(%9.2f)
		
*==stochastic regression imputation
*if !missing(ast8y, ADHD9y) & missing(m_BMI)
gen ir_m_sugar=r_m_sugar
*declare the mi style
mi set wide
*register im_BMI as an imputation variable
mi register imputed ir_m_sugar
*use the new method (naivereg) within mi impute
misstable sum m_age m_smkpreg Parity_nm m_edu if missing(ir_m_sugar)
misstable patterns m_age m_smkpreg Parity_nm m_edu if missing(ir_m_sugar)
sum ir_m_sugar if !missing(ast8y, ADHD7y)			   /*n=6,860*/
sum ir_m_sugar if !missing(ast8y, ADHD9y)			   /*n=6,403*/
*1st round
mi impute naivereg ir_m_sugar m_age i.m_smkpreg i.Parity_nm i.m_edu, add(2) force 	  /*n Imputed=1867*/
sum _1_ir_m_sugar _2_ir_m_sugar _3_ir_m_sugar _4_ir_m_sugar _5_ir_m_sugar _6_ir_m_sugar _7_ir_m_sugar _8_ir_m_sugar _9_ir_m_sugar _10_ir_m_sugar _11_ir_m_sugar _12_ir_m_sugar _13_ir_m_sugar _14_ir_m_sugar
drop _1_ir_m_sugar _2_ir_m_sugar _3_ir_m_sugar _4_ir_m_sugar _5_ir_m_sugar _6_ir_m_sugar _7_ir_m_sugar _8_ir_m_sugar _9_ir_m_sugar _10_ir_m_sugar _11_ir_m_sugar _12_ir_m_sugar

list ir_m_sugar _13_ir_m_sugar _14_ir_m_sugar if missing(ir_m_sugar)
gen av_ir_m_sugar=(_13_ir_m_sugar+_14_ir_m_sugar)/2
sum _13_ir_m_sugar _14_ir_m_sugar av_ir_m_sugar
replace ir_m_sugar=av_ir_m_sugar if missing(ir_m_sugar)
sum r_m_sugar ir_m_sugar 								/*n=11,903 -> 13,770*/
la var ir_m_sugar "Energy adjusted free sugar intake (g/d) @32w, imputed"
drop _13_ir_m_sugar _14_ir_m_sugar av_ir_m_sugar Parity_nm

*Imputation numbers for Ast-ADHD association
sum r_m_sugar ir_m_sugar if !missing(ast8y, ADHD7y)			/*n=6,860 -> 7,165*/
		
mi unregister ir_m_sugar

egen ir_m_sugarq5=cut(ir_m_sugar), g(5) icode
la var ir_m_sugarq5 "Quintiles of energy adjusted imputed free sugar intake (g/d) @32w"
tab ir_m_sugarq5
tab m_sugarq5 ir_m_sugarq5 
tabstat ir_m_sugar, st(median) by(ir_m_sugarq5) format(%9.1f)
recode ir_m_sugarq5 0=34.0 1=48.1 2=58.4 3=70.4 4=91.1, gen(ir_m_sugarq5m)
tab ir_m_sugarq5 ir_m_sugarq5m



*======================Save
save "Data\ALSPAC_Ast&ADHD.dta", replace


