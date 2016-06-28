	PRO CONCAT4DOS, SUBDIRECTORIES=SUBDIRECTORIES
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	CONCAT4DOS
; Purpose     :	
;	Concatenates IDL procedure files for copying to DOS machine.
; Explanation :	
;	Concatenates IDL procedure files together into a form suitable for
;	copying to a DOS machine.
;
;	All the .PRO files in the current directory are copied into a special
;	"dos" subdirectory, with the following changes made:
;
;		1.  All filenames are truncated to eight characters.
;		2.  All procedure files with names beginning with the same
;		    first eight characters are concatenated together into a
;		    single file.
;
; Use         :	
;	CD, directory		;(go to desired directory)
;	CONCAT4DOS		;or CONCAT4DOS, /SUBDIRECTORIES
; Inputs      :	
;	None.
; Opt. Inputs :	
;	None.
; Outputs     :	
;	None.
; Opt. Outputs:	
;	None.
; Keywords    :	
;	SUBDIRECTORIES = If set, then subdirectories are also recursively
;			 processed.
; Calls       :	
;	FDECOMP
; Common      :	
;	None.
; Restrictions:	
;	None.
; Side effects:	
;	A "dos" subdirectory is created.  On VMS machines, a temporary command
;	file called "CONCAT4DOS.COM" is created and then destroyed.  On UNIX
;	machines the temporary file is called "concat4dos.sh".
; Category    :	
;	Utilities, Operating_system.
; Prev. Hist. :	
;	William Thompson, August 1992.
; Written     :	
;	William Thompson, GSFC, August 1992.
; Modified    :	
;	Version 1, William Thompson, GSFC, 9 July 1993.
;		Incorporated into CDS library.
;		Modified so that a temporary file is created on UNIX machines
;			as well, to speed up.
;	Version 2, William Thompson, GSFC, 18 April 1994.
;		Added SUBDIRECTORIES switch, and copying of documentation (.txt
;		or .tex) files.
; Version     :	
;	Version 2, 18 April 1994.
;-
;
	ON_ERROR,2
;
;  If the SUBDIRECTORIES switch was set, then first process the current
;  directory.  Make sure that a "dos" subdirectory is created.
;
	IF KEYWORD_SET(SUBDIRECTORIES) THEN BEGIN
		CONCAT4DOS
		IF !VERSION.OS EQ 'vms' THEN BEGIN
			DOSDIRFILE = FINDFILE('DOS.DIR',COUNT=N_FOUND)
			IF N_FOUND EQ 0 THEN SPAWN,	$
				'CREATE/DIRECTORY [.DOS]'
		END ELSE BEGIN
			DOSDIRFILE = FINDFILE('dos',COUNT=N_FOUND)
			IF N_FOUND EQ 0 THEN SPAWN, 'mkdir dos'
		ENDELSE
;
;  Next find all the subdirectories under the current directory.
;
		IF !VERSION.OS EQ 'vms' THEN BEGIN
			DIR_FILES = FINDFILE('*.dir')
			BREAK_FILE, DIR_FILES, D1, D2, DIRS, D3, D4, D5
		END ELSE SPAWN, 'find * -type d -print -prune', DIRS
;
;  Process each subdirectory, and move its "dos" file under the one for the
;  current directory.
;
		FOR I_DIR = 0,N_ELEMENTS(DIRS)-1 DO BEGIN
			DIR = DIRS(I_DIR)
			DIR8 = STRMID(DIR,0,8)
			IF (DIR NE '') AND (DIR NE 'dos') THEN BEGIN
				CD,DIR
				CONCAT4DOS, /SUBDIRECTORIES
				IF !VERSION.OS EQ 'vms' THEN BEGIN
					SPAWN,'RENAME DOS.DIR [-.DOS]' + $
						DIR8 + '.DIR'
				END ELSE BEGIN
					SPAWN,'mv dos ../dos/' + DIR8
				ENDELSE
				CD,'..'
			ENDIF
		ENDFOR
		RETURN
	ENDIF
;
;  Start of the section that processes the current directory.  First make sure
;  there are procedure files in the current directory.
;
	FILES = FINDFILE('*.pro',COUNT=N_FILES)
	IF N_FILES EQ 0 THEN BEGIN
		MESSAGE,'No procedure files found',/INFORMATIONAL
		RETURN
	ENDIF
;
;  Next, look for an existing "dos" directory.  Depending on whether the OS is
;  VMS or Unix, open up a command file to store all subsequent commands.  All
;  the commands will then be executed at the end with a single spawn.
;
	IF !VERSION.OS EQ 'vms' THEN BEGIN
		OPENW,UNIT,'CONCAT4DOS.COM',/GET_LUN
		PRINTF,UNIT,'$ SET VERIFY'
		DOSDIR = 'DOS.DIR'
	END ELSE BEGIN
		OPENW,UNIT,'concat4dos.sh',/GET_LUN
		PRINTF,UNIT,'set echo'
		DOSDIR = 'dos'
	ENDELSE
	DOSDIRFILE = FINDFILE(DOSDIR,COUNT=N_FOUND)
;
;  If an existing directory was found, then warn the user that all the ".pro"
;  files in that subdirectory will be deleted, and ask if the user wants to
;  continue.  If yes, then delete the files.
;
	IF N_FOUND NE 0 THEN BEGIN
		PRINT,'DOS directory already found'
		PRINT,'All .PRO files in the DOS directory will be deleted.'
		ASK,'Continue? ',ANSWER,'YN'
		IF ANSWER EQ 'Y' THEN BEGIN
			IF !VERSION.OS EQ 'vms' THEN BEGIN
				PRINTF,UNIT,'$ DELETE/NOLOG/NOCONFIRM ' + $
					'[.DOS]*.PRO;*'
			END ELSE BEGIN
				PRINTF,UNIT,'rm dos/*.pro'
			ENDELSE
		END ELSE GOTO, FINISH
;
;  Otherwise, create the subdirectory.
;
	END ELSE BEGIN
		IF !VERSION.OS EQ 'vms' THEN BEGIN
			PRINTF,UNIT,'$ CREATE/DIRECTORY [.DOS]'
		END ELSE BEGIN
			PRINTF,UNIT,'mkdir dos'
		ENDELSE
	ENDELSE
;
;  For each file, determine the eight character equivalent, and copy all files
;  beginning with those eight characters into a single file.
;
	LAST = ''
	FOR I=0,N_FILES-1 DO BEGIN
		FDECOMP,FILES(I),DISK,DIR,NAME,EXT,VER
		NAME8 = STRMID(NAME,0,8)
		IF NAME8 NE LAST THEN BEGIN
			IF STRLEN(NAME8) EQ 8 THEN NAME9 = NAME8 + '*' ELSE $
				NAME9 = NAME8
			IF !VERSION.OS EQ 'vms' THEN BEGIN
				PRINTF,UNIT,'$ COPY ' + NAME9 +	$
					'.PRO [.DOS]' + NAME8 + '.PRO'
			END ELSE BEGIN
				PRINTF,UNIT,'cat ' + NAME9 + '.pro > dos/' + $
					NAME8 + '.pro'
			ENDELSE
		ENDIF
		LAST = NAME8
	ENDFOR
;
;  If there are any documentation files (.txt or .tex), then copy them as well.
;
	FILES = FINDFILE('*.t*', COUNT=N_FILES)
	IF N_FILES NE 0 THEN FOR I=0,N_FILES-1 DO BEGIN
		FDECOMP,FILES(I),DISK,DIR,NAME,EXT,VER
		NAME8 = STRMID(NAME,0,8)
		EXT3 = STRMID(EXT,0,3)
		IF !VERSION.OS EQ 'vms' THEN BEGIN
			PRINTF,UNIT,'$ COPY ' + FILES(I) + ' [.DOS]' +	$
				NAME8 + '.' + EXT3
		END ELSE BEGIN
			PRINTF,UNIT,'cat ' + FILES(I) + ' > dos/' + $
				NAME8 + '.' + EXT3
		ENDELSE
	ENDFOR
;
;  Tell the command file to delete itself after processing, and execute it.
;
FINISH:
	IF !VERSION.OS EQ 'vms' THEN BEGIN
		PRINTF,UNIT,'$ DELETE/NOLOG/NOCONFIRM CONCAT4DOS.COM;*'
		FREE_LUN,UNIT
		SPAWN,'@CONCAT4DOS.COM'
	END ELSE BEGIN
		PRINTF,UNIT,'rm concat4dos.sh'
		FREE_LUN,UNIT
		SPAWN,'source concat4dos.sh'
	ENDELSE
;
	RETURN
	END
