pro break_doc , input, name, purpose, category, callseq,  keep_key=keep_key, $
	debug=debug, brief=brief, header=header, struct=doc_str
;+
; 	NAME: break_doc
;
;	PURPOSE: extract subset of idl header info for display/verification  
;		 this is a check of a two line purpose
;		 third purpose line
;
;	CALLING SEQUENCE: 
;		break_doc, infile
;		break_doc, header
;
;       Input Parameters:
;          input - file to extract - assume idl .pro file
;		   OR documentation header (from doc_head)
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
;	Category: gen, swmaint, unix_only
;
;	Common Blocks: get_doc_private, doc_strt
;
;	Modification History: S.L.Freeland, 18-July-1992 
;			      (derived from sw_head.pro)
;			      slf,  9-Aug-1992	added print option
;			      slf, 22-Mar-1994 convert to rd_tfile
;                             slf,  6-Oct-1998 - add terminators Explana and Use
;                             slf, 15-Oct-1998 - Restore Mons Morrison 12-jun-97 mods.
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;-
common  get_doc_private, doc_strt	; str template (initialization)

; define the return structure (see key_saved for first N fields) 
; only on first call
; First fields are keywords of interest 
if n_elements(doc_strt) eq 0 then begin
  doc_str={Name:'',Purpose:'',CallSeq:'',Category:'',    $ 
	   Definition:'', Type:'',			 $
	   Path:'', bad_start:0, bad_stop:0, bad_line:0, $
	   filename: ''}
  doc_strt=doc_str
endif else doc_str=doc_strt
debug=keyword_set(debug)

file=input
; only makes sense for a 'pro' file 
if str_lastpos(file,'.pro') ne (strlen(file) - 4) then file=file+ '.pro'
;
if not file_exist(file) then begin     
   message,/info , 'File: ' + file + ' not found... returning'
   return
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
key_saved=['NAME,ROUT,PROG','PURP,PUPO','CALL,SAMP','CATE']
key_all=[key_saved,'INPU','OUTP','COMM','OPTI','REST','PROC','MODI']
key_all=[key_all,'KEYW', 'HIST', 'SIDE','METH','WARN','EXPL','USE ']

; get the  path
break_file, file, log, path, filename, filetype
if path eq '' then path=curdir()
path=concat_dir(path,filename)
;
doc_str.path=path
doc_str.filename=filename
line_limit=3				; n lines limit
purpose_found=0				; boolean
name_found=0
category_found=0
callseq_found=0

purpose=keyword_set(purpose)
;
doc_head, file , header, definition		; 
nopurpose=strpos(strupcase(header),'PURP') eq -1
if (nopurpose)(0) then begin
  header=strtrim(rd_tfile(file),2)
  ssc=where(strpos(header,';') eq 0,ccnt)
  if ccnt gt 0 then header=header(ssc)
endif
  

doc_str.definition=(arr2str(definition,'$'))(0)
doc_str.definition=strlowcase(strtrim(doc_str.definition,2))
case strmid(doc_str.definition,0,3) of
   'pro': doc_str.type='Procedure'
   'fun': doc_str.type='Function'
   else:  doc_str.type='Main(?)'
endcase   

;					; header - programmer convenience
; skip uninteresting header lines
premature=0				; check for stop, no start
;
; check for valid delimiters
doc_start=where(strpos(header,';+') ge 0,stcount)
doc_stop=where(strpos(header,';-') ge 0,spcount)
doc_str.bad_start=stcount eq 0
doc_str.bad_stop=spcount eq 0

purpose_count=0
build_count=0
building=-1
key_pos=-1
keytest=-1
next_key=0
first_key=1			; position of 1st key may help identify
				; later keywords(?)
terminators=[' ','\\']

headers=where(header ne ';',hcnt)

if hcnt gt 0 then begin
   
for i=0,n_elements(header)-1 do begin	; should use wheres instead of loop
   line=strtrim(strmid(header(i),1,100),2)
;  try to determine if a keyword is present
   posskey=strmid(line, 0, key_len)
   if posskey eq '' then posskey='xyzx'	; kludge to ignore null keys
   keytest=strposarr(key_all, strupcase(posskey))
   whichkey=where(keytest+1,count) 
;  a keyword may start or stop the building process
   if count gt 0 then begin 
      if building gt 0 then building = -1
      if whichkey(0) le n_elements(key_saved)-1 then begin
	 if doc_str.(whichkey(0)) eq '' then begin 
            build_count=0 + $				;new start
	       strpos(line,' ') ne -1			;keyword only
            building =whichkey(0)			; tag pointer 
         endif 
      endif
   endif 
;

;  if building one of the saved keywords, append to existing value
   build_term=terminators(build_count gt 1)	; comma seperate 
   if building ge 0 and build_count ge 0 then begin ;and line ne '' then begin 
      doc_str.(building)=strtrim(doc_str.(building) + build_term + line,2)
      build_count=build_count+1
      if build_count gt line_limit then begin	;line timeout
         building=-1
         doc_str.bad_line=1
      endif
   endif
endfor   	
endif
;

;
; if keep_key switch not set, eliminate leading keywords from fields 

term=terminators(1)
if not keyword_set(keep_key) then begin
   for i=0, n_elements(key_saved) -1 do begin
      colon=strpos(doc_str.(i),':')
      blank=strpos(doc_str.(i),' ')
      
      doc_str.(i)=strmid(doc_str.(i), $
         max([blank,colon])>0+1<colon+1,strlen(doc_str.(i)))
      doc_str.(i)=strtrim(doc_str.(i),2)
      if strmid(doc_str.(i),0,2) eq term then $
         doc_str.(i) = strmid(doc_str.(i),2,strlen(doc_str.(i)))
   endfor
endif

; eliminate leading and trailing terminators

for i=0, n_elements(key_saved)-1 do begin
   if strpos(doc_str.(i),term) eq 0 then $
      doc_str.(i)=strmid(doc_str.(i),strlen(term),strlen(doc_str.(i)))
   if str_lastpos(doc_str.(i),term) eq strlen(doc_str.(i)) - strlen(term) then $
      doc_str.(i)=strmid(doc_str.(i),0,strlen(doc_str.(i))-strlen(term))
endfor

;assign output
; cleanup purpose

chkpurp=strupcase(strtrim(doc_str.purpose,2))

if strlen(chkpurp) le 8 then begin 
   box_message,'Patching purpose...'
   comphead=strcompress(header,/remove)
   pss=(wc_where(comphead,';purpose*',pcnt,/case_ignore))(0)
   if pcnt gt 0 then doc_str.purpose=arr2str(header(pss:pss+1),' ')
endif

ppos=strpos(strupcase(doc_str.purpose),'PURPOSE')

if ppos ne -1 then begin
   newpurp=strmid(doc_str.purpose,8+ppos,200)
   doc_str.purpose=strtrim(newpurp,2)
endif

; strip leading special characters
temp=strtrim(doc_str.purpose,2)
while (strspecial(temp,/first))(0) and strlen(temp) gt 0 do begin 
   temp=strmid(temp,1,200)
endwhile
doc_str.purpose=temp(0)

if strpos(doc_str.purpose,';') eq 0 then begin
   temp=(strtrim(strmids(doc_str.purpose,1,200),2))(0)
   doc_str.purpose=temp
endif

if strpos(doc_str.category,'\\') ne -1 then begin
   temp=ssw_strsplit(doc_str.category,'\\')
   doc_str.category=temp(0)
endif

purpose=str2arr(doc_str.purpose,term)
callseq=str2arr(doc_str.callseq,term)
name=   str2arr(doc_str.name,term)
category= str2arr(doc_str.category,term)
; 
return

end
