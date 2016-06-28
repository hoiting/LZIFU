function gt_exptime, struct, str_pattern=str_pattern, string=string, convert=convert
;+
;   Name: gt_exptime
;
;   Purpose: return exposusure time from input 
;
;   Input Parameters:
;      struct - input structure 
;
;   Calling Sequence:
;      exptime=gt_exptime(struct [,str_pattern=pattern, /string, $
;              convert=convert_function)
;
;   History:
;      9-jun-1995 (SLF) 
;
;-


if not data_chk(struct,/struct) then begin
   message,/info,"Input must be a structure..."
   return,-1
endif

retval=gt_tagval(struct,'exptime', str_pattern=str_pattern, level=level)

if level eq -1 then begin
   message,/info,"Tag: <exptime>  not defined for input structure"
   return,-1
endif

return,retval
end


