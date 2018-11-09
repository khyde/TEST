; $Id:	a_cdom_mannino.pro,	April 22 2013	$

 FUNCTION A_CDOM_MANNINO, RRS_412=rrs_412, RRS_443=rrs_443, RRS_555=rrs_555, RRS_547=rrs_547, RRS_667=rrs_667, RRS_670=rrs_670, AT_412=at_412, AT_443=at_443, SATELLITE=satellite, GET_ALGS=get_algs, ERROR=error, ERR_MSG=err_msg, SENSOR=sensor
;+
; NAME:
; 	A_CDOM_MANNINO
;
; PURPOSE:
;		This Function computes Absorption at 355nm by CDOM (ACDOM_355) the Mannino algorithm and SeaWiFS and or MODIS Rrs data
;
; CATEGORY:
;		ALGORITHM
;
; CALLING SEQUENCE:		 ;
;		Result = A_CDOM_MANNINO(Rrs412=Rrs412,Rrs555=Rrs555)
;
; INPUTS:
;		SeaWiFS:
;			Rrs412:	Remote Sensing Reflectance at 412nm
;			Rrs555:	Remote Sensing Reflectance at 555nm
;
; KEYWORD PARAMETERS:
;		LWN:	Indicates that the input Rrs is actually LWN and the program will then convert these LWNs into Rrs
;
; OUTPUTS:
;		This function returns ACDOM_355, The absorption by CDOM at 355nm
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; EXAMPLE:
;		Result = A_CDOM_MANNINO(Rrs412=Rrs412,Rrs555=Rrs555)
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;
; MODIFICATION HISTORY:
;			Written:  July 9, 2006     - A. Mannino & J.O'Reilly (Jay.O'Reilly@NOAA.GOV)
;		  Modified: March 16, 2007   - Latest Algorithm Coefficients from Antonio Mannino
;     Modified: Jan 7, 2008      - Lowered NLW_LOW from 0.2 to 0.1 , add keyword ALG  ; TeresaDucas
;     Modified: April 9, 2008    - Received equation from Antonio Mannino;   A_CDOM355 = alog(((Rrs490/Rrs555)-0.488225)/3.03165)/(-3.50104)
;     Modified: March 19, 2010   - Recieved new equation from Antonio Manino A_CDOM355 = alog((Rrs412/Rrs555-0.24676)/4.5002)/(-5.5593)
;     Modified: January 31, 2011 - Added Keyword SENSOR to distinguish between MODIS and SeaWiFS algorithms and added equation for Rrs547 received from A. Mannino
;     Modified: April 22, 2013   - Updated program to include several new algorithms from A. Mannino
;     Modified: May, 13, 2015    - Added GET_ALGS keyword to return the algorithm names.
;-
;	****************************************************************************************************
	ROUTINE_NAME='A_CDOM_MANNINO'
  ERROR = []
  ERR_MSG = []

;	===> Lower cutoff value (in RRS units)
	RRS_LOW = 0.0

;	RRS_412 = [0.00430675,0.004722,0.003713,0.00564475,0.00599525,0.0034025,0.00262028571428571,0.00709355555555555,0.003498,0.00272175,0.0025545,0.0034125,0.00351444444444444,0.0029365,0.004244,0.00156275,0.00213025,0.00347975,0.000678,0.0018325,0.00178375,0.00411314285714286,0.001983,0.00294228571428571,0.00756257142857143,0.0095595,0.00769866666666666,0.004108,0.0042515,0.0043315,0.00156942857142857,0.00145025,0.00203085714285714,0.00240225,0.00328228571428571,0.00249825]	
;	RRS_443 = [0.0048435,0.004834,0.00434866666666667,0.00542444444444444,0.0058755,0.0033885,0.00293571428571429,0.00897044444444444,0.00424257142857143,0.00337725,0.002974,0.003354,0.0040465,0.003508,0.00400825,0.00194075,0.0021805,0.00349575,0.001204,0.00212925,0.0022545,0.00347675,0.00198822222222222,0.00296114285714286,0.00797,0.01021575,0.00839875,0.00391,0.0037535,0.00385975,0.00217525,0.00206911111111111,0.00261275,0.00245044444444444,0.00437571428571428,0.003802]	
;	RRS_555 = [0.0095005,0.00805428571428571,0.00837342857142857,0.00808914285714285,0.00801325,0.00272825,0.00244342857142857,0.0143388571428571,0.00448575,0.003021,0.00239914285714286,0.00239911111111111,0.00704355555555555,0.00746444444444444,0.00263075,0.00159342857142857,0.00213555555555555,0.00286028571428571,0.00228857142857143,0.00226775,0.00188575,0.00234075,0.00213575,0.00209171428571429,0.00581771428571429,0.00984575,0.0086725,0.00387875,0.00283325,0.00238275,0.0018565,0.00178371428571429,0.00191225,0.001392,0.00704725,0.00518375]
;	RRS_670 = [0.0036175,0.00261125,0.002461,0.002474,0.00245425,0.000511333333333333,0.000445777777777778,0.00443028571428571,0.000784888888888889,0.00046025,0.000381111111111111,0.000546,0.00189133333333333,0.00199971428571429,0.0002485,0.000252,0.0005705,0.000531428571428571,0.000584857142857143,0.000421142857142857,0.000301428571428571,0.00046975,0.000791,0.000286285714285714,0.00091075,0.0019605,0.00168225,0.00071875,0.0004085,0.000329142857142857,0.00026925,0.000240285714285714,0.00025475,0.000295,0.0017565,0.0012665]
;	AT_412  = [0.086125,0.0313625,0.0827933333333331,0.000206349206349044,0.014325,0.018425,0.035125,0.0866875,0.046746031746032,0.0501375,0.039888888888889,0.0179444444444445,0.061680555555556,0.115475,0.0114,0.059375,0.0282,0.0206625,0.358603571428572,0.054775,0.065705357142857,0.00108749999999999,0.026114285714285,0.0214303571428572,0.0184339285714286,0.019533333333333,0.028875,0.00660000000000002,0.00646071428571431,0.00645,0.078914285714285,0.083944642857143,0.0536625,0.0243125,0.0987125,0.1190875]
;	AT_443  = REPLICATE(0.0,N_ELEMENTS(AT_412)) 
	
;	RRS_412 = [0.00199675,0.0036455,0.0068655,0.00409822222222222,0.00353971428571429,0.0031455,0.00163571428571429,0.00236075,0.00113525,0.0020745,0.00485257142857143,0.0047045,0.00210133333333333,0.0026865,0.00250275,0.00191425,0.002038,0.00211775,0.00207325,0.00357825,0.00560371428571429,0.00446575,0.00189575,0.00225125,0.0022795,0.00244875,0.001853,0.001537,0.0016425,0.001579,0.00164488888888889,0.00632425,0.00166075,0.00140075,0.00272755555555556,0.00293025,0.00298775,0.00321725,0.00183428571428571,0.00131925,0.001442,0.001144,0.001006,0.00258888888888889,0.00255325,0.00202333333333333,0.00133022222222222,0.00165485714285714,0.00136142857142857,0.00131075,0.0021975,0.000869,0.00214575,0.00253914285714286,0.00201125]
;	RRS_443 = [0.0038975,0.00388444444444444,0.00910714285714286,0.00473111111111111,0.00392355555555556,0.00342275,0.00311971428571429,0.003703,0.00251666666666667,0.00267625,0.00477475,0.00472644444444445,0.00236375,0.00312375,0.003052,0.00252225,0.00269425,0.00271688888888889,0.002858,0.00562555555555556,0.00834525,0.00685933333333333,0.0018925,0.001858,0.00191425,0.002585,0.0022685,0.002147,0.00232511111111111,0.0020585,0.00230575,0.00999628571428572,0.00254355555555555,0.002351,0.0032545,0.00347088888888889,0.00338025,0.00371971428571429,0.00280057142857143,0.00250022222222222,0.00261575,0.002358,0.0023355,0.00268571428571429,0.00226755555555556,0.00261625,0.00196275,0.0027015,0.00222028571428571,0.00246822222222222,0.00321314285714286,0.0017345,0.002868,0.00326285714285714,0.002787]
;	RRS_547 = [0.0105762857142857,0.00749775,0.0142525714285714,0.00485475,0.00344177777777778,0.00258975,0.00872875,0.00782125,0.0076105,0.00264342857142857,0.0020505,0.0019355,0.002124,0.00297685714285714,0.002712,0.00247775,0.00216942857142857,0.00288511111111111,0.00294822222222222,0.0090985,0.01434375,0.0115495555555556,0.00167225,0.00172425,0.00169325,0.00333628571428571,0.00272075,0.00185355555555556,0.00178325,0.00173875,0.0019055,0.0167528571428571,0.002553,0.001781,0.00303555555555556,0.0034365,0.002513,0.00227575,0.00182971428571429,0.0017585,0.0023175,0.00211971428571429,0.00204225,0.00280355555555556,0.00372975,0.004249,0.00146111111111111,0.00315175,0.00198542857142857,0.00205288888888889,0.00177025,0.00161625,0.002081,0.002314,0.00236125]
;	RRS_667 = [0.0050875,0.0025465,0.004856,0.000760857142857143,0.000475777777777778,0.000316285714285714,0.00315575,0.00214725,0.002319,0.00018,0.00020875,0.00018875,0.000396,0.000681714285714286,0.0005645,0.0004435,0.000294571428571429,0.000638285714285714,0.0006025,0.00238275,0.00604288888888889,0.0037265,0.000365333333333333,0.00044925,0.000368285714285714,0.000690857142857143,0.0005625,0.00042675,0.000325,0.000409,0.000287142857142857,0.00631525,0.0003805,0.00014275,0.00032325,0.00049725,0.00022325,0.000176,0.00017,0.00016975,0.00039675,0.000313,0.00031,0.00057075,0.00100475,0.00096875,0.0002915,0.000631,0.000362285714285714,0.000198,0.000143,9.57142857142857E-05,0.000414,0.00026975,0.0003335]
;	AT_412  = [0.755222222222222,0.0611222222222222,0.104251785714286,0.035175,0.0298472222222222,0.0252,0.629257142857143,0.2250125,0.974525,0.06075,0.0112142857142857,0.0119625,0.0405597222222222,0.04405,0.0460482142857143,0.0729160714285715,0.0580285714285714,0.0650269841269841,0.0776464285714286,0.159385714285714,0.186331944444445,0.179780555555555,0.0271458333333333,0.00309999999999999,0.00596071428571429,0.0328138888888889,0.06855,0.08185,0.0697513888888888,0.072275,0.0686857142857143,0.1919375,0.0937319444444445,0.0939482142857143,0.0421875,0.0429767857142857,0.0300986111111111,0.0292535714285714,0.0680857142857143,0.11375,0.127644642857143,0.1628375,0.195798214285714,0.027525,0.00455,0.100175,0.0853472222222223,0.117875,0.10615,0.124788888888889,0.0515142857142857,0.1787375,0.057525,0.0442196428571429,0.0673819444444444]
;	AT_443  = REPLICATE(0.0,N_ELEMENTS(AT_412)) 
	 
	IF N_ELEMENTS(RRS_412) EQ 0 THEN RRS412 = [] ELSE RRS412 = DOUBLE(RRS_412) 
	IF N_ELEMENTS(RRS_443) EQ 0 THEN RRS443 = [] ELSE RRS443 = DOUBLE(RRS_443)
	IF N_ELEMENTS(RRS_555) EQ 0 THEN RRS555 = [] ELSE RRS555 = DOUBLE(RRS_555)
	IF N_ELEMENTS(RRS_547) EQ 0 THEN RRS547 = [] ELSE RRS547 = DOUBLE(RRS_547)
	IF N_ELEMENTS(RRS_667) EQ 0 THEN RRS667 = [] ELSE RRS667 = DOUBLE(RRS_667)
	IF N_ELEMENTS(RRS_670) EQ 0 THEN RRS670 = [] ELSE RRS670 = DOUBLE(RRS_670)
	IF N_ELEMENTS(AT_412)  EQ 0 THEN AT412  = [] ELSE AT412  = DOUBLE(AT_412)
	IF N_ELEMENTS(AT_443)  EQ 0 THEN AT443  = [] ELSE AT443  = DOUBLE(AT_443)
	
	 	
; ===> Initialize ACDOM_355 array to same size as Rrs412
	IF ANY(RRS412) THEN TEMP = DOUBLE(RRS412)
  IF NONE(TEMP) AND ANY(RRS443) THEN TEMP = DOUBLE(RRS443)
  IF NONE(TEMP) AND ANY(RRS547) THEN TEMP = DOUBLE(RRS547)
  IF NONE(TEMP) AND ANY(RRS555) THEN TEMP = DOUBLE(RRS555)
  IF NONE(TEMP) AND ANY(RRS667) THEN TEMP = DOUBLE(RRS667)
  IF NONE(TEMP) AND ANY(RRS670) THEN TEMP = DOUBLE(RRS670)
	IF KEY(GET_ALGS) THEN TEMP = ''
	TEMP(*) = MISSINGS(TEMP)
	
;	===> aCDOM(355) (m-1)
;  ACDOM_355(OK) = ALOG10((_Rrs412(OK)/_Rrs555(OK)-0.24676)/4.5002)/(-5.5593) ; ORIGINAL ACDOM_355 EQUATION - REPLACED 4/22/2013 BY K. HYDE
;  ACDOM_355(OK) = ALOG10((_Rrs421(OK)/_Rrs547(OK)-0.272208/4.48858)/(-5.777)

  STRUCT = CREATE_STRUCT('EX555_A275', TEMP,'EX555_A355', TEMP,'EX555_A380', TEMP,'EX555_A412', TEMP,'EX555_A443', TEMP,$
                         'EX670_A275', TEMP,'EX670_A355', TEMP,'EX670_A380', TEMP,'EX670_A412', TEMP,'EX670_A443', TEMP,$                         
                         'MLR_A275',   TEMP,'MLR_A355',   TEMP,'MLR_A380',   TEMP,'MLR_A412',   TEMP,'MLR_A443',   TEMP,'MLR_S275',   TEMP,'MLR_S300',   TEMP,$
                         'QAA443_A275',TEMP,'QAA443_A355',TEMP,'QAA443_A380',TEMP,'QAA443_A412',TEMP,'QAA443_A443',TEMP,'QAA443_S275',TEMP,'QAA443_S300',TEMP,$
                                            'QAA412_A355',TEMP,'QAA412_A380',TEMP,'QAA412_A412',TEMP,'QAA412_A443',TEMP)
  
  IF KEY(GET_ALGS) THEN RETURN, TAG_NAMES(STRUCT)
  
  IF RRS412 NE [] AND RRS547 NE [] THEN BEGIN
    OK = WHERE(RRS412 NE MISSINGS(RRS412) AND FINITE(RRS412) AND RRS412 GE RRS_LOW AND $
               RRS547 NE MISSINGS(RRS547) AND FINITE(RRS547) AND RRS547 GE RRS_LOW AND $
               RRS412/RRS547 GE 0.310,COUNT)
    IF COUNT GE 1 THEN BEGIN
      Y = RRS412(OK)/RRS547(OK)            ; Exponential One-Phase Decay - RRS547 MODIS
      STRUCT.EX555_A275(OK) = ALOG((Y-0.2792)/21.95)/(-1.582) ; X = Ln[(Y-B0)/B2]/-B1
    ENDIF
    OK = WHERE(RRS412 NE MISSINGS(RRS412) AND FINITE(RRS412) AND RRS412 GE RRS_LOW AND $
               RRS547 NE MISSINGS(RRS547) AND FINITE(RRS547) AND RRS547 GE RRS_LOW AND $
               RRS412/RRS547 GE 0.295,COUNT)
    IF COUNT GE 1 THEN BEGIN
      Y = RRS412(OK)/RRS547(OK)            ; Exponential One-Phase Decay - RRS547 MODIS 
      STRUCT.EX555_A275(OK) = ALOG((Y-0.2792)/21.95)/(-1.582) ; X = Ln[(Y-B0)/B2]/-B1
      STRUCT.EX555_A355(OK) = ALOG((Y-0.2652)/4.337)/(-5.534)
      STRUCT.EX555_A380(OK) = ALOG((Y-0.2676)/4.054)/(-8.484)
      STRUCT.EX555_A412(OK) = ALOG((Y-0.2675)/3.619)/(-13.74)
      STRUCT.EX555_A443(OK) = ALOG((Y-0.2678)/3.406)/(-23.28)
    ENDIF  
  ENDIF

  IF RRS412 NE [] AND RRS555 NE [] THEN BEGIN
    OK = WHERE(RRS412 NE MISSINGS(RRS412) AND FINITE(RRS412) AND RRS412 GE RRS_LOW AND $
               RRS555 NE MISSINGS(RRS555) AND FINITE(RRS555) AND RRS555 GE RRS_LOW AND $
               RRS412/RRS555 GE 0.310, COUNT)
    IF COUNT GE 1 THEN BEGIN 
      Y = RRS412(OK)/RRS555(OK)             ; Exponential One-Phase Decay - RRS555 SeaWiFS
      STRUCT.EX555_A275(OK) = ALOG((Y-0.2581)/24.87)/(-1.583) ; X = Ln[(Y-B0)/B2]/-B1
    ENDIF
    OK = WHERE(RRS412 NE MISSINGS(RRS412) AND FINITE(RRS412) AND RRS412 GE RRS_LOW AND $
               RRS555 NE MISSINGS(RRS555) AND FINITE(RRS555) AND RRS555 GE RRS_LOW AND $
               RRS412/RRS555 GE 0.295, COUNT)
    IF COUNT GE 1 THEN BEGIN  
      Y = RRS412(OK)/RRS555(OK)             ; Exponential One-Phase Decay - RRS555 SeaWiFS
      STRUCT.EX555_A355(OK) = ALOG((Y-0.2452)/4.838)/(-5.576)
      STRUCT.EX555_A380(OK) = ALOG((Y-0.2492)/4.608)/(-8.689)
      STRUCT.EX555_A412(OK) = ALOG((Y-0.2487)/4.085)/(-14.028)
      STRUCT.EX555_A443(OK) = ALOG((Y-0.2479)/3.770)/(-23.40)
    ENDIF      
  ENDIF
    
  IF RRS412 NE [] AND RRS667 NE [] THEN BEGIN
    OK = WHERE(RRS412 NE MISSINGS(RRS412) AND FINITE(RRS412) AND RRS412 GE RRS_LOW AND $
               RRS667 NE MISSINGS(RRS667) AND FINITE(RRS667) AND RRS667 GE RRS_LOW AND $
               RRS412/RRS667 GE 1.29,COUNT)
    IF COUNT GE 1 THEN BEGIN
      Y = RRS412(OK)/RRS667(OK)             ; Exponential One-Phase Decay - RRS667 MODIS
      STRUCT.EX670_A275(OK) = ALOG((Y-0.9925)/634.2)/(-2.054) ; X = Ln[(Y-B0)/B2]/-B1      
    ENDIF  
    OK = WHERE(RRS412 NE MISSINGS(RRS412) AND FINITE(RRS412) AND RRS412 GE RRS_LOW AND $
                                  RRS667 NE MISSINGS(RRS667) AND FINITE(RRS667) AND RRS667 GE RRS_LOW AND $
                                  RRS412/RRS667 GE 1.29,COUNT)
    IF COUNT GE 1 THEN BEGIN
      Y = RRS412(OK)/RRS667(OK)             ; Exponential One-Phase Decay - RRS667 MODIS      
      STRUCT.EX670_A355(OK) = ALOG((Y-0.8569)/91.97)/(-7.661)
      STRUCT.EX670_A380(OK) = ALOG((Y-0.8650)/79.16)/(-11.55)
      STRUCT.EX670_A412(OK) = ALOG((Y-0.8625)/62.89)/(-18.44)
      STRUCT.EX670_A443(OK) = ALOG((Y-0.8502)/54.78)/(-30.53)
    ENDIF                                
  ENDIF
  
  IF RRS412 NE [] AND RRS670 NE [] THEN BEGIN
    OK = WHERE(RRS412 NE MISSINGS(RRS412) AND FINITE(RRS412) AND RRS412 GE RRS_LOW AND $
               RRS670 NE MISSINGS(RRS670) AND FINITE(RRS670) AND RRS670 GE RRS_LOW AND $
               RRS412/RRS670 GT 1.29,COUNT)
    IF COUNT GE 1 THEN BEGIN
      Y = RRS412(OK)/RRS670(OK)             ; Exponential One-Phase Decay - RRS670 SeaWiFS
      STRUCT.EX670_A275(OK) = ALOG((Y-0.9686)/958.4)/(-2.302) ; X = Ln[(Y-B0)/B2]/-B1
    ENDIF
    
    OK = WHERE(RRS412 NE MISSINGS(RRS412) AND FINITE(RRS412) AND RRS412 GE RRS_LOW AND $
               RRS670 NE MISSINGS(RRS670) AND FINITE(RRS670) AND RRS670 GE RRS_LOW AND $
               RRS412/RRS670 GT 1.10,COUNT)
    IF COUNT GE 1 THEN BEGIN
      Y = RRS412(OK)/RRS670(OK)             ; Exponential One-Phase Decay - RRS670 SeaWiFS
      STRUCT.EX670_A355(OK) = ALOG((Y-0.7723)/92.44)/(-7.794)
      STRUCT.EX670_A380(OK) = ALOG((Y-0.6850)/47.35)/(-9.522)
      STRUCT.EX670_A412(OK) = ALOG((Y-0.7074)/43.85)/(-15.86)
      STRUCT.EX670_A443(OK) = ALOG((Y-0.7857)/56.59)/(-31.79)
    ENDIF    
  ENDIF
  
  IF RRS443 NE [] AND RRS547 NE [] THEN BEGIN ; MODIS
    OK = WHERE(RRS443 NE MISSINGS(RRS443) AND FINITE(RRS443) AND RRS443 GE RRS_LOW AND $
      RRS547 NE MISSINGS(RRS547) AND FINITE(RRS547) AND RRS547 GE RRS_LOW,COUNT)
    IF COUNT GE 1 THEN BEGIN
      STRUCT.MLR_A275(OK) = EXP( 0.464+(-0.769*ALOG(RRS443(OK)))+(0.6920*ALOG(RRS547(OK))))
      STRUCT.MLR_A355(OK) = EXP(-1.960+(-1.208*ALOG(RRS443(OK)))+(1.0490*ALOG(RRS547(OK))))
      STRUCT.MLR_A380(OK) = EXP(-2.507+(-1.261*ALOG(RRS443(OK)))+(1.0880*ALOG(RRS547(OK))))
      STRUCT.MLR_A412(OK) = EXP(-3.070+(-1.285*ALOG(RRS443(OK)))+(1.1070*ALOG(RRS547(OK))))
      STRUCT.MLR_A443(OK) = EXP(-3.664+(-1.291*ALOG(RRS443(OK)))+(1.1050*ALOG(RRS547(OK))))
      STRUCT.MLR_S275(OK) = EXP(-3.258+( 0.336*ALOG(RRS443(OK)))+(-0.279*ALOG(RRS547(OK))))
      STRUCT.MLR_S300(OK) = EXP(-3.640+( 0.186*ALOG(RRS443(OK)))+(-0.146*ALOG(RRS547(OK))))
    ENDIF
  ENDIF
  
  IF RRS443 NE [] AND RRS555 NE [] THEN BEGIN ; SEAWIFS
    OK = WHERE(RRS443 NE MISSINGS(RRS443) AND FINITE(RRS443) AND RRS443 GE RRS_LOW AND $
               RRS555 NE MISSINGS(RRS555) AND FINITE(RRS555) AND RRS555 GE RRS_LOW,COUNT)
    IF COUNT GE 1 THEN BEGIN  
      STRUCT.MLR_A275(OK) = EXP( 0.643+(-0.6820*ALOG(RRS443(OK)))+(0.6300*ALOG(RRS555(OK))))
      STRUCT.MLR_A355(OK) = EXP(-1.692+(-1.0760*ALOG(RRS443(OK)))+(0.9540*ALOG(RRS555(OK))))
      STRUCT.MLR_A380(OK) = EXP(-2.227+(-1.1240*ALOG(RRS443(OK)))+(0.9900*ALOG(RRS555(OK))))
      STRUCT.MLR_A412(OK) = EXP(-2.784+(-1.1460*ALOG(RRS443(OK)))+(1.0080*ALOG(RRS555(OK))))
      STRUCT.MLR_A443(OK) = EXP(-3.379+(-1.1513*ALOG(RRS443(OK)))+(1.0060*ALOG(RRS555(OK))))
      STRUCT.MLR_S275(OK) = EXP(-3.325+( 0.3000*ALOG(RRS443(OK)))+(-0.252*ALOG(RRS555(OK))))
      STRUCT.MLR_S300(OK) = EXP(-3.679+( 0.1680*ALOG(RRS443(OK)))+(-0.134*ALOG(RRS555(OK))))
    ENDIF  
  ENDIF

  IF AT412 NE [] AND AT443 NE [] THEN BEGIN
    OK = WHERE(AT412 NE MISSINGS(AT412) AND FINITE(AT412) AND $
               AT443 NE MISSINGS(AT443) AND FINITE(AT443) AND AT412 GT AT443,COUNT)  ; AT412 must be > AT443
    IF COUNT GE 1 THEN BEGIN
      X = AT412(OK)-AT443(OK)             ; QAA-BASED AT
      STRUCT.QAA443_A275(OK) = 10.08*(X^0.4207) ; Y = A*X^B
      STRUCT.QAA443_A355(OK) = 2.671*(X^0.5750)
      STRUCT.QAA443_A380(OK) = 1.771*(X^0.5829)
      STRUCT.QAA443_A412(OK) = 1.048*(X^0.5797)
      STRUCT.QAA443_A443(OK) = 0.617*(X^0.5870)
      STRUCT.QAA443_S300(OK) = 0.0158*(X^(-0.0737))
      STRUCT.QAA443_S275(OK) = 0.0162*(X^(-0.1483))
    ENDIF 
  ENDIF
  
  IF AT412 NE [] THEN BEGIN
    OK = WHERE(AT412 NE MISSINGS(AT412) AND FINITE(AT412))
    IF COUNT GE 1 THEN BEGIN
      X = AT412(OK)             ; QAA-BASED AT
      STRUCT.QAA412_A355(OK) = 1.236*(X^0.600) ; Y = A*X^B
      STRUCT.QAA412_A380(OK) = 0.813*(X^0.616)
      STRUCT.QAA412_A412(OK) = 0.499*(X^0.646)
      STRUCT.QAA412_A443(OK) = 0.286*(X^0.648)      
    ENDIF
  ENDIF

  RETURN, STRUCT
	
  RETURN_ERROR:
  ERROR= 1
  ERR_MSG = 'ERROR: NO VALID INPUT DATA'
  RETURN, []
	


END; #####################  End of Routine ################################



