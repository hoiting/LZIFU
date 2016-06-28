	FUNCTION ROWSORT, TARGET, COL0, COL1, ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	ROWSORT
;
; Purpose     :	Sort an array based on the values in two of its columns.
;
; Explanation :	This function returns a vector of subscripts that allow access
;		to the rows of the target array in ascending order.  The sort
;		is based on two columns of the array (the array may have any
;		number of columns) which are specified as parameters to the
;		function.  The result is always a vector of longword type 
;		with the same number elements as row in the target array.  
;
; Use         :	A = ROWSORT (TARGET, Col0, Col1)
;
; Inputs      :	TARGET	The array to be sorted. The array must consist of at
;			least two columns but may contain any number of rows.
;
; Opt. Inputs :	COL0	The primary column to base the sort on.  If two 
;			elements in this column contain the same value, then
;			the sort is based on the corresponding elements in 
;			COL1.
;
;		COL1	The secondary column to peform the search on.
;			Array elements in this column are only consulted when
;			there is a clash between two elements in COL1.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Return Value:	A vector of subscripts which allow access of the target array
;		in ascending order.
;	
;
; Keywords    :	ERRMSG  If defined and passed, then any error messages will
;			be returned to the user in this parameter rather
;			than depending on the MESSAGE routine in IDL.  If 
;			no errors are encountered, then a null string is
;			returned.  In order to use this feature, ERRMSG must
;			be defined first, e.g.
;
;				ERRMSG = ''
;				LIST_EXPER, ERRMSG=ERRMSG, ...
;				IF ERRMSG NE '' THEN ...
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	The algorithm used by this function is very inefficient and 
;		should not be used on arrays with more then 100000 rows.
;
; Side effects:	None.
;
; Category    :	Planning, Database.
;
; Prev. Hist. :	none.
;
; Written     :	Ron Yurow, GSFC, 11 September 1997
;
; Modified    :	Version 1, Ron Yurow, GSFC, 17 September 1997
;
; Version     :	Version 1, 17 September 1997
;-
;

	ON_ERROR, 2

;
; Check the number of parameters.
;

        IF N_PARAMS() LT 3 THEN BEGIN
           MESSAGE = 'Syntax: A = ROWSORT (TARGET, Col0, Col1)'
	   GOTO, HANDLE_ERROR
        ENDIF

; 
; Set S to a vector of subscripts which allow the access to elements of 
; column COL0 of the array TARGET in ascending order.
;

	S = SORT (TARGET (COL0, *))

;
; Set U to a vector of subscripts which allow access to the unique elements
; in column COL0 of the array TARGEGT. 
;

	U = S (UNIQ (TARGET (COL0, S)))

;
; Set U to the unique elements of column COL0 of the array TARGET.
;

	UKEY = TARGET (COL0, U)

;
; Set NO_UKEY to the number of unique elements we found in column COL0 of the
; array TARGET.
;

	NO_UKEY = N_ELEMENTS (UKEY)

;
; Loop to construct the vector of subscripts RES which will allow the rows of
; the array TARGET to be sorted in ascending order based on the values in 
; columns COL0 and COL1.  This is done by iterating through every unique 
; element of column COL0 and adding to the vector of subscripts RES, those
; subscripts which will allow the rows of TARGET to be sorted based on the 
; value of the elements of column COL1.  Since the unique elements of column
; COL0 are stored in ascending order in the array UKEY, this results in the 
; correct answer.
;

	FOR I = 0, NO_UKEY - 1 DO BEGIN

;
; Set the array SUB to a vector of subscripts which point to the rows of the 
; array target in which the elements in column COL0 match the ith element in
; the array UKEY.
;

	   SUB = WHERE (TARGET (COL0, S) EQ UKEY (I))

;
; Check if this is our first time through the loop (I = 0).  If it is, then
; we can assume that the array RES does not already exist.
;

	   IF I EQ 0 THEN BEGIN

;
; Set RES to the vector of subscripts that allow access of the rows of the 
; array TARGET such that the elements in COL1 will be in ascending order and
; all the elements in COL0 will be equal to the ith element in the array
; UKEY.
; 

	      RES = S (SUB (SORT (TARGET (COL1, S(SUB)))))

	   ENDIF ELSE BEGIN

;
; Concatenate the vector of subscripts that allow access of the rows of the
; array TARGET such that the elements of COL1 will be in ascending order and
; all the elements in COL0 will be equal to the ith element in the array
; UKEY onto the current contents of the vector RES.
;

	      RES = [RES, S (SUB (SORT (TARGET (COL1, S(SUB)))))]

	   ENDELSE

	ENDFOR

;
; Return the vector of subscripts, RES.  Were Done !!
;

	RETURN, RES

;
;  Error handling point.
;

HANDLE_ERROR:
	IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = 'ROWSORT: ' + MESSAGE $
		ELSE MESSAGE, MESSAGE, /CONTINUE
	RETURN, 0

	END