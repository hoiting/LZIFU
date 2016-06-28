;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: ppd.pro
; Created by:    Liyun Wang, GSFC/ARC, November 12, 1994
;
; Last Modified: Tue Jan 10 16:46:41 1995 (lwang@orpheus.nascom.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;+
; NAME:
;	PPD
;
; PURPOSE:
;       Pop up directory name from the directory stack and CD to it.
;
; CALLING SEQUENCE:
;	PPD
;
; SIDE EFFECTS:
;	The top entry of the directory stack is removed.
;
; RESTRICTIONS:
;	Popping up a directory from an empty stack causes a warning
;	message to be printed.  The current directory is not changed
;	in this case.
;
; COMMON BLOCKS:
;	STACK_DIR:  Contains the stack.
;       CDD:        Common block used by CDD.
;
; MODIFICATION HISTORY:
;	17, July, 1989, Written by AB, RSI.
;       Version 2, Liyun Wang, GSFC/ARC, November 12, 1994
;          Modified from POPD for use with CDD and PD.
;
; VERSION:
;       Version 2, November 12, 1994
;-
PRO ppd
   COMMON cdd, home_dir, home_len, idl_path, diskname
   COMMON stack_dir, STACK
   ON_ERROR, 2                  ; Return to caller on error
   n_stack = N_ELEMENTS(stack) 
   IF n_stack EQ 0 THEN MESSAGE, 'No other directory.'
   cdd, stack(0)
   curr_dir = stack(0)
   IF n_stack EQ 1 THEN delvarx, stack ELSE BEGIN
      stack = stack(1:*)
   ENDELSE
   IF N_ELEMENTS(stack) NE 0 THEN PRINT, curr_dir, stack ELSE $
      PRINT, curr_dir
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'ppd.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
