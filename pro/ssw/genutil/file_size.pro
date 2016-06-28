function file_size, files, units=units, string=string, auto=auto, totalf=totalf
;
;+
;   Name: file_size
;
;   Purpose: return file sizes - optionally as string with units
;
;   Keyword Parameters:
;      string - if set, output is string
;      auto   - if set, auto-scale (ex: Kb, Mb, ....)  
;      total  - if set, total all file sizes before string/auto applied
;               (example, display total transfer for NN files)  
;  
;   Restrictions:
;      auto and string not yet vecorized 
;
;   History:
;      8-Feb-1995 S.L.Freeland 
;     15-jul-1997 (SLF) - add TOTAL keyword and function
;     20-aug-2003 (SLF) - change 'string' -> 'fstring' (handle > 1024)
;-

string=keyword_set(string)
auto=keyword_set(auto)

fsizes=file_stat(files,/size)		; byte size
if keyword_set(totalf) then fsizes=total(fsizes)       ; sum all input files

if fsizes(0) eq -1 then begin
   message,/info,"File: " + files(0) + " not found..."
   return,fsizes
endif

unit=['B','KB','MB','GB']
cutoffs=[0,1.e3,1.e6,1.e9]

units=unit(0)				; default

if auto then begin			; bytes
   ss=where(fsizes ge cutoffs,cnt)
   units=unit(ss(cnt-1))
   fsizes=fsizes/(cutoffs(ss(cnt-1))>1)
endif

if string then $
   fsizes=strtrim(fstring(fsizes,format='(f10.2)') + ' ' + units,2)

return, fsizes
end
