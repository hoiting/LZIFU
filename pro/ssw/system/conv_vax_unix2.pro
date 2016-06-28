;+ temporary shell around CONV_VAX_UNIX (Zarro, GSFC, July'97)

function  conv_vax_unix2, variable, TARGET_ARCH=target,verbose=verbose

if not exist(variable) then return,0

if os_family() eq 'vms' then return,variable

return,conv_vax_unix(variable,TARGET_ARCH=target) 

end

