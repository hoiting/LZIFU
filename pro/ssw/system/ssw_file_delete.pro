pro ssw_file_delete, files, status, quiet=quiet
; 
;+
;   Name: file_delete
;
;   Purpose: system/shell independent file delete
;
;   Input Parameters:
;      files - scaler string or vector string array of filenames to delete
;
;   Output Paramters:
;      status - sucess  1 -> deleted or not there to begin with
;			0 -> couldnt delete (it's still there)
;			     (scaler or vector depending on files)
;   Keyword Parameters:
;      quiet - if set, dont print message on failures
;
;   Calling Sequence:
;      file_delete, files [,status , /quiet]
;
;   History:
;      slf, 8-feb-1993		
;      S.L.Freeland - made 'ssw_file_delete' from 'file_delete'
;                     since RSI screwed me
;
;   Restrictions: must have write priviledge to requested files
;-
status=intarr(n_elements(files))		; initialize to failure
;
qtemp=!quiet
!quiet=keyword_set(quiet)
;
for i=0,n_elements(files)-1 do begin
   on_ioerror,cantopen
   openr,lun,/get_lun,files(i),/delete      
   free_lun,lun
   status(i)=1
   goto,couldopen				; so sue me - blame it
cantopen:					; on idl error trap limits
   status(i)= 1 - file_exist(files(i))		; success if not there
   if 1-status(i) then $
	message,/info,"Can't delete: " + files(i)
couldopen:					; to begin with
endfor
;
!quiet=qtemp					; restore system variable
if n_elements(status) eq 1 then status=status(0); make scaler
return
end
