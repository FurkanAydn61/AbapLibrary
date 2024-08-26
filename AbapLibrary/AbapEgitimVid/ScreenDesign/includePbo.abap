*& Include          ZFOR_CIS_P001_PBO
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  lcl_screen=>get_screen( sy-dynnr )->pbo( ).
ENDMODULE.

MODULE ts_control_active_tab_set OUTPUT.
  ts_control-activetab = g_ts_control-pressed_tab.
  CASE g_ts_control-pressed_tab.
    WHEN c_ts_control-tab1.
      g_ts_control-subscreen = '9001'.
    WHEN c_ts_control-tab2.
      g_ts_control-subscreen = '9002'.
  ENDCASE.
ENDMODULE.