pro callback, status, error, bridge, ud
	out = bridge->getvar('out')
	(*(ud.pout))[ud.i,ud.j] = out
end
