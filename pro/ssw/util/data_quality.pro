function data_quality, images,        $
        rows=rows, columns=columns,   $
        badvalue=badvalue, hist=hist, minimum=minimum, maximum=maximum, $
        std_dev=std_dev, quality_thresh=quality_thresh		       
;+  
;
;   Name: data_quality
;
;   Purpose: determine empirical data quality
;
;   Input Parameters:
;      images - 2D image or 3D image cube
;
;   Output Parameters:
;      function returns %GOOD OR Boolean (true=good)
;                 floating vector w/length = #images
;            -OR- boolean vector  w/length = #images if QUALITY_THRESH supplied
;
;   Keyword Parameters:
;      rows     - switch - if set, quality in terms of good rows      
;      columns  - switch - if set, quality in terms of good columns  
;      badvalue - user supplied value defining BAD (default is minimum(image))
;      hist     - switch - if set, BAD value is highest frequency value
;      minimum  - switch - if set, BAD value is minimum(image) [DEFAULT]
;      maximum  - switch - if set, BAD value is maximum(image)
;
;   Calling Sequence:
;      quality=data_quality(images [,/row, /col, /min, /max, /hist, badval=nn])
;
;   Calling Examples:
;      quality=data_quality(cube)                 ; %pixels NE minimum(image)
;      good=data_quality(cube, quality=90)        ; boolean quality GE 90
;      quality=data_quality(cube, bad=0, /rows)   ; %rows with some data
;
;   History:
;       2-Oct-1996 - S.L.Freeland
;-
nimg=n_elements(images(0,0,*))
if nimg eq 0 then begin
   message,/info,"Need 2D or 3D array..., returning"
   return,-1
endif

histo=keyword_set(hist)

; select appropriate comparison value command (per image basis)
case 1 of
  histo:                    chkexe='chkval=(where(histog eq max(histog)))(0)'
  keyword_set(minimum):     chkexe='chkval=min(images(*,*,i))'
  keyword_set(maximum):     chkexe='chkval=max(images(*,*,i))'
  n_elements(badvalue) eq 1:chkexe='chkval=badvalue'
  n_elements(std_dev) eq 1 :chkexe='chkval=stdev(images(*,*,i))'
  else:                     chkexe='chkval=min(images(*,*,i))'  ; default=MIN
endcase

gcnts=fltarr(nimg)        ; "GOOD" pixel counts
brows=fltarr(nimg)        ; "BAD"  row counts
bcols=fltarr(nimg)        ; "BAD"  column counts
sdev =fltarr(nimg)

for i=0,nimg-1 do begin                              ; For each image
   if histo then histog=histogram(images(*,*,i))     
   exestat=execute(chkexe)                           ; update "BAD" value
   good = images(*,*,i) ne chkval                    ; boolean mask
   gcnts(i)=total(good)                              ; total good/image
   rbad=where(total(good,1) eq 0,rbadcnt)            ; bad rows
   cbad=where(total(good,2) eq 0,cbadcnt)            ; bad columns
   brows(i)=rbadcnt                                  ; #bad rows/image
   bcols(i)=cbadcnt                                  ; #bad columns/image
   sdev(i)=chkval
endfor

ncol=float((size(good))(1))
nrow=float((size(good))(2))

case 1 of
  keyword_set(std_dev):  quality=sdev/std_dev*100.
  keyword_set(rows):     quality=100.-((brows/nrow)*100.) ; qual= % good rows
  keyword_set(columns):  quality=100.-((bcols/ncol)*100.) ; qual= % good cols
  else:                  quality=(gcnts/(ncol*nrow))*100. ; qual= % good pixels
endcase

if keyword_set(quality_thresh) then quality=quality ge quality_thresh

return, quality
end
