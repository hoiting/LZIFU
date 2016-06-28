;+
; Project     :	SOHO - CDS
;
; Name        :	REM_COM()
;
; Purpose     :	Finds elements unique to second vector.
;
; Explanation :	Returns indeces of all those elements which are unique to the second vector,
;               removing any duplicate elements or any that are also present in the first 
;               vector.
;
; Use         : <indeces = rem_com( vec1, vec2)>
;
; Inputs      : vec1 = array of values;
;               vec2 = array of values.
;
; Opt. Inputs : None.
;
; Outputs     : Array of indeces into vec2 poitnign to unique elements.
;
; Opt. Outputs:	None.
;
; Keywords    : None.
;
; Calls       :	rem_dup.
;                
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Command preparation.
;
; Prev. Hist. :	None.
;
; Written     :	Version 0.00, Martin Carter, RAL, 14/10/94
;
; Modified    :	Version 0.01, Martin Carter, RAL, 28/11/94
;                            Added proforma.
;
; Version     :	Version 0.01, 28/11/94
;-
;**********************************************************

FUNCTION rem_com, vec1, vec2   

  ; get indeces of non-common items in vec2

  ; get list of indeces of unique items in concatenated vector

  indeces_0 = rem_dup([vec1, vec2])

  ; get indeces of indeces in second part of concatenated vector 
  ; NB rem_dup chooses first index of similar items

  indeces_1 =  WHERE ( indeces_0 GE N_ELEMENTS(vec1) ) 

  ; check if any items       

  IF indeces_1(0) GE 0 THEN BEGIN

    ; get list of indeces in second part of concatenated vector 

    indeces_1 = indeces_0(indeces_1)

    ; get list of indeces in vec2 

    indeces_1 = indeces_1 - N_ELEMENTS(vec1)

  ENDIF

  RETURN, indeces_1

END
