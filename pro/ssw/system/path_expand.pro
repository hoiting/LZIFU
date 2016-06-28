	FUNCTION PATH_EXPAND, PATH
;+
; Project     : SOHO - CDS
;
; Name        : 
;	PATH_EXPAND
; Purpose     : 
;	Expands VMS logical names in a search path.
; Explanation : 
;	Expands any logical names in an IDL search PATH (e.g. !PATH) into the
;	directories defined by that logical name.   *** VMS only. ***
; Use         : 
;	Result = PATH_EXPAND(PATH)
; Inputs      : 
;	PATH = Valid IDL search path, e.g. !PATH.
; Opt. Inputs : 
;	None.
; Outputs     : 
;	The result of the function is a string containing a modified search
;	path with the logical names expanded.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	None.
; Calls       : 
;	GETTOK
; Common      : 
;	None.
; Restrictions: 
;	The variable PATH must be in the proper format for !PATH.
; Side effects: 
;	None.
; Category    : 
;	Documentation, Online_help.
; Prev. Hist. : 
;	William Thompson
; Written     : 
;	William Thompson, GSFC, 1992.
; Modified    : 
;	Version 1, William Thompson, GSFC, 23 April 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 24 September 1993.
;		Renamed to PATH_EXPAND so as to not conflict with IDL v3.1
;		internal routine called EXPAND_PATH.
;       Version 3, Liyun Wang, NASA/GSFC, October 2, 1996
;               Used CALL_FUNCTION to call TRNLOG, which is available
;               only on VMS system           
; Version     : 
;	Version 3, October 2, 1996
;-
;
	TEMP = PATH
	EXP_PATH = ''
	WHILE TEMP NE '' DO BEGIN
		THISPATH = GETTOK(TEMP,',')
		LASTCHAR = STRMID(THISPATH,STRLEN(THISPATH)-1,1)
		IF LASTCHAR EQ ':' THEN BEGIN
			LOGNAME = STRMID(THISPATH,0,STRLEN(THISPATH)-1)
                        IF NOT CALL_FUNCTION('TRNLOG', LOGNAME, TRANS, $
                                             /FULL_TRANSLATION) THEN $
				TRANS = THISPATH
		END ELSE TRANS = THISPATH
;
	        FOR ITRANS=0,N_ELEMENTS(TRANS)-1 DO BEGIN
		        IF EXP_PATH EQ '' THEN BEGIN
				EXP_PATH = TRANS(ITRANS)
			END ELSE BEGIN
			        EXP_PATH = EXP_PATH + ',' + TRANS(ITRANS)
			ENDELSE
		ENDFOR
	ENDWHILE
;
	RETURN, EXP_PATH
	END
