;+
; Project     : SOHO - CDS     
;                   
; Name        : LOCATE_VAL()
;               
; Purpose     : Locates a particular value in a vector or array.
;               
; Explanation : Searches a vector (trivial) or array and returns the 
;               coordinates of a specified value. cf GET_IJ()
;               
; Use         : IDL> print,locate_val(array [,value, /max, /min, range=range])
;    
; Inputs      : array - 2-d array to be searched
;               
; Opt. Inputs : value - the numerical value to be located.
;               
; Outputs     : Function returns (array of) (x,y) locations of the pixel.
;               
; Opt. Outputs: None
;               
; Keywords    : TOP     - search for maximum of array
;               BOTTOM  - search for minimum of array
;               RANGE   - error allowed on value searched for
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: Only on 1 or 2-d arrays at moment
;               
; Side effects: None
;               
; Category    : Util, numerical, array
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 27-Jul-95
;               
; Modified    : 
;
; Version     : Version 1, 27-Jul-95
;-            

function locate_val, array, value, top=top, bottom=bottom, range=range

;
;  check parameters
;
if n_params() eq 0 then begin
   print,'Use: IDL> n = locate_val(array [,value, /top, /bottom])
   return,0
endif

if n_elements(array) le 1 then begin
   print,'Use: IDL> n = locate_val(array [,value, /top, /bottom])
   print,'First parameter must be 1-d or 2-d'
   return,0
endif

if (n_params() eq 1) and (not keyword_set(top)) and $
                         (not keyword_set(bottom)) then begin
   print,'Use: IDL> n = locate_val(array [,value, /top, /bottom])
   print,'Must supply value or keyword'
   return,0
endif

;
; set up range of values to be located
;
case 1 of
   keyword_set(top):    begin
                           value1 = max(array)
                           value2 = max(array)
                        end
  
   keyword_set(bottom): begin
                           value1 = min(array)
                           value2 = min(array)
                        end
   n_elements(value) gt 0: begin
                              if n_elements(range) eq 0 then range = 0.0
                              value1 = value - range
                              value2 = value + range
                           end
                     else: return,-1
endcase

;
;  handle 1-d and 2-d cases
;
s = size(array)
if s(0) eq 1 then begin
   return,where((array ge value1) and (array le value2))
endif else begin
   n = where((array ge value1) and (array le value2))
   if n(0) eq -1 then return,n(0)
   out = intarr(2,n_elements(n))
   for i=0,(n_elements(n))-1 do begin
      out(1,i) = n(i)/s(1)
      out(0,i) = n(i) - out(1,i)*s(1)
   endfor
endelse

;
;  return 2-d array of (x,y) coordinates
;
return,out
end
