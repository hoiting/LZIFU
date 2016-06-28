;+
;
; NAME: 
;	GET_RECENT_FILE
;	
; PURPOSE:
;	This function returns the name of the most recent file
;	from a list of files with dates encoded in their names.
;
; CATEGORY:
;	SYSTEM
;
; CALLING SEQUENCE:
;	Most_recent_file = Get_recent_file( Filelist [,DATE=DATE, ALLSORTED=ALLSORTED] )
;
; CALLS:
;	file2time, file_list, curdir, loc_file, uniqo
;
; INPUTS:
;       none explicit, only through commons;
;
; OPTIONAL INPUTS:
;
; OUTPUTS:
;       none explicit, only through commons;
;
; KEYWORD INPUTS:
;
; KEYWORD OUTPUTS:
;	DATE - time in sec from 1-jan-1979 for file(s) encoded in file name.
;	ALLSORTED - If set, return array of files sorted by date
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	Use file2time to parse and interpret time.
;
; MODIFICATION HISTORY:
;	Version 1, richard.schwartz@gsfc.nasa.gov, 27-mar-2001.
;
;-
function get_recent_file, filelist, date=date, allsorted=allsorted



files = filelist

break_file, files, disk, dir, fname
fname = fname( uniqo(fname))
date = file2time(fname+',0000', out='sec')



ord = reverse( sort(date))

files = files(ord)
date  = date(ord)

if keyword_set( allsorted ) then return, files 

date = date[0]
return, files[0]
end
