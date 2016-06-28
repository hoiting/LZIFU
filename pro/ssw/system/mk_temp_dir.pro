;+
; Project     : SOHO - CDS
;
; Name        : MK_TEMP_DIR
;
; Purpose     : Create a temporary directory 
;
; Category    : Utility
;
; Explanation : 
;
; Syntax      : IDL>mk_temp_dir,dir,temp_dir
;
; Inputs      : DIR = directory in which to create temporary sub-directory
;
; Opt. Inputs : None
;
; Outputs     : TEMP_DIR = name of created sub-directory
;
; Opt. Outputs: None
;
; Keywords    : ERR = error string
;
; Restrictions: None
;
; Side effects: Subdirectory named temp$$$$ is created
;
; History     : Version 1,  9-June-1999,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro mk_temp_dir,dir,temp_dir,err=err,verbose=verbose

err=''
temp_dir=''

if not is_dir(dir) then begin
 pr_syntax,'mk_temp_dir,dir'
 return
endif

;-- test for write access

if not write_dir(dir) then begin
 err='No write access to "'+dir+'"'
 message,err,/cont
 return
endif

;-- create a unique extension for temp

pid=get_rid()
sub_dir=concat_dir(dir,'temp'+pid)
mk_dir,sub_dir,/a_write,/a_read

;-- test for success

unix=os_family(/lower) eq 'unix'
verbose=keyword_set(verbose)
if is_dir(sub_dir) then begin
 temp_dir=sub_dir
 if verbose then message,'created "'+sub_dir+'"',/cont
endif else begin
 err='failed to create "'+sub_dir+'"'
 if verbose then message,err,/cont
endelse
           
return & end       

