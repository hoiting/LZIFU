;+
; Project     : SOHO - CDS
;
; Name        : PAIR_STRUCT
;
; Category    : structures, utility
;
; Purpose     :	Pair a structure down into component "tag:value" pairs
;
; Explanation :	Useful for input to CREATE_STRUCT
;
; Syntax      : IDL>pair =pair_struct(struct)
;
; Inputs      : STRUCT = structure to pair
;
; Opt. Inputs : None
;
; Outputs     : PAIR = string array of pairs,
;                e.g: {a:1,b:2} --> ["a",s.(0),"b",s.(1)]
;
; Opt. Outputs: None
;
; Keywords    : DUPLICATE = set to allow duplicate tag names
;               EQUAL = if set, then
;               {a:1,b:2} --> 'a=s.(0),b=s.(1)'
;               COLON = if set, then
;               {a:1,b:2} --> 'a:s.(0),b:s.(1)'
;
; History     : Written,  1-Apr-1997,  D.M. Zarro (ARC)
;             : Modified, 1-Nov-1999,  D.M. Zarro (SM&A) - add /EQUAL
;             : Modified, 13-Sept-2001,  D.M. Zarro (EITI/GSFC) - add /COLON
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function pair_struct,s,name,duplicate=duplicate,equal=equal,colon=colon

on_error,1

if (datatype(s) ne 'STC') then begin
 pr_syntax,'pairs=pair_struct(struct)'
 return,''
endif

tags=tag_names(s)
ntags=n_elements(tags)
if datatype(name) ne 'STR' then name='s'

noduplicate=1-keyword_set(duplicate)
if keyword_set(equal) then delim='='
if keyword_set(colon) then delim=':'

for i=0,ntags-1 do begin
 include=1
 if (noduplicate) and exist(pairs) then begin
  chk=where(strpos(pairs,'"'+tags(i)+'",') gt -1,count)
  if count gt 0 then include=0
 endif
 if include then begin
  if is_string(delim) then $
   temp=tags(i)+delim+name+'.('+trim(string(i))+')' else $
    temp='"'+tags(i)+'"'+','+name+'.('+trim(string(i))+')'
  pairs=append_arr(pairs,temp)
 endif
endfor

if is_string(delim) then pairs=arr2str(pairs,delim=',')

return,pairs & end

