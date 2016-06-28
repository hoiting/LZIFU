;+
; Project     : SOHO - CDS
;
; Name        : CACHE_DATA
;
; Purpose     : cache data in pointer for fast retrieval
;
; Category    : Utility, searching, I/O
;
; Syntax      : IDL> cache_data,name,params,data,/get
;
; Inputs      : DATA = data to cache [any type]
;               PARAMS = parameters describing data [string]
;               NAME = unique name of cache in common [string]
;
; Outputs     : DATA = retrieved data (if /GET)
;
; Keywords    : GET = retrieve cached data from name
;               EMPTY = empty cache
;               FREE = free cache memory
;               STATUS =1/0 if success/failure
;               MAX_SIZE= maximum size of cache [def=20]
;
; History     : Version 1,  6-Nov-1999,  D.M. Zarro.  Written
;               9-Jun-2005, S.L.Freeland - assure pointer is scalar
;                           for /GET option (avoid rsi induced problem
;                           in subscripting Version differences)
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

;-----------------------------------------------------------------------------
;-- empty and free-up cache memory

pro empty_cache,name,free=free                 
restore_cache,name,cache
free=keyword_set(free)
if not is_struct(cache) then return
ncache=n_elements(cache.pointer)
for i=0,ncache-1 do begin
 temp=get_pointer(cache.pointer(i),/no_copy)
 delvarx,temp
 if free then free_pointer,cache.pointer(i)
endfor 
cache.params=''
cache.cpos=-1
if free then delvarx,cache
save_cache,name,cache

return & end

;--------------------------------------------------------------------------
;-- retrieve cache array corresponding to name

pro restore_cache,name,cache
delvarx,cache
if is_string(name) then begin
 s=execute('cache_var="cache_"+name') 
 s=execute('common '+cache_var+','+cache_var)
 s=execute('if is_struct('+cache_var+') then cache='+cache_var)
endif

return & end
                                                                           
;-----------------------------------------------------------------------------
;-- save cache array corresponding to name

pro save_cache,name,cache
if is_string(name) then begin
 s=execute('cache_var="cache_"+name') 
 s=execute('common '+cache_var+','+cache_var)
 s=execute('if is_struct(cache) then '+cache_var+'=cache else delvarx,'+cache_var)
endif

return & end
                                                                           

;----------------------------------------------------------------------------
;-- show cache contents

pro show_cache,name

if is_blank(name) then return

restore_cache,name,cache

if not is_struct(cache) then begin
 message,'cache - '+name+' is empty',/cont
 return
endif

ncache=n_elements(cache.params)
message,cache.name+' (cpos: '+trim(cache.cpos)+')',/cont

for i=0,ncache-1 do begin
 params=cache.params(i)
 if is_string(params) then begin
  print,'('+trim(i)+') '+params & help,(*cache.pointer(i))
 endif
endfor

return & end

;-----------------------------------------------------------------------------

pro create_cache,name,max_size,status=status

status=0b
error=0
if is_blank(name) then error=1 

if error then begin
 message,'input cache name must be non-blank string',/cont
 return
endif

status=1b
if not exist(max_size) then max_size=20
make_pointer,pointer,dim=max_size
cache={name:name,params:strarr(max_size),pointer:pointer,cpos:-1}
save_cache,name,cache
return & end

;------------------------------------------------------------------------------
            
pro cache_data,name,params,data,get=get,status=status,verbose=verbose,$
              max_size=max_size,empty=empty,free=free,show=show,create=create

status=0b
if is_blank(name) then return
name=trim(name)

;-- create cache

if keyword_set(create) then begin
 create_cache,name,max_size,status=status
 return
endif
 
;-- empty cache

if keyword_set(empty) or keyword_set(free) then begin
 empty_cache,name,free=free
 status=1b
 return
endif

;-- show cache
        
if keyword_set(show) then begin
 show_cache,name
 status=1b
 return
endif

if is_blank(params) then return

;-- get cache from common

restore_cache,name,cache

;-- start with get 

if keyword_set(get) then begin
 data=''
 if not is_struct(cache) then return
 chk=(where(params eq cache.params,count))(0) ; slf, add (0) subscript
 if count gt 0 then begin
  if keyword_set(verbose) then $
   message,'restoring '+params+' from '+name,/cont
  data=get_pointer(cache.pointer(chk),undef=undef)
  if undef then data='' else status=1b
 endif
 return
endif  

;-- now do set

if (not exist(data)) then return

;-- create cache array for name if first time

if not is_struct(cache) then begin
 create_cache,name,max_size
 restore_cache,name,cache
endif

;-- check if already cached
;-- else increment pointer position CPOS and update pointer value with data

cpos=cache.cpos
chk=where(params eq cache.params,count)
if count gt 0 then add_pos=chk(0) else begin
 add_pos=cpos+1
 cache.cpos=add_pos
endelse

if add_pos ge n_elements(cache.pointer) then begin
 add_pos=0
 cache.cpos=0
endif

cache.params(add_pos)=params 
set_pointer,cache.pointer(add_pos),data

;-- put cache back into common

save_cache,name,cache

status=1b

return & end

