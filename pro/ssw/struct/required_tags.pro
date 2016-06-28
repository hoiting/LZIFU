
function required_tags, index, taglist, _extra=_extra, $
		   ssw_standard=ssw_standard, loud=loud, $
		   missing_tags=missing_tags
;+
;   Name: required_tags
;  
;   Purpose: check input structure of fits header for 'required' tags
;     
;   Input Parameters:
;      index - IDL structures or FITS header array (input to gt_tagval)
;      taglist - array or comma delimited list of tags to 
;
;   Output:
;      function returns boolean (true =1=> all required tags present)
;                                false=0=> at least one required tag missing)  
;
;   Keyword Parameters:
;      /xxx, /yyy /(etc) - optionally supply tags via keyword switches
;      ssw_standard - if set, check against a minimalist SSW standard set  
;      missing_tags (output) - list of missing tags, if any
;
;   Calling Sequence:
;      ok=required_tags(index,'date_obs,crpix1,cdelt1')      ; tags in struct?
;      ok=required_tags(index,/date_obs,/crpix1,/cdelt1)     ; same
;      ok=required_tags(header,/date_obs,/crpix1,/cdelt1)    ; same for FITs
;                                                            ; header  
;   History:
;      9-March-1998 - S.L.Freeland - written to simplify some common checks
;     18-Jul-2000   - S.L.Freeland - suppress warning message unless /LOUD set
;-
loud=keyword_set(loud)

syntax=['IDL> truth=valid_tags(index, taglist)', $
	'IDL> truth=valid_tags(index, /tag1, /tag2...']

if not data_chk(index,/struct) or data_chk(index,/string) then begin
   if loud then box_message,'Need structure ("index") or string (fits header) input...'
   return,0
endif

case 1 of
     data_chk(_extra,/struct): tlist=tag_names(_extra)
     data_chk(taglist,/scalar,/string): tlist=str2arr(taglist)
     data_chk(taglist,/string): tlist=taglist
     keyword_set(ssw_standard): $
	    tlist=str2arr('date_obs,naxis1,crpix1,crval1,cdelt1')
     else: begin
        box_message,['Supply taglist (string, string array or via keywords',  syntax]
        return,0
     endcase
endcase

tlist=strtrim(tlist,2)

nreq=n_elements(tlist)
tfound=lonarr(nreq)

for i=0,nreq-1 do begin
   chk=gt_tagval(index, tlist(i), found=found)
   tfound(i)=found
endfor

totfound=total(tfound)

missing_tags=''
case 1 of
   totfound eq nreq: mess = 'All tags found'
   totfound eq 0: begin
     missing_tags=tlist
     mess='None of the required tags were found'
   endcase
   else: begin
      missing_tags=tlist(where(1-tfound))
      mess='The following tags are missing:'
  endcase
endcase

if loud then box_message,[mess, '   ' + arr2str(missing_tags,' , ')]

return, totfound eq nreq
end
