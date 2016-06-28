;============================================================================
;+
; PROJECT:  HESSI
;
; NAME:  find_contig_ranges
;
; PURPOSE:  Compress a set of ranges to leave only the non-contiguous ranges.
;	Example:  If vals equals the following intarr(2,3):
;	[2,4]
;	[4,8]
;	[10,12]
;	[12,14]
;	then result=find_contig_ranges(vals) would return:
;	[2,8]
;	[10,14]
;
; CATEGORY: UTIL
;
; CALLING SEQUENCE:  result = find_contig_ranges(vals)
;
; INPUTS:  none
;
; OPTIONAL INPUTS (KEYWORDS):
;	EPSILON - If end of interval is within epsilon of start of next interval,
;	  they're considered contiguous.
;
;
; OUTPUTS:  2xn array of noncontiguous ranges.  If input array is not (2,n) then
;	returns -1.
;
; OPTIONAL OUTPUTS:  None
;
; Calls:
;
; COMMON BLOCKS: None
;
; PROCEDURE:
;
; RESTRICTIONS: Assumes vals array is monotonically increasing
;
; SIDE EFFECTS: None.
;
; EXAMPLES:
;
; HISTORY:
;	Written Kim, 30-Apr-2001
;	Modifications:
;	29-Jul-2003, Added epsilon keyword.
;	15-Mar-2006, Correct epsilon check - difference should be divided by magnitude of numbers
;	  and changed epsilon default to 1.e-7
;	16-Mar-2006, Kim.  Correct again.  For integers just check difference, for non-integers,
;	  check difference divided by magnitude.
;-
;============================================================================

function find_contig_ranges, vals, epsilon=epsilon

ranges = -1

if (size(vals, /dimen))[0] eq 2 then begin

	nvals = n_elements(vals[0,*])

	if nvals eq 1 then return, vals

	type = size(vals, /type)
	; If integers, (type <4 and > 11), just check difference
	if type lt 4 or type gt 11 then begin
		checkvar, epsilon, 0.
		q = where ( (vals[0,1:*] - vals[1,*]) gt epsilon, count)
	endif else begin
		checkvar, epsilon, 1.e-7
		q = where ( (vals[0,1:*] - vals[1,*])/vals[1,*] gt epsilon, count)
	endelse

	if count gt 0 then begin
		qs = [0,q+1]
		qe = [q,nvals-1]

		ranges = bytarr(2,count+1) * vals[0] ; just to get the right data type

		ranges[0,*] = vals[0,qs]
		ranges[1,*] = vals[1,qe]

	endif else ranges = [vals[0,0], vals[1,nvals-1]]

endif

return,ranges

end

