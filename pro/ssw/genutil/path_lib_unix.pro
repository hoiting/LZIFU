;	(2-mar-92)
function path_lib_unix, name, directory = direct, multi = multi, nopro = nopro
;+
; NAME:
;	PATH_LIB_UNIX
; PURPOSE:
;	Extract the path of one or more procedures.
; CATEGORY:
;	
; CALLING SEQUENCE:
;	path = path_lib_unix()	; For prompting.
;	path = path_lib_unix(name)	; Find full path for procedure Name
;					; using the current !PATH.
; INPUTS:
;	Name = string containing the name of the procedure or "*" for all.
;	
; OPTIONAL INPUT PARAMETERS:
;	DIRECTORY = directory to search.  If omitted, use  current directory
;		and !PATH.
;	MULTI = flag to allow printing of more than one file if the module
;		exists in more than one directory in the path + the current
;		directory.
;       NOPRO =	If present and set, then ".pro" is not appended to name.
; OUTPUTS:
;	The routine returns one or more paths as a string array.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	None.
; RESTRICTIONS:
;	??
; PROCEDURE:
;	Straightforward.
; MODIFICATION HISTORY:
;	Written, 2-mar-92, J. R. Lemen
;-

on_error,2              ;Return to caller if an error occurs
if n_elements(name) eq 0 then begin	;Interactive query?
	name = ''
	read,'Name of procedure or * for all: ',name
endif
name = strlowcase(name)		;make it always lower case

if n_elements(direct) eq 0 then path = ".:" + !path $	;Directories to search
	else path = direct

if n_elements(multi) le 0 then multi = 0	;Only print once
if strpos(name,"*") ge 0 then begin	;Wild card?
	multi = 1		;allow printing of multiple files
	endif

ret_file = ''			; Set up the return variable
while strlen(path) gt 0 do begin ; Find it
	i = strpos(path,":")
	if i lt 0 then i = strlen(path)
	file = strmid(path,0,i)+ "/" + name
	if not keyword_set(nopro) then file = file + ".pro"
;	print,"File: ",file
	xfile = findfile(file)
	path = strmid(path,i+1,strlen(path))
	if (strlen(xfile(0)) gt 0) then begin
	  ret_file = [ret_file, xfile]
	  if multi eq 0 then path = ''
  	endif
endwhile
if n_elements(ret_file) gt 1 then ret_file = ret_file(1:*)

return,ret_file
end
