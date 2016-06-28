function rd_tfiles, filename, ncols, skip, hskip=hskip,$
                 delim=delim, nocomment=nocomment, compress=compress,   $
                 quiet=quiet, autocol=autocol, convert=convert, header=header, $
		 filemap=filemap, colpos=colpos
;+
;NAME:
;	rd_tfiles
;PURPOSE:
;	Allow an array of input files and then basically call RD_TFILE
;SAMPLE CALLING SEQUENCE:
;	out = rd_tfiles(filenames)
;	out = rd_tfiles(filenames, ncols, nocomment='#')
;INPUT:
;	filenames- Files to read
;OPTIONAL INPUT:
;	ncols	- Number of columns to read
;	skip	- Number of lines of header to skip
;OPTIONAL KEYWORD OUTPUT:
;	filemap	- An array mapping which lines came from which
;		  files.  The length is identical to the output
;		  and the integer value is the subscript into
;		  the input filename array
;HISTORY:
;	Written 26-Nov-97 by M.Morrison
;	 1-Dec-97 (MDM) - Added FILEMAP output option
;	15-Apr-98 (MDM) - Added COLPOS passtrough
;-
;
nfil = n_elements(filename)
for ifil=0,nfil-1 do begin
    txt0 = rd_tfile(filename(ifil), junk, skip, hskip=hskip)
    if (keyword_set(nocomment) or keyword_set(ncols)) then $
		txt0 = strnocomment(txt0, comment=nocomment, /remove_nulls)
    ;
    nn = n_elements(txt0)
    if (ifil eq 0) then begin
	txt = temporary(txt0)
	filemap = intarr(nn)
    end else begin
	txt = [txt, temporary(txt0)]
	filemap = [filemap, intarr(nn)+ifil]
    end
end
;
if (keyword_set(ncols)) then txt = str2cols(txt, delim, ncols=ncols, colpos=colpos, $
					/ignore_extra_cols, /trim)
return, txt
end