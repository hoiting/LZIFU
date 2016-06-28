pro rsh, node, command, status, user=user, $
	ocommand=ocommand, nospawn=nospawn, null=null, echo=echo
;+
;   Name: rsh
;
;   Purpose: spawn remote command
;
;   Input Parameters:
;      node - node name for rsh
;      command - command to execute
;
;   Output Parameters:
;      status - status output from    spawn
;
;   Calling Sequence:
;      rsh, node, command [status, user=user, /null, /echo]
;
;   Restrictions: unix only
;
;   History:
;      4-Feb-1994 (SLF)
;     12-May-1994 (SLF) (added a space between node and -l)
;      9-Jul-1994 (SLF) moved echo to preced spawn command (see what is is
;			doing, not what it did)
;     28-feb-1995 (slf) osf case
;-
; check input parameters
status=''
case 1 of 
   strlowcase(!version.os eq 'vms'): begin
      message,/info,'UNIX only, returning...'
      return
   endcase
   n_params() eq 0: message,/info,$
	'rsh, node, command , status, [/nospawn]
   n_params() eq 1: begin
      command=node
      node=get_host()
   endcase
   else:
endcase

case strlowcase(!version.os) of
   'irix': tpath='/usr/bsd/'
   'osf':  tpath='/usr/bin/'
    else:  tpath='/usr/ucb/'
endcase

nullx=['',' -n ']
cmd='rsh ' + node + nullx(keyword_set(null))
if keyword_set(user) then cmd = cmd + ' -l ' + user
cmd = cmd + ' ' +  command

ocommand=tpath + cmd
if keyword_set(echo) then message,/info,ocommand
if not keyword_set(nospawn) then spawn,ocommand,status

return
end
