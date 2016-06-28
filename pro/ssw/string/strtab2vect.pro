pro strtab2vect,strtable, p0, p1, p2, p3, p4, p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15, $
	    columns=columns
;+
;   Name: strtab2vect
;
;   Purpose: extract columns in a 2D string table to one or more 1D vectors
;
;   Input Parameters:
;      strtable - a string "table" (2D)
;
;   Output Parameters:
;      p0 - vector = reform(strtable(0,*))
;      [p1,p2,p3....pN - vectors = reform(strtable(N,*)) ]
;  
;   Keyword Parameters:
;      column - user specified column(s) to map -> p0 [p1, p2...]
;  
;   Calling Sequence:
;      strtab2vect, table, v1 [,v2,v3...vN]  ; map table(N,*)->vN
;      strtab2vect, table, a[,b,c..], col=[x,y,z...] ; map table(x,*)->a
;
;   Calling Example:
;    IDL> help,dbdata                               ; input table
;         DBDATA          STRING    = Array(5, 41)
;    IDL> strtab2vect,dbdata,c0,c4,columns=[0,4]    ; <<<<
;    IDL> help,c0,c4
;         C0              STRING    = Array(41)
;         C4              STRING    = Array(41)
;
;   History:
;      22-Jan-1999 - S.L.Freeland - tired of 'vect=reform(strtab(n,*))'
;  
noutput=n_params()-1
if not keyword_set(columns) then columns=lindgen(noutput)
pout='p'+strtrim(lindgen(noutput),2)

ncoltab=data_chk(strtable,/nx)

if noutput gt ncoltab then begin
  noutput=ncoltab
  box_message,['Warning: columns requested exceed table dimension',$
	       'Only ' + strtrim(noutput,2) + ' output values valid']
endif  

if max(columns)+1 gt  ncoltab then begin
  box_message,'Requested or implied column numbers exceed table columns'
  columns=columns<(ncoltab-1)
endif

for i=0,noutput-1 do begin
   exestat=execute('delvarx,'+pout(i))                   ; delete value
   exestr=pout(i) + ' =reform(strtable(columns(i),*))'   ; assign to outpu Pn
   exestat=execute(exestr)
endfor

return
end
