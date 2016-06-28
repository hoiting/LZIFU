function mk_fits_head, data, time=time, date=date, comment=comment, history=history
;
;+
;NAME:
;	mk_fits_head
;PURPOSE:
;	Given a data array, build the minimal FITS header.
;CALLING SEQUENCE:
;	head = mk_fits_head(data)
;	head = mk_fits_head(data, time='17:00:01', date='27-Oct-92')
;INPUT:
;	data	- The data array
;OPTIONAL KEYWORD INPUT:
;	time	- Time that the image was taken
;	date	- The date that the image was taken
;	comment	- Optional comments
;	history	- Optional history information
;OUTPUT:
;	ASCII string array with the FITS header.  The length is only the
;       length used, and the END string is not included
;HISTORY:
;	Written 27-Oct-92 by M.Morrison
;	 2-Feb-93 (MDM) - Modified to save floating points properly
;	17-Mar-94 (MDM) - Modified to make the string length 80 
;			  characters
;	28-Jun-94 (MDM) - Modified to save double points properly
;	30-Aug-96 (MDM) - Modified to shift the values over 1 character
;			  to be proper FITS standard.
;-
;
nbits = get_nbytes(data(0,0))*8
siz = size(data)
naxis = siz(0)
if (data_type(data) ge 4) then nbits=-nbits
;
fits_head = strarr(25)

fits_head(0) = 'SIMPLE  = ' + string('T',			format="(a20, ' /')")
fits_head(1) = 'BITPIX  = ' + string(nbits,			format="(i20, ' /')")
fits_head(2) = 'NAXIS   = ' + string(naxis,			format="(i20, ' /')")
ii = 3
for i=1,naxis do begin
    lab = 'NAXIS' + strtrim(i,2) + '     '
    lab = strmid(lab, 0, 8) + '= '
    fits_head(ii) = lab + string(siz(i),			format="(i20, ' /')")
    ii = ii + 1
end
;
if (keyword_set(time)) then begin
    fits_head(ii) = 'TIME-OBS= ' + string(time,			format="(a20, ' /')")
    ii = ii + 1
end
if (keyword_set(date)) then begin
    fits_head(ii) = 'DATE-OBS= ' + string(date,			format="(a20, ' /')")
    ii = ii + 1
end
;
if (keyword_set(comment)) then begin
    fits_head(ii)= 'COMMENT   ' + string(comment)
    ii = ii + 1
end
;
if (keyword_set(history)) then begin
    fits_head(ii)= 'HISTORY  ' + string(history)
    ii = ii + 1
end
;
fits_head = strmid(fits_head+'                                                                                ', 0, 80)
return, fits_head(0:ii-1)
end

