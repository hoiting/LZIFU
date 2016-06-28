;+
; Project     : SOHO - CDS
;
; Name        : STR2FILE
;
; Purpose     : print string array to a file
;
; Category    : utility
;
; Explanation : 
;
; Syntax      : IDL> str2file,array,file
;
;
; Inputs      : ARRAY = string array to print
;
; Opt. Inputs : FILE = filename for output
;               (if not given, defaults to str2file.tmp home directory)
;
; Outputs     : None
;
; Opt. Outputs: None
;
; Keywords    : VERBOSE - set to output info
;               ERR - error string
;
; Common      : None
;
; Restrictions: ARRAY must be string
;
; Side effects: None
;
; History     : Version 1,  1-Feb-1996,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro str2file,array,file,verbose=verbose,err=err

on_error,1
err=''

if datatype(array) ne 'STR' then begin
 err= 'input array must be a string'
 message,err,/cont
 return
endif

if datatype(file) ne 'STR' then begin
 file=concat_dir(getenv('HOME'),'str2file.tmp')
 if keyword_set(verbose) then message,'array will be printed to '+file,/cont
endif

fdir=file_break(file,/path)
ok=test_open(fdir,/write)
if ok then begin
 openw,lun,file,/get_lun,error=ioerror
 if ioerror ne 0 then begin
  err=!err_string & message,err,/cont
  return
 endif
 for i=0,n_elements(array)-1 do printf,lun,array(i)
 close,lun & free_lun,lun
endif else begin
 err='Denied write privilege for file: '+file
 message,err,/cont
endelse


return & end
