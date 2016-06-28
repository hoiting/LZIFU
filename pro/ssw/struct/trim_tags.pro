;+
; Project     :	HESSI
;
; Name        :	TRIM_TAGS
;
; Purpose     :	Trim all string tags in a structure
;
; Syntax      :	IDL> out=trim_tags(in)
;
; Inputs      :	IN = input struct
;
; Opt. Inputs :	None.
;
; Outputs     :	OUT = output struct with string tags trimmed
;
; Opt. Outputs:	None.
;
; Keywords    : RECURSE = recurse on nested structures
;               NO_COPY = do not make new copy of input
;
; Category    :	Structures
;
; Written     :	Dominic Zarro, SM&A/GSFC, 19 May 1999
;
; Contact     : dzarro@solar.stanford.edu
;-

	function trim_tags,struct,recurse=recurse,no_copy=no_copy

	on_error, 1
        if datatype(struct) ne 'STC' then begin
         pr_syntax,'out=trim_tags(struct)'
         if exist(struct) then return,struct else return,-1
        endif

        recurse=keyword_set(recurse)
        ntags=n_elements(tag_names(struct))        

        if keyword_set(no_copy) then out=temporary(struct) else out=struct
        for i=0,ntags-1 do begin
         if datatype(out(0).(i)) eq 'STR' then out.(i)=trim(out.(i)) 
         if (datatype(out(0).(i)) eq 'STC') and recurse then $
          out.(i)=trim_tags(out.(i),/recurse,no_copy=no_copy)
        endfor

        return,out
        end
