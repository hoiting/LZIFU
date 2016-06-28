;+
; NAME:
; 	FMT_TIMER	
; PURPOSE:
;	print formatted times of an index file
; CALLING SEQUENCE:
; 	fmt_timer,index	
; 	fmt_timer,index,tmin,tmax,imin=imin,imax=imax,tspan=tspan
;       fmt_timer,index,/noprint
;
; Keyword Parameters:
;   /noprint, /quiet - dont print, just return t0/t1
;   /no_sort - just strip first and last elements (assume sorted)
;              (more efficient for large input vectors)
;              (default for very large input unless /force_sort set)
;
;   /force_sort - override default switch to /no_sort if very large
;                 input vectors (which are transparently inefficient)
;
; OPTIONAL OUTPUTS
;	TMIN	- formatted time of minimum time of index records
;	TMAX	- formatted time of maximum time of index records
;	IMIN	- index of the input structure INDEX corresponding to TMIN
;	IMAX	- index of the input structure INDEX corresponding to TMAX
;	TSPAN	- time span in sec of index records
;
;  
; HISTORY:
;	Hugh Hudson, Dec. 18,  1992
;	HSH, outputs added May 18, 1993
;	HSH, changed output and added /noprint keyword Aug 26, 1993
;	GLS, modified code to handle cases where index records are not time
;	     sorted, and added IMIN, IMAX output keywords
;       SLF, use anytim.pro (allow all SSW/YOhkoh/SOHO times)
;       SLF, add /QUIET, /NO_SORT, /FORCE_SORT
;       SLF, 19-aug-1998 - made sort the default
;-
pro fmt_timer, index, tmin, tmax, imin=imin, imax=imax, tspan=tspan, $
	       noprint=noprint, no_sort=no_sort, force_sort=force_sort, $
               quiet=quiet

slimit=10000l                         ; just take first/last if over this #
nindex=n_elements(index)
dont_sort=keyword_set(no_sort)
force_sort=1-dont_sort
overlimit=(nindex gt slimit)
noprint = keyword_set(noprint) or keyword_set(quiet)

if dont_sort then begin
  iindex=anytim([index(0),index(nindex-1)],out='ints')
  if not keyword_set(no_sort) then box_message,$
      ['Lots of input, assuming sorted for memory efficiency', $
       'use /FORCE_SORT to override']
endif else iindex=anytim(index,out='ints')           ; allow any SSW time
 
tsec = int2secarr(iindex)
imin = where(tsec eq min(tsec))
imax = where(tsec eq max(tsec))
tmin = fmt_tim(iindex(imin(0)))
tmax = fmt_tim(iindex(imax(0)))
tspan = tsec(imax(0)) - tsec(imin(0))

if not noprint then $
  print,"(first, last) = '",tmin,"', '",tmax,"'"

end
