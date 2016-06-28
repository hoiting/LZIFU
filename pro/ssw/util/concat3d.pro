;+
; Project     : SOHO - CDS     
;                   
; Name        : CONCAT3D()
;               
; Purpose     : Concatenate two or more 3-d arrays.
;               
; Explanation : Concatenate two or more 3-d arrays to produce one output array.
;               eg if a  = intarr(20,25,10)
;                     b  = intarr(20,25,12)
;                     c  = intarr(20,25,5)  then 
;
;                 x = concat3d(a,b,c) will return an array of dimensions (20,25,27) 
;               
; Use         :  IDL>  x = concat3d(a,b [,c,d,e]  (max of 5 input arrays)
;    
; Inputs      :  a,b,c...   input 3-d arrays, the first 2 dimensions of which must
;                           have the same size.
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns the concatenation.
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: First 2 dimensions of input arrays must be the same.
;               
; Side effects: None
;               
; Category    : Util, array
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 13-May-94
;               
; Modified    : 
;
; Version     : Version 1,  13-May-94 
;-            

function concat3d, a, b, c, d, e

n = n_params()

if n_params() lt 2 then begin
   print,'Use:  array = concat3d(a,b [,c,d,e])'
   return,0
endif

;
;  collect details of dimensions
;
s0 = intarr(n)
s1 = intarr(n)
s2 = intarr(n)

s = size(a)
s0(0) = s(0)
s1(0) = s(1)
s2(0) = s(2)
s = size(b)
s0(1) = s(0)
s1(1) = s(1)
s2(1) = s(2)

if n ge 3 then begin
   s = size(c)
  s0(2) = s(0)
  s1(2) = s(1)
  s2(2) = s(2)
endif

if n ge 4 then begin
  s = size(d)
  s0(3) = s(0)
  s1(3) = s(1)
  s2(3) = s(2)
endif

if n ge 5 then begin
  s = size(e)
  s0(4) = s(0)
  s1(4) = s(1)
  s2(4) = s(2)
endif


;
;  check inputs are 3-d
;
if s0(0) ne 3 or n_elements(uniq(s0)) ne 1 then begin
   print,'CONCAT3D: all inputs must be 3-dimensional arrays.'
   return,0
endif

;
;  check first 2 dimensions agree, if they do concatenate arrays
;
if n_elements(uniq(s1)) ne 1 or n_elements(uniq(s2)) ne 1 then begin
   print,'CONCAT3D: First 2 dimensions of input arrays are not the same size.'
   return,0
endif else begin
   case n of
      2: return,[[[a]],[[b]]]
      3: return,[[[a]],[[b]],[[c]]]
      4: return,[[[a]],[[b]],[[c]],[[d]]]
      5: return,[[[a]],[[b]],[[c]],[[d]],[[e]]]
      else: return,0
   endcase
endelse

end
