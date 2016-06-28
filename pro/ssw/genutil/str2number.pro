function str2number, strarr, quiet=quiet, loud=loud
;+ 
;   Name: str2number
;
;   Purpose: return numeric part of a string or string array
;
;   Input Parameters:
;      strarr - string or string array which contain numeric info
;
;   Output:
;      Function returns numeric array (long or floating, as appropriate)
;      For elements w/no numeric info, output set to zero (0)
;
;   Keyword Parameters:
;      loud - if set, print warning if one or more strings contain no number
;
;   Calling Sequence:
;      numbers=str2number(strarr)  ; return numeric portion of strarr
;      
;
;   Calling Example:
;      IDL> print,str2number(['as34','asdfsadf','a234.5','asdf-8.734asdf'])
;      % STR2NUMBER: Some input contains no numeric data (set those to zero)
;            34.0000      0.00000      234.500     -8.73400
;   History:
;      1-May-1995 (SLF)  Written (to return font sizes orignially)
;				  form='FONTNAMEfonssize'
;     23-may-1995 (SLF)  Made QUIET the default (use /loud to override)
;
;   Method:
;      make non-numeric characters blanks and eliminate with strcompress
;
;   Restrictions:
;      exponential format not recognized 
;-

quiet=keyword_set(quiet) 
loud=keyword_set(loud) and (1-keyword_set(quiet))

tarr=strlowcase(strarr)		; reduce search space
bstring=byte(tarr)		; convert to bytes

; define search values
b0=(byte('0'))(0)		; numbers
b9=(byte('9'))(0)
bd=(byte('.'))(0)		; special number characters "-" and "."
bn=(byte('-'))(0)

nonnumeric=where((bstring lt b0 or bstring gt b9) $     ; identify non-numerics
   and (bstring ne bd)  and   (bstring ne bn),ncnt)
if ncnt gt 0 then bstring(nonnumeric)=32b		; blank them out
numbers=strcompress(string(bstring),/remove)		; eliminate them

; print "no numeric" warning if applicable 
nchk=where(numbers eq '',ncnt)
if ncnt gt 0 and loud then $
   message,/info,"Some input contains no numeric data (set those to zero)"

chkflt=where(strpos(numbers,'.') ne -1,fcnt)	; floating data?
case 1 of
   fcnt gt 0: numbers = float(numbers) 		; yes, output fltarr
   else: numbers=long(numbers)			; no,  output lonarr
endcase

return,numbers
end
