;+
; NAME:
;	id_unesc
; PURPOSE:
;	Convert identifiers escaped with id_esc back into strings.
; USAGE:
;	string = id_unesc(identifier)
; INPUT:
;	The escaped string (identifier) to convert back to a regular string.
; OUTPUT: 
;	The original string
; HISTORY: 
;	Written 16-Jan-98
;       14-Feb-1998 - S.L.Freeland - nlm->n_elements
; AUTHOR:
;	Craig DeForest
; METHOD:
;	We have to work around IDL's awful, sick, and twisted string
;	handling.  We break the string into an array of characters
;	to find the '$' characters (escape sequences are two alphanumeric
;	(or '_') characters followed by '$'), and then convert the 
;	complete three-character sequence back into its original target
;	character using the information in the id_escape common block.
;	At the end, we patch the modified array back into a string.
;-
function id_unesc,in

; Common block containing escape sequences
common id_escape,targets,escapes
if not isvalid(targets) then id_esc_init

; Loop over strings, handling 'em one at a time...
out = in
for i=0,n_elements(in)-1 do begin
	
	;; Break the input string up into bytes to find the '$'s.
	ry = string(transpose(byte(in(i))))
	w = where(ry eq '$')
	
	;; Search and destroy escape sequences.
	if(w(0) ne -1) then begin

		;; No '$'s allowed next to the origin...
		if(w(0) lt 2) then message,"Illegal escape sequence in string '"+in(i)+"'."

		;; One by one, convert the escape sequences back into their
		;; original target characters.
		for j=0,n_elements(w)-1 do begin
			wes = where(escapes eq strmid(in(i),w(j)-2,2))
			if(wes(0) eq -1) then message,"Unknown escape sequence '"+strmid(in(i),w(j)-2,2)+"$' in string '"+in(i)+"'."
			ry(w(j)-2)= ''
			ry(w(j)-1)= targets(wes(0))
			ry(w(j)) = ''
		end
	end
	
	; Turn this motley assortment back into a string.  How evil
	; and contorted!
	bry = byte(ry)
	if(total(bry) eq 0) then out(i)='' else $
		out(i) = string(bry(where(bry ne 0)))

end

return,out
end
