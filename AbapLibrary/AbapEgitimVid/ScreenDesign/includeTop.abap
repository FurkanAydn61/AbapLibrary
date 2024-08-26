*& Include          ZFOR_CIS_P001_TOP
*&---------------------------------------------------------------------*

PROGRAM zfor_cis_p001.

DATA: ok_code TYPE sy-ucomm,
      init.
CONTROLS: tabs TYPE TABSTRIP.
CONSTANTS: BEGIN OF c_ts_control,
             tab1 LIKE sy-ucomm VALUE 'TAB1',
             tab2 LIKE sy-ucomm VALUE 'TAB2',
           END OF c_ts_control.

CONTROLS: ts_control TYPE TABSTRIP.
DATA: BEGIN OF g_ts_control,
        subscreen   LIKE sy-dynnr,
        prog        LIKE sy-repid VALUE 'ZFOR_CIS_P001',
        pressed_tab LIKE sy-ucomm VALUE c_ts_control-tab1,
      END OF g_ts_control.