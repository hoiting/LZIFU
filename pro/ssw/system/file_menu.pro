function file_menu, dirs, str, interactive=interactive
;
;+
;NAME:
;	file_menu
;PURPOSE:
;	Given a set of directories (and optionally a partial
;	filename with a wildcard), display a menu to allow the
;	user to select the file he wants.
;INPUTS:
;	dirs	- The directories to search
;		  If not present, it uses the default directory
;	str	- The wildcard partial filename to search for
;	interactive - If set, ask the user to type in the partial
;		  filename to search for
;OUTPUTS:
;	RETURNS: The file name (including the path).  If quit/exit
;		 is selected, then a null string is returned.
;LIMITATIONS:
;	For a filename that is 32 characters long (for example:
;	/0d0/ops/reformat/ada910903.0046), the routine will only
;	handle 365 of those files.   BEWARE.  If the number is too
;	large, it will bomb.
;HISTORY:
;	Written 21-Oct-91 by M.Morrison
;	18-Mar-92 (MDM) - Changed to use "file_list" and "wmenu_sel"
;-
;
if (keyword_set(interactive)) then begin
    str = ''
    read, 'Enter file to search for - use wildcards (ie: sfr*) ', str
end else begin
    if (n_elements(str) eq 0) then str = '*'
end
;
ff = file_list(dirs, str)
;
if (ff(0) eq '') then begin
    print, 'No files found with the following parameters:
    print, 'Directories: ', dirs
    print, 'File Specifier: ', str
    return, ''
end
;
ifil = wmenu_sel(ff, /one)
ifil = ifil(0)
if (ifil eq -1) then file='' else file = ff(ifil)
;
return, file
end
