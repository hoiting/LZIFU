function str_istype, struct, _extra=_extra
;+
;   Name: str_istype
;
;   Purpose: boolean function - check for structure type (instrument)
;
;   Calling Sequence:
;      truth=str_istype(struct, /KEYWORD)
;            keyword=tag name   
;
;   History:
;      5-jun-1995 (SLF)
;   
;   Restrictions:
;      proto
;-
;
retval=0
nkeywords=n_tags(_extra)

expected=ssw_instruments()

case 1 of
   n_tags(_extra) eq 0: message,/info,"Must supply at least 1 keyword..."
   n_tags(struct) eq 0: 
   else: begin
      ktags=tag_names(_extra)
      stags=tag_names(struct)
      retval=1
      for i=0, nkeywords -1 do retval= retval and       $
         (is_member(ktags(i),stags,/ignore_case) or     $
         is_member(ktags(i)+'*',stags,/wc,/ignore_case))
   endcase
endcase

return, retval
end


