FUNCTION diff, arr1, arr2, flag
;+
; FUNCTION DIFF
;
; Returns values in arr1 that are not in arr2; if none, then returns -1.
;
; INPUTS:
; arr1, arr2	Arrays to compare, can be any size or type (???)
;
; OUTPUTS:
; flag		Zero if no values are returned (-1), else is 1
;
; Written by N. Rich, NRL/Interferometrics, about 2000
;
; Modified:
;  01.11.06, nbr - Rewrite so it works one way only.
;
;	11/08/01 @(#)diff.pro	1.2 - NRL LASCO IDL Library
;-
;

nel1=N_ELEMENTS(arr1)
nel2=N_ELEMENTS(arr2)

IF nel1 GE nel2 THEN BEGIN
	bigger = arr1
	small  = arr2
ENDIF 
IF nel1 LT nel2 THEN BEGIN
	bigger = arr2
	small  = arr1
ENDIF
n = nel1 ;	> nel2
flag = 0

FOR i=0,n-1 DO BEGIN
   v = WHERE(arr1[i] EQ arr2,nv)
   IF nv EQ 0 THEN BEGIN
     flag = 1
     IF DATATYPE(diffs) EQ 'UND' THEN diffs = arr1[i] $
     	ELSE diffs=[diffs,arr1[i]]
   ENDIF
ENDFOR

IF DATATYPE(diffs) EQ 'UND' THEN diffs = -1
return, diffs

end
