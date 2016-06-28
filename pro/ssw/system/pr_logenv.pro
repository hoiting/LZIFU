pro pr_logenv, outenv, _extra=_extra, hc=hc, status=status, $
   	lead=lead, trailing=trailing, envreplace=envreplace
;+
;   Name: pr_logenv
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
;      leading -  if set, match leading patterns only  (patt*) default (*patt*)
;      trailing - if set, match trailing patterns only (*patt) default (*patt*)
;      hc     -   if set, produce hardcopy
;      status -   if set, prepend status (user/machine/date/!version...)
;      PATTERN -  ALL OTHER SWITCHES ARE INTERPRETED AS SEARCH STRINGS
;
;   Method:
;      keyword inheritance used to pass in search patterns as switches
;
;   History:
;      23-jun-1995 (SLF) 
;-
if n_elements(envreplace) eq 0 then envreplace='SSW' 

if n_elements(_extra) eq 0 then pattern='*' else pattern=tag_names(_extra)
lead=(['*',''])(keyword_set(trailing))
trail=(['*',''])(keyword_set(leading))

pattern=lead+pattern+trail

trans=get_logenv(pattern,outenv=env)
if n_elements(trans) eq 1 and trans(0) eq '' then begin
   env="No " + (["environmental","logical"])(!version.os eq 'VMS') + "  matches for pattern " 
   trans=pattern
endif

stat=keyword_set(status)
hc=keyword_set(hc)
show=(n_params() eq 0) or (1-hc)

outenv=''
if stat then pr_status,outenv		; pre-pend system information

ss=where(env ne '',sscnt)

for i=0,n_elements(envreplace)-1 do begin
   oneenv=get_logenv(envreplace(i))
   chkss=where(strpos(trans,oneenv) eq 0, sscnt)
   if sscnt gt 0 then begin
      temp=trans(chkss)
      match=strjustify(['$' + envreplace(i),oneenv],/right)
      strput,temp,match(0)
      trans(chkss)=strtrim(temp,2)
   endif
endfor

outtrans=strjustify(env)+ ' = ' + strjustify(trans)

if max(strlen(outtrans)) lt 76 then outtrans=strjustify(outtrans,/box)
outtrans=strtrim(outtrans,2)
outenv=[outenv,'', outtrans]

ss=where(outenv ne '',sscnt)

if sscnt eq 0 then outenv='' else outenv=outenv(ss)

if show then prstr,outenv

return
end
