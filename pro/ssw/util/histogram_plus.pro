;+
; PROJECT: SSW
;
; NAME: HISTOGRAM_PLUS
;
;
; PURPOSE: Returns the normal IDL histogram, with the reverse_indices packaged into
;   a pointer to avoid the nasty syntax.
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;    hist = histogram_plus( array, $
;     Select, Nselect=Nselect, REV_PTR= rev_ptr, $
;     [, BINSIZE=value] [, INPUT=variable] [, MAX=value] [, MIN=value] [, /NAN] $
;     [, NBINS=value] [, OMAX=variable] [, OMIN=variable] $
;     [, /L64 |  REVERSE_INDICES=variable] )
;
;
; CALLS:
; none
; Return Value

; Returns a 32-bit or a 64-bit integer vector equal to the density function of the input Array.
;
; INPUTS:
;       Array -The vector or array for which the density function is to be computed.
;
; OPTIONAL INPUTS:
;
;
; OUTPUTS:
;       Select - valid indices from histogram(ARRAY)
;
; OPTIONAL OUTPUTS:
; none
;
; KEYWORDS:
;   NSELECT - number of elements in select
;   REV_PTR - Ptr array of indices corresponding to elements of Select.
;     If no value are found, REV_PTR is set to 0.
;
;   All Keyword Inputs available to HISTOGRAM
; COMMON BLOCKS:
; none
;
; SIDE EFFECTS:
; none
;
; RESTRICTIONS:
; none
;
; PROCEDURE:
;   Input array is scanned using histogram function.  The valid indices are returned
;   in Select.
;
; MODIFICATION HISTORY:
; 24-Jan-2002, Version 1, richard.schwartz@gsfc.nasa.gov
; 28-Jan-2002, ras, fixed bug with r, used r[select[i]] not r[i]
;
;-

function histogram_plus, array, select, rev_ptr=rev_ptr, $
nselect=nselect, _extra=_extra

h = histogram( array, revers=r, _extra=_extra )

select = where( h gt 0, nselect )

rev_ptr = 0
if nselect ge 1 then begin
  rev_ptr = ptrarr( nselect )
  for i=0, nselect-1 do rev_ptr[i] = ptr_new( r[r[select[i]]:r[select[i]+1]-1] )
  endif

return, h
end