;+
; Project     : SOHO - CDS
;
; Name        : NUMCHAR()
;
; Purpose     : Count all appearances of a character in a string.
;
; Explanation : Count all appearances of character (char) in string (st).
;
; Use         : IDL> nc = numchar(st,char)
;
; Inputs      : ST  - String (array) from which character will be removed.  
;               CHAR- Character to be removed from string. 
;
; Opt. Inputs : None.
;
; Outputs     : Function returns the number of occurrences.
; 
; Opt. Outputs: None 
;	
; Keywords    : None
;	
; Calls       : None
;	
; Common      : None
;
; Restrictions: None
;	
; Side effects: None
;	
; Category    : Utilities, strings.
;
; Prev. Hist. : Based on REMCHAR
;
; Written     : C D Pike, RAL 4-Jun-97
;
; Modified    : 
;
; Version     : Version 1, 4-Jun-97
;-
;
function numchar,st,char

n = n_elements(st)
out = intarr(n)
for i=0,n-1 do begin
   bst = byte(st(i))                                 ;Convert string to byte
   bchar = byte(char) & bchar = bchar(0)          ;Convert character to byte
   good = where(bst eq bchar,ngood)
   out(i) = ngood
endfor

return, out
end
