;+
; Project     : HESSI
;                  
; Name        : CLOSE_LUN
;               
; Purpose     : Same as FREE_LUN but with error checks
;                             
; Category    : system utility i/o
;               
; Syntax      : IDL> close_lun,lun
;
; Inputs      : LUN = logical unit number to free and close
;
; Outputs     : None
;
; Keywords    : None
;                   
; History     : 6 May 2002, Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

pro close_lun,lun,all=all

on_ioerror,bail

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 return
endif

if keyword_set(all) then begin
 close,/all
 return
endif

if not is_number(lun) then return
if lun le 0 then return

if since_version('5.4') then begin
 call_procedure,'close',lun,/force
 call_procedure,'free_lun',lun,/force
endif else begin
 close,lun
 free_lun,lun
endelse

bail:

return & end
