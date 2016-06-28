pro remtab, in_str, out_str
;
;+
;NAME:
;	remtab
;PURPOSE:
;	To remove the tabs from a line
;	but to maintain the positions where the characters were
;	Assumes tabs are every 8 columns
;INPUT:
;	in_str	- input string or string array
;OUTPUT:
;	out_str	- output string or string array
;HISTORY:
;	Written 1988 by M.Morrison
;               2-Jun-94 (SLF) allow string arrays - skip lines w/no tabs
;			       ues lookup for substituion for speed
;-
;
out_str = in_str
;
tablines=strpos(out_str,string(9b))		; where tabs
tabs=where(tablines ne -1,tlcnt)		; only look at lines w/tabs

; use lookup to avoid buried for loop, slf 2-jun-94
blnks=''
for i=1,8 do blnks=[blnks,string(replicate(32b,i))]	; generate table

for line=0,tlcnt-1 do begin				; for each tab line
   p = tablines(tabs(line)) 				; first tab in line

   while (p(0) ne -1) do begin				; while tabs remain
      out_str(tabs(line)) = $				; substitute blanks
	 strmid(out_str(tabs(line)), 0, p) + $ 
         blnks(8 - (p mod 8)) 		   + $
	 strmid(out_str(tabs(line)), p+1,strlen( out_str(tabs(line))))
      p = strpos(out_str(tabs(line)), string(9b))	; anymore tabs?
   endwhile

endfor
;
return
end
