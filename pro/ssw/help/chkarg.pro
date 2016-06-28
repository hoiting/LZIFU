;+
; Project     : SDAC
;
; Name        : 
;	CHKARG
; Purpose     : 
;	Determine calling arguments of procedure or function.
; Explanation : 
;	Determines the calling arguments of an IDL procedure or function.  Used
;	by SCANPATH, but can also be called separately.
; Use         : 
;	CHKARG  [, NAME ]
; Inputs      : 
;	None required.
; Opt. Inputs : 
;	NAME	= Name of procedure to check arguments of.  If not passed, then
;		  it will be prompted for.
; Outputs     : 
;	The arguments of the procedure are printed to the screen.
; Opt. Outputs: 
;       name  = name of routine
;	proc  = string array with lines of procedure 
;       lname = libr/direc location of procedure
;       found = 1/0 if file is found/not found
; Keywords    : 
;	PATH  = optional directory/library search path.  Same format
;		and semantics as !PATH.  If omitted, !PATH is used.
;       SEARCH_ONLY = search path but do not print procedure arguments
;       RESET = clear commons
;       FOUND = 1 if found, 0 otherwise
;       PROGRESS = present progress bar
;       OUT = list of function/procedure calls
;       QUIET = turnoff printing
; Calls       : 
;	DATATYPE, GET_LIB, GET_MOD, GET_PROC, LOC_FILE
; Common      : 
;	None.
; Restrictions: 
;       Cannot access built-in IDL procedures
; Side effects: 
;	None.
; Category    : 
;	Documentation, Online_help.
; Prev. Hist. : 
;       Written DMZ (ARC) Oct 1990
;       Converted to version 2 (DMZ Jul'92)
; Written     : 
;	D. Zarro, GSFC/SDAC, October 1990.
; Modified    : 
;	Version 1, William Thompson, GSFC, 23 April 1993.
;		Incorporated into CDS library.
;       Version 2, Dominic Zarro, GSFC, 1 August 1994.
;               Cleaned up
;       Version 3, Dominic Zarro (GSFC) 21 September 1994.
;                  added checks for blank lines in documentation
;       Version 4, Zarro (GSFC), 21 April 1995
;                  added SEARCH keyword
;       Version 5, Zarro (SM&A/GSFC), 10 Feb 1999
;                  put on steroids
;       Version 6, Zarro (SM&A/GSFC), 20 May 1999
;                  added OUT and QUIET keywords
;-

pro chkarg,name,proc,location,path=path,found=found,reset=reset,quiet=quiet,$
           all=all,search_only=search_only,progress=progress,out=out
          
common procb,names,procs

on_error,1
found=0 & read_proc=1
loud=1-keyword_set(quiet)
if keyword_set(reset) then begin
 names='' & procs=''
endif
search=keyword_set(search_only)

if datatype(name) ne 'STR' then name=''
tname=name
break_file,name,dsk,location,pname,ext,ver
if (pname+ext) eq '' then begin
 repeat begin
  name = ''
  read,'* enter name of procedure? ',name 
  name=strtrim(name,2)
 endrep until (name ne '')
endif
break_file,name,dsk,location,pname,ext,ver
if ext eq '' then name=name+'.pro'

;-- is file in memory?

vms=!version.os eq 'vms'

if (not found) and (n_elements(names) ne 0) and (not keyword_set(reset)) then begin
 break_file,name,dsk,lname,pname,ext,ver
 break_file,names,dsks,lnames,pnames,exts,vers
 if vms then begin
  if ext eq '' then exts=''
  if ver eq '' then vers=''
  look=where(strupcase(name) eq strupcase(strtrim(pnames+exts+vers,2)),count)
 endif else begin
  look=where(name eq strtrim(pnames+exts,2),count)
 endelse

 if count gt 0 then begin
  location=(dsks+lnames)(look(0)) & proc=procs(*,look(0))
  found=1 & read_proc=0 & tname=(pnames+exts+vers)(look(0))
  if loud then message,'recalling '+tname+' from memory',/contin
 endif
endif

;-- check if file can be found directly with LOC_FILE

if found eq 0 then begin
 look=loc_file(name,count=nf)
 if nf gt 0 then begin
  if loud then message,'found in current directory',/cont
  break_file,look(0),dsk,location,pname,ext,ver
  location=dsk+location 
  tname=strtrim(pname+ext+ver,2)
  found=1 & read_proc=1
 endif
endif

;-- next search path

if not found then begin
 proc=name+' NOT FOUND'
 if n_elements(path) eq 0 then path = !path
 break_file,name,dsk,location,pname,ext,ver
 tname=pname+ext+ver

;-- get directories/libraries

 libs=get_lib(path)
 nlibs=n_elements(libs)

;-- now search each one till the procedure is found

 progress=keyword_set(progress)
 if progress then begin
  pid =progmeter(/INIT,label='Searching...',button='Cancel')
 endif
 last_val=0. & step=1.
 for i=0,nlibs-1 do begin
  location=libs(i)
  if progress then begin
   val = i/(1.0*nlibs)
   if abs((val-last_val))*100. gt step then begin
    if (progmeter(pid,val) eq 'Cancel') then goto,exit
    last_val=val
   endif
  endif
  islib=(strpos(location,'@') eq 0)
  if islib then begin
   mods=strlowcase(get_mod(location))
   nmods=n_elements(mods)
   if (nmods ne 1) or (mods(0) ne '') then begin  ;-- modules present?
    clook=where(strlowcase(pname) eq mods,count)
    if count gt 0 then begin
     fname=clook(0)
     found=1 
     if (not keyword_set(all)) then goto,exit
    endif else found=0
   endif
  endif else begin
   sname=concat_dir(location,tname)
   openr,lun,sname,error=error,/get_lun
;   look=loc_file(sname,count=nf)
   if error eq 0 then begin
    temp=fstat(lun)
    sname=temp.name
    if exist(lun) then free_lun,lun
    break_file,sname,dsk,loc,pname,ext,vers
    tname=strtrim(pname+ext+vers,2)
    found=1
    if (not keyword_set(all)) then goto,exit
   endif else found=0
  endelse
 endfor
endif

exit:    ;-- found procedure
xkill,pid

if not search then begin
 if found then begin
  if read_proc then proc=get_proc(location,tname)
  if loud then begin
   print,'---- Module: ', tname
   print,'---- From:   ', location
  endif
  strip_arg,proc,out,quiet=quiet
 endif else begin
  out=''
  message,proc,/contin
 endelse

;-- remove trailing blanks

 temp=reverse(proc)
 chk=where(temp ne '',cnt)
 if cnt gt 0 then proc=reverse(temp(chk(0):n_elements(temp)-1))
endif

;-- clean up extracted files from VMS libraries

quit:
if vms then rm_file,concat_dir(getenv('HOME'),'*.*_xdoc_*')

break_file,tname,dsk,tloc,pname,ext,ver
;name=pname

return & end


