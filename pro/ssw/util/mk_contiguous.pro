;+
;
;   PROJECT:
;    SSW/XRAY
;	Name:
;	 MK_CONTIGUOUS
;
;  PURPOSE:
;    This routine checks that a set input EDGES are dimensioned 2xN and
;	 that the hi and lo edges match for adjacent channels.  If they don't match,
;	 it produces a set of new edge bins, CEDGES, that are contiguous.  Finally,
;	 it also creates a set of indices, INDX, that have this relationship,
;		EDGES = CEDGES[*,INDX]
;  CALLING SEQUENCE:
;    mk_contiguous, edges, cedges, old_index, test=test, epsilon=epsilon
;
;  INPUTS:
;	EDGES - 2xN	edges to test if they hi and lo edges of each bin are
;		contiguous to the neighboring bins.
;	EPSILON - optional keyword, default value of 1e-5. Fractional criterion
;		to determine whether edges[1, i] eq edges[0,i+1], so the test of
;		equality is abs(edges[1,i]-edges[0,i+1]) le epsilon*edges[1,i]
;
;
;  OUTPUTS:
;	CEDGES - new contiguous 2x(N+m) edges if needed
;	INDX - indices that map the new CEDGES into the EDGES, i.e. EDGES = CEDGES[INDX]
;	TEST - returns 0 or 1, If 1, cedges aren't needed and aren't created,
;		original EDGES are contiguous
;

;  RESTRICTIONS:


;  MODIFICATION HISTORY:
;	29-Mar-2006, richard.schwartz@gsfc.nasa.gov
;	25-aug-2006, ras, forms contiguous edges using get_edges(/cont)
;	30-Aug-2006, Kim. Correct 25-aug mod - use /edges_2, and epsilon misspelled
;
;-

;-
pro mk_contiguous, edges, cedges, indx, test=test, epsilon=epsilon

default, epsilon, 1e-5
;test edges to see if contiguous
test = 0
sz = size(/dim, edges)
vtest = (sz[0] eq 2) or (product(sz) eq 2) and (n_elements(sz) le 2)
if vtest eq 0 then begin
	error_message= 'EDGES must have 2 elements or be 2xN'
	goto, error_return
	endif

test  = 1
if product(sz) eq 2 then return ;No Gaps
cont  = where( abs(edges[1,*]-edges[0,1:*]) lt epsilon*edges[1,*], ncont)
if (ncont+1) eq product(sz)/2 then return ;No Gaps
test = 0

;Make a contiguous set
cedges = get_edges(/contig,epsilon=epsilon, edges[*], /edges_2)
ilow   = value_locate( edges[0,*]*(1.-epsilon), cedges[0,*])

indx   = where( abs(edges[0,ilow]-cedges[0,*]) le epsilon*edges[0,ilow])


return
error_return:
	test = 0
	message, /info, error_message
end

