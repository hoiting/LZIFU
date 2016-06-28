;+
; Project     : HESSI
;                  
; Name        : DEVICE2
;               
; Purpose     : wrapper around DEVICE that uses 'CATCH' since DEVICE
;               seems to crash on some Linux systems.
;                             
; Category    : system utility
;               
; Syntax      : IDL> device2,keywords=value
;
; Outputs     : See keywords
;
; Keywords    : Inherits all DEVICE keywords
;                   
; History     : 24 Aug 2005, Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

pro device2,_ref_extra=extra

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 return
endif

device,_extra=extra

end
