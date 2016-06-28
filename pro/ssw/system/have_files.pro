;+
; Project     : HESSI
;                  
; Name        : HAVE_FILES
;               
; Purpose     : given a directory and a set of filenames, return
;               the names of files aleady in directory
;                             
; Category    : system utility
;               
; Syntax      : IDL> ofile=have_files(ifile,dir)
;
; Inputs      : IFILE = list of filenames to check for
;               DIR = directory name to check [def=current]
;                                   
; Outputs     : OFILE = list of matching files (blank if no matches)
;               
; Keywords    : INDEX = indices of matching files
;               MISSING = list of filenames not in directory
;               COUNT = # of matches found
;               MCOUNT = # of non-matches
;               
; History     : Written, 22-Dec-1999, Zarro (SM&A/GSFC)
;               Modified, 28-Dec-2003, Zarro (L3Com/GSFC)
;                - changed directory default
;
; Contact     : dzarro@solar.stanford.edu
;-    

function have_files,ifile,dir,index=index,count=count,missing=missing,$
                    mcount=mcount

ofile=''
count=0l
index=-1l
missing=''
mcount=0l

if is_blank(ifile) then begin
 pr_syntax,'ofile=have_files(file,dir [,index=index,count=count])'
 return,''
endif


if is_dir(dir,out=odir) then iname=concat_dir(odir,file_break(ifile)) else $
 iname=ifile

;-- now search for them in dir

for i=0,n_elements(iname)-1 do begin
 chk=loc_file(iname[i],count=ocount)
 if ocount gt 0 then begin
  tfile=append_arr(tfile,chk)
  tindex=append_arr(tindex,i)
 endif else mfile=append_arr(mfile,ifile[i])
endfor

count=n_elements(tfile)
if count gt 0 then begin
 ofile=tfile & index=tindex
endif

mcount=n_elements(mfile)
if mcount gt 0 then missing=mfile

return,ofile

end
