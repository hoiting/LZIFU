;+
; Project     : SOHO - CDS
;
; Name        : MKLOG
;
; Purpose     : define a logical (VMS) or environment (UNIX) variable
;
; Category    : Utility, OS
;
; Explanation : checks OS to determine which SET function to use
;
; Syntax      : IDL> mklog,name,value
;
; Inputs      : NAME  = string name of variable to define logical for
;             : VALUE = string name of logical 
;
; Keywords    : VERBOSE = print result
;               LOCAL = convert input value to local name
;
; Side effects: logical will become undefined if name=''
;
; History     : Written, 1-Sep-1992,  D.M. Zarro. 
;               Modified, 25-May-99, Zarro (SM&A/GSC) 
;                - add better OS check
;               Modified, 27-Nov-2007, Zarro (ADNET) 
;                - added check for $ prefix
;               Modified, 8-Jan-2008, Zarro (ADNEY)
;                - added /local
;
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro mklog,name,value,verbose=verbose,local=local

if is_blank(name) then return
if not_exist(value) then return

sz=size(value)
np=n_elements(sz)
svalue=value
if sz[np-2] eq 7 then begin
 if keyword_set(local) then svalue=chklog(local_name(value),/pre) else $
  svalue=chklog(value,/pre)
endif
if  sz[np-2] eq 1 then svalue=fix(value)

os=strupcase(os_family())

case os of
 'VMS'   : begin
            if strtrim(svalue,2) eq '' then begin
             ok=chklog(name)
             if ok ne '' then call_procedure,'dellog',name
            endif  else call_procedure,'setlog',name,svalue
           end
 else    : begin
            sname=strtrim(name,2)
            doll=strpos(sname,'$') eq 0
            svalue=strtrim(string(svalue),2)
            setenv,sname+'='+svalue
            if doll then begin
             sname=strmid(sname,1,strlen(sname))
             setenv,sname+'='+svalue
            endif else setenv,'$'+sname+'='+svalue
           end
endcase
verbose=keyword_set(verbose)
if verbose then print,'% MKLOG: '+name+' = '+chklog(name)

return & end
