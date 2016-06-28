	PRO doy2date, DOY, year, month, day, yymmdd
;	----------------------------------------------------------------
;+							19-Sep-91
;	NAME:
;		doy2date
;	PURPOSE:
;		convert DOY and year to month and day.
;	CALLING SEQUENCE:
;		DOY2date, DOY, year, month, day [, yymmdd]
;	INPUT:
;		doy	day of year
;		year	year (e.g. 90, 91, 92...)
;	OUTPUT:
;		month	month number (01,02,03,..)
;		day	day of the month
;	Optional/Output:
;		yymmdd	string with 'yymmdd'
;	HISTORY:
;		Extended from Mons Morrison's DOY2Date,
;		done 19-Sept-91 by GAL.
;-
;	---------------------------------------------------------------
;	ON_ERROR, 2	;force a return to caller on error

;	YO Mons, do really need to keep this Common block????????	
	common doy2date_blk, last_year, yarr_mon, yarr_date

;
;	           J   F   M   A   M   J   J   A   S   O   N   D  Leap
	mon_arr = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 10]

	if (n_elements(last_year) eq 0) then last_year = -99

	if (year ne last_year) then begin
	    mon_arr(1) = 28					;RESET
	    IF ((year mod 4) eq 0) then mon_arr(1)=29
	    ;1904,1908,1912,1916....1964,1968...,1980,1984,1988,1992

	    yarr_mon  = intarr(367)
	    yarr_date = intarr(367)
	    imon = 1
	    idat = 1
	    for i=1,366 do begin
		yarr_mon(i) = imon
		yarr_date(i) = idat
		idat = idat + 1
		if (idat gt mon_arr(imon-1)) then begin
		    imon = imon+1
		    idat = 1
		end
	    end

	    last_year = year
	end

	month = yarr_mon(doy)
	day   = yarr_date(doy)
	
	IF (N_PARAMS() EQ 5) THEN BEGIN		;pass back 'yymmnn'
          yy = STRTRIM( STRING(YEAR), 2)
	  mm = STRTRIM( STRING(format='(i2.2)',month), 2)
	  dd = STRTRIM( STRING(format='(i2.2)',day), 2)
	  yymmdd = yy + mm + dd
	ENDIF

	END
