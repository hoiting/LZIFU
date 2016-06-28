;+
; Project     : SOHO - CDS     
;                   
; Name        : DIMREFORM
;               
; Purpose     : As reform, but dimensions supplied as an array
;               
; Explanation : With REFORM, the number of dimensions is hardcoded into the
;               function call.  This function takes an array with the sizes of
;               the dimensions of the result, and performs a REFORM call with
;               the correct number of dimensions.
;               
; Use         : array = DIMREFORM(ARRAY,DIMENSIONS)
;    
; Inputs      : ARRAY : the array to be reformed.
;
;               DIMENSIONS : The dimensions of the result. As with reform, the
;                            number of elements in the result must be the same
;                            as the number of elements in the input array.
;               
; Opt. Inputs : None.
;               
; Outputs     : Returns reformed array
;               
; Opt. Outputs: None.
;               
; Keywords    : OVERWRITE : As in REFORM
;
; Calls       : None.
;
; Common      : None.
;               
; Restrictions: Assumes sensible input
;               
; Side effects: None.
;               
; Category    : Array utility
;               
; Prev. Hist. : None.
;
; Written     : S. V. H. Haugan, UiO, 10 January 1997
;               
; Modified    : Not yet
;
; Version     : 1, 10 January 1997
;-            
FUNCTION dimreform,array,dimensions,overwrite=overwrite
  
  ovw = keyword_set(overwrite)
  
  d = dimensions
  
  CASE n_elements(dimensions) OF
     1: return,reform(array,d(0),overwrite=ovw)
     2: return,reform(array,d(0),d(1),overwrite=ovw)
     3: return,reform(array,d(0),d(1),d(2),overwrite=ovw)
     4: return,reform(array,d(0),d(1),d(2),d(3),overwrite=ovw)
     5: return,reform(array,d(0),d(1),d(2),d(3),d(4),overwrite=ovw)
     6: return,reform(array,d(0),d(1),d(2),d(3),d(4),d(5),overwrite=ovw)
     7: return,reform(array,d(0),d(1),d(2),d(3),d(4),d(5),d(6),overwrite=ovw)
     8: return,reform(array,d(0),d(1),d(2),d(3),d(4),d(5),d(6),d(7),$
                      overwrite=ovw)
  END
END
