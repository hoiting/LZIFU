pro file_append, file, text, uniq=uniq, nlines=nlines, loud=loud, $
   newfile=newfile, error=error
;+
;   Name: file_append
;
;   Purpose: append text to text file - optionally, only append uniq text
;
;   Input Parameters:
;      file   - file name	- if no such file exists, open new file
;      text   - text to append  - string or string array
;  
;   Keyword Parameters:
;      uniq    - if set, only append uniq lines of text
;      nlines  - number of new appended lines (same as n_elements(text) if 
;		 uniq is not set 
;      loud    - if sent, print informational messages
;      newfile - if set, open use a new file (on unix, deletes existing)
;
;   Calling Sequence:
;      file_append, file, text [,/uniq, nlines=nlines, /newfile, /loud]
;
;   History:
;      slf, 10-mar-1993
;      slf,  4-May-1993 	; added newfile option
;      slf,  3-mar-1995 	; add flush (for fast machines)
;      slf,  8-mar-1995		; quiet failure, add ERROR
;-
loud = keyword_set(loud)
nlines=n_elements(text)
if nlines gt 0 then new=indgen(nlines)
if keyword_set(uniq) then begin
   contents=rd_tfile(file,/quiet)		; current contents
   newmap=intarr(n_elements(text))
   for i=0,nlines-1 do begin
      chk=where(contents eq text(i),count)
      newmap(i)=count eq 0
   endfor                  
   new=where(newmap, nlines)
endif

opentypes=['openu','openw']
wopen=opentypes(keyword_set(newfile))

on_ioerror,null
if nlines gt 0 then begin
   on_ioerror,ioerror
   call_procedure,wopen,lun,/get_lun,file,append=1-keyword_set(newfile),/stream
   printf,lun,text(new), format='(a)'		; "	"	"
   flush,lun
   free_lun,lun					; "	"	"
   goto,appok					; append ok
   ioerror:					; open/write error
   nlines=0
   if loud then message, /info, 'error opening or appending to: ' + file
   appok:
endif else begin
   if loud then message,/info,'No lines appended'
endelse
error=(nlines eq 0)
return
end
