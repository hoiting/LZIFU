function make_into_bytarr, in0, swap_lendian=swap_lendian
;+
;   Name: make_into_bytarr
;
;   Purpose: convert input to byte array  
;
;   Input:
;      in0 - input   data  
;
;   Output:
;      function returns byte version
;   Keyword Parameters:
;      swap_lendian - if litte endian and keyword set, then swap  
;
;   History:
;      ~ 1-Jan-1998 - Mons Morrison
;       16-Jun-1998 - S.L.Freeland - add /SWAP_LENDIAN keyword and function
;-

if (n_elements(in0) eq 0) then return, out	;undefined
in=in0

if is_lendian() and keyword_set(swap_lendian) then dec2sun,in

n1 = n_elements(in(*,0))
n2 = n_elements(in(0,*))
out = byte(in, 0, n1*2, n2)	;hardwrired to integer*2 input for now
;

return, out
end
