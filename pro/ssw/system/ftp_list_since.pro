function ftp_list_since, listing, count=count, ndays=ndays, nhours=nhours, $
   older=older, utoff=utoff, upat=upat, ftimes=ftimes
;
;+
;   Name: ftp_list_since
;
;   Purpose: return ftp file list newer than or older than NDAYS (or NHOURS)
;
;   Input Parameters:
;      listing - strarr list from ftp 'ls' or 'dir' (or ftp url)
;      ndays - number of days for compare
;
;   Output Parameters:
;      function returns files more recent (or older) than specified
;
;   Calling Examples:
;      IDL> newf=ftp_list_since(ftplisting,NHOURS=12,UTOFF=-5) ; <=12 hrs. old 
;      IDL> oldf=ftp_list_since(ftplisting,NDAYS=100,/OLDER)   ; >=100 days old 
;
;   Keyword Parameters:
;      OLDER - if set, files older than {NDAYS or NHOURS} - def=NEWER
;      NDAYS - desired window in #DAYS
;      NHOURS - desired window in #HOURS
;      UTOFF - optionally, dT(ftp server times:UT) ; signed hours from UT
;      UPAT - optional uniq string pat to consider - default = '-r'
;      COUNT (output) - number of files returned
;      FTIMES (output) - times of files returned (server time zone)
;
;   Restrictions:
;      Must supply either NDAYS or NHOURS
;      use of ftp://<url> instead of listing implies anon ftp -and-
;         IDL V>=5.4 (via sockets) - NOT YET TESTED...
;      Note: time zone of the ftp sever is unknown so if you are worried
;      about granularity on order of NHOURS instead of NDAYS, you may want to 
;      supply UTOFF (or ~equivlently, pad NHOURS accordingly..)
;
;-

rcount=0 ; number of files returned - pessimistically assume none
case 1 of 
   1-data_chk(listing,/string): begin
      box_message,'Must provide ftp listing or ftp url...'
      return,''
   endcase
   n_elements(listing) eq 0 and strpos(listing(0),'ftp:') eq 0: begin 
      sock_list,listing,ftplist
   endcase
   else: ftplist=listing
endcase

case 1 of
   keyword_set(ndays): val=ndays
   keyword_set(nhours): val=nhours
   else: begin 
      box_message,'Must supply either NDAYS or NHOURS
      return,''
   endcase
endcase

if n_elements(upat) eq 0 then upat='-r'

ssf=where(strpos(ftplist,upat) ne -1,sscnt)
if sscnt eq 0 then begin 
   box_message,'No files in list??'
   return,''
endif
first=strcompress(ftplist(ssf(1)))
ncols=n_elements(where_pattern(first,' '))+1 ; cols=nblanks+1 
utnow=reltime(/now,out='ecs')
nyear=strmid(utnow,0,4)

years=replicate(nyear,sscnt)

cols=str2cols(ftplist(ssf),/unal,/trim)
strtab2vect,cols,mm,dd,time,files,col=indgen(4)+(ncols-4)

old=where(strpos(time,':') eq -1,ocnt)

if ocnt gt 0 then begin 
   years(old)=time(old)
   time(old)='00:00'
endif
ftimes=dd+'-' + mm + '-' + years + ' ' + time

if n_elements(utoff) eq 0 then utoff=0
dtn=ssw_deltat(reltime(/now,hours=utoff(0)),ref=ftimes,hours=nhours,days=ndays)
if keyword_set(older) then ss=where(dtn ge val,sscnt) else $
  ss=where(dtn le val,sscnt)

if sscnt eq 0 then retval='' else begin
   retval=files(ss)
   ftimes=ftimes(ss)
endelse

count=n_elements(retval) * (retval(0) ne '')

return,retval
end





