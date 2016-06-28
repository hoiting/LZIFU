;+
; Name: str_sub2top
;
; Category: UTIL
;
; Purpose:
; Move all structure tags to the top level, removing pointers and object
; references while recursing on nested structures.  Nested structure fields
; are moved to the top-level with their names appended to the parent structure
; name with a '$$' as a separator.  Named structures have their name,
; prepended by '_$_', used as the prefix for their tags.
;
; Calling sequence:  top_struct = str_sub2top( my_struct )
;
; Input:
; struct - structure of interest for de-nesting
;
; Output:
; top-level structure, or -1 if an error occurred
;
; Input keywords:
;
; Output keywords:
; ERR_MSG - string containing error message.  Null if no errors occurred during
;   execution.
; ERR_CODE - 0/1 if no error/ an error occurred during execution.
;
; Calls:
; add_tag, rem_tag, itself for recursion
;
; Written: Paul Bilodeau, RITSS/ NASA-GSFC 16-May-2001
;
; Modification History:
;       9-May-2002,  Paul Bilodeau - now store names of named structures.
;       25-Jun-2002, Paul, Kim - speed up by storing tags to remove, and if test in else
;       23-Jan-2003, Kim - corrected error for named structures by replacing rem_tag and
;                    add_tag with rep_tag_name
;       07-Oct-2004, Andre Csillaghy - Make it work for array of structures.
;       8-jan-2008, Kim - Andre's array of structures didn't work, so I tried again, but mine
;                    only works for named structures. Put Xn in front of
;                    _$_structure_name_$ (where n indicates how many elements in array)
;
;------------------------------------------------------------------------------
FUNCTION str_sub2top, struct, ERR_MSG=err_msg, ERR_CODE=err_code

err_msg = ''
err_code = 1

;CATCH, err
;IF err NE 0 THEN BEGIN
;    err_msg = !err_string
;    RETURN, -1
;ENDIF

IF Size( struct, /TYPE ) NE 8 THEN BEGIN
    err_msg = 'STR_SUB2TOP: Input must be a structure.'
    RETURN, -1
ENDIF

; kim commented out following block 20-jul-2007
; i giv up trying making it work for array of structures - andre
;n_struct = n_elements( struct )
;if n_struct gt 1 then begin
;    dims = size( struct, /dim )
;    for i=0,n_struct-1 do ret_struct = append_arr( ret_struct, str_sub2top(struct[i], $
;                                                                           err_msg = err_msg, $
;                                                                           err_code = err_code) )
;    return, reform( ret_struct, dims )
;endif

n_tag = N_Tags( struct )
struct_tags = Tag_Names( struct )
struct_name = Tag_Names( struct, /STRUCTURE_NAME )
nstruct = n_elements(struct)

; kim - added xn number in front of _$_struct_name_$ where n is the number elements of struct
tags = struct_name NE '' ? $
  ((nstruct eq 1) ? '' : 'x'+trim(nstruct)) +'_$_' +  struct_name + '_$' + struct_tags : $
  struct_tags

out_struct = struct

tags2remove = ''

FOR i=n_tag-1, 0, -1 DO BEGIN
    struct_sub_type = Size( struct.(i), /TYPE )
    CASE struct_sub_type OF
        8: BEGIN
            ;; substructure - recurse to extract information
            sub = str_sub2top( struct.(i), ERR_MSG=err_msg, ERR_CODE=err_code )
            IF err_code THEN RETURN, -1
            out_struct = rem_tag( out_struct, struct_tags[i] )
            IF Size( sub, /TYPE ) EQ 8 THEN BEGIN
                sub_tags = Tag_Names( sub )
                FOR j=0L, N_Tags( sub )-1L DO begin
                    new_tag_name =  tags[i]+'$$'+sub_tags[j]
                    out_struct = add_tag( out_struct, sub.(j), new_tag_name )
                endfor
            ENDIF
        END
        10: tags2remove = append_arr( tags2remove, struct_tags[i] )
        11: tags2remove = append_arr( tags2remove, struct_tags[i] )
        ELSE: IF struct_name NE '' then out_struct = rep_tag_name(out_struct, struct_tags[i], tags[i])
    ENDCASE
ENDFOR

IF N_Elements( tags2remove ) GT 1 THEN $
  out_struct = rem_tag( out_struct, tags2remove )

err_code = 0

RETURN, out_struct

END
