;+
; Project     : SOHO - CDS
;
; Name        : FIND_CAT
;
; Category    : Utility
;
; Purpose     : Find and list routines matching input category string
;
; Explanation : Used in WWW category search engine
;
; Syntax      : IDL> find_cat,category
;
; Inputs      : CATEGORY = category name (e.g. widgets)
;
; Opt. Inputs : None
;
; Outputs     : ITEMS = listing of matching routines
;
; Opt. Outputs: None
;
; Keywords    : FILE = output file for listing (otherwise goes to screen)
;               RESET = force reading of SSW databases
;               COUNT = number of hits
;               GEN = only search GEN branches
;               BEST = search BESTOF database
;               CLEAN = name of temporary files to delete 
;               PURPOSE = append purpose to listing
;               MINCHAR = min chars required for input category name
;               NAME = set to search by name
;               EXACT = set for exact match
;               SITE = search SITE specific info databases
;               UPDATE = update memory copy of DBASE if disk copy changed
;
; History     : Version 1,  1-Oct-1998,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro find_cat,category,items,file=file,reset=reset,count=count,minchar=minchar,$
             gen=gen,best=best,clean=clean,purpose=purpose,name=name,$
             exact=exact,site=site

common find_cat_com1,dbase,dbase_best,dbase_time,dbase_best_time,$
       last_update_time

on_error,1
rm_file,clean

if datatype(category) ne 'STR' then begin
 message,'Search field was not entered',/cont
 pr_syntax,'find_cat,category'
 return
endif
count=0

category=trim(category)
temp=strip_wild(category,wbegin=wbegin)
if (trim(temp) eq '') or (category eq '') then begin
 message,'Search field was blank',/cont
 return
endif                     

temp=strcompress(strupcase(category),/rem)
temp=strep(temp,',',' ',/all)
fcat=str2arr(temp,delim=' ')
if exist(minchar) then begin
 for i=0,n_elements(fcat)-1 do begin
  ok=strlen(trim(fcat(i))) ge nint(minchar)
  if ok then begin
   keep=append_arr(keep,trim(fcat(i)),/no_copy)
  endif
 endfor
 if exist(keep) then fcat=keep else goto,done
endif

best=keyword_set(best)
reset=keyword_set(reset)
purpose=keyword_set(purpose)
exact=keyword_set(exact)
gen=keyword_set(gen)
by_name=keyword_set(name)
find_cache='find_cat_cache'

;-- check if databases have been updated since last read/save

if not exist(dbase_time) then dbase_time=0.
if not exist(dbase_best_time) then dbase_best_time=0.
if not exist(last_update_time) then last_update_time=0.

if keyword_set(site) then sdir='site' else sdir='gen'
if best then begin
 dbfile='$SSW/'+sdir+'/setup/ssw_bestof_map.dat'
 cur_dbtime=dbase_best_time
endif else begin
 dbfile='$SSW/'+sdir+'/setup/ssw_info_map.dat'
 cur_dbtime=dbase_time
endelse

chk=file_info2(dbfile,stat)
if chk eq 0 then begin
 message,dbfile+' not found',/cont
 return
endif
new_dbtime=anytim2tai(stat.date)
curr_time=anytim2tai(!stime)
;one_day=24.*3600.
;getting_old=(curr_time-last_update_time) gt one_day
new_dbase=(new_dbtime gt cur_dbtime) 

;-- read and save category databases

re_read=new_dbase or reset or (best and (not exist(dbase_best))) or $
                             ((1-best) and (not exist(dbase)))

if re_read then begin
 cache_data,find_cache,/empty

 if best then begin
;  message,'reading SSW_BESTOF_MAP...',/cont
  dbase_best=rd_tfile(dbfile,delim="::",nocomm=';',/auto)
  dbase_best_time=new_dbtime
 endif else begin
;  message,'reading SSW_INFO_MAP...',/cont
  dbase=rd_tfile(dbfile,delim="::",nocomm=';',/auto)
  dbase_time=new_dbtime
 endelse
 last_update_time=curr_time
endif

;-- check if search results have been cached

params=arr2str(fcat)
if best then params=params+'best'
if purpose then params=params+'purpose'
if exact then params=params+'exact'
if gen then params=params+'gen'
if by_name then params=params+'name'

cache_data,find_cache,params,items,status=status,/get
if status then goto,found

;-- perform search

if by_name then k='0' else k='3'
expr=''
if best then db_name='dbase_best' else db_name='dbase'
temp=fcat
for i=0,n_elements(fcat)-1 do begin
 temp(i)=strip_wild(fcat(i),wbegin=wbegin)
 j=trim(string(i))
 if i eq 0 then start='' else start=' or '
 expr=expr+start+'(strpos(strupcase('+db_name+'('+k+',*)),temp('+j+')) gt -1)'
endfor
expr='('+expr+')'
if keyword_set(gen) then expr=expr+' and (strpos(strupcase('+db_name+'(0,*)),"/GEN/") gt -1)'
expr='wsearch=where('+expr+',count)'
s=execute(expr)
fproc=temp(0)

;-- expand any logicals

done: items=''
delim='/'
if count gt 0 then begin
 if by_name then begin
  for i=0,count-1 do begin
   ic=trim(string(i))
   expr='temp='+db_name+'(0,wsearch('+ic+'))'
   s=execute(expr)
   break_file,temp,fdsk,fdir,fname,fext
   fpos=strpos(strupcase(fname+fext),fproc)
   chk2=fpos gt -1
   if chk2 then begin
    include=1
    if (1-wbegin) then include=(fpos eq 0)
    if exact then include=trim(fproc) eq strupcase(trim(fname))
    if include then begin
     expr='result=chklog(temp,/pre)'
     if purpose then expr=expr+'+"::"+'+db_name+'(2,wsearch('+ic+'))'
     e=execute(expr)
     keep2=append_arr(keep2,result,/no_copy)
    endif
   endif
  endfor
  if exist(keep2) then begin
   items=keep2 & count=n_elements(keep2)
  endif
 endif else begin
  if exact then begin
   for i=0,count-1 do begin
    ic=trim(string(i))
    expr='item='+db_name+'(3,wsearch('+ic+'))'
    s=execute(expr)
    items=str2arr(item)
    chk=where(trim(fproc) eq strupcase(trim(items)),icount)
    if icount gt 0 then keep3=append_arr(keep3,wsearch(i),/no_copy)
   endfor
   if exist(keep3) then wsearch=keep3
   count=n_elements(wsearch)
  endif
  if count gt 0 then begin
   expr='items=chklog('+db_name+'(0,wsearch),/pre)'
   if purpose then expr=expr+'+"::"+'+db_name+'(2,wsearch)'
   s=execute(expr)
  endif
 endelse
endif

if count le 1 then items=[items]
ok=where(trim(items) ne '',count)
if count ne 0 then begin
 items=items(ok)
 kluge=chklog('$SSW_HESSI')
 if strpos(kluge,'idl') eq -1 then kluge=kluge+'/idl'
 items=str_replace(items,'$SSW_HESSIidl',kluge)
endif

if (count le 1) and (items(0) eq '') then begin
 items=['%FIND_CAT: No files found matching search criteria: '+category]
endif else cache_data,find_cache,params,items

found:

if datatype(file) eq 'STR' then begin
 openw,lun,file,/get_lun,/app
 printf,lun,transpose([items])
 close,lun & free_lun,lun
 espawn,'chmod guo+w '+file
endif else begin
 print,transpose([items])
endelse 

return & end

