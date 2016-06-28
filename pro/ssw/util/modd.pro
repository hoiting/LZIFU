;+
; NAME: modd
;
; PURPOSE: calculate a modulus
;
; CALLING SEQUENCE:  out=modulus(num,mod)
;
;    mod should be an integer
;    num can be anything, but the limit for integers is ~32700 < 512x512
;                                      
;
; HISTORY: drafted apr. 1992, A. McAllister
;-
FUNCTION  modd,num,modn

modul=num-long(fix(num/modn))*modn

return,modul

end