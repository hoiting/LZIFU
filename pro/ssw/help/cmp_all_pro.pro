	PRO CMP_ALL_PRO, PATH1, PATH2, CODE_ONLY=CODE_ONLY
;+
; Project     : SOHO - CDS
;
; Name        : CMP_ALL_PRO
;
; Purpose     : Compares all procedure files in one path against another.
;
; Explanation : 
;
; Use         : CMP_ALL_PRO, PATH1, PATH2
;
; Inputs      : PATH1	= Primary path to use in the comparison.  All the
;			  ".pro" files in PATH1 will be compared against their
;			  equivalents (if any) in PATH2.
;
;		PATH2	= Secondary path list.  This is a character string
;			  listing one or more paths to use in looking for
;			  equivalents of the procedure files found in PATH1.
;			  The format is that used by FIND_WITH_DEF.
;
; Opt. Inputs : None.
;
; Outputs     : Messages about which files differ, or are not found, are
;		printed to the terminal screen.
;
; Opt. Outputs: None.
;
; Keywords    : CODE_ONLY = If set, then the FILE_DIFF routine is called to
;			    determine whether or not the routine differs only
;			    in documentation, or in the code as well.
;
; Calls       : CMP_FILES, FIND_WITH_DEF, CONCAT_DIR, BREAK_PATH
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
; Modified    : Version 1, William Thompson, GSFC, 30 April 1993.
;		Version 2, William Thompson, GSFC, 21 June 1993.
;			Modified so that "not found" messages are shorter.
;		Version 3, William Thompson, GSFC, 21 August 1997
;			Added keyword CODE_ONLY
;
; Version     : Version 3, 21 August 1997
;-
;
;
	ON_ERROR, 2
;
	IF N_PARAMS() NE 2 THEN MESSAGE,'Syntax:  CMP_ALL_PRO, PATH1, PATH2'
;
;  Look for any directory separators in PATH1.  If any are found, then call
;  this routine reiteratively.
;
	PATHS = BREAK_PATH(PATH1)
	IF N_ELEMENTS(PATHS) GT 2 THEN BEGIN
		FOR I = 1, N_ELEMENTS(PATHS)-1 DO CMP_ALL_PRO,PATHS(I),PATH2
		RETURN
	ENDIF
;
;  Otherwise, find all the procedure files in the current path.
;
	FILES1 = FINDFILE(CONCAT_DIR(PATH1,'*.pro'), COUNT=N_FILES1)
	IF N_FILES1 EQ 0 THEN BEGIN
		PRINT,'No procedure files found in ' + PATH1
		RETURN
	ENDIF
;
;  Don't make the second path too long when printing out the messages.
;
	TEMP = PATH2
	IF !VERSION.OS EQ 'vms' THEN SEP = ',' ELSE	$
		IF !VERSION.OS EQ 'windows' THEN SEP = ';' ELSE SEP = ':'
	PATHLIST2 = GETTOK(TEMP,SEP)
	IF TEMP NE '' THEN PATHLIST2 = PATHLIST2 + SEP + '...'
;
;  Check each file separately.
;
	FOR IFILE = 0,N_FILES1-1 DO BEGIN
		FILE1 = FILES1(IFILE)
		BREAK_FILE,FILE1,DISK,DIR,FILENAME,EXT,VERSION,NODE
		FILE2 = FIND_WITH_DEF(FILENAME,PATH2,'.pro',/NOCURRENT)
		IF FILE2 EQ '' THEN BEGIN
			PRINT,'Procedure ' + FILENAME + ' not found in ' + $
				PATHLIST2
		END ELSE IF CMP_FILES(FILE1,FILE2,CODE_ONLY=CODE_ONLY) EQ 1 $
			THEN PRINT,FILE1 + ' and ' + FILE2 + ' differ'
	ENDFOR
;
	RETURN
	END
