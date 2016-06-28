;+
; Project     : SOHO - CDS
;
; Name        : FIND_PROC
;
; Category    : Utility, help
;
; Purpose     : Find routine in SSW tree
;
; Explanation : Used in WWW search engine
;
; Syntax      : IDL> find_proc,proc
;
; Inputs      : PROC = procedure name (e.g. xdoc, or *xdoc, or xdoc*)
;
; Opt. Inputs : None
;
; Outputs     : STDOUT listing of found procedures
;
; Opt. Outputs: None
;
; Keywords    : FILE = output file for listing (otherwise goes to screen)
;               RESET = force reading of SSW databases
;               COUNT = number of hits
;               CLEAN = name of temporary files to delete 
;
; History     : Version 1,  2-Oct-1998,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro find_proc,proc,file=file,reset=reset,count=count,$
            clean=clean

common find_proc,dbase,dbase_time

on_error,1

rm_file,clean

if datatype(proc) ne 'STR' then begin
 message,'Search field was not entered',/cont
 pr_syntax,'find_proc,proc'
 return
endif

;-- remove any extensions and check for wild characters

fproc=strip_wild(proc,wbegin=wbegin)

if trim2(fproc) eq '' then begin
 message,'Search field was blank',/cont
 return
endif
                                      
;-- check if databases have been updated since last read/save

count=0
reset=keyword_set(reset)
if not exist(dbase_time) then dbase_time=0.

dbfile='$SSW/gen/setup/ssw_map.dat'
cur_dbtime=dbase_time
chk=file_info2(dbfile,stat)
if chk eq 0 then begin
 message,dbfile+' not found',/cont
 return
endif
new_dbtime=anytim2tai(stat.date)
new_dbase=new_dbtime gt cur_dbtime

;-- read and save database

re_read=new_dbase or reset or (not exist(dbase))

if re_read then begin
 cache_data,'find_proc_cache',/empty
 dbase=rd_tfile(dbfile)
 dbase_time=new_dbtime
endif

;-- check if in cache

cache_data,'find_proc_cache',fproc,keep,status=status,/get
if status then goto,done

;-- perform search

delim='/'
chk=where(strpos(strupcase(dbase),fproc) gt -1,count)
if count gt 0 then begin
 for i=0,count-1 do begin
  temp=dbase(chk(i))
  break_file,temp,fdsk,fdir,name
  fpos=strpos(strupcase(name),fproc)
  chk2=fpos gt -1
  if chk2 then begin
   include=1
   if (1-wbegin) then include=(fpos eq 0)
   if include then begin
    temp2=chklog(temp,delim=delim,/pre)
    if temp2(0) eq '' then temp2=temp 
    keep=append_arr(keep,temp2)
   endif
  endif
 endfor
endif

;-- list results

done:
items='' 
count=n_elements(keep)
if count gt 0 then items=keep
if count le 1 then items=[items]
ok=where(trim2(items) ne '',count)
if count gt 0 then items=items(ok)

if (count le 1) and (items(0) eq '') then $
 items=['%FIND_PROC: No files found matching: '+proc] else $
  cache_data,'find_proc_cache',fproc,items

if datatype(file) eq 'STR' then begin
 openw,lun,file,/get_lun
 printf,lun,transpose([items])
 close,lun & free_lun,lun
 espawn,'chmod guo+w '+file
endif else begin
 print,transpose([items])
endelse

return & end

