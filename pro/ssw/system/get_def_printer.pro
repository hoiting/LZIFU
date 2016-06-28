;+
; Name        : GET_DEF_PRINTER
;
; Purpose     : Get default printer from available printers
;
; Category    : system
;
; Explanation : 
;
; Syntax      : IDL> get_def_printer,printer
;
; Inputs      : None
;
; Opt. Inputs : None
;
; Outputs     : PRINTER = default printer name
;
; Opt. Outputs: None
;
; Keywords    : DEFAULT = default printer name
;               DESC = description of printer
;               SET  = set input printer to be last selected printer
;
; Common      : GET_DEF_PRINTER = last selected printer
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  28 Feb 1997,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro get_def_printer,printer,default=default,desc=desc,set=set

common get_def_printer,last_choice

;-- setup defaults

list_printer,printers,descs

;-- user input (for setting)

if keyword_set(set) then begin
 in_printer=''
 if datatype(printer) eq 'STR' then begin
  in_printer=getenv(printer)
  if in_printer eq '' then in_printer=trim(printer)
  plook=where(strupcase(in_printer) eq strupcase(printers),pcnt)
  if pcnt gt 0 then last_choice=in_printer
 endif
 return
endif

;-- check  default

def_printer=''
if datatype(default) eq 'STR' then begin
 def_printer=getenv(default)
 if def_printer eq '' then def_printer=trim(default)
endif

last_printer=''
if datatype(last_choice) eq 'STR' then last_printer=last_choice
check_list=[def_printer,last_printer]

index=0
use=where(trim(check_list) ne '',cnt)
if cnt gt 0 then begin
 plook=where(strupcase(check_list(use(0))) eq strupcase(printers),pcnt)
 if pcnt gt 0 then index=plook(0)
endif

printer=printers(index) & desc=descs(index)

return & end

