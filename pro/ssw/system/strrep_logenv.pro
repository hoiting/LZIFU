function strrep_logenv, inarray, environ
;+
;   Name: rep_logenv
;
;   Purpose: replace environmental translation with envionmental
;
;   Input Parameters:
;      inarray - string array (ex: file name list or path name list)
;      environ - 
;
;   Restrictions:
;      Assume translation in same column for all inarray for now
;
;   History:
;      18-feb-1996 S.L.Freeland - shorten displayed path and file information
;      15-Jul-1996 S.L.Freeland - double delimiters->one delimiter
;      20-Feb-1998 S.L.Freeland - default to 1st character match 
;-

if not data_chk(inarray,/string) or not data_chk(environ,/string,/scaler) then begin
   message,/info,"out=strlogenv(textarray,envscaler)"
   return,inarray
endif

environ='$' + str_replace(environ,'$','')	; assure 1 and only 1 $

trans=get_logenv(environ)

matchl=strjustify([' ',trans],/right)	        ; match lenghts (for strput)

outarray=inarray				; dont clobber input

delim=get_delim()
if trans ne '' then begin
   which=where(strpos(outarray,trans) eq 0,wcnt)
   if wcnt gt 0 then begin
      temp=outarray(which)
      strput,temp,matchl(0),strpos(temp(0),trans)
      outarray(which)= environ + delim + strtrim(temp,2)
   endif
endif 

chkdoub=where(strpos(outarray,delim+delim) ne -1,sscnt)
for i=0,sscnt-1 do outarray(chkdoub(i))= $
   str_replace(outarray(chkdoub(i)),delim+delim,delim)   

return,outarray

end
