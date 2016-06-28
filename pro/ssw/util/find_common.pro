;+
; Project     : SOHO - CDS     
;                   
; Name        : FIND_COMMON()
;               
; Purpose     : Find which elements are common to the input vectors.
;               
; Explanation : Returns the indices of the elements in second vector which
;               are also present in the first vector.
;               
; Use         : IDL> c = find_common(first, second)
;    
; Inputs      : first  -  vector to be searched
;               second -  search vector
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns indices of elements in second vector which
;               are common to first and second vectors
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : FIND_DUP()
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 9-Nov-94
;               
; Modified    : Make loop variable LONG.  CDP, 1-Oct-97
;
; Version     : Version 2, 1-Oct-97
;-            

function find_common, x, y

;
;  check input 
;
if n_params() lt 2 then begin
   print,'Use: c = find_common(first, second)'
   return, -1
endif

;
;  vectors only
;
if (size(x))(0) ne 1 or (size(y))(0) ne 1 then begin
   print,'Input parameters must be vectors.'
   return, -1
endif

;
;  search for occureences of the values of the first vector
;
n = -1
for i=0L,n_elements(x)-1 do begin
   n = [n,where(y eq x(i))]
endfor
nn = where(n ge 0)

;
;   if none, clean exit
;
if nn(0) eq -1 then return,-1

;
;  else return indices in second vector
;
n = n(nn)
n = n(sort(n))
return, n(rem_dup(n))

end
