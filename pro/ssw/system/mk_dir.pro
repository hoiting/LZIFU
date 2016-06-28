;+
; Project     : HESSI
;                  
; Name        : MK_DIR
;               
; Purpose     : wrapper around FILE_MKDIR that catches errors
;                             
; Category    : system utility
;               
; Syntax      : IDL> mk_dir,dir
;                                        
; Outputs     : None
;                   
; History     : 17 Apr 2003, Zarro (EER/GSFC)
;               13 Apr 2004, Zarro (L-3Com/GSFC) - added CHMOD
;
; Contact     : dzarro@solar.stanford.edu
;-    

pro mk_dir,dir,_extra=extra,verbose=verbose

if is_blank(dir) then return
v54=since_version('5.4')

for i=0,n_elements(dir)-1 do begin

 error=0
 catch,error
 if error ne 0 then begin
  if keyword_set(verbose) then message,err_state(),/cont
  catch,/cancel
  continue
 endif

 dname=chklog(dir[i],/pre)
 if not is_dir(dname) then begin
  if v54 then file_mkdir,dname else espawn,'mkdir '+dname,/noshell
 endif

 if is_struct(extra) then begin
  if is_dir(dname) then chmod,dname,_extra=extra
 endif

endfor

return & end
