	PRO CMP_LIBS, DIR1, P2, OUTPUT=OUTPUT, FILES=FILES, UNIX=UNIX,	$
		CODE_ONLY=CODE_ONLY, DIFFER_ONLY=DIFFER_ONLY
;+
; Project     : SOHO - CDS
;
; Name        : CMP_LIBS
;
; Purpose     : Compares one IDL library against another.
;
; Explanation : Compares all procedure files in one path against any matches
;		found in another path.  This routine differs from CMP_TREES in
;		that it does not expect the two libraries to be organized in
;		the same way.  Only procedure files found in the first
;		directory tree will be used for comparison.
;
; Use         : CMP_LIBS, DIR1, PATH2
;
; Inputs      : DIR1	= Start of the first directory tree to use in the
;			  comparison.  All the files "*.pro" in DIR1 and
;			  subdirectories will be compared against their
;			  equivalents (if any) in the tree given by PATH2.
;
;		PATH2	= A path expression for the second library (or set of
;			  libraries.  Use a plus sign before any directory to
;			  signal that the tree should be expanded.
;
; Opt. Inputs : None.
;
; Outputs     : Messages about which files differ, or are not found, are
;		printed to the terminal screen.
;
; Opt. Outputs: None.
;
; Keywords    : OUTPUT	= The name of a file to store the output in.  If not
;			  passed, then the output is written to the screen
;			  using /MORE.
;		FILES	= The filenames to compare.  If not passed, then
;			  "*.pro" is used.  The FILES keyword can be used to
;			  change this to "*.*" for instance.
;		UNIX	= If set, then the Unix "cmp" command is used to do the
;			  comparison, rather than depending on IDL.
;
;		CODE_ONLY = If set, then the FILE_DIFF routine is called to
;			    determine whether or not the routine differs only
;			    in documentation, or in the code as well.  This is
;			    only applicable to IDL .pro files.  Ignored if
;			    /UNIX is set.
;
;		DIFFER_ONLY = If set, then don't print any messages about files
;			      which are not found in the second library.
;
; Calls       : CMP_FILES, FIND_WITH_DEF, CONCAT_DIR, FIND_ALL_DIR
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
; Written     : William Thompson, GSFC, 26 May 1995
;
; Modified    : Version 1, William Thompson, GSFC, 26 May 1995
;		Version 2, William Thompson, GSFC, 21 August 1997
;			Added keyword CODE_ONLY
;		Version 3, William Thompson, GSFC, 17 February 1998
;			Added /NOCURRENT to FIND_WITH_DEF call
;
; Version     : Version 3, 17 February 1998
;-
;
	ON_ERROR, 2
;
	IF N_PARAMS() NE 2 THEN MESSAGE,'Syntax:  CMP_LIBS, DIR1, PATH2'
;
;  Open the output device, either a file or the screen.
;
	IF N_ELEMENTS(OUTPUT) EQ 1 THEN BEGIN
	    OPENW, U, OUTPUT, /GET_LUN
	END ELSE BEGIN
	    OPENW, U, FILEPATH(/TERMINAL), /MORE, /GET_LUN
	ENDELSE
;
;  Check the FILES keyword.
;
	IF N_ELEMENTS(FILES) EQ 0 THEN FILES = '*.pro'
;
;  Decide how to treat the directory names.  Determine the following:
;
;    TOP	The way the current directory is referred to in the operating
;		system being used.
;    TRAILING	The number of extra trailing characters in DIR1 that need to be
;		removed before combining with the subdirectories.
;
	IF !VERSION.OS EQ "vms" THEN BEGIN
	    TOP = '[]'
	    TRAILING = 1
	END ELSE BEGIN
	    TOP = '.'
	    TRAILING = 0
	ENDELSE
;
;  Find all the directories in the DIR1 and PATH2 trees.
;
	CD, CURRENT=CWD			;Save the current working directory
	CD, DIR1  &  PATH1 = FIND_ALL_DIR(TOP)
	CD, CWD
	PATH2 = FIND_ALL_DIR(P2, /PATH, /PLUS)
;
;  For each directory, compare the files.
;
	FOR I = 0,N_ELEMENTS(PATH1)-1 DO BEGIN
	    P1 = PATH1(I)
	    D1 = STRMID(DIR1,0,STRLEN(DIR1)-TRAILING) + STRMID(P1,1,999)
	    HEADER_PRINTED = 0
;
;  Find all the files of the requested type in the current path.
;
	    CD, D1  &  FILES1 = FINDFILE(FILES, COUNT=N1)
	    CD, CWD
	    IF N1 NE 0 THEN BEGIN
;
;  In VMS, remove all version numbers.
;
		IF !VERSION.OS EQ 'vms' THEN BEGIN
		    BREAK_FILE, FILES1, DISK, DIR, NAME, EXT
		    FILES1 = NAME + EXT
		ENDIF
;
;  Compare the files with matches.
;
		FMATCH1 = REPLICATE(1, N1)
		FOR J = 0,N1-1 DO BEGIN
		    F1 = CONCAT_DIR(D1,FILES1(J))
		    F2 = FIND_WITH_DEF(FILES1(J), PATH2, /NOCURRENT)
		    IF F2 EQ '' THEN FMATCH1(J) = 0 ELSE BEGIN
			IF KEYWORD_SET(UNIX) THEN BEGIN
			    SPAWN,'cmp '+F1+' '+F2,RESULT
			    TEST = RESULT(0) NE ''
			END ELSE TEST = CMP_FILES(F1,F2,	$
				CODE_ONLY=CODE_ONLY) EQ 1
			IF TEST THEN BEGIN
			    IF NOT HEADER_PRINTED THEN BEGIN
				PRINTF,U,' '
				PRINTF,U,P1
				HEADER_PRINTED = 1
			    ENDIF
			    PRINTF,U,'Files ' + F1 + ' and ' + F2 + ' differ'
			ENDIF
		    ENDELSE
		ENDFOR
;
;  Print out the names of all the files that don't have matches.
;
		FOR J = 0,N1-1 DO IF NOT FMATCH1(J) THEN BEGIN
		    IF NOT HEADER_PRINTED THEN BEGIN
			PRINTF,U,' '
			PRINTF,U,P1
			HEADER_PRINTED = 1
		    ENDIF
		    IF NOT KEYWORD_SET(DIFFER_ONLY) THEN PRINTF, U,	$
			    'File ' + FILES1(J) + ' not found in ' + P2
		ENDIF
	    ENDIF
	ENDFOR
;
;  Close the output and return.
;
	FREE_LUN,U
	RETURN
	END
