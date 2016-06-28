;+
; Project     : SOHO - CDS
;
; Name        : COPY_VAR
;
; Purpose     : to copy data by pointer
;
; Category    : utility
;
; Explanation : Copy data by moving address location. 
;               Effectively the same as: new_var=temporary(var)
;               but more elegant.
;
; Syntax      : IDL> new_var=copy_var(var)
;
; Inputs      : VAR = data variable to copy
;
; Opt. Inputs : None
;
; Outputs     : NEW_VAR = new data variable to receive value of VAR
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
; History     : Written, 22-Feb-98, Zarro (SAC/GSFC)
;               Modified, 15-Jun-99, Zarro (SM&A/GSFC) - switched back to using TEMPORARY
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


function copy_var,var

if not exist(var) then return,-1 else return,temporary(var)

make_pointer,temp
set_pointer,temp,var,/no_copy
new_var=get_pointer(temp,/no_copy)
free_pointer,temp
return,new_var
end
