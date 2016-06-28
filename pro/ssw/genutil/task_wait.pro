;   Name: task_wait
;
;   Purpose: wait for various background tasks to complete
;
;   Input Parameters:
;      NONE as of today (must use keyword filewait for now)
;
;   Keyword Parameters:
;      filewait=filewait - list of one or more files to monitor
;      minsamp = minutes to wait between checks (default is 1 minute1)
;      mail    - if set, send mail when tasks have completed - default is to
;                only send mail on timeout condition.
;      delete  - w/filewait - completion flagged by files deleted (default)
;      create  - w/filewait - completion flagged by files created
;      tohours - timeout (specified in hours)
;      tomins  - timeout (specified in minutes) - default timeout is 1 hour
;      tostop  - on timeout, issue stop 	(default)
;      toretry - on timeout, retry via recursion (to fix problems in parallel)
;      status_file - file name or switch - for loggin task_wait status
;                    messages
;      caller  -   calling routine name (string) for status_file header
;
;   Calling Sequence:
;      task_wait, filewait=filewait [/delete, /create, tomins=tomins, $
;		  tohours=tohours, tostop=tostop, toretry=toretry]
;
;   Calling Examples:
;      task_wait, filewait=filelist, minsamp=5., tomins=30., $
;	  	  caller='monitor', /toretry
;      
;      This example would wait until all files in <filelist> are gone (deleted
;      or renamed). It will check every 5 minutes; if any files still exist
;      after 30 minutes, a mail message is sent (timeout condition).  Since
;      /toretry is set, it would then resubmit itself (user can trouble shoot
;      in parallel).  With CALLER keyword set, it will log messages in 
;      $DIR_SITE_TASKMON/TW_monitor.FID (FID=yymmdd.hhss).  You can terminate
;      the task_wait job (at the next timeout period) which uses /retry by 
;      creating file $DIR_SITE_TASKMON/TW_monitor.FID.tostop 
;      (change from toretry to tostop)
;
;   History:
;      30-Sep-1994 (SLF) - Written to monitor distributed processes
;       1-Oct-1994 (SLF) - Added timeout action (stop or repeat via recursion)
;       2-Oct-1994 (SLF) - Added statusfile output and file-timeout ability
;       3-Oct-1994 (SLF) - Add file-kill option
;       4-Oct-1994 (SLF) - change 'more' to 'prstr' to allow backgrounding!
;
;   Restrictions:
;      This revision uses file creation or file deletion to indicate 
;      task completions, so only works for tasks which do one or the other...
;-
function laststat, files, total, final_tot, accum, timeout
;+ 
;   Name: laststat
;
;   Purpose: format status info for task_wait
;
;-
fstatus=['does not exist','exists']
stat=["TASK_WAIT STATUS","",files + "... " + fstatus(file_exist(files)),""]
stat=[stat, 						         	$
    "Number Files Existing: " + strtrim(fix(total),2) + ", " +        	$
    "Number Expected: " + strtrim(fix(final_tot),2), 			$
    "Time Elapsed  (minutes): " + string(accum,  format='(f6.2)') + ", " +	$
    "Timeout Limit (minutes): " + string(timeout,format='(f6.2)')]
return,stat
end

pro task_wait, filewait=filewait, delete=delete, create=create,  $
     minsamp=minsamp, tomins=tomins, tohours=tohours, mail=mail, $
     loud=loud, tostop=tostop, toretry=toretry, lstatus=lstatus, $
     status_file=status_file, caller=caller

if not data_chk(filewait,/string) then begin
   message,/info,"Currently need to specify FILEWAIT (list of files)
   return
endif

loud=keyword_set(loud)

; set up time between checks (in minutes)
if n_elements(minsamp) eq 0 then minsamp=1.
waitsecs=float(minsamp)*60.

ntasks=n_elements(filewait)
currstat=file_exist(filewait)

; accumulate time in minutes
case 1 of 
   keyword_set(tomins):   timeout=tomins
   keyword_set(tohours):  timeout=tohours*60. 
   else: timeout=60.				; one hour default
endcase

; define normal exit criteria
if keyword_set(create) then final_tot=ntasks else final_tot=0

total=total(file_exist(filewait))
notdone= total ne final_tot
accum=0.				; accumulated time in minutes
notto=accum lt timeout

; temporary? - always make a status file		; ******
if not keyword_set(status_file) then status_file=1	; ****** enable

; If status_file is set, define the task_wait status file name and start-it
if n_elements(caller) eq 0 then caller=get_user()	; define it
statfile=keyword_set(status_file) or keyword_set(caller)

if statfile then begin
;  recursive calls will use existing status_file
   if data_chk(status_file,/string) then statout=status_file else $
      statout=concat_dir('$DIR_SITE_TASKMON','TW' + '_' + caller + '_' + ex2fid(anytim2ex(!stime)))
   if not file_exist(statout) then begin
      message,/info,"Logging task_wait status to: " + statout
      pr_status,text,/idldoc,caller=caller
      stop_file=statout + '.tostop'		
      kill_file=statout + '.kill'
      file_append,statout,text,/new
      if keyword_set(toretry) then file_append,statout, ["", 	$
        "Create File: " + stop_file , 				$
        "              to STOP at next TIMEOUT interval",""]
      file_append, statout, ["", 				$
        "Create File: " + kill_file , 				$
        "              to STOP at next SAMPLE  interval",""]
   endif
endif

stop_file=statout + '.tostop'		; file to force killing at TO time
kill_file=statout + '.kill'		; file to force killing at SAMPLE time
;					

if not keyword_set(lstatus) then lstatus=''
laststat=[lstatus,laststat(filewait, total, final_tot, accum, timeout)]

; start the task waiting loop
while notdone and notto do begin
  if loud then message,/info,"waiting " + strtrim(waitsecs/60.,2) + " minutes..."
  wait,waitsecs				; wait for specified time
  total=total(file_exist(filewait))	; re-check file status
  notdone= total ne final_tot		; assign boolean
  accum=accum + (waitsecs/60.)		; accumulate total time in minutes
  to=accum gt timeout
  notto=1-to
  laststat=[lstatus,laststat(filewait, total, final_tot, accum, timeout)]
  if loud then prstr,laststat
  if statfile then begin
      contents=rd_tfile(statout)		; limit size of monitor
      nlines=n_elements(contents)
      if nlines gt 51 then contents= $		
         [contents(0:34),"", $
          "********************** EDITED CONTENTS **********************","",$
          contents(nlines-16:nlines-1)]
      file_append,statout,[contents,laststat],/new
  endif
  killit = file_exist(kill_file)		; TERMINATE IMMEDIATELTY
  if killit then begin
     subj="*** TASK_WAIT - FILE KILL ***"
     toaction="*** KILL FILE: " + kill_file  + " EXISTS, STOPPING"
     notto=0					; force timeout     
     toretry=0					; dont retry
  endif
endwhile

toretry=keyword_set(toretry)

if notdone then begin
   prstr,final_status
   if not killit then toaction=(["TOSTOP set - Stopping exectution","TORETRY set - Restarting..."]) (keyword_set(toretry))
   if file_exist(stop_file) and toretry then begin
      subj="*** TASK_WAIT - FILE T/O STOP ***"
      toaction="*** STOP FILE: " + stop_file  + " EXISTS, STOPPING"
      toretry=0
   endif
   if n_elements(subj) eq 0 then subj="*** TASK_WAIT - TIMEOUT CONDITION ***"
   mess=[subj,toaction,"",laststat]
   message,/info,subj
   file_append,statout,mess
   mail,mess,subj=subj,/self
   if keyword_set(toretry) then begin
      task_wait, filewait=filewait, tomins=tomins, tohours=tohours, mail=mail, $
         lstatus=["","*** RECURSIVE CALL ***",mess],minsamp=minsamp, create=create, $
         delete=delete, loud=loud, tostop=tostop, toretry=toretry,             $
         status_file=statout
   endif else message,"Stopping on Timeout or Kill condition..."
endif else begin
   message,/info,"Normal exit (all tasks completed).."
   mess=["TASK_WAIT Normal Exit","",laststat]
   file_append,statout,mess
   if keyword_set(mail) then mail,mess, subj="TASK_WAIT Normal Exit"         
endelse   


return
end
