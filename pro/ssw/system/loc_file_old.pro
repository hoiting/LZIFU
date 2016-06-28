;+
; Project     : SOHO - CDS
;
; Name        : 
;       LOC_FILE()
; Purpose     : 
;       Get files from a set of directories.
; Explanation : 
;	Similar to the standard utility FINDFILE, but allows for a series of
;	directories to be searched.  Also, in Unix, it takes care of pathnames
;	that contain the special "~" character, which FINDFILE currently does
;	not do.
; Use         : 
;       Result = LOC_FILE(FILE,PATH=PATH,LOC=LOC,COUNT=COUNT,ALL=ALL)
; Inputs      : 
;       FILE	= Name of file(s) to search for.  It may contain wildcard
; Outputs     : 
;	The result of the function is an array containing the names of all the
;	files found.
; Keywords    : 
;       PATH	= Array or scalar string with names of directories to search.
;       LOC	= Returned directory locations of found files.
;       COUNT	= Number of found files.
;       ALL	= If set, then search all directories.  Otherwise, the
;		  procedure stops as soon as a match is found.
;       NO_RECHECK = switch off rechecking
;       RECHECK = switch on rechecking
; Category    : 
;	Utilities, Operating_system.
; Written     : 
;	D. Zarro, GSFC/SDAC, December 1992.
; Modified    : 
;	Version 1, William Thompson, GSFC, 23 April 1993.
;		Incorporated into CDS library.
;       Version 2, Dominic Zarro, GSFC, 1 August 1994.
;               Added for error checking
;       Version 3, Zarro (SM&A), 30-November-1998
;               Added extra check for super large directories
;       Version 4, Zarro (SM&A), 15-April-1999
;               Added NO_RECHECK to switch off extra checking
;               for super large directories
;       Version 5, Zarro (SM&A), 7-Dec-1999 - vectorized
;       Version 6, Zarro (EIT/GSFC), 28 May 2000 - added check
;               for delimited path string via call to STR_EXPAND
;       Version 7, Zarro (EIT/GSFC), 12 June 2000 - made NO_RECHECK
;              the default
;       Version 8, Zarro (EIT/GSFC), 1 July 2000 - added check for
;              correct OS delimiter in file/path names
;       Version 9, Zarro (EIT/GSFC), 12 Dec 2001 - added check for
;              blank filename
;       Version 10, Zarro (EIT/GSFC), 3 Jan 2002 - added call to
;              CHKLOG prior to STR_EXPAND
;-
  
function loc_file_old,file,path=path,loc=loc,all=all,count=count,$
         verbose=verbose,err=err,recheck=recheck

;dprint,'% LOC_FILE called by: ',get_caller()

on_error,1

count=0 & err=''
verbose=keyword_set(verbose) 

if is_blank(file) then begin
 err='Invalid filename entered'
; err='usage --> FILES=LOC_FILE(FILE,PATH=PATH)'
 if verbose then message,err,/cont
 if not exist(file) then return,'' else return,file
endif

;-- recurse on vector inputs

nfile=n_elements(file)
if nfile gt 1 then begin
 for i=0,nfile-1 do begin
  chk=loc_file(file(i),path=path,loc=loc,all=all,count=scount,$
         verbose=verbose,err=err,recheck=recheck)
  if scount gt 0 then out=append_arr(out,chk,/no_copy)
 endfor
 count=n_elements(out)
 if count eq 0 then return,'' else return,out
endif

loc='' 
recheck=keyword_set(recheck)
vms=os_family(/lower) eq 'vms'
unix=os_family(/lower) eq 'unix'

if n_elements(file) eq 1 then file=file(0)
if trim2(file) eq '' then return,file

cd,current=cdir
cfile=chklog(file,/pres)

;-- strip off file name (ensure that delimiters are appropriate for OS)

local_delim=get_delim()
cfile=str_replace(cfile,'/',local_delim)

break_file, cfile, disk, direc, name, ext, vers
dirnam=disk+direc
dirnam=chklog(dirnam,/pres)
filnam=name+ext+vers

;-- expand path delimiters

have_path=is_string(path)
if have_path then begin
 path_in=chklog(path,/pres,/full)
 tpath=str_expand(path_in,verbose=verbose)
endif

case 1 of

 (dirnam(0) eq '') and (not have_path): dpath=cdir

 (dirnam(0) ne '') and (not have_path): dpath=dirnam

 (dirnam(0) ne '') and (have_path): dpath=[dirnam,tpath]

 (dirnam(0) eq '') and (have_path): dpath=tpath

 else: begin
  err='Do not understand request'
  if verbose then message,err,/cont
  return,file
 end
endcase

fname=''
ndir=n_elements(dpath)
ppath=''
for i=0,ndir-1 do begin
 bpath=dpath(i)
 if bpath ne ppath then begin           ;-- avoid searching twice

  if not vms then bpath=chklog(bpath,/pres)
  bname=concat_dir(bpath,filnam)

;-- translate logicals in disk and directory names

  cdir=chklog(bpath,/pres)
  cdir=cdir(0)
  cdir=str_replace(cdir,'/',local_delim)
  break_file,cdir,dsk,dirc
  cdsk=chklog(dsk,/pres)
  cdir=chklog(dirc,/pres)

;-- look for odd characters in dir/file name

  wild=strpos(filnam(0),'*')
  quest=strpos(filnam(0),'?')
  ditto1=strpos(cdsk(0),'...')
  ditto2=strpos(cdir(0),'...')
  node=strpos(cdsk(0),'::')

  if (wild eq -1) and (quest eq -1) and (ditto1 eq -1) and (ditto2 eq -1) $
   and (node eq -1) then begin
   chk=test_open(bname,/nodir)
   if chk then begin count=1 & go_find=bname & endif else count=0
  endif else begin
   if strpos(bpath,'~') gt -1 then bpath=expand_tilde(bpath)     
   bname=concat_dir(bpath,filnam)
   go_find=findfile(bname,count=count)

;-- kluge for UNIX case where FINDFILE can't expand more than
;   about 310 files

   if (count eq 0) and unix and recheck then begin
    dprint,'% LOC_FILE: rechecking...',/cont
    if is_dir(bpath) then begin
     cd,current=curr,bpath               
     espawn,'ls ',all
     expr=str_replace(filnam,'*','.*')
     chk=call_function('stregex',all,expr,/bool)
     ok=where(chk,count)
     if count gt 0 then go_find=all(ok)
     cd,curr
    endif
    if count gt 0 then go_find=concat_dir(bpath,go_find)
   endif
  endelse
  
  if count ne 0 then begin
   if fname(0) eq '' then fname=go_find else fname=[temporary(fname),go_find]
   if loc(0) eq '' then loc=bpath else loc=[temporary(loc),bpath]
   if not keyword_set(all) then goto,jump
  endif
 endif
 ppath=bpath
endfor

jump: if fname(0) eq '' then count=0 else count=n_elements(fname)
if n_elements(fname) eq 1 then fname=fname(0)

if count eq 0 then begin
 err=file+' not found'
 if verbose then message,err,/cont
endif

return,fname

end
