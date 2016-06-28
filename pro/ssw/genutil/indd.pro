;	(27-apr-85, revised into IDL version 1-mar-1991)
;
;
;	routine:	indd
;
;#####################################################################
	function	indd, A, B 
;#####################################################################
;                         
;+
; NAME:		INDD
; PURPOSE:	Return index of array A(i) for which
;		A(i-1) < B <= A(i) 
; CATEGORY:
; CALLING SEQUENCE: indx = indd(A, B) 
; INPUTS:	A = an array whose value is monotonically increasing
;		B = threshold value
; OUTPUTS: 	Function result = indx of array A(i) to satisfy the
; 		conditon  A(i-1) < B <= A(i)
; COMMON BLOCKS: none
; SIDE EFFECTS:  none
; RESTRICTIONS:  none
; PROCEDURE:	straightforward
;
;-
;                         
;#####################################################################
;
	npts   = n_elements(A)			; How long is A?
	result = intarr(n_elements(B))		; Set up return variable	

	ii = where ( B gt A(npts-1), nn1)	; Fix cases which are out of
	if nn1 gt 0 then result(ii) = npts	;- bounds on the upper limit

;  The next section treats the cases where A(0) < B <= A(npts-1):

	ii = where( (B gt A(0)) and (B le A(npts-1)), nn1)
	if nn1 gt 0 then $
	   for i=0,nn1-1 do result(ii(i)) = MAX(where(B(ii(i)) gt A))+1 


	return, result
	end
