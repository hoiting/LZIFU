function unixtime2ex, in, qdebug=qdebug
;+
;NAME:
;	unixtime2ex
;PURPOSE:
;	To convert time of the form "Fri Feb 19 12:54:04 PST 1999"
;	to external format
;SAMPLE CALLING SEQUENCE:
;	out = unixtime2ex(in)
;	out = unixtime2ex("Fri Feb 19 12:54:04 PST 1999")
;	out = unixtime2ex("Fri Feb  19 02:15:29 1999")
;INPUT:
;	in 	- String array of times
;OUTPUT:
;	out	- External time format 7xN array
;HISTORY:
;	Written 19-Feb-99 by M.Morrison
;-
;
mat = str2cols(in, /unalign)
n = n_elements(mat(*,0))
iyr = n-1	;last item
tmp = mat(2,*) + '-' + mat(1,*) + '-' + mat(iyr,*) + ' ' + mat(3,*)
if (keyword_set(qdebug)) then print, tmp
out = anytim2ex(tmp)
;
return, out
end