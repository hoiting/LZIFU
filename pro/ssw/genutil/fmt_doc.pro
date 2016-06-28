function fmt_doc, doc_str, lf=lf , brief=brief, header=header
;
;+ 
;   Name: fmt_doc
;
;   Purpose: format output buffer containing documentation header info 
;
;   Input Parameters:
;	doc_str - document structures, as returned by get_doc.pro
;		  scaler or array of structures
;
;   Optional Keyword Paramters:
;      lf - if set, 1 blank line inserted between routine documentation
;
;   Output Parameters:
;      function returns string array of formatted doc_str contents
;      for scaler input, each doc_str field is included (page format) 
;      for array input, a summary list format (Name Purpose) is produced
;
;   Calling Sequence:	outarr=fmt_doc(doc_str)
;
;   Category: gen, util, swmaint, documentation, class3
;
;   History: slf, 20-Jul-1992
;            slf, 30-Mar-1994 (add brief, keyindent)
;-
outdoc=['']				; init output buffer
   
line_feed=keyword_set(lf)
lun=-1					; terminal for now

keyindent='   '
indent=keyindent + keyindent
; loop for each documentation structure
unknown='?????????'
; identify unknown fields
for i=0,3 do begin
   unkfield=where(doc_str.(i) eq '',unkcnt)
   if unkcnt gt 0 then doc_str(unkfield).(i)=unknown
endfor

names=doc_str.name
noname=where(doc_str.name eq unknown,unkcnt)

for i=0,unkcnt-1 do begin
   blnk=strpos(doc_str(noname(i)).definition,' ')
   term=strpos(doc_str(noname(i)).definition,',')
   if term eq -1 then term=strlen(doc_str(noname(i)).definition)   
   names(noname(i))=strmid(doc_str(noname(i)).definition,blnk,term-blnk)
endfor

for i=0, n_elements(doc_str)-1 do begin
   purpose=str2arr(doc_str(i).purpose,'\\')
   name=strupcase(names(i))
   if keyword_set(header) then $
      outdoc=[outdoc,'------ ' + doc_str(i).path + ' ------','']
   outdoc=[outdoc,doc_str(i).type + ': ' + name, keyindent + 'Purpose:', indent + purpose]
   if not keyword_set(brief) then begin
      if doc_str(i).callseq ne '' then $
         outdoc=[outdoc, + keyindent+ 'Calling Sequence:', $
            indent + str2arr(doc_str(i).callseq,'\\')]
   endif
   if line_feed then outdoc=[outdoc,'']
;
endfor

outdoc=outdoc(1:*)

return,strtrim(outdoc) 
;
end      
