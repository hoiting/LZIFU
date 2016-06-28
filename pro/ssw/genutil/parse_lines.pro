function parse_lines, input, ncpl
;+
;NAME:
;	parse_lines
;PURPOSE:
;	To take a string (or an array of strings) and to 
;	reformat it so that a given string is no longer than
;	a given value.  Breaks are done at with space
;SAMPLE CALLING SEQUENCE:
;	mat = parse_lines(input, ncpl)
;	mat = parse_lines(mat0, 50)
;INPUT:
;	input	- The string (or string array)
;	ncpl	- number of characters per line
;OUTPUT:
;	returns a string array with maximum length of "ncpl"
;HISTORY:
;	Written 1996 by M.Morrison
;	 6-Nov-96 (MDM) - Added documentation header
;	28-May-97 (MDM) - Added protection for when words are longer
;			  than the parsing length
;-
;
one_line = strtrim(arr2str(input, delim=' '), 2)
nchar = strlen(one_line)
nlin = nchar/ncpl + 5
out = strarr(nlin)
;
iline = 0
while (strlen(one_line) ne 0) and (iline lt nlin) do begin
    p = ncpl < strlen(one_line)
    if (strlen(one_line) gt ncpl) then while (strmid(one_line, p, 1) ne ' ') and (p gt 0) do p = p-1
    out(iline) = strmid(one_line, 0, p)
    iline = iline + 1
    one_line = strmid(one_line, p+1, 9999)
end

ss = where(out ne '')
if (ss(0) eq -1) then out = '' else out = out(ss)
;
return, out
end

