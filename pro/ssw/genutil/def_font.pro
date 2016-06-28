function def_font, default=default, button=button, label=label, $
	slider=slider, text=text, init=init
;
;+
;   Name: def_font
;
;   Purpose: return system dependent default fonts using system variable
;
;   Keyword Parameters:
;      init - switch, if set, return machine dependent defaults
;      button,label,slider,text, - widget type specific values
;      default - default (for all types)
;       
;   slf, 19-june-92 (eventually should use defsysv for this)
;   slf, 22-oct-92   add case
;   slf, 30-apr-93  use system variable, added keywords, alpha case
;   slf, 23-feb-96  remove system variable references (SSW integration)
;   Zarro (ADNET/GSFC) 25-July-06 - made default font a blank string
;
;   Restrictions:
;-

init=keyword_set(init) or 1		;*** forced on (slf, 23-feb SSW)
if init then begin
   case strlowcase(!version.os) of
      "risc/os":font='-adobe-times-bold-r-normal--*-100-*-*-*-*-*-*'
      "irix":   font='-adobe-helvetica-bold-r-normal-*-10-100-*-*-*-*-*'
      "ultrix": font='newcenturyschlbk_bold10'
      "alpha":  font='-adobe-times-bold-r-normal--*-100-*-*-*-*-*-*'
      else:     font=''
   endcase
endif 

return,font
end
