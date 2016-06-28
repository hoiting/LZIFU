;+
; Project     : SOHO - CDS     
;                   
; Name        : ARRAY_XOR()
;               
; Purpose     : Returns the XOR elements of two arrays.
;               
; Explanation : Given 2 arrays it returns an array containing the elements
;               that are in either array but not both.
;               
; Use         : IDL> x = [0,1,2,3,4,8]
;               IDL> y = [2,3,4,9]
;               IDL> print,array_xor(x,y)   -->  0 1 8 9
;    
; Inputs      : x,y  - two arrays (any type ecept complex and structure)
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns exclusive array
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : FIND_COMMON, REST_MASK
;
; Common      : None
;               
; Restrictions: Input arrays must be same type
;               
; Side effects: None
;               
; Category    : Util
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL.  22-Apr-97
;               
; Modified    : 
;
; Version     : Version 1, 22-Apr-97
;-            

function  array_xor,x,y

n1 = find_common(x,y)
n2 = find_common(y,x)

if datatype(x) eq 'STR' then begin
   if n1(0) ge 0 and n2(0) ge 0 then begin
      xrm = rest_mask(x,find_common(y,x))
      yrm = rest_mask(y,find_common(x,y))
      if xrm(0) gt -1 then outx = x(xrm) else outx = ''
      if yrm(0) gt -1 then outy = y(yrm) else outy = ''
      out = [outx,outy]
      out = out(where(out ne ''))
      out = out(rem_dup(out))
      return,out
   endif else begin
      return,[x,y]
   endelse
endif else begin
   if n1(0) ge 0 and n2(0) ge 0 then begin
      xrm = rest_mask(x,find_common(y,x))
      yrm = rest_mask(y,find_common(x,y))
      if xrm(0) gt -1 then outx = x(xrm) 
      if yrm(0) gt -1 then outy = y(yrm)
      case 1 of
         n_elements(outx) gt 0 and n_elements(outy) gt 0: out = [outx,outy]
         n_elements(outx) gt 0: out = outx
         n_elements(outy) gt 0: out = outy
         else: help,outx,outy
      endcase
      out = out(rem_dup(out))
      return,out
   endif else begin
      return,[x,y]
   endelse
endelse
end
