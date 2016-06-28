;+
; Project     : SOHO - CDS
;
; Name        : GET_KEYWORD
;
; Purpose     : Extract values in a string array that appear after
;               keyword construct such as: KEYWORD=VALUE
;               (e.g. extract all time values following STARTIME=time_value)
;
; Category    : Utility
;
; Syntax      : IDL> values=get_keyword(array)
;
; Inputs      : ARRAY = array to search
;               KEY   = keyword name to extract
;
; Outputs     : VALUES = keyword values
;               INDEX  = index location of keyword
;
; Keywords    : CASE = set to make search case sensitive
;
; History     : Version 1,  25-May-1997,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function get_keyword,array,key,case_sens=case_sens,index=index

values=''
index=-1
if (datatype(key) ne 'STR') or (datatype(array) ne 'STR') then begin
 message,'syntax -> values=get_keyword(array,key)',/cont
 return,values
endif

skey=trim(key)
if (strpos(skey,'=') eq -1) then skey=key+'='
temp=strcompress(array,/rem)
if keyword_set(case_sens) then begin
 kpos=strpos(temp,skey)
endif else begin
 kpos=strpos(strupcase(temp),strupcase(skey))
endelse

spos=where(kpos gt -1,scount)
if scount gt 0 then begin
 values=strarr(scount)
 for i=0,scount-1 do begin
  epos=strpos(array(spos(i)),'=')
  if epos gt -1 then $
   values(i)=trim(strmid(array(spos(i)),epos+1,100))
 endfor
endif 

index=spos

if n_elements(values) eq 1 then values=values(0)
return,values & end

