; Copyright (c) 1995, Strathclyde University .
; SCCS info: Module @(#)num_chk.pro	1.6 Date 3/13/95
;
;+
; PROJECT:
;       ADAS IBM MVS to   UNIX conversion
;
; NAME:
;	NUM_CHK()
;
; PURPOSE:
;	Checks to see if a string is a valid representation of an
;	integer or floating point number.
;
; EXPLANATION:
;	The IDL functions FIX and FLOAT will convert strings into number
;	values.  However FIX and FLOAT only require that the string
;	begins with a valid number.  For example FIX('38%h224') will
;	return the integer value 38 and no error is flagged.  This
;	function, NUM_CHK will check the entire string for errors.
;	You will still need to use FIX or FLOAT afterwards once NUM_CHK
;	has confirmed that the string is valid.
;
; USE:
;	Example;
;		error = num_chk(string,/integer)
;		if error eq 0 then begin
;			i = fix(string)
;		endif else begin
;			message,'Illegal integer input'
;		endelse
;
; INPUTS:
;	STRING   - The string to be checked.
;
; OPTIONAL INPUTS:
;	None
;
; OUTPUTS:
;	This function returns 0 if the string represents a valid number and
;	1 if it does not.
;
; OPTIONAL OUTPUTS:
;	None
;
; KEYWORD PARAMETERS:
;       INTEGER  - Set this keyword to specify that the string should
;		   represent an integer.  The default is that the string
;		   is assumed to represent a floating point value.
;
;	SIGN     -  if sign < 0, then only negative numbers allowed
;		    if sign = 0, then either sign allowed
;		    if sign > 0, then only positive values allowed.
;
; CALLS:
;	None
;
; SIDE EFFECTS:
;	None
;
; CATEGORY:
;	Data entry utility.
;	
; WRITTEN:
;       Andrew Bowen, Tessella Support Services plc, 8-Mar-1993
;
; MODIFIED:
;       Version 1       Andrew Bowen    28-May-1993
;                       First release.
;
;	Version 1.1     Lalit Jalota    17-Feb-1995
;			Added SIGN keyword.
;	Version 1.2     Lalit Jalota    27-Feb-1995
;			Added ESIGNS which allows exponent to be of any sign
;			even if number as a whole is negative or positive.
; VERSION:
;       1       28-May-1993
;       1.1     17-Feb-1995  
;       1.2     27-Feb-1995  
;-
;-----------------------------------------------------------------------------


FUNCTION num_chk, string, INTEGER=integer, SIGN=sign

		;**** Set defaults for keyword ****
  IF (NOT KEYWORD_SET(integer)) THEN integer=0
  IF (NOT KEYWORD_SET(sign)) THEN BEGIN 
	sign = 0
  ENDIF

		;**** arrays of legal characters ****
  numbers 	= '0123456789'
  decimal 	= '.'
  exponents 	= 'ED'
  esigns	= '+-'

  if (sign lt 0) then signs ='-'
  if (sign eq 0) then signs = '+-' 
  if (sign gt 0) then signs ='+'

		;**** trim leading and trailing blanks/compress white ****
		;**** space and convert any exponents to uppercase.   ****
  numstr = strupcase(strtrim(strcompress(string),2))

		;**** length of input string ****
  len = strlen(numstr)

  error = 0

  if integer eq 0 then stage = 1 else stage = 6

  for i = 0, len-1 do begin

    char = strmid(numstr,i,1)

		;**** the parsing steps 1 to 8 are for floating   ****
		;**** point, steps 6 to 8, which test for a legal ****
		;**** exponent, can be used to check for integers ****

;**** The parsing process is as follows;  Each character in the   ****
;**** string is checked against the valid list at the current     ****
;**** stage.  If no match is found an error is reported.  When a  ****
;**** match is found the stage number is updated as indicated     ****
;**** ready for the next character.  The valid end points are     ****
;**** indicated in the diagram.					  ****
;
;Stage	1		2		3		4
;
;Valid	sign	--> 2	dec-pt	--> 3	digit	--> 5	dec-pt	--> 5
;  "	dec-pt	--> 3	digit	--> 4			digit	--> 4
;  "	digit	--> 4					exp't	--> 6
;  "							END
;
;Stage	5		6		7		8
;
;Valid	digit	--> 5	esign	--> 7	digit	--> 8	digit	-->8
;  "	exp't	--> 6	digit	--> 8			END
;  "	END
;

    CASE stage OF

      1 : begin
        if 		strpos(signs,char) ge 0 	then stage = 2 $
	else if 	decimal eq char 		then stage = 3 $
	else if 	strpos(numbers,char) ge 0 	then stage = 4 $
	else 		error = 1
      end

      2 : begin
	if	 	decimal eq char 		then stage = 3 $
	else if 	strpos(numbers,char) ge 0 	then stage = 4 $
	else 		error = 1
      end

      3 : begin
	if	 	strpos(numbers,char) ge 0 	then stage = 5 $
	else 		error = 1
      end

      4 : begin
	if	 	decimal eq char 		then stage = 5 $
	else if 	strpos(numbers,char) ge 0 	then stage = 4 $
	else if		strpos(exponents,char) ge 0	then stage = 6 $
	else 		error = 1
      end

      5 : begin
	if	 	strpos(numbers,char) ge 0 	then stage = 5 $
	else if		strpos(exponents,char) ge 0	then stage = 6 $
	else 		error = 1
      end

      6 : begin
        if 		strpos(esigns,char) ge 0 	then stage = 7 $
	else if 	strpos(numbers,char) ge 0 	then stage = 8 $
	else 		error = 1
      end

      7 : begin
	if	 	strpos(numbers,char) ge 0 	then stage = 8 $
	else 		error = 1
      end

      8 : begin
	if	 	strpos(numbers,char) ge 0 	then stage = 8 $
	else 		error = 1
      end

    ENDCASE

  end

		;**** check that the string terminated legally ****
		;**** i.e in stages 4, 5 or 8                  ****
  if (stage ne 4) and (stage ne 5) and (stage ne 8) then error = 1

		;**** return error status to the caller ****
  RETURN, error

END
