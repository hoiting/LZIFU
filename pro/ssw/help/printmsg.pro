;===============================================================================
;+
; Name:
;
;      PRINTMSG
;
; Purpose:
;
;      Print an error/warning/informational message
;
; Category:
;
;      Error handling
;
; Calling sequence:
;
;      PRINTMSG, msg , [ /WARNING , /INFORMATIONAL ] 
;
; Input:
;
;      msg : error/warning/informational message
;
; Keyword parameters:
;
;      WARNING = set message prefix to '%W> '
;      INFORMATIONAL = set message prefix to '%I> '
;      NONAME = suppresses name of routine issuing the message
;      NOPREFIX = suppresses prefix
;
; Outputs:
;
;      Printout
;
; Common blocks:
;
;      None
;
; Calls:
;
;      MESSAGE
;
; Description:
;
;      Simple modification of built-in routine MESSAGE: calls MESSAGE after 
;      altering the message prefix according to the values of the keywords 
;      (default: '%E> '). Another difference is that a message is always 
;      issued, even when !QUIET eq 1 and keyword INFORMATIONAL is set.
;
; Side effects:
;
;      Same as MESSAGE
;
; Modification history:
;
;      V. Andretta,    1/Nov/1999 - Written.
;      V. Andretta,   18/Nov/1999 - Added NONAME and NOPREFIX keywords
;
; Contact:
;
;      andretta@na.astro.it
;-
;===============================================================================
;

  pro PRINTMSG,msg,WARNING=warn,INFORMATIONAL=info $
              ,NONAME=noname,NOPREFIX=noprefix

  ON_ERROR,2

;=== Check input

  if N_ELEMENTS(msg) eq 0 then msg=''

;=== Get name of caller and add it to the message

  HELP,CALLS=caller
  caller=(STR_SEP(caller[1],' '))[0]
  if not KEYWORD_SET(noname) then err_msg=caller+': '+msg[0] $
                             else err_msg=msg[0]

;=== Set prefix

  prefix=!ERROR_STATE.msg_prefix
  case 1 of
    KEYWORD_SET(info): !ERROR_STATE.msg_prefix='%I> '
    KEYWORD_SET(warn): !ERROR_STATE.msg_prefix='%W> '
    else:              !ERROR_STATE.msg_prefix='%E> '
  endcase

;=== Issues message

  curr_quiet=!QUIET
  !QUIET=0
  if KEYWORD_SET(info) then MESSAGE,err_msg,/INFO,/NONAME,NOPREFIX=noprefix $
                       else MESSAGE,err_msg,/CONT,/NONAME,NOPREFIX=noprefix
  !QUIET=curr_quiet

;=== Restore previous message prefix

  !ERROR_STATE.msg_prefix=prefix

;=== Normal end

  RETURN
  END
