pro fits_disp_month, infil_arr, smin, smax, gif=gif, dir=dir, $
		filter=filter, char_factor=char_factor, $
		mapfil=mapfil, mappre=mappre, $
		img_scale=img_scale
;
;+
;NAME:
;	fits_disp_month
;PURPOSE:
;	To display a single image per day for a single month
;CALLING SEQUENCE:
;	fits_disp_month, files, -50, 50
;	fits_disp_month, file_list('/data14/mdi_summary/daily/maglc', 'smdi_maglc_fd_199611*')
;METHOD:
;	The date of the first image defines which month is to be displayed
;	"DATEOBS" fits keyword must be in the header.
;	If smin/smax are not passed, then the first image defines the
;	image scaling min and max
;HISTORY:
;	Written 27-Nov-96 by M.Morrison (taking SXT disp_month.pro)
;	19-May-97 (MDM) - Added writing boarder lines (because of MDI HR)
;	20-May-97 (MDM) - Added output of HTML map file (mappre and mapfil options)
;	30-May-97 (MDM) - Modified to work with EIT FITS files (no header
;			  tag "DATEOBS") so got DATE-OBS and TIME-OBS
;			- Added img_scale option
;	16-Jun-97 (MDM) - Corrected error if image for first of the month
;			  is missing.
;-
;
mapfil = '#rectangle upper-left, lower-right'
if (n_elements(mappre) eq 0) then mappre = ''
if (infil_arr(0) eq '') then return
;
nfil = n_elements(infil_arr)
img = rfits(infil_arr(0), h=h)
if (n_elements(smin) eq 0) then smin = min(img)
if (n_elements(smax) eq 0) then smax = max(img)
;
dattim = sxpar(h, 'dateobs')
if (data_type(dattim) eq 2) then dattim = sxpar(h, 'date-obs') + ' ' + sxpar(h, 'time-obs')
month = dattim
tarr = anytim2ex(month)
tarr(0:4) = 0
;
if (n_elements(disp_factor) eq 0) then disp_factor = 1.	;use disp_factor = 1.29 for ramtek
if (n_elements(char_factor) eq 0) then char_factor = 1.	;use char_factor = 0.75 for ramtek
nx = 7
ny = 6
siz = 128
win_xsiz = fix(nx*siz*disp_factor+.5)
win_ysiz = fix((ny*siz+25)*disp_factor)
nout = siz*disp_factor
;
last_day = -99
	tarr(4) = 1
	dummy = anytim2ints(tarr)
	day1 = dummy.day
	;dow = ex2dow(anytim2ex(month))
	dow = ex2dow(tarr)

	tv2, win_xsiz, win_ysiz, /already, /init
	erase

	ref_dow = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
	for i=0,6 do xyouts, siz*i*disp_factor, ny*nout+5, ref_dow(i), /device, charsize=(disp_factor+.4)*char_factor

	for ifil=0,nfil-1 do begin
	    infil = infil_arr(ifil)
	    data = rfits(infil, h=h)
	    dattim = sxpar(h, 'dateobs')
	    if (data_type(dattim) eq 2) then dattim = sxpar(h, 'date-obs') + ' ' + sxpar(h, 'time-obs')
	    ii = (gt_day(dattim) - day1) + dow
	    if (ii ne last_day) then begin	;take first image for the day
		x0 = (ii mod nx)*nout
		y0 = (ny-1 - ii/nx)*nout
		data = congrid(data, nout, nout, interp=0)
		if (keyword_set(img_scale)) then case img_scale of
		    1: data = bytscl(alog10((data - eit_dark()) > 1))
		end
		data = bytscl(data, smin, smax)
		data(0,*) = 0
		data(*, n_elements(data(0,*))-1) = 0
		tv, data, x0, y0
		xyouts, x0, y0, fmt_tim(dattim), /device, charsize=disp_factor*char_factor

		xll = x0
		yll = win_ysiz - y0 -nout	;invert coordinates
		arr = strtrim(fix([xll, yll, xll+nout, yll+nout]), 2)	;up-left, low-right
		mapfil0 = mappre + $
			'' + infil + ' ' + $
			
			string(arr, format='(2(a,",",a,2x))')
		mapfil = [mapfil, mapfil0]

		last_day = ii
	    end
	end

	month_str = strmid(gt_day(dattim, /str, /longmonth), 3, 100)
	xyouts, win_xsiz*.5, 50, month_str, charsize = 6*disp_factor*char_factor, /dev, charthick=3
;
if (keyword_set(gif) and (!d.name eq 'Z')) then zbuff2file, gif
;
end
