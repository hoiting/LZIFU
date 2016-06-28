;+
; Project     : HESSI
;
; Name        : MK_LINK
;
; Purpose     : Link file(s) to a directory
;
; Explanation : Uses spawn,'ln -s'
;
; Category    : utility system io
;
; Syntax      : IDL> link_file,file,dir
;
; Inputs      : FILE = file name(s) to link
;               DIR = dir name in which to link
;
; Keywords    : OUT = spawn error string
;
; History     : 15-March-2000,  D.M. Zarro (SM&A).  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro mk_link,file,dir,out=out,verbose=verbose

verbose=keyword_set(verbose)
quiet=1-verbose
if os_family() ne 'unix' then begin
 message,'Unix only',/cont
 return
endif

if (not is_string(file)) or (not is_string(dir)) or $
   (n_elements(dir) ne 1) then begin
 pr_syntax,'mk_link,file,dir'
 return
endif

if (not test_dir(dir,out=ndir,quiet=quiet)) then return

;-- check for valid files

nfile=loc_file(file,count=count,err=err)
if count eq 0 then begin
 message,err,/cont
 return
endif

break_file,nfile,fdsk,fdir,fname,fext
fdir=trim(fdsk+fdir)
fname=trim(fname+fext)   

;-- only link existing files that aren't already linked

for i=0,count-1 do begin
 chk=loc_file(fname(i),path=ndir,count=count1)
 if (count1 eq 0) then begin
  lcmd='ln -sf '+nfile(i)+' '+ndir
  cmd=append_arr(cmd,lcmd,/no_copy)
 endif
endfor

if not exist(cmd) and verbose then begin
 message,'input files already linked',/cont
 return
endif

;-- spawn link commands 

if verbose then message,'creating links...',/cont
espawn,cmd,out,/noshell

return & end

