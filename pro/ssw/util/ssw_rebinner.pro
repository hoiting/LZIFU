
;+
; PROJECT:
;       SSW
; Name:
;   ssw_rebin_assign
; Purpose:
;   This function builds a structure to map a function/distribution on
;   one set of edges into new edges. Coefficients are strictly proportional
;   to the bin widths.
;
; Procedure:
; The structure array has one structure for every element of the new
; binning.  The structure looks like this:
;** Structure <1b65f20>, 3 tags, length=12, data length=12, refs=1:
;  I0              LONG                 0
;  N               LONG                 0
;  FRAC            POINTER   <PtrHeapVar1311>
;
; I0 - starting bin for old bin edges that map to this new bin
; N  - number of consecutive old bins to use
; FRAC - fraction of old bin value to use in new bins. FRAC is a pointer.
; This procedure creates a linear transformation matrix which can be used
; to rebin vector data such as count rates defined on a PHA scale.
; It is for a matrix with n output bins defined on energy edges EDGE1, (n+1)
; and create a transform, MAP, to interpolate a detector response, MATRIX1, from
; narrow channels to broader output channels defined by EDGE2.  The matrix
; is defined in terms of counts/channel unless the keyword FLUX is set.
; This operation is sometimes called flux rebinning.  Matrix2 is generally
; a matrix with mostly zeroes and can be easily represented with a sparse matrix
; if the matrix is square.
;   for a bin defined on EDGE1 which falls wholly within a bin on EDGE2
;   the map matrix element is 1
;   for a bin defined on EDGE1 which falls partially within a bin on EDGE2
;   the map matrix element is given by the fraction of BIN1 contained by BIN2

;
; Category:
;   GEN, SPECTRUM, UTILITY,
; Calling Sequence:
;   map = ssw_rebin_assign( edge1, edge2 )
;
;
; Inputs:
;   Edge1: N+1 energy edges of N output bins or 2xN energy edges
;   Edge2: K+1 output energy edges for new matrix, or 2xK edges
;
; Outputs:
;   Map: The structure holding the transformation coefficients.
;     This is to be used with rebinner().
; Restrictions:
;   This is not an optimized procedure
;
;
; History:
;   Version 1, RAS, 12-dec-2002, based on map_matrix.
;   15-nov-03, ras, longword for loop index
;   7-jan-2004, ras, removes old pointers instead of leaving dangling hidden pointers
;-

function ssw_rebin_assign, edge1, edge2

in_edge1=edge1
in_edge2=edge2


edge_products, edge1, edges_2=edge1, width=we1
edge_products, edge2, edges_2=edge2, width=we2

n1=n_elements(edge1[0,*])  ;output bins in matrix1, energy edges,
n2=n_elements(edge2[0,*])  ;output bins in new matrix2

map = replicate( {i0:0L,n:0L, frac:ptr_new()}, n2)

;fill the column with the fraction from the edge2 bins that falls into
;this edge1(*,i) bin.
col  = fltarr(n1)
for i=0l,n2-1 do begin ;change to longword

    test = reform(( (edge1[0,*] ge edge2[1,i]) or (edge1[1,*] le edge2[0,i]) ))

    col[0] = 1-test
    wz  = where( test eq 0, nz) ;those channels which fall in this range
    if nz eq 1 then $
      col[wz[0]]= f_div( we2[i], we1[wz[0]]) $
      else if nz gt 1 then begin
       i1  = wz[0]   ;first channel in range
       i2  = wz[nz-1]    ;last channel in range
       col[i1] = f_div( edge1[1,i1] - edge2[0,i], we1[i1])
       col[i2] = 1.0 - f_div(edge1[1,i2] - edge2[1,i], we1[i2])
      endif
      wnz = where( col ne 0., nz)
      if nz ge 1 then begin
       map[i].n = nz eq 1 ? 1 : wnz[nz-1] - wnz[0] +1
       map[i].i0 = wnz[0]
       temp= nz eq 1 ? col[wnz[0]] : col[wnz[0]:wnz[0]+map[i].n-1]
       map[i].frac = ptr_new(temp)

       endif

endfor

edge1=in_edge1
edge2=in_edge2
return,map
end

;+
;Name: SSW_REBIN
;
;Purpose: Performs the rebinning using coefficient structure
;   obtained from ssw_rebin_assign
;
;History: 11-aug-03, richard.schwartz@gsfc.nasa.gov
;-

function ssw_rebin, mp, v1
n= n_elements( mp )
m= (size(v1,/str)).dimensions[1]>1
;was - out = v1[0] + fltarr(n,m)
out = v1[0]*0.0 + fltarr(n,m)

for i=0L,n-1 do begin
    s = mp[i]
    if s.n ge 1 then $
    out[i,*] = s.n eq 1 ? v1[s.i0,*] * *s.frac : $
    m eq 1 ? total( v1[s.i0:s.i0+s.n-1] * *s.frac) : $
    total( v1[s.i0:s.i0+s.n-1,*] ## *s.frac, 1)
    endfor
return, out
end


;+
; PROJECT: SSW
; NAME:   ssw_rebinner.pro
;
; PURPOSE:  Rebin the contents of a spectrum from one set of energy edges
;             to another.  This simple algorithm assumes the counts in
;             each INPUT channel are UNIFORMLY distributed within that
;             channel.
;
; CATEGORY:  Math
;
; CALLING SEQUENCE:
;
;     ssw_rebinner, specin, edgesin, specout, edgesout
;
; INPUTS:
;
;     specin   Input spectrum
;     edgesin  Energy values of channel edges for input spectrum
;     edgesout Energy values of channel edges for desired spectrum
;
; OUTPUTS:
;
;     specout  Spectrum values rebinned from one set of channel
;                boundaries to the other
;
; CALLS:
;
;     edge_products
; Common Blocks:
;   ssw_REBINNER - holds coefficient arrays and test values

;
; MODIFICATION HISTORY:
;

; 10-aug-03, richard.schwartz@gsfc.nasa.gov
;   saves conversion coefficients.  Frequently reused conversions
;   coefficients saved in both directions.
;-
pro ssw_rebinner, specin, edgesin, specout, edgesout, dbl=dbl

common ssw_rebinner, c_edgesin, c_edgesout, kin, kout, mp0, mp1

;Have the rebin matrices been computed already
nin = n_elements( edgesin )
nout = n_elements( edgesout )
is0 = 0
is1 = 0
default,kin,0
default,kout,0


if nin eq kin then begin
    is0 = total( abs(edgesin-c_edgesin)) eq 0
    if is0 then is0 = total( abs(edgesout-c_edgesout)) eq 0
    endif

if not is0 then if nin eq kout then begin
    is1 = total( abs(edgesin-c_edgesout)) eq 0
    if is1 then is1 = total( abs(edgesout-c_edgesin)) eq 0
    endif


if not is0 and not is1 then begin
    c_edgesin = edgesin
    c_edgesout = edgesout
    kin = nin
    kout = nout
    scale = keyword_set( dbl ) ? 1.0d0 : 1.0
    if n_elements(mp0) ge 1 then heap_free,mp0
    if n_elements(mp1) ge 1 then heap_free,mp1
    mp0 = ssw_rebin_assign( edgesin*scale, edgesout*scale)
    mp1 = ssw_rebin_assign( edgesout*scale, edgesin*scale)
    is0 = 1
    endif


specout = is0 ? ssw_rebin( mp0, specin) : ssw_rebin(mp1, specin)
end