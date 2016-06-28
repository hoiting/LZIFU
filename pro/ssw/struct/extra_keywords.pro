;+
; Project     : HESSI
;
; Name        : EXTRA_KEYWORDS
;
; Purpose     : extract keyword settings from _extra structure
;
; Use         : @extra_keywords
;
; Inputs      : None
;
; Outputs     : All the variables associated with each tag are
;               released into memory.
;
; Explanation : 
;               For example, to obtain keyword values for a set
;               of input keywords, create a string array:
;
;               pro name,_extra=extra
;               more_keywords=[ keyword1,keyword2, etc]
;               @extra_keywords
;
;
; Restrictions: This program must be @'ed
;
; Category    : Structure handling
;
; Restrictions: This program must be @'ed
;
; Written     : Tolbert (RITSS/GSFC) October 2000
; Modified    : Zarro (EER/GSFC), Dec 14, 2002 - vectorized REM_TAG call               
;-


; if extra contains any of items in more_keywords, then make those local 
; variables from extra structure

if is_struct(extra) and (datatype(more_keywords) eq 'STR') then begin
        extra_tags = strlowcase(tag_names(extra))
        for i = n_elements(extra_tags)-1,0,-1 do begin  ; loop backwards
                idx = wc_where (more_keywords, extra_tags(i)+'*', n_found)
                if n_found gt 1 then begin
                        status = 0
                        err_msg = 'Ambiguous keywords.'
                        message, err_msg, /cont
                        return
                endif
                if n_found eq 1 then begin
                        ok = execute (more_keywords(idx(0))  + ' =  extra.(i)')
;                        extra = rem_tag(extra, extra_tags(i))
                        rtags=append_arr(rtags,extra_tags(i))
                endif
        endfor
        if exist(rtags) then extra=rem_tag(extra,rtags)
endif
if not is_struct(extra) then delvarx, extra  


