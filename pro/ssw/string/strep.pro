;+
; Project     :	SOHO - CDS
;
; Name        :	STREP
;
; Purpose     : Replaces first occurrence of given string within a string.
;
; Explanation : Within the given string the routine will replace the first
;               occurrence of the supplied substring with the requested
;               replacement.
;
;               eg. IDL> x = 'abcdefgcd'
;                        print, strep(x,'cd','qq')  --> 'abqqefgcd'
;
;               see also REPSTR() for replacement of all occurrences.
;
; Use         : Result = output=strep(input,old,new,/all)
;
; Inputs      :
;               input=any string
;               old=old characters
;               new=new characters
;
; Opt. Inputs : None.
;
; Outputs     : Result = new string.
;
; Opt. Outputs: None.
;
; Keywords    : all = replace all characters
;
; Calls       : uses STRMID
;
; Common      : None.
;
; Restrictions: None.
;
; Side effects: None.
;
; Category    : String processing
;
; Prev. Hist. : None.
;
; Written     :	DMZ (ARC) August 1993
;
; Modified    : Documentation header update.  CDP, 26-Sep-94
;
; Version     : Version 2, 26-Sep-94
;               Version 3, 8-Jun-98, Zarro (SAC/GSFC) - added /compress
;-
;
FUNCTION strep,input,old,new,all=all,compress=compress              
   len=STRLEN(input) & p=STRPOS(input,old) 

   tnew=STRTRIM(new,2)
   IF p EQ -1 THEN RETURN,input
   leno=STRLEN(old)
   lenn=STRLEN(tnew)

;-- buffer so that new string tailors with old string

   IF lenn LT leno THEN BEGIN
      REPEAT BEGIN
         tnew=tnew+' '
      ENDREP UNTIL STRLEN(tnew) EQ leno
   ENDIF

   output=STRMID(input,0,p)+tnew+STRMID(input,p+leno,len-p-leno+1)
   IF KEYWORD_SET(all) THEN output=strep(output,old,new,/all)
   if keyword_set(compress) then output=strcompress(output,/rem)
   RETURN, output
END

