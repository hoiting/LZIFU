

pro progress,percentin,bigstep=bigstepin,smallstep=smallstepin, $
                 reset=reset,last=last,label=label,noeta=noeta, $
                 frequency=frequency,progstring=pstring, $
                 noprint=noprint,norecurse=norecurse, $
                 minval=minvalin,maxval=maxvalin

;+
;NAME:
;     PROGRESS
;PURPOSE:
;     Prints a progress summary in percent done and time remaining as
;     a process runs.  Call this routine multiple times from the
;     running process while updating the percent done parameter.
;CATEGORY:
;CALLING SEQUENCE:
;     progress,percent
;INPUTS:
;     percent = percent finished (in range 0 to 100, unless minval and
;               maxval are set)
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS
;     /reset = this must be set for the first call to set up variables.
;     /last = the process is done and this is the last call.  Optional
;             for the last call.  Makes sure the printout goes all the
;             way to 100%, does a final carriage return, and resets
;             some variables.
;     label = string to print at the front of the progress line.  Only
;             used on the first call when /reset is set.
;     bigstep = percentage multiple to print the percent done as a
;               number (def = 25).  Only used on the first call when
;               /reset is set.  Integer.
;     smallstep = percentage multiple to print a dot (def = 5).  Only
;                 used on the first call when /reset is set.  Integer.
;     minval = percent value at process start (default = 0.0).  Only
;                 used on the first call when /reset is set.  Integer.
;     maxval = percent value at process end (default = 100.0).  Only
;                 used on the first call when /reset is set.  Integer.
;     /noeta = Do not print the estimated time to completion.  This
;              feature depends on your terminal accepting 8b as a
;              backspace character. If this does not work, the
;              formatting will be messed up.  So, if your formatting
;              is messed up, set this keyword to turn the feature off.
;     frequency = If set, update the estimated time to completion
;                 if at least 'frequency' seconds have passed since
;                 the last update.  The time is always printed when a
;                 dot or number is printed, as well. If set to 2, for
;                 example, update approximately every two seconds, etc. 
;                 If set to 0, update on every call to progress.
;                 The default (not set) is to update the time only
;                 when a dot or number is printed. 
;OUTPUTS:
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;     Assumes that nothing else is printed between calls.  If it is,
;     the formatting will be messed up.  If you change the size of the
;     terminal during the process, the formatting may also be messed
;     up if it might have gone over the length of a line.  The
;     counting is done with integers, so you can't count, for example,
;     from 0. to 1. with dots printed at intervals of 0.1, regardless
;     of how you set minval and maxval.
;PROCEDURE:
;     Call the routine multiple times as progress is made.  It will
;     print numbers and dots to indicate the progress, e.g.
;     Label:  0 .... 25 .... 50 .... 75 .... 100  | Time=00:00:00
;     Also prints an estimated time to completion, HH:MM:SS
;EXAMPLE:
;     progress,0.0,/reset,label='Progress (%)'
;     for i=0,n-1 do begin
;        ; your processing goes here
;        progress,100.*float(i+1.0)/n
;     endfor
;     progress,100.,/last
;     Progress (%):  0 .... 25 .... 50 .... 75 .... 100  | Time=00:00:00
;
;     Or, you can use the minval and maxval keywords to change the
;     range of the counting:
;
;     progress,0.,/reset,label='test',bigstep=128,smallstep=32,maxval=512
;     for i=0,511 do begin
;        wait,0.1
;        progress,i+1
;     endfor
;     progress,512.,/last
;     test:  0 ... 128 ... 256 ... 384 ... 512  | Time=00:00:51
;MODIFICATION HISTORY:
;     T. Metcalf 2005-Jan-06
;     2005-Jan-10 Added frequency keyword.
;     2005-Jan-12 Move time to end of final string so that it does not
;                 move.
;     2005-Jan-13 If /last is set, the time printed is the total elapsed
;                 time.
;     2005-Jan-19 Added minval and maxval keywords.
;     2005-Feb-01 Check for rpercent eq 0 in eta calculation.
;     2005-Feb-11 Remove strcompress around user label.
;-

common progress_private,bigstep,smallstep,lastpercent,starttime,lasttime, $
                        ncharacters,progstring,ttysize,minval,maxval

if n_elements(frequency) GE 1 then freq = float(frequency[0])>0.0 else freq = 0.0

if keyword_set(reset) OR not keyword_set(bigstep) or not keyword_set(smallstep) or $
   n_elements(lastpercent) LE 0 then $
   doreset = 1 else doreset = 0
if n_elements(lastpercent) GT 0 and not keyword_set(doreset) then $
   if lastpercent LT minval then doreset = 1

if keyword_set(doreset)  then begin
   if not keyword_set(bigstepin) then bigstep=25 $
   else bigstep = round(bigstepin)
   if not keyword_set(smallstepin) then smallstep=5 $
   else smallstep = round(smallstepin)
   if n_elements(minvalin) LE 0 then minval = 0.0 else minval = float(minvalin)
   if n_elements(maxvalin) LE 0 then maxval = 100.0 else maxval = float(maxvalin)
   if smallstep GT bigstep then smallstep=bigstep

   if NOT keyword_set(norecurse) then begin ; Get full output string for counting
      progress,100.0,/reset,/last,/noprint,progstring=ps,label=label, $
               /norecurse,/noeta,bigstep=bigstepin,smallstep=smallstepin, $
               minval=minvalin, maxval=maxvalin
      ncharacters = strlen(ps) ; the length of the full progress string
      test = ''
      ; maxch is the longest possible string computed from
      ; ncharacters and the longest time string we're likely need
      maxch =  ncharacters + strlen(' | Time=00000:00:00') 
      ttysize = maxch  ; Maximum required tty width.
      for i=1,maxch-1 do begin 
         ; Figure out how wide the tty is.  There has got to be
         ; a better way to do this!!!
         ; String switches to an array when the tty line would be full.
         test = string('a',test)  ; add one character
         if (size(test))[0] then begin ; scalar string or string array?
            ttysize = i ; if we never get here, the tty is bigger than we need
            break
         endif
      endfor
      ; Better way(?), but works only for some unix flavors,
      ; so do don't want to do this.
      ; The IDL ioctl command could also be used, but it is at least
      ; as system dependent.
      ; spawn,['stty','size'],result,/noshell 
      ; ttysize=splitstr(result,' ')
      ; ttysize = ttysize[n_elements(ttysize)-1]
   endif

   lastpercent = round(minval)-1.0   ; must be exactly round(minval)-1 at the start
   starttime = systime(1)
   lasttime = starttime
   progstring = ''
   if keyword_set(label) then begin
      ;s = strcompress(label+': ')
      s = label+': '
      if NOT keyword_set(noprint) then print,s,format='(a,$)'
      progstring = progstring + s
   endif
endif   ; end of initialization

percent = (float(percentin) < maxval) > minval

if percent LT lastpercent then return 

if keyword_set(last) then npercent = round(maxval) else npercent = round(percent)
nlastpercent = round(lastpercent)

; Print whatever dots and numbers we need to

nprinted = 0
if npercent GT nlastpercent then begin
   for ipct=nlastpercent+1,npercent do begin
      if ipct MOD bigstep EQ 0 then begin
         s = ' '+strcompress(string(ipct),/remove_all)+' '
         if NOT keyword_set(noprint) then print,s,format='(a,$)' 
         progstring = progstring + s
         nprinted = nprinted + strlen(s)
      endif else if ipct MOD smallstep EQ 0 then begin
         s = '.'
         if NOT keyword_set(noprint) then print,s,format='(a,$)'
         progstring = progstring + s
         nprinted = nprinted + strlen(s)
      endif
   endfor
endif

; Print the estimated time left

if (keyword_set(nprinted) OR $
    n_elements(frequency) GE 1 OR $
    keyword_set(last)) AND $
   NOT keyword_set(doreset) AND $ ; no time has passed, can't get eta
   NOT keyword_set(noeta) then begin
   ; Compute & print estimated time to completion
   thistime = systime(1)
   if (thistime - lasttime) GE freq OR $
      keyword_set(nprinted) OR $
      keyword_set(last) then begin
      rpercent = float(percent-minval)/float(maxval-minval)
      if keyword_set(last) OR rpercent EQ 0.0 then $
         eta = (thistime-starttime) $ ; /last -> total elapsed time
      else $
         eta = (1.0-rpercent)*(thistime-starttime)/rpercent
      h = fix(eta / 3600.0)
      eta = eta - h*3600.0
      m = fix(eta/60.0)
      eta = eta - m*60.0
      s = fix(eta)
      if h LT 10 then h = '0'+string(h) else h = string(h)
      if m LT 10 then m = '0'+string(m) else m = string(m)
      if s LT 10 then s = '0'+string(s) else s = string(s)
      eta = ' | Time='+strcompress(h+':'+m+':'+s,/remove_all)
      ; Get number of spaces needed to push time string out to
      ; where the end of the final string will be so it will
      ; not appear to move.
      if keyword_set(ncharacters) then $
         nspace = ncharacters - strlen(progstring) $
      else nspace=0
      if strlen(progstring)+nspace+strlen(eta) GE ttysize then begin
         ; We will eventually go over the end of the line so 
         ; reduce number of spaces.
         nspace = (ttysize-strlen(progstring)-strlen(eta))
      endif
      if nspace LT 0 then begin
         ; We will go over the end of the line with this call,
         ; so we need to erase the last time and move to a new 
         ; line.
         if NOT keyword_set(noprint) then begin
            ; erase the last time and write
            ; enough to get to the next line
            nerase = strlen(eta)+nspace
            if nerase GT 0 then $
              print,string(replicate(32b,nerase)),format='(a,$)'
            progstring = ''  ; starting a new line
         endif
      endif
      if nspace GT 0 then spacestr = string(replicate(32b,nspace)) $
      else spacestr = ''
      ; 8b is a backspace so the eta will be overwritten on next call
      eta = spacestr + eta + $
            string(replicate(8b,strlen(eta)+strlen(spacestr)))
      if NOT keyword_set(noprint) then print,eta,format='(a,$)'
      lasttime = thistime  ; the last time the ETA was printed
   endif
endif

if keyword_set(last) then begin
   if NOT keyword_set(noprint) then print
   lastpercent = minval-1.0  ; force a reset on the next call
endif

pstring = progstring
lastpercent = percent

end
