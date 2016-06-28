function str_taginfo, structure, bcnt,                          $
   type=type, ndimensions=ndimensions,                          $
   strings=strings, structures=structures,                      $
   ss=ss, nott=nott
;+
;   Name: str_taginfo
;
;   Purpose: return info about all tags in the input structure
;
;   Input Parameters:
;      structure - structure containing tags of interest
;
;   Output Parameters:
;      function returns specified information:
;         info specified by keyword (TYPE (default), NDIMENSION, etc)
;         *OR* boolean (STRING, STRUCTURE, etc) if tag is of specified type
;              [function output is always vector of length = (ntags(structure))]
;
;      bcnt - (booleans only) - count of TRUE values
;
;   Keyword Parameters:
;      TYPE -       if set, return IDL data type of tag (per IDL SIZE function)
;      NDIMENSION - if set, return number of dimensions (size(tag))(0)
;      STRING     - if set, boolean (1 if corresponding tag is string, 0 otherwise)
;      STRUCTURE  - if set, boolena (1 if corrsponding tag is structure...)
;      NOTT       - if set, invert boolean
;      ss (output)- boolean - tag indices where true
;
;   Calling Sequence:
;      info=str_taginfo(structure [,/type, /ndimension]
;      truth=str_taginfo(structure [,/string, /struct, count)
;
;   Calling Examples:
;      tagtypes=str_taginfo(structure,/type)                  ; TYPES
;      stringchekc=str_taginfo(structure,/string,count)       ; strings?
;      notstructs=str_taginfo(structure,/struct,/nott,count)  ; not structures?
;
;   16-aug-1996 - S.L.Freeland
;   24-Sep-1998 - S.L.Freeland - fixed typo per RAS suggestion
;-


retval=-1						; error return
if not data_chk(structure,/struct) then begin
   message,/info,"Expected a structure as input ... returning -1
   return,retval
endif

typex=keyword_set(type)
ndimenx=keyword_set(ndimensions)
structures=keyword_set(structures)
strings=keyword_set(strings)
nott=keyword_set(nott)

ntag=n_tags(structure)
type=lonarr(ntag)
ndimensions=lonarr(ntag)

; fill arrays
for i=0,ntag-1 do begin
   ndimensions(i)=(size(structure(0).(i)))(0)
   type(i)=(size(structure(0).(i)))(ndimensions(i)+1)
endfor

bop=(['eq','ne'])(nott)

case 1 of
   typex: retval=type
   ndimenx: retval=ndimensions
   strings:    exestat=execute( "retval= (type " + bop + " 7)")
   structures: exestat=execute( "retval= (type " + bop + " 8)")
   else: message,/info,"Need to set a keyword..."
endcase

ss=where(retval eq 1,bcnt)

return, retval
end
