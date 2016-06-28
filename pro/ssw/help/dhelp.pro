;---------------------------------------------------------------------------
; Document name: dhelp.pro
; Created by:    Liyun Wang, GSFC/ARC, March 20, 1995
;
; Last Modified: Mon Mar 20 10:51:25 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO DHELP, v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,$
           v18,v19,v20,structure=structure,dlevel=dlevel
;+
; PROJECT:
;       SOHO - SUMER
;
; NAME:
;       DHELP
;
; PURPOSE: 
;       Diagnostic HELP (activated only when DEBUG reaches DLEVEL)
;
; EXPLANATION:
;       This routine acts similarly to the HELP command, except that
;       it is activated only when the environment variable DEBUG is
;       set to be equal to or greater than the debugging level set by
;       DLEVEL (default to 1).  It is useful for debugging.  
;       
; CALLING SEQUENCE: 
;       DHELP, [,/structure] v1 [, v2, ...] [,dlevel=dlevel]
;
; INPUTS:
;       V1, V2, ... - List of variables to be passed to the HELP command
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       All input variables are printed out on the screen
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       STRUCTURE - Set this keyword to show strcuture
;       DLEVEL    - An integer indicating the debugging level; defaults to 1
;
; CALLS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
;       Can be activated only when the environment variable DEBUG (indicating 
;          the debugging level) is set to an integer which is equal to
;          or greater than DLEVEL
;       Can print out a maximum of 20 variables (depending on how many
;          is listed in the code)
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Written March 20, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, Liyun Wang, GSFC/ARC, March 20, 1995
;
; VERSION:
;       Version 1, March 20, 1995
;-
;
   ON_ERROR, 2
   ON_IOERROR, io_error
   debug = FIX(getenv('DEBUG'))
   IF N_ELEMENTS(dlevel) EQ 0 THEN dlevel = 1
   IF dlevel GT debug THEN RETURN   
   np = N_PARAMS()
   cmd = 'HELP'
   IF KEYWORD_SET(structure) THEN cmd = cmd+',/structure'
   FOR i = 1, np DO cmd = cmd+',v'+STRTRIM(i,2)
   status = EXECUTE(cmd)
   
io_error:
;---------------------------------------------------------------------------
;  If the conversion fails, it means that either DEBUG is not set, or
;  set to something else that cannot be converted to integer
;---------------------------------------------------------------------------
   RETURN
END

;---------------------------------------------------------------------------
; End of 'DHELP.PRO'.
;---------------------------------------------------------------------------
