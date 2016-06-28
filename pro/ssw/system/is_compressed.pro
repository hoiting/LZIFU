;+
; Project     : HESSI
;
; Name        : IS_COMPRESSED
;
; Purpose     : returns true if file has .Z or .gz ext
;
; Category    : utility I/O
;
; Syntax      : IDL> chk=is_compressed(file)
;
; Inputs      : FILE = input filename(s)
;
; Outputs     : 1/0 if compressed or not
; 
; Optional Outputs: TYPE = 'gz' or 'Z' 
;
; History     : Written 2 July 2000, D. Zarro, EIT/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function is_compressed,file,type

type=''
if datatype(file) ne 'STR' then return,0b

nfiles=n_elements(file)
bool=bytarr(nfiles)
type=strarr(nfiles)
for i=0,nfiles-1 do begin
 chk1=str_match(file(i),'.gz',/case_sens)
 if chk1 ne '' then begin
  bool(i)=1b & type(i)='gz'
 endif else begin
  chk2=str_match(file(i),'.Z',/case_sens)
  if chk2 ne '' then begin
   bool(i)=1b & type(i)='Z'
  endif
 endelse
endfor

if nfiles eq 1 then begin
 bool=bool(0)
 type=type(0)
endif

return,bool

end
