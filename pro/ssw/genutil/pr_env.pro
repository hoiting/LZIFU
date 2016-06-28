pro pr_env, _extra=_extra
;+
;   Name: pr_evn
;
;   Purpose: simple synonym for pr_logenv
;
;   SEE DOC HEADER FOR PR_LOGENV
;
;   History:
;      15-feb-1996 (S.L.Freeland)
;      26-Jul-2000 (R.D.Bentley) - modified for windows
;-
; just pass everything through to pr_logenv

if strlowcase(!version.os_family) ne 'windows' then $
   pr_logenv,_extra=_extra              $
   else pr_logwindows,_extra=_extra

return
end
