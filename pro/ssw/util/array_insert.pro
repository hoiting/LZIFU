;+
;NAME: array_insert
;PURPOSE: Insert an array into another array at a specified point.
;   Output array is dimension of original plus inserted array.
;   If arr_a is 1-D, arr_b must be 1-D and will be inserted at element 'index'.
;   If arr_a is 2-D, arr_b can be 1-D or 2-D:
;     if arr_b is 1-D, the same elements are inserted into every row of arr_a
;     if arr_b is 2-D, the second dimension must match the second dimension of arr_a
;
;INPUT:
;  arr_a - destination array
;  arr_b - array to insert
;  index - column # in arr_a to place arr_b into
;
;OUTPUT: array of combined arrays. Returns -1 if error.

;EXAMPLES:
; 1. arr_a and arr_b are 1-D
;  print, array_insert (indgen(6), indgen(3), 4)
;       0       1       2       3       0       1       2       4       5
; 2. arr_a is 2-D and arr_b is 1-D
;  print, array_insert (indgen(2,3), [33,34], 1)
;       0      33      34       1
;       2      33      34       3
;       4      33      34       5
; 3. arr_a and arr_b are 2-D.
; print, array_insert (indgen(2,3), transpose([33,34,35]), 1) ; arr_b is 1x3
;       0      33       1
;       2      34       3
;       4      35       5
;
; Restrictions:  Can't handle higher dimensions than 2-D arrays

;HISTORY:
;	Written 5-May-2006, Kim Tolbert
;	8-Nov-2006, Kim.  Use reproduce instead of rebin, so it will work on strings too.
;-

function array_insert, arr_a, arr_b, index

if n_params() lt 2 then begin
	message,'Incorrect arguments.  Usage: a=array_insert(array1, array2 [, index] )', /cont
	return, -1
endif

checkvar, index, 0

a_ndim = size(arr_a, /n_dim)
b_ndim = size(arr_b, /n_dim)

if a_ndim gt 2 or b_ndim gt 2 then begin
	message, 'Error. Can not handle > 2D arrays.', /cont
	return, -1
endif

sa = size(arr_a, /dim)
a_dim1 = sa[0]
a_dim2 = a_ndim le 1 ? 1 : sa[1]


sb = size(arr_b, /dim)
b_dim1 = sb[0] > 1
b_dim2 = b_ndim le 1 ? 0 : sb[1]

if b_ndim gt 1 and (b_dim2 ne a_dim2) then begin
	message, 'Error.  Second dimension of destination array and array to insert must match.', /cont
	return, -1
endif

do_rebin = a_dim2 ne b_dim2

;if index eq 0 then return, [ (do_rebin ? rebin(arr_b[*],b_dim1,a_dim2) : arr_b), arr_a]

;if index ge a_dim1 then return, [ arr_a, (do_rebin ? rebin(arr_b[*],b_dim1,a_dim2) : arr_b) ]

;return, [ arr_a[0:index-1,*], (do_rebin ? rebin(arr_b[*],b_dim1,a_dim2) : arr_b), arr_a[index:*,*] ]

if index eq 0 then return, [ (do_rebin ? reproduce(arr_b[*],a_dim2) : arr_b), arr_a]

if index ge a_dim1 then return, [ arr_a, (do_rebin ? reproduce(arr_b[*],a_dim2) : arr_b) ]

return, [ arr_a[0:index-1,*], (do_rebin ? reproduce(arr_b[*],a_dim2) : arr_b), arr_a[index:*,*] ]


end