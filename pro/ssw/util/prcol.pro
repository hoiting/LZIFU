pro prcol,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9, $
   col_delimiter=col_delimiter, delim=delim, $
   center=center, left=left,right=right, box=box, header=header, noprint=noprint, $
   outarr=outarr
;+
;   Name: prcols
;
;   Purpose: print up to 10 array parameters in aligned columns w/optional header
;
;   Input Parameters:
;      up to 10 arrays - number of elements must match
;
;   Keyword Paramters:
;      right/left/center - specify alignment/justification (see strjustify)
;      box - if set, draw box the whole thing (see strjustify)
;      header - optional header string to align with data - comma or blank delimited string will
;               (number of fields should match array sizes)
;      noprint - switch - if set, dont print to terminal (output via OUTARR keyword)
;      coldelim=coldelim - if string, delimiter to insert between columns 
;                          if number, number of blanks to insert between cols (def=2 blanks)
;      outarr - the aligned text array
;
;   Method: call strjustify, execute
;
;   History:
;      11-sep-1995 (SLF) - provide terminal front end to strjustify
;-

; parse header if present
np=n_params()			; number of colums
nn=n_elements(p0)		; number elements

if nn eq 0 then begin
   message,/info,"No parameters to align.."
   return
endif
 
; parse header if supplied
if data_chk(header,/string) then begin
   dlist=[',',' ']					; delimiter list
   dp=0
   headarr=str2arr(header,dlist(dp))			; break string
   while dp lt n_elements(dlist) and n_elements(headarr) ne np do begin
      headarr=str2arr(header,dlist(dp))			; break string
      dp=dp+1
   endwhile

   if n_elements(headarr) ne np then begin
      message,/info,"Number of elements in header does not equal number of columss.. ignored.."
      headarr=strarr(np)
   endif

endif else headarr=strarr(np)

outarr=strarr(nn+1)

if keyword_set(delim) and not keyword_set(col_delimiter) then col_delimiter=delim
case data_chk(col_delimiter,/type) of 
   7: col_del=col_delimiter
   0: col_del="  "
   else: col_del=string(replicate(32b,col_delimiter))
endcase

for i=0,n_params() -1 do exestat=execute( $
   "outarr=outarr + col_del  + strjustify([strtrim(headarr(i),2), strtrim(p" + strtrim(i,2) + $
                       ",2)],left=left,right=right,center=center)")

if not keyword_set(header) then outarr=outarr(1:*)	; remove null headers
outarr=strtrim(outarr,2)

outarr=strjustify(outarr,left=left,right=right,center=center,box=box) ; box if required

if not keyword_set(noprint) then more,outarr

return
end
