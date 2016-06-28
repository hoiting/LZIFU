PRO YESNOX,STR,IN,default
;
;+
;NAME:
;	yesnox
;PURPOSE:
;	Ask a yes/no question and check the answer
;	for validity (calls "yesno")
;CALLING SEQUENCE
;	yesnox, 'Do you wish to extract the data', in, 'Yes'
;INPUT:
;	str	- The question string
;OUTPUT:
;	in	- Returns a 0 for no, a 1 for yes
;OPTIONAL INPUT:
;	default	- Select the default answer.  If a 
;		  <CR> is chosen, select the default answer
;		  If not present, the default answer is "NO"
;HISTORY:
;	Written 1988 by M.Morrison
;	27-Oct-96 [LWA], added CALLING SEQUENCE to header.
;-
;
if (n_params(0) lt 3) then default='N'
defstr = strtrim( strupcase(default),2 )
def='  [Default: '  +  defstr + ' ] '
IN=' '				
PRINT, STR, def, '? ', format = '(3a,$)'
READ,"",IN			
if (in eq '') then in = defstr
YESNO,IN
;
RETURN
END
