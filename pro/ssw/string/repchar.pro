;+
; Project     : SOHO - CDS     
;                   
; Name        : REPCHAR()
;               
; Purpose     : Replaces a character within a string by another.
;               
; Explanation : All occurrences of the specified character within a string 
;               are replaced by the specified character (a space by default).
;               
; Use         : IDL> new = repchar(old,out_char [,in_char])
;    
; Inputs      : old      - string in which to replace character.
;               out_char - character to be replaced
;
; Opt. Inputs : in_char  - character to be inserted in place of out_char.
;                          (Default is a space)
;               
; Outputs     : Function returns suitably adapted string.
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, string
;               
; Prev. Hist. : R. Sterner.  Oct, 1986.
;
; Written     : CDS version by C D Pike, RAL, 24-Jun-94
;               
; Modified    : 
;
; Version     : Version 1, 24-Jun-94
;-            

function repchar, old, c1, c2

;
;  check parameters
;
if (n_params() lt 2) then begin
  print,' Replace all occurrences of one character with another '+$
    'in a text string.'
  print,' new = repchar(old, c1, [c2])'
  print,'   old = original text string.         '
  print,'   c1 = character to replace.          '
  print,'   c2 = character to replace it with.  '
  print,'        default is space.'
  print,'   new = edited string.                '
  return, ''
endif

;
; convert string and character to a byte (array).
;
b = byte(old)       
cb1 = byte(c1)   

;
; find occurrences of char 1.
;
w = where( b eq cb1(0), nfound)

;     
; if none, return old string.
;
if nfound eq 0 then return, old 

;
;  was replacement specified? If not default is a space
;    
if n_params() lt 3 then c2 = ' '   

;
; convert char 2 to byte.
;
cb2 = byte(c2)     
 
;
; replace char 1 by char 2. 
;
b(w) = cb2(0)       
 
;
; return new string.
;
return, string(b)        
 
end  
