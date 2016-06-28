function path_lib, name, directory = direct, multi = multi, nopro = nopro
;+
; NAME:
;	PATH_LIB
; PURPOSE:
;	Extract the path of one or more procedures.
; CATEGORY:
;	
; CALLING SEQUENCE:
;	path = path_lib()	; For prompting.
;	path = path_lib(name)   ; Find full path for procedure Name using
;				  the current !PATH.
; INPUTS:
;	Name = string containing the name of the procedure.
;	Under Unix, Name may be "*" for all modules.
;	
; KEYWORDS:
; Unix KEYWORDS:
;	DIRECTORY = directory to search.  If omitted, use  current directory
;		and !PATH.
;	MULTI = flag to allow the return of more than one pathname if the module
;		exists in more than one directory in the path + the current
;		directory.
;       NOPRO = If present and set, then ".pro" is not appended to name.
; VMS KEYWORDS:
;	None.
;
; OUTPUTS:
;	The path name is returned as a string array.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	None.
; RESTRICTIONS:
;	Nothing happens under VMS, except a warning message is printed.
; MODIFICATION HISTORY:
;	Written, J. R. Lemen, 2-mar-92
;-

on_error,2                        ;Return to caller if an error occurs
if (!version.os eq 'vms') or (!version.os eq 'DOS') then begin
   print,' ** Warning in path_lib ===>  Not supported for ',!version.os
   return,''
endif else aa = path_lib_unix(Name, directory=direct, multi=multi, nopro=nopro)

return,aa
end
