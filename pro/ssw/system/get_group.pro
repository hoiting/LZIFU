function get_group, dummy, all=all
;+
;  NAME:
;      get_group
;
;  SAMPLE CALLING SEQUENCE:
;	group = get_group()
;	groups = get_group(/all)
;
;  PURPOSE:
;      Find out the name of the group of the current process.
;      Optionally return the list of all groups it's a member of
;
;  INPUT PARAMETERS:
;	None.
;
;  OUTPUT PARAMETERS:
;	Returned value is the group name.
;
;  PROCEDURE:
;	Spawn a child process and pipe the result back.
;
;  HISTORY:
;	Written 16-Apr-97 by M.Morrison
;       22-Jun-2000 - RDB - return '' except under unix
;-

out=''

case strlowcase(!version.os_family) of

'unix': begin
   spawn,'groups',result,/noshell
   out = result(0)		;make it scalar

   arr = str2arr(out, delim=' ')
   if (keyword_set(all)) then out = arr $
		      else out = arr(0)
   end
else: begin
   end
endcase

return, out
end
