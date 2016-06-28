pro update_history, index,  records,   mode=mode , debug=debug, $
    caller=caller, routine=routine, noroutine=noroutine, version=version
;+
;    Name: update_history
;
;    Purpose: add history record(s) to input structure(s)
;
;    Input Parameters:
;      index   - structure vector or FITs header array
;      records - info to add - string/string array
;
;    Keyword Parameters:
;      routine - if set , routine name to prepend to each history record -
;                default is via: 'get_caller' unless /noroutine set
;      caller - synonym for routine
;      noroutine - if set, dont prepend 'Caller' to records
;      version   - if set, verion number, include 'VERSION:' string
;  
;      mode - if set and #records=#index, add record(i)->index(i)
;             (default mode = record(*)->index(*) (all records->all structure)
;       
;    History:
;       3-November-1998 - S.L.Freeland - simplify history -> struct   
;      26-November-1998 - S.L.Freeland - fixed problem w/multiple MODE1 calls
;       8-jul-2003 - S.L.Freeland - Version 6. protect
;                    (rsi subscript -> degenerate dimension)
;  
;    
;-
debug=keyword_set(debug)
fheader=0
if data_chk(caller,/string) and n_elements(routine) eq 0 then routine=caller(0)

case data_chk(index,/type) of
   7: begin
         retval=fitshead2struct(index)
         fheader=1
   endcase
   8: retval=index
   else: begin
      box_message,['Need structure vector or FITS header...' , $
		   'IDL> update_history, index, records [/mode, version=xx]']
      return
   endcase
endcase   

nind =n_elements(retval)
nrecs=n_elements(records)

case 1 of
   data_chk(records,/string):
   data_chk(records,/defined): 
   keyword_set(version): records=''        ; Allow VERSION-ONLY additions
   else: begin
      box_message,['You must supply records to add or VERSION number', $
		   'IDL> update_history,index,records [version=xx']
      return
   endcase
endcase

addrecs=records

case 1 of
   data_chk(routine,/string): addroutine=routine
   keyword_set(noroutine):    addroutine=''
   else: addroutine=get_caller()                   ; default is caller
endcase   

case 1 of
   n_elements(version) eq 0: addver=''
   else: addver='VERSION:'+string(str2number(version),format='(F6.2)')
endcase

; now add the HISTORY records via boost_tag

addstring=strtrim(strlowcase(addroutine) + ' ' + addver + ' ' + addrecs,1)
if n_elements(mode) eq 0 then mode=0
case 1 of
   mode eq 0: retval=boost_tag(retval,addstring,'HISTORY')
   mode eq 1 and (nrecs eq nind): begin
     retval=boost_tag(index,addstring(0),'HISTORY')
     if n_elements(addstring) eq 1 then addstring=addstring(0)
     hpoint=n_elements(retval(0).history)-1
     ; check for degenerate dimensions (rsi idl V6 for example)
     if since_version('6.0') then begin 
        nadds=data_chk(addstring,/ndimen)
        nret=data_chk(retval.HISTORY(hpoint,*),/ndimen)
        if nadds eq nret-1 then $
           addstring=reform(addstring,1,n_elements(addstring))
     endif
     retval.HISTORY(hpoint,*)=addstring
  endcase
  else: begin
      box_message,$
	['MODE 1 set, but n_elements(INDEX) NE n_elements(RECORDS)' ,$
         'No HISTORY records updatedated']
      return
   endcase
endcase

if debug then stop

if fheader then index=struct2fitshead(retval) else $
                index=temporary(retval)

return
end
