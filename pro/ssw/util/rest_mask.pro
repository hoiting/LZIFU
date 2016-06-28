;
FUNCTION REST_MASK, array, subindex
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       REST_MASK()
;
; PURPOSE: 
;       Return the index excluding those given in SUBINDEX.
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       Result = REST_MASK(array, subindex)
;
; INPUTS:
;       ARRAY    -- An array of any kind of data type
;       
;       SUBINDEX -- Integer vector containing indices which will be excluded
;                   from ARRAY
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT   -- Indices of ARRAY with SUBINDEX excluded
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       None.
;
; CALLS:
;       DATATYPE
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Written October 19, 1994, by Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Change test when string array is input.  CDP, 23-Apr-97
;       Version 3, SVHH, 23 April 1997
;               New algorithm, independent of data type (works for
;               NaN values as well).
;
; VERSION:
;       Version 3, 23 April 1997
;-
;
   ON_ERROR, 2
   IF N_PARAMS() NE 2 THEN MESSAGE, 'Syntax: Result=rest_mask(index, subindex)'
   
   ;; There could be identical entries in subindex, so the following could
   ;; give wrong results:
   ;; IF N_ELEMENTS(subindex) GE N_ELEMENTS(array) THEN RETURN, -1
   
   ;; Make logical array
   
   new_array = make_array(/byte,n_elements(array),value=1b)
   
   ;; Punch out all those mentioned in subindex
   
   new_array(subindex) = 0b
   
   ;; Return index of remaining nonzero entries
   return,where(new_array)
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'rest_mask.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
