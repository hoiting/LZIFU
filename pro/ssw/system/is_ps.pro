

function is_ps, filename, loud=loud
;
;+
;   Name: is_ps
;
;   Purpose: boolean function - is file a PostScript File?
;
;   Input Parameters:
;      filename - file name to check
;   
;   Calling Sequence:
;      truth=is_ps(filename)
;   History:
;      14-apr-1997 - S.L.Freeland 
;-      

retval=0

if file_size(filename) gt 4 then begin
   patt=bytarr(4)  
   openr,lun,filename,/get_lun
   readu,lun,patt
   free_lun,lun
   retval=(strupcase(string(patt)) eq '%!PS')
endif

return, retval
end
