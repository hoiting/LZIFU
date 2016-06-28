;+
; Project     : SOHO - CDS     
;                   
; Name        : YES_NO
;               
; Purpose     : Prompts and checks for a user answer of either YES or NO
;               
; Explanation : Prompts user for a yes/no answer and will not give up until
;               it gets one.
;               
; Use         : yes_no, query, answer [,default,check=check]
;    
; Inputs      : query    - The question string
;               
; Opt. Inputs : default  - The default answer.  If a <CR> response is given,  
;                          select the default answer.  If this is not present,
;                          the default answer is "NO"

;               
; Outputs     : answer - Returns a 0 for no, a 1 for yes
;               
; Opt. Outputs: None
;               
; Keywords    : check  -   Double check the answer given for super-secure
;                          applications.
;
; Calls       : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, user
;               
; Prev. Hist. : Based on Yohkoh routine by M Morrison
;
; Written     : CDS version by C D Pike, RAL, 12-May-93
;               
; Modified    : 
;
; Version     : Version 1, 12-May-93
;-            

pro yes_no,query,answer,default,check=check

;
;  if no default given, assume "NO"
;
if (n_params(0) lt 3) then default='N'

;
; tidy default string
;
defstr = strtrim( strupcase(default),2 )
def=' [Default: '  +  defstr + '] '

;
;  set up outputs
;
answer = 0 & check_answer = 0

;
;  loop over the whole thing until answer and its check are satisfactory
;

while not check_answer do begin
;
; get first response
;
   in = ' '                            
   print, query, def, format = '(2a,$)'
   read,in
;
;  if null response then setup default
;       
   if (in eq '') then in = defstr

;
;  pick off first letter
;
   letter = strupcase(strmid(in,0,1))
;
; .. and see if valid
;
   while letter ne 'Y' and letter ne 'N' do begin
      bell,1
      print,'Not a valid response, enter y(es) or n(o).'
      print, query, def, format = '(2a,$)'
      read,in
      if (in eq '') then in = defstr
      letter = strupcase(strmid(in,0,1))
   endwhile
;
;  integer arithmetic to give numerical answer
;
   answer = byte(letter)/80 & answer = answer(0)              

;
;  if a secure answer was requested then double check
;
   check_answer = 0
   if keyword_set(check) then begin
      in_check = ' '                            
      bell,3
      print, 'Response was "',letter,'".  Are you sure? ', format = '(3a,$)'
      read,in_check
      letter = strupcase(strmid(in_check,0,1))
      while letter ne 'Y' and letter ne 'N' do begin
         bell,1
         print,'Not a valid response, enter y(es) or n(o).'
         if (in_check eq '') then in = defstr
         print, 'Response was "',letter,'".  Are you sure? ', format = '(3a,$)'
         read,in_check
         letter = strupcase(strmid(in_check,0,1))
      endwhile
      check_answer = byte(letter(0))/80  & check_answer = check_answer(0)       
   endif else check_answer = 1
endwhile    

end
