pro pr_logwindows, outenv, _extra=_extra, hc=hc
;;        lead=lead, trailing=trailing, envreplace=envreplace
;+
;   Name: pr_logwindows
;
;   Purpose: print or return Environment/Logical definitions
;
;   Calling Sequence:
;      pr_logenv [, /PATTERN1 [, /PATTERN2, /PATTERN3...] , /hc]
;
;   Calling Examples:
;      pr_logenv, /ssw
;
;   Input Parameters:
;      NONE
;
;   Keyword Parameters:
;;;      leading -  if set, match leading patterns only  (patt*) default (*patt*)
;;;      trailing - if set, match trailing patterns only (*patt) default (*patt*)
;      hc     -   if set, produce file c:\temp\setenv.txt
;      PATTERN -  ALL OTHER SWITCHES ARE INTERPRETED AS SEARCH STRINGS
;
;   Method:
;      keyword inheritance used to pass in search patterns as switches
;
;   Restrictions:
;      WINDOWS only
;      will only list env. vars. set by set_logenv (=> set_logwindows)
;
;   History:
;      28-Jul-2000 (RDB)
;-

common logwin,setenv_str,ksetenv

if strlowcase(!version.os_family) ne 'windows' then begin
   message,/info,'Use for WINDOWS commands, only.'
   return
endif


if n_elements(_extra) eq 0 then begin           ;pattern='*'
   wp = indgen(ksetenv)

endif else begin                                ;pattern supplied
   pattern=tag_names(_extra)
   wp=-1
   for jp = 0,n_elements(pattern)-1 do begin
;     print,pattern(jp)
     ww = where(strpos(setenv_str,pattern(jp)) ge 0)
     if ww(0) ge 0 then wp = [wp,ww]
   endfor
   if n_elements(wp) gt 1 then wp = wp(1:*)
   if wp(0) eq -1 then begin
      outenv =-1
      message,'N0 match found',/cont
      return
   endif

endelse

outenv = setenv_str(wp)
more,outenv

if keyword_set(hc) then prstr,setenv_str(wp),file='c:\temp\setenv.txt',/nodele

end
