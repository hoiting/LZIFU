function strwhere,st_array,search_st, mcount
;+
; NAME
;       strwhere
; PURPOSE
;       Search for occurrences of a string in a string array.
; CALLING SEQUENCE
;`      ss=strwhere(st_array,'search_st')
; CALLING EXAMPLE
;       ss=strwhere(sfrs,'*911226.14*')
; INPUT
;       st_array = string array to be searched.
;       search_st = string for which to search.
;               Wildcards (*) can be used.
; OUTPUT
;       ss = indices where desired string is found in array.
;       mcount - number of matches
;
; PROGRAMS CALLED
;       strmatch, where
; HISTORY
;       15-jan-2001  LWA, Written.
;       15-Feb-2001  SLF, make backwardly compatible
;                    (strmatch only available >=5.3)
;                    [ use similar 'wc_where.pro' ]
;
;-

if since_version('5.3') then begin 
   ii=strmatch(st_array,search_st)
   jj=where(ii eq 1,mcount)
endif else jj=wc_where(st_array,search_st,mcount)

return,jj

end

