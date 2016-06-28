;+
; Project     : SOHO - CDS
;
; Name        : KILL_JOB
;
; Purpose     : Kill a UNIX job
;
; Category    : Utility
;
; Explanation : e.g. kill_job,'telnet' to kill all jobs with the containing
;               the string 'telnet'
;
; Syntax      : IDL> kill_job,job_name
;
; Inputs      : JOB_NAME = name of job to kill
;
; Keywords    : /CASE: job searching is case sensitive
;               /EXACT: job name must be exact
;               /VERBOSE: send messages
;
; Restrictions: UNIX only
;
; Side effects: None
;
; History     : Version 1,  5-Dec-1997,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


pro kill_job,job,_extra=extra,verbose=verbose

if strupcase(os_family()) ne 'UNIX' then return
verbose=keyword_set(verbose)

if not exist_job(job,_extra=extra,jobs=jobs) then begin
 if verbose then message,job+ ' not found',/cont
 return
endif

njobs=n_elements(jobs)
for i=0,njobs-1 do begin
 proc=str2arr(trim(jobs(i)),delim=' ')
 job_id=proc(0)
 if job_id ne '' then begin
  state='kill -9 '+job_id
  espawn,state,out,/noshell
  if verbose and trim(out(0)) ne '' then message,out(0),/cont
 endif
endfor

return & end
