pro pr_path, path
;
;+
;NAME:
;	pr_path
;PURPOSE:
;	Procedure to print the IDL !path variable (since it
;	is so long for Yohkoh users and returns an error with
;	the command "print,!path"
;CALLING SEQUENCE:
;	pr_path
;	pr_path, path
;OPTIONAL OUTPUT:
;	path	- a string array of the directories in the path
;HISTORY:
;	Written 17-Apr-92 by M.Morrison
;	25-Apr-94 (MDM) - Removed "more-like" code and replace with PRSTR
;	 8-May-00 (RDB) - use ";" as delimiter for windows
;-
;
delim = ':'
if strlowcase(!version.os_family) eq 'windows' then delim=';'
path = str2arr(!path, delim=delim)
prstr, path
;
print,'Total Number of Directories in the Path = ', n_elements(path)
;
end
