function diskfree, disk, tot=tot, used=used, filesys=filesys, mount=mount
;
;+
;NAME:
;	diskfree
;PURPOSE:
;	To return the number of free bytes available on the disk in megabytes.
;	Also returns total and used bytes and file system and mount names.
;CALLING SEQUENCE:
;	d = diskfree('/yd0')
;	d = diskfree('/yd0', tot=tot, used=used, filesys=filesys, mount=mount)
;INPUT:
;	disk
;OUTPUT:
;	Returns the number of free bytes in units of megabytes
;OPTIONAL KEYWORD OUTPUT:
;	tot	- Total # bytes on the disk (in megabytes)
;	used	- # of bytes used
;	filesys	- the file system name
;	mount	- the mount name
;HISTORY:
;	Written 14-Mar-92 by M.Morrison
;	19-Mar-92 (MDM) - Modified to return results as scalars if only
;			  only called for one disk
;	24-Mar-92 (MDM) - Modified to work on sun machines - there is 
;			  only one header line
;	14-Dec-92 (MDM) - Modified calculation for number of lines for
;			  header to use 1 for all machines except 
;			  DEC/Ultrix which has 2 lines of header.
;			  Confirmed 1 line of header for Sun, Mips, SGI
;			- Also modified to work on SGI
;		
;	 8-Jun-1994 (SLF) - Return -1 if cannot stat disk (avoid crash)
;        3-Dec-1994 (SLF) - handle long disk names(caused split entries&crash!)
;        7-Mar-1995 (SLF) - add OSF, flag vms
;       21-aug-2001 (SLF) - no header protection (SunOS/ultra-10?)
;       
;-
;
if os_family() ne 'unix' then begin
   message,/info,"UNIX only for now..."
   return,0
endif

if (n_elements(disk) eq 0) then disk = ''	;do all disks
;
cmd = 'df ' + (['-k ',' '])(is_member(!version.os,'ultrix')) + disk
if get_host() eq 'flare20' then cmd = 'df ' + disk ; << is this a kludge or what????
spawn, cmd, result

if result(0) eq '' then begin
   mount= '????'
   out = -1.
   tot = -1.
   used = -1.
   filesys = '????'
   message,/info,"Trouble getting disk status (verify NFS connection)"
   return,-1
endif

nlinhead = 1 < (n_elements(result)-1)
if (!version.os eq 'ultrix') then nlinhead = 2
result=result(nlinhead:*)

; slf 3-dec-1994 - Long disk names caused multi-line entries and crash 
; (sun/mips at least) - added concatetenation logic for split records...
split=where(strpos(result,'        ') eq 0,scnt)

if scnt gt 0 then begin
   result(split-1) = result(split-1) + ' ' + strtrim(result(split),2)
   result(split)=''
   result=result(where(result ne ''))
endif

n = n_elements(result)
out = fltarr(n)
tot = fltarr(n)
used = fltarr(n)
filesys = strarr(n)
mount = strarr(n)
;
off = 0
factor = 1.

if is_member(!version.os, ['IRIX'],/ignore_case) then off=1

for i=0,n-1 do begin
    df = str2arr(strcompress(result(i)), delim = ' ')
    filesys(i)  = df(0)
    tot(i)	= df(1+off)/1000.*factor	;results are listed in kbytes - SGI are in units of 512 byte blocks!!
    used(i)	= df(2+off)/1000.*factor
    out(i)	= df(3+off)/1000.*factor
    mount(i)	= df(5+off)
end
;
if (n eq 1) then begin			;turn output into a scalar if only one element
    filesys	= filesys(0)
    tot		= tot(0)
    used	= used(0)
    out		= out(0)
    mount	= mount(0)
end
;
return, out
end
