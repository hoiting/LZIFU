function str2cols, inarr, delim, ncols=ncols, colpos=colpos, trim=trim, $
	qstop=qstop, ignore_extra_cols=ignore_extra_cols, unaligned=unaligned, $
	debug=debug
;+
;   Name: str2cols
;
;   Purpose: break strarry into columns at specified delimiter
;
;   Input Parameters:
;      inarr - string or string array to break
;
;   Optional Keyword Parameters:
;      ncols  - number of columns in output (default is number delimiters+1)
;      colpos - user supplied position breaks (default is via delimiter search)
;      trim   - if set, trim leading and trailing blanks from output
;      unaligned - use this if any columns might overlap
;   
;   History:
;      19-May-1994 (SLF) Written
;       2-Jun-1994 (SLF) call revised remtab if delimiter is blank
;       3-Jun-1994 (SLF) return value order = arr(cols,rows)
;      13-Jun-1994 (SLF) change leading blank handler, add TRIM
;      14-Jun-1994 (SLF) protect against ncols > ndelimiters!
;       9-mar-1996 (SLF) more elegant algorithm (total delimiter bit map 
;			                         along columns)
;       6-Jun-1996 (SLF) allow 1 element (string) input
;      13-apr-1997 (SLF) allow partial lines
;	26-Nov-97  (MDM) Added QSTOP
;		   (MDM) Corrected error where there are leading blanks
;			 in front of each line for the first column
;		   (MDM) Added /IGNORE_EXTRA_COLS
;	 1-Dec-97 (MDM) Corrected 26-Nov change for when NCOLS inx
;			is not passed in
;	 1-Dec-97 (MDM) Further patch to 26-Nov
;        7-Oct-98 S.L.Freeland - add /UNALIGNED keyword and function
;
;   Restrictions:
;      USE /UNALIGNED if any columns might overlap
;      (default algorithm looks for columns of delimiters)
;
;   Method:
;      convert to bytes (makes 2D array)
;      total columns where character=delimiter - if zero, column of delimiters
;      For /UNALIGNED case, call <strmids> for every column
;  
;-
unaligned=keyword_set(unaligned)
debug=keyword_set(debug)

if not keyword_set(delim) then delim=' '		; blank is default
incol=keyword_set(ncols)				; user defined

if not data_chk(inarr,/defined,/string) then begin	; verify input
   message,/info,"Input must be string or string array"
   return,''
endif

chkd=where(strpos(inarr,delim) ne -1, dcnt)

if dcnt eq 0 then begin
   return,inarr                      ; NO Delimiters, EARLY EXIT
endif  

inarray=inarr						; protect input

if delim eq ' ' then  begin
   remtab, inarray, inarray	; remove tabs
   if unaligned then inarray=strcompress(inarray)       ; remove excess delim 
endif

one_liner=n_elements(inarray) eq 1
if one_liner then inarray=[inarray,'']
nrows=n_elements(inarray)

; convert null lines to line of delimiters
nulls=where(strlen(strcompress(inarray,/remove)) eq 0,nullcnt)

if nullcnt gt 0 then $
   inarray(nulls)= string(replicate( (byte(delim))(0),max(strlen(inarray) )))

nnulls=where(inarray ne '',nnullcnt)
if nnullcnt eq 0 then begin				; ignore null lines
   nnulls = indgen(nrows)
   nnullcnt = nrows
endif

binarr=byte(inarray)                       ; byte version

case 1 of 
   unaligned: begin 
      ss=where_pattern(inarr,delim,dcnt)            ; where delimiters
         dmap=binarr                                ; else, delimiter map
         dmap(*)=0       
         dmap(ss)=1                                 ; set delimiter boolean
         tdelim=total(dmap,1)                       ; total delimiters per entry
         maxd=max(tdelim)                           ; maximum
         retval=strarr(maxd+1,n_elements(inarr))    ; size output array
         if delim eq ' ' then inarr=strtrim(inarr,1)
         dpos=strpos(inarr,delim)
         tail=inarr
         for i=0,maxd do begin                      ; for up to max delim/entry
           nodelim=where(dpos eq -1,ndcnt)          ; 
	   if ndcnt gt 0 then $
	      dpos(nodelim)=strlen(tail(nodelim))  ; these entries finished
           head=strmids(tail,0,dpos)                ; do one column   
	   retval(i,*)=temporary(head)              ; insert->output
	   tail=strmids(tail,dpos+1,strlen(tail))   ; define the tail
           if delim eq ' ' then tail=strtrim(tail,1)
	   dpos=strpos(tail,delim)                  ; next delim pos for column
           if debug then stop
         endfor
         if delim eq ' ' then retval=strtrim(retval,2)
         retval=strarrcompress(retval,/column)        ; remove null columns
   endcase
   else: begin
      if strlen(delim) gt 1 then  begin
         message,/info,"Delimiter must be 1 character...
         retval=inarray
      endif

     if not keyword_set(colpos) then begin
;        make a bit map of non-delimiters, then take column totals
;        (total = 0 implies every row has delimiter in that column)
         dmap=(binarr ne (byte(delim))(0) and binarr ne 0b)
         colpos=where(total(dmap,2) eq 0 and total(shift(dmap,-1),2) ne 0)
      endif
      
      cpos=[colpos]
      if (colpos(0) ne 0) then begin
	tmp = byte(strmid(inarray,0,1)) - fix(byte(delim))	;see if all first char is delim
	if (max(abs(tmp)) ne 0) then cpos=[0,colpos]	;first column starts at char 0
      end
      upos=[deriv_arr(cpos), max(strlen(inarray))]
      if not keyword_set(ncols) then ncols=n_elements(upos) else $
         if ncols gt n_elements(upos) then ncols=n_elements(upos)

      retval=strarr(ncols,nrows)

      for i=0,ncols-2 do begin
         retval(i,*)=strmid(inarray,cpos(i),upos(i))
      endfor
      lcollen = max(strlen(inarray))	;last column length
      if (keyword_set(ignore_extra_cols)) then lcollen = upos(i)
      retval(i,*)=strmid(inarray,cpos(i),lcollen)
   endcase
endcase
;
if (keyword_set(qstop)) then stop
; 
if n_elements(retval(*,0)) gt 1 and delim eq ' ' then begin
   notnull=where(strtrim(retval(0,*),2) ne '',nncnt)
   if nncnt eq 0 then begin
      lead_blank=retval(0,*)
      retval(1,*)=retval(0,*) + retval(1,*)
      retval=retval(1:*,*)
   endif
endif 

if delim ne ' ' then begin		; blank out delimiters
   bretval=byte(retval)
   wdelim=where(bretval eq (byte(delim))(0),bcnt)
   if bcnt gt 0 then bretval(wdelim)=32b
   retval=string(bretval)
endif

if keyword_set(trim) then retval=strtrim(retval,2)

if one_liner then retval=retval(*,0)

if (keyword_set(qstop)) then stop
return,retval
end   
   
