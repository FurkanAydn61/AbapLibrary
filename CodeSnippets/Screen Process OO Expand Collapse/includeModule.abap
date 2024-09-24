*&---------------------------------------------------------------------*
*& Include          ZFKN_OO_SCREEN_MOD
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  lcl_screen=>get_screen( sy-dynnr )->pbo( ).
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai INPUT.
  gv_okcode = lcl_screen=>get_screen( sy-dynnr )->pai( gv_okcode ).
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command INPUT.
  lcl_screen=>get_screen( sy-dynnr )->exit_command( gv_okcode ).
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module T_TABSTRIP_ACTIVE_TAB_SET OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE t_tabstrip_active_tab_set OUTPUT.

  tsa_9000-activetab = g_ts_control-pressed_tab.
  CASE g_ts_control-pressed_tab.
    WHEN c_t_tabstrip-tab1.
      g_ts_control-subscreen = '2000'.
    WHEN c_t_tabstrip-tab2.
      g_ts_control-subscreen = '2100'.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_DYNAMIC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_dynamic INPUT.
CASE sy-ucomm.
  WHEN 'PB_2020'.
    gv_subscreen_2020 = '2010'.
  WHEN 'PB_2010'.
    gv_subscreen_2020 = '2020'.
  WHEN OTHERS.
ENDCASE.
ENDMODULE.