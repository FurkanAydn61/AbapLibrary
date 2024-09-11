*&---------------------------------------------------------------------*
*& Modulpool ZFKN_MPOOL_CHAIN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
PROGRAM zfkn_mpool_chain.
DATA: p_car TYPE spfli-carrid,
      p_con TYPE spfli-connid.
TABLES: spfli.
DATA: ok_code TYPE sy-ucomm.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STANDARD'.
* SET TITLEBAR 'xxx'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INVALID_VALIDATION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE invalid_validation INPUT.
CASE ok_code.
  WHEN 'DISP'.
    SELECT SINGLE * FROM spfli WHERE carrid = p_car AND connid = p_con.
      IF sy-subrc NE 0.
          MESSAGE 'INVALID INPUT' TYPE 'E'.
      ENDIF.
ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'DISP'.
      SELECT SINGLE * FROM spfli WHERE carrid  EQ p_car AND connid EQ p_con.
      CALL SCREEN 0200.
    WHEN '&BACK' OR '&CANCEL' OR '&EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'STANDARD'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0100.
  ENDCASE.
ENDMODULE.