pro plottimes, xf, yf, str, siz, dir
;
;+
;NAME:
;       plottimes
;PURPOSE:
;	Ancient routine which effectively does an "xyouts, /norm"
;	but relative to the PLOT window, not the whole page.
;SAMPLE CALLING SEQUENCE:
;       plottimes, 0.1, 0.9, 'Infil: ' + infil
;       plottimes, xf, yf, str, siz, dir
;INPUT:
;       xf      - fractional position in the x
;       yf      - fractional position in the y
;       str     - the string to write out
;       dir     - the direction (rotation)
;HISTORY:
;       Written 1991 by M.Morrison
;        5-Nov-96 (MDM) - Added documentation header
;	 14-May-2001, William Thompson, GSFC, use modern system variables.
;-
;
;
bits, !type, b
;
if (b(0)) then begin	;x axis is log
    ;t1 = alog10(!cxmin)
    ;t2 = alog10(!cxmax)
    t1 = !x.crange(0)
    t2 = !x.crange(1)
    x = 10.^( (t2-t1)*xf + t1)
end else begin
    x = (!x.crange(1) - !x.crange(0))*xf + !x.crange(0)
end
;
if (b(1)) then begin	;y axis is log
    ;t1 = alog10(!cymin)		;MDM 25-Jan-90
    ;t2 = alog10(!cymax)
    t1 = !y.crange(0)
    t2 = !y.crange(1)
    y = 10.^( (t2-t1)*yf + t1)
end else begin
    y = (!y.crange(1) - !y.crange(0))*yf + !y.crange(0)
end
;
if (n_params(0) eq 0) then xyouts, 0.55, 0.01, 'Plot Made '+!stime
if (n_params(0) ge 3) then begin
    if (n_elements(siz) eq 0) then siz0=0.9 else siz0=siz
    if (n_elements(dir) eq 0) then dir0=0   else dir0=dir
    if (!fancy eq 0) then siz0 = siz0<0.9
    xyouts, x, y, str, siz=siz0, orient=dir0
end
;
return
end
