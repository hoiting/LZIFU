;+
; Project     : HESSI
;                  
; Name        : CHMOD
;               
; Purpose     : wrapper around FILE_CHMOD that catches errors
;                             
; Category    : system utility
;               
; Syntax      : IDL> file_chmod,file
;                                        
; Outputs     : None
;                   
; History     : 17 Apr 2003, Zarro (EER/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

pro chmod,file,mode,_extra=extra,verbose=verbose

if not since_version('5.4') then return
if is_blank(file) then return

for i=0,n_elements(file)-1 do begin

 error=0
 catch,error
 if error ne 0 then begin
  if keyword_set(verbose) then message,err_state(),/cont
  catch,/cancel
  continue
 endif

 if n_params() eq 2 then file_chmod,file[i],mode,_extra=extra else $
  file_chmod,file[i],_extra=extra

endfor

return

end
