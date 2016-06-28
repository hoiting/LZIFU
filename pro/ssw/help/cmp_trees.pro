	PRO CMP_TREES, DIR1, DIR2, OUTPUT=OUTPUT, FILES=FILES, UNIX=UNIX, $
		QUOTED=QUOTED, CODE_ONLY=CODE_ONLY
;+
; Project     : SOHO - CDS
;
; Name        : CMP_TREES
;
; Purpose     : Compares all procedure files in one path against another.
;
; Explanation : Compares all procedure files in one path against the
;		corresponding files in another parallel path.  This routine
;		differs from CMP_LIBS in that the two trees are expected to be
;		identically structured.  If a routine is found in a particular
;		directory in the first tree, then it is expected to be in same
;		directory in the second tree.
;
; Use         : CMP_TREES, DIR1, DIR2
;
; Inputs      : DIR1	= Start of the first directory tree to use in the
;			  comparison.  All the files "*.pro" in DIR1 and
;			  subdirectories will be compared against their
;			  equivalents (if any) in the tree starting with DIR2.
;
;		DIR2	= Start of the second path list.
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
;               QUOTED  = If set, then filenames will be quoted.  When used
;                         with /UNIX, then gets around problem with embedded
;                         blanks in filenames.
;
;		CODE_ONLY = If set, then the FILE_DIFF routine is called to
;			    determine whether or not the routine differs only
;			    in documentation, or in the code as well.  This is
;			    only applicable to IDL .pro files.  Ignored if
;			    /UNIX is set.
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
; Written     : William Thompson, GSFC, 31 May 1994
;
; Modified    : Version 1, William Thompson, GSFC, 31 May 1994
;		Version 2, William Thompson, GSFC, 13 June 1994
;			Added keyword FILES.  Changed FILENAME to OUTPUT.
;			Added keyword UNIX.
;		Version 3, William Thompson, GSFC, 15 June 1994
;			Changed so that output is the same, regardless of
;			whether or not the UNIX keyword is set.
;		Version 4, William Thompson, GSFC, 31 March 1995
;			Changed so that only the directories where differences
;			are found are printed out.
;		Version 5, William Thompson, GSFC, 14 April 1995
;			Made compatible with VMS.
;		Version 6, William Thompson, GSFC, 21 August 1997
;			Added keyword CODE_ONLY
;               Version 7, William Thompson, GSFC, 27 July 2004
;                       Added keyword QUOTED
;
; Version     : Version 7, 27 July 2004
;-
;
;
	ON_ERROR, 2
;
	IF N_PARAMS() NE 2 THEN MESSAGE,'Syntax:  CMP_TREES, DIR1, DIR2'
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
;  Find all the directories in the DIR1 and DIR2 trees.
;
	CD, CURRENT=CWD			;Save the current working directory
	CD, DIR1  &  PATH1 = FIND_ALL_DIR(TOP)
	CD, DIR2  &  PATH2 = FIND_ALL_DIR(TOP)
	CD, CWD
;
;  Find all the directories which exist in both directories.
;
	MATCH1 = REPLICATE(-1,N_ELEMENTS(PATH1))
	MATCH2 = REPLICATE(-1,N_ELEMENTS(PATH2))
	FOR I = 0,N_ELEMENTS(PATH1)-1 DO	$
		MATCH1(I) = (WHERE(PATH1(I) EQ PATH2))(0)
	FOR I = 0,N_ELEMENTS(PATH2)-1 DO	$
		MATCH2(I) = (WHERE(PATH2(I) EQ PATH1))(0)
;
;  For each set of matched directories, compare the files.
;
	FOR I = 0,N_ELEMENTS(PATH1)-1 DO IF MATCH1(I) NE -1 THEN BEGIN
		P1 = PATH1(I)
		P2 = PATH2(MATCH1(I))
		D1 = STRMID(DIR1,0,STRLEN(DIR1)-TRAILING) + STRMID(P1,1,999)
		D2 = STRMID(DIR2,0,STRLEN(DIR2)-TRAILING) + STRMID(P2,1,999)
		HEADER_PRINTED = 0
;
;  Find all the files of the requested type in the current path.
;
		CD, D1  &  FILES1 = FINDFILE(FILES, COUNT=N1)
		CD, D2  &  FILES2 = FINDFILE(FILES, COUNT=N2)
		CD, CWD
		IF (N1+N2) NE 0 THEN BEGIN
;
;  In VMS, remove all version numbers.
;
			IF !VERSION.OS EQ 'vms' THEN BEGIN
				BREAK_FILE, FILES1, DISK, DIR, NAME, EXT
				FILES1 = NAME + EXT
				BREAK_FILE, FILES2, DISK, DIR, NAME, EXT
				FILES2 = NAME + EXT
			ENDIF
;
;  Find all the files which exist in both directories.
;
			FMATCH1 = REPLICATE(-1,N1>1)
			FMATCH2 = REPLICATE(-1,N2>1)
			FOR J = 0,N1-1 DO	$
				FMATCH1(J) = (WHERE(FILES1(J) EQ FILES2))(0)
			FOR J = 0,N2-1 DO	$
				FMATCH2(J) = (WHERE(FILES2(J) EQ FILES1))(0)
;
;  Compare the files with matches.
;
			FOR J = 0,N1-1 DO IF FMATCH1(J) NE -1 THEN BEGIN
				F1 = CONCAT_DIR(D1,FILES1(J))
				F2 = CONCAT_DIR(D2,FILES2(FMATCH1(J)))
				IF KEYWORD_SET(UNIX) THEN BEGIN
                                    IF KEYWORD_SET(QUOTED)          THEN $
                                      CMD = 'cmp "'+F1+'" "'+F2+'"' ELSE $
                                      CMD = 'cmp '+F1+' '+F2
                                    SPAWN,CMD,RESULT
                                    TEST = RESULT(0) NE ''
				END ELSE TEST = CMP_FILES(F1,F2,	$
					CODE_ONLY=CODE_ONLY) EQ 1
				IF TEST THEN BEGIN
					IF NOT HEADER_PRINTED THEN BEGIN
						PRINTF,U,' '
						PRINTF,U,P1
						HEADER_PRINTED = 1
					ENDIF
					PRINTF,U,'Files ' + FILES1(J) + $
						' differ'
				ENDIF
			ENDIF
;
;  Print out the names of all the files that don't have matches.
;
			FOR J = 0,N1-1 DO IF FMATCH1(J) EQ -1 THEN BEGIN
				IF NOT HEADER_PRINTED THEN BEGIN
					PRINTF,U,' '
					PRINTF,U,P1
					HEADER_PRINTED = 1
				ENDIF
				PRINTF,U, 'File ' + FILES1(J) +	$
					' not found in ' + D2
			ENDIF
			FOR J = 0,N2-1 DO IF FMATCH2(J) EQ -1 THEN BEGIN
				IF NOT HEADER_PRINTED THEN BEGIN
					PRINTF,U,' '
					PRINTF,U,P1
					HEADER_PRINTED = 1
				ENDIF
				PRINTF,U, 'File ' + FILES2(J) +	$
					' not found in ' + D1
			ENDIF
		ENDIF
	ENDIF
;
;  Print out the names of all the directories that don't have matches.
;
	PRINTF,U,' '
	FOR I = 0,N_ELEMENTS(PATH1)-1 DO IF MATCH1(I) EQ -1 THEN PRINTF,U, $
		'Subdirectory ' + PATH1(I) + ' not found in ' + DIR2
	PRINTF,U,' '
	FOR I = 0,N_ELEMENTS(PATH2)-1 DO IF MATCH2(I) EQ -1 THEN PRINTF,U, $
		'Subdirectory ' + PATH2(I) + ' not found in ' + DIR1
;
;  Close the output and return.
;
	FREE_LUN,U
	RETURN
	END
