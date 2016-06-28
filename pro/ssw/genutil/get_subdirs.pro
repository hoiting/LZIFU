function get_subdirs, indir, ls=ls
;
;+
;NAME:
;	get_subdirs
;PURPOSE:
;	To return a list of the subdirectories under a given location
;CALLING SEQUENCE:
;	sdir = get_subdirs('/2p/morrison')
;	sdir = get_subdirs('/ys')
;	sdir = get_subdirs('ys:[sxt]')
;INPUT:
;	indir	- The input directory to find all subdirectories under
;RESTRICTIONS:
;	For VMS system, there has to be a "]" in the input specification
;HISTORY:
;	Written 19-Oct-92 by M.Morrison
;	 5-Jul-94 (MDM) - Modified to add the root directory to the list
;			  of subdirectories found
;	13-Jan-98 (MDM) - Modified to not use "ls -R" option, rather to use
;			  the "find" instruction.
;			- Added /ls option to use the old method
;-
;
if (!version.os ne 'vms') then begin
    if (keyword_set(ls)) then begin
	cmd = 'ls -R ' + indir + ' | grep ":" 
	spawn, cmd, out
	for i=0,n_elements(out)-1 do out(i) = strmid(out(i), 0, strlen(out(i))-1)	;drop the trailing ':'
	if (out(0) eq '') then out = indir else out = [indir, out]	;MDM added 5-Jul-94
    end else begin
	cmd = ['find', indir, '-type', 'd', '-print']	;TODO - add "-follow" switch to follow links?
	spawn, cmd, out, /noshell
    end
end else begin
    temp = str_replace(indir, ']', '...]*.dir;1')
    cmd = 'directory/brief/column=1/nohead/notrail ' + temp
    spawn, cmd, out
    for i=0,n_elements(out)-1 do begin
	out(i) = str_replace(out(i), ']', '.')
	out(i) = str_replace(out(i), '.DIR;1', ']')
    end
end
;
return, out
end
