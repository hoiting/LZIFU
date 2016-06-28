;+
; Project     : HESSI
;                  
; Name        : IS_SSW
;               
; Purpose     : return true if current IDL environment is SSW
;                             
; Category    : system utility
;               
; Syntax      : IDL> a=is_ssw()
;    
; Inputs      : None
;                              
; Outputs     : 1/0 is under SSW or not
;               
; History     : 23-Jan-2003, Zarro (EER/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    


function is_ssw

defsysv,'!SSW',exists=defined
if not defined then defsysv,'!SSW',0b
return,!SSW
end
