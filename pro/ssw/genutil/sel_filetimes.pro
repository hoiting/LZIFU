function sel_filetimes, sttim, entim, files, dir=dir, filter=filter, $
		position=position, qstop=qstop, $
		closest=closest, delta=delta, one_before=one_before, $
		append=append, strrep=strrep
;+
;NAME:
;	sel_filetimes
;PURPOSE:
;	To select the files within a time range (assuming the file
;	date/time is in the filename in YYMMDD.HHMM format
;SAMPLE CALLING SEQUENCE:
;	files = sel_filetimes('1-jun','1-jul',files)
;	dirs = file_list('/data14/mdi_summary/daily/maglc', '*')
;	files = sel_filetimes('1-jun','1-jul',dir=dirs, filter='*.fts')
;	files = sel_filetimes(closest='1-jul',dir=dirs, filter='*maglc_re*')
;INPUTS:
;	sttim	- the starting date/time
;	entim	- the ending date/time
;INPUT/OUTPUT:
;	files	- The full list of files to search through.  It is output
;		  if it is not defined coming in
;OPTIONAL KEYWORD INPUT:
;	dir	- The director(ies) to search
;	filter	- The wildcard filter to use to select files in the
;		  directories
;	one_before- If set, then get the file which immediately PRECEDES
;		  the input time (used when file times are the START time
;		  of a block of data).
;	append	- If set, append that string to the end of the file
;		  name (ie: '_0000' to get FILE2TIME to work)
;	strrep	- If set, it must be a two element string array.  A string
;		  substitution is done to trick FILE2TIME
;	position- The starting position of the YYMMDD.HHMM string.  It is
;		  derived by looking for the charcter "9" otherwise.
;			** OBSOLETE since 14-Oct-97 **
;RESTRICTION:
;	All file names must be of the same form
;HISTORY:
;	Written 30-Aug-96 by M.Morrison
;	14-Oct-97 (MDM) - Modified to use Freeland FILE2TIME
;			- Added option CLOSEST and DELTA
;	11-Nov-97 (MDM) - Added /ONE_BEFORE
;-
;
if (n_elements(files) eq 0) then begin
    if (n_elements(dir) eq 0) then dir = ''
    if (n_elements(filter) eq 0) then filter = '*'
    files = file_list(dir, filter)
end
;
if (files(0) eq '') then begin
    print, 'SEL_FILETIMES: No files found'
    return, ''
end
;
files0 = files
if (keyword_set(append)) then files0 = files0 + append
if (n_elements(strrep) eq 2) then files0 = str_replace(files0, strrep(0), strrep(1))
daytim = file2time(files0, out_style='int')
;
if (keyword_set(closest)) then begin
    ss = tim2dset(daytim, closest, delta=delta)
    out = files(ss)
end else begin
    ss = sel_timrange(daytim, sttim, entim, between=(1-keyword_set(one_before)))
    if (ss(0) eq -1) then out = '' else out = files(ss)
end
;
if (keyword_set(qstop)) then stop
return, out
end
