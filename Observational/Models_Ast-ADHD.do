*===========================================================================
* Project: Asthma-ADHD 
* Purpose: Models for asthma-ADHD association (observational), cumulative
* Last date: 06 Feb 2023
* Changes: 
*===========================================================================

*Defining the model macros:
global model_1 " "
global model_2 "sex"
global model_3 "$model_2 i.m_edu i.kqimdq5 i.m_housing i.m_findif"
global model_4 "$model_3 i.anx_g4"
global model_5 "$model_4 i.dep_g4"
global model_6 "$model_5 gestage" 
global model_7 "$model_6 i.m_smkpreg"
global model_8 "$model_7 i.paracetamol"
global model_9 "$model_8 m_age"
global model_10 "$model_9 ibweight"
global model_11 "$model_10 i.preecl"
global model_12 "$model_11 i.ir_m_sugarq5 im_energy"  
global model_13 "$model_12 im_BMI"


*===========================================================================


