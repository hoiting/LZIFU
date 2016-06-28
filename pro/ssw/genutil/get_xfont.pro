function get_xfont, pattern, count=count, only_one=only_one, fixed=fixed, $
	closest=closest, bold=bold, normal=normal, _extra=_extra
;+
;   Name: get_xfont
;
;   Purpose: return font (front end filter to device,get_font=)
;
;   Input Parameters: 
;      pattern - font pattern to match
;
;   Keyword Parameters:
;      only_one - return one match as a scaler string 
;      fixed    - if set, only fixed sized fonts (example: for table output)
;      closest  - if set, font size (select closest size to this if mulitple)
;
;   History:
;       25-mar-95 (SLF) 
;	10-Apr-95 (MDM) - Fixed a typo "xfont" versus "xfonts"
;        2-May-95 (SLF) - font format protections (call str2number)
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;-
only_one=keyword_set(only_one)
fixed=keyword_set(fixed)

; if no window, create a pixmap (offscreen window)

; avoid automatic creation of a window if none is open (make an offscreen window) 
nn= -2
if !d.window eq -1 then window,nn, /free, xsize=2,ysize=2,/pix

if not keyword_set(pattern) then begin
   patt=''
   if keyword_set(fixed) then patt ='*fix*'
   if keyword_set(bold)  then patt ='*bold*'
endif else patt='*' + str_replace(pattern,'*','') + '*'		; add wild cards

if not keyword_set(patt) then patt = '*'			; all

device,get_fontname=xfonts, font=patt, get_fontnum=count

case 1 of 
   xfonts(0) eq patt: begin
      count=0
      xfonts=''						; return null
   endcase
   count eq 1: xfonts=xfonts(0)
   count gt 1: begin
      if keyword_set(closest) then begin		; closest font size
         fsize=lonarr(count)
         fmt1=where(strpos(xfonts,'--') ne -1,f1cnt)
         fmt2=where(strpos(xfonts,'--') eq -1 and strlen(xfonts) le 40,f2cnt)
         if f1cnt gt 0 then fsize(fmt1)=long(ssw_strsplit(ssw_strsplit(xfonts(fmt1),'--',/tail),'-',/head))
         if f2cnt gt 0 then fsize(fmt2)=str2number(xfonts(fmt2))
         diff=abs(fsize-closest)
         best=where(diff eq min(diff),count)
         xfonts=xfonts(best)
      endif
      if only_one then xfonts=xfonts(0)
   endcase   
   else:
endcase

   

if nn eq !d.window then wdelete,nn

return, xfonts
end
