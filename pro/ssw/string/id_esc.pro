;+
; NAME:
;	id_esc
; PURPOSE:
;	To bijectively map character strings to identifiers, allowing
;	(for example) FITS header strings to be used as structure 
;	tag names.
; METHOD:
;	Illegal characters are turned into escape sequences.  An 
;	escape sequence consists of a pair of identifier-legal characters
;	FOLLOWED by the (identifier-legal) character '$'.  The unusual 
;       escape structure (with the marker following the sequence)
;	is to allow the first character of the tag to always be an
;	alphabetical character.  There is a special escape ('zz$'), 
;	the 0th entry in the data arrays in the id_escape common block,
;	whose only purpose is to be an alphabetical character at the start
;	of an identifier if necessary.
; EXAMPLE:
;	print,id_esc(['3-days_left',"date_obs","time-obs"])
;	zz$3_d$days_left date_obs time_d$obs
; AUTHOR:
;	Craig DeForest
; HISTORY:
;	Written 16-Jan-98
; USAGE:
;	tagname = fitstagesc(fitsname)
; INPUTS:
;	The string to be escaped, or an array of 'em
; RETURNS:
;	The escaped string, or an array of 'em
;-
function id_esc,in
common id_escape,targets,escapes

if not isvalid(targets) then id_esc_init

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actual escaping code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
out = replicate('',n_elements(in))
for i=0,n_elements(in)-1 do begin
	for j=0,strlen(in(i))-1 do begin
		c = strmid(in(i),j,1)
		w = where(targets eq c)
		if(w(0) ne -1) then out(i) = out(i)+escapes(w(0))+'$' else out(i)=out(i)+c
	end
	first = (byte(strmid(out(i),0,1)))(0)
	if not ((first ge (byte('A'))(0) and first le (byte('Z'))(0)) or $
	        (first ge (byte('a'))(0) and first le (byte('z'))(0))) then $
		out(i) = escapes(0)+'$'+out(i)
end


return,out
end
		
	
