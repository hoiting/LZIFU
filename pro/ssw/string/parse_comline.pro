;+
;
; NAME:
;	PARSE_COMLINE 
;
; PURPOSE:
;       This function parses a string that has fields separated by commas or blanks and 
;       return an array of strings, one string per field.
;
; CATEGORY:
;       STRING
;
; CALLING SEQUENCE:
;       Result = PARSE_COMLINE(Input_string,Nvalues) 
;
; CALLS:
;       Checkvar.
;
; INPUTS:
; 	Input_string:	String to parse.
;
; OUTPUTS:
;	Result:		Parsed string.
;
; OPTIONAL OUTPUTS:
;	Nvalues:	Number of separate fields found on line.
;
; KEYWORDS:
;       NOCOMMAS:	Blanks separate fields in Input_string rather than
;   		 	commas.See PROCEDURE for explanation.
;	DELIM:		Alternative delimiter to comma, single character
;	NOCASE:		If set, case of command line is left unchanged, 
;			otherwise it is changed to uppercase. 
;
; PROCEDURE:
;       When the NOCOMMA keyword is set, blanks separate fields.  When 
;	NOCOMMA is not set, commas separate fields, and fields may contain 
;	blanks.  Used mainly for user-input strings that contain multiple 
;	entries in one string. 
;
; MODIFICATION HISTORY:
;       RAS, 1992
;	Mod. 11/28/94  Fixed bug with non-comma delimiters!
;	Mod. 07/14/94  Delim input left as string
;       Mod. 05/08/96 by RCJ. Added documentation.
;-          
;----------------------------------------------------------------------------

function parse_comline, command_line, nvalues, nocommas=nocommas, $
	delim=delim_in, nocase=nocase

com_line= command_line
;IF THERE ARE NO COMMAS THEN PUT THEM IN BETWEEN NON-BLANK GROUPS SO
;THE DEFAULT SECTION CAN PARSE THE STRINGS
if keyword_set(nocommas) then begin ;put in commas between strings
	wchar =where( byte(com_line) ne 32B, nchar)
	dchar = wchar(1:*)-wchar
	wgt1  = where(dchar gt 1,nchar)
	if nchar ge 1 then for i=0,nchar-1 do $
		strput,com_line,',',wchar(wgt1(i))+1
endif
checkvar, delim_in, ','
checkvar, delim, delim_in
com_line =delim + com_line + delim 
byte_line = byte(com_line) ;change it into bytes to ease parsing

delim = (byte(delim))(0) 

wcomma = where( byte_line eq delim, ncomma) ;WHERE ARE THE COMMAS
svalues = strarr(ncomma-1) 	;
for i=0,ncomma-2 do $
	svalues(i) = strmid(com_line,wcomma(i)+1,wcomma(i+1)-wcomma(i)-1)
if not keyword_set(nocase) then svalues = strupcase(strtrim( svalues,2)) $
	else svalues = strtrim(svalues,2)

nvalues = ncomma-1

return, svalues
end
