*& Include          ZABAP_EGITIM_039_TOP
*&---------------------------------------------------------------------*

DATA: go_grid TYPE REF TO cl_gui_alv_grid,
      go_cust TYPE REF TO cl_gui_custom_container.

DATA: gt_scarr  TYPE TABLE OF scarr,
      gs_scarr  TYPE scarr,
      gt_fcat   TYPE  lvc_t_fcat,
      gs_fcat   TYPE lvc_s_fcat,
      gs_layout TYPE lvc_s_layo.

FIELD-SYMBOLS: <gfs_scarr> TYPE lvc_s_fcat.

CLASS cl_event_receiver DEFINITION DEFERRED.
DATA: go_event_receiver TYPE REF TO cl_event_receiver.


*&---------------------------------------------------------------------*
*& Include          ZABAP_EGITIM_039_CLS
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

    METHODS handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING
        e_object
        e_interactive.

    METHODS handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING
        e_ucomm.


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
    BREAK-POINT.
  ENDMETHOD.

  METHOD handle_toolbar.
    DATA: ls_button TYPE stb_button.

    CLEAR: ls_button.
    ls_button-function = '&DEL'.
    ls_button-text = 'Silme'.
    ls_button-quickinfo = 'Silme İşlemi'. "Üstüne geldiğinde gösterilecek yazı"
    ls_button-icon = '@11@'.
    ls_button-disabled = abap_false. "Kullanılır olup olmadığını kontrol ediyor"
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR: ls_button.
    ls_button-function = '&DISPLAY'.
    ls_button-text = 'Görüntüle'.
    ls_button-quickinfo = 'Görüntüle'.
    ls_button-icon = '@10@'.
    ls_button-disabled = abap_false.
    APPEND ls_button TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN '&DEL'.
        MESSAGE 'Silme İşlemi' TYPE 'I'.
      WHEN '&DISPLAY'.
        MESSAGE 'Display İşlemi' TYPE 'I'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.


*& Include          ZABAP_EGITIM_039_FRM
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
*gs_layout-no_toolbar = abap_true.

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
  IF go_grid IS INITIAL.
    CREATE OBJECT go_cust
      EXPORTING
        container_name = 'CC_ALV'.                  " Name of the Screen CustCtrl Name to Link Container To

    CREATE OBJECT go_grid
      EXPORTING
        i_parent = go_cust.                  " Parent Container

    CREATE OBJECT go_event_receiver.

    SET HANDLER go_event_receiver->handle_toolbar FOR go_grid.

    SET HANDLER go_event_receiver->handle_user_command FOR go_grid.

    CALL METHOD go_grid->set_table_for_first_display
      EXPORTING
        is_layout                     =  gs_layout                " Layout
      CHANGING
        it_outtab                     =  gt_scarr                " Output Table
        it_fieldcatalog               =  gt_fcat                " Field Catalog
      .

  ELSE.
    CALL METHOD go_grid->refresh_table_display.

  ENDIF.
ENDFORM.


