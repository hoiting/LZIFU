;===============================================================================
;+
; Name:
;      GET_INDX
; Purpose:
;      Compute set of N indexes for an N-dimensional array given 1-D indexes
; Category:
;      Utility
; Calling sequence:
;      index_set = GET_INDX(index_array,dimensions)
; Inputs:
;      indx_array : 1-D indexes (vector, N elements)
;      dimensions : dimensions of the array (array: [d1,d2,...,dn])
; Keyword parameters:
;      None
; Output:
;      Output : array of array indexes (dimensions: (n,N))
; Common blocks:
;      None
; Calls:
;      None
; Description:
;      From a 1-D set of array indexes (as obtained from functions like 
;      WHERE etc.) pointing to elements of an n-dimensional array , an array 
;      of n-D indexes is extracted. If N indexes are specified by the 
;      input 1-D set, the output will be a (n,N) array.
; Side effects:
;      None
; Restrictions:
;      None
; Modification history:
;      V. Andretta, 19/Jun/1998 - Written (Modified from an earlier version)
;      V. Andretta,  9/Oct/1999 - Fixed problem with scalar input.
;      V. Andretta, 29/Oct/1999 - Changed response to invalid input.
; Contact:
;      andretta@na.astro.it
;-
;===============================================================================
;
  function GET_INDX,indx_array,dimensions


;*> On error, return to caller

  on_error,2


;*> Check input

  Nindx=n_elements(indx_array)
  if Nindx eq 0 then begin
    message,'Usage: index_set=GET_INDX(index_array,dimensions)',/continue
    return,-1L
  endif
  if Nindx eq 1 and indx_array(0) eq -1 then begin
    message,'No indexes can be extracted',/info
    return,replicate(-1L,n_elements(dimensions)>1)
  endif
  indx1=reform([long(indx_array)],Nindx,/OVERWRITE)

  Ndim=n_elements(dimensions)
  if Ndim eq 0 then begin
    message,'Usage: index_set=GET_INDX(index_array,dimensions)',/continue
    return,-1L
  endif
  N=long(dimensions)
  if (size(N))(0) gt 1 then begin
    message,'Dimensions of the array must be specified by a vector',/continue
    return,-1L
  endif

  indxN=reform(lonarr(Ndim*Nindx,/NOZERO),[Ndim,Nindx],/OVERWRITE)


;*> Compute indexes

  indxN(0,*)=indx1 mod N(0)
  for Idim=1,Ndim-1 do begin
    indx1=indx1/N(Idim-1)
    indxN(Idim,*)=indx1 mod N(Idim)
  endfor


;*> Return

  return,indxN
  end

