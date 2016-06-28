;+
; Project     : HESSI
;
; Name        : STC_CLONE
;
; Purpose     : Clone a structure by saving it to an IDL save file
;               and then restoring it into a new structure
;
; Category    : utility structures
;
; Syntax      : IDL> clone=stc_clone(structure)
;
; Inputs      : structure = structure to clone (array or scalar)
;
; Outputs     : CLONE = cloned structure
;
; History     : Written 29 Nov 2002, D. Zarro (EER/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;
;-

function stc_clone,structure,err=err,_extra=extra

err='Invalid structure entered'
if not exist(structure) then begin
 message,err,/cont
 return,-1
endif

if size(structure,/tname) ne 'STRUCT' then begin
 message,err,/cont
 return,structure
endif

return,clone_var(structure)

end
