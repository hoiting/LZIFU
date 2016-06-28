;+
; Project     : SOHO - CDS
;
; Name        : EXEC_STRUCT
;
; Category    : structures, utility
;
; Purpose     :	Execute CREATE_STRUCT to dynamically create new structure
;
; Explanation :	
;
; Syntax      : IDL> new_struct=exec_struct(pairs,struct=struct)
;
; Inputs      : PAIRS = string pair array form PAIR_STRUCT
;
; Opt. Inputs : None
;
; Outputs     : NEW_STRUCT = created structure
;
; Opt. Outputs: None
;
; Keywords    : ERR= error string
;               STRUCT = structure variable name
;               NAME = new created structure name
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  1-Dec-1997,  D.M. Zarro - written
;               Version 2,  12-Dec-1998, Zarro (SM&A) - improved memory management
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function exec_struct,pairs,err=err,name=name,quiet=quiet,$
              _extra=input_struct
on_error,1
err=''

if (datatype(pairs) ne 'STR') or (datatype(input_struct) ne 'STC') then begin
 err='Invalid input'
 pr_syntax,'new_struct=exec_struct(pairs,_extra=struct)'
 return,''
endif

@unpack_struct

lim=300
new_struct=''
if datatype(name) ne 'STR' then name=''
temp=arr2str(pairs)
tlen=strlen(temp)

if tlen gt lim then begin
 npairs=n_elements(pairs)
 i=0
 spair=''
 while (i lt npairs) do begin
  if spair ne '' then delim=',' else delim=''
  spair=spair+delim+pairs(i)
  if i lt (npairs-1) then begin
   spair_next=spair+delim+pairs(i+1)
   slen=strlen(spair_next)
  endif else slen=lim
  if (slen ge lim) then begin
   expr='tstruct=create_struct('+spair+')'
   stat=execute(expr)
   if stat then begin
    if datatype(new_struct) eq 'STC' then $
     new_struct=create_struct(new_struct,tstruct,name=name) else $
      new_struct=create_struct(tstruct,name=name)
    spair=''
   endif else goto,done
  endif
  i=i+1
 endwhile
endif else begin
 expr='new_struct=create_struct('+temp+',name=name)'
 stat=execute(expr)
endelse

done:
if not stat then begin
 err='Structure creation failed'
 if 1-keyword_set(quiet) then message,err,/cont
endif


return,new_struct & end

