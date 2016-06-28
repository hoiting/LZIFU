pro UNIX_CMD, Cmd0, Out, Tkill, Check = Check, Qdebug = Qdebug, outfil=outfil, nocheck_connect=nocheck_connect
;
;+
;NAME:
;	UNIX_CMD
;PURPOSE:
;	To execute a UNIX command and to monitor the command to make
;	sure that it completed in the expected time.  If not, kill the
;	process and re-submit the command
;SAMPLE CALLING SEQUENCE:
;	unix_cmd, cmd, out, tkill
;	unix_cmd, 'rsh isass0 ls -l /ydb/evn', out, 5*60.
;INPUT:
;	cmd	- The command to execute
;	tkill	- The time in seconds to wait before killing and
;		  re-submitting the command (in the event that it
;		  has hung). 
;OUTPUT:
;	out	- The results from the command
;OPTIONAL KEYWORD INPUT:
;	check	- The number of seconds between checks.  Defaults to
;		  1 second.
;	qdebug	- If set, then print some debug statements
;	outfil	- The output file to send the results to
;	nockeck_connect - If set, do not check that a connection was made
;		  to the remote node.  Default is to check for lost 
;		  network connections.
;METHOD:
;	Spawn the command as detached (using "&") and monitor the
;	process.  The output goes to a file (default is in the
;	home directory)
;
;	Use double quotes (") to isolate wildcards * and any time
;	that quotes are required in the command to be executed.
;	EXAMPLE:
;             rsh sxt2 "setenv ys_quiet; source ~/.yslogin; printenv DIR_SFD_DAILY1"
;HISTORY:
;	Written 1994 by M.Morrison/K.J.Liu
;	 1-Feb-95 (MDM) - Modified to make the temporary file have the PID
;			  in the file name so that two UNIX_CMD jobs can
;			  run in parallel
;	 9-Feb-95 (MDM) - Modified to recognize NFS stale handling error
;			- Added debug statement
;	27-Feb-95 (MDM) - Re-inserted 14-Dec-94 (MDM) debug statement 
;-
;
;
;
if (n_elements(tkill) eq 0) then tkill = 60    ;give 60 seconds to complete the command by default
;
qdelete = 0
if (n_elements(outfil) eq 0) then begin
    spawn, 'echo $$', pid0	;not really the parent PID, so a conflict can happen every once in a while?
    outfil = concat_dir(getenv('HOME'), 'unix_cmd.temp'+pid0(0))
    qdelete = 1
end

iretry = 1
top:	;---- retry if connection is lost

file_delete, outfil
if (strpos(Cmd0, '> ') eq -1) then cmd = Cmd0 + ' >& ' + outfil else cmd = cmd0		;MDM changed > to >& 31-Aug-94
;cmd = '/bin/csh -c "' + Cmd + ' ; exit " &'
 cmd = "/bin/csh -c '" + Cmd + " ; exit ' &"
qdone = 0
if keyword_set(Check) then tstep = Check $		;wait check seconds between checks
	else tstep = 1					;check every second

start_time = systime(1)
if (keyword_set(qdebug)) then print, 'CMD: ' + cmd
spawn, cmd, result	;, pid = pid
pid = (str2arr(result, delim=' '))(1)

while (not qdone) do begin
    wait, tstep
    pscmd = ' ps ' + strtrim(pid,2)		;MDM removed /bin/csh call 13-Sep-94
    if (!version.os eq 'IRIX') then pscmd = '/bin/csh -c "ps -p ' + strtrim(pid,2) + ' "'
    spawn, pscmd, psresult
    qdone = 1
    qrunning = (N_Elements(psresult) ge 2)
    if (qrunning) then qrunning = (psresult(1) ne 'Exit 1')
    if (qrunning) then begin	;job still running
	qdone = 0
	run_time = systime(1) - start_time
	if (run_time gt Tkill) then begin
	    tbeep, 4
	    print, '********** Having to kill and restart a hung process ********
	    cmd2 = 'kill -9 ' + strtrim(pid,2)
	    spawn, cmd2
	    start_time = systime(1)
	    print, cmd
	    spawn, cmd, result
	    pid = (str2arr(result, delim=' '))(1)
	endif
    endif
endwhile

if (not keyword_set(nocheck_connect)) then begin	;if allowed to check for lost connection
    ;---- MDM added check for can't fork and no more processes errors
    spawn, 'grep -i "connection timed out" ' + outfil, result1	& if (result1(0) eq 'Exit 1') then result1 = ''
    spawn, 'grep -i "Can''t fork" '          + outfil, result2	& if (result2(0) eq 'Exit 1') then result2 = ''
    spawn, 'grep -i "No more processes" '    + outfil, result3	& if (result3(0) eq 'Exit 1') then result3 = ''
    spawn, 'grep -i "Stale NFS file handle" '+ outfil, result4	& if (result4(0) eq 'Exit 1') then result4 = ''
    if (result1(0) ne '') or (result2(0) ne '') or (result3(0) ne '') or (result4(0) ne '') then begin	;lost the connection
	iretry = iretry + 1
	print, 'Execution PROBLEM: ' + result1 + result2 + result3
	tbeep, 3
	print, 'Waiting 10 seconds before starting attempt # ' + strtrim(iretry,2) + ' again for ' + cmd0
	wait, 10
	goto, top		;bad coding, but... 
     end
end

;
if (file_stat(outfil,/size) eq 0) then out = '' else out = rd_tfile(outfil)
if (qdelete) then File_Delete, outfil
;
if (n_elements(out) eq 1) and (out(0) ne '') then print, 'UNIX_CMD:  One line of output: ' + out	;MDM added 31-Aug-94
;
end




