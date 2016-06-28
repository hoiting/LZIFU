;---------------------------------------------------------------------------
; Document name: timing.pro
; Created by:    Liyun Wang, NASA/GSFC, August 8, 1996
;
; Last Modified: Thu Aug  8 17:50:55 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO timing, name, output=output
;+
; PROJECT:
;       SOHO
;
; NAME:
;       TIMING
;
; PURPOSE:
;       To measure the run time of given IDL routine(s)
;
; CATEGORY:
;       Utility, misc
;
; SYNTAX:
;       timing, str
;
; EXAMPLES:
;       To report elapsed time on screen,
;          TIMING, ['a = findgen(300, 300)', 'b = a # a']
;
;       To pass out the elapsed time,
;          etime = 0.d0
;          TIMING, ['a = findgen(300, 300)', 'b = a # a'], out=etime
;
;       To pass out the elapsed time as a string,
;          etime = ''
;          TIMING, ['a = findgen(300, 300)', 'b = a # a'], out=etime
;
; INPUTS:
;       STR - String scalar or array to be interpreted and executed by IDL
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       OUTPUT - Named scalar variable. If defined and passed in, the
;                elapsed time will be returned via this variable (can
;                be a string or floating point number, depends on the
;                data type passed in) and no message is written to
;                screen. If OUTPUT is not passed or defined, a message
;                showing the elapsed time is printed on the screen.
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       Given string(s) must be a complete, valid IDL statement and
;       ready to be interpreted and executed.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, August 8, 1996, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   IF datatype(name) NE 'STR' THEN BEGIN
      PRINT, 'syntax:  timing, string'
      RETURN
   ENDIF

   time_begin = SYSTIME(1)
   FOR i=0, N_ELEMENTS(name)-1 DO BEGIN
      status = EXECUTE(name(i))
   ENDFOR
   time_end = SYSTIME(1)
   seconds = time_end-time_begin
   sec_str = STRTRIM(STRING(seconds, format='(f20.3)'),2)
   IF N_ELEMENTS(output) EQ 0 THEN $
      PRINT, 'Time elapsed: '+sec_str+' seconds.' $
   ELSE BEGIN
      IF datatype(output) EQ 'STR' THEN $
         output = sec_str $
      ELSE $
         output = seconds
   ENDELSE
   RETURN
END

;---------------------------------------------------------------------------
; End of 'timing.pro'.
;---------------------------------------------------------------------------
