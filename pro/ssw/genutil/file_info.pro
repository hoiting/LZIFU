function file_info, infil, finfo
;
;+
;NAME:
;	file_info
;PURPSOSE:
;	To return information about the file that is not included
;	in the FSTAT return
;CALLING SEQUENCE:
;	nfil = file_info(infil, finfo)
;INPUT:
;	infil	- The input file to find the information for.  It
;		  can be a wild card since 'findfile' will be used
;OUTPUT:
;	returns	- Number of files found
;	finfo	- A structure with the information in the file.
;			.SIZE
;			.REC_LEN
;			.FILENAME
;			.DIRECTORY
;			.DATE
;			.TIME
;			.PROTECTION
;			.OWNER
;HISTORY:
;	Written 14-Nov-91
;	 1-Mar-92 (MDM) - Updated the header information
;	18-Apr-92 (MDM) - Adjusted to accept an array of file name
;-
;
finfo0 = make_str("{dummy, name: ' ', "+$
			"size: long(0), "+$	;from fstat
			"rec_len: long(0), "+$	;from fstat

			"filename: ' ', "+ $
			"directory: ' ', "+ $

			"date: ' ', "+ $
			"time: ' ', "+ $
			"protection: ' ', "+ $
			"owner: ' '}")
;
nfil = 0
if (n_elements(infil) eq 1) then ff = findfile(infil) $
			else ff = infil
if (ff(0) ne '') then begin
    nfil = n_elements(ff)
    finfo = replicate(finfo0, nfil)
    ;
    for ifil=0,nfil-1 do begin
	infil0 = ff(ifil)
	break_file, infil0, dsk_log, dir, filnam, ext

	openr, lun, infil0, /get_lun
	f = fstat(lun)
	free_lun, lun

	finfo(ifil).name	= infil0
	finfo(ifil).size	= f.size
	finfo(ifil).rec_len	= f.rec_len

	finfo(ifil).filename	= filnam + ext
	finfo(ifil).directory	= dsk_log + dir

	cmd = 'ls -l ' + ff(ifil)
	spawn, cmd, result
	rarr = str2arr(strcompress(result(0)), delim=' ')
						;rarr(0) = protection
						;rarr(1) = ??
						;rarr(2) = owner
						;rarr(3) = size
						;rarr(4) = month
						;rarr(5) = date
						;rarr(6) = time
						;rarr(7) = filename
	finfo(ifil).date	= rarr(5) + '-' + rarr(4)
	finfo(ifil).time	= rarr(6)
	finfo(ifil).protection	= rarr(0)
	finfo(ifil).owner	= rarr(2)
   end
end
;
return, nfil
end
