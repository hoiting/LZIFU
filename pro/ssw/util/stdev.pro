; $Id: stdev.pro,v 1.4 2000/01/21 00:30:04 scottm Exp $
;
; Copyright (c) 1983-2000, Research Systems, Inc.  All rights reserved.
;       Unauthorized reproduction prohibited.

Function STDEV, Array, Mean
;
;+
; NAME:
;	STDEV
;
; PURPOSE:
;	Compute the standard deviation and, optionally, the
;	mean of any array.
;
; CATEGORY:
;	G1- Simple calculations on statistical data.
;
; CALLING SEQUENCE:
;	Result = STDEV(Array [, Mean])
;
; INPUTS:
;	Array:	The data array.  Array may be any type except string.
;
; OUTPUTS:
;	STDEV returns the standard deviation (sample variance
;	because the divisor is N-1) of Array.
;		
; OPTIONAL OUTPUT PARAMETERS:
;	Mean:	Upon return, this parameter contains the mean of the values
;		in the data array.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Mean = TOTAL(Array)/N_ELEMENTS(Array)
;	Stdev = SQRT(TOTAL((Array-Mean)^2/(N-1)))
;
; MODIFICATION HISTORY:
;	DMS, RSI, Sept. 1983.
;-
	on_error,2		;return to caller if error
	n = n_elements(array)	;# of points.
	if n le 1 then message, 'Number of data points must be > 1'
;
        mean = total(array)/n	;yes.
        return,sqrt(total((array-mean)^2)/(n-1))

       end

