;+
; Project     : SOHO - CDS
;
; Name        : GET_TAG_VALUE
;
; Purpose     : get tag values from within a structure
;
; Category    : Help, structures
;
; Explanation : 
;              Uses keyword inheritance and execute to determine
;              if the requested tag exists. Uses recursion
;              to search nested structures. The nice thing
;              about this method is that the tag names don't
;              have to be hardwired into the code. Any tag name
;              can be entered and will be stored as a tag name in the
;              anonymous structure _EXTRA. The latter is then
;              cross-checked against the tags in the input structure STC.
;
; Syntax      : IDL>  value=get_tag_value(stc,/tag_name)
;
; Inputs      : STC = any structure
;
; Opt. Inputs : None
;
; Outputs     : Requested tag value
;
; Opt. Outputs: None
;
; Keywords    : ERR (output) =  1/0 for success/failure
;               QUIT (input) = 0/1 to report/not report failure
;               TAG_NAME   = tag name to extract
;               e.g. to extract time tag from index.time use:
;               TIME=GET_TAG_VALUE(INDEX,/TIME)
;               MATCH = # of characters to match (e.g. if 3 then first
;               3 characters sufficient for match)
;
; History     : Version 1,  1-Sep-1995,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function get_tag_value,stc,_extra=tag_name,err=err,quiet=quiet,match=match

on_error,1
err=1
tag_value=0

if datatype(stc) ne 'STC' then begin
 message,'input must be a structure',/contin
 return,0
endif
if n_elements(tag_name) eq 0 then begin
 message,'please enter a tag name keyword',/contin
 return,0
endif

input_tag=tag_names(tag_name)
if n_elements(input_tag) ne 1 then begin
 message,'input one keyword at a time',/cont
 return,0
endif
input_tag=input_tag(0)

;-- check first level tags

tags=tag_names(stc)
stags=strtrim(tags,2)
intag=strtrim(input_tag,2)
if is_number(match) then begin
 if match gt 0 then begin
  intag=strmid(intag,0,match)
  stags=strmid(stags,0,match)
 endif
endif
clook=where(intag eq stags,count)
if count ne 0 then begin
 stat='tag_value=stc.'+tags(clook(0))
 status=execute(stat)
 err=0 
endif

;-- if not found on first level then search nested structures recursively

if err eq 1 then begin
 for i=0,n_elements(tags)-1 do begin
  if datatype(stc(0).(i)) eq 'STC' then begin
   arg='tag_value=get_tag_value(stc.'+tags(i)+',/'+input_tag+',err=err,/quiet)'
   stat=execute(arg)
   if err eq 0 then goto,found
  endif
 endfor
endif
   
found:
if err and (not keyword_set(quiet)) then message,input_tag+' tag not found',/contin

return,tag_value
end

