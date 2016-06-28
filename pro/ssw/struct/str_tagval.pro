function str_tagval, item, tag, _extra=_extra, str_pattern=str_pattern, $
      level=level, struct=struct, found=found, $
      rfound=rfound, recurse=recurse
;+
;   Name: str_tagval
;
;   Purpose: return value stored in specified tag - (nested N-deep struct OK)
;
;   Input Parameters:
;      item       - structure
;      tag/field  - tag to search for
;      
;   Optional Keyword Parameters:
;      str_pattern (input)  - optional match pattern in structure name
;      struct 	   (output) - structure name at match level 
;      level       (output) - nest level where match found 
;		   [ -1 -> not found, 0 -> top level, 1 -> nested one down, etc)
;      found       (output) - boolean found? (level ne -1)
;
;      (rfound&recurse - for internal use only)
;		                                           
;   Calling Sequence:
;      tag_val=str_tagval(item, tagname [,str_patt='pattern', struct=struct, $
;					level=level)
;
;   Calling Examples:
;      tagval=str_tagval(structure,/tagname, level=level) ; via keyword inherit
;      tagval=str_tagval(structure,'tagname',level=level)
;      tagval=str_tagval(index,'periph',str_pattern='sxt',level=level)
;      tagval=str_tagval(rmap ,'periph',str_pattern='sxt',level=level)
;
;   Method:
;      recursive for nested structures
;
;   Restrictions:
;     need to add case where item is FITS header (call WT routine)
;     
;   History:
;      Circa 1-dec-1995 S.L.Freeland
;      15-aug-1996      S.L.Freeland add FOUND keyword (gt_tagval compat)
;      28-oct-1996      S.L.Freeland allow TAG via keyword inheritance
;-

common str_tagval_blk,flevel		; nest/calling level where tag found

recurse=keyword_set(recurse)

if not recurse then begin
   case 1 of
      n_params() eq 2:
      n_elements(tag) eq 0 and keyword_set(_extra): tag=(tag_names(_extra))(0)
      else: begin
            message,/info,"Need to supply input structure/text and a tagname..."
            return,retval
      endcase                 
   endcase
   flevel= -1				; clear common 
   struct=''
   lev=-1
   rfound=lev
endif else lev=rfound

retval=-1
level=-1

case data_chk(item,/type) of
   0: 
   8: begin
         str=tag_names(item,/structure)
         ss=tag_index(item,tag)
         foundit=ss(0) ne -1
         if keyword_set(str_pattern) then foundit = foundit and $
		strpos(str,strupcase(str_pattern)) ne -1
         if foundit then begin
            retval=item.(ss) 
            flevel=rfound+1
            struct=str
         endif else begin  
               lev=lev+1
               for i=0,n_tags(item)-1 do $
                  if data_chk(item.(i),/type) eq 8 and flevel eq -1 then $
                     retval=str_tagval(item.(i),tag,struct=struct,$
                        rfound=lev,str_pattern=str_pattern, /recurse)
               endelse
       endcase
   7: begin
         retval=''
         ss=wc_where(item,tag+'*',/case_ignore,count)
         if count gt 0 then retval=item(ss)
      endcase
   else: retval=item
endcase

level=flevel
found=level(0) ne -1
return,retval
end
