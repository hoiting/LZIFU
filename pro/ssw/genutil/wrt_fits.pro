pro wrt_fits, outfil, head, image
;
;+
;NAME:
;	wrt_fits
;PURPOSE:
;	Write a FITS file given an image and a FITS header
;CALLING SEQUENCE:
;	wrt_fits, outfil, head, image
;INPUT:
;	outfil	- The output file name
;	head	- A string array with FITS format header
;		  The routine will make sure each line is 80
;		  characters and that there are 36 (or 36*n) entries
;	image	- The data to save
;FUTURE OPTIONS:
;	If "head" is not defined, created a basic header to save
;	the data
;HISTORY:
;	Written 1-Jul-92 by M.Morrison
;	11-Sep-92 (MDM) - Fixed bug with checking that header was 36 
;			  elements long
;	19-Oct-92 (MDM) - Modification to swap bytes when running on
;			  DEC machines.  The FITS byte convention is the
;			  "non-DEC" byte order.
;	27-Oct-92 (MDM) - Modified to write zeros to the end of the 
;			  last data record to make it end on a 2880 byte
;			  logical record boundary.
;			- Corrected error in byte swapping fix of 19-Oct
;			- Added capability to build header if it is not
;			  passed.
;        1-Dec-93 (JBG) - added openw compatability for vms
;	 2-Feb-94 (MDM) - Modified to save floating points properly
;        6-Apr-94 (DMZ) - added check for DEC/OSF
;	15-Jun-94 (MDM) - Modified to check header for blank lines and
;			  remove them off the back end.  (done by looking
;			  for "END" and dropping all else behind it)
;	28-Jun-94 (MDM) - Corrected for saving floating points properly
;			  and expanded to work on double point images
;	10-Aug-94 (MDM) - Corrected the figuring of whether the END was there
;			- Got back in sync by adding DMZ 6-Apr-94 mod
;	02-Feb-01 (LS)	- call 'is_lendian' (single point 'swap_os' function)
;-
;
if (n_elements(head) eq 0) then h = mk_fits_head(image) else h = head
ss = where(strmid(h+'   ', 0, 6) eq 'END   ')
if (ss(0) eq -1) then h = [h, 'END'] else h = h(0:ss(0))	;drop stuff after "END"
n = n_elements(h)
if ((n mod 36) ne 0) then begin
    nadd = 36-(n mod 36)
    h = [h, strarr(nadd)]
end
h = strmid(h + '                                                                                ', 0, 80)
;
if !version.os eq 'vms' then begin
   openw, lun, outfil, 2880, /get_lun
endif else openw, lun, outfil, /get_lun
;
writeu, lun, h
;writeu, lun, image
;
;----- FITS format standard is not the convention used by DEC - Added 19-Oct-92
;
bitpix = get_nbytes(image(0))*8
if (data_type(image) ge 4) then bitpix=-bitpix
;qswap = 0
;os=strlowcase(!version.os)
qswap=is_lendian()
;if ((os eq 'vms') or (os eq 'ultrix') or (os eq 'osf')) then qswap = 1
;if ((!version.os eq 'vms') or (!version.os eq 'ultrix')) then qswap = 1
if ((qswap) and (abs(bitpix) gt 8)) then begin
    image0 = image		;have to make a duplicate copy since user might want to use "image"
    dec2sun, image0		;outside of this routine and don't want to corrupt it
    writeu, lun, image0
end else begin
    writeu, lun, image
end
;
nbyte = get_nbytes(image)		;MDM added 27-Oct-92
extra = 2880 - (nbyte mod 2880)
if (extra ne 2880) then writeu, lun, bytarr(extra)
;
free_lun, lun
end
