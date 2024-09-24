*&---------------------------------------------------------------------*
*& Include          ZFKN_OO_SCR_DYN_ICON_TOP
*&---------------------------------------------------------------------*
PROGRAM zfkn_oo_screen.

DATA: gv_okcode TYPE sy-ucomm.

CONTROLS: tsa_9000 TYPE TABSTRIP.

CONSTANTS: BEGIN OF c_t_tabstrip,
             tab1 LIKE sy-ucomm VALUE 'TAB1',
             tab2 LIKE sy-ucomm VALUE 'TAB2',
           END OF c_t_tabstrip.

DATA: BEGIN OF g_ts_control,
        subscreen   LIKE sy-dynnr,
        prog        LIKE sy-repid VALUE 'ZFKN_OO_SCR_DYN_ICON',
        pressed_tab LIKE sy-ucomm VALUE c_t_tabstrip-tab1,
      END OF g_ts_control.

DATA: gv_subscreen_2020 TYPE sy-dynnr VALUE '2020'.