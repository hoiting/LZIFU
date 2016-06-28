;+
; Project     : SOHO - CDS     
;                   
; Name        : CHECK_CONFLICT
;               
; Purpose     : To check any conflict of IDL procedure/function names.
;               
; Explanation : All .pro file names in the CDS IDL path are checked for 
;               duplicate names.
;               
; Use         : check_conflict, list [,/quiet, /full]
;    
; Inputs      : None
;               
; Opt. Inputs : None
;               
; Outputs     : None 
;               
; Opt. Outputs: list  -  contains a list of any duplicates found.  
;               
; Keywords    : quiet - if present results are not output on terminal (except
;                       if /full is given, that overrides /quiet for the extra
;                       information.
;
;               full  - if present, complete information (ie the result
;                       of running PURPOSE on each duplicate file is written
;                       to the screen.
;
; Calls       : PURPOSE
;               FIND_DUP
;               REMCHAR
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Doc
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 12-Nov-93
;               
; Modified    : 
;
; Version     : Version 1, 12-Nov-93
;-            

pro check_conflict, out_list, quiet=quiet, full=full

;
;  create a list of the one-liner documentation which contains all the file
;  names.
;
purpose,list=list,/path,/quiet

;
;  pick out just the file names and convert to lower case, just in case
;
list = strlowcase(strmid(list,0,17))

;
;  remchar won't handle arrays so get rid of () in function names 
;  individually
;
for i=0,n_elements(list)-1 do begin
   x = list(i)
   remchar,x,'(' & remchar,x,')'
   list(i) = x
endfor

;
;  form the output list but return if nothing was found
;
temp = find_dup(list)
if temp(0) ge 0 then begin
   out_list = list(temp)
endif else begin
   if not keyword_set(quiet) then print,'** No name conflicts found. **'
   out_list = ''
   return
endelse

;
;  report on line if not silenced
;
if not keyword_set(quiet) then begin
   print,' '
   print,'The following duplicate files were found in the CDS directories:'
   print,' '
   for i=0,n_elements(out_list)-1 do print,out_list(i)
endif   

;
;  if full was requested then redo a PURPOSE for each duplicate
;
if keyword_set(full) then begin
   for i=0,n_elements(out_list)-1 do begin
      purpose,strtrim(out_list(i),2),/path
   endfor
endif

end
