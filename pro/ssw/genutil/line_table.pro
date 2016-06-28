pro line_table, table, data=data, reverse=reverse, gamma=gamma
;+
;   Name: line_table
;
;   Purpose: make an ~IDL image color table cooexist with a <linecolors> table
;
;   Input Parameters:
;      table - IDL standard color tables (see loadct), default = #3(red)
;
;   Keyword Parameters:
;      gamma -   if set, gamma factor 
;      reverse - if set, reverse
;      data - optional data array to scale (scaled to image color table)
;
;   Calling Sequence:
;      line_table,table# [,/reverse, gamma=gamma, data=data]
;
;   History:
;      14-nov-1995 (SLF) - merge color plots and image display for WWW
;                          allow colorful line plots and approximation of 
;			   standard IDL color tables for (scaled) images
;      15-July-1996 (SLF) - simplified by calling 'stretch_range.pro'
;
;   Side Effects:
;      loads a color table (and common block) - optionally scale data
;-

if n_elements(table) eq 0 then table=3		; default to red tables
if n_elements(gamma) eq 0 then gamma=1.		; default gamma
reverse=keyword_set(reverse)

nc=16						; colors lost to linecolors
loadct,table					; load the color table
linecolors					; define line colors (0-16)
tvlct,r,g,b,/get				; save post linecolors rgb

low=([0,255])(reverse)
high=255-low
help,'stretch range...',low,high,gamma,reverse
stretch_range,low,high, gamma, range=[([0,nc])(reverse),!d.table_size-1]

; optionally scale data to the "image" range
if keyword_set(data) then data=bytscl(data,top=!d.table_size-nc-2)+nc

return
end
