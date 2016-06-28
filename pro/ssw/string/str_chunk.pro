;+
; Project     : SOHO - CDS
;
; Name        : STR_CHUNK
;
; Category    : string, utility
;
; Purpose     :	Break a string into equi-sized chunks
;
; Explanation :	
;
; Syntax      : IDL> out=str_chunk(in,size)
;
; Inputs      : IN = input string
;               SIZE = string size of each chunk
;
; Opt. Inputs : None
;
; Outputs     : OUT = string array of individual chunks
;
; Opt. Outputs: None
;
; Keywords    : None
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  1-Oct-1998,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function str_chunk,in,csize

on_error,1

if datatype(in) ne 'STR' then begin
 pr_syntax,'out=str_chunk(in,size)'
 return,''
endif

len=strlen(in)
if not exist(csize) then csize=len
if csize le 0 then return,''
i=0
while (i lt len) do begin
 out=append_arr(out,strmid(in,i,csize))
 i=i+csize
endwhile
return,out & end

