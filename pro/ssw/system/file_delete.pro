pro file_delete, files, status, quiet=quiet, _extra=extra
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
;
;		*** NOTE: This parameter is obsolete! ***
;
;   Keyword Parameters:
;      quiet - if set, dont print message on failures
;
;   Calling Sequence:
;      file_delete, files [,status , /quiet]
;
;   History:
;      slf, 8-feb-1993		
;	12-May-2003, William Thompson, added obsolete warning
;      Zarro, 15-May-2003 - added _EXTRA to catch stray keywords
;
;   Restrictions: must have write priviledge to requested files
;
;			    *** IMPORTANT NOTE ***
;
;	This routine conflicts with an IDL built-in routine of the same name,
;	introduced in version 5.4.  The syntax is very similar, except that the
;	built-in routine does not support the STATUS parameter.  If one wishes
;	to use the procedure rather than the built-in routine, use
;	SSW_FILE_DELETE instead.
;
;-
;
;  Issue a warning if the STATUS parameter was passed.
;
if n_params() eq 2 then begin
    message,/continue, 'OBSOLETE ROUTINE -- Use SSW_FILE_DELETE instead'
    help, /traceback
endif
;
;  Issue a warning if an unsupported keyword was passed.
;
if n_elements(extra) ne 0 then print,	$
	'FILE_DELETE: Warning -- unsupported keywords passed'
;
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
