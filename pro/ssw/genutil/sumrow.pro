;	(9-feb-91)
FUNCTION SUMROW,A
;+
;  NAME:
;	SUMROW
;
;  PURPOSE:
;	Some along rows of a matrix
;
;  CALLING SEQUENCE:
;	Vector = SUMROW(A)
;
;-

b = replicate(1,n_elements(a(*,0)))#a
return,b(0:*)			; Make a vector
end
