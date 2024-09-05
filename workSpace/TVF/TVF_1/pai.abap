*----------------------------------------------------------------------*
*   INCLUDE ZFI_017_P01_PAIDAT                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.
  ok_code = lcl_screen=>get_screen( sy-dynnr )->pai( ok_code ).
ENDMODULE.                 " PAI  INPUT
MODULE exit_command INPUT.
  lcl_screen=>get_screen( sy-dynnr )->exit_command( ok_code ).
ENDMODULE.                 " EXIT_COMMAND  INPUT

MODULE ts_control_active_tab_get INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN c_ts_control-tab1.
      g_ts_control-pressed_tab = c_ts_control-tab1.
    WHEN c_ts_control-tab2.
      g_ts_control-pressed_tab = c_ts_control-tab2.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_DESCRIPTION  INPUT
*&---------------------------------------------------------------------*
MODULE set_description INPUT.

  mo_helper->set_description( ).

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  FIELD_REQUIRED  INPUT
*&---------------------------------------------------------------------*
MODULE field_required INPUT.

  IF ok_code EQ 'SAVE'.
    mo_helper->field_required( ).
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_ASSET_VALUES  INPUT
*&---------------------------------------------------------------------*
MODULE check_asset_values INPUT.

  IF zfi_017_s01-anln1 IS NOT INITIAL OR zfi_017_s01-anln2 IS NOT INITIAL.
    DATA(_anln2) = COND #( WHEN zfi_017_s01-anln2 EQ space THEN '0000' ELSE zfi_017_s01-anln2 ).
    SELECT SINGLE COUNT(*) FROM anla
      WHERE bukrs EQ @zfi_017_s01-bukrs
        AND anln1 EQ @zfi_017_s01-anln1
        AND anln2 EQ @_anln2.
    IF sy-dbcnt IS INITIAL.
      MESSAGE e076(zfi_017).
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_DEFAULT_PRICE  INPUT
*&---------------------------------------------------------------------*
MODULE set_default_price INPUT.

  ON CHANGE OF zfi_017_s01-anln1 OR zfi_017_s01-anln2.
    mo_helper->set_fixed_asset_price( ).
  ENDON.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_DEPARTMENT  INPUT
*&---------------------------------------------------------------------*
MODULE set_department INPUT.

  ON CHANGE OF zfi_017_s01-envtp.
    mo_helper->set_department_dat( ).
    cl_gui_cfw=>set_new_ok_code( '/00' ).
  ENDON.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  AUTH_ENVTP  INPUT
*&---------------------------------------------------------------------*
MODULE auth_envtp INPUT.

  mo_helper->authorization_envtp_cntl(
    EXCEPTIONS
      handle_error = 1
      OTHERS       = 2 ).
  IF NOT sy-subrc IS INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING contains_error.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_SERIAL_NUMBER  INPUT
*&---------------------------------------------------------------------*
MODULE check_serial_number INPUT.

  CHECK NOT zfi_017_s01-serno IS INITIAL.
  SELECT SINGLE envno
    FROM zfi_017_t01
      INTO @DATA(_envno)
        WHERE serno EQ @zfi_017_s01-serno
          AND statu NE '05'
          AND envno NE @zfi_017_s01-envno.
  IF sy-subrc IS INITIAL.
    MESSAGE e080(zfi_017) WITH zfi_017_s01-serno _envno.
  ENDIF.

ENDMODULE.