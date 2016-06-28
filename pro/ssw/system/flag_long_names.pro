	PRO FLAG_LONG_NAMES
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	FLAG_LONG_NAMES
; Purpose     :	
;	Flags procedure names that would appear the same under DOS
; Explanation :	
;	Flags sets of IDL procedure names which have the same first eight
;	characters.  These would appear to be the same file on DOS machines.
;	The names of each set of .PRO files with the same first eight
;	characters are printed to the screen.
; Use         :	
;	CD, directory	;(go to desired directory)
;	FLAG_LONG_NAMES
; Inputs      :	
;	None.
; Opt. Inputs :	
;	None.
; Outputs     :	
;	None.
; Opt. Outputs:	
;	None.
; Keywords    :	
;	None.
; Calls       :	
;	None.
; Common      :	
;	None.
; Restrictions:	
;	None.
; Side effects:	
;	None.
; Category    :	
;	Utilities, Operating_system.
; Prev. Hist. :	
;	William Thompson, January 1993.
; Written     :	
;	William Thompson, GSFC, January 1993.
; Modified    :	
;	Version 1, William Thompson, GSFC, 9 July 1993.
;		Incorporated into CDS library.
; Version     :	
;	Version 1, 9 July 1993.
;-
;
	ON_ERROR,2
;
;  First make sure there are procedure files in the current directory.
;
	FILES = FINDFILE('*.pro',COUNT=N_FILES)
	IF N_FILES EQ 0 THEN MESSAGE,'No procedure files found'
;
;  For each file, determine the eight character equivalent, and look for
;  duplicates.
;
	LAST = ''
	DUPS = ''
	FOR I=0,N_FILES-1 DO BEGIN
		FDECOMP,FILES(I),DISK,DIR,NAME,EXT,VER
		NAME8 = STRMID(NAME,0,8)
		IF NAME8 NE LAST THEN BEGIN
			IF N_ELEMENTS(DUPS) GT 1 THEN	$
				FOR J=0,N_ELEMENTS(DUPS)-1 DO PRINT,DUPS(J)
			DUPS = NAME
		END ELSE BEGIN
			DUPS = [DUPS,NAME]
		ENDELSE
		LAST = NAME8
	ENDFOR
;
	RETURN
	END
