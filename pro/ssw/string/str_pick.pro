;+
; Project     : SOHO - CDS     
;                   
; Name        : STR_PICK()
;               
; Purpose     : Extract a substring bounded by given characters.
;               
; Explanation : Given an input string and two bounding characters (or
;               substrings), the function returns the extracted substring.  
;               Default delimiters are first and second spaces.  
;               If only one is given then substring returned
;               is from there to the end of the string. If both characters
;               are specified and one of them does not exist then a null
;               string is returned.
;               
; Use         : IDL> text = str_pick(in_text, char1, char2)
;
;               eg print, str_pick('this is <crazy>.', '<','>')
;
;                        --->  crazy
;    
; Inputs      : in_text  -  string from which to extract
;               
;               
; Opt. Inputs : char1 - left boundary character (or substring)
;               char2 - right boundary character (or substring)
;               
; Outputs     : Function returns extracted substring
;               
; Opt. Outputs: None
;               
; Keywords    : INC_FIRST - include first substring in output
;               INC_LAST  - include last substring in output
;
; Calls       : Standard str_ routines
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
; Written     : C D Pike, RAL, 27-Mar-95
;               
; Modified    : Allow boundaries to be substrings.  CDP, 10-Apr-95
;               Allow array inputs and add keywords.  CDP, 24-Apr-97
;               Long the loop counter.  CDP, 14-Jul-97
;
; Version     : Version 4, 14-Jul-97
;-            

function str_pick, text, char1, char2, inc_first=inc_first, inc_last=inc_last

;
;  parameter checks
;
if n_params() eq 0 then begin
   print,'Use:  text = str_pick(string, char_left, char_right)
   return,''
endif

if n_params() eq 1 then begin
   char1 = ' ' & char2 = ' '
endif

;
;  allow array input/output
;
outs = strarr(n_elements(text))
p1 = -1
p2 = -1
for i=0L,n_elements(text)-1 do begin

;
;  easy if only left hand character is given
;
   case 1 of
      n_params() eq 2: begin
         p1 = strpos(text(i),char1)
         if p1 ge 0 then begin
            outs(i) = strmid(text(i),p1+strlen(char1),strlen(text(i))) 
         endif else begin
            outs(i) = ''
         endelse
      end

;
;  if both search characters are the same then pick the substring between
;  the first and second occurrence
;
   char1 eq char2: begin
      p1 = strpos(text(i),char1)
      if p1 eq -1 then begin
         outs(i) = ''
      endif else begin
         p2 = strpos(text(i),char2,p1+1)
         if p2 eq -1 then p2 = strlen(text(i))
         outs(i) = strmid(text(i),p1+strlen(char1),(p2-p1-strlen(char1)))
      endelse
   end

;
;  two different characters specified so search for them
;
   else: begin
      p1 = strpos(text(i),char1)
      if p1 eq -1 then begin 
         outs(i) = ''
      endif else begin
         p2 = strpos(text(i),char2,p1+1)
         if p2 eq -1 then begin
            outs(i) = ''
         endif else begin
            outs(i) = strmid(text(i),p1+strlen(char1),p2-p1-strlen(char1))
         endelse
      endelse
   end
   endcase
endfor

;
;  check wrappers
;
if keyword_set(inc_first) then outs = char1+outs
if keyword_set(inc_last)  then outs = outs+char2

if n_elements(outs) eq 1 then return,outs(0) else return,outs

end
