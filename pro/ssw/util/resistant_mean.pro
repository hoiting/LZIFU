 FUNCTION RES_MED,A       
;+
;Name
; RES_MED
;PURPOSE
; Compute the median of an array, which may be of even length. 
;Calling sequence  
; MID_VALUE = RES_MED(A)
;Outputs
; The median of array A
;Author:
; H.T. Freudenreich, ?/89
; renamed res_med by ras, 8-sep-1997,
; med() is too short for a function name under ssw until
; everyone is at version 5, included here since it is only
; used inside of resistant_mean and version 5(4?) supports
; the /even keyword in Median().
;-
ON_ERROR,2
NUM = N_ELEMENTS(A)
IF NUM MOD 2 EQ 0 THEN BEGIN  ; even # points. Can't call MEDIAN.
   B = A   &  B = B( SORT(B) )  &  I0  = (NUM-1)/2  & MED =.5*(B(I0)+B(I0+1)) 
ENDIF ELSE MED=MEDIAN(A)
RETURN, MED
END


PRO RESISTANT_MEAN,Y,CUT,MEAN,SIGMA,NUM_REJ, WUSED=WUSED 
;+
;NAME:
; Resistant_Mean
;
;PURPOSE:
; An outlier-resistant determination of the mean and its standard deviation.
; It trims away outliers using the median and the median absolute deviation.
;
;CALLING SEQUENCE:
; RESISTANT_MEAN,VECTOR,SIGMA_CUT, MEAN,SIGMA,NUM_REJECTED
;
;INPUT ARGUMENT:
; VECTOR    = Vector to average
; SIGMA_CUT = Data more than this number of standard deviations from the
;             median is ignored. Suggested values: 2.0 and up.
;	      maximum value of sigma_cut is 6.79.
;
;OUTPUT ARGUMENT:
; MEAN  = the mean
; SIGMA = the standard deviation of the mean
; NUM_REJECTED = the number of points trimmed
;KEYWORDS:
; WUSED = indices used for mean in array Y
;
;SUBROUTINE CALLS:
; MED, which calculates a median, replaced with RES_MED
;	richard.schwartz@gsfc.nasa.gov, 8-sep-1997
;
;AUTHOR: H. Freudenreich, STX, 1989; Second iteration added 5/91.
;MODIFICATION HISTORY:
;	mod, ras,  28-sep-1995, report elements used
;	richard.schwartz@gsfc.nasa.gov, 8-sep-1997
;	richard.schwartz@gsfc.nasa.gov, 4-dec-1997
;	protect against negative revised sigma.
;-

ON_ERROR,2

NPTS    = N_ELEMENTS(Y)
YMED    = RES_MED(Y)
ABSDEV  = ABS(Y-YMED)
MEDABSDEV = RES_MED( ABSDEV)/.6745
IF MEDABSDEV LT 1.0E-24 THEN MEDABSDEV = AVG(ABSDEV)/.8
CUT	= CUT < 6.79

CUTOFF    = CUT*MEDABSDEV
WUSED0   = WHERE( ABSDEV LE CUTOFF )
GOODPTS = Y( WUSED0 )
MEAN    = AVG( GOODPTS )
NUM_GOOD = N_ELEMENTS( GOODPTS )
SIGMA   = SQRT( TOTAL((GOODPTS-MEAN)^2)/NUM_GOOD )
NUM_REJ = NPTS - NUM_GOOD

; Compensate SIGMA for truncation (formula by HF):
SC=CUT
IF SC LT 1.75 THEN SC=1.75
SIGMA0 = SIGMA
IF SIGMA LE 3.4 THEN SIGMA=SIGMA/(.18553+.505246*SC-.0784189*SC*SC)

CUTOFF = CUT*SIGMA 

WUSED = WHERE( ABSDEV LE CUTOFF, NUM_GOOD )    ;RAS 28-SEP-1995

IF NUM_GOOD GE 2 then begin
GOODPTS = Y( WUSED )
MEAN    = AVG( GOODPTS )
;NUM_GOOD = N_ELEMENTS( GOODPTS ) - NO LONGER NEEDED
SIGMA   = SQRT( TOTAL((GOODPTS-MEAN)^2)/NUM_GOOD )
NUM_REJ = NPTS - NUM_GOOD

SC=CUT
IF SC LT 1.75 THEN SC=1.75
IF SIGMA LE 3.4 THEN SIGMA=SIGMA/(.18553+.505246*SC-.0784189*SC*SC)

; Now the standard deviation of the mean:
SIGMA = SIGMA/SQRT(NPTS-1.)
ENDIF ELSE BEGIN
	WUSED=WUSED0
	SIGMA=SIGMA0
ENDELSE
RETURN
END
