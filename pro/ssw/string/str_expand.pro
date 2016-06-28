;+
; Project     : HESSI
;                  
; Name        : STR_EXPAND
;               
; Purpose     : Expand delimited string into an array.
;               Like STR2ARR but delimiter is OS dependent, and
;               input can be vector. Will also recursively expand '+'.
;                             
; Category    : string system utility
;               
; Syntax      : IDL> a=str_expand(b)
;                (e.g. b='test1:test2:test3' 
;                      a=['test1','test2','test3']
;
; Inputs      : B = string to expand
;               
; Outputs     : A = expanded string
;               
; Keywords    : VERBOSE = set for messaging
;               
; History     : Written, 28-May-2000, Zarro (EIT/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    


function str_expand,path,verbose=verbose

if not exist(path) then return,-1
if datatype(path) ne 'STR' then return,path
verbose=keyword_set(verbose)

spath=path 

;-- first expand delimiters

delim=get_path_delim()
have_delim=strpos(spath,delim) gt -1
chk=where(have_delim,count)

if count gt 0 then begin
 if verbose then message,'expanding delimiter "'+delim+'"',/cont
 npath=n_elements(spath)
 for i=0,npath-1 do begin
  apath=spath(i)
  if have_delim(i) then apath=str2arr(apath,delim=delim)
  new_path=append_arr(new_path,apath,/no_copy) 
 endfor
 spath=new_path
endif

;-- next expand '+'

have_plus=strpos(spath,'+') gt -1
chk=where(have_plus,count)
if count gt 0 then begin
 if verbose then message,'expanding "+" sign',/cont
 for i=0,count-1 do spath(chk(i))=expand_path( spath(chk(i)) )
endif

;-- finally expand new delimiters that may have appeared after expanding '+'

have_delim=strpos(spath,delim) gt -1
chk=where(have_delim,count)
if count gt 0 then spath=str_expand(spath,verbose=verbose)

if n_elements(spath) eq 1 then spath=spath(0)

return,spath
end

