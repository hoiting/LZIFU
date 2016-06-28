pro do_reg_backup, type, bdir_in, bdir_out, qdebug=qdebug, $
	nweeks=nweeks, nmonths=nmonths, $
	subdirs=subdirs, levels=levels, $
	check=check
;+
;NAME:
;	do_reg_backup
;PURPOSE:
;	To make a regular backup of a directory tree
;SAMPLE CALLING SEQUENCE:
;	do_reg_backup
;	do_reg_backup, type, bdir_in, bdir_out
;	do_reg_backup, 'month', '/mdisw', '/data0/backups', levels=0
;	do_reg_backup, 'month'
;METHOD:
;	The desire is to make a weekly and monthly backup with 
;	archives of the last few weeks/months.  This routine
;	will cycle through N weeks/months and keep reusing the
;	directory.  The routine can be run daily with the
;	/check switch and then it will only make the weekly
;	backups on Sunday and monthly's on the first of the month.
;	
;	For the command:
;	   IDL> do_reg_backup, 'month', '/mdisw', '/data0/backups'
;	and assuming 14-Apr-97, it will backup
;	   /mdisw/idl, /mdisw/*/idl, /mdisw/*/*/idl
;	   /mdisw/setup, /mdisw/*/setup, /mdisw/*/*/setup
;	and put it into
;	   /data0/backups/week2
;
;	A file /data0/backups/week2_970414.2024 is also created
;	so that the date/time of the backup can be easily found.
;OPTIONAL INPUT:
;	type	- The type of backup ("week" or "month")
;	bdir_in	- The base directory to use as input
;	bdir_out- The base directory to use as output
;OPTIONAL KEYWORD INPUT:
;	qdebug	- If set, don't do the spawning
;	nweeks	- Number of weeks to save (4 max, default=3)
;	nmonths	- Number of months to save (12 max, default=3)
;	subdirs	- The list of directories to backup. 
;		  (Default is "idl" and "setup")
;	levels	- How many levels down to look for "subdirs"
;		  (Default=2)
;	check	- If set, then check that it is Sunday (for
;		  weekly backup) or the 1st of the month (for
;		  monthly backups)
;HISTORY:
;	Written 14-Apr-97 by M.Morrison
;-
;
if (n_elements(type) eq 0) then type = 'week'
if (n_elements(bdir_in) eq 0) then bdir_in = '/ssw'
if (n_elements(bdir_out) eq 0) then bdir_out = '/tsw/ssw_backups'
if (n_elements(subdirs) eq 0) then subdirs = ['idl','setup']
if (n_elements(levels) eq 0) then levels = 2	;counting from 0
;
if (n_elements(nweeks) eq 0) then nweeks = 3
if (n_elements(nmonths) eq 0) then nmonths = 3
;
daytim = !stime
;
case strupcase(type) of
    'WEEK': begin
		anytim2weeks, daytim, xxx, weeks, years
		iback = (weeks mod nweeks) + 1
		if (keyword_set(check)) then begin	;see if it is sunday
		    dow = ex2dow( anytim2ex(daytim) )
		    if (dow ne 0) then begin
			print, 'It is not Sunday.  Returning'
			return
		    end
		end
	    end
    'MONTH': begin
		tarr = anytim2ex(daytim)
		iback = (tarr(5) mod nmonths) + 1
		if (keyword_set(check)) then begin	;see if it is the first of the month
		    if (tarr(4) ne 1) then begin
			print, 'Its not the first of the month.  Returning'
			return
		    end
		end
	    end
     else: stop, 'Unrecognized type: ' + type
endcase
;
outdirnam = strlowcase(type) + strtrim(iback,2)
outdir = concat_dir(bdir_out, outdirnam)
;
if (not keyword_set(qdebug)) then spawn, 'rm -rf ' + outdir + '*'		;clear out the directory (since it will be recycled)
;
if (not file_exist(bdir_out)) then spawn, 'mkdir ' + bdir_out
if (not file_exist(outdir)) then spawn, 'mkdir ' + outdir
;
for i=0,levels do begin
    pre = ''
    for j=1,i do pre = pre + '*/'
    dirs = arr2str(pre + subdirs, delim=' ')
    cmd = 'cd ' + bdir_in + '; tar -cfv - ' + dirs + ' | (cd ' + outdir + '; tar -xpf -)'
    print, cmd
    if (not keyword_set(qdebug)) then spawn, cmd
end

spawn, 'touch ' + outdir + '_' + ex2fid(anytim2ex(daytim))
spawn, 'chmod -R 775 ' + outdir		;make sure we can overwrite/delete

end
