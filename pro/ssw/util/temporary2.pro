;+
; Project     : HESSI
;                  
; Name        : TEMPORARY2
;               
; Purpose     : more robust TEMPORARY function that handles undefined input
;                             
; Category    : utility
;               
; Syntax      : IDL> out=temporary2(in)
;
; Inputs      : IN = input variable
;                                   
; Outputs     : OUT = output variable
;                              
; History     : Written, 19-Nov-2003, Zarro (L-3/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

function temporary2,in

if n_elements(in) eq 0 then return,undef

return,temporary(in)

end
