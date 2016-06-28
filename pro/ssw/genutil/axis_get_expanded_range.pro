;---------------------------------------------------------------------------
; Document name: axis_get_expanded_range.pro
; Time-stamp: <Mon Dec 04 2006 16:56:04 csillag auriga.ethz.ch>
;---------------------------------------------------------------------------
;+
; PROJECT:
;       HESSI/FASR/PHOENIX
;
; NAME:
;       axis_get_expanded_range()
;
; PURPOSE:
;       This function calculates returns the actual range that an
;       image will take on the screen. we call this
; the expanded range. This takes into acct that each pixel in the original image
; might occupy more than a single pixel on the screen or paper. We also get the limits
; (which are the indices) of the axes that will be actually plotted. This is
; needed when a range is specified.
;
; CATEGORY:
;       genutil
;
; CALLING SEQUENCE:
;       result = axis_get_expanded_range( axis, log = log, range = range,
;                                         crange = crange, limit = limit )
;
; INPUTS:
;       axis:
;       log
;       range:
;       crange:
;
; OUTPUTS:
;       result: a 2-element vector that contains the range taken by the image
;       axis on the screen
;
; EXAMPLES:
;
; SEE ALSO:
;       axis_get_edges
;
; HISTORY:
;       dec 2006 --- adapt the documentation header
;       january 2006 --- refactored from axis_get_edges
;       january 2006 --- doc updated andre.csillaghy@fhnw.ch
;       june 2004 --- acs, csillag@fh-aargau.ch created
;--------------------------------------------------------------------------


function axis_get_expanded_range, axis, log=log, range=range, crange = crange, limit = limit

checkvar, log, 0
checkvar, range, [0,0]
checkvar, crange, [0,0]

; first get the axis edges, i.e. expand the first and last edges to guessed bin values
edges = axis_get_edges( axis )

; now check out in this array for the limits:
if valid_range( range ) then begin 

    n_edges = n_elements( edges )
; assume axis grows monotonicaly. we search the limits in the edges array
    if n_edges gt 1 then begin 
        limit = ( value_locate( edges, range ) ) > 0 <  (n_elements( axis )-1)
    endif else begin 
; this might not be the last version....
        if range[0] + edges le (range[1]-range[0])/2. then limit = [0]
        if range[1] - edges ge (range[1]-range[0])/2. then limit = append_arr( limit, 1 )
    endelse

    IF limit[0] GT limit[1] THEN limit = limit[[1, 0]]

    expanded_range = [edges[limit[0]],edges[limit[1]+1]]

endif else begin 
    limit = [0, n_elements( axis ) -1]
    expanded_range = [edges[0], last_item(edges)]
endelse

; go tired of trying to avoid this if
crange_local = log? 10^crange : crange
if expanded_range[0] le expanded_range[1] then begin
    expanded_range = expanded_range > crange_local[0] < crange_local[1]
endif else begin
    expanded_range = expanded_range < crange_local[0] > crange_local[1]
endelse


return, expanded_range

end
