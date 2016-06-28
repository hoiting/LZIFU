;+
; Project     : SOHO - CDS     
;                   
; Name        : STR_DEBLANK
;               
; Purpose     : replace blank delimiters in a string with commas
;               
; Category    : utility
;               
; Explanation : 
;               
; Syntax      : IDL> result=str_deblank(variable,format)
;    
; Examples    : a='1,2,3 5 6,7'
;               print,str_deblank(a)
;               '1,2,3,4,5,6,9'
;
; Inputs      : VARIABLE = string to deblank
;               
; Opt. Inputs : FORMAT  = string format to use 
;               
; Outputs     : RESULT = deblanked variable
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
; History     : Version 1,  4-May-1996,  D M Zarro.  Written
;
; Contact     : DMZARRO
;-            

function str_deblank,variable,format

;-- check inputs

if not exist(variable) then return,0
if datatype(variable) eq 'STC' then return,variable

new=variable
if datatype(variable) eq 'STR' then begin
 if strtrim(variable) eq '' then return,variable
endif else new=string(new)

if datatype(format) eq 'STR' then sform=format
if n_elements(new) gt 1 then new=arr2str(new) else new=new(0)

new=strep(new,',',' ',/all)
new=strcompress(new)
new=strtrim(new,2)
new=str2arr(new,delim=' ')
if exist(sform) then new=string(new,format=sform)
new=arr2str(new,delim=',')
new=strcompress(new,/rem)

return,new
end

