pro files_search, indir, instr, outfil, fil_spec=fil_spec
;
;+
;NAME:
;	files_search
;PURPOSE:
;	Search all files in a set of Unix sub-directories for an input string
;CALLING SEQUENCE:
;	files_search
;	files_search, indir, instr, outfil, fil_spec=fil_spec
;	files_search, '/ys', 'makvec'
;	files_search, '/ys', 'hel2pix', 'dum.dum', fil_spec='*.pro'
;INPUT:
;	indir	- The top directory to search.  All directories under it will
;		  be searched
;	instr	- The string to search all files in the subdirectories for
;OPTIONAL INPUT:
;	outfil	- The name of the file to write the results to.  Default is
;		  "FILES_SEARCH.TXT"
;OPTIONAL KEYWORD INPUT:
;	fil_spec- The file specification to search for ('*' for example)
;		  Default is "*.pro"
;HISTORY:
;	Written Nov-91 by M.Morrison
;	20-Oct-92 (MDM) - Added document header
;			- Added FIL_SPEC
;	27-Oct-92 (MDM) - Renamed from SEA.PRO to FILES_SEARCH.PRO
;-
;
if (n_elements(indir) eq 0) then begin & indir=' ' & read, 'Enter input directory', indir & end
if (n_elements(instr) eq 0) then begin & instr=' ' & read, 'Enter search string  ', instr & end
if (n_elements(outfil) eq 0) then outfil = 'files_search.txt'
if (n_elements(fil_spec) eq 0) then fil_spec = '*.pro'
;
cmd = 'ls -R ' + indir + ' | grep ":"		;get list of subdirs
spawn, cmd, sub_dirs
;
openw, lun, outfil, /get_lun
printf, lun, 'FILES_SEARCH.PRO Run on ', !stime
printf, lun, 'Input directory searching: ', indir
printf, lun, 'Searching for string: ', instr
printf, lun, '  '
;
for isub_dir=0,n_elements(sub_dirs)-1 do begin
    ;
    dir = strmid(sub_dirs(isub_dir), 0, strlen(sub_dirs(isub_dir))-1)
    print, 'Now looking through ', dir
    cmd = 'grep -i ' + instr + ' ' + dir + '/' + fil_spec
    spawn, cmd, result
    ;
    if (result(0) ne '') then for i=0,n_elements(result)-1 do printf, lun, result(i)
end
;
free_lun, lun
end

