function zformat, in, n, caps=caps, mdi_leading=mdi_leading, string=string
;+
;NAME:
;	zformat
;PURPOSE:
;	To format some output as hex.  It's needed because of
;	handling of negative integer numbers and because of
;	a problem with the alpha's
;SAMPLE CALLING SEQUENCE:
;	out = zformat(888)
;	out = zformat(in, n)
;OPTIONAL KEYWORD INPUT:
;	caps	- If set, make the alphabetic characters upper
;		  case
;	mdi_leading - If set, prepend a "0x" to the output.
;	string	- If set, then make the output a single string
;HISTORY:
;	Written 11-Jul-96 by M.Morrison
;-
;
fmt = '(z8.8)'
if (keyword_set(caps)) then fmt = strupcase(fmt)
if (n_elements(n) eq 0) then n = 4
;
out = string(in, format=fmt)
if (n ne 8) then out = strmid(out, 8-n, n)
;
if (keyword_set(mdi_leading)) then out = '0x' + out
if (keyword_set(string)) then out = arr2str(out, delim=' ')
return, out
end
