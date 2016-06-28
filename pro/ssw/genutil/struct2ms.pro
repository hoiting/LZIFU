function struct2ms, anon
;
;+
;   Name: struct2ms
;   
;   Purpose: convert an structure to a make_str structure
;	     (allow nesting of anonymous structures)
;
;   History:
;       10-Feb-1994 (SLF)
;	10-Feb-1996 (MDM) - Modified to handle nested structures
;
;-
if data_chk(anon,/struct) then begin
   name=tag_names(anon,/struct)
   tags=tag_names(anon)
   str='{dummy'      
   for i=0,n_elements(tags)-1 do begin
	if (data_chk(anon(0).(i),/struct)) then begin
	    outtmp = '{' + tag_names(anon(0).(i),/struct) + '}'
	    siztmp = size(anon(0).(i))
	    case siztmp(0) of
		1:
		2: outtmp = string(outtmp, siztmp(1:2),format='("replicate(", a, ",", i4, ",", i4, ")")')
		else: stop
	    endcase
	    str = str + ',' + tags(i) + ':'+ outtmp
	end else begin
	    str=str+ ',' + tags(i) + ':' + fmt_tag(size(anon(0).(i))) 
	end
   end
   outval=make_str(str + '}')
   if n_elements(anon) gt 1 then outval=replicate(outval,n_elements(anon))
   outval=str_copy(outval,anon)
endif else begin
   if data_chk(anon,/defined) then outval=anon else outval=-1
   message,/info,'Input must be a structure
endelse

return, outval
end
