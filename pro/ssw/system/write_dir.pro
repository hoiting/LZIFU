;+
; Project     : HINODE/EIS
;
; Name        : WRITE_DIR
;
; Purpose     : Test if directory is writeable
;
; Inputs      : DIR  = directory name to test
;
; Keywords    : See WRITE_DIR2
;
; Version     : Written, 12-Nov-2006, Zarro (ADNET/GSFC)
;                - uses better FILE_TEST
;               Modified, 6-July-2007, Zarro (ADNET/GSFC)
;                - added /VERBOSE
;
; Contact     : dzarro@solar.stanford.edu
;-

function write_dir,dir,out=out,valid_dir=valid_dir,err=err,_extra=extra,$
           verbose=verbose

forward_function file_test

verbose=keyword_set(verbose)
err=''
if is_blank(dir) then begin
 err='Invalid or blank directory input'
 if verbose then message,err,/cont
 return,0b
endif

if since_version('5.4') then begin
 out=chklog(dir,/pre)
 if arg_present(valid_dir) then valid_dir=file_test(out,/dir)
 test=file_test(out,/dir,/write)
 if test eq 0 then err='No write access to '+out
 if verbose and is_string(err) then message,err,/cont
 return,test
endif

return,write_dir2(dir,out=out,valid_dir=valid_dir,err=err,_extra=extra)

end
