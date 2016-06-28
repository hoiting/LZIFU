;+
; Project     : HESSI
;
; Name        : FIX_EXTRA
;
; Purpose     : When using keyword inheritance, the tag name in _extra may be abbreviated
;               relative to the full name. For example, using /log when one really
;               means /log_scale may cause setting /log_scale to fail if one is
;               really looking for the full name /log_scale.
;
; Example     : IDL> help,/st,extra
;                     GRID            INT              1
;                     LIMB            INT              1
;                     LOG             INT              1
;
;               IDL> help,/st,template
;                     LOG_SCALE       BYTE         0
;                     GRID_SPACING    FLOAT           0.00000
;                     LIMB_PLOT       BYTE         0
;
;               IDL> help,fix_extra(extra,template),/st
;                     LOG_SCALE       INT              1
;                     GRID_SPACING    INT              1
;                     LIMB_PLOT       INT              1
;
;
; Category    : string structure utility
;                   
; Inputs      : EXTRA = structure produced by _extra 
;               TEMPLATE = structure of actual full keyword names or list
;                          of tag names
;
; Outputs     : Same as EXTRA, but abbreviated names are expanded to match template
;
; Keywords    : None
;
; History     : 23-Nov-2002, Zarro (EER/GSFC)
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


function fix_extra,extra,template

;-- check inputs

if not is_struct(extra) then return,-1
if is_struct(template) then mtags=tag_names(template)
if is_string(template) then mtags=template
if is_blank(mtags) then return,extra

etags=tag_names(extra)
ntags=n_elements(etags)

;-- cycle each tag thru template. If there is a match, then tag will assume name
;   of template tag. 

new_extra=extra
for i=0,ntags-1 do begin
 old_name=etags[i]
 chk=where( strpos(mtags,old_name) eq 0,count)
 if count gt 0 then begin
  new_name=mtags[chk[0]]
  new_extra=rep_tag_name(new_extra,old_name,new_name)
 endif
endfor
  
return,new_extra

end

