;---------------------------------------------------------------------------
; Document name: axis_get_edges.pro
; Time-stamp: <Thu Jan 05 2006 10:55:13 csillag tournesol.local>
;---------------------------------------------------------------------------
;+
; PROJECT:
;       HESSI/FASR/PHOENIX
;
; NAME:
;       axis_get_edges()
;
; PURPOSE:
;       This procedure is an addition to get_edge_products.
;       Given a vector of mean values, it first computes the edges of the
;       vector values passed. In addition, it assumes that the values passed correspond
;       to the mean values of an axis. It thus "guesses" the edges of the first and last axis.
;
; CATEGORY:
;       gen/utilities
;
; CALLING SEQUENCE:
;       result = axis_get_edges( mean, edges = edges )
;
; INPUTS:
;       mean: a n-element vector of mean values (assumed to be an axis)
;
; OUTPUTS:
;       result: an n+1-element vector of (axis) edges
;
; EXAMPLES:
;       print, axis_get_edges( indgen(4) ) 
;       -0.500000     0.500000      1.50000      2.50000      3.50000
;
; SEE ALSO:
;       edge_products, get_edge_products
;
; HISTORY:
;       january 2006 --- doc updated andre.csillaghy@fhnw.ch
;       june 2004 --- acs, csillag@fh-aargau.ch created
;--------------------------------------------------------------------------


function axis_get_edges, mean

; we assume axis contains the mean of the bin values
; thus we need to first transform the axis to allow the bin extension at the beginning
; and at the end of the range

; the mean from the mean are the edges...
edges = get_edge_products( mean, /mean ) 

;.... except for the first and the last ones
; guessing the width of the first and last
if n_elements( edges ) gt 1 then begin 
    width_left = edges[1] - edges[0]
    right_part = last_nelem( edges, 2  )
    width_right = right_part[1] - right_part[0]
    edges = [edges[0]-width_left, edges, last_item( edges ) + width_right ]

; acs 2005-02-22
endif else begin 
    width = edges[0]
    edges = [mean[0]-width, mean[0]+width, mean[1] + width] 
endelse

return, edges

end
