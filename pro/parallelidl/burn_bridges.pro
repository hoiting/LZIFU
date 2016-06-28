pro burn_bridges, bridges
	ncpus = n_elements(bridges)
;	for cpu=0,ncpus-1 do $
       for cpu=ncpus-1,0,-1 do $  ; kill bridge in decending order
		obj_destroy, bridges[cpu]
end
