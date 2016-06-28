pro set_xcolors
;+
;   Name: set_xcolors 
;
;   Purpose: part of idl setup - avoid order dependent X call effects 
;
;   History: slf, 3-Apr-1992
;	     slf, 9-Aug-1992 - verify DISPLAY is defined 
;            slf,  1-nov-96  - 24 bit support check SSW_X_DEPTH,X_COLORS,X_RETAIN
;                              use device,decompose=0 
;            slf,  7-nov-96  - no action if remote DISPLAY 
;	     MDM, 11-Nov-96  - Removed 7-Nov modification
;			     - Moved pseudo code to before window call
;			     - Various other changes
;            DMZ, 24-Jan-97  - added check for when called as UNIX
;                              CRON job, in which case setting X colors
;                              produces errors
;	     MDM,  1-May-97  - Modified to print warning statement if
;			       using 8 bit pseudo color
;			     - Modified to set pseudo flag if ncolors is set
;			     - Changed spawn,'tty' to be /noshell which
;				sped up the execution considerably.
;            Zarro, 12-Jan-02- added ALLOW_WINDOWS to catch device open
;                              errors
;-
; avoid execution order dependent window/widget behavior

if !d.name ne 'X' then return           ; early exit if not X windows
if get_logenv('ssw_nox') ne '' then return ; likewise if NOX set
on_error,2
version= strlowcase(!version.os) 
if not allow_windows() then return

display=getenv('DISPLAY')               ; check DISPLAY environment/log

; ---------- check for environmental override ----------
depth  =     get_logenv('SSW_X_DEPTH')
retain = fix(get_logenv('SSW_X_RETAIN'))
colors = fix(get_logenv('SSW_X_COLORS')) > fix(getenv('ys_ncolors'))
pseudo = fix(get_logenv('SSW_X_PSEUDO')) or keyword_set(colors)		;MDM added "or colors" 1-May-97
;--------------------------------------------------------

eight_bit = (depth eq '8') or keyword_set(pseudo)  ;MDM added "or pseudo"  11-Nov-96
localx=strlen(display) le 4  and display ne '' ; '', :0, or .0:0 assumed local 

;;;if not localx then return                    ; dont bother if remote

;if depth eq '' and version ne 'vms' then begin
;   spawn,'xdpyinfo',xinfo,/noshell                
;   depth=where(strpos(xinfo,'depths') ne -1,dcnt)  
;   if dcnt gt 0 then begin
;     depths=strtrim(str2arr(xinfo(depth(0)),' '),2)
;     eight_bit=depths(n_elements(depths)-1) eq '8'
;   endif     
;endif  
;  
if (eight_bit) then case 1 of  
      (colors gt 0): 				; environmental used
      (version eq 'irix')  : colors=235
      (version eq 'ultrix'): colors=240
      (version eq 'sunos') : colors=242
      else: 				        ; standard default
endcase

if keyword_set(pseudo) then device,pseudo=8 $
	  		else device,decompose=0  ; permit 24 to look like 8
if keyword_set(pseudo) then begin
    print, '------------ SET_XCOLORS Warning ---------------'
    print, 'Your options have selected to use 8 bit colors'
    print, 'Check the following environment variables if it should be 24 bit'
    print, '        SSW_X_COLORS'
    print, '        SSW_X_PSEUDO'
    print, '        ys_ncolors'
end

if retain gt 0 then device,retain=retain

case 1 of
   colors gt 0: begin
      window,/free,xs=2,ys=2,/pix,colors=colors
      wdelete 
   endcase
   not eight_bit: begin
      window,/free,xs=2,ys=2,/pix
      wdelete
   endcase
   else:
endcase

return
end
