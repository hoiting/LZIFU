pro split_files, infiles, opaths, ofiles, slash=slash 
;
; +
;   Name: split_files
;
;   Purpose: seperate infiles into paths and filenames
;
;   Input Parameters:
;      infiles - string or string array with path/filename   
; 
;   Optional Keyword Input:
;      slash - if set, the trailing / on the pathname is left 
;
;   History: slf, 20-feb-1992
;
;   Restrictions: unix only
;
;-
on_error,2
if strupcase(!version.os) eq 'VMS' then $
   message,"unix only for now"

opaths=infiles
ofiles=infiles
;
slash=keyword_set(slash)
;
delimit=str_lastpos(infiles,'/')
;
; minimize loop count by using strmid for similar cases
case n_elements(delimit) of
   1:    cases=delimit					; scaler
   else: cases=delimit(uniq(delimit,sort(delimit)))	; array
endcase
;
for i=0, n_elements(cases)-1 do begin
   casen=where(delimit eq cases(i))
   ofiles(casen)=strmid(infiles(casen),cases(i)+1,1000)
   opaths(casen)=strmid(infiles(casen),0,cases(i) + slash)
endfor
;
return
end
