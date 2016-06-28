;+
; PROJECT:
;	SDAC
; NAME:
;	WIN_SPAWN
;
; PURPOSE:
;	This procedure allows SPAWN to return results under WINdows.
;
; CATEGORY:
;	SYSTEM, WINDOWS
;
; CALLING SEQUENCE:
;	WIN_SPAWN, Command, Result
;;
; INPUTS:
;       Command- Set of DOS commands.
;
; KEYWORDS INPUTS:
;	TEMP_FILE - file to overwrite with text output of command.
;	The default location is c:/windows/temp/spawn_results.txt
;       DELETE = set to delete temporary file when done
;       NOSHELL = skip using command shell
;       BACKGROUND/NOWAIT = spawn in background
; KEYWORD OUTPUTS:
;	COUNT - number of lines in result
;
; PROCEDURE:
;	This procedure spawns and saves the results to a local file which
;	is subsequently read back to make the results available in the same
;	way spawn can return results under Unix and VMS.
;
; MODIFICATION HISTORY:
;	Version 1. richard.schwartz@gsfc.nasa.gov, 8-Jun-1998
;	Version 2. Kim Tolbert, 18-Aug-1998 - Use TMP env. variable
;       Version 3. Zarro (SM&A/GSFC), 12-Nov-1999 - added /DELETE and a 
;       CONCAT_DIR
;       Version 4. Zarro (SM&A/GSFC), 17-March-2000 - added some input
;       error checking as well as check if return result requested.
;       Also, added a random number to TEMP_FILE to avoid collisions
;       if more than one copy of program runs simultaneously, or TEMP_FILE
;       already exists
;       Version 5. Zarro (SM&A/GSFC), 23-March-2000
;       added spawning a batch file using START /min /b /high.
;       On some systems, these switches "may" inhibit the annoying shell window
;       20-May-00, Zarro (EIT/GSFC) - removed START
;       20-Jan-01, Zarro (EITI/GSFC) - added IDL 5.4 capability
;       29-Nov-06, Zarro (ADNET/GSFC) - added background capability 
;-

pro win_spawn, command, result, count=count,_extra=extra, $
         temp_file=temp_file,background=background,nowait=nowait,$
         delete=delete,test=test,err=err,noerror=noerror,noshell=noshell

count=0 & result='' & err=''
if strlowcase(os_family()) ne 'windows' then return
if datatype(command) ne 'STR' then begin
 err='invalid input commmand'
 return
endif

want_out=n_params() eq 2
want_error=1-keyword_set(noerror)
background=keyword_set(background) or keyword_set(nowait)

;-- temporary directory to stash files

tempdir = get_temp_dir()

;-- create batch file to spawn  

bat_file=mk_temp_file('win_spawn_'+get_rid()+'.bat',direc=tempdir)
if not want_out then want_error=0b

;-- the new way

if idl_release(lower=5.4,/inc) then begin
 ncmd=n_elements(command)

 if ncmd eq 1 then state='spawn,command,/hide' else begin
  file_append,bat_file,[command,'exit'], /new
  state='spawn,"'+bat_file+'",/hide'
 endelse
 if want_out then begin
  state=state+',result,count=count'
  if want_error then state=state+',/stderr'
 endif
 if background then state=state+',/nowait'
 status=execute(state)
 if (ncmd gt 1) and (1-background) then rm_file,bat_file
 return
endif

;-- the old way
;-- create file to capture output

cmds=command
chk=where(strpos(cmds,'>') gt -1,rcount)
if (rcount gt 0) or (not want_error) then want_out=0b

if want_out then begin
 if datatype(temp_file) ne 'STR' then $
  temp_file=concat_dir(tempdir,'spawn_result.txt_'+get_rid()) else $
   temp_file=trim(temp_file)                                                   
 cmds(0)=cmds(0)+' > '+temp_file
 if n_elements(cmds) gt 1 then cmds(1:*)=cmds(1:*)+' >> '+temp_file
endif

file_append,bat_file,[cmds,'exit'], /new

if keyword_set(test) then begin
 message,'testing...',/cont
 print,cmds
 stop
endif

spawn,bat_file

if not want_out then goto,done

;-- wait until output is ready

rcount=0
repeat begin
 chk=findfile(temp_file)
 have_output=chk(0) ne ''
 rcount=rcount+1
 too_long=rcount gt 100
endrep until (have_output or too_long)

if have_output then result=rd_ascii(temp_file) else begin
 err='spawn did not complete successfully'
endelse

count=n_elements(result)
result_out=n_params() eq 2
if not result_out then print,result

;-- clean up

done:
rm_file,bat_file
if keyword_set(delete) then rm_file,temp_file

return
end
