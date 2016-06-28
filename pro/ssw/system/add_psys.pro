;+
; Project     : SOHO - CDS     
;                   
; Name        : ADD_PSYS
;               
; Purpose     : Add plotting system variables
;               
; Category    : utility
;               
; Syntax      : IDL> add_sys
;
; Inputs      : None
;               
; Outputs     : None
;
; Side Effects: !device, !image, etc defined
;
; History     : 6-May-2004,  D. Zarro (L-3Con/GSFC).  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-     

pro add_psys

defsysv,'!image',exists=defined
if not defined then imagelib
defsysv,'!aspect',exists=defined
if not defined then devicelib
defsysv,'!debug',exists=defined
if not defined then uitdblib

return

end
