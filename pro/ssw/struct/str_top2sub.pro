;+
; Name: str_top2sub
;
; Category: UTIL
;
; Purpose:
; Recreate a nested structure that was de-nested with str_sub2top.
; The delimiter expected for substructures is '$$' between valid
; structure tag names.  Named structures are expected to have '_$_'
; before the name, followed by '_$' and the tag names of the structure.
;
; Calling sequence:  struct = str_top2sub( my_struct )
;
; Input:
; top - structure of interest for re-nesting.
;
; Output:
; structure, or -1 if an error occurred
;
; Input keywords:
;
; Output keywords:
; ERR_MSG - string containing error message.  Null if no errors occurred during
; 	execution.
; ERR_CODE - 0/1 if no error/ an error occurred during execution.
;
; Calls:
; arr2str, trim, uniq, itself for recursion
;
; Written: Paul Bilodeau, RITSS/ NASA-GSFC 1-April-2002
;
; Modification History:
;        9-May-2002, Paul Bilodeau - now recreates named structures.
;	26-Jul-2004, Kim.  When recreating named structures, if there's an error (like
;	  no xxx__define file for that named structure, previously would return -1.  Now
;	  returns the rest of the structure that it could handle - just won't include the
;	  substructures with the error.  No message will be printed - have to look at err_msg
;	  returned.
;	6-Jul-2005, Andre / Kim modifs to make it work with sunstrcutures that contain arrays
;	  as well as corrected a case where it returned -1 instead of the structure
;	8-jan-2008, Kim.  Make it work for array of named structures - now
;	  there's a code in name that tells it how many times to replicate named structure.
;-
;
;------------------------------------------------------------------------------
FUNCTION str_top2sub, top, ERR_MSG=err_msg, ERR_CODE=err_code

err_msg = ''
err_code = 0

;CATCH, err
;IF err NE 0 THEN BEGIN
;    err_code = 1
;    err_msg = !err_string
;    RETURN, -1
;ENDIF

n_top = n_elements( top )
if n_top gt 1 then begin
    dims = size( top, /dim )
    for i=0,n_top-1 do ret_struct = append_arr( ret_struct, str_top2sub(top[i]) )
    return, reform( ret_struct, dims )
endif


IF Size( top, /TYPE ) NE 8 THEN BEGIN
    err_code = 1
    err_msg = 'STR_TOP2SUB: Input must be a structure.'
    RETURN, -1
ENDIF

n_tag = N_Tags( top )
tags = Tag_Names( top )

nest_pos = Strpos( tags, '$$' )

name_pos = Strpos( tags, '_$_' )

must_parse = Where( name_pos GT -1 OR nest_pos GT -1, n_must_parse )

IF n_must_parse EQ 0 THEN RETURN, top


; Only nested tag names OR a named structure can be dealt with at a
; particular level of recursion.
nest_2_reset = Where( $
  nest_pos GT -1 AND $
  name_pos GT -1 AND $
  nest_pos GT name_pos, $
  n_nest_2_reset )

IF n_nest_2_reset GT 0 THEN nest_pos[nest_2_reset] = -1

name_2_reset = Where( $
  name_pos GT -1 AND $
  nest_pos GT -1 AND $
  name_pos GT nest_pos, $
  n_name_2_reset )

IF n_name_2_reset GT 0 THEN name_pos[name_2_reset] = -1

is_name = Where( name_pos GT -1, n_is_name )
IF n_is_name GT 0 THEN BEGIN
    err_code = n_is_name NE n_tag
    IF err_code THEN BEGIN
        err_msg = 'Number of tags in input struct not equal to number of ' + $
          'named structure tags.'
        RETURN, -1
    ENDIF
    n_names = N_Elements( uniq( name_pos, Sort( name_pos ) ) )
    err_code = n_names NE 1
    IF err_code THEN BEGIN
        err_msg = 'Number of structure names is ' + trim( n_names ) + '.'
        RETURN, -1
    ENDIF

;	kim - 20-jul-2007, if starts with Xn then n is number of structures
	nstruct = 1
    if strmid(tags[0], 0, 1) eq 'X' then begin
       first_delim = strpos(tags[0], '_')
       nstruct = fix(strmid(tags[0], 1, first_delim-1))
    endif

    tags = Strmid( tags, name_pos[0]+3 )
    delim_pos = Strpos( tags[0], '_$' )
    struct_name = Strmid( tags[0], 0, delim_pos )
    tags = Strmid( tags, delim_pos+2 )

    ;; Use execute for structure creation to avoid structure
    ;; definition conflicts.
    err_code = 1 - Execute( 'struct = {' + struct_name + '}' )
    IF err_code THEN BEGIN
        err_msg = !err_string
        RETURN, -1
    ENDIF

;	kim - 20-jul-2007 - added
    if nstruct gt 1 then struct = replicate (struct, nstruct)	;kim

    ;; Create the sub-structure.
    this_sub_stc = Create_Struct( tags[0], top.(0) )

    FOR i=1, n_tag-1 DO $
      this_sub_stc = Create_Struct( this_sub_stc, tags[i], top.(i) )

    ;; Recurse to take care of any further nesting or named structures.
    this_sub_stc = str_top2sub( this_sub_stc, ERR_CODE=err_code, $
      ERR_MSG=err_msg )
    IF err_code THEN RETURN, -1

    stc_tags = Tag_Names( struct )
    sub_stc_tags = Tag_Names( this_sub_stc )
    FOR i=0, N_Tags( this_sub_stc )-1 DO BEGIN
        stc_2_this_idx = Where( stc_tags EQ sub_stc_tags[i] )
        struct.( stc_2_this_idx[0] ) = this_sub_stc.(i)
    ENDFOR

    RETURN, struct
ENDIF

FOR i=0, n_must_parse-1 DO BEGIN
    idx = must_parse[i]
    top_tags = append_arr( top_tags, Strmid(tags[idx], 0, nest_pos[idx]) )
    sub_tags = append_arr( sub_tags, Strmid(tags[idx], nest_pos[idx]+2) )
ENDFOR

IF n_must_parse LT n_tag THEN struct = rem_tag( top, tags[must_parse] )

; Map the nested structure tags to their top level names
sub_stc_idx =  uniq( top_tags )
n_sub_stc = N_Elements( sub_stc_idx )

FOR i=0, n_sub_stc-1 DO BEGIN
    ;; Final name of the new sub-structure
    top_tag = top_tags[ sub_stc_idx[ i ] ]

    ;; Indices of sub tags for use.
    top_used = Where( top_tags EQ top_tag, n_used )

    ;; Match locations in the top structure to the location in the
    ;; sub-structure.
    top_2_sub_idx = Where( Strmid(tags, 0, Strlen(top_tag) ) EQ top_tag )

    ;; Create the sub-structure.
    this_sub_stc = Create_Struct( sub_tags[ top_used[0] ], $
      top.( top_2_sub_idx[0] ) )

; acs / kim 2005-07-06 was: n_elements( struct ), that wrongly returned -1 for some cases.
    n_els_in_struct = n_elements( top )

    for k=0, n_els_in_struct-1 do begin

        FOR j=1, n_used-1 DO begin
; acs 2005-06-30 need to handle the special case of n_els_in_struct separately
; because the subscripting in this case could prevent subarrays to be written
; correctly.  perhaps there is a better way to do this?
            value = n_els_in_struct eq 1 ? top.( top_2_sub_idx[j] ) : (top.( top_2_sub_idx[j] ))[k]
;            this_sub_stc = Create_Struct( this_sub_stc, sub_tags[ top_used[j] ], $
;                                              (top.( top_2_sub_idx[j] ))[k] )
            this_sub_stc = Create_Struct( this_sub_stc, sub_tags[ top_used[j] ], value )

        endfor

    ;; Recurse to take care of any further nesting.
        this_sub_stc = str_top2sub( this_sub_stc, ERR_CODE=err_code, $
                                    ERR_MSG=err_msg )
        IF not err_code THEN begin

            if k eq 0 then begin
                IF N_Elements( struct ) GT 0 THEN begin
                    struct = add_tag( struct, this_sub_stc, top_tag )
                endif ELSE begin
                    struct = Create_Struct( top_tag, this_sub_stc )
                endelse
                tag_pos = where( tag_names( struct ) eq top_tag )
            endif else begin
                help, this_sub_stc
                struct[k].(tag_pos) = this_sub_stc
            endelse

        ENDIF else err_msg = 'Structure is incomplete.  ' + err_msg

    endfor
ENDFOR

RETURN, n_elements(struct) gt 0 ? struct : -1

END
