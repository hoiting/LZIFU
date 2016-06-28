pro restgenx,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15, $
    p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,$
    file=file, _extra=_extra, inquire=inquire, quiet=quiet, ndefined=ndefined
;+
;   Name: restgenx
;
;   Purpose: update of 'restgen' to handle pointers, objects, etc.
;
;   Input Parameters:
;      p0,p1...pn - variables to restore (assume written via 'savegenx.pro')
;
;   Keyword Parameters:
;      file     - input file name;  default 'save.geny' (per savegenx.pro)
;      inquire  - switch: if set, check defined parameters 
;      quiet    - switch: if set, then /INQUIRE is quiet 
;      _extra  - all other keywords passed to RSI 'restore' via inheritance
;      ndefined - (OUTPUT) number of parameters saved (only if /INQUIRE set)
;
;   Calling Sequence:
;      IDL> restgenx, file='file', p1 [,p2,p3,..pN] [,/inquire] [,/quiet]
;
;   Calling Examples:
;     IDL> restgenx, file='test',/inquire, ndef=nn ; what's in 'test.geny'?
;     IDL> restgenx, file='test', x,y,z            ; 1st 3 par. from 'test.geny'
;
;   History:
;      4-November-1999 - S.L.Freeland - permit modern RSI data pntr/object...
;
;   Method:
;      Setup and call RSI 'restore' 
;      Retrieve contents written via 'savegenx'
;
;   Restrictions:
;      Need further consideration of restgenx/restgen integration...
;-
inquire=keyword_set(inquire)
loud=1-keyword_set(quiet)

; ------------ derive/check for file ------------
if not data_chk(file,/string,/scalar) then ifile='save.geny' else ifile=file
if not file_exist(ifile) then ifile=ifile+'.geny'
if not file_exist(ifile) then begin 
   box_message,'Cannot find file: <' + ifile + '>..., returning'
   return
endif
; ------------------------------------------------

; ------- restore the parameters (named p0[,p1..pN] by 'savegenx.pro' )
restore, file=ifile, _extra=_extra
; ------------------------------------------------

;------------------ /INQUIRE ? ---------------
if keyword_set(inquire) then begin 
   out=''
   estat=execute('help,out=out,'+arr2str('P'+strtrim(indgen(30),2)))
   ssdef=where(strpos(strupcase(out),'UNDEFINED') eq -1, ndefined)
   if ndefined eq 0 then box_message,'No parameters defined!' else begin 
      status=['#Parameters defined: ' + strtrim(ndefined,2),'', out(ssdef)]
      if loud then box_message,status
   endelse
endif
; ------------------------------------------------------

end
