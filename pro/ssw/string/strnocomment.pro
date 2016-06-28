function strnocomment, inarray, comment=comment, remove_nulls=remove_nulls, $
	leave_inline_comments=leave_inline_comments
;+
;   Name: strnocomment
;
;   Purpose: de-comment a string / string array
;
;   Input Parameters:
;      inarray - string or string array
;
;   Keyword Parameters:
;      comment - optional comment character (defaul derived from data/system)
;      remove_nulls - switch, if set, remove null lines (after comments remove)
;      leave_inline_comments - switch, if set, remove comment only if entire line is comment
;
;   Calling Sequence:
;     nocomm=strno_comment(array [ ,comment='character', /remove_nulls ])
;
;   Method:
;      uses byte operation for big-array efficiency (no for loops)
;
;   History:
;      18-March-1996 (S.L.Freeland)
;      28-Nov-2001, kim.tolbert@gsfc.nasa.gov.  Added leave_inline_comments keyword.
;-

; check input
if not data_chk(inarray,/string) then begin
   message,/info,"Need string array input..., returning"
   return,inarray
endif

barray=byte(inarray)				; byte version

; comment character determination
if data_chk(comment,/string) then begin
      bdelim=byte(comment)  			; user input one
endif else begin				; else, guess comment
;  Assumption: most common of the 'usual' chars is the comment character
   busual=byte([';','#','!'])			; add to this list as required
   histb=histogram(barray)			; ascii histogram
   bdelim = byte(busual(where(histb(busual) eq max(histb(busual)))))
endelse

if keyword_set(leave_inline_comments) then begin
	;find comment character that is first character in line
	ss = where ( (byte (strtrim(inarray,2)))(0,*) eq bdelim(0), sscnt)
	oarray = inarray
	if sscnt gt 0 then oarray(ss) = ''
endif else begin
	; now identify comments, change to ascii terminators, and convert->string
	ss=where(barray eq (bdelim)(0),sscnt)		; where are delimiters?
	if sscnt gt 0 then barray(ss) = 0b		; substitute ascii terminator
	oarray=string(barray)				; (truncates at 0b)
endelse

; optionally remove nulls on request
if keyword_set(remove_nulls) then begin
   notnulls=where(strlen(strcompress(oarray,/remove)) gt 0,sscnt)
   if sscnt gt 0 then oarray = oarray(notnulls) else oarray=''
endif

return,oarray
end




