function fstats, low, high, name=name, all=all
;
;+
;   Name: fstats
;
;   Purpose: vector version of fstat
;
;   Input Paramters:
;      low  (optional) -  first lun to check - default is free_lun low limit
;      high (optional) -  last lun to check  - default is free_lun high limit
;      name		- only return records with mathcing file names 
; 			  (returns -1 if file not open on any unit)
;
;   Optional Keyword Parameters:
;      all -  if set, use entire lun range (starting at lun=1)
;      name - if set, only record with specified file name (if exists)
;
;   Output: function returns vector of fstat structures
;
;   Calling Sequence:
;      fstat=fstats( [low, high, /all, name=name])
;
;   History: (SLF)  2-jun-93
;            (SLF) 30-jun-94 Implement name function
;-
lowlun=100		; assume get_lun used
highlun=128

all=keyword_set(all) or keyword_set(name)

if keyword_set(all) then begin
   lowlun=1
   highlun=128
endif else begin
   if keyword_set(low) then lowlun=low
   if keyword_set(high) then highlun=high
endelse
template=fstat(-1)

if (highlun-lowlun) gt 0 then $
	template=replicate(template,highlun-lowlun)

for i=lowlun,highlun-1 do  template(i-lowlun)=fstat(i)   

if keyword_set(name) then begin
   ss=where(strupcase(template.name) eq strupcase(name),sscnt)
   if sscnt gt 0 then template=template(ss) else template=-1
endif

return,template
end
