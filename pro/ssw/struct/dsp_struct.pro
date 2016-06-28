;+
; Project     : SOHO - CDS     
;                   
; Name        : DSP_STRUCT
;               
; Purpose     : Display contents of a structure as a pulldown menu.
;               
; Explanation : A pulldown menu is created representing all the
;		levels of "introspection" of the structure variable.
;
;		If a tag in a structure is an array, it's "written out"
;		if it's less than SIZE, which by default is set to 30.
;
;		It may be used as a standalone widget or as part of a
;		menu. In the latter case, it generates a pulldown button
;		that unfolds the structure.
;               
; Use         : DSP_STRUCT, DATA_STRUCTURE
;    
; Inputs      : DATA_STRUCTURE: Any IDL structure.
;               
; Opt. Inputs : None.
;               
; Outputs     : None.
;               
; Opt. Outputs: None.
;               
; Keywords    : TITLE: The title of the menu/button.
;
;		SIZE: Controls the maximum size of arrays to be expanded
;
;		ON_BASE: The base to place the button on if it's supposed
;			to be a subpart of another widget hierarchy.
;			
;		ALONE: Set to make it be a stand-alone widget application.
;
; Calls       : xpl_struct
;
; Common      : None.
;               
; Restrictions: None.
;               
; Side effects: 
;               
; Category    : CDS, QL, DISPLAY, UTILITY
;               
; Prev. Hist. : Requested simultaneously by the Goddard & Rutherford
;		people, independent of each other.
;
; Written     : SVHH, 15 January 1994
;               
; Modified    : SVHH, Documentation added March 1994, stand-alone mode added.
;		SVHH, 3-May-1995, Version 1.1
;			Made arrays unfold the first <SIZE> number
;			of elements.
;               Version 2, SVHH, 21 November 1996
;                       Using XPL_STRUCT for the main job.
; Version     : 2, 21 November 1996
;-            


PRO dsp_struct_noop,ev
  
END

PRO dsp_struct_quit,ev
  widget_control,ev.top,/destroy
END

PRO dsp_struct,str,Size=Size,$
               title=title,on_base=on_base,alone=alone
  
  IF N_elements(Size) eq 0 THEN	Size = 30
  
  IF N_elements(title) eq 0 THEN BEGIN
      title = tag_names(str,/structure_name)
      IF title eq '' THEN title	= 'Anonymous structure'	$
      ELSE title = 'Structure: '+title
  EndIF
  
  IF N_elements(on_base) eq 0 THEN BEGIN
     base = Widget_BASE(title=title,/column,event_pro="dsp_struct_noop")
     quitb = widget_button(base,value='Quit',event_pro="dsp_struct_quit")
     xpl_struct,str,on_base=base,/nohelp,size=size
     Widget_CONTROL,base,/realize
     IF Keyword_SET(alone) THEN Xmanager,"dsp_struct",base,$
        event_handler="no_operation"
  END ELSE BEGIN
     localbase=Widget_BASE(on_base,event_pro="dsp_struct_noop",/row)
     xpl_struct,str,on_base=localbase,/nohelp,size=size
  END
  
END
