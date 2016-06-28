function map_format, format, dcount
;+
;   Name: map_format
;
;   Purpose: return data type string(s) for input format list
;
;   Input Parameters:
;      format - format string  like '(1x,i4,2x,f4.2,1x,i6)'
;   
;   Output Parameters:
;     dcount - number of valid elements returned
;  
;      function returns IDL defintion string implied by format
;      (for dynamic structure building  - for example, see table2struct.pro)  
;     
;   Calling Example: (generally called by structure building applications)
;     IDL> more,map_format('(1x,i4,2x,f4.1,d3.1,1x,a10)')
;          0l                    
;          0.0                   
;          0.0d                  
;          ''                    
;      ; Note that only data elements (I,F,D,E,A) map to an output
;      ; X (skips), etc are ignored  
;
;   Restrictions:
;     nested group counts not yet allowed (simple formats)  
;     No optimization for byte,int,long (all Ixx map to longs)
;   
;   History:
;     23-oct-1997 - S.L.Freeland (for GLS generic ascii table-> data reader)
;  
;
dcount=0
if not data_chk(format,/string) then begin
   prstr,strjustify(["Need a FORMAT string...", $
	  "IDL> fmaps=map_format('(FORMAT)')"],/box)
   return,''
endif   
; -------- trim blanks and leading/trailing parens --------------
ifmt=strtrim(format,2)
flen=strlen(ifmt)
ifmt=strmid(ifmt,0,([flen,flen-1])(strlastchar(ifmt) eq ')'))
ifmt=strmid(ifmt,(strmid(ifmt,0,1) eq '('),flen)
; -----------------------------------------------------------

types =str2arr('a,i,f,d,e')             ; formats handled
mtypes=str2arr("'',0l,0.0,0.0d,0.0d")   ; definition mappings
nt=n_elements(types)

pieces=strlowcase(str2arr(ifmt))
np=n_elements(pieces)
parens=where(strpos(pieces,'(') ne -1,pcnt)

if pcnt gt 0 then begin
    message,/info,"Groups not yet supported"
    return,''
endif    

outval=strarr(np)+'xx'                           ; initialize 
for i=0,nt-1  do begin
   ss=where(strpos(pieces,types(i)) ne -1,nncnt)
   if nncnt gt 0 then outval(ss)=mtypes(i)       ; valid mapping found
endfor

ssout=where(outval ne 'xx',dcount)
if dcount gt 0 then outval=outval(ssout) else begin
    message,/info,"No valid Format elements-> IDL data description mappings"
    outval=''
endelse

return,outval

end
