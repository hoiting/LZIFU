;+
; Project     :	SOHO - CDS
;
; Name        :	SPLIT_STRUCT
;
; Purpose     :	split two structures apart
;
; Explanation :
;
; Use         : SPLIT_STRUCT,STRUCT,INDEX,S1,S2
;
; Inputs      :	STRUCT = input structure to split
;               INDEX  = index (or tag name) at which to break off structure
;                        (all tags after and including this tag will be removed)
; Opt. Inputs :	None.
;
; Outputs     :	S1, S2 = split structures
;
; Version     :	Version 1.0, 22 January 1995
;               Version 2.0, 8 Oct 1998 -- modified to use CREATE_STRUCT
;               Version 3, 12-Dec-1998 -- improved memory management
;               Version 4, 23-Dec-2004 -- improved with REM_TAG
;-

pro split_struct,struct,index,s1,s2

if (1-is_struct(struct)) or (n_elements(index) eq 0) then begin
 pr_syntax,'split_struct,struct,index,s1,s2'
 return
endif

tags=tag_names(struct)
ntags=n_elements(tags)
if is_string(index) then begin
 cut=where(strupcase(strtrim(index,2)) eq tags,count)
 if (count eq 0) then begin
  message,'no such tag',/cont
  return
 endif
endif else cut=index
cut=cut[0]

if cut le 0 then begin
 s2=struct
 return
endif

if cut ge (ntags-1) then begin
 s1=struct
 return
endif

;-- split by removing tags 

scut=indgen(ntags-cut)+cut
s1=rem_tag(struct,scut)

scut=indgen(cut)
s2=rem_tag(struct,scut)

return & end

