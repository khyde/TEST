; $Id:	a_cdom_save_make.pro,	March 19 2010	$
;
 ; HISTORY:
;		May 18,2008 Combine a_cdom_km_save_make and a_cdom_mannino_save_make  :	T.Ducas
;-
; *************************************************************************

PRO A_CDOM_SAVE_MAKE,DIR_IN=DIR_IN,DIR_OUT=DIR_OUT,DATE_RANGE=DATE_RANGE,$
									A_CDOM_ALGS=A_CDOM_ALGS,PERIOD_CODE=PERIOD_CODE,MAP=MAP,OVERWRITE=OVERWRITE

  ROUTINE_NAME='A_CDOM_SAVE_MAKE'

	IF N_ELEMENTS(PERIOD_CODE) NE 1 THEN _PERIOD_CODE ='S' ELSE _PERIOD_CODE=PERIOD_CODE
	IF N_ELEMENTS(A_CDOM_ALGS) LT 1 THEN A_CDOM_ALGS = 'MANNINO'
	IF KEYWORD_SET(OVERWRITE) THEN _OVERWRITE = 1 ELSE _OVERWRITE = 0
	IF N_ELEMENTS(DIR_IN) LT 1 THEN STOP
 	IF N_ELEMENTS(DIR_OUT) EQ 1 THEN BEGIN
 		IF FILE_TEST(DIR_OUT,/DIRECTORY) EQ 0L THEN FILE_MKDIR,DIR_OUT
	ENDIF
	PROD='A_CDOM'

  FOR ATH = 0L, N_ELEMENTS(A_CDOM_ALGS)-1 DO BEGIN
    IF A_CDOM_ALGS(ATH) EQ 'MANNINO' THEN BEGIN
  		_ALG=A_CDOM_ALGS(ATH)
  		PROD_TYPE ='355'
  		FA_412= PARSE_IT(FILE_SEARCH(DIR_IN+_PERIOD_CODE+'_*-RRS_412.SAVE')) & FA_412=FA_412[SORT(FA_412.DATE_START)]
  		FA_555= PARSE_IT(FILE_SEARCH(DIR_IN+_PERIOD_CODE+'_*-RRS_555.SAVE')) & FA_555=FA_555[SORT(FA_555.DATE_START)]

  		IF FA_412(0).FULLNAME EQ '' OR FA_555(0).FULLNAME EQ '' THEN BEGIN
  			PRINT, 'NEED RRS_412 and RRS_555 SAVE FILES TO MAKE A_CDOM-MANNINO'
  			GOTO,DONE_MANNINO
  		ENDIF

  		IF N_ELEMENTS(DATE_RANGE) EQ 2 THEN BEGIN
  			OK_412= WHERE(FA_412.DATE_START GE DATE_RANGE(0) AND FA_412.DATE_END LE DATE_RANGE(1),COUNT_412) & IF COUNT_412 GE 1 THEN FA_412 = FA_412(OK_412)
  			OK_555= WHERE(FA_555.DATE_START GE DATE_RANGE(0) AND FA_555.DATE_END LE DATE_RANGE(1),COUNT_555) & IF COUNT_555 GE 1 THEN FA_555 = FA_555(OK_555)
  		ENDIF

  		IF N_ELEMENTS(DIR_OUT) LT 1 THEN DIR_OUT=FA_555(0).DIR

  	 	FOR _FILES = 0L,N_ELEMENTS(FA_555)-1L DO BEGIN
  			AFILE_555=FA_555(_FILES).FULLNAME
  	  	ADATE = FA_555(_FILES).DATE_START
  	  	OK_412 = WHERE(FA_412.DATE_START EQ ADATE,COUNT)
        IF COUNT NE 1 THEN CONTINUE
        AFILE_412 = FA_412(OK_412).FULLNAME
  			SAVEFILE = DIR_OUT+REPLACE(FA_555(_FILES).FIRST_NAME,'RRS_555',PROD)+'_'+PROD_TYPE+'-'+ _ALG+'.save'
  			FA_SAVE=FILE_INFO(SAVEFILE)
        FI_412 =FILE_INFO(AFILE_412)
        FI_555 =FILE_INFO(AFILE_555)
  			IF FILE_TEST(SAVEFILE) EQ 1 AND NOT KEYWORD_SET(OVERWRITE) AND FA_SAVE.MTIME GT FI_412.MTIME AND FA_SAVE.MTIME GT FI_555.MTIME THEN CONTINUE

  	;   =====> Get Matching 412 for this day
  	    
  	    DATA_412  = STRUCT_SD_READ(AFILE_412,PROD='RRS_412',STRUCT=STRUCT_412,COUNT=COUNT_GOOD,SUBS=OK_GOOD,ERROR=ERROR)
  	    DATA_555 = STRUCT_SD_READ(AFILE_555,prod='RRS_555',STRUCT=STRUCT_555,COUNT=COUNT_GOOD,SUBS=OK_GOOD,ERROR=ERROR)
		 		A_CDOM = A_CDOM_MANNINO(RRS412=STRUCT_412.IMAGE, RRS555=STRUCT_555.IMAGE)
		    STRUCT_SD_WRITE,SAVEFILE,PROD=PROD+'_'+PROD_TYPE, ALG=_ALG,IMAGE=A_CDOM,MISSING_CODE=MISSINGS(A_CDOM), $				                
				                SCALING='LINEAR',INTERCEPT=0.0,SLOPE=1.0,DATA_UNITS=UNITS(PROD),TRANSFORMATION='',$
				                PERIOD=FA_555(_FILES).PERIOD,INFILE=[AFILE_412,AFILE_555],NOTES=NOTES
    		GONE,DATA_412
    		GONE,DATA_555
    		GONE,STRUCT
      ENDFOR ;	 	FOR _FILES = 0L,N_ELEMENTS(FA_555)-1L DO BEGIN
    ENDIF ; IF A_CDOM_ALGS(ATH) EQ 'MANNINO' THEN BEGIN
    DONE_MANNINO:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    IF A_CDOM_ALGS(ATH) EQ 'KM' THEN BEGIN
  		_ALG='KM'
  		PROD_TYPE ='300'
      FA_443= FILE_ALL(DIR_IN+_PERIOD_CODE+'_*-RRS_443.SAVE') & FA_443=FA_443[SORT(FA_443.DATE_START)]
      FA_510= FILE_ALL(DIR_IN+_PERIOD_CODE+'_*-RRS_510.SAVE') & FA_510=FA_510[SORT(FA_510.DATE_START)]

      IF FA_443(0).FULLNAME EQ '' OR FA_510(0).FULLNAME EQ '' THEN BEGIN
        PRINT, 'NEED RRS_443 and RRS_510 SAVE FILES TO MAKE A_CDOM-KM'
        GOTO,DONE
      ENDIF

      IF N_ELEMENTS(DATE_RANGE) EQ 2 THEN BEGIN
        OK_443= WHERE(FA_443.DATE_START GE DATE_RANGE(0) AND FA_443.DATE_END LE DATE_RANGE(1),COUNT_443) & IF COUNT_443 GE 1 THEN FA_443 = FA_443(OK_443)
        OK_510= WHERE(FA_510.DATE_START GE DATE_RANGE(0) AND FA_510.DATE_END LE DATE_RANGE(1),COUNT_510) & IF COUNT_510 GE 1 THEN FA_510 = FA_510(OK_510)
      ENDIF

		  IF N_ELEMENTS(DIR_OUT) LT 1 THEN DIR_OUT=FA_443(0).DIR

	    FOR _FILES = 0L,N_ELEMENTS(FA_443)-1L DO BEGIN
        AFILE_443=FA_443(_FILES).FULLNAME
        ADATE = FA_443(_FILES).DATE_START
        SAVEFILE = DIR_OUT+REPLACE(FA_443(_FILES).FIRST_NAME,FA_443(_FILES).PROD,PROD)+'_'+PROD_TYPE+'-'+ _ALG+'.save'
        FA_SAVE=FILE_INFO(SAVEFILE)
        IF FILE_TEST(SAVEFILE) EQ 1 AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE

    ;   =====> Get Matching 510 for this day
        OK_510 = WHERE(FA_510.DATE_START EQ ADATE,COUNT)
        IF COUNT NE 1 THEN CONTINUE
        AFILE_510 = FA_510(OK_510).FULLNAME
        DATA_443  = STRUCT_SD_READ(AFILE_443,PROD='RRS_443',STRUCT=STRUCT,COUNT=COUNT_GOOD,SUBS=OK_GOOD,ERROR=ERROR)
        DATA_510  = STRUCT_SD_READ(AFILE_510,prod='RRS_510',STRUCT=STRUCT,COUNT=COUNT_GOOD,SUBS=OK_GOOD,ERROR=ERROR)
        A_CDOM    = A_CDOM_KM(LWN443=DATA_443, LWN510=DATA_510, /RRS)
        STRUCT_SD_WRITE,SAVEFILE,PROD=PROD+'_'+PROD_TYPE, ALG=_ALG,IMAGE=A_CDOM,MISSING_CODE=MISSINGS(A_CDOM), $
                        MASK=STRUCT.MASK,CODE_MASK=STRUCT.CODE_MASK,CODE_NAME_MASK=STRUCT.CODE_NAME_MASK, $
                        SCALING='LINEAR',INTERCEPT=0.0,SLOPE=1.0,DATA_UNITS=UNITS(PROD),TRANSFORMATION='',$
                        PERIOD=FA_555(_FILES).PERIOD,INFILE=[AFILE_443,AFILE_510],NOTES=NOTES
		    GONE,DATA_A
        GONE,DATA_B
        GONE,STRUCT
  		ENDFOR ; FOR _FILES = 0L,N_ELEMENTS(FB)-1L DO BEGIN
    ENDIF ;	IF COUNT_KM GE 1 THEN BEGIN
  ENDFOR ; FOR ATH = 0L, N_ELEMENTS(A_CDOM_ALGS)-1 DO BEGIN



 DONE:
 END; #####################  End of Routine ################################
