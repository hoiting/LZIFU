;+
; Project     :	SOHO - CDS
;
; Name        : UNPACK_STRUCT
;
; Purpose     : unpacks the tag names of structure into dynamic variables
;
; Use         : INPUT_STRUCT=STRUCT & @UNPACK_STRUCT
;
; Inputs      : INPUT_STRUCT
;
; Opt. Inputs : None.
;
; Outputs     : All the variables associated with each tag are
;               released into memory.
;
; Opt. Outputs: None.
;
; Keywords    : None.
;               
; Explanation : 
;               For example, to convert all the tag values of the
;               structure system variable !d (e.g. !d.x_size) into 
;               variables named with the corresponding tag name (e.g. x_size),
;               type: 

;               IDL> input_struct=!d    ;-- must use input_structure as input
;               IDL> @unpack_struct     ;-- must be on a separate line
;
; Calls       : None.
;
; Common      : None.
;
; Restrictions: This program must be @'ed
;
; Side effects: None.
;
; Category    : Structure handling
;
; Prev. Hist. : None.
;
; Written     :	Zarro (ARC/GSFC) 14 June 1995
;
; Version     : 1
;-

if datatype(input_struct) ne 'STC' then $
 message,'set structure input name to INPUT_STRUCT',/cont else begin $
 names=tag_names(input_struct) & np=n_elements(names) & $
 for i=0,np-1 do begin $
  state=names(i)+' = '+'input_struct.('+strtrim(string(i,'(i2)'),2)+')' & $
  unpack_status=execute(strcompress(state,/remove)) & endfor & $
endelse

