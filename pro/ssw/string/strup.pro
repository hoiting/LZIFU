;+
; Project     : HESSI
;                  
; Name        : STRUP
;               
; Purpose     : simultaneously trim and uppercase a string
;                             
; Category    : string utility
;               
; Syntax      : IDL> out=strup(in)
;
; Inputs      : IN = input string
;                                   
; Outputs     : OUT = output string
;                              
; History     : Written, 4-Jan-2000, Zarro (SM&A/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

function strup,in

return,strupcase(trim2(in))

end
