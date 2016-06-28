;+
; Project     :	SOHO - CDS
;
; Name        :	STRIP_STRUCT
;
; Purpose     :	Strip down a structure by removing tags
;
; Use         : SUB=STRIP_STRUCT(STRUCT,INDEX,LEN)
;
; Inputs      :	STRUCT = input structure to strip
;               INDEX  = index (or tag name) to start trip
;               LEN    = # of tags to strip
;
; Outputs     :	SUB = stripped structure
;
; Keywords    :	NAME = new name for stripped structure
;		INVERSE = If set, return structure with only tags that would
;					have been stripped.
;
; Category    :	Structure handling
;
; Written     :	Dominic Zarro (ARC)
;
; Version     :	Version 1.0, 8 Oct 1998 - Zarro (SMA/GSFC)
; Modified:	2 Jan 1999 - Kim Tolbert.  Added inverse keyword
;               24 Dec 2004 - Zarro (L-3Com/GSFC), vectorized
;-

function strip_struct,struct,index,len,inverse=inverse,_extra=extra,err=err

err=''
if (1-is_struct(struct)) or (not exist(index)) or (not exist(len)) then begin
 pr_syntax,'new_struct=strip_struct(struct,index,len)'
 err='invalid inputs'
 if exist(struct) then return,struct else return,-1
endif
if len eq 0 then return,struct

tags=tag_names(struct)
ntags=n_elements(tags)
if is_string(index) then begin
 cut=where(strupcase(strtrim(index,2)) eq tags,count)
 if (count eq 0) then begin
  err='no such tag'
  message,err,/cont
  return,struct
 endif
endif else cut=index
cut= 0 > cut[0] < (ntags-1)
last=(cut+len-1) < (ntags-1)

indices2 = indgen(last - cut + 1) + cut
all = indgen(ntags)
indices = rest_mask (all, indices2)
if keyword_set(inverse) then indices=indices2

return,rem_tag(struct,indices,err=err,_extra=extra)

end

