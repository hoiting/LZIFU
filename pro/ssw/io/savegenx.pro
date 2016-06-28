pro savegenx,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15, $
      p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,$
      file=file, notype=notype, noextension=noextension, $
      _extra=_extra, overwrite=overwrite                       ; => save  
;+
;   Name: savegenx
;
;   Purpose: update of 'savegen' to handle pointers, objects, etc.
;
;   Input Parameters:
;      p0,p1...pn - variables to save - any IDL type,variety
;
;   Keyword Parameters:
;      file   - output file name;  default 'save.geny'
;      notype/noextension (synonyms)  - dont include default extention '.geny'
;      overwrite - if set, OK to clobber existing version of FILE
;      _extra - all other keywords passed to RSI 'save' via inheritance
;
;   Calling Sequence:
;      IDL> savegenx, v1 [,v2,v3...vN] [,file='filename'] [,/noexten] [,/over]
;
;   History:
;      4-November-1999 - S.L.Freeland - permit saving "modern" RSI data
;
;   Method:
;      setup and call 'save' via execute statement
;      Retrieve contents via: 'restgenx'
;
;  Restrictions:
;    Need to consider integration with 'savegen/restgen' a little more...
;-
if n_params() eq 0 then begin
   box_message,['No parameters supplied to save...',$
                'IDL> savegenx, v1 [,v2,v3...vN] [,file=file]']
   return
endif 

; ----------- file name definition --------
notype=keyword_set(notype) or keyword_set(noextension)
if not data_chk(file,/string,/scalar) then file='save'
ofile=str_replace(file,'.geny','')+(['.geny',''])(notype)

; --- dont clobber existing version unless /OVERWRITE is set ---------
clobber=keyword_set(overwrite)
if not clobber then begin 
   if file_exist(ofile) then begin
      box_message,['Warning: File> ' + ofile + ' already exists...',$
                   'Use: /OVERWRITE switch to force update']
      return
   endif
endif
; -------------------------------------------------------------

; --------------------- save section ---------------
plist='p' + strtrim(indgen(n_params()),2)                    ; defined params
savecmd='save,'+arr2str(plist) + ',file=ofile,_extra=_extra' ; execmd
estat=execute(savecmd)                                       ; execute it
; -------------------------------------------------

return
end
