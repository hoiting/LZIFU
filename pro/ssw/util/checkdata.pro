;+
; Name: checkdata
;
; Category: UTIL
;
; Purpose: Check an input against a specified set of properties.  This allows
; 	an input to be matched against several criteria, such as: is it a float/
; 	double array with 128-133 elements?
;
; Calling sequence:
; 	data_is_ok = checkdata( data, TYPE=[4,5], N_ELEM=Lindgen(5)+128 )
;
; Inputs:
; 	data - item of interest.
;
; Outputs:
;	0 / 1 if the data did not / did meet the specified criteria.
;
; Input keywords:
; 	The test on the following criteria will evaluate to true if the
; 	data meets ONE of the criteria:
; 	TYPE - array containing possible specified IDL type codes for the data.
; 	N_ELEM - array containing specified number of elements of data.
; 	N_DIMEN - array containing specified number of dimensions of data.
; 	STRUCT_NAME - specified name of data structure.
;
;	These keywords are different from the above in that the data must perfectly
; 	match all values within each of these criteria.  Thus, to return true, the
; 	data must have ALL specified structure tag names.
; 	DIMEN - array containing specified dimensions of data.
; 	TAG_NAME - specified tag names of data structure
;
; Output keywords:
;
; Calls:
;	required_tags
;
; Written: Paul Bilodeau, RITSS / NASA-GSFC, 18-May-2001
;-
;-------------------------------------------------------------------------------
FUNCTION checkdata, data, TYPE=type, N_ELEM=n_elem, N_DIMEN=n_dimen,  $
	DIMEN=dimen, STRUCT_NAME=struct_name, TAG_NAME=tag_name

CATCH, err
IF err NE 0 THEN RETURN, 0

IF N_Params() NE 1L THEN RETURN, 0

num_type = N_Elements( type )
num_n_elem = N_Elements( n_elem )
num_n_dimen = N_Elements( n_dimen )
num_dimen = N_Elements( dimen )
num_struct_name = N_Elements( struct_name )
num_tag_name = N_Elements( tag_name )

retval = num_type GT 0L OR num_n_elem GT 0L OR $
	num_n_dimen GT 0L OR num_dimen  GT 0L OR $
	num_struct_name GT 0L OR num_tag_name GT 0L

s = Size( data, /STRUCTURE )

IF num_type GT 0L THEN BEGIN
	match = Where( type EQ s.type, n_match )
	retval = retval AND ( n_match GT 0L )
ENDIF

IF num_n_elem GT 0L THEN BEGIN
	match = Where( n_elem EQ s.n_elements, n_match )
	retval = retval AND ( n_match GT 0L )
ENDIF

IF num_n_dimen GT 0L THEN BEGIN
	match = Where( n_dimen EQ s.n_dimensions, n_match )
	retval = retval AND n_match GT 0L
ENDIF

IF num_dimen GT 0L THEN BEGIN
	dimen_ret = 0
	IF num_dimen LE 8L THEN BEGIN
		data_dimen = s.dimensions
		data_dimen = data_dimen[0:num_dimen-1L]
		dimen_ret = data_dimen EQ dimen
		dimen_ret = Total( dimen_ret ) EQ num_dimen
	ENDIF
	retval = retval AND dimen_ret
ENDIF

IF num_struct_name GT 0L THEN BEGIN
	struct_name_ret = 0
	IF s.type EQ 8L THEN BEGIN
		s_name = Tag_Names( data, /STRUCTURE )
		match = Where( struct_name EQ s_name, n_match )
		struct_name_ret = n_match GT 0L
	ENDIF
	retval = retval AND struct_name_ret
ENDIF

IF num_tag_name GT 0L THEN BEGIN
	tag_name_ret = required_tags( data, tag_name )
	retval = retval AND tag_name_ret
ENDIF

RETURN, retval

END