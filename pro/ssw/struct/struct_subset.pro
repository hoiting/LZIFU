;+
; Name: struct_subset
;
; Category: UTIL
;
; Purpose:
; Create a structure with a subset of given tags from an input structure.
;
; Calling sequence:  
; struct = struct_subset( struct, tags_to_keep )
; struct = struct_subset( struct, tags_to_remove, /EXCLUDE )
;
; Input:
; input - structure of interest
;
; Output:
; structure with specified tags, -1 if there are no tags that meet the
; given criteria, or -1 if an error occurred
;
; Input keywords:
; EXCLUDE - set this if result should be structure with all tags
;           _except_ those input.
;
; Output keywords:
; ERR_MSG - string containing error message.  Null if no errors occurred during
; 	execution.
; ERR_CODE - [0/1] if [no error / an error] occurred during execution.
; STATUS - [0/1] if a structure is returned.  Indicates that some of
;          the input structure tags met the given criterion. 
; QUIET - Set if no error messages should be printed.
;
; Calls:
; is_string, is_struct, where_arr
;
; Written: Paul Bilodeau, RITSS/ NASA-GSFC 1-April-2002
;-
;------------------------------------------------------------------------------
FUNCTION struct_subset, input, $
                        tags, $
                        EXCLUDE=exclude, $
                        ERR_MSG=err_msg, $
                        ERR_CODE=err_code, $
                        STATUS=status, $
                        QUIET=quiet

loud = 1 - Keyword_Set( quiet )
err_msg = ''
err_code = 0
status = 0

IF NOT( is_struct( input ) ) THEN BEGIN
    err_code = 1
    err_msg = 'INPUT must be a structure.'
    IF loud THEN MESSAGE, err_msg, /CONTINUE
    RETURN, -1
ENDIF

IF NOT( is_string( tags ) ) THEN BEGIN
    err_code = 1
    err_msg = 'TAGS must be a string.'
    IF loud THEN MESSAGE, err_msg, /CONTINUE
    RETURN, -1
ENDIF

in_tags = Tag_Names( input )
n_in_tags = N_Tags( input )

which = where_arr( in_tags, Strupcase( tags ), count, $
  NOTEQUAL=Keyword_Set( exclude ) )
IF count EQ 0 THEN RETURN, -1

status = 1

; The requested subset of tag names spans all structure tags.
IF count EQ n_in_tags THEN RETURN, input

output = Create_Struct( in_tags[ which[0] ], input.( which[0] ) )

FOR i=1, count-1 DO $
  output = Create_Struct( output, in_tags[ which[i] ], input.( which[i] ) )

RETURN, output

END
