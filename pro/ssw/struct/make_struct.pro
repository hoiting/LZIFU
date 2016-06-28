;+
; Project     : SOHO-CDS
;
; Name        : MAKE_STRUCT
;
; Purpose     : a new way of creating structures
;
; Category    : structures
;
; Explanation : uses keyword inheritance to dynamically create structures
;
; Syntax      : struct=make_struct(tagname=tagvalue)
;
; Examples    : IDL> struct=make_struct(a=1,b=findgen(100),c='test')
;               IDL> help,/st,struct
;                  ** Structure <40557288>, 3 tags, length=424, refs=1:
;                  A               INT              1
;                  B               FLOAT     Array[100]
;                  C               STRING    'test'
;
; Inputs      : TAGNAME=TAGVALUE pair
;
; Opt. Inputs : None
;
; Outputs     : STRUCT = created structure
;
; Opt. Outputs: None
;
; Keywords    : NAME = structure name (def=anonymous)
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 7 Jan 1998, D. Zarro, SMA/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function make_struct,_extra=extra,name=name

if datatype(extra) eq 'STC' then begin
 if datatype(name) eq 'STR' then begin
  if trim(name) ne '' then extra=create_struct(extra,name=name)
 endif 
endif else extra=-1 

return,extra

end

