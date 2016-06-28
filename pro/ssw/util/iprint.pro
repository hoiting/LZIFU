;+
; Project     : SOHO - CDS
;
; Name        : IPRINT
;
; Purpose     : Print array with counter, e.g. 1) value
;
; Category    : Utility
;
; Explanation : 
;                            
; Syntax      : IDL> iprint,array
;
; Inputs      : ARRAY = array to print
;
; Opt. Inputs : PAGE = no of lines per page
;
; Outputs     : Terminal output

; Opt. Outputs: None
;
; Keywords    : None
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  25-May-1997,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


pro iprint,a,page

if datatype(a) eq 'STC' then return
if not exist(page) then page=20 else page=page > 1
for i=0l,n_elements(a)-1 do begin
 chk=(i mod page)
 if (chk eq 0) and (i ne 0) then begin
  print,'Enter Q to quit, else continue...'
  ans='' & read,ans
  if strupcase(ans) eq 'Q' then return
 endif
 print,i,') ',a(i)
endfor
return & end
