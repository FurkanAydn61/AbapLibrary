*&---------------------------------------------------------------------*
*& Include          ZFOR_CIS_P001_PAI
*&---------------------------------------------------------------------*

MODULE pai INPUT.
  ok_code = lcl_screen=>get_screen( sy-dynnr )->pai( ok_code ).
ENDMODULE.

MODULE ts_control_active_tab_get INPUT.
ok_code = sy-ucomm.
CASE ok_code.
  WHEN c_ts_control-tab1.
    g_ts_control-pressed_tab = c_ts_control-tab1.
  WHEN c_ts_control-tab2.
    g_ts_control-pressed_tab = c_ts_control-tab2.
ENDCASE.
ENDMODULE.