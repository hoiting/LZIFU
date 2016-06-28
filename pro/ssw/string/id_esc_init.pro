;+
; NAME:
;	id_esc_init
; PURPOSE:
; 	Initialize the common blocks used by id_esc and id_unesc
; HISTORY:
;	Written 16-Jan-98, Craig DeForest
;	Added uppercase escape sequences, 20-Jan-98, CED
;       14-Feb-1998 - S.L.Freeland - nlm->n_elements
;	26-Jan-1999 - C.E.DeForest - changed escape codes to UPPERCASE
;		because IDL (may its creators plumb the depths of the inferno)
;		always returns UPPERCASE for structure tags.  This fixes 
;		a bug in fits_interp.
; METHOD:
;	Identifiers may have A-Z, 0-9, $, and _ in them.  We use the '$'
;	as a marker for two-digit escape sequences that indicate the 
;	unusable characters.  Most of the printable ones have sort-of-mnemonic
;	escape sequences defined in a nice array below.  The unprintable
;	and high-end ones, we handle with two-digit hexadecimal codes. 
;	All this stuff just generates a string array ('targets') that 
;	contains one of each kind of character that needs escaping, and 
;	another string array('escapes') that contains the two-letter code
;	for each of the unusable characters.
; SEE ALSO: id_esc, id_unesc
;-
pro id_esc_init
common id_escape,targets,escapes

; TARGETS contains the characters that need escaping; 
; ESCAPES contains their escape characters.  The 0th element
;     of each is for the special null-string escape for the beginning
;     of an identifier.

; Characters with nice 2-letter abbrevs
a = [	'''','RQ',	'`','DQ',	',','CO',	'.','PD', $
	'=','EQ',	'+','PL',	'-','_D',	'$','DS', $
	'@','AT',	'#','NO',	'?','QM',	'!','EP', $
	'%','PC',	'^','CT',	'&','AN',	'*','ST', $
	'\','BS',	'/','FS',	'>','GT',	'<','LT', $
	'[','LB',	']','RB',	'(','LP',	')','RP', $
	'{','LC',	'}','RC',	'~','TL',	'|','VB', $
	';','SC',	':','CN',	' ','__',	'	','_T' $
]
tg=''
es='ZZ'
for i=0,(n_elements(a)/2)-1 do begin
	tg=[tg,a(i*2)]
	es=[es,a(i*2+1)]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Add all the unprintable stuff that we haven't yet covered.  Anything
; that's not yet in the table from the above stuff is escaped with a 
; two-digit hex code.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Figure out what's not printable. 
;
unprintable = replicate(1,255)
pcodes=[ bindgen(26)+(byte('A'))(0), $
	 bindgen(26)+(byte('a'))(0), $
	 bindgen(10)+(byte('0'))(0), $
	 byte('$'), byte('_'),  $
	 (byte(tg))(*)          $
]
unprintable(pcodes) = 0
upcodes = where(unprintable eq 1)

for i=0,n_elements(upcodes)-1 do begin
	tg=[tg,string(byte(upcodes(i)))]
	es = [es,string(upcodes(i),format='(Z2.2)')]
end

;
; Replicate the whole list so that we can unescape 
; stuff regardless of case of the escape sequence...
;
targets = [tg,tg]
escapes = [es,strupcase(es)]

end
