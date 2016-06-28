;+
; Project     : SOHO - CDS
;
; Name        : LIST_PRINTER
;
; Purpose     : LIST available printers
;
; Category    : Help, Device
;
; Explanation : 
;
; Syntax      : IDL> list_printer,printers,desc
;
; Examples    :
;
; Inputs      : None
;
; Opt. Inputs : None
;
; Outputs     : PRINTER - printer que names
;
; Opt. Outputs: DESC -  description of each printer
;
; Keywords    : ERR - error messages
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  8-Aug-1995, D M Zarro . Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro list_printer,printers,desc,err=err

if os_family(/lower) eq 'vms' then printers=list_printer_vms(desc,err=err) else $
 printers=list_printer_unix(desc,err=err)

return & end
