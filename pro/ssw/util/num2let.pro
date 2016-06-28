;+
; Project     :	SOHO - CDS
;
; Name        :	NUM2LET
;
; Purpose     :	Returns a letter ('A', 'B') from an input integer (1, 2).
;
; Explanation :	In the creation of file names, sometimes one would rather
;		suffix a filename with a letter instead of an integer (i.e.,
;		't111a.dat', 't111b.dat' instead of 't1111.dat', 't1112.dat').
;		This procedure prevents the user from defining an array of
;		alphabetic letters in each procedure where it is needed.
;
; Use         :	LET = NUM2LET(I)
;
; Inputs      :	I =	Integer between 1 and 26.  Accepts either scalars or
;			arrays.
;
; Opt. Inputs :	None.
;
; Outputs     :	LET =	Letter, returns 'a' for I=1 and 'z' for I=26.  Returns
;			'_' for any other number input.
;
; Opt. Outputs:	None.
;
; Keywords    :	CAPS:	Return a capital letter instead of a small letter.
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Utility.
;
; Prev. Hist. :	None.
;
; Written     :	Donald G. Luttermoser, GSFC/ARC,  8 December 1995
;
; Modified    :	Version 1, Donald G. Luttermoser, GSFC/ARC,  8 December 1995
;			Initial program.
;
; Version     :	Version 1,  8 December 1995
;-
FUNCTION NUM2LET, NUM, CAPS=CAPS
;
LET = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', $
       'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
;
IF N_PARAMS() EQ 0 THEN RETURN, '_'
N = N_ELEMENTS(NUM)
IF N EQ 1 THEN BEGIN
	IF (NUM(0) LT 1) OR (NUM(0) GT 26) THEN RETURN, '_'
	IF KEYWORD_SET(CAPS) THEN RETURN, STRUPCASE(LET(NUM(0)-1)) $
		ELSE RETURN, LET(NUM(0)-1)
ENDIF ELSE BEGIN
	LETRET = STRARR(N)
	FOR I=0,N-1 DO BEGIN
		IF (NUM(I) LT 1) OR (NUM(I) GT 26) THEN LETRET(I) = '_' $
		ELSE BEGIN
			IF KEYWORD_SET(CAPS) THEN LETRET(I) = $
				STRUPCASE(LET(NUM(I)-1)) $
			ELSE LETRET(I) = LET(NUM(I)-1)
		ENDELSE
	ENDFOR
	RETURN, LETRET
ENDELSE
;
END
