function strcapitalize, strarr, except=except, _extra=_extra
;
;+
;   Name: strcapitalize
;
;   Purpose: capatilize first letters in Names and Titles
;
;   Input Parameters:
;      strarr - string array to capitalize
;   
;   Keyword Parameters:
;      except     - (switch) - if set, dont capitalize 'a', 'the'
;      <ANYTHING> - input - other words NOT to capitalize (any other keyword)
;
;   Calling Sequence:
;      cap=strcapitalize(strarr [,/except ,/ANYTHING])
;
;   Calling Examples:
;      cap=strcapitalize(strarr ,/is)	; dont capitlize a, the, or "is"
;
;   History: 
;      5-jul-1995 (SLF) - prettying up html and other documents...
;-
if not data_chk(strarr,/string) then begin
   message,/info,"No input array..."
   message,/info,"Calling Sequence> cap=strcapitalize(strarr [,/except])"
   return,''
endif

nocapital=keyword_set(except) or keyword_set(_extra)
nocap=['a','the']
if keyword_set(_extra) then nocap=[nocap,tag_names(_extra)]


outarr=strlowcase(' ' + strcompress(strtrim(strarr,2)))	; force leading blank
bout=byte(outarr)					; to simplify algorithm

special=[' ','-']					; new words trigger

; for each special delimter (usually, just a bank), replace with strupcase...
for i=0,n_elements(special)-1 do begin
   spec=where(bout eq (byte(special(i)))(0),scnt )	; find blanks/special
   if scnt gt 0 then bout(spec+1)=byte(strupcase(string(bout(spec+1))))
endfor

outarr=strtrim(bout,2)

; now 'de-capitalize' exceptions, if any

if nocapital then begin
   chk=strcapitalize(nocap)
   rep=strlowcase(chk)
   for i=0, n_elements(nocap)-1 do outarr=str_replace(outarr,chk(i),rep(i))
endif

return,outarr
end
