pro doc_summ, infiles, outdoc, hc=hc, header=header, brief=brief, doc_strs=doc_strs
;
;+
;   Name: doc_summ
;
;   Purpose: 
;      Extract portions of documentation headers and present in some
;      standardized format
;
;   Input Parameters:
;      infiles - list of
;   Calling Sequence:
;      doc_summ, infiles, outdoc [/hc]
;      doc_summ, path,    outdoc [/hc]
;
;   History:
;      30-Mar-1994 (SLF)
;   
;-
case 1 of
   n_elements(infiles) eq 0: begin
      message,/info,'Need to input path, filelist, or doc structures'
      message,/info,'Calling Sequence: doc_summ, input [,/brief, /header]
      return
   endcase
   data_chk(infiles,/struct): doc_str=infiles		; input doc structures
   strpos(infiles(0),'.pro') eq -1: begin		; directory
      files=file_list(infiles,'*.pro')		
   endcase
   else: files=infiles
endcase

if not data_chk(doc_strs,/struct) then begin
; extract and parse documentataion headers (via break_doc.pro)
   filen=0
   repeat begin
      if not file_exist(files(filen)) then begin
         message,/info,"Cannot find file: " + files(filen)
      endif else begin
         message,/info,files(filen)
         break_doc,files(filen),str=newstr   
      endelse
      if data_chk(doc_strs,/struct) then $
         doc_strs=str_concat(doc_strs,newstr) else doc_strs=newstr
      filen=filen+1
   endrep until filen ge n_elements(files)
endif

; now format the 
outdoc=fmt_doc(doc_strs, /lf, header=header, brief=brief)

if keyword_set(hc) then prstr,outdoc,/hc

return
end

