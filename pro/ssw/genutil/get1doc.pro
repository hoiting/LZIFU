function get1doc, infile, keep_key=keep_key, debug=debug, print=print, $
		  brief=brief, head=head
;
;+
; 	NAME: get1doc 
;
;	PURPOSE: extract subset of idl header info for display/verification  
;		 this is a check of a two line purpose
;		 third purpose line
;
;	CALLING SEQUENCE: doc=get1doc(infile)
;
;       Input Parameters:
;          infile - file to extract - assume idl .pro file
;
;       Optional Keyword Parameters:
;          keep_key - if set, keywords from file are retained in the
;		      tag value - default is to eliminate since the 
;		      tag name contains relavent info. 
;	   debug - if set, some programmer info is printed
;
;	Output: 
;	   function returns structure containing documentation info 
;	   all fields are string type - null fields imply a particular
;	   field is missing from the documentation header 
;
;	Restrictions: unix only x 
;
;	Category: gen, swmaint, unix_only
;
;	Common Blocks: get_doc_private, doc_strt
;
;	Modification History: slf, 18-July-1992 
;			      (derived from sw_head.pro)
;			      slf,  9-Aug-1992	added print option
;	12-Jun-97 (MDM) - Added "EXPL" (Explanation) to the list of
;			  section separators
;-
;on_error,2
common  get_doc_private, doc_strt	; str template (initialization)

debug=keyword_set(debug)
printing=keyword_set(print)
printlun=-1				; terminal for now

file=infile
; only makes sense for a 'pro' file 
if str_lastpos(file,'.pro') ne (strlen(file) - 4) then $
	file=file+ '.pro'
;
if not file_exist(file) then begin     
   message,/info , 'File: ' + file + ' not found... returning'
   return,''
endif
; for id, keywords limited to 4 characters to minimize typo problems
; define keywords of interest - these should be same order as doc_str
; field names since updating of structure fields uses str.(i) syntax
key_len=4
;
; key_saved are those keywords included in return structure
; key_all are those plus any other common keyword (used to terminate)
; the building of multiple line keywords of interest (especially PURPOSE) 
; NOTE - to add info to return structure, add new keyword (1st 4 char)
; 	 to key_saved and doc_str structure definition
;        an element in key_saved may include a synonym list
key_saved=['NAME,ROUT,PROG','PURP','CALL','CATE']
key_all=[key_saved,'INPU','OUTP','COMM','OPTI','REST','PROC','MODI']
key_all=[key_all,'KEYW', 'HIST', 'SIDE','METH','WARN','EXPL']

; define the return structure (see key_saved for first N fields) 
; only on first call
; First fields are keywords of interest 
if n_elements(doc_strt) eq 0 then begin
  doc_str="{dummy, Name:'',Purpose:'',CallSeq:'',Category:'', " + $ ;fields saved
	" Path:'', bad_start:0, bad_stop:0, bad_line:0}"
  doc_str=make_str(doc_str)
  doc_strt=doc_str
endif else doc_str=doc_strt

; get the  path
break_file, file, log, path, filename, filetype
if path eq '' then path=curdir()
path=concat_dir(path,filename)
;
doc_str.path=path

line_limit=3				; n lines limit
purpose_found=0				; boolean
name_found=0
category_found=0
callseq_found=0

lines=0

line = ''					
terminate=';-'				;when to stop
purpose=keyword_set(purpose)
;
logging = keyword_set(print) 
if logging then openw,unit0,/get_lun,'sxt_sw.doc' else $
   unit0 = -1 						; terminal out
;
openr,unit,/get_lun, file 
readf,unit,line
;
; skip uninteresting header lines
premature=0				; check for stop, no start
skip=1
;
; loop until header found (or eof)
while not eof(unit) and skip do begin 
  skip = strpos(line,';+') lt 0
  vstop = strpos(line,terminate) ge 0
  if vstop then premature=1		; stop before start  anomoly 
  readf,unit,line
endwhile
;
head=['** Documentation for: ' + file + ' **']

doc_str.bad_start=skip
purpose_count=0
build_count=0
building=-1
key_pos=-1
keytest=-1
next_key=0
first_key=1			; position of 1st key may help identify
				; later keywords(?)
;
terminators=[' ','\\']
;
; document header line loop (terminate at eof or end of header(;-)
while (not eof(unit)) and $
   (strpos(strupcase(line),terminate) lt 0) do begin 
;
   head=[head,line]
;  try to determine if a keyword is present
   if strmid(line,0,1) eq ';' then begin	; comment line
      strput,line,' '
      line=strcompress(strtrim(line,2))		; trim/compress
   endif
   posskey=strmid(line, 0, key_len)
   keytest=strposarr(key_all, strupcase(posskey))
   whichkey=where(keytest+1,count)
   
;  a keyword may start or stop the building process
   if count gt 0 then begin 
      if whichkey(0) le n_elements(key_saved)-1 then begin
	 if doc_str.(whichkey(0)) eq '' then begin 
            build_count=0 + $				;new start
	       strpos(line,' ') ne -1			;keyword only
            building =whichkey(0)				  ; tag pointer 
         endif 
    endif else building = -1 			  	  ; stop 
;
   if debug then help,count,keytest, posskey, building
   endif
;
;  if building one of the saved keywords, append to existing value
   build_term=terminators(build_count gt 1)	; comma seperate 
   if building ge 0 and build_count ge 0 and line ne '' then begin 
      if debug then begin
          print,'building ', posskey                
          print,'new line:',line
      endif 
     doc_str.(building)=strtrim(doc_str.(building) + build_term + line,2)
      build_count=build_count+1
      if build_count gt line_limit then begin	;line timeout
         building=-1
         doc_str.bad_line=1
      endif
   endif
       
   
   
   	
   readf,unit,line				    ; get next
;

endwhile
;
; check for valid documentation terminator
doc_str.bad_stop= eof(unit) or premature
free_lun,unit
;
if logging then free_lun, unit0
;
; if keep_key switch not set, eliminate leading keywords from fields 
if not keyword_set(keep_key) then begin
   for i=0, n_elements(key_saved) -1 do begin
      colon=strpos(doc_str.(i),':')
      blank=strpos(doc_str.(i),' ')
      doc_str.(i)=strmid(doc_str.(i), $
         max([blank,colon])>0+1,strlen(doc_str.(i)))
      doc_str.(i)=strtrim(doc_str.(i),2)
      if strmid(doc_str.(i),0,2) eq '\\' then $
         doc_str.(i) = strmid(doc_str.(i),2,strlen(doc_str.(i)))
   endfor
endif
; 
return, doc_str(0)
end
