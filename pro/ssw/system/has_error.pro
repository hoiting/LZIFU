;---------------------------------------------------------------------------
; Document name: has_error.pro
; Created by:    Liyun Wang, NASA/GSFC, September 18, 1997
;
; Last Modified: Thu Sep 18 09:55:26 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION has_error, error, prefix=prefix
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       HAS_ERROR()
;
; PURPOSE: 
;       Handles an error message and return the error status
;
; CATEGORY:
;       Utility
; 
; EXPLANATION:
;       This routine checks the given error string, which is usually
;       returned from a calling program, to see if it is null. If not,
;       the error string is shown in a pop-up widget and the routine
;       returns 0; otherwise it returns 1.
;
; SYNTAX: 
;       Result = has_error(error)
;
; EXAMPLES:
;       a = anytim2utc(b, /ecs, error=error)
;       IF has_error(error) then return
;       
; INPUTS:
;       ERROR - String scalar for error message
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - 0/1, flag indicating ERROR is null or not
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       PREFIX - String scalar or vector which will be used as prefix
;                of message string to show up
;
; COMMON:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       If ERROR is not null, a message window is popped up and
;       operation can not preceed until this window is dismissed.
;
; HISTORY:
;       Version 1, September 18, 1997, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   estatus = error NE '' 
   IF N_ELEMENTS(prefix) EQ 0 THEN prefix = ''
   IF estatus THEN xack, [prefix, error], /modal
   RETURN, estatus
END

;---------------------------------------------------------------------------
; End of 'has_error.pro'.
;---------------------------------------------------------------------------
