*===========================================================================
* Project: Asthma-ADHD
* Purpose: Table 1
* By Dr Mohammad Talaei 
* Launch date: 12 Oct 2023
* Last update: 23 July 2024
*===========================================================================

*QMUL
cd "C:\Users\hmy431\OneDrive - Queen Mary, University of London\ALSPAC"
*Home
cd "C:\Users\mtala\OneDrive - Queen Mary, University of London\ALSPAC"

*Open data
use "Data\ALSPAC_Ast&ADHD.dta", clear
*Model
do AstADHD\codes\Models_Ast-ADHD.do


cd "C:\Users\hmy431\Documents"
cd "C:\Users\mtala\Documents"
keep if !missing(ast8y) & !missing(ADHD7y)

*-->Continuous variable								m_age im_BMI gestage ibweight ir_m_sugar im_energy
putexcel set outputs\Table_1_Ast-ADHD.xlsx, sheet(Table 1) modify
putexcel A1=("") B1=("Mean ± SD") C1=("Min-Max") D1=("N"), bold 
local row="m_age im_BMI gestage ibweight ir_m_sugar im_energy"	   

set more off
local nn=1	   
foreach varr of varlist `row' {
local nn=`nn'+1
local excA: display "A"`nn'
local excB: display "B"`nn'
local excC: display "C"`nn'
local excD: display "D"`nn'
local cvlabel: variable label `varr'
putexcel `excA'=("`cvlabel'"), bold  
display "----------------------------------------------" `"`varr'"'
sum `varr', d
local msd : display %3.2f `r(mean)' " ± " %3.2f `r(sd)' 
local minmax : display %3.2f `r(min)' "-" %3.2f `r(max)' 
putexcel `excB' = ("`msd'") `excC' = ("`minmax'") `excD' = `r(N)', names nformat(number_d2) 
sleep 2000
}
*


*-->Binary variables with one value report			sex ast8y ADHD7y ADHD9y
local row="sex ast8y ADHD7y ADHD9y"	   
putexcel B8= ("BBB, n (%)"), bold

set more off
local nn1=8 	
set more off   
foreach bvar of varlist `row' {
local nn1=`nn1'+1
local bvlabel: variable label `bvar'
local bvlab: display `"`bvlabel'"' ", n (%)"
putexcel A`nn1'= ("`bvlab'"), bold 
display "----------------------------------------------" `"`varr'"'
tabulate `bvar' if `bvar'>=0, matcell(nn) 
local np1 : display %5.0fc nn[2,1] " (" %3.1f (nn[2,1]/r(N))*100 ")"
putexcel B`nn1' = ("`np1'"), names nformat(number_d2) 
sleep 3000
}
*

*Alternative method using dtable command for both binary and categorical variables
/*Notes:	Categories
				3: m_findif paracetamol preecl
				4: categories m_housing 
				5: m_smkpreg anx_g4 dep_g4
				6: m_edu
			kqimdq5 omitted as it is quintile and source variable is not available 	*/

dtable i.sex i.m_edu i.m_findif i.m_housing i.m_smkpreg i.anx_g4 i.dep_g4 i.paracetamol i.preecl i.ast8y i.ADHD7y i.ADHD9y if !missing(ast8y) & !missing(ADHD7y), export(Table_1.xlsx)


*-->Binary secondary exposures 					ecz8y hay8y atopy
*Notes: 	Needs to be in original sample (without keep command on line 22 executed)
foreach bvar in ecz8y hay8y atopy {
	tab `bvar' if !missing(ADHD7y)
}
