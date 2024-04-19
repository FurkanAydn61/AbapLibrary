*& Include          ZABAP_EGITIM_037_TOP
*&---------------------------------------------------------------------*

DATA: go_grid TYPE REF TO cl_gui_alv_grid,
      go_cust TYPE REF TO cl_gui_custom_container.

DATA: gt_scarr TYPE TABLE OF scarr,
      gs_scarr TYPE scarr,
      gt_fcat TYPE LVC_T_FCAT,
      gs_fcat TYPE LVC_S_FCAT,
      gs_layout TYPE LVC_S_LAYO.






FIELD-SYMBOLS: <gfs_fcat> TYPE lvc_s_fcat,
               <gfs_scarr> TYPE scarr.

CLASS cl_event_receiver DEFINITION DEFERRED.
DATA: go_event_receiver TYPE REF TO cl_event_receiver.

**************************************************************

*& Include          ZABAP_EGITIM_037_CLS
*&---------------------------------------------------------------------*

CLASS cl_event_receiver DEFINITION.
  PUBLIC SECTION.

    METHODS handle_top_of_page                  "Top_OF_PAGE"
        FOR EVENT top_of_page OF cl_gui_alv_grid
      IMPORTING
        e_dyndoc_id
        table_index.

    METHODS handle_hotspot_click               "HOTSPOT_CLICK"
        FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING
        e_row_id
        e_column_id.

    METHODS handle_double_click                "Double_click"
        FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING
        e_row
        e_column
        es_row_no.

    METHODS handle_data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING
        er_data_changed
        e_onf4
        e_onf4_before
        e_onf4_after
        e_ucomm.

    METHODS handle_onf4
        FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING
        e_fieldname
        e_fieldvalue
        es_row_no
        er_event_data
        et_bad_cells
        e_display.

ENDCLASS.

CLASS cl_event_receiver IMPLEMENTATION.

  METHOD handle_top_of_page.
    BREAK-POINT.
  ENDMETHOD.

  METHOD handle_hotspot_click.
    BREAK-POINT.
  ENDMETHOD.

  METHOD handle_double_click.
    BREAK-POINT.
  ENDMETHOD.

  METHOD handle_data_changed.
    BREAK-POINT.
  ENDMETHOD.

  METHOD handle_onf4.
    TYPES: BEGIN OF lty_value_tab,
             carrname TYPE s_carrname,
           END OF lty_value_tab.

    DATA: lt_value_tab TYPE TABLE OF lty_value_tab,
          ls_value_tab TYPE lty_value_tab.

    DATA: lt_return_tab TYPE TABLE OF  ddshretval,
          ls_return_tab TYPE  ddshretval.


    CLEAR: ls_value_tab.
    ls_value_tab-carrname = 'Uçuş 1'.
    APPEND ls_value_tab TO lt_value_tab.


    CLEAR: ls_value_tab.
    ls_value_tab-carrname = 'Uçuş 2'.
    APPEND ls_value_tab TO lt_value_tab.


    CLEAR: ls_value_tab.
    ls_value_tab-carrname = 'Uçuş 3'.
    APPEND ls_value_tab TO lt_value_tab.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield     = 'CARRNAME'
        window_title = 'CARNAME F4'
        value_org    = 'S'
      TABLES
        value_tab    = lt_value_tab
        return_tab   = lt_return_tab.
      READ TABLE lt_return_tab INTO ls_return_tab WITH KEY fieldname = 'F0001'.
      IF sy-subrc eq 0.
        READ TABLE gt_scarr ASSIGNING <gfs_scarr> INDEX es_row_no-row_id.
        IF sy-subrc eq 0.
           <gfs_scarr>-carrname = ls_return_tab-fieldval.
         go_grid->refresh_table_display(   ).

        ENDIF.
      ENDIF.

      er_event_data->m_event_handled = 'X'.


  ENDMETHOD.

*******************************************************************

*& Include          ZABAP_EGITIM_037_PBO
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

*******************************************************************

*& Include          ZABAP_EGITIM_037_PAI
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

*****************************************************************

*& Include          ZABAP_EGITIM_037_FRM
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

  LOOP AT gt_fcat ASSIGNING <gfs_fcat>.
    IF <gfs_fcat>-fieldname EQ 'CARRNAME'.
      <gfs_fcat>-edit = abap_true.
      <gfs_fcat>-style = cl_gui_alv_grid=>mc_style_f4.
    ENDIF.
  ENDLOOP.

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

  IF go_grid IS INITIAL .

    CREATE OBJECT go_cust
      EXPORTING
        container_name = 'CC_ALV'.

    CREATE OBJECT go_grid
      EXPORTING
        i_parent = go_cust.                  " Parent Container

    PERFORM register_f4.

    CREATE OBJECT go_event_receiver.

    SET HANDLER go_event_receiver->handle_onf4 FOR go_grid.

    CALL METHOD go_grid->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout                 " Layout
      CHANGING
        it_outtab       = gt_scarr                 " Output Table
        it_fieldcatalog = gt_fcat.                  " Field Catalog
    CALL METHOD go_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.                  " Event ID

  ELSE.
    CALL METHOD go_grid->refresh_table_display.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form REGISTER_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_f4 .
  DATA: lt_f4 TYPE lvc_t_f4,
        ls_f4 TYPE lvc_s_f4.

  CLEAR:ls_f4.
  ls_f4-fieldname = 'CARRNAME'.
  ls_f4-register = abap_true.
  APPEND ls_f4 TO lt_f4.

  CALL METHOD go_grid->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4.                  " F4 Fields
ENDFORM.