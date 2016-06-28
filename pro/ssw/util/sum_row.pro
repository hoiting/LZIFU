;+
; Project     : SOHO - CDS     
;                   
; Name        : SUM_ROW()
;               
; Purpose     : Sums along the rows of a matrix.
;               
; Explanation : Sums along the rows of a matrix.
;               
; Use         : row = sum_row(array)
;    
; Inputs      : array  -  the array to be row-summed
;               
; Opt. Inputs : None
;               
; Outputs     : None
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
; Category    : Util, arrays
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 4-Jan-94
;               
; Modified    : 
;
; Version     : Version 1, 4-Jan-94
;-         

function sum_row, array

;
;  matrix operation to perform summation
;
line  = replicate(1,n_elements(array(*,0)))#array

;
;  return vector
;
return,line(0:*)

end
