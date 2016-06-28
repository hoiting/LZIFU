function lcur_calc, index, data, marks, uncert, satpix, plotmark, avg_uncert, $
			normalize=normalize, total_cnts=total_cnts
;
;+
;NAME:
;	lcur_calc
;PURPOSE:
;	To calculate the light curve averages for the LCUR_IMAGE routine
;INPUT:
;	index	- the index structure
;	data	- the data array
;       marks   - The subscripts within the image that were selected.  The
;                 output array is NxM where N is the largest number of subscripts
;                 that were selected in a region, and M is the number of
;                 different regions selected.  When padding is necessary, the
;                 value is set to -1, so that value needs to be avoided.
;OPTIONAL INPUT
;	uncert	- The uncertainty array
;	satpix	- The saturated pixel array
;OUTPUT:
;	plotmark- The plotting mark to be used.  If "uncert" and "satpix" are
;		  not passed in, then it is always "1"
;			for average uncert > 0.25	- value = 4 (diamond)
;			for any sat pixel in region	- value = 5 (triangle)
;			for over 25% sat pix in region	- value = 2 (astrix)
;	avg_uncert- The average uncertainty
;OPTIONAL KEYWORD INPUT:
;	normalize - If set, then divide by the exposure duration to normalize
;		    to DN/sec.
;	total_cnts - If set, then return the total counts in the region (not
;		    the counts per second)
;HISTORY:
;	Written 18-Oct-93 by M.Morrison
;	19-Oct-93 (MDM) - Added header information
;			- Corrected /TOTAL_CNTS option
;	28-Feb-95 (MDM) - Added avg_uncert output
;-
;
nx = n_elements(data(*,0,0))
ny = n_elements(data(0,*,0))
n = n_elements(data(0,0,*))
;
out = fltarr(n)
if (n_elements(uncert) ne 0) then avg_uncert = fltarr(n)
plotmark = intarr(n) + 1	;plot a + by default
;
for i=0,n-1 do begin
    ss = marks + i*long(nx)*long(ny)
    temp = data(ss)		;POLY and CONTOUR return the subscripts of what we want
    if (n_elements(uncert) ne 0) then utemp = uncert(ss)
    if (n_elements(satpix) ne 0) then stemp = satpix(ss)

    out0 = total(temp)
    if (not keyword_set(total_cnts)) then out0 = out0 / n_elements(temp)
    if (keyword_set(normalize)) then out0 = out0 / (gt_expdur(index(i))/1000.)	;convert to DN/sec
    out(i) = out0

    if (n_elements(uncert) ne 0) then begin
	ratio = total(utemp) / (abs(total(temp))>1)		;signal to noise?
	if (ratio gt .25) then plotmark(i) = 4	;
	out0 = sqrt( total( float(utemp)^2 ) )
	if (not keyword_set(total_cnts)) then out0 = out0 / n_elements(utemp)
	if (keyword_set(normalize)) then out0 = out0 / (gt_expdur(index(i))/1000.)	;convert to DN/sec
	avg_uncert(i) =  out0
    end
    if (n_elements(satpix) ne 0) then begin
	if (total(stemp) gt 1) then plotmark(i) = 5
	if (total(stemp)/n_elements(stemp) gt .25) then plotmark(i) = 2
    end
end
;
return, out
end
