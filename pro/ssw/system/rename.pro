pro rename, old, new, filt=filt, lowcase=lowcase, upcase=upcase
;
;+
;   Name: rename 
;
;   Purpose: rename unix files (new string replaces old string)
;
;   Input Parameters
;      old - pattern to replace
;      new - new pattern to insert (default is null)
;
;   Keyword Parameters:
;      filt - file filter - replace done on subset matching this pattern
;	      normally, old pattern is used for file matching
;	      include wild cards on one or both sides
;      lowcase - if set, convert to lower case
;      upcase  - if set, convert to upper case
;   
;   Restrictions: unix only
;
;   Caution: make sure your pattern only occurs where you expect it!!
;            all occureneces are replaced
;
;   History - slf, Feb 1992
;	      slf, 10-Oct-1992 - add lowcase/upcase keywords
;	      slf, 16-mar-1993 - allow directory renames (eliminate ':')
;-
if not keyword_set(filt) then filt='*'
; allow numerical input
old=string(old)
if n_elements(new) eq 0 then new=' '
new=string(new)
;
files=findfile(filt)
patoccur=where(strpos(files,old) ge 0,count)	; only where old occurs
;
if count eq 0 then begin
   message,/info,"No matching files, returning"
   return
endif
;
oldnames=files(patoccur)
dirs=where(strpos(oldnames,':') eq strlen(oldnames)-1,dcount)
if dcount gt 0 then $
   oldnames=str_replace(oldnames,':','')	; caution !! should 
						; only do for last position

newnames=strcompress(str_replace(oldnames,old,new),/remove)
if keyword_set(lowcase) then newnames=strlowcase(newnames)
if keyword_set(upcase)  then newnames=strupcase(newnames)
;
for i=0,n_elements(oldnames)-1 do begin
   spawn,'mv -f "' + oldnames(i) + '" ' + newnames(i)
   message,/info,'Renaming:' +  oldnames(i) + ' To:' +  newnames(i)
endfor
;
return
end
