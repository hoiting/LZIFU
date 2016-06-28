;---------------------------------------------------------------------------
; Document name: extend_matrix.pro
; Created by:    Liyun Wang, GSFC/ARC, November 22, 1995
;
; Last Modified: Wed Nov 22 15:30:11 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       EXTEND_MATRIX()
;
; PURPOSE:
;       Extand dimension of a given matrix by attaching a submatrix
;
; CATEGORY:
;       Utility, matrix
;
; EXPLANATION:
;       There may be cases where one wants to extend a (MxN) matrix to
;       [(M+K)xN], [(K+M)xN], [Mx(N+K)], or [Mx(K+N)], where K is an
;       integer number. This routine does exactly this.
;
; SYNTAX:
;       Result = paste_matrix(matrix, int, /keyword)
;
; EXAMPLES:
;       a = indgen(5,5)
;       print, extend_matrix(a, 4, /xprep, value=50)
;
;       50      50      50      50       0       1       2       3       4
;       50      50      50      50       5       6       7       8       9
;       50      50      50      50      10      11      12      13      14
;       50      50      50      50      15      16      17      18      19
;       50      50      50      50      20      21      22      23      24
;
;       print, extend_matrix(a, 4, /yappd, value=40)
;
;        0       1       2       3       4
;        5       6       7       8       9
;       10      11      12      13      14
;       15      16      17      18      19
;       20      21      22      23      24
;       40      40      40      40      40
;       40      40      40      40      40
;       40      40      40      40      40
;       40      40      40      40      40
;
; INPUTS:
;       MATRIX - A 2-dimensional matrix
;       INT    - An integer over which the matrix is extended
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - The extended matrix
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       XPREP - Set this keyword to prepend a necessary submatrix in X dir
;       YPREP - Set this keyword to prepend a necessary submatrix in Y dir
;       XAPPD - Set this keyword to append a necessary submatrix in X dir
;       YAPPD - Set this keyword to append a necessary submatrix in Y dir
;
;       Note: Only one of above keywords can be set at one time. If
;             none of the above keywords is set, XAPP is implied
;
;       VALUE - Initial value of the extended submatrix. If not
;               present, zero value (or null string for string array)
;               is assumed
;       ERROR - A named variable that contains error message returned.
;               If no error occurs, ERROR will be a null string
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, November 22, 1995, Liyun Wang, GSFC/ARC. Written
;
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
FUNCTION make_matrix, m, n, dtype
;---------------------------------------------------------------------------
;  Make a MxN matrix that has the same datatype as DTYPE
;---------------------------------------------------------------------------
   IF N_PARAMS() NE 3 THEN BEGIN
      MESSAGE, 'Require 3 input parameters!', /cont
      RETURN, 0
   ENDIF

   CASE (dtype) OF
      1: RETURN, BYTARR(m,n)
      2: RETURN, INTARR(m,n)
      3: RETURN, LONARR(m,n)
      4: RETURN, FLTARR(m,n)
      5: RETURN, DBLARR(m,n)
      6: RETURN, COMPLEXARR(m,n)
      7: RETURN, STRARR(m,n)
      ELSE: BEGIN
         MESSAGE, 'Unsupported datatype', /cont
         RETURN, 0
      END
   ENDCASE
END

FUNCTION extend_matrix, matrix, int, xprep=xprep, yprep=yprep, $
                        xappd=xappd, yappd=yappd, error=error, $
                        value=value
   ON_ERROR, 2
   error = ''
   IF N_PARAMS() NE 2 THEN BEGIN
      error = 'Need two parameters.'
      MESSAGE, error, /cont
      RETURN, 0
   ENDIF
   sz = SIZE(matrix)
   IF sz(0) NE 2 THEN BEGIN
      error = 'The first parameter must be a 2-D array.'
      MESSAGE, error, /cont
      RETURN, 0
   ENDIF
   IF sz(3) EQ 0 OR sz(3) EQ 8 THEN BEGIN
;---------------------------------------------------------------------------
;     "Undefined" and "structure" datatype are not supported
;---------------------------------------------------------------------------
      error = 'Unsupported datatype.'
      MESSAGE, error, /cont
      RETURN, matrix
   ENDIF
   k = 0
   xprep = KEYWORD_SET(xprep)
   yprep = KEYWORD_SET(yprep)
   xappd = KEYWORD_SET(xappd)
   yappd = KEYWORD_SET(yappd)
   IF xprep THEN BEGIN
      k = k+1
      i = 1
   ENDIF
   IF yprep THEN BEGIN
      k = k+1
      i = 2
   ENDIF
   IF xappd THEN BEGIN
      k = k+1
      i = 3
   ENDIF
   IF yappd THEN BEGIN
      k = k+1
      i = 4
   ENDIF
   IF k GT 1 THEN BEGIN
      error = 'Only one keyword is allowed!'
      MESSAGE, error, /cont
      RETURN, matrix
   ENDIF ELSE IF k EQ 0 THEN i = 3
   CASE i OF
      1: BEGIN
         temp = make_matrix(int, sz(2), sz(3))
         IF KEYWORD_SET(value) THEN temp(*,*) = value
         RETURN, TRANSPOSE([[TRANSPOSE(temp)], [TRANSPOSE(matrix)]])
      END
      2: BEGIN
         temp = make_matrix(sz(1), int, sz(3))
         IF KEYWORD_SET(value) THEN temp(*,*) = value
         RETURN, [[temp], [matrix]]
      END
      3: BEGIN
         temp = make_matrix(int, sz(2), sz(3))
         IF KEYWORD_SET(value) THEN temp(*,*) = value
         RETURN, TRANSPOSE([[TRANSPOSE(matrix)], [TRANSPOSE(temp)]])
      END
      4: BEGIN
         temp = make_matrix(sz(1), int, sz(3))
         IF KEYWORD_SET(value) THEN temp(*,*) = value
         RETURN, [[matrix], [temp]]
      END
   ENDCASE
END

;---------------------------------------------------------------------------
; End of 'extend_matrix.pro'.
;---------------------------------------------------------------------------
