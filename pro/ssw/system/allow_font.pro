;+
; Project     : HESSI
;                  
; Name        : ALLOW_FONT
;               
; Purpose     : platform/OS independent check if current system
;               supports given font
;                             
; Category    : system utility
;               
; Syntax      : IDL> a=allow_font()
;                                        
; Outputs     : 1/0 if yes/no
;                   
; History     : 14 May 2003, Zarro (EER/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

function allow_font,font,err=err

common allow_font,font_names
err=''

if not is_string(font) then begin
 err='String font name required'
 message,err,/cont
 return,0b
endif

;-- try to open a window

unix=os_family(/lower) eq 'unix'
if (unix and not exist(font_names)) or (not unix) then begin
 if not allow_windows(/quiet) then return,0b
  if not is_wopen(!d.window) then begin
  window,/pix,/free,xsize=1,ysize=1
  wpix=!d.window                                     
 endif
endif      
in_font=font

;-- easy for UNIX since DEVICE,/GET_FONTNAMES returns supported fonts

if unix then begin
 if not exist(font_names) then device,set_font='*',get_fontnames=font_names
 if is_string(font_names) then begin
  chk=where(strup(in_font) eq strup(font_names),count)
  if count eq 0 then begin
   err=in_font+' unsupported on current system' 
   message,err,/cont
   wdel,wpix
   return,0b
  endif else return,1b
 endif
endif

;-- use catch for Windows
 
error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 err=in_font+' unsupported on current system' 
 message,err,/cont
 wdel,wpix
 return,0b
endif

device,font=in_font
wdel,wpix
return,1b

end
