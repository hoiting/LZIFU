;+
; Project     : EIS
;
; Name        : PAD_TAG
;
; Purpose     : pad strings tags in structure to have non-zero length
;
; Category    : structures
;
; Syntax      : IDL> pad_tag,struct
;
; Inputs      : STRUCT = input structure
;
; Outputs     : STRUCT = padded structure
;
; Keywords    : None
;
; History     : 2-Jan-2005,  D.M. Zarro (L-3Com/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro pad_tag,struct,err=err

if not is_struct(struct) then return

tags=tag_names(struct)
for i=0,n_elements(tags)-1 do begin
 sz=size(struct[0].(i))
 dtype=sz[n_elements(sz)-2]
 if dtype eq 7 then begin
  len=strlen(struct.(i))
  chk=where(len eq 0,count)
  if count gt 0 then struct[chk].(i)=' '
 endif
endfor

return

end
