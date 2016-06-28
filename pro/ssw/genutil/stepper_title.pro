pro stepper_title, title, break, blank=blank, $
	brief=brief, charsize=charsize, color=color

;
;+
;   Name: stepper_title
;
;   Purpose: overly title on graphics device for stepper/xstepper
;
;   History - slf, 10-Jun-92 - provide single point maint for title
;	      slf, 31-aug-93 - add charsize and color keywords

;
;   Side Effects - title is written to default graphics device
;-
if keyword_set(blank) then color = 0 else color =255
case 1 of
   keyword_set(blank): color=0
   1-keyword_set(color): color=255
   else:
endcase

if n_elements(charsize) eq 0 then charsize=1.26


title=title(0)					
if n_elements(break) eq 0 then begin
   break = 38        ; Break point
   nb=strpos(strmid(title,break,strlen(title)),' ')
   break=break+nb   
endif

if strlen(title) le break then begin
    xyouts,0,10,title, color=color,/device, charsize=charsize
endif else begin
     str0 = strmid(title,0,break)
     str1 = strmid(title,break,strlen(title))
     xyouts,10,10,str1,charsize = charsize, /device, color=color
     xyouts, 0,23,str0,charsize = charsize, /device, color=color
endelse 
return
end
