function where_pattern, inarray, inpattern, sscnt, print=print
;+ 
;   Name: where_pattern
;
;   Purpose: find byte pattern in byte array
;            (ex: find repeated pattern in unformatted files)
;
;   Input Parameters:
;      inarray -   byte or string array to search
;      inpattern - byte or string array to match
;
;   Output Parameters:
;      function returns indicies of match (-1 if no match)
;      sscnt - number of matches 
;
;   Keyword Parameters:
;      print - if set, print WHERE statement used in execute 
;
;   History:
;      5-Nov-1994 (SLF) - to search for byte pattern in unformatted files
;     23-Jan-1995 (SLF) - allow non-printing characters (linefeed) in inpattern 
;
;   Restrictions:
;      Size of pattern limited by execute statement length limits
;      (Length <= 13 in IDL V3.5)
;-

barr=byte(inarray)		; bytearray to search
bpat=byte(inpattern)		; byte pattern to look for

if n_elements(bpat) gt 13 then begin
   tbeep
   message,/info,"Warning: input pattern truncated to 13 characters"
   bpat=bpat(0:12)      
endif

; generate the execute string - (via shift and where)

shifts=-(indgen(n_elements(bpat) ))		

exestr="shift(barr," + string(shifts,format='(i3)') + ") eq " + $ 
            strcompress(string(fix(bpat)) + 'b',/remove)

exestr='ss=where(' + arr2str(exestr,' and ') + ',sscnt)

; execute the string (where statement)
exestat=execute(exestr)

if keyword_set(print) then begin
   break=str2arr(exestr,'shift')
   prstr,[break(0),'shift' + break(1:*)]
endif

return,ss
end
