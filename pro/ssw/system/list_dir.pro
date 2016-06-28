;+
; Project     : EIS
;
; Name        : LIST_DIR
;
; Purpose     : fast directory listing
;
; Category    : utility system
;
; Syntax      : IDL> dirs=ls_dir(indir)
;
; Inputs      : INDIR = directory to search
;
; Outputs     : DIRS = directories in INDIR
;
; Keywords    : COUNT = # of directories found
;
; History     : Written, 29 April 2003, D. Zarro (L-3Com/GSFC)
;               Modified, 3 March 2007, Zarro (ADNET)
;               - improved error checking
;
; Contact     : dzarro@solar.stanford.edu
;-

function list_dir,dir,count=count,err=err

forward_function file_test

err=''
count=0
if is_blank(dir) then begin
 err='directory name not entered'
 message,err,/cont
 return,''
endif

if not is_dir(dir,out=odir,/expand) then begin
 err='invalid directory - '+odir
 message,err,/cont
 return,''
endif

;-- Windows case first

odir=strtrim(odir,2)
if os_family(/lower) ne 'unix' then begin
 endslash=stregex(odir,'\\$',/bool)
 if endslash then sdir=odir+'*' else sdir=odir+'\*'
 results=findfile(sdir,count=count)
 if count eq 0 then return,''
 dirs=str_trail(results,'\\',count=count,match=match)
 if count eq 0 then return,''
 results=dirs[match]
 chk=where2(stregex(results,'(\\\.+\\?)$',/bool),ncomplement=count,complement=complement)
 if count eq 0 then return,''
 if n_elements(complement) ne n_elements(results) then results=results[complement]
 chk=where(file_test(results,/dir),count)
 if count eq 0 then return,'' 
 if count eq 1 then chk=chk[0]
 return,results[chk]
endif

;-- Unix case

cd,current=current
cd,odir
cmd='\ls -F'
espawn,cmd,/noshell,results,count=count
cd,current

if count eq 0 then return,''
if odir eq '/' then odir=''
dirs=odir+'/'+temporary(strtrim(results,2))
results=str_trail(dirs,'\/|@',count=count,match=match)
if count eq 0 then return,''
if count ne n_elements(dirs) then results=results[match]
chk=where(file_test(results,/dir),count)
if count eq 0 then return,'' 
if count eq 1 then chk=chk[0]
return,results[chk]

end


