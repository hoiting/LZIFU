	FUNCTION AMEDIAN,ARRAY,WIDTH
;+
; NAME:
;	AMEDIAN
; PURPOSE:
;	Works the same as MEDIAN, but the effect tapers off at the edges.
; CALLING SEQUENCE:
;	Result = AMEDIAN( ARRAY, WIDTH )
; INPUT PARAMETERS:
;	ARRAY	= One or two-dimensional array to be median filtered.
;	WIDTH	= Width of the median filter box.
; OPTIONAL KEYWORD PARAMETERS:
;	None.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	None.
; RESTRICTIONS:
;	ARRAY must be one or two-dimensional.
; PROCEDURE:
;	A larger array is constructed with the border filled with the reflected
;	edges of the original array.  Then MEDIAN is applied to this larger
;	array, and the area corresponding to the original array is returned as
;	the result of the function.
; MODIFICATION HISTORY:
;	William Thompson, February 1993.
;-
;
	ON_ERROR,2
;
;  Check the number of parameters.
;
	IF N_PARAMS() NE 2 THEN MESSAGE,	$
		'Syntax:  Result = AMEDIAN(ARRAY,WIDTH)'
;
;  Check the size of the array.
	SZ = SIZE(ARRAY)
	IF SZ(0) EQ 0 THEN MESSAGE,'ARRAY not defined'
	IF SZ(0) GT 2 THEN MESSAGE,'ARRAY must be one- or two-dimensional'
	NX = SZ(1)
	IF SZ(0) EQ 2 THEN NY = SZ(2)
;
;  Get the size of the border to add onto the array.
;
	IF N_ELEMENTS(WIDTH) NE 1 THEN MESSAGE,		$
		'WIDTH must be a scalar'
	W = FIX((WIDTH+1)/2)
;
;  Form the larger array to apply the median filter function to.
;
	IF SZ(0) EQ 1 THEN BEGIN
		A = FLTARR(NX+2*W)
		A(W) = ARRAY
		A(0) = REVERSE(A(1:W))
		A(NX+W) = REVERSE(A(NX-W-1:NX-2))
	END ELSE BEGIN
		A = FLTARR(NX+2*W, NY+2*W)
		A(W,W) = ARRAY
		A(0,W) = REVERSE(ARRAY(1:W,*),1)
		A(NX+W,W) = REVERSE(ARRAY(NX-W-1:NX-2,*),1)
		A(0,0) = REVERSE(A(*,W+1:2*W),2)
		A(0,NY+W) = REVERSE(A(*,NY-1:NY+W-2),2)
	ENDELSE
;
;  Apply the median filter function, and extract the part corresponding to the
;  original array.
;
	A = MEDIAN(A,WIDTH)
	IF SZ(0) EQ 1 THEN A = A(W:NX+W-1) ELSE A = A(W:NX+W-1,W:NY+W-1)
;
	RETURN,A
	END
