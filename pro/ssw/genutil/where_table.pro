function where_table, text, tabcnt, min_line=min_line, min_column=min_column, $
  		debug=debug, loud=loud
;+
;   Name: where_table
;
;   Purpose: identify tables within a text array
;
;   History:
;      29-mar-1995 (S.L.Freeland) - for text formatting (ex: text->html)
;       5-mar-1997 (SLF) - made quiet the default
;-

loud=keyword_set(loud)
if n_elements(min_line) eq 0 then min_line=3
if n_elements(min_column) eq 0 then min_column=3

remtab,text,ntext		; tabs to spaces
btext=byte(ntext)		; byte version

bmap=btext eq 32b	; space bit map

debug=keyword_set(debug)
tabss=0
starttab=0
stoptab=0
tabon=0

for i=0,n_elements(ntext)-(min_line+1) do begin
   btotal=total(bmap(*,i:i+min_line-1),2)		; total b map columns
   chkb=where(btotal eq min_line,c1)			; blanks
   chkl=where(btotal eq 0, c2)				; non-blanks
;  *********** vectorize this FORTRAN-like code *************
;  
   if c1 ge min_column and c2 gt 0 then begin
      tabss=[tabss,i]					; first table ss
      if 1-tabon then begin
	 starttab=[starttab,i]
         tabon=1
      endif
   endif else begin
      if tabon then stoptab=[stoptab,i-1]
      tabon=0
   endelse
;  **********************************************************
   if debug then stop
endfor

ss=[-1,-1]
tabcnt=n_elements(starttab)-1
if n_elements(starttab) - n_elements(stoptab) eq 1 then $
   stoptab=[stoptab,i+min_line-1]
if tabcnt gt 0 then ss=[[starttab(1:*)],[stoptab(1:*)+min_line]]  else $
    if loud then message,/info,"No tables found..." 

; vectorize using deriv tabss...
;if n_elements(tabss) eq 1 then message,/info,"No tables found..." else begin
;   tabss=tabss(1:*)
;   dtdx=deriv_arr(tabss)
;   utab=where(dtdx gt 1,ucnt)
;   if ucnt eq 1 then ss=[tabss(0),tabss(0)+ min_line] else begin
;      for j=0,ucnt - 1 do begin
;      tabstart=tabss(where(dtdx eq 1))
;      tabend=tabss(where(dtdx gt 1)) + min_line
;      ss=tabss
;      endfor
;   endelse
;endelse

return,ss

end
