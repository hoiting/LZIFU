pro lcur_plot, win, index, lcur, plotmark, avg_uncert, $
		ynozero=ynozero, qoplot=qoplot0, subscript=subscript, ioff=ioff
;
;+
;NAME:
;	lcur_plot
;PURPOSE:
;       To plot the light curve averages for the LCUR_IMAGE routine
;INPUT:
;	win	- The light curve plot window number
;	index	- The index structure
;	lcur	- The average (or total) counts for each image (and region)
;	plotmark- The flag on what plotting symbols to plot for each image
;		  (see LCUR_CALC)
;OPTIONAL INPUT:
;	avg_uncert-The uncertainty of the data points.  Plot as error bars
;OPTIONAL KEYWORD INPUT:
;	ynozero	- If set, adjust y scale so it is not zero if necessary
;	qoplot	- If set, do not make a new plot, simply overplot the
;		  data
;	subscript- The image numbers of the images to plot the light
;		  curve for
;	ioff	- The region number (used when plotting a single 
;		  light curve, not needed when doing multiple light
;		  curve plot option)
;HISTORY:
;       Written 18-Oct-93 by M.Morrison
;       19-Oct-93 (MDM) - Added header information
;                       - Corrected /TOTAL_CNTS option
;	26-Oct-93 (MDM) - Corrected overplotting symbol bug
;	28-Feb-95 (MDM) - Added AVG_UNCERT 
;-
;
COMMON UTCOMMON, UTBASE, UTSTART, UTEND, xst_plot
;
if (!d.name ne 'PS') then begin
    wset, win
    wshow, win
end
;
if (n_elements(ioff) eq 0) then ioff = 0
nx = n_elements(lcur(*,0))
n = n_elements(lcur(0,*))
if (n_elements(subscript) eq 0) then subscript = indgen(nx)
ns = n_elements(subscript)
;
qoplot = keyword_set(qoplot0)
q6plot = total(!p.multi) ne 0		;6 plots per page option
if (keyword_set(qoplot)) then ref_time = xst_plot else ref_time = index(0)
x = int2secarr(index, ref_time)
;
for i=0,n-1 do begin
    if (q6plot) then yrange = [min(lcur(subscript,i)), max(lcur(subscript,i))] $
		else yrange = [min(lcur(subscript,*)), max(lcur(subscript,*))]
    qmoplot = (i ne 0) and (not q6plot)			;multiple overplot option, with not 6 plot option enabled
    if (qoplot or qmoplot) then outplot, x(subscript), lcur(subscript,i), ref_time, psym = 0 $
			else utplot, x(subscript), lcur(subscript,i), ref_time, psym = 0, ynozer=ynozero, yrange=yrange
    ;---- Mark labels
    y0 = max(lcur(subscript,i), imax) + (!y.crange(1)-!y.crange(0))*0.01 	;move up 1 %
    x0 = x(subscript(imax))
    x1 = x(subscript(ns-1)) + (!x.crange(1)-!x.crange(0))*0.02	;move 2% over to the right
    y1 = lcur(subscript(ns-1),i)
    str = string(byte(65+i+ioff))
    xyouts, x0, y0, str, size=1.5, charthick=1.5
    xyouts, x1, y1, str, size=1.5, charthick=1.5

    if (n_elements(avg_uncert) ne 0) then errplot, x(subscript), lcur(subscript,i)-avg_uncert(subscript,i), $
								lcur(subscript,i)+avg_uncert(subscript,i)

    for j=1,10 do begin
	ss = where(plotmark(subscript,i) eq j, nn)
	if (ss(0) ne -1) then outplot, x(subscript(ss)), lcur(subscript(ss),i), ref_time, psym=j
    end
end
;
end
