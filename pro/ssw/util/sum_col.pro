;+
; Project     : SOHO - CDS     
;                   
; Name        : SUM_COL()
;               
; Purpose     : Sums along the columns of a matrix.
;               
; Explanation : Sums along the columns of a matrix.
;               
; Use         : col = sum_col(array)
;    
; Inputs      : array  -  the array to be column-summed
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

function sum_col, array

;
;  return result of matrix operation to perform summation
;
return, array#replicate(1,n_elements(array(0,*)))

end
