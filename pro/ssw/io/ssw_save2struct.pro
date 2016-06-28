function ssw_extra2struct,_extra=_extra ; via DMZarro inspired _extra nugget
return,temporary(_extra) ; keywords + values -> structure via _EXTRA utility
end
   
function ssw_save2struct, ssw_savefile, only_params=only_params
;+
;   Name: ssw_save2struct
; 
;   Purpose: savefile contents -> structure
;
;   Input Parameters:
;      savefile - name of IDL save file
;
;   Keyword Parameters:
;      only_params - optional list of variables to include in output
;                    Comma delimited list 
;
;   History:
;      21-sep-2007 - S.L.Freeland
;      
;   Restrictions:
;      Uses execute so not VM compatible
;-

on_error,2
if not file_exist(ssw_savefile) then begin 
   box_message,'Need to supply valid+existing IDL save file...'
   return,-1
endif
restore,ssw_savefile,/relax ; restore contents -> local variables
if data_chk(only_params,/string) then begin  ; user supplied subset
   vars=strupcase(str2arr(only_params))  
endif else begin 
   sobj=obj_new('IDL_Savefile',ssw_savefile)  ; default = all variables
   vars=sobj->names()
   obj_destroy,sobj
endelse

; construct execute statement
keywords=arr2str(vars + '=' + vars)
estring='retval=ssw_extra2struct(' + keywords + ')'
estat=execute(estring)

if n_tags(retval) ne n_elements(vars) then $ 
   box_message,'Warning: not all requested variables found/returned...' 
 
return,retval
end
