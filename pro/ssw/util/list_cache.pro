;+
; Project     : Hinode/EIS
;
; Name        : LIST_CACHE
;
; Purpose     : Cache time-based search results
;
; Category    : utility
;
; Syntax      : IDL> list_cache,id,tstart,tend,data
;
; Inputs      : ID = string identifier for results
;               TSTART/TEND: start/end times used for searching
;               DATA = structure array of search results
;
; Keywords    : SET - to save results
;               GET - to restore results
;               DELETE - to delete results for input ID
;               COUNT - # of returned results
;               WITHIN_TIMES - true if search times fall within range
;                of last search times
;               CLEAR - clear cache completely
;
; History     : Written 16 March 2007, Zarro (ADNET) 
;
; Contact     : dzarro@solar.stanford.edu
;-


pro list_cache,id,tstart,tend,data,set=set,$
         delete=delete,count=count,within_times=within_times,$
         clear=clear

within_times=0b
count=0 
common list_cache,fifo
if not obj_valid(fifo) then fifo=obj_new('fifo')

if keyword_set(clear) then begin
 fifo->empty
 return
endif

if is_blank(id) then begin
 message,'ID name not set',/cont
 return
endif

;-- delete data

if keyword_set(delete) then begin
 fifo->delete,id
 return
endif

if (1-valid_time(tstart)) or (1-valid_time(tend)) then begin
 message,'TSTART/TEND not entered',/cont
 return
endif
dstart=anytim2tai(tstart) & dend=anytim2tai(tend)

;-- set data

if keyword_set(set) then begin
 if is_struct(data) then count=n_elements(data) else begin
  data=0. &  count=0
 endelse
 last={data:data,tstart:dstart,tend:dend,count:count}
 fifo->set,id,last
 return
endif

;-- get data

delvarx,data
fifo->get,id,last

;-- return if no results from last search, or outside last search range

if (1-is_struct(last)) then return
within_times= (dstart le last.tend) and (dstart ge last.tstart) and $
              (dend le last.tend) and (dend ge last.tstart)
if (1-within_times) then return

count=last.count
if (count eq 0) then return

;-- filter out requested times

if (1-is_struct(last.data)) then begin
 count=0 & return
endif

ss=where_times(last.data.times,tstart=dstart,tend=dend,count=count)
if count eq 0 then return
if (count lt n_elements(last.data.times)) then data=last.data[ss] else data=last.data

return & end


