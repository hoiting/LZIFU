;+
; Project     : SOHO - CDS     
;                   
; Name        : TEXT_MATCH()
;               
; Purpose     : Find text(s) matching expression
;               
; Explanation : The supplied text array (INITIAL_LIST) is searched, and the
;               indices of the texts that match the supplied search criteria
;               (FIND, FIRST and LAST) are returned. The search is
;               CASE SENSITIVE.
;               
;               The search string (FIND) is a sequence of texts separated by
;               the operators '&' (high precedence AND), '|' (OR), and '$'
;               (low precedence AND).
;
;               The search string "active&nis" contains the search texts
;               "active" and "nis", and will match only those lines in
;               INITIAL_LIST that contain BOTH these texts as substrings.
;
;               "active|nis" will select lines with EITHER "active"
;               OR "nis".
;
;               "16/03|17/03$NIS" will select lines with (EITHER "16/03" OR
;               "17/03") AND "NIS".
;               
;               Parentheses are not allowed in the search, but with one AND
;               operator with high precedence (&) and one with low precedence
;               ($), there should be little need for them.
;
;               The search can be narrowed down by specifying FIRST and LAST
;               as substrings (no operators) to match the first and last
;               selectable strings.
;               
; Use         : INDEX = TEXT_MATCH(INITIAL_LIST,FIND,FIRST,LAST)
;    
; Inputs      : INITIAL_LIST : An array of texts to be searched.
;               
;               FIND : Search string. 
;
;               FIRST : Simple (one search text, no operators) text to match
;                       the first of the selectable texts.
;                       
;               LAST : Simple text to match the last of the selectable texts.
;
; Opt. Inputs : None.
;               
; Outputs     : Returns the indices of the matching lines. Returns -1 if
;               no matches were found.
;               
; Opt. Outputs: None.
;               
; Keywords    : None.
;
; Calls       : PARCHECK, TYP()
;
; Common      : None.
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; Category    : Cds_utility, string
;               
; Prev. Hist. : Distilled from PICKFITS v 5
;
; Written     : S.V.H. Haugan, UiO, 18 April 1996
;               
; Modified    : Version 2, SVHH, 23 April 1996
;                          Removed a side effect that altered input
;                          parameter FIND.
;               Version 3, SVHH, 29 April 1996
;                          Added wrapper around !DEBUG reference to allow
;                          compilation everywhere.
;  
; Version     : 3, 29 April 1996
;-            

FUNCTION text_match,ilist,find,first,last
  ON_ERROR,2
  debug = 0
  IF !version.os NE 'vms' THEN $
     dummy = execute("debug=!debug")
  IF debug GT 0 THEN ON_ERROR,0
  
  IF N_PARAMS() NE 4 THEN  $
     MESSAGE,"Use: RESULT = TEXT_MATCH(INITIAL_LIST,FIND,FIRST,LAST)"
  
  parcheck,ilist,1,typ(/str),1,"INITIAL_LIST"
  parcheck,find,2,typ(/str),0,"FIND"
  parcheck,first,3,typ(/str),0,"FIRST"
  parcheck,first,4,typ(/str),0,"LAST"

  low = 0
  hi = N_ELEMENTS(ilist)-1
  
  IF first NE '' THEN BEGIN
     low = (WHERE(STRPOS(ilist,first) GT -1))(0)
     IF low EQ -1 THEN RETURN,-1
  END
  
  IF last NE '' THEN BEGIN
     hi = MAX(WHERE(STRPOS(ilist,last) GT -1))
     IF hi EQ -1 THEN hi = N_ELEMENTS(ilist)-1
  END
  
  IF low GT hi THEN RETURN,-1
  
  list = ilist(low:hi)
  
  IF find NE '' THEN BEGIN
     ovalid = REPLICATE(1b,N_ELEMENTS(list))
     ofind = str_sep(find,'$')
     FOR l = 0,N_ELEMENTS(ofind)-1 DO BEGIN
        fnd = str_sep(ofind(l),'|')
        valid = bytarr(N_ELEMENTS(list))
        FOR i = 0,N_ELEMENTS(fnd)-1 DO BEGIN
           subfind = str_sep(fnd(i),'&')
           subvalid = REPLICATE(1b,N_ELEMENTS(list))
           FOR j = 0,N_ELEMENTS(subfind)-1 DO BEGIN
              ix = WHERE(STRPOS(list,subfind(j)) EQ -1)
              IF ix(0) NE -1 THEN subvalid(ix) = 0
           END
           valid = valid OR subvalid
        END
        ovalid = ovalid AND valid
     END
     ix = WHERE(ovalid)
     
  END ELSE BEGIN
     ix = LINDGEN(N_ELEMENTS(list))
  END
  
  IF ix(0) EQ -1 THEN RETURN,ix
  RETURN,ix + low
END
