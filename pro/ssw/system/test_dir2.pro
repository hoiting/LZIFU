;+
; Project     : SOHO-CDS
;
; Name        : TEST_DIR2
;
; Purpose     : Test that a directory exists and is writable
;
; Category    : Utility
;
; Syntax      : status=test_dir(dir_name)
;
; Inputs      : DIR_NAME = directory name to check
;
; Outputs     : status = 1/0 if success/fail
;
; Keywords    : ERR = output messages
;               QUIET = turn off printing output messages
;               COUNT = # of valid directories
;
; History     : Written 14 May 1998 D. Zarro, SAC/GSFC
;               Modified 14 March 2000, Zarro (SM&A/GSFC) - vectorized
;               Modified, 3-Jan-2002, Zarro - added check for input
;               directory as single element scalar
;               Modified, 16-Nov-2006, Zarro (ADNET/GSFC)
;                - renamed to TEST_DIR2
;      
;
; Contact     : dzarro@solar.stanford.edu
;-

function test_dir2,dir_name,out=out,quiet=quiet,err=err,count=count,_extra=extra

;-- use recursion for vector inputs

count=0 
np=n_elements(dir_name)
if np gt 1 then begin
 bool=bytarr(np)
 out=strarr(np)
 terr=strarr(np)
 for i=0,np-1 do begin
  bool[i]=test_dir2(dir_name[i],out=tout,quiet=quiet,err=temp,_extra=extra)
  terr[i]=trim(temp)  
  out[i]=tout
 endfor
 sorder=uniq([terr],sort([terr]))
 err=trim(arr2str(terr(sorder),delim=' '))
 chk=where(bool,count)
 return,bool
endif

loud=1-keyword_set(quiet)
err=''

if not is_dir2(dir_name,out=out,_extra=extra) then begin
 err='non-existent directory '
 if is_string(dir_name) then err=err+'"'+dir_name[0]+'"'
 if loud then message,err,/cont
 return,0b
endif

if not write_dir2(dir_name,_extra=extra) then begin
 err='No write access to directory '
 if is_string(dir_name) then err=err+'"'+dir_name[0]+'"'
 if loud then message,err,/cont
 return,0b
endif

count=1
return,1b

end
