;+
; Project     : SOHO - CDS     
;                   
; Name        : PR_SYNTAX
;               
; Purpose     : print syntax of calling procedure/function
;               
; Category    : utility
;               
; Explanation : 
;               
; Syntax      : IDL> pr_syntax,input
;    
; Examples    : 
;
; Inputs      : INPUT = input syntax string
;               
; Opt. Inputs : None
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : None
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; History     : Version 1,  4-Sep-1997, Zarro (SAC/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-            


pro pr_syntax,input

if datatype(input) eq 'STR' then begin
 if trim(input) ne '' then begin
  caller=get_caller()
  print,'% '+caller+': syntax --> '+input
 endif
endif

return & end

