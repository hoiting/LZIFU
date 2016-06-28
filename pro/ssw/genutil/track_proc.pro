function track_proc, name0, proc0, proc1, qdebug=qdebug, kill=kill, mat=mat, result=result, term0=term0
;+
;NAME:
;	track_proc
;PURPOSE:
;	To find all processes for a given process name and user.  Optionally
;	kill the process
;SAMPLE CALLING SEQUENCE:
;	pids = track_proc('mdi', 'mdi_sci')
;	pids = track_proc('mdi', 'mdi_sci', 'bin.sgi/idl')
;	pids = track_proc('mdi', 'mdi_sci', term0='?', /kill)
;RESTRICTION:
;	Only runs on SGI
;HISTORY:
;	Written 30-May-96 by M.Morrison
;	 8-Aug-96 (MDM) - Added TERM0 option
;	18-Apr-97 (MDM) - changed extraction of "term" and "proc"
;	12-May-97 (MDM) - Added protection of parsing problem for PS results
;	12-May-97 (MDM) - Removed protection and added workaround
;-
;
qdebug = 1
;
spawn, ['ps', '-edalf'], result, /noshell
result = result(1:*)		;drop title line
;
;39 S     root     0     0  0  39 RT  *     0:0     88192c50   May 02 ?        0:23 sched
;30 S     root   610   604  0  26 20  *  3175:2031  884feb70   May 02 ?       160:43 /usr/bin/X11/Xsgi -bs -nobitscale 
;30 S morrison  1549  1548  0  39 20  *   548:233   88190350 11:39:38 pts/12   0:03 -tcsh 
;
mat = strtrim(str2cols(result),2)
n = n_elements(mat(*,0))
;if (n lt 15) then begin
;    print, 'Trouble parsing PS results
;    return, -1
;end
;
name = reform(mat(2,*))
pid  = long(reform(mat(3,*)))
ppid = long(reform(mat(4,*)))
;term = reform(mat(13,*))
;proc = reform(mat(15,*))
term = reform(mat(12,*))
;proc = reform(mat(14,*))
proc = reform(mat(n-1,*))	;workaround because runtime and proc merge for long times (see 160:43 above)
;
p1 = strpos(proc, proc0)
if (keyword_set(term0)) then ss = where( (name eq name0) and (p1 ne -1) and (ppid gt 128) and (term eq term0), nss) $
			else ss = where( (name eq name0) and (p1 ne -1) and (ppid gt 128), nss)
if (nss eq 0) then begin
    print, 'Cannot find process: ' + proc0 + ' with user: ' + name0
    return, -1
end
;
print, '---- Main processes found:'
prstr, result(ss), /nomore
;
out_pids = pid(ss)
out_ppids = ppid(ss)
out = -1
for i=0,n_elements(out_pids)-1 do begin
    cpid = out_pids(i)
    cppid = out_ppids(i)
    ;
    while (cpid ne -1) do begin
	out = [out, cpid]
	;ss = where((pid eq cppid) and (name eq name0), nss)
	if (keyword_set(term0)) then ss = where((pid eq cppid) and (name eq name0) and (term eq term0), nss) $
				else ss = where((pid eq cppid) and (name eq name0), nss)
	if (nss eq 0) then begin
	    cpid = -1
	end else begin
	    cpid = pid(ss(0))
	    cppid = ppid(ss(0))
	end
    end
end
out = out(1:*)
;
if (keyword_set(qdebug)) then begin
    ss = where_arr(pid, out)
    print, '---- Related processes found:'
    prstr, result(ss)
end
;
if (keyword_set(proc1)) then begin	;find just the task with process proc1
    ss = where_arr(pid, out)
    p1 = strpos(proc(ss), proc1)
    ss2 = where(p1 ne -1, nss)
    if (nss eq 0) then begin
	print, 'Cannot find process in sub-list with name: ' + proc1
	return, -1
    end
    out = pid(ss(ss2))
    ;
    if (keyword_set(qdebug)) then begin
        ss = where_arr(pid, out)
        print, '---- Related sub-processes found:'
        prstr, result(ss)
    end
end
;
if (keyword_set(kill)) then begin
    cmd = ['kill', '-9', strtrim(out,2)]
    print, 'Issuing cmd: ' + arr2str(cmd, delim=' ')
    spawn, cmd, /noshell
end
;
return, out
end