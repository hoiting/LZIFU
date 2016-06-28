	FUNCTION IS_DIGIT, STR 
;+
; Project     :	SOHO - CDS/SUMER
;
; Name        :	IS_DIGIT
;
; Purpose     :	Determine if a character is a digit [0 - 9].
;
; Explanation :	This function checks every character of a string, or every
;               element of an array passed to it to determine if it is an
;               ASCII digit, that is [0 - 9].  If it is a digit then the 
;               function returns 1 (TRUE) for that element, otherwise the
;               function returns 0 (FALSE).
;
; Use         :	RESULT = IS_DIGIT (STR)
;
;		STR = "7 MARY 3"
;		IF MAX (IS_DIGIT (STR)) THEN PRINT, "String contains a digit" $
;		ELSE PRINT, "String does not contian a digit"
;
;               IDL>String contains a digit
;
;
; Inputs      :	STR	 = String of characters, or an array whose elements
;                          are within the range 0 to 255.  If an earray with
;                          with elements outside this range is passed to the 
;                          to the function, then each element is forced into
;                          this range. e.g. elements less then 0 are 0 and 
;                          elements greater then 255 are changed to 255.
;
; Opt. Inputs :	None.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Result      : a byte array with as many elements as the array or string that
;               was passed to this function in the parameter STR.  Every 
;               element in the resultant array will be set to 1 (TRUE) if the 
;               corresponding element or character is an ascii digit,
;               otherwise it will be set to 0 (FALSE).
;
; Keywords    :	None.
;
; Calls       :	VAR_TYPE.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Planning, science
;
; Prev. Hist. :	This procedure is based on C function of the same name.
;
; Written     :	Ron Yurow, 6 November 1995
;
; Modified    :	Version 1, Ron Yurow, 6 November 1995
;		Version 2, Ron Yurow, 28 February 2003
;		Changed VAR_TYPE to DATATYPE for compatability with SSW.
;
; Version     :	Version 2, 28 February 2003
;-
;
	ON_ERROR, 2
;
;  Check the an input parameter exists.
;
	IF N_PARAMS() EQ 0 THEN RETURN, 0

;  
;  Copy the parameter STR to a temporary variable TSTR.
;

         TSTR = STR


;
;  Check what type of parameter has been passed to the function.  If is 
;  anything but a string or byte array, then force every element of the
;  parameter STR to be in the range 0 <= x <= 255.
;

        TYPE = DATATYPE (TSTR, 2)

        IF TYPE NE 1 AND TYPE NE 7 THEN TSTR = 0 > TSTR < 255


;
;  Check if TSTR is an empty string, if it is then we will just return 0.
;

        IF TYPE EQ 7 THEN IF TSTR EQ "" THEN RETURN, 0


;
;  Check if the input parameter is a byte array, If it is not then convert it 
;  to a byte array.
;

        IF TYPE NE 1 THEN TSTR = BYTE (TSTR)

        
;
;  Set the variables MAX_ASCII_NO and MIN_ASCII_NO to whatever a values a 
;  a number must be between in the ascii key sequence.
;

        MAX_ASCII_NO = BYTE ('9')
        MIN_ASCII_NO = BYTE ('0')


;
;  Return an array of logical values, one for each element in the parameter
;  STR, where each element in the array indicates whether the corresponding
;  element of STR is an ASCII digit.
;
 
        RETURN, TSTR GE MIN_ASCII_NO (0) AND TSTR LE MAX_ASCII_NO (0)
        END
