;+
; Project     : SOHO - CDS     
;                   
; Name        : COPY_TAG_VALUES
;               
; Purpose     : Copy tag values of one structure into another structure
;               
; Explanation : The values of the tags in the SOURCE structure are copied into
;               the tags of the DESTINATION structure which have matching tag
;               names. Tag names may be truncated as long as an unambiguous
;               identification can be made.
;
;               The datatypes of the tags in the DESTINATION stucture are not
;               changed, and type conversions of the SOURCE values are handled
;               in the same way IDL normally handles type conflicts.
;               
;               If the STATUS parameter is used, it is set to one if
;               everything is OK, and the procedure tries to catch all errors
;               to return a zero in STATUS if something goes wrong. In this
;               case, some or all the relevant values may have been copied,
;               but there is no guarantee about anything.
; 
;               Attempts to set non-existing tags in DESTINATION will be
;               ignored, as will any ambiguous assignment, although the STATUS
;               flag will be set to zero to signal the error.
;
; Use         : COPY_TAG_VALUES,DESTINATION,SOURCE [,STATUS]
;    
; Inputs      : DESTINATION : Any structure.
;
;               SOURCE : A structure with some tags bearing the new values of
;                        the corresponding tags in DESTINATION.
;               
; Opt. Inputs : None.
;               
; Outputs     : DESTINATION is altered to reflect the new values.
;               
; Opt. Outputs: STATUS : Set to 1 on successful completion, or zero if an
;               error occurred.
;               
; Keywords    : None.
;
; Calls       : PARCHECK, TYP()
;
; Common      : None.
;               
; Restrictions: The structures must be single structures.
;               
; Side effects: None known.
;               
; Category    : Utility
;               
; Prev. Hist. : Taken out of cw_pzoom
;
; Written     : SVH Haugan (UiO), 30 April 1996
;               
; Modified    : Version 2, SVHH, 6 June 1996
;                       Using the stc.(i)=stc.(j) construct instead of
;                       dummy=execute(..).
;
; Version     : 2, 6 June 1996
;-            

PRO copy_tag_values,DESTINATION,SOURCE,STATUS
  
  IF N_PARAMS() LT 2 THEN  $
     MESSAGE,"Use: COPY_TAG_VALUES,DESTINATION,SOURCE [,STATUS]"
  
  ;; STRUCTs are always arrays
  parcheck,destination,1,typ(/stc),1,'DESTINATION'
  IF N_ELEMENTS(destination) GT 1 THEN  $
     MESSAGE,"DESTINATION structure can only have one element"
  
  parcheck,source,2,typ(/stc),1,'SOURCE'
  IF N_ELEMENTS(source) GT 1 THEN  $
     MESSAGE,"SOURCE structure can only have one element"
  
  ;; Ok so far.
  
  status = 1
  
  dtags = tag_names(DESTINATION)
  stags = tag_names(SOURCE)
  
  FOR I=0L,N_ELEMENTS(stags)-1 DO BEGIN
     stag = stags(i)
     ix = WHERE(dtags EQ stag,count)
     IF count EQ 0 THEN begin
        MESSAGE,"Tag "+stag+" doesn't exist, ignored",/informational
        status = 0
     END
     IF count EQ 1 THEN BEGIN $
        catch,error
        IF error NE 0 THEN BEGIN
           status = 0
           MESSAGE,"Error in setting tag:"+stag,/continue
           GOTO,IGNORE
        END
        destination.(ix(0)) = source.(i)
IGNORE:
        CATCH,/CANCEL
     END
  END
END


