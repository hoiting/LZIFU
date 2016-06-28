;	(9-feb-91)
FUNCTION SUMCOL,A
;+
;  NAME:
;	SUMCOL
;
;  PURPOSE:
;	Some along columns of a matrix
;
;  CALLING SEQUENCE:
;	Vector = SUMCOL(A)
;
;-

return,a#replicate(1,n_elements(a(0,*)))
end
