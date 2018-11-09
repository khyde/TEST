; $Id:	A_CDOM_TWARDOWSKI.PRO,	2003 Dec 02 15:41	$

 FUNCTION A_CDOM_TWARDOWSKI, A_CDOM_412, WLS=WLS, EQUATION=EQUATION
;+
; This Program computes an ABSORPTION SPECTRUM for CDOM based on the Generalized Equation in
; 	Twardowski, Boss, Sullivan, Donaghay. 2004.
;		Modeling the spectral shape of absorption by chromophoric dissolved organic matter.
;		Marine Chemistry 89 (2004) 69-88
;		ag(wl) = ag(412)(wl/412)^(-6.92)
;
;		INPUTS:
;			A_CDOM_412:  Absorption by CDOM at 412 nm
;			WLS:				 Wavelengths (nm)

; 	MODIFICATION HISTORY:
;			Written Jan 11, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='A_CDOM_TWARDOWSKI'
	IF N_ELEMENTS(WLS) EQ 0 THEN WLS = FINDGEN(321) + 380


	IF KEYWORD_SET(EQUATION) THEN RETURN,'a!DCDOM(!Ml!X)!N = a!DCDOM(412)!N (!Ml!X/412)!U-6.92!X!N'

	A_CDOM = A_CDOM_412*(WLS/412.0)^(-6.92)
	RETURN, A_CDOM

END; #####################  End of Routine ################################



