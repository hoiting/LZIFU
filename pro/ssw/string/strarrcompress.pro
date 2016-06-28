function strarrcompress, strarray, rows=rows, columns=columns, $
	pattern=pattern, trim=trim
;+
;   Name: strarrcompress
;
;   Purpose: remove null elements from string arrays (1D 2D)
;
;   Input Paramters:
;      strarray - string array
;
;   Keyword Parameters:
;      rows    - switch (2D only) - if set, eliminate null rows
;      columns - switch (2D only) - if set, eliminate null columns
;      trim    - if set, trim non-null elements (leading/trailing blanks) 
;
;   Calling Sequence:
;      comparr=strarrcompress(strarr)
;
;   History:
;      14-May-1996 - S.L.Freeland
;-
if not keyword_set(pattern) then pattern=''	

rows=keyword_set(rows) or (1 - keyword_set(columns))

sarr=size(strarray)

tarr=strcompress(strarray,/remove)
tmap=tarr eq pattern
nncnt=0

case 1 of 
   sarr(0) eq 1: begin					; 1D case
      nonnull=where(strlen(tarr) gt 0,nncnt)
      if nncnt gt 0 then retval=strarray(nonnull)       ; non-nulls
   endcase

   keyword_set(rows): begin
      nonnull=where(total(tmap,1) ne n_elements(tmap(*,0)),nncnt)
      if nncnt gt 0 then retval=strarray(*,nonnull)      
   endcase

   keyword_set(columns): begin
      nonnull=where(total(tmap,2) ne n_elements(tmap(0,*)),nncnt)
      if nncnt gt 0 then retval=strarray(nonnull,*)     
   endcase

   else:message,/info,"Unexpected case..."
endcase

if nncnt eq 0 then retval=''
if keyword_set(trim) then retval=strtrim(retval,2)

return,retval
end
