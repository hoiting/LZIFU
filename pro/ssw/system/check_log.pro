pro check_log, logfile, user=user, job=job, status=status, nomail=nomail, $
	window=window, mailnorm=mailnorm, errstring=errstring, loud=loud, $
	quiet=quiet, unixerr=unixerr,  ftperr=ftperr, remove=remove
;+
;
;   Name: check_log
;
;   Purpose: check idl batch logfile for abnormal termination
;
;   Calling Sequence:
;      check_log, logfile [user=user]
;
;   Input Paramters:
;      logfile - idl batch log to check
;
;   Keyword Paramters:
;      job    - batch job name (optional)
;      user   - user list for e-mail
;      window - lines preceding error to include in output (def=5, -1 = all)
;      nomail   - switch, if set, inhibit mail on ABNORMAL exit (def=mail)
;      mailnorm - switch, if set, mail on NORMAL exit (def=nomail)
;      unixerr - switch, if set, limit checks to UNIX errors
;      ftperr  - switch, if set, limit checks to ftp errors
;
;   History:
;       1-Mar-1994 (SLF)
;       2-Mar-1994 (SLF) - add <no job file> and <compile time error> checks
;      15-Apr-1994 (SLF) - inhibit message if /quiet is set
;      21-Apr-1994 (SLF) - add UNIXERR/FTPERR keywords and action, call sear
;			   call search.pro, mail SUBJ: info, other mods...
;       3-May-1994 (SLF) - call search.pro with /case_ignore set
;      10-May-1994 (SLF) - allow inhibition of unix and ftp checks via log/env
;      29-Sep-1994 (SLF) - add REMOVE keyword (succesfully completed jobs&logs)
;       4-Sep-1994 (SLF) - do a RENAME instead of a delete (seperate option after testing
;-
;

mailnorm=keyword_set(mailnorm)
nomail=keyword_set(nomail)

; Establish error conditions
idlcond=1				; 
; new conditions may be added (pair Search String/Error Type)
default=0
case 1 of
   keyword_set(unixerr): begin
        errtype='(UNIX)'
        errcond=						[	$
;	["SEARCH STRING",		"ERROR MESSAGE"			$
	["Stale NFS file handle",	"NFS EXPORT PROBLEM"]	]
   endcase
   keyword_set(ftperr):  begin
      errtype='(FTP)'
        errcond=						[	$
;	["SEARCH STRING",			"ERROR MESSAGE"		$
	["ftp: connect: Connection timed out",	"FTP CONNECT PROBLEM"] ]
   endcase
   else: begin						
        default=1
        errtype='(ABNORMAL EXIT)'
        errcond=						[	$

;	["SEARCH STRING",		"ERROR MESSAGE"			$
        ["% Syntax Error",      	"Syntax Error"],		$
        ["% Execution halted",		"Run Time Error"],		$
	["% Can't open file for input:","No IDL Job File!"],		$
	["Compilation errors in module","Compile Time Error"]	]
   endcase
endcase
ncond=n_elements(errcond(0,*))

if n_elements(errstring) then begin
   errcond=reform(string(errstring))
   case 1 of 
      data_chk(errcond,/scaler,/string): errcond=[errcond,'User Specified']
      else:
   endcase
endif

if not keyword_set(window) then window=5
loud=keyword_set(loud)
quiet=keyword_set(quiet)	; FYI, quiet is not same as 1-loud
;
if n_elements(logfile) eq 0 then begin
   logfile=concat_dir(getenv('HOME'),'IDL_BATCH_RUN')
   message,/info,'No logfile supplied, using: ' + logfile
endif

if not file_exist(logfile) then begin
   message,/info,'No log file exists, returning...
   return
endif
;
lines=rd_tfile(logfile,/compress)
nlines=n_elements(lines)

ecount=0
if lines(0) eq '' then begin
   ecount=1
   errmess='Logfile: ' + logfile + ' is empty
   type='Empty Log File'
endif else begin
   cond=-1
   while (cond lt ncond-1) and (ecount eq 0) do begin
      cond=cond+1
      if loud then message,/info,'Checking for: ' + errcond(1,cond) 
      chkerr=wc_where(lines,'*' + errcond(0,cond) + '*', /case_ignore,ecount)
   endwhile
   if ecount gt 0 then begin
      type=errcond(1,cond)
      if loud then message,/info,'Condition found: ' + type
      if window lt 0 then errmess=lines else $
	 errmess=lines(chkerr(0)-window>0:chkerr(0)+window<nlines-1)
   endif
endelse   

status=ecount eq 0

break_file,logfile,log,paths,file,ext,vers
jobname=file 
if keyword_set(job) then jobname=string(job)

descript= 'ERROR ' + errtype + ', ' + strupcase(jobname) +  ', [' +  logfile + ']'

if not status then begin
   search,logfile,errcond(0,cond),outarr=outarr,window=window,/last,/case_ignore
   tbeep
   mess= descript
   if not quiet then message,/info,mess
   errmess=[mess,'',type,'',$
	   'Last Flagged Occurence in Logfile: ' + logfile + ' ....', outarr]
   subj=errcond(1,cond) + ' [' + strupcase(jobname) + ']'
   if not nomail then mail, errmess, user=user, subj=subj
endif else begin
   if default then begin
       if get_logenv('IDL_BATCH_NOUNIX') eq '' then begin
          check_log, logfile, user=user, job=job, status=s1, nomail=nomail, $
	      window=window, errstring=errstring, loud=loud, $
	      quiet=quiet,/unix
       endif else s1 = 1
       if get_logenv('IDL_BATCH_NOFTP') eq '' then begin
          check_log, logfile, user=user, job=job, status=s2, nomail=nomail, $
	      window=window, errstring=errstring, loud=loud, $
	      quiet=quiet,/ftperr
       endif else s2 = 1
       status= s1 and s2
   endif
   
   if status then begin			; normal completion
      if mailnorm then begin
         subj="IDL Normal Exit"
         mess='Normal exit, ' + descript 
         mail, mess, user=user, subj=subj
      end
      if keyword_set(remove)  then begin
         message,/info,"Renaming succesfully completed job & log.."
         rename,logfile,logfile + '.old',filt=logfile
         if (keyword_set(job)) then profile=(path_lib(job))(0)
         if profile ne '' then $
            rename, profile, profile + '.old' , filt=profile
      endif      
   endif
endelse

return
end
