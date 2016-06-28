function gt_tagval, item, tag, str_pattern=str_pattern, $
      level=level, struct=struct, found=found, _extra=_extra, $
      default=default, missing=missing
;+
;   Name: gt_tagval
;
;   Purpose: return value stored in specified tag - (nested N-deep struct OK)
;
;   Input Parameters:
;      item       - structure or vector structure OR FITS header
;      tag/field  - tag to search for (may use /TAG instead)
;      
;   Optional Keyword Parameters:
;      str_pattern (input) -  optional match pattern in structure name
;      /XXXXX      (input) -  TAG may be passed via KEYWORD INHERITANCE
;      missing     (input) -  Fill Value for missing tags (implies type)
;      default     (input) -  Synonym for MISSING (fill or default values)
;      struct 	   (output) -  structure name at match level 
;      level       (output) -  nest level where match found 
;		   [ -1 -> not found, 0 -> top level, 1 -> nested one down, etc)
;      found       (boolean) - true if found (level ne -1)
;
;   Calling Sequence:
;      tag_val=gt_tagval(item, tagname [,str_patt='pattern', struct=struct, $
;					level=level, found=found)
;
;   Calling Examples:
;      tagval=gt_tagval(structures,'tagname', found=found) ; extract str.TAG
;      tagval=gt_tagval(structures,/tagname,  found=found) ; same as above
;      fitval=gt_tagval(fitsheader,/parameter,found=found) ; FITs header
;
;   Method:
;      recursive for nested structures (calls str_tagval)
;
;   History:
;      Circa 1-dec-1995 S.L.Freeland  
;      15-aug-1996   Just make this a synonym for str_tagval 
;      28-oct-1996   S.L.Freeland - allow FITS header
;      19-Feb-1998   S.L.Freeland - add MISSING and DEFAULT keywords (synonym)
;      20-April-1998 Zarro (SAC/GSGC) - added check for single element vector
;      25-Oct-1998   S.L.Freeland - allow MISSING/DEFAULT for 1 element case
;      16-Nov-1998   Zarro (SM&A) - vectorized MISSING/DEFAULT
;
;   Method: call <str_tagval> for structures, <fxpar> for FITs header
;-

; permit search string passwed via keyword inheritance

if n_elements(tag) eq 0 and keyword_set(_extra) then tag=(tag_names(_extra))(0)

retval=''                               ; initialize (not found)
level=-1                                ; 
count=0

case data_chk(item(0),/type) of

   8: retval=str_tagval(item, tag, $
           str_pattern=str_pattern,level=level, struct=struct,found=count)

   7: retval=fxpar(item,tag, count=count)

   else: message,/info,"IDL> out=gt_tagval(item,/tag) or gt_tagval(item,'tag')

endcase

found = count gt 0 			; assign boolean FOUND flag

if not found then begin                 ; return vector
   case 1 of    
      n_elements(default) gt 0: defvalue=default
      n_elements(missing) gt 0: defvalue=missing
      else: defvalue = -1
   endcase
   nitem=n_elements(item)
   ndef=n_elements(defvalue) < nitem    
   retval=make_array(nitem,value=-1,type=datatype(defvalue,2))
   retval(0:ndef-1)=defvalue(0:ndef-1)
   if ndef lt nitem then retval(ndef:nitem-1)=retval(ndef-1)
   if nitem eq 1 then retval=retval(0)
endif  

return, retval

end
