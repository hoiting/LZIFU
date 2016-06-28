;+
; Project     : SOHO - CDS     
;                   
; Name        : TFTD
;               
; Purpose     : Search for a string in header documentation.
;               
; Explanation : From a previously created and saved list of one-liners
;               from the IDL userlib and CDS trees the routine selects 
;               up to 50 at random and prints them.  This routine is run at 
;               IDL startup as part of a user-education drive.
;               
; Use         : IDL> tftd [,'search_string', lines=lines, /prog, cat=cat]
;    
; Inputs      : None 
;               
; Opt. Inputs : search_string  -  if given only routine names or one-line
;                                 documentation containing that string will
;                                 be presented. If present, all matches are
;                                 output and the LINES keyword is ignored.
;
;                                 The default search is effectively wild-carded
;                                 to search for '*string*'.  If however a
;                                 wildcard is used explicitly at the end of
;                                 the search string, eg 'FITS*' then only those
;                                 entries beginning with the supplied
;                                 characters will be located. The /NAME
;                                 keyword is then redundant.
;
;               
; Outputs     : Listing to screen or printer
;               
; Opt. Outputs: None
;               
; Keywords    : lines - specifies the number of one-liners to output
;                       (limit of 50 is imposed)
;
;               prog  - use programmer routines only
;
;               cat   - if specified, only routines having the supplied
;                       string in the CATEGORY header section will be
;                       listed.  If cat has the value '?' then a list
;                       of possible categories is printed.
;
;               name  - if set, search is conducted within the name only
;                       of the program - not the explanation.
;
;               hard  - produce hardcopy of list
;
;               keep  - keep output in file tftd_results in current
;                       directory
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: Only userlib and CDS trees used at the moment.
;               
; Side effects: User awareness increased. Authors of routines with 
;               non-standard documentation embarrassed (hopefully).
;               
; Category    : Doc, help
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 5-May-94
;               
; Modified    : Look for save file in CDS_INFO, CDP, 20-May-1994
;               Add prog keyword.  CDP, 13-Jun-94
;               Make LINES a keyword and string search the only parameter.
;                                  CDP, 14-Sep-94
;               To include category option.  CDP, 20-Sep-94
;               Added /NAME keyword and explicit wildcard.  CDP, 14-Feb-95
;               Added check for existence of save files. DMZ, 28-Feb-95
;               Add hardcopy option.  CDP, 11-Apr-97
;               Add keep keyword.  CDP, 25-Jan-99
;
; Version     : Version 8, 10-Apr-97
;-            

pro tftd, key, lines=lines, prog=prog, cat=cat, $
               name=name, hard=hard, keep=keep


;
;  storage for possible hardcopy
;
hout = strarr(1000)

;
;  number of lines specified?
;
if not keyword_set(lines) then lines = 10

;
;  is the category option required?
;
category = 0
if keyword_set(cat) then begin
   category = 1
   if not keyword_set(prog) then begin
      file=concat_dir('$CDS_INFO','category_user.save')
      clook=loc_file(file,count=count)
      if count gt 0 then restore,file
   endif else begin
      file=concat_dir('$CDS_INFO','category_prog.save')
      clook=loc_file(file,count=count)
      if count gt 0 then restore,file
   endelse
endif
   
;
; read appropriate one-liner list
;
if not keyword_set(prog) then begin
   file=concat_dir('$CDS_INFO','1liners_user.save')
   clook=loc_file(file,count=count)
   if count gt 0 then restore,file
endif else begin
   file=concat_dir('$CDS_INFO','1liners_prog.save')
   clook=loc_file(file,count=count)
   if count gt 0 then restore,file
endelse

if count eq 0 then begin
 message,'Cannot locate save files',/cont & return
endif


;
;  act according to whether simple purpose search or by category
;
case category of
  0: begin

;
;  limit number of selections
;
        lines = lines < 50

;
;  was a search key specified?
;
        if n_params() eq 1 then begin
           mup = strupcase(mlist)
           key = strupcase(key)
           if strpos(key,'*') ge 0 then begin
              remchar,key,'*'
              if keyword_set(name) then begin
                 nn = where(strpos(strmid(mup,0,18),key) eq 0)
              endif else begin
                 nn = where(strpos(mup,key) eq 0)
              endelse
           endif else begin
              if keyword_set(name) then begin
                 nn = where(strpos(strmid(mup,0,18),key) ge 0)
              endif else begin
                 nn = where(strpos(mup,key) ge 0)
              endelse
           endelse
           if nn(0) ge 0 then begin
              mlist = mlist(nn)
              mlist = mlist(rem_dup(mlist))
              lines = n_elements(mlist)
              n = indgen(lines)
           endif else begin
              print,'No matches.'
              return
           endelse
        endif else begin
;
;  no search requested, just by numbers.
;  crude method to ensure get number requested.
;
           while n_elements(n) lt lines do begin
              n = fix(randomu(seed,lines)*(n_elements(mlist)-1))
              n = n(rem_dup(n))
           endwhile
        endelse

;
;  sort list (n is already sorted by rem_dup)
;
        mlist = mlist(sort(mlist))
        
;
;  output the result
;
        print,' '
        if not keyword_set(prog) then begin
           print,'Thoughts for the day produced by TFTD q.v.'
        endif else begin
           print,'Thoughts for the day (programmers) produced by TFTD q.v.'
        endelse
        print,' '
        for i=0,lines-1 do begin
           hout(i) = strmid(mlist(n(i)),0,78)
           print,hout(i)
        endfor
        print,' '
     end

  1: begin
        if cat eq '?' then begin
           catlist = strmid(catlist,19,100)
           catlist = catlist(rem_dup(catlist))
           cup = strlowcase(catlist)
           text = ' '
           for i=0,n_elements(cup)-1 do text = text + cup(i) + '*'
           text = repstr(text,'.','*')
           text = repstr(text,',','*')
           textarr = str_sep(text,'*')
           textarr = textarr(rem_dup(textarr))
           print_str,textarr   
           if keyword_set(hard) then print_str,textarr,/hard,/q   
        endif else begin
           upcat = strupcase(cat)
           cup = strupcase(catlist)
           nn = where(strpos(strmid(cup,18,80),upcat) ge 0)
           if nn(0) ge 0 then begin
              catlist = catlist(nn)
              catlist = catlist(rem_dup(catlist))
              mlist = mlist(rem_dup(mlist))
              lines = n_elements(catlist)
              for i=0,lines-1 do begin
                 hit = where(strpos(mlist,strmid(catlist(i),0,18)) ge 0)
                 if hit(0) ge 0 then begin
                    hout(i) = mlist(hit)
                    print,hout(i)
                 endif
              endfor
           endif else begin
              print,'No category entries of that type.'
              return
           endelse
        endelse
     end

else:
endcase

;
;  hardcopy if needed
;
if keyword_set(hard) then begin
   n = where(hout ne '',count)
   if count gt 0 then hout = hout(n)
   print_str,hout,/hard,/q
endif

;
;  keep file copy if needed
;
if keyword_set(keep) then begin
   n = where(hout ne '',count)
   if count gt 0 then hout = hout(n)
   print_str,hout,/keep,/q,file='tftd_results'
endif

end
