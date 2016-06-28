	FUNCTION str_diff, str1, str2, diff=diff, 	$
 		tnames=tnames, tnums=tnums,		$
		dtnames=dtnames, dtnums=dtnums
;	-----------------------------------------------------------
;+							20-Feb-92
;	NAME: diff_str
;
;	PURPOSE: Boolean function returns true (1) when differences
;		are found between the two input structures.  IF no
;		differences are found returns false (0).
;	
;	INPUT:
;		str1		1st structure for comparison
;		str2		2nd structure for comparison
;
;       Optional Keyword Input:
;		diff   - if set, only checks tags (
;		tnames - vector of tagnames to check
;		tnums  - vector of tnums to check
;
;       Optional Keyword Output:
;		dtnames - vector of tagnames which differ
;		dtnums  - vector of tagnumbers which differ
;
;	RETURNED:
;		0	no differences found
;		1	differences found and listed in dtags
;
;	HISTORY: written 20-Feb-92, slf/gal
;	
;       Restrictions - not yet recursive (no nested tags)
;
;-
;	--------------------------------------------------------------
if n_elements(tnames) eq 0 then tnames=tag_names(str1)
tagnames=tnames
;
difftagn=(n_tags(str1) ne n_tags(str2))		; check number of tags
;
diffmap=[0]					; init diff map vector
;
; check for tag data type differences 
for i=0,min([n_tags(str1) ,n_tags(str2)])-1 do 	begin $	; tag data types 
     if (str_is(str1.(i)) and str_is(str2.(i))) then $
        thisdiff=str_diff(str1.(i),str2.(i)) else  $		; rcrs.
	thisdiff=total(abs(size(str1.(i))-size(str2.(i)))) 	; nonzer0=diff
     diffmap=[diffmap, thisdiff]				; map diffs.
endfor
;
dtnums=where(diffmap(1:*),count)		; output diff tag#
difftype=(count gt 0)				; any nonzero=diff
;
global_chks = (difftagn or difftype) and (not keyword_set(diff))

diffmap=[0]					; bogus 1st 
for i=0,n_elements(tnames)-1 do begin		; user tag list
   t1pos=tag_index(str1,tnames(i))		; tag position, str1
   t2pos=tag_index(str2,tnames(i))		; tag position, str2
   missing=((t1pos eq -1) or (t2pos eq -1))	; present in both?
   typechk=where(t1pos eq dtnums,count)         ; rcrs already done
   difftype=(count ne 0)			; same data type? 
   diffval=0					; initailize
   if not (missing or difftype) then $		; ok to compare 
      diffval=total(str1.(t1pos) ne str2.(t2pos)) ne 0
   diffmap=[diffmap,	$
      (missing or difftype or diffval)]		; diff bit map set
endfor
;
dtnums=where(diffmap(1:*),count)
if(count gt 0) then dtnames=tagnames(dtnums) else dtnames=''
specific_chks=(total(diffmap) ne 0)
return, global_chks or specific_chks
end
