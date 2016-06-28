pro array_max,z,imax,jmax,zmax
;
;PURPOSE:
;	returns coordinates (i,j) of array maximum z(i,j)
;INPUT:
;	z	=2D array
;	
;OUTPUT:	
;	imax	=index of x-axis where maximum of 2D image is 
;	jmax	=index of x-axis where maximum of 2D image is 
;	zmax	=maximum of 2D array z(i,j)
;
;HISTORY:
;	1990. written. aschwand@lmsal.com
;	1999, contributed to SSW

dim	=size(z)
zmax	=max(z,ij)
imax	=ij mod dim(1)
jmax	=ij/dim(1)
end 
