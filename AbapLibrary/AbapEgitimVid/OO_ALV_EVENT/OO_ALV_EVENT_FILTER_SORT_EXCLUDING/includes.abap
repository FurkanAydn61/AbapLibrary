*& Include          ZABAP_EGITIM_040_TOP
*&---------------------------------------------------------------------*

DATA: go_grid TYPE REF TO cl_gui_alv_grid,
      go_cust TYPE REF TO cl_gui_custom_container.

DATA: gt_scarr  TYPE TABLE OF scarr,
      gs_scarr  TYPE scarr,
      gt_fcat   TYPE  lvc_t_fcat,
      gs_fcat   TYPE lvc_s_fcat,
      gs_layout TYPE lvc_s_layo.

DATA: gt_excluding TYPE ui_functions,
      gv_excluding TYPE ui_func.

DATA: gt_sort TYPE lvc_t_sort,
      gs_sort TYPE lvc_s_sort.

DATA: gt_filter TYPE lvc_t_filt,
      gs_filter TYPE lvc_s_filt.




CLASS     cl_event_receiver DEFINITION DEFERRED.
DATA: go_event_receiver TYPE REF TO cl_event_receiver.


*&---------------------------------------------------------------------*
*& Include          ZABAP_EGITIM_040_CLS
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
    BREAK-POINT.
  ENDMETHOD.

ENDCLASS.


*& Include          ZABAP_EGITIM_040_PBO
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


*& Include          ZABAP_EGITIM_040_PAI
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


*&---------------------------------------------------------------------*
*& Include          ZABAP_EGITIM_040_FRM
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

*    PERFORM set_exclude."Toolbar da görmek istemediğimiz yerleri kaldıremak için kullanırız"

*    PERFORM set_sort."Default olarak büyükten küçüğe ya da küçükten büyüğe sıralmaya yarar"

    PERFORM set_filter."Filtreleme işlemi için kulandık"

    CALL METHOD go_grid->set_table_for_first_display
      EXPORTING
*       i_buffer_active      =                  " Buffering Active
*       i_bypassing_buffer   =                  " Switch Off Buffer
*       i_consistency_check  =                  " Starting Consistency Check for Interface Error Recognition
*       i_structure_name     =                  " Internal Output Table Structure Name
*       is_variant           =                  " Layout
*       i_save               =                  " Save Layout
*       i_default            = 'X'              " Default Display Variant
        is_layout            = gs_layout                 " Layout
*       is_print             =                  " Print Control
*       it_special_groups    =                  " Field Groups
        it_toolbar_excluding = gt_excluding                  " Excluded Toolbar Standard Functions
*       it_hyperlink         =                  " Hyperlinks
*       it_alv_graphics      =                  " Table of Structure DTC_S_TC
*       it_except_qinfo      =                  " Table for Exception Tooltip
*       ir_salv_adapter      =                  " Interface ALV Adapter
      CHANGING
        it_outtab            = gt_scarr                  " Output Table
        it_fieldcatalog      = gt_fcat                 " Field Catalog
        it_sort              = gt_sort                 " Sort Criteria
        it_filter            = gt_filter                 " Filter Criteria
*      EXCEPTIONS
*       invalid_parameter_combination = 1                " Wrong Parameter
*       program_error        = 2                " Program Errors
*       too_many_lines       = 3                " Too many Rows in Ready for Input Grid
*       others               = 4
      .
*    IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.

  ELSE.
    CALL METHOD go_grid->refresh_table_display.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCLUDE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_exclude .
  CLEAR: gv_excluding.

  gv_excluding = cl_gui_alv_grid=>mc_fc_detail.
  APPEND gv_excluding TO gt_excluding.

  gv_excluding = cl_gui_alv_grid=>mc_fc_find.
  APPEND gv_excluding TO gt_excluding.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_sort .
  CLEAR: gs_sort.
  gs_sort-spos = 1."Hangisinin önce sıralayacağını gösterdik"
  gs_sort-fieldname = 'CURRCODE'.
  gs_sort-down = abap_true.
  APPEND gs_sort TO gt_sort.

  CLEAR: gs_sort.
  gs_sort-spos = 2.
  gs_sort-fieldname = 'CARRNAME'.
  gs_sort-up = abap_true.
  APPEND gs_sort TO gt_sort.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FILTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_filter .
CLEAR: gs_filter.
gs_filter-tabname = 'GT_SCARR'.
gs_filter-fieldname = 'CURRCODE'.
gs_filter-sign = 'I'.
gs_filter-option = 'EQ'.
gs_filter-low = 'USD'.
APPEND gs_filter TO gt_filter.
ENDFORM.






