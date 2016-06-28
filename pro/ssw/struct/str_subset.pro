function str_subset, instructs, taglist, include=include, exclude=exclude, $
                     version=version, quiet=quiet, status=status, $
                     regex = regex
;+
;   Name: str_subset
;
;   Purpose: generate a (smaller) structure with a subset of selected tags
;
;   Input Parameters:
;     instructs - the parent structure(s)
;     taglist   - list of tag names to include (or exclude) in output structure
;                 (string array, comma delimited string, or template structure)
;
;   Keyword Parameters:
;     version   - optional structure version number to include (float)
;     exclude   - if set, TAGLIST is list of tags to EXCLUDE
;     quiet       - if set, doesn't print message about no tags matching
;     status     - returns 0 if no tags matched, 1 otherwise
;     regex     - if set, uses regular expression to
;                 select the subset of tags
;
;   Calling Sequence:
;      smallstr=str_subset(bigstruct, taglist [,/exclude] [,version= nn.] )
;
;   Calling Examples:
;   IDL> new=str_subset(eitstruct,'filename,wavelnth,filter,object,date_obs')
;   IDL> help,new,/str
;        ** Structure MS_232241394011, 5 tags, length=72:
;        DATE_OBS        STRING    '1997-04-30T00:20:22.000Z'
;        FILENAME        STRING    'efr19970430.002022'
;        OBJECT          STRING    'full FOV'
;        WAVELNTH        INT            195
;        FILTER          STRING    'Clear'
;
;   History:
;      6-may-1997 - S.L.Freeland
;		31-Aug-2000 - Kim Tolbert.  Added quiet and status
;                             keywords
;               01-Sep-2004 - Andre Csillaghy. Added regex keyword
;               10-mar-2005 - S.L.Freeland - raised the Version# cutoff
;                             on 1-sep-2004 enhancment (>5.3)
;               16-mar-2005 - S.L.Freeland - per Andre C suggestion, quoted the
;                             10-mar-2005 Version number...
;               23-mar-2005 - Andre - Corrected to work properly with
;                             structure arrays and tag arrays
;
;   Calls:
;      data_chk, str2arr, make_str, where_arr, fmt_tag, uniq, is_member
;
;   Restrictions:
;      nested structure handling only for Version>=5.4
;-

quiet = keyword_set(quiet)
status = 1

if (1- data_chk(instructs,/struct)) then begin
   message,/info,"IDL> smallstr=str_subset(bigstruct, taglist)
   return,''
endif

retval=instructs

; figure tag list (string, string array or structure template)
case 1 of
    data_chk(taglist,/struct): stags=tag_names(taglist)
    data_chk(taglist,/scalar,/string): stags=str2arr(taglist)
    data_chk(taglist,/string): stags=taglist
    else: begin
       message,/info,"IDL> smallstr=str_subset(bigstruct, taglist)"
      return,instructs
    endelse
endcase

stags=strtrim(strupcase(stags),2)
stags=stags(uniq(stags,sort(stags)))
alltags=tag_names(instructs)

if not keyword_set( regex ) then begin 
; ---------- match taglist to template --------------
    which=where_arr(alltags, stags, count, notequal=keyword_set(exclude))
endif else begin 
    which = wc_where_arr( alltags, stags, count, notequal=keyword_set(exclude), /case_ignore)
endelse

; add VERSION tag on request (possibly overwrite existing value)
vtag=(['',',version:0.'])( (n_elements(version) ne 0) and $
                           (1-is_member('VERSION',stags))  )

if count gt 0 then begin

; be on the conservative side...
    if since_version( '5.4' ) then begin 
        
; acs 2004-09-29 try to make it faster, make it work with nested structures,
; at least at the first level of nesting, and eliminate the call to
; make_str.
 
        retval = create_struct( alltags[which[0]], instructs[0].(which[0]) )
        for i=1, count -1 do begin 
            retval = create_struct( retval, alltags[which[i]], instructs[0].(which[i]) )
        endfor
        
        if is_number( version ) then retval = create_struct( retval, 'version', version )

        n_arr = n_elements( instructs )
        if n_arr gt 1 then begin 
            retval = replicate( retval, n_arr )
            struct_assign, instructs, retval
            dims = size( instructs, /dim )
            retval = reform( retval, dims )
        endif
            
    endif else begin 

;  ----------- build structure via make structure -------------
        str='{dummy'
        for i=0,count-1 do str=str + ',' + alltags(which(i)) + ':' + $
                               fmt_tag(size(instructs(0).(which(i))))
        newstruct=make_str(str+vtag+'}')
        
;  ------- define and fill output structure -------------
        retval=replicate(newstruct,n_elements(instructs))
        for i=0,count-1 do retval.(i)=instructs.(which(i))
        if keyword_set(version) then retval.VERSION=version
        
    endelse

endif else begin
	status = 0
	if not (quiet) then message,/info,"No tags matching desired list...."
endelse

return,retval
end


;------------------------------------------------------------

pro str_subset_test

str={one:0,two:'',three:indgen(50)}

help,str_subset(str,'one,three'),/str
;   ONE             INT              0
;   THREE           INT       Array[50]  ; OK w/scalar

strs=replicate(str,100) ; make a vector of structures
help,str_subset(strs,'one,three'),/str
;** Structure <400c2008>, 2 tags, length=10002, data length=10002, refs=1:
;   ONE             INT              0
;   THREE           INT       Array[50, 100] <<< !!Xtra Dim

;What it used to do for the above:
;IDL> .run str_subset2 ; (copy w/version cutoff set=8.0!)
;IDL> help,str_subset(strs,'one,three'),/str
;   ONE             INT              0
;   THREE           INT       Array[50] <<< as expected

gaga = str_subset(strs,'one,three')
help, gaga, /str
help, strs
;STRS            STRUCT    = -> <Anonymous> Array[100]
strs[49].three[34]=567
print, strs[49].three
help, strs, /str
;** Structure <55a6b0>, 3 tags, length=116, data length=114, refs=2:
;   ONE             INT              0
;   TWO             STRING    ''
;   THREE           INT       Array[50]
gaga = str_subset(strs,'one,three')
help, gaga
;GAGA            STRUCT    = -> <Anonymous> Array[100]
help, gaga, /str
;** Structure <555840>, 2 tags, length=102, data length=102, refs=1:
;   ONE             INT              0
;   THREE           INT       Array[50]
print, gaga[49].three              
; should have the 567 assigned

; now test for mor dimensions (with reform) and substrings
strr = add_tag( str, {tag1:bytarr(10), tag2:'blabla'}, 'four')
urf = replicate( strr, 23, 45)
help, urf
urf[12,33].four.tag2 = 'hahaha'
print, urf[12,33].four.tag2
beuleu = str_subset( urf, 'one, four' )
print, beuleu[12,33].four.tag2
print, beuleu[12,41].four.tag2

urf[0,1].three[35]=255
print, urf[0,1].three
print, urf[0,2].three
beuleu = str_subset( urf, 'three, four' )
print, beuleu[12,33].four.tag2
print, beuleu[12,41].four.tag2
print, beuleu[0,1].three
print, beuleu[0,2].three

aa = str_subset( urf, 'one' )
help, aa, /str

end
