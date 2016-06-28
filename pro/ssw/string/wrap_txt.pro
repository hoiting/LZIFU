;+
; PROJECT:
;       HESSI
;
; NAME:
;       WRAP_TXT()
;
; PURPOSE:
;       Convert a string (or string array) into a series of lines of given length, with
;		'$' appended to each line that was wrapped (suitable for a .pro script)
;
; CATEGORY:
;       string
;
; SYNTAX:
;       Result = wrap_txt(str)
;
; INPUTS:
;       STR - String scalar or array to be wrapped
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
;       LENGTH  - Maximum length of output string array elements
;                   (default is 90)
;		DELIM   - Delimiter indicating acceptable places to break string (default is ',')
;       WARNING   - Contains warning message (if any returned line is
;                   longer than LENGTH)
;       NO_DOLLAR - If set, don't put '$' on end of continued line
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       None.
;
; HISTORY:
;       Written: Kim Tolbert, 10-Jan-2004, Based heavily on Liyun Wang's str2lines.
;		Differences from str2lines:
;			wrap_txt accepts an array of input strings
;			wrap_txt allows specification of delimiter to wrap on
;			str2lines compressed all white space, wrap_txt doesn't
;			wrap_txt appends lines that were wrapped with continuation character ('$')
;
; MODIFICATIONS:
;       4-Apr-2005, Kim. added no_dollar keyword
;-

function wrap_txt, str_in, length=length, delim=delim, warning=warning, no_dollar=no_dollar

if size(str_in, /tname) ne 'STRING' then return, ''
checkvar, length, 90

checkvar, delim, ','
dollar = keyword_set(no_dollar) ? '' : ' $'

for index = 0,n_elements(str_in)-1 do begin
   str = str_in[index]
   line = str
   if strlen(str) le length then goto, nextline

   maxlen = STRLEN(str)
   ok = 1 & off = 0  & idx = -1

   WHILE (ok GT 0) DO BEGIN
      ii = STRPOS(str, delim, off)
      IF ii GE 0 THEN BEGIN
         if idx[0] eq -1 then idx = ii else idx = [idx, ii]
         off = ii+1
      ENDIF ELSE ok = 0
   ENDWHILE

   num = N_ELEMENTS(idx)
   IF num EQ 0 THEN goto, nextline

   off = 0
   line = ''
   IF num GE 2 THEN BEGIN
      FOR i=0, num-2 DO BEGIN
         span = idx(i+1)-off
         IF span GT length THEN BEGIN
            line = [line, STRMID(str, off, idx(i)-off+1)]
            off = idx(i)+1
         ENDIF
      ENDFOR
      str = STRMID(str,off,maxlen)	; corrected 1/24/2002, Kim. Was STRMID(str_in...
      idx = idx(num-1)-off
      off = 0
   ENDIF
   span = idx(0)-off
   IF STRLEN(str) GT length THEN BEGIN
      line = [line, STRMID(str, off, span+1)]
      line = [line, STRMID(str, span+1, maxlen)]
   ENDIF ELSE BEGIN
      line = [line, str]
   ENDELSE
   line = line(1:*)

   summary = STRLEN(line)
   ii = WHERE(summary GT length)
   IF ii(0) GE 0 THEN warning = 'Found word(s) with length greater than '+$
      STRTRIM(STRING(length),2)

   nextline:
   n_new = n_elements(line)
   if n_new gt 1 then line[0:n_new-2] = line[0:n_new-2] + dollar
   lines = append_arr(lines, line)
endfor

return, lines

END


