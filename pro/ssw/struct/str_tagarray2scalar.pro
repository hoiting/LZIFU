;---------------------------------------------------------------------------
; Document name: str_tagarray2scalar
; Time-stamp: <Wed Mar 09 2005 10:19:36 csillag darksun>
;---------------------------------------------------------------------------
;
;+
;NAME:
;   str_tagarray2scalar
;
;PROJECT:
;   PHOENIX
;
;CATEGORY:
;   Structure handling
;
;PURPOSE:
;   Transforms a structure that contains tag arrays into a structure
;   that contains tag scalar, for a specific index value. 
;
;   This is useful to extract values for keyword parameters catched
;   within the _extra structure. See examples.
;
;CALLING SEQUENCE:
;   scalar_struct = str_tagarray2scalar(array_struct, index)
;
;INPUT:
;   array_struct: a structure containing tag arrays
;   index: the index in the array to extract the scalar
;
;KEYWORDS:
;   none yet
;
;EXAMPLE:
;   extra = {first_keyword: [0,1,2,3,4], $
;            second_keyword: [7,5,4,3,2], $
;            third_keyword: 1}
; 
;   help, str_tagarray2scalar( extra, 3 ), /str
;** Structure <84c258c>, 3 tags, length=6, data length=6, refs=1:
;   FIRST_KEYWORD   INT              3
;   SECOND_KEYWORD  INT              3
;   THIRD_KEYEORD   INT              1
;
;HISTORY:
;        acs march 2005 - extracte from spectro_plot weher it was usted internally
;--------------------------------------------------------------------------------

function str_tagarray2scalar, struct, idx
; extracts a value from array tags in a structure  and checks for last element too

ntags = n_tags( struct )
struct_out = struct
for i = 0, ntags -1 do begin 

    array = struct.(i)
    array_siz = size( array, /struct )

    if array_siz.n_dimensions le 1 then begin
        arr_el= array[idx < (array_siz.n_elements-1)]
    endif else begin
        if array_siz.dimensions[1] GT 1 THEN BEGIN
            arr_el = array[*, idx < (array_siz.dimensions[1]-1)]
        ENDIF ELSE BEGIN
            arr_el = array
        ENDELSE
    endelse

    struct_out = rep_tag_value( struct_out, arr_el, i )
    
endfor

return, struct_out

end
