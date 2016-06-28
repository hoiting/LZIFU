function file_info2, infil, finfo, ls=ls, qdebug=qdebug
;
;+
;NAME:
;	file_info2
;PURPSOSE:
;	To return information about the file from "ls -l" output
;CALLING SEQUENCE:
;	nfil = file_info2(infil, finfo)
;	nfil = file_info2(dummy, finfo, ls=ls)
;INPUT:
;	infil	- The input file to find the information for.  It
;		  can contain a wild card.  It needs to be a scalar if
;		  wild cards are being used.
;OPTIONAL KEYWORD INPUT:
;	ls	- The "ls -l" results can be passed directly to 
;		  this routine.  
;OUTPUT:
;	returns	- Number of files found
;	finfo	- A structure with the information in the file.
;			.SIZE
;			.FILENAME
;			.DIRECTORY
;			.DATE
;			.DAY
;			.TIME
;			.PROTECTION
;			.OWNER
;HISTORY:
;	Written by M.Morrison 7-Aug-92 taking file_info.pro as a start
;	 7-Oct-92 (MDM) - Added QDEBUG
;			- Fixed problem with recognizing dates from last year
;	20-Oct-92 (MDM) - Minor mod
;	22-Oct-92 (MDM) - Modification to the way that year is recognized
;	12-May-93 (MDM) - Modification to work on the SGI machine
;	19-May-93 (MDM) - Added " around ls spawn to work on ADS file
;	28-Jul-93 (DMZ) - Alpha OSF fix (ls command)
;	27-Jun-94 (MDM) - Changed how routine figured out if "ls" was performed
;			  on SGI or OSF machine. (not based on !version.os)
;	 1-Aug-95 (MDM) - Patched a bug where infil could come in AND ls
;			  is passed in.
;	 3-Jan-96 (MDM) - Added patch to handle the case where the file size is
;			  over 10 megabytes (the filename was being corrupted)
;	 5-Feb-97 (MDM) - Corrected to work with years over 2000
;	 7-May-97 (MDM) - Modified to use /NOSHELL on the spawn command if
;			  the input has no wildcards
;			- Added some workaround for file not found (kinda
;			  bogus, but at least it won't crash internally)
;-
;
finfo0 = {file_info2, $
			 name: ' ', $

			 filename: ' ',    $
			 directory: ' ',    $

			 size: long(0),   $
			 date: ' ',    $
			 day: fix(0), $
			 time: long(0),    $
			 protection: ' ',    $
			 owner: ' '} 
;
tarr = anytim2ex(!stime)
yr = tarr(6)
;
nfil = 0
finfo = finfo0
ff = ''
if (keyword_set(ls)) then ls1 = ls	;MDM added 1-Aug-95
case n_elements(infil) of
    0: if (keyword_set(ls)) then begin
	if (strmid(ls(0), 0, 5) eq 'total') then begin
	    if (n_elements(ls) eq 1) then return, nfil	;no files in the directory
	    ls1 = ls(1:*) 
	end else begin
	    ls1 = ls
	end
	ff = strmid(ls1, 45, 100)
	rarr = str2arr(strcompress(ls1(0)), delim=' ')
	if (n_elements(rarr) ge 9) then ff = strmid(ls1, 54, 100)	;MDM added 27-Jun-94
       end
    1: ff = findfile(infil(0))
    else: ff = infil
end
;
if (ff(0) ne '') then begin
    nfil = n_elements(ff)
    finfo = replicate(finfo0, nfil)
    ;
    for ifil=0,nfil-1 do begin
	infil0 = ff(ifil)
	break_file, infil0, dsk_log, dir, filnam, ext

	finfo(ifil).name	= infil0

	finfo(ifil).filename	= filnam + ext
	finfo(ifil).directory	= dsk_log + dir

	if (keyword_set(ls)) then begin
	    result = ls1(ifil)
	end else begin
	    cmd = ['ls', '-l', ff(ifil)]
	    if (keyword_set(qdebug)) then print, 'NOSHELL Command: ', cmd
	    spawn, cmd, result, /noshell
	    ;;cmd = 'ls -l "' + ff(ifil) + '"'
	    ;;spawn, cmd, result
	end
	rarr = str2arr(strcompress(result(0)), delim=' ')
						;rarr(0) = protection
						;rarr(1) = ??
						;rarr(2) = owner
						;			group on IRIX and OSF
						;rarr(3) = size
						;rarr(4) = month
						;rarr(5) = date
						;rarr(6) = time
						;rarr(7) = filename
	if (rarr(0) eq '') then rarr = strarr(8)	;MDM 7-May-97 (for file not found)

	if (n_elements(rarr) ge 9) then rarr = [rarr(0:2), rarr(4:8)]		;IRIX or OSF "ls"
;       case (!version.os) of
;           'IRIX': rarr = [rarr(0:2), rarr(4:8)]         ;added 12-May-93
;           'OSF':  rarr = [rarr(0:2), rarr(4:8)]         ;added 28-Jul-93
;           else:
;       endcase

	date_str = rarr(5) + '-' + rarr(4)
	;;if (strmid(rarr(6), 0, 3) eq '199') then date_str = date_str + '-' + strmid(rarr(6),2,2) $	;rarr(6) is year
	;if (strpos(rarr(6), ':') eq -1) then date_str = date_str + '-' + strmid(rarr(6),2,2) $		;rarr(6) is year
	if (strpos(rarr(6), ':') eq -1) then date_str = date_str + '-' + strmid(rarr(6),0,4) $		;rarr(6) is year
					else date_str = date_str+'-'+strtrim(yr,2) + ' ' + rarr(6)	;rarr(6) is time
	del = int2secarr(date_str, !stime)
	if (del gt 86400) then date_str = rarr(5) + '-' + rarr(4) + '-' + strtrim(yr-1,2) + ' ' + rarr(6)	;it was last year
	ints = anytim2ints(date_str)
	finfo(ifil).size	= rarr(3)
	finfo(ifil).date	= date_str
	finfo(ifil).day		= ints.day
	finfo(ifil).time	= ints.time
	finfo(ifil).protection	= rarr(0)
	finfo(ifil).owner	= rarr(2)

	if (keyword_set(ls)) then begin		;MDM added 3-Jan-96
	    infil0 = rarr(7)
	    break_file, infil0, dsk_log, dir, filnam, ext
	    finfo(ifil).name	= infil0

	    finfo(ifil).filename	= filnam + ext
	    finfo(ifil).directory	= dsk_log + dir
	end

	if (keyword_set(qdebug)) then begin
	    print, 'Input: ', result(0)
	    print, 'File Name: ', finfo(ifil).name
	    print, 'File size: ', finfo(ifil).size
	    print, 'Output: ', fmt_tim(finfo(ifil)), finfo(ifil).date
	end
   end
end
;
return, nfil
end
