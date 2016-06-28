pro wrt_str, structure, unit
;
;+ 
;   Name: wrt_str
;
;   Purpose: write data structure size information for SXT generic files
;
;   Input Parameters:
;      structure: input idl structure type
;      unit: logical unit for write - assumed alread open
;
;   Method: recursive for nested structures
;
;
;   History: slf, 10/25/91
;
;- 
;

;;on_error,2				;return to caller

str_size = size(structure)
;;if n_elements(str_size) ne 4 or str_size(2) ne 8 then $
;;   message,'structure required'
if (not data_chk(structure,/struct)) then message,'structure required'
;
writeu,unit,str_size				;size (idl)
writeu,unit,n_tags(structure)			;number tags
writeu,unit,tag_names(structure)		;tag names
;
for i=0, n_tags(structure)-1 do $		;for each tag
   if n_tags(structure.(i)) eq 0 then $ 	;if not structure,
      writeu,unit,size(structure(0).(i)) else $ ;write idl size
         wrt_str, structure(0).(i), unit	;else recurse 
return
end
