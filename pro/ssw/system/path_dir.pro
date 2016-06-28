;+
; Project     : SOHO - CDS     
;                   
; Name        : PATH_DIR()
;               
; Purpose     : Return directories in the path containing the input string
;               
; Explanation : Searches the IDL path and returns an array of any directory
;               names that include the input string.  All directories are
;               returned if no input string is given. 
;               
; Use         : IDL> print, path_dir(string)
;               IDL> pd = path_dir('util', /show)
;    
; Inputs      : None
;               
; Opt. Inputs : string - search string
;               
; Outputs     : Function returns a string array.
;               
; Opt. Outputs: None
;               
; Keywords    : SHOW  -  print output to screen
;
; Calls       : GREP()
;               BREAK_PATH()
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
; Written     : C D Pike, RAL, 4-Jan-95
;               
; Modified    : 
;
; Version     : Version 1, 4-Jan-95
;-            

function path_dir, string, show=show


;
;  get full path list
;
ans = break_path(!path)

;
;  check number of arguments
;
if n_params() eq 0 then begin
   if keyword_set(show) then print_str,ans
   return, ans 
endif

;
; otherwise look for specific string
;
ans = grep(string,ans)
if keyword_set(show) then print_str,ans
return, ans
end


