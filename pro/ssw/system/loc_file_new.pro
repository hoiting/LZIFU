;+
; Project     : HESSI
;                  
; Name        : LOC_FILE_NEW
;               
; Purpose     : new improved LOC_FILE that uses FILE_SEARCH 
;                             
; Category    : system utility
;               
; Syntax      : IDL> a=loc_file_new(file)
;
; Inputs:     : FILE = file names to search (scalar or array) 
;
; Outputs     : The result of the function is an array containing the names of 
;               all files found.
; Keywords    : 
;       PATH    = Array or scalar string with names of directories to search.
;       COUNT   = Number of found files.
;       ALL     = If set, then search all directories.  Otherwise, the
;                 procedure stops as soon as a match is found.
;               
; Restrictions: Needs IDL version > 5.4
;               
; Side effects: None
;               
; History     : Written, 8-Nov-2002, Zarro (EER/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

function loc_file_new,file,path=path,all=all,count=count,$
                      verbose=verbose,err=err,_extra=extra

forward_function file_search
count=0 & err=''
verbose=keyword_set(verbose)

if not since_version('5.5') then begin
 err='Requires version > 5.4' 
 message,err,/cont
 return,''
endif

sz=size(file)
dtype=sz[n_elements(sz)-2]
if dtype ne 7 then return,''

;-- check if user entered a search path

np=1 
tpath=''
delim=get_delim()

if is_string(path) then begin
 tfile=file_break(file)
 tpath=strtrim(path,2)
 np=n_elements(tpath)
endif 

for i=0,np-1 do begin
 if tpath[i] eq '' then sfile=strtrim(file,2) else $
  sfile=tpath[i]+delim+strtrim(tfile,2)
 temp=file_search(sfile,/fully,/nosort,count=tcount)
 if tcount gt 0 then begin
  if (not keyword_set(all))  then begin
   count=tcount 
   if count eq 1 then temp=temp[0]
   return,temp
  endif
  if exist(rfile) then rfile=[temporary(rfile),temp] else sfile=temp
 endif
endfor
count=n_elements(rfile)
if count eq 1 then rfile=rfile[0]
if  (count eq 0) then begin
 rfile=''
 if verbose then message,'Search files not found',/cont
endif

return,rfile
 
end
