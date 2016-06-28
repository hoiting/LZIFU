function get_history, index, pattern, version=version, caller=caller, $
		      found=found, loud=loud
;+
;   Name: get_history
;
;   Purpose: get HISTORY from structures or FITS header, optionally match patt
;
;   Input Parameters:
;      index - structure array or (less useful) FITS header
;      pattern - optional string pattern to match
;
;   Keyword Parameters:
;      caller - if set than PATTERN=Calling Routine Name
;      version - if set, extract VERSION number (per update_history)
;      found (output)  - boolean if specified history/pattern found
;  
;   Calling Sequence:
;      hist=get_history(index [,pattern], [/version] [/routine or routine=xx])
;
;   History:
;      3-November-1998 - S.L.Freeland - simplify common sequence
;      1-December-1998 - S.L.Freeland - set missing VERSIONs to -1.0
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;  
;   Calls:
;      gt_tagval , data_chk, wc_where, ssw_strsplit, str_replace
;-
loud=keyword_set(loud)
  
; extract .HISTORY
hist=gt_tagval(index, /history, found=found, missing='')

if not found then begin
   if loud then box_message,'No HISTORY records found...'
   return,hist
endif  

case 1 of
   data_chk(pattern,/string):
   data_chk(caller,/string): pattern=caller
   keyword_set(caller): pattern=get_caller()
   else: pattern=''
endcase

; -------- now do pattern searching -----------
ss=wc_where(hist,'*'+pattern+'*',count,/case_ignore)
found=count gt 0

nulls=strarr(n_elements(index))
retval=hist
retval(*)=''


if found then begin
  retval(ss)=hist(ss)
  if keyword_set(version) then begin
      sss=wc_where(retval,'*VERSION:*',count,/case_ignore)
      found=count gt 0
      if found then retval=str2number(ssw_strsplit(retval(sss),'VERSION:',/tail)) else $
             retval=str2number(nulls)-1
   endif 
endif else begin
   retval=nulls
   if keyword_set(version) then retval=str2number(nulls)-1
endelse
if loud then begin
   if found then mess='Number of matching HISTORY records: ' + strtrim(count,2) else $
       mess="No matching HISTORY records"
   box_message,mess

endif  

return,retval
end
