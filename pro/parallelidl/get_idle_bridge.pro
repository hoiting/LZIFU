function get_idle_bridge, bridges, cpu_no=found
	ncpus = n_elements(bridges)
	found = -1
	repeat begin
		for cpu=0,ncpus-1 do begin
			case (bridges[cpu])->status(error=errstr) of
				0: found = cpu
;				2: found = cpu   ; changed by I-Ting Ho. Only return bridge when the status is "IDLE" (code=0)
				3: begin
					print, 'Error encountered: '+errstr
					stop
				end
				4: begin
					print, 'Aborted execution: '+errstr
					stop
				end
				else: ; do nothing
			endcase
			if found ne -1 then break
		endfor
		if found eq -1 then wait, 0.1 ; idle loop
	endrep until found ne -1
	bridge = (bridges[found])
if (bridges[cpu])->status(error=errstr) NE 0 then stop
	; Destroy all variables  I-Ting's modification
     all_var = 'tmp_var_xv3fd3' 
     bridge->Execute, all_var+'=ROUTINE_INFO("$MAIN$",/VARIABLES)' 
     all_var = bridge -> GetVar(all_var) 
     command = 'DELVAR, '+STRJOIN(all_var,', ') 
     bridge->Execute, command 

	return, bridge
end
