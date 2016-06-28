;+
; Project     : SOHO - CDS
;
; Name        : RM_FILE
;
; Purpose     : delete a file in OS independent way
;
; Category    : OS
;
; Explanation : uses openr,/del
;
; Syntax      : IDL> rm_file,file,err=err
;
; Inputs      : FILE = filename to delete
;
; Keywords    : ERR = any errors
;
; History     : Version 1,  1-Jul-1996,  D.M. Zarro.  Written
;               Modified, 29-Nov-99, Zarro (SM&A/GSFC), added CATCH
;               Modified, 14-Mar-00, Zarro (SM&A/GSFC) - added /check
;               Modified, 13-Aug-01, Zarro (EITI/GSFC) 
;                - upgraded to use FILE_DELETE in IDL 5.4
;               Modified, 9-Feb-04, Zarro (L-3Com/GSFC) 
;                - added directory search
;               Version 5, 3-Dec-2004, William Thompson, GSFC
;                - Don't call file_delete for null filenames
;               Modified, 4-Dec-2006, Zarro (ADNET/GSFC)
;                - removed blanks from file names
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro rm_file,file,err=err,check=check

err=''
if is_blank(file) then begin
 err='Invalid input'
 return
endif

;-- check if directory

if is_dir(file) then files=loc_file('*.*',path=file) else begin

;-- expand wild chars

 if strpos(file[0],'*') gt -1 then files=loc_file(file[0]) else files=file

endelse

if keyword_set(check) then begin
 print,files
 return
endif

if since_version('5.4') then begin
 dfiles=strtrim(files,2)
 ww = where(dfiles ne '',wwcount)
 if wwcount gt 0 then call_procedure,'file_delete',dfiles[ww],/quiet
 return
endif

count=n_elements(files)
ferr=strarr(count)
for i=0,count-1 do begin

 tmp=files(i)

 if is_open(tmp,unit=unit) then begin
  close,unit
  free_lun,unit
 endif

 delvarx,unit
 err='' & error=0
 def_err='error deleting: '+tmp

 on_ioerror,trap

 if error ne 0 then begin
  trap:
  on_ioerror,null
  deleted=0b
  defsysv,'!error_state',exists=defined
  if defined then s=execute('err=!error_state.msg') else err=def_err
  goto,cleanup
 endif

;-- use Catch for IDL versions >= 4

 if idl_release(lower=4,/inc) then begin
  catch,error
  if error ne 0 then begin
   catch,/cancel
   deleted=0b
   defsysv,'!error_string',exists=defined
   if defined then s=execute('err=!error_string') else err=def_err
   goto,cleanup
  endif  
 endif

 openr,unit,tmp,/get_lun,/del
 if exist(unit) then begin
  close,unit & free_lun,unit
 endif

 if !err ne 0 then begin
  error=!err
  deleted=0b 
  if have_proc('strmessage') then err=call_function('strmessage',!error) else err=def_err
 endif else deleted=1b

cleanup: if not deleted then ferr(i)=err

endfor

errors=where(ferr ne '',ecount)
if ecount gt 0 then err=arr2str(ferr(errors))

return & end
