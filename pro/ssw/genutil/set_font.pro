pro set_font, siz, x_only=x_only, widget_only=widget_only
;+
;NAME:
;	set_font
;PURPOSE:
;	To change the font size for X windows and widgets
;SAMPLE CALLING SEQUENCE:
;	set_font
;	set_font, 12
;	set_font, 12, /xonly
;OPTIONAL INPUT:
;	size	- The font size to find the closest match to
;OPTIONAL KEYWORD:
;	x_only	- If set, only change X device
;	widget_only - If set, only change widget
;HISTORY:
;	Written 6-Nov-96 by M.Morrison
;-
;
if (n_elements(siz) eq 0) then siz=12
;
font = get_xfont(closest=siz(0), /only_one, /fixed)
;
if (not keyword_set(x_only)) then begin
    print, 'Setting WIDGET Font to: ' + font
    setenv, 'MDI_DEF_FONT='+font
    widget_control, default_font=font
end
;
if (not keyword_set(widget_only)) then begin
    print, 'Setting X      Font to: ' + font
    device, font=font
end
;
end
