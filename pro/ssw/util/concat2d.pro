;+
; Project     : SOHO - CDS     
;                   
; Name        : CONCAT2D()
;               
; Purpose     : Concatenate two or more 2-d arrays.
;               
; Explanation : Concatenate two or more 2-d arrays to produce one output array.
;               eg if a  = intarr(20,25)
;                     b  = intarr(20,2)
;                     c  = intarr(20,27)  then 
;
;                 x = concat3d(a,b,c) will return an array of dimensions (20,54) 
;               
; Use         :  IDL>  x = concat2d(a,b [,c,d,e]  (max of 5 input arrays)
;    
; Inputs      :  a,b,c...   input 2-d arrays, the first dimensions of which must
;                           be the same size.
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
; Restrictions: First dimensions of input arrays must be the same.
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

function concat2d, a, b, c, d, e

n = n_params()

if n_params() lt 2 then begin
   print,'Use:  array = concat2d(a,b [,c,d,e])'
   return,0
endif

;
;  collect details of dimensions
;
s0 = intarr(n)
s1 = intarr(n)

s = size(a)
s0(0) = s(0)
s1(0) = s(1)

s = size(b)
s0(1) = s(0)
s1(1) = s(1)

if n ge 3 then begin
   s = size(c)
  s0(2) = s(0)
  s1(2) = s(1)
endif

if n ge 4 then begin
  s = size(d)
  s0(3) = s(0)
  s1(3) = s(1)
endif

if n ge 5 then begin
  s = size(e)
  s0(4) = s(0)
  s1(4) = s(1)
endif


;
;  check inputs are 2-d
;
if s0(0) ne 2 or n_elements(uniq(s0)) ne 1 then begin
   print,'CONCAT2D: all inputs must be 2-dimensional arrays.'
   return,0
endif

;
;  check first dimension agrees, if they do concatenate arrays
;
if n_elements(uniq(s1)) ne 1  then begin
   print,'CONCAT2D: First dimension of input arrays is not the same.'
   return,0
endif else begin
   case n of
      2: return,[[a],[b]]
      3: return,[[a],[b],[c]]
      4: return,[[a],[b],[c],[d]]
      5: return,[[a],[b],[c],[d],[e]]
      else: return,0
   endcase
endelse

end
