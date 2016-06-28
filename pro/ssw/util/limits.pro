;+
;FUNCTION:	FUNCTION LIMITS, X
;
;PURPOSE:	Scan vector X and return 2 element vector of [min(x),max(x)]
;
;-
FUNCTION LIMITS, X
;
ON_ERROR,2
;
csave = !c
Result = [MIN(X),MAX(X)]
!c = csave
return, result
END

