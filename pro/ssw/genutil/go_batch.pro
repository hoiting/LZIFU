pro go_batch, command_list, nodelist=nodelist, user=user, remove=remove, $
	batchdir=batchdir, jobname=jobname, logdir=logdir, logfile=logfile, $
	mail=mail, nodelete=nodelete, proname=proname, logname=logname, $
	defnodes=defnodes, caller=caller
;+
;   Name: go_batch
;
;   Purpose: make and idl 'batch' job and 'submit' it (using VMS terminology)
;            (puts and end statement on your command list and calls idl_batch)
;
;   Input Parameters:
;      command_list - one or more idl statements to execute
;
;   Keyword Parameters:
;      nodelist - one or more nodes to submit job on (will choose 'best' node)
;      user     - user for remote job (ignored if no nodelist)
;      remove   - if set, remove selected node from nodelist (for distribuinting jobs)
;      batchdir - directory for job (added to IDL !path) - default = $DIR_SITE_BATCH
;      logdir   - if set, directory for log file
;      nodelete - if set, do not delete job & log after succesful completion
;      defnodes - if set, will use node list specified by $SITE_BATCHNODES
; 			  (see is_bestnode documentation)
;     caller    - string name of calling routine (passed to pr_status)
;
;   Calling Sequence:
;      go_batch, command_list [nodelist=nodelist, user=user, batchdir=batchdir, $
;			      [logdir=logdir, logfile=logfile]
;
;   Calling Examples:
;      go_batch, 'daily_forecast' , nodelist=['flare13','flare14','flare15']
;      (runs the idl command 'daily_forecast' as a background task on the
;      (least utiilized machine in the nodelist)
;      
;   Side Effects:
;      and idl child process is submitted in the background on the specified
;      or best node available.  
;
;   History:
;      29-Sep-1994 (SLF) written to facilitated distributed processing
;       1-Oct-1994 (SLF) added job file capability 
;       2-Oct-1994 (SLF) added CALLER keyword (passed to pr_status)
;-
;
common go_batch_blk, count		; used for uniq jobnames

if not data_chk(command_list,/string) then begin
   message,/info,"Must supply command, command list, or filename...
   return
endif

comm_list=command_list

if n_elements(count) eq 0 then count=0 else count=(count+1) mod 100

filein=0
if n_elements(comm_list) eq 1 and file_exist(comm_list) then begin
   message,/info,"job file name supplied"
   nodelete=1
   break_file,comm_list(0),logdir,batchdir,jobname,ext,ver
   comm_list=rd_tfile(comm_list(0))      
   filein=1
endif   


; the value of environmental $DIR_SITE_BATCH may be set in the 
; site setup file $ys/site/setup/setup_dirs 

if not keyword_set(batchdir) then batchdir = '$DIR_SITE_BATCH'
if not keyword_set(logdir)   then logdir   = '$DIR_SITE_LOGS'

; note - batchdir must be in the IDL path on the remote machin... (*** need check ***)
if not file_exist(batchdir) then begin
   message,/info,"Batch directory: " + batchdir + " does not exist"
   message,/info,"Using $ys/site/soft/atest/util..."
   batchdir="$ys/site/soft/atest/util"
endif 

local=get_host(/short)
; determine optimal node if nodelist is array or undefined

if data_chk(nodelist,/scaler,/string) then best=nodelist else $
   best=is_bestnode(nodelist,defnodes=defnodes,remove=remove)			

rshcmd=local ne best or keyword_set(user) 
if not keyword_set(user) then user=get_user()
message,/info,"Using node: " + best

if not keyword_set(jobname) then begin
   jobname=str2arr( (str2arr(comm_list(0)))(0),'_')
   jobname='gob_' + arr2str(strmid(jobname,0,1),'') + '_' + $
     strmid(get_user(),0,3) + '_' + ex2fid(ut_time(/ex)) + '_' + $
	string(count,format='(i2.2)')
endif
		
proname=concat_dir(batchdir,jobname+'.pro')
logname=concat_dir(logdir,  jobname+'.log')

remchoice=[' /remove ',' ']

cmd="nohup $DIR_GEN_SCRIPT/idl_batch " + jobname + $
	remchoice(keyword_set(nodelete)) + logname + " &"

; make the job file if the user supplied commands instead of a filename
if not filein then begin
;  make sure there is only one end statement (dont add one if users supplies it)
   noendss=where(strupcase(strtrim(comm_list,2)) ne 'END',noendcnt)
   commands=comm_list(noendss)
;  get some status info to insert
   pr_status,header,/idldoc, caller=caller
   file_append,/new,proname,[header,commands,'end']  ; make jobfile
endif   

if rshcmd then begin
   rsh, best, cmd, user=user, /echo 
endif else begin
   print,"CMD: " + cmd
   spawn, cmd
endelse

return
end
