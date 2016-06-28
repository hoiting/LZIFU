function file_list2, dirs, str, files=file, fdir=fdir
;
;+
;NAME:
;	file_list2
;PURPOSE:
;	Given a set of directories and a list of filenames, return
;	the full filenames where they exist.  No wildcards are
;	permitted in "dirs" or "str"
;CALLING SEQUENCE:
;	infil = file_list2(dirs, str)
;	infil = file_list2(data_paths())
;	infil = file_list2(data_paths(), 'spr*')
;INPUTS:
;	dirs	- The directories to search
;		  If not present, it uses the default directory
;	str	- The file names to find
;OUTPUTS:
;	RETURNS: The file list (including the path).
;OPTIONAL KEYWORD OUTPUT:
;	files	- Just the file names of the filenames
;	fdirs	- Just the directory portion of the filenames
;HISTORY:
;	Written 13-Jan-98 by M.Morrison
;-
;
ff = ''
if (n_elements(dirs) eq 0) then dirs = ''		;use default dir
ff0 = concat_dir(dirs(0), str)
for i=1,n_elements(dirs)-1 do ff0 = [ff0, concat_dir(dirs(i), str)]
qexist = file_exist(ff0)
ss = where(qexist, nss)
if (nss eq 0) then begin
    out = ''
end else begin
    out = ff0(ss)
    break_file, out, dsk_log, dir, filnam, ext
    file = filnam+ext
    fdir = dsk_log+dir
end
;
return, out
end

