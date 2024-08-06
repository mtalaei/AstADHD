*===========================================================================
* Project: Asthma-ADHD
* Purpose: Presentation
* By Dr Mohammad Talaei 
* Launch date: 16 May 2023
* Last update: 05 Jun 2024
*===========================================================================

*QMUL
cd "C:\Users\hmy431\OneDrive - Queen Mary, University of London\ALSPAC"
*Home
cd "C:\Users\mtala\OneDrive - Queen Mary, University of London\ALSPAC"

*Open data
use "Data\ALSPAC_Ast&ADHD.dta", clear
 
*Model
do AstADHD\codes\Models_Ast-ADHD.do


*===========Ast(bi)-ADHD 7y Epi cumulative 5-level				Fig 1-A
matrix orci = J(5, 3, .)
matrix coln orci = OR ll95 ul95
matrix rown orci = 0 1 2 3 4  

matrix orci[1,1]=1.35
matrix orci[1,2]=1.10
matrix orci[1,3]=1.65

matrix orci[2,1]=1.28
matrix orci[2,2]=1.04
matrix orci[2,3]=1.57

matrix orci[3,1]=1.21
matrix orci[3,2]=0.98
matrix orci[3,3]=1.49

matrix orci[4,1]=1.17
matrix orci[4,2]=0.95
matrix orci[4,3]=1.45

matrix orci[5,1]=1.15
matrix orci[5,2]=0.93
matrix orci[5,3]=1.42

matrix list orci

coefplot (matrix(orci[,1]), ci((orci[,2] orci[,3]))), ///
xline(1) xtitle(Odds ratio, margin(small)) xlabel(0.8(0.2)1.8) ///
coeflabels(0 = "Crude" 1 = "Adjusted for sex" 2 = "+ SES factors"  ///
3 = "+ Maternal anxiety" 4 = "Fully adjusted model") ///
mlabel format(%9.2f) mlabposition(12) mlabgap(*1.5) mlabcolor(black) ytitle(Cumulative adjustment factors) ///
title("{bf:Asthma@7-ADHD@7 association}" " ", size(medium)) graphregion(fcolor(white)) ///
grid(n) color(cranberry) ciopts(lcolor(cranberry))

graph save Graph "AstADHD\outputs\Ast-ADHD7y_cumu5.gph", replace
graph export "AstADHD\outputs\Ast-ADHD7y_cumu5.tif", replace width(1200)



*===========Ast(cat4)-ADHD 7y Epi cumulative 5-level			Fig 1-B
matrix orci1 = J(5, 3, .)
matrix coln orci1 = OR ll95 ul95
matrix rown orci1 = 0 1 2 3 4  

matrix orci1[1,1]=0.84
matrix orci1[1,2]=0.64
matrix orci1[1,3]=1.12

matrix orci1[2,1]=0.78
matrix orci1[2,2]=0.59
matrix orci1[2,3]=1.04

matrix orci1[3,1]=0.81
matrix orci1[3,2]=0.61
matrix orci1[3,3]=1.08

matrix orci1[4,1]=0.81
matrix orci1[4,2]=0.61
matrix orci1[4,3]=1.08

matrix orci1[5,1]=0.83
matrix orci1[5,2]=0.62
matrix orci1[5,3]=1.11

matrix list orci1

matrix orci2 = J(5, 3, .)
matrix coln orci2 = OR ll95 ul95
matrix rown orci2 = 0 1 2 3 4  

matrix orci2[1,1]=1.51
matrix orci2[1,2]=1.09
matrix orci2[1,3]=2.09

matrix orci2[2,1]=1.46
matrix orci2[2,2]=1.05
matrix orci2[2,3]=2.02

matrix orci2[3,1]=1.32
matrix orci2[3,2]=0.94
matrix orci2[3,3]=1.85

matrix orci2[4,1]=1.26
matrix orci2[4,2]=0.90
matrix orci2[4,3]=1.77

matrix orci2[5,1]=1.24
matrix orci2[5,2]=0.88
matrix orci2[5,3]=1.75

matrix list orci2

matrix orci3 = J(5, 3, .)
matrix coln orci3 = OR ll95 ul95
matrix rown orci3 = 0 1 2 3 4  

matrix orci3[1,1]=1.00
matrix orci3[1,2]=0.69
matrix orci3[1,3]=1.45

matrix orci3[2,1]=0.91
matrix orci3[2,2]=0.63
matrix orci3[2,3]=1.33

matrix orci3[3,1]=0.92
matrix orci3[3,2]=0.63
matrix orci3[3,3]=1.34

matrix orci3[4,1]=0.90
matrix orci3[4,2]=0.61
matrix orci3[4,3]=1.31

matrix orci3[5,1]=0.89
matrix orci3[5,2]=0.61
matrix orci3[5,3]=1.30

matrix list orci3

coefplot (matrix(orci1[,1]), ci((orci1[,2] orci1[,3])) label(Atopy without asthma)) ///
(matrix(orci2[,1]), ci((orci2[,2] orci2[,3])) label(Nonatopic asthma)) ///
(matrix(orci3[,1]), ci((orci3[,2] orci3[,3])) label(Atopic asthma)), ///
xline(1) xtitle(Odds ratio, margin(small)) xlabel(0.6(0.2)2.60) ///
coeflabels(0 = "Crude" 1 = "Adjusted for sex" 2 = "+ SES factors"  ///
3 = "+ Maternal anxiety" 4 = "Fully adjusted model") ///
mlabel format(%9.2f) mlabposition(12) mlabgap(*1.5) mlabcolor(black) ytitle(Cumulative adjustment factors) ///
title("{bf:Asthma endotypes@7-ADHD@7 association}" " ", size(medium)) graphregion(fcolor(white)) ///
grid(n) legend(ring(0) pos(4))

graph save Graph "AstADHD\outputs\AstC-ADHD7y_cumu5.gph", replace
graph export "AstADHD\outputs\AstC-ADHD7y_cumu5.tif", replace width(1200)
*coeflabels: , wrap(30) labgap(1)


*Ast(cat3), excluding atopy without asthma
coefplot (matrix(orci2[,1]), ci((orci2[,2] orci2[,3])) label(Nonatopic asthma) color(cranberry) ciopts(lcolor(cranberry))) ///
(matrix(orci3[,1]), ci((orci3[,2] orci3[,3])) label(Atopic asthma) color(midblue) ciopts(lcolor(midblue))), ///
xline(1) xtitle(Odds ratio, margin(small)) xlabel(0.6(0.2)2.20) ///
coeflabels(0 = "Crude" 1 = "Adjusted for sex" 2 = "+ SES factors"  ///
3 = "+ Maternal anxiety" 4 = "Fully adjusted model") ///
mlabel format(%9.2f) mlabposition(12) mlabgap(*1.5) mlabcolor(black) ytitle(Cumulative adjustment factors) ///
title("{bf:Asthma endotypes@7-ADHD@7 association}" " ", size(medium)) graphregion(fcolor(white)) ///
grid(n) legend(ring(0) pos(4))

graph save Graph "AstADHD\outputs\AstC3-ADHD7y_cumu5.gph", replace
graph export "AstADHD\outputs\AstC3-ADHD7y_cumu5.tif", replace width(1200)




*===============PRS histogram									Fig S1
*Asthma
forv i=1(1)7 {
		hist Asthma_Z_SCORE_children_S`i', ylabel(, nogrid) xlabel(, nogrid) ///
		xtitle("Asthma PRS, P threshold `i'") name(Gr`i', replace) 
}
graph combine Gr1 Gr2 Gr3 Gr4 Gr5 Gr6 Gr7
graph save Graph "AstADHD\outputs\AstPRS_Hist.gph", replace
graph export "AstADHD\outputs\AstPRS_Hist.tif", replace width(1500)
*ADHD
forv i=1(1)7 {
		hist ADHD_Z_SCORE_children_S`i', ylabel(, nogrid) xlabel(, nogrid) ///
		xtitle("ADHD PRS, P threshold `i'") name(Gr`i', replace) 
}
graph combine Gr1 Gr2 Gr3 Gr4 Gr5 Gr6 Gr7
graph save Graph "AstADHD\outputs\ADHDPRS_Hist.gph", replace
graph export "AstADHD\outputs\ADHDPRS_Hist.tif", replace width(1500)