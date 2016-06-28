;+
; Project     : SOHO - CDS     
;                   
; Name        : STR_FORMAT
;               
; Purpose     : format a variable to a string
;               
; Category    : utility
;               
; Explanation : 
;               
; Syntax      : IDL> result=STR_format(variable,format)
;    
; Inputs      : VARIABLE = variable to format
;               
; Opt. Inputs : FORMAT  = string format to use [def = '(f15.3')]
;               
; Outputs     : RESULT = variable formatted as a string
;
; History     : Version 1,  4-May-1996,  D M Zarro.  Written
;
; Contact     : DMZARRO
;-            

function str_format,variable,format

if not exist(variable) then return,''
if is_blank(format) then sform='(f15.3)' else sform=format
return,string(variable,format=sform)

end

