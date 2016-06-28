	FUNCTION CMP_FILES, FILENAME1, FILENAME2, CODE_ONLY=CODE_ONLY
;+
; Project     : SOHO - CDS
;
; Name        : CMP_FILES()
;
; Purpose     : Checks whether two text files are identical or not.
;
; Explanation : This routine reads in two text files and compares them line by
;		line to determine if they are different or not, similar to the
;		Unix routine "cmp".
;
; Use         : Result = CMP_FILES( FILENAME1, FILENAME2 )
;
;		IF CMP_FILES('file1.pro','file2.pro') EQ 1 THEN	$
;			PRINT,'file1.pro and file2.pro are different'
;
; Inputs      : FILENAME1, FILENAME2 are the names of the two files to check
;		against each other.
;
; Opt. Inputs : None.
;
; Outputs     : The result of the function is one of the following values:
;
;			0 = The files are identical
;			1 = The files are different
;			2 = An error occured
;
; Opt. Outputs: None.
;
; Keywords    : CODE_ONLY = If set, then the FILE_DIFF routine is called to
;			    determine whether or not the routine differs only
;			    in documentation, or in the code as well.  This is
;			    only applicable to IDL .pro files.
;
; Calls       : None.
;
; Common      : None.
;
; Restrictions: None.
;
; Side effects: None.
;
; Category    : Software_management.
;
; Prev. Hist. : None.
;
; Written     : William Thompson, GSFC, 30 April 1993.
;
; Modified    : Version 1, William Thompson, GSFC, 30 April 1993
;		Version 2, William Thompson, GSFC, 21 August 1997
;			Added keyword CODE_ONLY
;
; Version     : Version 2, 21 August 1997
;-
;
;
	ON_ERROR, 2
;
	IF N_PARAMS() NE 2 THEN MESSAGE,	$
		'Syntax:  Result = CMP_FILES( FILENAME1, FILENAME2 )
;
;  If the CODE_ONLY keyword is set, then use FILE_DIFF.
;
	IF KEYWORD_SET(CODE_ONLY) THEN BEGIN
	    RESULT = FILE_DIFF(FILENAME1, FILENAME2, /IDLPRO, MESS=MESS)
	    IF RESULT AND (STRUPCASE(STRMID(MESS,0,4)) EQ 'CODE') THEN	$
		    RETURN, 1 ELSE RETURN, 0
	ENDIF
;
	ON_IOERROR, ERROR_POINT
	GET_LUN, UNIT1
	GET_LUN, UNIT2
	OPENR, UNIT1, FILENAME1
	OPENR, UNIT2, FILENAME2
;
	LINE1 = ''
	LINE2 = ''
	RESULT = 1
	WHILE NOT (EOF(UNIT1) AND EOF(UNIT2)) DO BEGIN
		IF EOF(UNIT1) OR EOF(UNIT2) THEN GOTO, EXIT_POINT
		READF,UNIT1,LINE1
		READF,UNIT2,LINE2
		IF LINE1 NE LINE2 THEN GOTO, EXIT_POINT
	ENDWHILE
	RESULT = 0
	GOTO, EXIT_POINT
;
ERROR_POINT:
	MESSAGE, /CONTINUE, 'An error has occurred comparing ' +	$
		FILENAME1 + ' and ' + FILENAME2
	RESULT = 2
;
EXIT_POINT:
	ON_IOERROR, NULL
	FREE_LUN, UNIT1
	FREE_LUN, UNIT2
	RETURN, RESULT
	END
