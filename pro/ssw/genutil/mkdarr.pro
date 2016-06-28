;  (04-Mar-1991)
;
	function mkdarr,a,b,xy=xy
;
;+
; NAME:  MKDARR
; PURPOSE: To make an array having two elements such as:
;		[(a0,b0),(a0,b1),,,(a0,bn),(a1,b0),(a1,b1),,,(a1,bn),,,
;		(am,b0),(am,b1),,,(am,bn)] out of [a0,,,am] and
;		[b0,,,bn], or, with xy switch,
;               [(a0,b0),(a1,b0),,,(am,b0),(a0,b1),(a1,b1),,,(am,b1),,,
;               (a0,bn),(a1,bn),,,(am,bn)] out of [a0,,,am] and [b0,,,bn].
; CATEGORY:
; CALLING SEQUENCE: c = mkdarr(a,b)
; INPUTS: a = arbitraty 1-d array.
;	  b = arbitraty 1-d array.
; OPTIONAL INPUTS: none.
; OUTPUTS: result = c = two-element array [(a0,b0),(a0,b1),...,(a0,bn),
;		    (a1,b0),(a1,b1),...,(a1,bn),...(am,b0),(am,b1),
;		    ....,(am,bn)] or, with xy switch [(a0,b0),,,(am,bn),
;                   ,,,,(a0,bn),,,(am,bn)].
; OPTIONAL OUTPUTS: none.
; COMMON BLOCKS: none.
; SIDE EFFECTS: none.
; RESTRICTIONS: none.
; MODIFICATIONS: written by N.Nitta, March 1991.
;                modified to handle scalar inputs and the order of the
;		 inputs, by NN, March 1992

;-
;
; copy the original inputs in case they be modified (see below)
   aa=a
   bb=b

; check if either of the arguments is a scalar
   sa=size(aa)
   sb=size(bb)
   if sa(0) eq 0 then begin
      aaa=[aa,aa]
      aaaa=reform(aaa,1,2)
      aa=aaaa(*,0)
   endif
   if sb(0) eq 0 then begin
      bbb=[bb,bb]
      bbbb=reform(bbb,1,2)
      bb=bbbb(*,0)
   endif


   if not keyword_set(xy) then begin
	a1=reform(rotate(rebin(aa,n_elements(aa),n_elements(bb)),1),1, $
		n_elements(aa)*n_elements(bb))
	b1=reform(rebin(bb,n_elements(bb),n_elements(aa)),1,	$
		n_elements(aa)*n_elements(bb))
    endif else begin
        a1=reform(rebin(aa,n_elements(aa),n_elements(bb)),1,       $
                n_elements(aa)*n_elements(bb))
        b1=reform(rotate(rebin(bb,n_elements(bb),n_elements(aa)),1),1, $
                n_elements(aa)*n_elements(bb))
    endelse

;	print,a,b,a1,b1
    c=[[a1,b1]]
    return,c
    end
