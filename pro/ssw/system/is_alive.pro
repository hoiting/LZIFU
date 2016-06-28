function is_alive, node, decnet=decnet, internet=internet, loud=loud, qstop=qstop
;
;+
;   Name: is_alive
;
;   Purpose: check health of remote host
;
;   Input Parameters:
;      node - node name or number 
;
;   Calling Sequence:
;      status=is_alive(node [,/vms])
;
;   Calling Examples:
;      if is_alive('nodename') then...
;      if is_alive('123.45.6.78') then ...
;      if is_alive('name::') then ...		; colons to designate DECNET
;
;   History:
;       5-May-94 (SLF) written
;      10-May-94 (SLF) added history documentation
;      28-feb-95 (SLF) add /usr/sbin/ping / OSF case
;       2-Aug-95 (MDM) - added additional method for seeing if the node is
;			 responding (so this would work on SGI)
;		       - added /QSTOP
;      17-May-96 (BNH) - Added /sbin/ping (FreeBSD/linux case)
;      22-May-96 (BNH) - Fixed bugs I added with this case
;      26-jun-96 (SLF) - HP 9000 (hp-ux
;-
loud=keyword_set(loud)
status=-1
if n_elements(node) eq 0 then begin
   print,'Calling Sequence:'
   print,'IDL> status = is_alive(node)'
   return,status
endif

nodename=string(node)
system=strlowcase(!version.os)

udecnet=(strpos(nodename,'::') ne -1)

if udecnet then begin
   tbeep
   message,/info,'DECNet not yet supported, returning...
endif else begin
   ; find ping
   poptions=['/etc/ping','/usr/etc/ping','/usr/sbin/ping','/sbin/ping']
   whereping=where(file_exist(poptions),pcnt)
   if pcnt eq 0 then begin
      tbeep
      message,/info,"Could not find ping in one of the expected places..."
      return,status
   endif
   ping=poptions(whereping(0))
   matchs='1'
   case 1 of
      is_member(!version.os,['irix'],/ignore_case): begin
          matchpos= 13
          ping= ping + ' -q -c 1 ' + nodename
       endcase
      is_member(!version.os,['osf'],/ignore_case): begin
          matchpos= 15
          ping= ping + ' -q -c 1 ' + nodename
      endcase
      is_member(!version.os,['mips'],/ignore_case): begin
          match_pos= 18
          ping= ping + ' ' + nodename + ' -c 1"
       endcase
      is_member(!version.os,['linux'],/ignore_case): begin
          matchpos= 15
          ping= ping + ' -q -c 1 ' + nodename
       endcase
       is_member(!version.os,['hp-ux'],/ignore_case): begin
          ping = ping + ' ' + nodename + ' -n 1'	  
	  matchpos = 19
       endcase
       else: begin
         ping = ping + ' ' + nodename
         matchs= "alive"
         matchpos = 3
       endcase
   endcase
   if loud then message,/info,'Spawn:' + ping
   spawn,ping,result			; execute ping
   result=str2arr(arr2str(result,' '),' ')
   matchpos=matchpos-1			; unix/idl subscript offset
   if n_elements(result)  lt matchpos then status = 0 else $
      status=(result(matchpos) eq matchs)
   if (status eq 0) then status = max(strpos(strlowcase(arr2str(result, ' ')), ' 0% packet loss')) ge 0
   messes=['No reponse from Node: ' + nodename ,   $
	   'Node: ' + nodename + ' is alive']
   message,/info,messes(status)
endelse

if (keyword_set(qstop)) then stop
return,status
end
