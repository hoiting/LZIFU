;+
; Project     : EIS
;
; Name        : LOAD_PATH
;
; Purpose     : Load an IDL path which contains specified program
;
; Category    : system
;                   
; Inputs      : PATH = full path name
;               MODULE = module name
;
; Outputs     : None
;
; Keywords    : VERBOSE = set for message output
;
; History     : 31-Jan-2003,  D.M. Zarro (EER/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro load_path,path,module,verbose=verbose,err=err,_extra=extra
err=''

if is_blank(module) or is_blank(path) then return
if have_proc(module) then return

sdir=local_name(path)
if not is_dir(sdir) then begin
 err='Directory not installed - '+path
 message,err,/cont
 return
endif

add_path,sdir,/expand,/quiet,_extra=extra

if not have_proc(module) then begin
 err='Failed to locate module - '+module
 message,err,/cont
 return
endif

if keyword_set(verbose) then message,'Successfully installed - '+sdir,/cont

return & end

