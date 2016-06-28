function get_infox, index, itags, format=format, header=header, delim=delim, $
	number=number, fmt_time=fmt_time, _extra=_extra, $
        display=display, more=more, $
        day_only=day_only, time_only=time_only, msecs=msecs, $
	titles=titles, keylab=keylab
;+
;   Name: get_infox
;
;   Purpose: convert IDL structure info to string summary (1 line/structure)
;
;   Input Parameters:
;      index - index structure
;      itags - desired list of TAGS to include 
;              (string array or comma delimited string)
;
;   Keyword Parameters:
;      format -  optional format list as string array or comma delimited string
;      delim  -  optional inter-field delimter (default = two blanks)
;      /gt_xxx - optional gt_functions to call and include in output
;      /display - print results to terminal
;      /more    - same as /display with more-like behavior
;      /number -  switch, if set, prepend the index subscript to each string
;      header - (output) - aligned header string 
;      fmt_time  - if switch set and structure contains STANDARD time keywords
;      fmt_time  - if STRING, specify desired string format for TIME/DAY
;                  (see OUT_STYLE options for anytim.pro)
;      day_only  - if set, only return DAY portion of DATE
;      time_only - if set, only return TIME portion of DATE
;	titles	- The array of column headings for the listing.  Default is
;		  the tag names.
;	keylab	- If set, then put the column labels with the data
;
;   Calling Sequence:
;      outstring=get_infox(structure, 'tag1,tag2,...tagn' , 		$
;				       header=header ,  		$
;				       /fmt_time, /gt_xxx, /gt_yyy, 	$
;                                      /number,				$
;				       /display, /more ]
;   Calling Examples:
;   IDL> info=get_infox(!version, 'OS_FAMILY,RELEASE,ARCH,OS',/more)
;    OS_FAM  RELEASE   ARCH   OS
;      unix   4.0.1a  alpha  OSF
;
;   In the following, eitstr is a 3 element vector of type eit_struct()
;   IDL> more, get_infox(eitstr,'WAVELNTH,FILTER',fmt_tim='ecs',format='a,a')
;        1997/03/14 00:11:50.000       304   Clear
;        1997/03/14 00:34:49.000       304   Clear
;        1997/03/14 00:50:10.000       304   Clear
;
;   IDL> more,get_infox(eitstr,'WAVELNTH,NAXIS1',fmt_tim='ccsds',format='a,a')
;        1997-03-14T00:11:50.000Z       304       512
;        1997-03-14T00:34:49.000Z       304       512
;        1997-03-14T00:50:10.000Z       304       512
;
;   History:
;      22-March-1996 (S.L.Freeland) - generalize the 'get_info' problem
;       3-April-1996 (S.L.Freeland) - added NUMBER keyword & function
;      18-march-1997 (S.L.Freeland) - add DAY_ONLY,TIME_ONLY keyword & function
;                                     (passed to ANYTIM), add MSECS (def=NO)
;      19-Feb-1998   (S.L.Freeland) - merge MDM suggestions
;                                   - enhance auto-formating logic  
;	19-Feb-1998 (M.D.Morrison)	- Added "titles" input
;	24-Feb-1998 (M.D.Morrison)	- Added KEYLAB option
;	10-Mar-1998 (M.D.Morrison)	- Changed "string(outtag" to "fstring(outtag"
;					  to avoid the "% STRING: Explicitly formated output truncated 
;					  at limit of 1024 lines." error
;       22-Nov-1999 (S.L.Freeland) - expand auto-fmts a little
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;
;   Method:
;      calls gt_tagval  (to extract the data)
;            strjustify (to align columns)
;            gt_xxx     (optionally called)
;            anytim     (if FMT_TIM, TIME, or DAY switches are set)
;
;   Restrictions:
;      if FORMAT is supplied, n_elements(FORMAT) must EQ n_elements(FIELDS)
;      if FMT_TIME is supplied, structure must contain SSW standard TIME tags
;
;   TODO - (allow FITs header or FITS file list?? recursive call after str convert??)
;-

if not data_chk(index,/struct) then begin
   message,/info,"Need data structure array
   return,''
endif
nind=n_elements(index)				; number input/ouput elements

if n_elements(delim) eq 0 then delim='  '	; default delimiter=two blanks

; -------------- define tag/field array ------------------------------
if keyword_set(itags) then begin
   tags=itags   
   if strpos(tags(0),',') ne -1 then tags=str2arr(tags)  ; user list
   tags=strupcase(strtrim(tags,2))	
endif
ntag=n_elements(tags)

; -----------------------------------------------------------------------   

; ---- output format=user supplied or data type dependent defaults  ----
defform='(' + ['a','i3','i7','i8','f8.2','f10.4','a','a'] + ')'
case n_elements(format) of
   0: forms=replicate('a',ntag)
   1: forms=strtrim(str2arr(format(0)),2)
   else: forms=format
endcase

if keyword_set(forms) then forms="(" + forms + ")"
; -----------------------------------------------------------------------   

; ---- initialize output array - include TIME on request -------------
day_only =keyword_set(day_only)
time_only=keyword_set(time_only)
msecs=keyword_set(msecs)

if msecs or day_only or time_only or (n_elements(fmt_time) ne 0) then begin
   if not data_chk(fmt_time,/scalar,/string) then fmt_time='yohkoh'
   otimes=anytim(index,out_style=fmt_time, time=time_only, date=day_only)
   if 1-msecs and strpos(otimes(0),'.') ne -1 then otimes= $
      ssw_strsplit(otimes,'.',/head) + (['','Z'])(strupcase(fmt_time) eq 'CCSDS')
   outarr=strjustify([ ([' START TIME',' START DAY'])(day_only),otimes],/center)
endif else outarr=strarr(nind+1)
; -----------------------------------------------------------------------   

; ------- call gt_functions if specified (keyword inheritance) --------
;         (assume syntax: out=gt_xxx(index,/string) is allowed)

if n_tags(_extra) gt 0 then begin
   funcs=strlowcase(tag_names(_extra))
   gt_funcs=where(strpos(funcs, 'gt_') eq 0,gtcnt)	 ; gt functions
   for i=0, gtcnt-1 do outarr=outarr + delim + $
         strjustify([strupcase(strmid(funcs(gt_funcs(i)),3,16)), $
         call_function(funcs(gt_funcs(i)),index,/string)],/right)
endif
; -----------------------------------------------------------------------   

case n_elements(titles) of
   0: tit_arr = tags
   1: tit_arr = strtrim(str2arr(titles(0)),2)
   else: tit_arr = titles
endcase

; ----------- now loop through specified tags/fields----------------------

head = ''
uformat=keyword_set(format)
for i=0,n_elements(tags)-1 do begin
   outtag=gt_tagval(index,tags(i),found=found)		; extract the data

   form=([defform(data_chk(outtag,/type)), $		; default format OR
                  forms(i)])(uformat)		; user supplied format

   form=([form,'(a)'])(found eq -1)		          ; Tag not found?
   if found eq -1 then 	outtag=replicate('[no-tag]',nind) ; Force Message

   if form eq '(a)' then form = $		          ; avoid array 
	'(a' + strtrim(max(strlen(outtag))>1,2) + ')'     ; truncation at null

   souttag=fstring(outtag,format=form) 			  ; this tag -> string
   newcol=[strmid(tags(i),0,max(strlen(souttag))),souttag]
   if not uformat then newcol=strjustify(newcol,/right)
   if (keyword_set(keylab)) then newcol = tit_arr(i) + ' ' + newcol + '  '
   outarr=outarr + ([delim,''])(i eq 0) + newcol

   head0 = strmid( strjustify(tit_arr(i), width=strlen(newcol(1)), /right), 0, strlen(newcol(1)))
   head = head + ([delim,''])(i eq 0) + head0
endfor

; -----------------------------------------------------------------------   

;;header=outarr(0)			; seperate header from output data
header=head
outarr=outarr(1:*)			; to maintain input->output mapping

; ----------------- prepend index number on request ---------------------
if keyword_set(number) then begin
   header=string(replicate(35b,strlen(strtrim(nind,2)))) + delim + header
   outarr=strjustify(strtrim(lindgen(nind),2)) +  delim + outarr
endif
; -----------------------------------------------------------------------   

; --------------- display on request ----------------------------------
more=keyword_set(more)
display=keyword_set(display) or more 
if display then prstr,[header,outarr],nomore=(1-more) ;loosely quoth the Raven 
; -----------------------------------------------------------------------   

return,outarr
end
