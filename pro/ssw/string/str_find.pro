;+
; Project     : HESSI
;
; Name        : STR_FIND
;
; Purpose     : find matches in an array of strings
;
; Category    : string utility
;                   
; Inputs      : INPUT = array of strings to search
;               PATT = string pattern to match (e.g. '*fits')
;
; Outputs     : Match results
;
; Keywords    : CASE_SENS: set for case sensitive match (def = no case)
;               COUNT = # of matched
;
; History     : 27-Dec-2001,  D.M. Zarro (EITI/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function str_find,input,patt,count=count,case_sens=case_sens

count=0
sz=size(input)
if sz(n_elements(sz)-2) ne 7 then return,''
sz=size(patt)
err='input pattern must be non-blank string'
if (sz(n_elements(sz)-2) ne 7) then begin
 message,err,/cont
 return,''
endif

if (strtrim(patt[0],2) eq '') then begin
 message,err,/cont
 return,''
endif

if (strtrim(patt[0],2) eq '*') then return,input

tpatt=str_replace(patt,'*','[^ ]*')
if n_elements(tpatt) gt 1 then tpatt='['+arr2str(tpatt,delim='|')+']'
chk=stregex(input,tpatt,/bool,fold_case=case_sens)
ok=where(chk gt 0,count)
if count gt 0 then return,comdim2(input[ok]) else return,''
          
end

