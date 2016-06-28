;---------------------------------------------------------------------------
; Document name: get_uniq_list.pro
; Created by:    Liyun Wang, GSFC/ARC, May 22, 1995
;
; Last Modified: Wed May 24 11:25:01 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION get_uniq_list, str_array,sensitive=sensitive,original=original
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:	
;       GET_UNIQ_LIST()
;
; PURPOSE:
;       Extract uniq list of string values from a string array
;
; EXPLANATION:
;       This routine examines all elements of a string array, sorts
;       these values, gets rid of repeated values and return a new
;       string array with uniq values in a sorted order.
;
; CALLING SEQUENCE: 
;       Result = get_uniq_list(str_array)
;
; INPUTS:
;       STR_ARRAY - String array to work with
;
; OPTIONAL INPUTS: 
;       ORIGINAL - Original list
;
; OUTPUTS:
;       RESULT      - Extracted string from STR_ARRAY or from input
;       SENSITIVE   - make search case sensitive 
;                [e.g. 'TEST' and 'test' will be different]
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       None.
;
; CALLS:
;       GREP, DATATYPE
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
;       Written May 22, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, GSFC/ARC, May 22, 1995
;       Version 2, modified, Zarro, ARC, June 6, 1996 --
;         added /SENSITIVE and protected input STR_ARRAY
;
; VERSION:
;       Version 1, May 22, 1995
;-
;
   ON_ERROR, 2

   sensitive=KEYWORD_SET(sensitive)
   
   IF datatype(str_array) NE 'STR' THEN BEGIN
      MESSAGE, 'Invalid input data type.', /cont
      RETURN, -1
   ENDIF
   
   new_array=str_array
   IF N_ELEMENTS(original) NE 0 THEN new_array = [new_array, original]
   new_array = STRTRIM(new_array,2)
   ii = WHERE(new_array NE '')
   IF ii(0) NE -1 THEN new_array = new_array(ii)
   IF N_ELEMENTS(new_array) GT 1 THEN BEGIN
    if sensitive then buff=new_array else buff=strlowcase(new_array)
    uniq_idx = uniq(buff, SORT(buff))
    new_array = new_array(uniq_idx)
   ENDIF
   RETURN, new_array
END

;---------------------------------------------------------------------------
; End of 'get_uniq_list.pro'.
;---------------------------------------------------------------------------
