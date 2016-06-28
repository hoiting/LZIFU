pro barrier_bridges, bridges
	ncpus = n_elements(bridges)
	idle = bytarr(ncpus)
	widle = where(idle eq 0, nw)
	repeat begin
		for i=0,nw-1 do begin
			case (bridges[widle[i]])->status(error=errstr) of
				0: idle[widle[i]] = 1b
;				2: idle[widle[i]] = 1b ;changed by I-Ting Ho. Wait until the bridge is IDLE (status=0)
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
		endfor
		widle = where(idle eq 0, nw)
		if nw gt 0 then wait, 1 ; idle loop
	endrep until nw eq 0
end
