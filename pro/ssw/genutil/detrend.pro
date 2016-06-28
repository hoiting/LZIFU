FUNCTION detrend, y, yd, ORDER=order

;+
;NAME:
;       detrend
;PURPOSE:
;	Removes linear or higher order polynomial trends from 1-D data
;	vectors.
;
;SAMPLE CALLING SEQUENCE:
;	coeff = DETREND(trended_data, detrended_data): remove linear trend.
;	coeff = DETREND(trended_data, detrended_data, ORDER=2):remove parabolic trend.
;
;INPUT:
;	Y = 1-D data vector, any type; length = NPTS.
;
;OPTIONAL KEYWORD INPUT:
;	ORDER = the order of the fit to the data to be removed.
;
;RETURNS:
;	COEFF = 1-D array of coefficients to the trend fit.
;
;OUTPUT OUTPUT:
;	YD = 1-D float array of detrended data; length = NPTS.
;
;HISTORY:
;       12-Dec-96: T. Berger.
;-


ON_ERROR,2

sz = SIZE(y)
npts = sz(1)
np1 = npts-1
yd = FLTARR(npts)

if not KEYWORD_SET(order) then order = 1

CASE order of

	1: begin
		yd = y - (y(0)*(np1-INDGEN(npts))+y(np1)*INDGEN(npts))/np1
		m = (y(np1)-y(0))/np1
		coeff = [y(0)-m,m]
	   end

	else: begin
		yfit = 1
		coeff = POLY_FIT(indgen(npts),y,order,yfit)
		yd = y - yfit
	      end

end

RETURN,coeff
END
