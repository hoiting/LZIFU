FUNCTION smooft, y, wfwhm

;+
;NAME:
;       smooft
;PURPOSE:
;	Implements the smooft routine from Numerical Recipes (Sec. 13.9).
;	Essentially a low-pass filter for a 1-D array of noisy data.
;
;SAMPLE CALLING SEQUENCE:
;	smoothed_data = SMOOFT(noisy_data,wfwhm)
;		where the smoothing window applied to 'noisy_data' is on
;		the order of 'wfwhm'.
;
;INPUT:
;	Y = 1-D data vector, any type; length = NPTS.
;	WFWHM = approximate width of smoothing window in abcissa points.
;
;RETURNS:
;	YFT = 1-D floating point array of smoothed data; length = NPTS.
;
;HISTORY:
;       12-Dec-96: Transcribed from Numerical Recipes by T. Berger.
;       12-Sep-97: Removed factor of 2 error on inverse transformed data. T.Berger.
;-


sz = SIZE(y)
if sz(0) ne 1 then begin
	MESSAGE,'Data array must be 1-D.'
	return, -1
end
npts = sz(1)
np1 = npts - 1

nmin = npts + FIX(2.0*wfwhm+0.5)
m = 2
while m lt nmin do m = m*2

yd = fltarr(npts)
;linear detrend the data vector:
linfac = (y(0)*(np1-INDGEN(npts)) + y(np1)*INDGEN(npts))/np1
yd = y - linfac

;zero pad and transform:
yd = [yd,REPLICATE(0.,m-npts)]
yft = FFT(yd,-1)

;apply windowing to data:
cnst = (wfwhm/FLOAT(m))^2.
fac = 1.-(cnst*INDGEN(m)^2.) > 0.0
yft = yft*fac

;transform back
yft = FLOAT(FFT(yft,1))

;restore linear trend
yft = yft + linfac

RETURN, yft
END

