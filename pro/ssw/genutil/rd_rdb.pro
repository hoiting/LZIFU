function rd_rdb, infil_arr, item, timarr, data, $
	mat=mat, struct=struct, qdebug=qdebug, nocomment=nocomment0
;
;+
;NAME:
;	rd_rdb
;PURPOSE:
;	To read an RDB file (text file with TAB delimiters).  Optionally
;	put the information into a structure with tag names equal to the
;	column label.
;SAMPLE CALLING SEQUENCE:
;	mat = rd_rdb('/data14/morrison/raw_hc_detune/400c3100_01h.28679/record.rdb')
;	mat = rd_rdb(infil, 'DATAMEAN', timarr, data)
;	mat = rd_rdb(infil, /struct)
;	mat = rd_rdb(infil, item, timarr, data)
;INPUT:
;	infil	- The input file(s)
;OPTIONAL INPUT:
;	item	- The label which needs to be extracted into an array
;OUTPUT:
;	returns a 2-D string array of the RDB file contents.  OPtionally
;		  return a structure
;	timarr	- A time structure array (with .TIME and .DAY tags)
;	data	- The values for "item"
;OPTIONAL KEYWORD INPUT:
;	struct	- If set, then return a structure with tags equal to the
;		  column labels.
;HISTORY:
;	Written 18-Jun-96 by M.Morrison
;	12-Jul-96 (MDM) - Corrected structure option when input is an array
;	18-Sep-96 (MDM) - Adjusted to allow for "#" in the field/tag names
;			- Corrected for reading structures without "REF_T"
;	 6-Nov-96 (MDM) - Added documentation information
;	19-Feb-99 (MDM) - Added NOCOMMENT option (defaults to "\")
;			- Further mods to skip comment lines
;-
;
if (keyword_set(nocomment0)) then nocomment = nocomment0 $
				else nocomment = '\'
timarr = 0b
data = 0b
out2 = 0b
for ifil=0,n_elements(infil_arr)-1 do begin
    infil = infil_arr(ifil)
    print, 'Now Reading: ' + infil
    ;
    ;;openr, lun, infil, /get_lun
    ;;lin = ''
    ;;readf, lun, lin
    lin = rd_tfile(infil, nocomment=nocomment)
    lin = lin(0)
    ss=where(byte(lin) eq 9b, nss)
    ncol = nss+1
    ;;free_lun, lun
    ;
    mat = rd_tfile(infil, ncol, delim=string(9b), nocomment=nocomment)	;defaults to "#" which is bad
    ;
    if (keyword_set(struct)) then begin
	mat = strtrim(strcompress(mat),2)
	ntag = n_elements(mat(*,0))
	str = '{dummy'
	for i=0,ntag-1 do begin
	    ss = where_arr( byte(mat(i,2:*)), [indgen(26)+97, indgen(26)+65])
	    qhex = strupcase(strmid(mat(i,2), 0, 2)) eq '0X'
	    case 1 of
		qhex:		ref = '0L'
		ss(0) ne -1:	ref = '" "'
		else:		ref = '0.0'
	    endcase
	    if (keyword_set(qdebug)) then print, i, mat(i,0), mat(i,2), '   ', ref
	    tag = mat(i,0)
	    tag = str_replace(tag, '#', '_num')
	    if (tag eq '') then tag = 'tag' + strtrim(i,2)
	    str = str + ', ' + tag + ': ' + ref
	end
	str = str + '}'
	out0 = make_str(str, str_name=str_name)
	;
	n = n_elements(mat(0,*))-2
	out = replicate(out0, n)
	for i=0,ntag-1 do begin
	    ss = where_arr( byte(mat(i,2:*)), [indgen(26)+97, indgen(26)+65])
	    qhex = strupcase(strmid(mat(i,2), 0, 2)) eq '0X'
	    case 1 of
		qhex: begin
			out00 = lonarr(n)
			temp = strmid(mat(i,2:*), 2, 99)
			reads, temp, out00, format='(z)'
	    	    end
		ss(0) ne -1: 	out00 = mat(i,2:*)
		else:		out00 = float(mat(i,2:*))
	    endcase
	    out.(i) = reform(out00)
	    if (keyword_set(qdebug)) then print, i, mat(i,0), mat(i,2)
	end
    end else begin
	out = mat
    end
    ;
    if (data_type(out2) eq 1) then out2 = out else out2 = [out2, temporary(out)]
    ;
    if (n_elements(item) eq 0) then item = mat(0,0)
    ;
    ss = where(strtrim(mat(*,0),2) eq item)
    data0 = float( mat(ss(0), 2:*) )
    if (n_elements(data0) ne 1) then data0 = reform(data0)

    ss = where(strtrim(mat(*,0),2) eq 'T_REF')
    if (ss(0) ne -1) then begin
	tim0 = str_replace(mat(ss(0), 2:*), '.', '/')
	tim0 = strmid(str_replace(tim0, '_', ' '), 0, 19)
	timarr0 = anytim2ints(tim0)
	if (n_elements(timarr0) ne 1) then timarr0 = reform(timarr0)
    end else begin
	timarr0 = 0b
    end

    if (data_type(timarr) eq 8) then begin
	data = [data, temporary(data0)]
	timarr = [timarr, temporary(timarr0)]
    end else begin
	data = temporary(data0)
	timarr = temporary(timarr0)
    end
end
;
return, out2
end
