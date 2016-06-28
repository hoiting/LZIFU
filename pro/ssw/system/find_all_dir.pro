	FUNCTION FIND_ALL_DIR, PATH, PATH_FORMAT=PATH_FORMAT,	$
		PLUS_REQUIRED=PLUS_REQUIRED, RESET=RESET
;+
; Project     :	SOHO - CDS
;
; Name        :	FIND_ALL_DIR()
;
; Purpose     :	Finds all directories under a specified directory.
;
; Explanation :	This routines finds all the directories in a directory tree
;		when the root of the tree is specified.  This provides the same
;		functionality as having a directory with a plus in front of it
;		in the environment variable IDL_PATH.
;
; Use         :	Result = FIND_ALL_DIR( PATH )
;
;		PATHS = FIND_ALL_DIR('+mypath', /PATH_FORMAT)
;		PATHS = FIND_ALL_DIR('+mypath1:+mypath2')
;
; Inputs      :	PATH	= The path specification for the top directory in the
;			  tree.  Optionally this may begin with the '+'
;			  character but the action is the same unless the
;			  PLUS_REQUIRED keyword is set.
;
;			  One can also path a series of directories separated
;			  by the correct character ("," for VMS, ":" for Unix)
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is a list of directories starting
;		from the top directory passed and working downward from there.
;		Normally, this will be a string array with one directory per
;		array element, but if the PATH_FORMAT keyword is set, then a
;		single string will be returned, in the correct format to be
;		incorporated into !PATH.
;
; Opt. Outputs:	None.
;
; Keywords    :	PATH_FORMAT	= If set, then a single string is returned, in
;				  the format of !PATH.
;
;		PLUS_REQUIRED	= If set, then a leading plus sign is required
;				  in order to expand out a directory tree.
;				  This is especially useful if the input is a
;				  series of directories, where some components
;				  should be expanded, but others shouldn't.
;
;		RESET	= Often FIND_ALL_DIR is used with logical names.  It
;			  can be rather slow to search through these
;			  subdirectories.  The /RESET keyword can be used to
;			  redefine an environment variable so that subsequent
;			  calls don't need to look for the subdirectories.
;
;			  To use /RESET, the PATH parameter must contain the
;			  name of a *single* environment variable.  For example
;
;				setenv,'FITS_DATA=+/datadisk/fits'
;				dir = find_all_dir('FITS_DATA',/reset,/plus)
;
;			  The /RESET keyword is usually combined with
;			  /PLUS_REQUIRED.
;
; Calls       :	FIND_WITH_DEF, BREAK_PATH
;
; Common      :	None.
;
; Restrictions:	PATH must point to a directory that actually exists.
;
;		On VMS computers this routine calls a command file,
;		FIND_ALL_DIR.COM, to find the directories.  This command file
;		must be in one of the directories in IDL's standard search
;		path, !PATH.
;
;		This procedure does not yet work in MacOS.  However, some
;		routines may call this routine anyway with the /PLUS_REQUIRED
;		keyword.  This should be safe to do.
;
; Side effects:	None.
;
; Category    :	Utilities, Operating_system.
;
; Prev. Hist. :	None.
;
; Written     :	William Thompson, GSFC, 3 May 1993.
;
; Modified    :	Version 1, William Thompson, GSFC, 3 May 1993.
;		Version 2, William Thompson, GSFC, 6 July 1993.
;			Added sort to spawned command under Unix.
;		Version 3, William Thompson, GSFC, 16 May 1995
;			Modified to support multiple directories.
;			Added keyword PLUS_REQUIRED
;		Version 4, William Thompson, GSFC, 6 August 1996
;			Added keyword RESET
;			Fixed bug that caused routine to not work right with
;			environment variables that started with "+"
;		Version 5, William Thompson, GSFC, 9 August 1996
;			Try to trap errors where invalid environment names are
;			passed.
;		Version 6, William Thompson, GSFC, 20 August 1996
;			Fixed bug when trying to reset environment variable
;			that only points to a single directory.
;		Version 7, William Thompson, GSFC, 13 February 1998
;			Include Windows and MacOS seperators.
;		Version 8, William Thompson, GSFC, 8 June 1998
;			Include call to FIND_WIND_DIR.  This gives complete
;			functionality under Windows.
;		Version 9, William Thompson, GSFC, 30-Nov-1999
;			Include call to IS_DIR
;		Version 10, William Thompson, GSFC, 03-Dec-1999
;			Don't use IS_DIR output in Unix--possible problem with
;			automount on some systems.
;               Version 11, Zarro (SM&A/GSFC), 23-March-00
;                       Removed all calls to IS_DIR
;		Version 12, William Thompson, GSFC, 02-Feb-2001
;			In Windows, use built-in expand_path if able.
;		Version 13, William Thompson, GSFC, 23-Apr-2002
;			Follow logical links in Unix
;			(Suggested by Pascal Saint-Hilaire)
;		Version 14, Zarro (EER/GSFC), 26-Oct-2002
;			Saved/restored current directory to protect against
;                       often mysterious directory changes caused by 
;                       spawning FIND in Unix
;               Version 15, William Thompson, GSFC, 9-Feb-2004
;                       Resolve environment variables in Windows.
;
; Version     :	Version 15
;-
;
	ON_ERROR, 2
;
	IF N_PARAMS() NE 1 THEN MESSAGE,	$
		'Syntax:  Result = FIND_ALL_DIR( PATH )'

;-- save current directory

   cd,current=current

;
;  If more than one directory was passed, then call this routine reiteratively.
;  Then skip directly to the test for the PATH_FORMAT keyword.
;
	PATHS = BREAK_PATH(PATH, /NOCURRENT)
	IF N_ELEMENTS(PATHS) GT 1 THEN BEGIN
		DIRECTORIES = FIND_ALL_DIR(PATHS[0],	$
			PLUS_REQUIRED=PLUS_REQUIRED)
		FOR I = 1,N_ELEMENTS(PATHS)-1 DO DIRECTORIES =	$
			[DIRECTORIES, FIND_ALL_DIR(PATHS[I],	$
				PLUS_REQUIRED=PLUS_REQUIRED)]
		GOTO, TEST_FORMAT
	ENDIF
;
;  Test to see if the first character is a plus sign.  If it is, then remove
;  it.  If it isn't, and PLUS_REQUIRED is set, then remove any trailing '/'
;  character and skip to the end.
;
	DIR = PATHS[0]
	IF STRMID(DIR,0,1) EQ '+' THEN BEGIN
		DIR = STRMID(DIR,1,STRLEN(DIR)-1)
	END ELSE IF KEYWORD_SET(PLUS_REQUIRED) THEN BEGIN
		DIRECTORIES = PATH
		IF STRMID(PATH,STRLEN(PATH)-1,1) EQ '/' THEN	$
			DIRECTORIES = STRMID(PATH,0,STRLEN(PATH)-1)
		GOTO, TEST_FORMAT
	ENDIF
;
;  On VMS machines, spawn a command file to find the directories.  Make sure
;  that any logical names are completely translated first.  A leading $ may be
;  part of the name, or it may be a signal that what follows is a logical name.
;
	IF !VERSION.OS_FAMILY EQ 'vms' THEN BEGIN
		REPEAT BEGIN
			IF STRMID(DIR,STRLEN(DIR)-1,1) EQ ':' THEN	$
				DIR = STRMID(DIR,0,STRLEN(DIR)-1)
			TEST = TRNLOG(DIR,VALUE) MOD 2
			IF (NOT TEST) AND (STRMID(DIR,0,1) EQ '$') THEN BEGIN
				TEMP = STRMID(DIR,1,STRLEN(DIR)-1)
				TEST = TRNLOG(TEMP, VALUE) MOD 2
			ENDIF
			IF TEST THEN DIR = VALUE
		ENDREP UNTIL NOT TEST
		COMMAND_FILE = FIND_WITH_DEF('FIND_ALL_DIR.COM',!PATH,'.COM')
		SPAWN,'@' + COMMAND_FILE + ' ' + COMMAND_FILE + ' ' + DIR, $
			DIRECTORIES
;
;  For windows, if IDL version 5.3 or later, use the built-in EXPAND_PATH
;  program.  However, first resolve any environment variables.
;
	END ELSE IF !VERSION.OS_FAMILY EQ 'Windows' THEN BEGIN
                WHILE STRMID(DIR,0,1) EQ '$' DO BEGIN
                    FSLASH = STRPOS(DIR,'/')
                    IF FSLASH LT 1 THEN FSLASH = STRLEN(DIR)
                    BSLASH = STRPOS(DIR,'/')
                    IF BSLASH LT 1 THEN BSLASH = STRLEN(DIR)
                    SLASH = FSLASH < BSLASH
                    TEST = STRMID(DIR,1,SLASH-1)
                    DIR = GETENV(TEST) + STRMID(DIR,SLASH,STRLEN(DIR)-SLASH)
                ENDWHILE
		IF !VERSION.RELEASE GE '5.3' THEN BEGIN
		    TEMP = DIR
		    TEST = STRMID(TEMP, STRLEN(TEMP)-1, 1)
		    IF (TEST EQ '/') OR (TEST EQ '\') THEN	$
			    TEMP = STRMID(TEMP,0,STRLEN(TEMP)-1)
		    DIRECTORIES = EXPAND_PATH('+' + TEMP, /ALL, /ARRAY)
		END ELSE DIRECTORIES = FIND_WIND_DIR(DIR)
;
;  On Unix machines spawn the Bourne shell command 'find'.  First, if the
;  directory name starts with a dollar sign, then try to interpret the
;  following environment variable.  If the result is the null string, then
;  signal an error.
;
	END ELSE BEGIN
		IF STRMID(DIR,0,1) EQ '$' THEN BEGIN
		    SLASH = STRPOS(DIR,'/')
		    IF SLASH LT 0 THEN SLASH = STRLEN(DIR)
		    EVAR = GETENV(STRMID(DIR,1,SLASH-1))
		    IF SLASH EQ STRLEN(DIR) THEN DIR = EVAR ELSE	$
			    DIR = EVAR + STRMID(DIR,SLASH,STRLEN(DIR)-SLASH)
		ENDIF
;		IF IS_DIR(DIR) NE 1 THEN MESSAGE,	$
;			'A valid directory must be passed'
		IF STRMID(DIR,STRLEN(DIR)-1,1) NE '/' THEN DIR = DIR + '/'
		SPAWN,'find ' + DIR + ' -follow -type d -print | sort -', $
			DIRECTORIES, /SH
;
;  Remove any trailing slash character from the first directory.
;
		TEMP = DIRECTORIES[0]
		IF STRMID(TEMP,STRLEN(TEMP)-1,1) EQ '/' THEN	$
			DIRECTORIES[0] = STRMID(TEMP,0,STRLEN(TEMP)-1)
	ENDELSE
;
;  Reformat the string array into a single string, with the correct separator.
;  If the PATH_FORMAT keyword was set, then this string will be used.  Also use
;  it when the RESET keyword was passed.
;
TEST_FORMAT:
	DIR = DIRECTORIES[0]
	CASE !VERSION.OS_FAMILY OF
		'vms':  SEP = ','
		'Windows':  SEP = ';'
		'MacOS': Sep = ','
		ELSE:  SEP = ':'
	ENDCASE
	FOR I = 1,N_ELEMENTS(DIRECTORIES)-1 DO DIR = DIR + SEP + DIRECTORIES[I]
;
;  If the RESET keyword is set, and the PATH variable contains a *single*
;  environment variable, then call SETENV to redefine the environment variable.
;  If the string starts with a $, then try it both with and without the $.
;
	IF KEYWORD_SET(RESET) THEN BEGIN
		EVAR = PATH
		TEST = GETENV(EVAR)
		IF TEST EQ '' THEN IF STRMID(EVAR,0,1) EQ '$' THEN BEGIN
			EVAR = STRMID(EVAR,1,STRLEN(EVAR)-1)
			TEST = GETENV(EVAR)
		ENDIF
		IF (TEST NE '') AND (TEST NE PATH) AND (DIR NE PATH) THEN $
			DEF_DIRLIST, EVAR, DIR
	ENDIF
;
        
;-- restore current directory

        cd,current

	IF KEYWORD_SET(PATH_FORMAT) THEN RETURN, DIR ELSE RETURN, DIRECTORIES
;
	END
