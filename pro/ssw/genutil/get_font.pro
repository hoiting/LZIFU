;============================================================================
;+
; PROJECT:  HESSI
;
; NAME: get_font
;
; PURPOSE:  Get fonts suitable for widgets for any platform
;
; CATEGORY: WIDGETS
;
; CALLING SEQUENCE:  get_font, font, big_font=big_font, small_font=small_font, huge_font=huge_font
;
; INPUTS:
;	None
;
; OPTIONAL KEYWORDS:
;	big_font - larger font for titles, etc
;	small_font
;	huge_font
;
; OUTPUTS:
;	font - normal size font
;
; OPTIONAL OUTPUTS:  None
;
; Calls: get_dfont
;
; COMMON BLOCKS: None
;
; HISTORY:
;	Kim Tolbert, 10-Jul-2005 (extracted from hsi_ui_getfont)
;
;
;-
;============================================================================

pro get_font, font, big_font=big_font, small_font=small_font, huge_font=huge_font

case !version.os_family of
    'Windows' : begin
    	font = 'MS Sans Serif*12'
    	small_font = 'MS Sans Serif*10'
    	big_font = 'Arial*Bold*24'
    	huge_font = 'Arial*Bold*36
    	end
    'MacOS' : begin
    	font = 'helvetica*10'
    	small_font = 'helvetica*8'
    	big_font = 'helvetica*14'
    	huge_font = 'helvetica*18'
    	end
    else: begin
        font = get_dfont(['-adobe-helvetica-medium-r-normal--10-*-*-*', $
                                 '-adobe-times-medium-r-normal--10-*-*-*'])
        small_font = get_dfont(['-adobe-helvetica-medium-r-normal--8-*-*-*', $
                                 '-adobe-times-medium-r-normal--8-*-*-*'])
		big_font = get_dfont(['-adobe-helvetica-bold-r-normal--14-*-*-*', $
                                 '-adobe-times-medium-r-normal--14-*-*-*'])
        huge_font = get_dfont(['-adobe-helvetica-bold-r-normal--24-*-*-*', $
                                 '-adobe-times-medium-r-normal--24-*-*-*'])
        end
endcase

font = font[0]
small_font = small_font[0]
big_font = big_font[0]
huge_font = huge_font[0]

end