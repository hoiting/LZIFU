pro keyword_db, dbasefile, keywords, exestrings, descriptions, $
    taglist=taglist, tagfile=tagfile, strtemplate=strtemplate, $
    alphabetize=alphabetize, head_db=head_db, $
    quiet=quiet, loud=loud, debug=debug, _extra=_extra, refresh=refresh,  exec_cmd=exec_cmd
;+
;   Name: keyword_db
;
;   Purpose: return info from one or more keyword database files
;  
;   Input Parameters:
;      dbasefile - name of keyword dbase file (rd_tfile/rd_uline_col compat)
;  
;   Output Parameters:
;      keywords -     list of keywords matching TAGLIST (default is all in db)
;      exestrings -   execute-ready strings associated with keyword list
;      descriptions - text descriptions associated with keyword list
;  
;   Keyword Parameters:
;      taglist - optional taglist to include/convert (def=all in dbase)
;                (array, comma delimited string)
;      tagfile - name of ascii file which contains taglist (via rd_tfile)
;      alphabetize - if set, return info in tag-alphbetic order
;      head_db - name of header dbase file to use 
;      refresh - if set, refresh common block
;      exec_cmd (output) - EXECUTIVE execute strings (ex: .NONE. )
;      quiet/loud - switches to determine noise level of routine
;      XXX - any single TAG can be passed as a switch (keyword inheritance)
;      loud/quiet - set noise level of procedure
;  
;   Calling Sequence:
;      keyword_db, dbasefile, kout, exeout, descout, $
;          taglist=taglist, tagfile=tagfile, strtemplate=strtemplate
;          /xxx  
;
;   Calling Example:
;                       |----In----| |-------- OUT -------------|
;      IDL> keyword_db, trace_keydb, keywords, exestr, descripts, $
;              taglist='date_obs, day, mfilt1,wave_len'
;
;      IDL> more, strjustify(keywords) + ' ' + descripts
;            day      Days since 1-Jan-79
;            date_obs Date/Time of Image
;            mfilt1   Filter wheel 1 Position
;            wave_len Wavelength length class (descriptor)
;
;   History:
;      7-March-1998 - S.L.Freeland - extract some ~generic code from
;                     trace_dph2struct, allow multiple keyword databases
;
;     10-March-1008 - SLF - update the structure common the way I originally
;                           intended
;  
;   Method:
;     for each dbase file, read,parse,store and optionally return TAGLIST subset  
;     common block stores one structure for each uniq dbase file name
;-
common keyword_db_blk, dbtemplate, dbstructs
	
maxkeys=200
if n_elements(dbtemplate) eq 0 or keyword_set(refresh) then begin
    dbtemplate= $
    {dbfile:'', keywords:strarr(maxkeys), exestr:strarr(maxkeys), desc:strarr(maxkeys)}
    dbstructs=dbtemplate
endif

loud=keyword_set(loud) 
quiet=1-loud
debug=keyword_set(debug)

; --------- read header master data base -------------------
if data_chk(dbasefile,/string) then head_db=dbasefile(0)
if not data_chk(head_db,/string,/scalar) then $                   ; historical default
   head_db=concat_dir('TR_CAL_INFO','trace_keywords.tdb') ; is TRACE

if not file_exist(head_db(0)) then begin
   box_message,'Invalid (or unfindable) DBASE file: ' + head_db(0)
   return
endif

ss=where(dbstructs.dbfile eq head_db,dbcnt)               ; check existing db

if dbcnt eq 0 then begin                                  ; not yet tried
   if not file_exist(head_db) then begin
      box_message,'Cannot find file: '+head_db
      return
   endif
   newdb=dbtemplate                                       ; start fresh
   headdbase=rd_ulin_col(head_db,nocom=';',/nohead)       ; default reader
   newdb.dbfile=head_db                                   ; db file name
   newdb.keywords=strtrim(headdbase(0,*),2)		  ; all 'keywords'
   newdb.exestr=  strtrim(headdbase(1,*),2)               ; execute strings
   newdb.desc=    strtrim(headdbase(2,*),2)               ; text descriptions
   dbstructs=merge_struct(dbstructs,newdb)                ; add this one to common
endif else newdb=dbstructs(ss(0))        ; read earlier, assign from common
; ----------------------------------------------------------- 

; ---------- derive TAGLIST ----------------
case 1 of
   data_chk(strtemplate,/struct): taglist=strlowcase(tag_names(strtemplate))
   data_chk(taglist,/string,/vect):
   data_chk(_extra,/struct): taglist=strlowcase((tag_names(_extra))(0))
   data_chk(taglist,/scalar,/string): begin
      case 1 of
         strpos(taglist, ',') ne -1: taglist=strlowcase(str2arr(taglist,/nomult))
         else:
      endcase
   endcase
   data_chk(tagfile,/scalar,/string): begin
     if file_exist(tagfile ) then taglist=rd_tfile(tagfile,nocom=';',/compress) else $
	 box_message,'TAGLIST file: ' + tagfile + ' not found...'
   endcase
   data_chk(taglist,/undefined):
   else:
endcase  
; ----------------------------------------------
; initialize output
exec_cmd=''
keywords=''
exestrings=''
descriptions=''
; ----------------------------------------------

; ----------------------------------------------
allkey=strlowcase(newdb.keywords)            ; all dbase keys
goodkey = (1-strspecial(allkey) and allkey ne '')              ; embedded garbage? 
exekey= strmid(allkey,0,1) eq '.'            ; "executive" commands
tagkey=1-exekey                              ; tag fillers
sstag=where(tagkey and goodkey,keycnt)       ; where filler OK
ssexe=where(exekey,execnt)                   ; where executive

if execnt gt 0 then exec_cmd=newdb.exestr(ssexe)  ; assign to output keyword
; ----------------------------------------------

ntaglist=n_elements(taglist)
if ntaglist eq 0 and keycnt gt 0 then taglist=strlowcase(allkey(sstag)) ; default->all
taglist=strtrim(taglist,2)                                  ; trim tags/names
ntaglist=n_elements(taglist)                                ; recalculate

if keycnt le 0 then begin
   box_message,'No valid keys in data base, returning...'    ; dont bother
   return
endif  

check=is_member(taglist,allkey(sstag))                      
valid=where(check,vcnt)
invalid=where(1-check,ivcnt)

okkey=intarr(n_elements(taglist))
for i=0,n_elements(taglist)-1 do $
   okkey(i)=(where(taglist(i) eq allkey(sstag),cnt))(0)
; ---------------------------------------------------------------

good=where(okkey ne -1, okcnt)
if okcnt eq 0 then begin
   box_message,'No tags in taglist match dbase'
endif else begin
   tagi=sstag(okkey(good))
   tagi=tagi(uniq(tagi,sort(tagi),/first))
   if keyword_set(alphabetize) then tagi=tagi(sort(strlowcase(newdb.keywords(tagi))))
   keywords    =newdb.keywords(tagi)
   exestrings  =newdb.exestr(tagi)
   descriptions=newdb.desc(tagi)
endelse
if debug then stop
return
end
