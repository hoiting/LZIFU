function write_access, directory
;+
;   Name: write_access
;
;   Purpose: check directory for write access
;
;   Input Parameters:
;      directory - directory to check (default is current directory)
;
;   Calling Sequnce:
;      writable=dir_write_access(directory)
;
;   Calling Example:
;      if write_access('directory') then begin ....
;
;
;   Restrictions:
;      scaler directories for now
;
;   8-Mar-1995 (SLF)
;-
if not keyword_set(directory) then directory=curdir()
filename=get_user() + strcompress(string(long(systime(1))),/remove)

chkfile=concat_dir(directory,filename)

file_append, chkfile, 'test', error=error
writable=1-error

if file_exist(chkfile) then file_delete,chkfile

return, writable
end
