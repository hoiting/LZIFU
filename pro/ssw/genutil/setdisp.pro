pro setdisp,node
;+
;   Name: setdisp
;
;   Purpose: set X windows display to remote node while in idl
;
;   Input Parameters:
;      node - string node name or string node number
;
;   History: slf, 3-nov-1992
;
;   Restrictions:
;      o does not handle local machine security issues
;      o probably a lot of others
; 
;   Side Effects:
;	redirects X output to specified node
;	may generate warning messages when 1st window is created (but works)
;      
;-

if n_elements(node) eq 0 then $
   message,'No node name/number supplied'
dnode=node
colon=strpos(dnode,':')
if colon ne -1 then $
   dnode=strmid(dnode,0,colon)

case strupcase(!version.os) of 
   'VMS': begin
      dcmd='set display /create /super /node=' + dnode + '::0'
      message,/info,dcmd
      spawn,dcmd
    endcase
   else : begin
      dcmd='DISPLAY=' + dnode + ':0'
      message,/info,'setenv ' + dcmd
      setenv,dcmd
   endcase
endcase
return
end
