pro killold, testing=testing, noconfirm=noconfirm, mail=mail, all=all, $
	user=user, hours=hours, root=root, $
        pattern=pattern, exclude=exclude, debug=debug
;+
;   Name: killold
;
;   Purpose: kill old jobs (PIDs)
;
;   Keyword Parameters:
;      noconfirm - switch, if set, do not prompt before each kill
;      testing   - switch, if set, just show what WOULD happen (no spawn)      
;      hours     - age to kill (default is 24-48 hours)
;      all       - kill all jobs (older than 10 minutes - dont kill THIS JOB)
;      pattern   - if supplied, only consider jobs which include this pattern
;      exclude   - if supplied, only consider jobs which do NOT include this
;                     this pattern
;
;   Calling Sequence:
;      killold [,/noconfirm, /testing]
;
;   Calling Example:
;      killold,hours=8,/mail        ; kill jobs older than 8 hours and send mail
;
;   Usage:
;      run as a cron job with /noconfirm switch for automated cleanup 
;
;   Restrictions:
;      Only cleans up jobs owned by account running it 
;      (but thats a good and possible thing)
;      Unix alpha-osf only (or others with identical "ps auxw" format)
;
;   History:
;      21-Dec-1995 (S.L.Freeland)
;       5-jan-1996 (S.L.Freeland) - add MAIL keyword
;      10-jan-1996 (S.L.Freeland) - use prstr instead of more
;      11-jan-1996 (S.L.Freeland) - only mail if jobs killed 
;       4-feb-1996 (S.L.Freeland) - add HOURS keyword and logic
;      13-apr-1997 (S.L.Freeland) - message + return if non-UNIX -> SSW system
;                                      root protect.
;      15-jul-1997 (S.L.Freeland) - add PATTERN and EXCLUDE keyword & function
;      16-jul-1997 (S.L.Freeland) - permit vectors for PATTERN and EXCLUDE 
;-

if data_chk(pattern,/string,/scalar) then pattern=str2arr(pattern)
if data_chk(exclude,/string,/scalar) then exclude=str2arr(exclude) 

debug=keyword_set(debug)
;
if not (os_family() eq 'unix') then begin
   message,/info,"Sorry, UNIX only "   
   return
endif

if n_elements(user) eq 0 then user=get_user()

if user eq 'root' then begin
   message,/info,"User = ROOT..."
   if not keyword_set(root) then begin
      message,/info,"If you really want to delete old root jobs, use /ROOT switch"
      message,/info,"(are you really sure you want to do that...)"   
      return
   endif
endif

; ------------------------------------------------
; Some assumptions about 'ps' command - works for OSF-alpha style at least
spawn,'ps auxw | grep ' + user,psout
; ------------------------------------------------
ssok=intarr(n_elements(psout)) + ([1,0])(keyword_set(pattern))     ; flag to include

for i=0,n_elements(pattern)-1 do begin
  ssok=ssok or (strpos(strupcase(psout),strupcase(pattern(i))) ne -1)
endfor  

for i=0,n_elements(exclude)-1 do begin
  ssok=ssok and (strpos(strupcase(psout),strupcase(exclude(i))) eq -1)
endfor  

ss=where(ssok,mcount)
if debug then stop,'post ss'

if mcount gt 0 then psout=psout(ss) else psout=''   



if psout(0) eq '' then begin
   message,/info,"No jobs match input paramters, returning..."
   return
endif  

; ** note - I will absorb the "software" messages... (Sam Freeland)
;muser=([user,"freeland@isass0.solar.isas.ac.jp"])(user eq "software")
muser=user
pscol=str2cols(psout)
pids=strtrim(reform(pscol(1,*)),2)
dates=strupcase(strtrim(strmid(psout,49,11),2))

month=(str2arr(gt_day(!stime,/string),'-'))(1)
lastmonth=(str2arr(gt_day(timegrid(!stime,week=-4,/string),/string),'-'))(1)

old=where(strpos(dates,month) ne -1 or strpos(dates,lastmonth) ne -1,ocnt)

all=keyword_set(all) or (n_elements(hours) ne  0)		; check times

case 1 of
  keyword_set(all):hours=.1
  n_elements(hours) eq 0: hours=0
  else:
endcase  

if all then begin
   ok=where(strlen(dates) eq 8 and strpos(dates,':') ne -1,okcnt)
   if okcnt gt 0 then begin
      dates(ok)=fmt_tim( gt_day(!stime,/string) + ' ' + dates(ok))
      delta=int2secarr(anytim2ints(dates(ok)))
      oldd=where(abs(delta) gt hours*3600. , ocnt2)
      case 1 of 
         ocnt gt 0 and ocnt2 gt 0: old=[old, ok(oldd)]
	 ocnt2 gt 0: old=ok(oldd)
         else:
      endcase
      ocnt=ocnt+ocnt2
   endif
endif

resp=''
noconf=keyword_set(noconfirm)
confirm=1-keyword_set(noconfirm)

resp=(['',"Y"])(noconf)
testing=keyword_set(testing)

mess="Number of old jobs: " + strtrim(ocnt,2)
message,/info,mess

pr_status,txt

mail_mess=[txt,'',strjustify(mess,/box)]

mailit=keyword_set(mail) and ocnt gt 0  

for i=0,ocnt-1 do begin
   this_mess=strjustify(psout(old(i)),/box)
   prstr,this_mess
   if confirm then $
      read,"*** >>> kill this PID? ",resp
   cmd="kill -9 " + pids(old(i))
   killit=strupcase(strmid(resp,0,1)) eq 'Y' 
   case 1 of 
      testing: kmess="Testing: " + cmd
      killit: begin
         kmess="Spawning: " + cmd
         spawn,cmd
      endcase
      else: kmess="No action..."
   endcase
   message,/info,kmess
   mail_mess=[mail_mess,'',this_mess,kmess]
endfor

if mailit then mail,mail_mess,user=muser, $
   /no_defsub, subj="KILLOLD - #PIDs killed: " + strtrim(ocnt,2)

return
end
