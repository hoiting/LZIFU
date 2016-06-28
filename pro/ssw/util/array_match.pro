;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: array_match.pro
; Created by:    Liyun Wang, GSFC/ARC, August 23, 1994
;
; Last Modified: Thu Sep 22 14:37:08 1994 (lwang@orpheus.gsfc.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION ARRAY_MATCH, a, b, column=column
;+
; Project     :	SOHO - CDS
;
; Name        :	ARRAY_MATCH()
;
; Purpose     : Detect if a vector matches any row or column of a 2D array
;
; Explanation : Search through a 2D array to see if any row (or column, if
;               keyword COLUMN is set) of it is identical to (or matches) 
;               a given vector.
;
;               This routine is called by XCDS to check if the current
;               study has been selected previously.
;
; Use         : Result = array_match(A, B [,/column])
;               IF (array_match(a,b [,/column])) THEN ...
;
; Inputs      : A -- a 2D array with n x m elements
;               B -- a vector with n elements (or m elements if keyword COLUMN
;                    is to be set)
; Opt. Inputs : None.
;
; Outputs     : Result -- 1 if vector B matches either row (or column when
;                         COLUMN is set) of array A; 0 otherwise
;
; Opt. Outputs: None.
;
; Keywords    : COLUMN -- If set, comparison is made through column of A
;
; Calls       : None.
;
; Common      : None.
;
; Restrictions: Number of elements of vector B must be equal to the column
;               number (or row number, if the keyword COLUMN is set) of
;               array A
;
; Side effects: None.
;
; Category    : Utilities, array manipulation
;
; Prev. Hist. : None.
;
; Written     :	Liyun Wang, GSFC/ARC, August 23, 1994
;
; Modified    : Liyun Wang, GSFC/ARC, August 24, 1994
;                  Fixed a bug that only checks for a maximum of two rows
;               Liyun Wang, GSFC/ARC, August 30, 1994
;                  Added keyword COLUMN to allow comparison of one vector with
;                  each column of a 2D array.
;
; Version     : Version 1.0, August 30, 1994
;-
;
   ON_ERROR, 2
   IF (N_PARAMS() LT 2) THEN BEGIN
      PRINT, 'ARRAY_MATCH Usage:   Result = array_match(A, B [,/column])'
      PRINT, '   where A is a 2D array, and B is a vector which has the'
      PRINT, '   same number of elements as the column (row) number of'
      PRINT, '   array A if keyword COLUMN is (not) set.'
      PRINT, ' '
      RETURN, 0
   ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Test to see if arrays A and B are valid for comparison
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   size_a = SIZE(a) &  size_b = SIZE(b)
   IF (size_a(0) GT 2 OR size_a(0) EQ 0) THEN BEGIN
      PRINT, 'ARRAY_MATCH -- Sorry, only one or two dimensional arrays'
      PRINT, '               can be used.'
      PRINT, ' '
      RETURN, 0
   ENDIF
   IF size_b(0) NE 1 THEN BEGIN
      PRINT, 'ARRAY_MATCH -- The second parameter must be a vector.'
      PRINT, ' '
      RETURN, 0
   ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Test to see if both arrays are comparable
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   IF (NOT KEYWORD_SET(column)) THEN BEGIN
      IF (size_b(1) NE size_a(1)) THEN BEGIN
         PRINT, 'ARRAY_MATCH -- The two input arrays are not comparable.'
         PRINT, ' '
         RETURN, 0
      ENDIF
   ENDIF ELSE BEGIN
      IF (size_b(1) NE size_a(2)) THEN BEGIN
         PRINT, 'ARRAY_MATCH -- The two input arrays are not comparable.'
         PRINT, ' '
         RETURN, 0
      ENDIF
   ENDELSE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Now begin to make comparison of each row of array A with vector B.
;  Whenever a match is found, return to the calling program
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   IF (size_a(0) EQ 1) THEN BEGIN ; Both arrays are 1D
      index = WHERE(a EQ b, count)
      IF (count EQ size_b(1)) THEN RETURN, 1
   ENDIF ELSE BEGIN             ; array A is two dimensional
      IF KEYWORD_SET(column) THEN BEGIN
         FOR i = 0, size_a(1)-1 DO BEGIN
            c = a(i,*)
            index = WHERE(c EQ b, count)
            IF (count EQ size_b(1)) THEN RETURN, 1
         ENDFOR
      ENDIF ELSE BEGIN
         FOR i = 0, size_a(2)-1 DO BEGIN
            c = a(*,i)
            index = WHERE(c EQ b, count)
            IF (count EQ size_b(1)) THEN RETURN, 1
         ENDFOR
      ENDELSE
   ENDELSE
   RETURN, 0
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'array_match.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
