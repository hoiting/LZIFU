;+
; Project     : SOHO - CDS     
;                   
; Name        : STRUNF
;               
; Purpose     : Unfold structure, produce template for struct_tags.hlp
;               
; Explanation : This procedure recursively unfolds a structure variable
;               and prints a template suitable for use in the struct_tags.hlp
;               file.
;               
; Use         : STRUNF,STRUCT,PREFIXB,PREFIXA
;    
; Inputs      : STRUCT : A structure variable
;               
;               PREFIX : The "fiducial name" of a structure variable
;                         of this type. E.g., "QLDS". Appears in front
;                         of each tag in the visible entries for the
;                         struct_tags.hlp file.
;               
; Opt. Inputs : None.
;               
; Outputs     : Prints a template for use in the struct_tags.hlp file.
;               
; Opt. Outputs: None.
;               
; Keywords    : None.
;
; Calls       : None.
;
; Common      : None.
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; Category    : Utility
;               
; Prev. Hist. : None.
;
; Written     : Stein Vidar H. Haugan, UiO, 9 April 1996
;               
; Modified    : Version 2, SVHH, 13 April 1996
;                       Recursive tag names for the !!!!!!! entries taken
;                       out (to conform with XPL_STRUCT behaviour).
;
; Version     : 2, 13 April 1996
;-            



PRO strunf,s,prefix
  n = tag_names(s,/struct)
  
  IF n NE '' THEN BEGIN
     n = byte(n)
     n = STRING(n(WHERE(n LT 48 OR n GT 57)))
  END
  
  
  parcheck,prefix,2,typ(/str),0,'PREFIX'
  
  prefixb = prefix
  
  prefixa = n + '.'
  
  t = tag_names(s)
  FOR i = 0,N_ELEMENTS(t)-1 DO BEGIN
     PRINT,'!!!!!!!!!!' + prefixa + t(i)
     n_lev = N_ELEMENTS(str_sep(prefixb,'.'))
     PRINT,'!' + STRMID('!!!!!!!!!!!!!!!!!!!!',0,N_lev)+prefixb + '.' + t(i)
     PRINT
     tag = 0
     dummy = execute("tag = s."+t(i))
     IF datatype(tag) EQ 'STC' THEN strunf,tag,prefixb+'.'+t(i) 
  END
END

  
