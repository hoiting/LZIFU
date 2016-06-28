function build_bridges, ncpus, nthreads
	if n_elements(ncpus) eq 0 then $
		ncpus = !cpu.hw_ncpu
	if n_elements(nthreads) eq 0 then $
		nthreads = 1
	bridges = objarr(ncpus)
	cd, current=pwd
	for cpu=0,ncpus-1 do begin
		; create bridge
        bridges[cpu] = obj_new('IDL_IDLBridge')
;		bridges[cpu] = obj_new('IDL_IDLBridge',output = './cpu'+strtrim(cpu,2)+'.txt')
		; execute startup
		(bridges[cpu])->execute, '@' + pref_get('IDL_STARTUP')
		; set path to include PWD
		(bridges[cpu])->execute, "cd, '" + pwd + "'"
		; set thread pool params
		(bridges[cpu])->execute, "cpu, tpool_nthreads=" + string(nthreads)
	endfor
	return, bridges
end
