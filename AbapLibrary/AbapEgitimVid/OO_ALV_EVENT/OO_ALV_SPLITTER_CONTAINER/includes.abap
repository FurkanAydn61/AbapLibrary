*& Include          ZABAP_EGITIM_032_TOP
*&---------------------------------------------------------------------*

DATA: go_alv TYPE REF TO cl_gui_alv_grid,
      go_alv2 TYPE REF TO cl_gui_alv_grid,
      go_cust TYPE REF TO cl_gui_custom_container.

DATA: go_splitter TYPE REF TO cl_gui_splitter_container,
      go_gui1 TYPE REF TO cl_gui_container,
      go_gui2 TYPE REF TO cl_gui_container.

DATA: gt_scarr TYPE TABLE OF scarr,
      gt_sflight TYPE TABLE OF sflight,
      gt_fcat TYPE LVC_T_FCAT,
      gt_fcat2 TYPE LVC_T_FCAT,
      gs_fcat2 TYPE LVC_S_FCAT,
      gs_fcat TYPE LVC_S_FCAT,
      gs_layout TYPE LVC_S_LAYO.


******************************************************

*& Include          ZABAP_EGITIM_032_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
 SET PF-STATUS '0100'.
 SET TITLEBAR '0100'.

 PERFORM display_alv.
ENDMODULE.


*********************************************************

*&---------------------------------------------------------------------*
*& Include          ZABAP_EGITIM_032_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
CASE sy-ucomm.
  WHEN '&BACK'.
    SET SCREEN 0.
ENDCASE.
ENDMODULE.

***********************************************************

*& Include          ZABAP_EGITIM_032_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.

  SELECT * FROM sflight INTO CORRESPONDING FIELDS OF TABLE gt_sflight.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fcat .
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'SCARR'
    CHANGING
      ct_fieldcat      = gt_fcat.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'SFLIGHT'
    CHANGING
      ct_fieldcat      = gt_fcat2.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout .
***********Layout ortak kullanabiliriz*************
  CLEAR: gs_layout.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-no_toolbar = abap_true.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv .
  CREATE OBJECT go_cust
    EXPORTING
      container_name = 'CC_ALV'.

  CREATE OBJECT go_splitter"1 satırlı 2 kolonlu container oluşturuyoruz"
    EXPORTING
      parent  = go_cust
      rows    = 1
      columns = 2.

  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_gui1.

  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = go_gui2.

  CREATE OBJECT go_alv
    EXPORTING
      i_parent = go_gui1.

  CREATE OBJECT go_alv2
    EXPORTING
      i_parent = go_gui2.

  CALL METHOD go_alv->set_table_for_first_display
    EXPORTING
      is_layout       = gs_layout
    CHANGING
      it_outtab       = gt_scarr
      it_fieldcatalog = gt_fcat.

  CALL METHOD go_alv2->set_table_for_first_display
    EXPORTING
      is_layout       = gs_layout
    CHANGING
      it_outtab       = gt_sflight
      it_fieldcatalog = gt_fcat2.

ENDFORM.