;+
; Project     : HESSI
;
; Name        : WHERE_WITHIN
;
; Purpose     : WHERE function for intervals
;
; Category    : Utility
;
; Explanation :
;
; Syntax      : IDL> ok=where_within(range, valid_range [, bad_count=bad_count, bad_ind=bad_ind] )
;
; Inputs      : range - 2xn array of interval start/end values
;               valid_range - 2-element array of start/end values to check range against
;
; Opt. Inputs : None
;
; Outputs     : Returns indices of input range array that are contained within valid_range
;               count - number of values of range that are within valid_range
;
; Opt. Output Keywords:
;               bad_count - Number of elements of range that don't fall within valid_range
;               bad_ind - Indices of range that don't fall within valid_range
;
; Common      : None
;
; Restrictions: Input range must be [2xn], valid_range must be 2-element array.
;
; Side effects: None
;
; History     : 25-Aug-2001, Kim Tolbert
;				20-Mar-2006, Richard.Schwartz@gsfc.nasa.gov
;				allow range to be dimensioned 2xN or Nx2
;				1-Nov-2006, richard.schwartz@gsfc.nasa.gov
;					make dimrange (dimensions of inrange) more robust by
;					forcing two dimensions.  Use dimrange for the
;					n_elements(inrange[...]), replace bindgen with lindgen
;				1-Nov-2006, Kim.  Added count argument
;
; Contact     : kim.tolbert@gsfc.nasa.gov
;-


function where_within, range, valid_range, count, bad_count=bad_count, bad_ind=bad_ind

count = 0
bad_count = 0
bad_ind = -1

inrange = range
;allow range to have 2 elements along either axis
dimrange = lonarr(2)+1
dimrange[0] = size(/dim, inrange)
case 1 of
	(n_elements(dimrange) eq 1) and (dimrange[0] eq 2):
	(dimrange[1] eq 2) and (dimrange[0] ne 2): begin
		inrange = transpose(inrange)
		dimrange= transpose(dimrange)
		end
	else:
endcase
if dimrange[0] ne 2  then begin
	message,'Range to check must be [2,n] array', /cont
	return, -1
endif

if n_elements(valid_range) ne 2 then begin
	message,'Valid range must be 2-element array', /cont
	return, -1
endif

nint = dimrange[1]

bad_ind = where  (inrange[0,*] lt valid_range[0] or $
			inrange[0,*] gt valid_range[1] or $
			inrange[1,*] lt valid_range[0] or $
			inrange[1,*] gt valid_range[1], bad_count)

if bad_count eq nint then return, -1

ret = lindgen(nint)
count = nint - bad_count

if bad_count eq 0 then return, ret else return, rem_elem(ret, bad_ind)

end