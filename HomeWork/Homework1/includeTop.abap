*&---------------------------------------------------------------------*
*& Include          ZABAP_EGITIM_DEMO_PROJECT_TOP
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.

PARAMETERS: p_cbox1 AS CHECKBOX USER-COMMAND cm1,
            p_cbox2 AS CHECKBOX USER-COMMAND cm2,
            p_cbox3 AS CHECKBOX USER-COMMAND cm3.

SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-002.

 PARAMETERS: p_rad1 RADIOBUTTON GROUP gr1 USER-COMMAND rb1,
             p_rad2 RADIOBUTTON GROUP gr1.

SELECTION-SCREEN END OF BLOCK bl2.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-003.

  PARAMETERS: p_num1 TYPE int4 MODIF ID m1,
              p_num2 TYPE int4 MODIF ID m1,
              p_num3 TYPE int4 MODIF ID m1.

SELECTION-SCREEN END OF BLOCK bl3.

DATA: gv_cevre TYPE int4,
      gv_alan TYPE int4,
      gv_mes TYPE char20,
      gv_mes2 TYPE char20,
      gv_text TYPE char100.