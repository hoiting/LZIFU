;** keyword /LESS returns closest subscript for arr that is less than or equal  to num

FUNCTION FIND_CLOSEST, num, arr, LESS=less
;+
; NAME:
;	FIND_CLOSEST
;
; PURPOSE:
;	This function finds the subscript of an array that is closest to
;	a given number.
;
; CATEGORY:
;	LASCO UTIL
;
; CALLING SEQUENCE:
;	Result = FIND_CLOSEST (Num, Arr)
;
; INPUTS:
;	Num:	Number for which the array will be searched
;	Arr:	An array of points in (preferably) ascending order
;
; KEYWORD PARAMETERS:
;	LESS:	Returns the closest subscript for arr that is less than or 
;		equal to num Otherwise the subscript of the point closest 
;		to num is returned.  Notice that the value of arr might be 
;		greater than num.
;
; OUTPUTS:
;	This function returns the subscript of an array closest to the given
;	number.
;
; RESTRICTIONS:
;	The input array should be in ascending order. But not necessary.
;
; MODIFICATION HISTORY:
; 	Written by:	Scott Passwaters, NRL, Feb, 1997
;	24 Sep 1998, N Rich	changed /LESS keyword to include equal-to
;	31 Jan 2000, N Rich	Allow for MOSTLY (except for isolated stray elements) sorted arr, but must still be ascending order
;	12 Apr 2005, N.Rich	Return -1 in one case.     
;
;	%W% %H% LASCO IDL LIBRARY
;-

   len = N_ELEMENTS(arr)

   l = WHERE(arr LE num)	; ** 9/24/98, nbr: LT to LE
   len2 = N_ELEMENTS(l)

   IF (len2 EQ len) or num GE arr(len-1) THEN RETURN, len - 1	;** take last element

   IF (l[0] EQ -1) and keyword_set(LESS) THEN BEGIN
	print,'% find_closest.pro % WARNING: no value in array LE to ',num
	return,-1
   ENDIF
   IF (l(0) EQ -1) or num LE arr(0) THEN RETURN, 0		;** take first element

   ind = l(len2-1)

   IF (KEYWORD_SET(LESS) or datatype(num) EQ 'STR') THEN RETURN, ind

   diff1 = ABS(num - arr(ind))
   diff2 = ABS(num - arr(ind+1))

   IF (diff1 LT diff2) THEN RETURN, ind
   RETURN, ind+1

END
