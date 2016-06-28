;+
; Project     : SOHO - CDS
;
; Name        : EXIST_JOB
;
; Purpose     : determine if a job exists
;
; Category    : Utility
;;
; Syntax      : IDL> exists=exist_job(job_name)
;
; Inputs      : JOB_NAME = name of job to search for
;
; Outputs     : EXISTS = 1/0
;
;
; Keywords    : /CASE: job searching is case sensitive
;               /EXACT: job name must be exact
;               /VERBOSE: output results
;
; Restrictions: UNIX only
;
; History     : Version 1,  5-Feb-2000,  D.M. Zarro (SM&A/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function exist_job,job,_extra=extra,jobs=jobs,verbose=verbose

exists=0b
if strupcase(os_family()) ne 'UNIX' then return,0b
if datatype(job) ne 'STR' then return,0b
if trim(job) eq '' then return,0b

espawn,'ps -ae',out,/noshell
jobs=grep(job,out,_extra=extra)

if jobs(0) eq '' then return,0b

if keyword_set(verbose) then begin
 for i=0,n_elements(jobs)-1 do begin
  if i eq 0 then message,'following job(s) found',/cont 
  print,jobs(i)
 endfor
endif  

return,1b  & end
