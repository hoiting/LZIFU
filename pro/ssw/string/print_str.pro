;+
; Project     : SOHO - CDS     
;                   
; Name        : PRINT_STR
;               
; Purpose     : Divide and print a string.  Optionally write ascii file.
;               
; Explanation : Divides a string into an array (using supplied delimiter)
;               and prints one element per line.  Most obvious use is to 
;               print !path. If input is already a string vector then just
;               print the elements one per line.
;               
; Use         : IDL> print_str, string [, [start,stop], delim=delim, 
;                                         hard=hard, quiet=quiet
;                                         file=file, keep=keep]
;    
; Inputs      : string - the string to be split and printed
;               
; Opt. Inputs : [start,stop] - array giving start and stop items to list
;               
; Outputs     : Results are printed to screen and/or written to file
;               
; Opt. Outputs: None
;               
; Keywords    : DELIM  - a substring to delimit the string items, default is ':'
;               HARD   - produce a hard copy.
;               QUIET  - no output to screen.
;               FILE   - specify output file, if null on input then name of
;                       file created is returned in this - must use /keep if
;                       this is null on entry. 
;               KEEP   - do not delete disk file.
;               NUMBER - give an index number on the listing
;
; Calls       : STR2ARR
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, string
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 20-July-94
;               
; Modified    : Add print delay as fudge.  CDP, 9-Dec-94
;               Handle vector input.  CDP, 23-Dec-94
;
;               Added hardcopy keyword.  CDP, 20-Feb-95
;               Added QUIET, FILE and KEEP keywords.  CDP, 9-Jun-95
;               Added NUMBER keyword.  CDP, 29-Jun-95
;               Added switch to landscape printing if needed.  CDP, 19-Jul-95
;               Added message if output KEEPed.  CDP, 27-Jul-95
;               Added [start,stop] parameter.    CDP, 26-Feb-96
;
; Version     : Version 8, 26-Feb-96
;-            

pro print_str, str, limits, delim=delim, hardcopy=hardcopy, quiet=quiet, $
                    keep=keep, file=file, number=number

;
;  help user
;
if n_params() eq 0 then begin
   print,'IDL> print_str, string [, limits, delim=delim, hard=hard, quiet=quiet
   print,'                           file=file, keep=keep]
   return
endif

if datatype(str,1) ne 'String' then begin
   print,'Input must be a string variable'
   return
endif


;
;  define delimiter
;
if not keyword_set(delim) then delim = ':'


;
;  break it up if needed
;
if (size(str))(0) eq 0 then x = str2arr(str,delim=delim) else x=str


;
;  to terminal?
;
if keyword_set(quiet) then to_screen = 0 else to_screen = 1
if to_screen then openw, screen, filepath(/terminal), /more, /get_lun
 
;
;  create filename (in home directory) for hardcopy or use user-supplied
;
vms=(!version.os eq 'VMS')
if not keyword_set(file) then begin
   hfile = 'print_str_temp'
   if vms then home='sys$login' else home=getenv('HOME')
   hfile=concat_dir(home,hfile)
endif else begin
   hfile = file
endelse
openw,lun,hfile,/get_lun

;
;  were limits given
;
if n_params() eq 2 then begin
   if n_elements(limits) eq 2 then begin
      lim1 = limits(0)
      lim2 = last_item(limits)
   endif else begin
      lim1 = limits(0)
      lim2 = n_elements(x)-1
   endelse
endif else begin
   lim1 = 0
   lim2 = n_elements(x)-1
endelse
;
; print it, include wait to fudge synch problem on alphas/idl3.5?
;

land = 0
for i=lim1,lim2 do begin
   if keyword_set(number) then begin
      num = strcompress(string(i,')',form='(i5,a)'),/rem)+' '
   endif else begin
      num = ''
   endelse
   if i gt 50 then wait,0.02
   if to_screen then printf,screen,num+x(i)
   if strlen(num+x(i)) gt 78 then land = 1
   printf,lun,num+x(i)
endfor


;
;  release units
;
free_lun,lun
if to_screen then free_lun,screen

;
;  print hard copy
;
if keyword_set(hardcopy) then begin
   if vms then begin
      com = 'print '+hfile 
   endif else begin
      if land then com = 'lpr -Olandscape -w132 '+hfile else com = 'lpr '+hfile
   endelse
   spawn,com
   bell
   print,'Hard copy sent to printer'
endif

;
;  keep it?
;
if (not keyword_set(keep)) and (not keyword_set(file)) then begin
   status = delete_file(hfile,/noconfirm)
endif else begin
   print,'Output saved in file: ',hfile
endelse

;
;  return file name
;
if not keyword_set(file) then file = hfile
return
end
