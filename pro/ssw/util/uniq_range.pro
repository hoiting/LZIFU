; $Id: uniq.pro,v 1.11 2004/01/21 15:55:04 scottm Exp $
;
; Copyright (c) 1988-2004, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.

;+
; NAME:
;	UNIQ_RANGE
;
; PURPOSE:
;	Return the subscripts of the unique elements in a 2xN array.
;
;	Note that repeated elements must be adjacent in order to be
;	found.  This routine is intended to be used with the ROWSORT
;	function.  See the discussion of the IDX argument below.
;
;	This command is an extension of the UNIQ in the IDL library.
;
; CATEGORY:
;	Array manipulation.
;
; CALLING SEQUENCE:
;	UNIQ(Array [, Idx])
;
; INPUTS:
;	Array:	The 2xN array to be scanned.  The type and number of dimensions
;		(as long as 2xN) of the array are not important.  The array must be sorted
;		into monotonic order by both columns unless the optional parameter Idx is
;		supplied.
;
; OPTIONAL INPUT PARAMETERS:
;	IDX:	This optional parameter is an array of indices into Array
;		that order the elements into monotonic order (by first column,
;       and by second column when two items in first column are equal).
;		That is, the expression:
;
;			Array(*,Idx)
;
;		yields an array in which the elements of Array are
;		rearranged into monotonic order.  If the array is not
;		already in monotonic order, use the command:
;
;			UNIQ(Array, ROWSORT(Array,0,1))
;
;		The expression below finds the unique elements of an unsorted
;		array:
;
;			Array(*,UNIQ_RANGE(Array, ROWSORT(Array,0,1)))
;
; OUTPUTS:
;	An array of indicies into ARRAY is returned.  The expression:
;
;		ARRAY(*,UNIQ_RANGE(ARRAY))
;
;	will be a copy of the sorted Array with duplicate adjacent
;	elements removed.
;
; EXAMPLE:
;   a = [ [0,1], [2,3], [0,1], [0,2], [0,1], [2,4] ]
;   print, a[*,uniq_range(a,rowsort(a,0,1))]
;       0       1
;       0       2
;       2       3
;       2       4
;
; COMMON BLOCKS:
;	None.
;
; MODIFICATION HISTORY:
;	1988, AB, Written.
;	29 July 1992, ACY - Corrected for case of all elements the same.
;	Nov, 1995.  DMS, Return a 0 if argument is a scalar.
;	11-Jan-2005, Kim Tolbert.  Extended uniq function to uniq_range to work for 2xn array
;
;-
;

function UNIQ_RANGE, ARRAY, IDX

; Check the arguments.
  s = size(ARRAY)
  if (s[0] lt 2) then return, 0		;A scalar or not 2xn
  if n_params() ge 2 then begin		;IDX supplied?
     q0 = array[0,idx]
     q1 = array[1,idx]
     indices = where( (q0 ne shift(q0,-1)) or $
                      (q1 ne shift(q1,-1)), count)
     if (count GT 0) then return, idx[indices] $
     else return, n_elements(q0[0,*])-1
  endif else begin
     indices = where( (array[0,*] ne shift(array[0,*], -1)) or $
                      (array[1,*] ne shift(array[1,*], -1)), count)
     if (count GT 0) then return, indices $
     else return, n_elements(ARRAY)-1
  endelse
end
