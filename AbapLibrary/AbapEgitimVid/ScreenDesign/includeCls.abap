*&---------------------------------------------------------------------*
*& Include          ZFOR_CIS_P001_CLS
*&---------------------------------------------------------------------*

CLASS lcl_screen DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          i_dynnr TYPE sy-dynnr.

    METHODS:
      pbo ABSTRACT,
      pai ABSTRACT
        IMPORTING
          fcode          TYPE sy-ucomm
        RETURNING
          VALUE(r_fcode) TYPE sy-ucomm,
      free ABSTRACT.

    METHODS:
      exit_command
        IMPORTING
          fcode TYPE sy-ucomm.

    CLASS-METHODS:
      get_screen
        IMPORTING
          i_dynnr         TYPE sy-dynnr
        RETURNING
          VALUE(r_screen) TYPE REF TO lcl_screen.

  PRIVATE SECTION.
    DATA: screen TYPE sy-dynnr.
    TYPES:
      BEGIN OF lst_screen,
        screen TYPE REF TO lcl_screen,
      END OF lst_screen.
    CLASS-DATA: t_screen TYPE STANDARD TABLE OF lst_screen.
    CONSTANTS: c_class_name TYPE string VALUE 'LCL_SCREEN'.
ENDCLASS.

CLASS lcl_screen IMPLEMENTATION.
  METHOD constructor.
    screen = i_dynnr.
  ENDMETHOD.

  METHOD exit_command.
    CASE fcode.
      WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
        LEAVE PROGRAM.
      WHEN 'CREA'.
        MESSAGE 'Yeni Kayıt Oluşturma Butonu Seçildi' TYPE 'I' DISPLAY LIKE 'S'.
    ENDCASE.
  ENDMETHOD.

  METHOD get_screen.
    DATA: ls_screen TYPE lst_screen,
          lv_type   TYPE string.

    READ TABLE t_screen INTO ls_screen WITH KEY screen->screen = i_dynnr.
    IF sy-subrc NE 0.
      CONCATENATE c_class_name i_dynnr INTO lv_type SEPARATED BY '_'.
      CREATE OBJECT ls_screen-screen TYPE (lv_type)
      EXPORTING
        i_dynnr = i_dynnr.
      APPEND ls_screen TO t_screen.
    ENDIF.
    r_screen ?= ls_screen-screen.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_screen_9000 DEFINITION INHERITING FROM lcl_screen FINAL.
  PUBLIC SECTION.
    METHODS:
      pbo REDEFINITION,
      pai REDEFINITION,
      free REDEFINITION.
ENDCLASS.

CLASS lcl_screen_9000 IMPLEMENTATION.
  METHOD pbo.
    SET PF-STATUS 'STANDARD'.
  ENDMETHOD.

  METHOD pai.
    CASE fcode.
      WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
        LEAVE PROGRAM.
      WHEN 'CREA'.
        MESSAGE 'Yeni Kayıt Oluşturma Butonu Seçildi' TYPE 'I' DISPLAY LIKE 'S'.
    ENDCASE.
    ok_code = sy-ucomm.
    CASE ok_code.
      WHEN c_ts_control-tab1.
        g_ts_control-pressed_tab = tabs-activetab = c_ts_control-tab1.
      WHEN c_ts_control-tab2.
        g_ts_control-pressed_tab = tabs-activetab = c_ts_control-tab2.
    ENDCASE.
  ENDMETHOD.

  METHOD free.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_screen_9001 DEFINITION INHERITING FROM lcl_screen FINAL.
  PUBLIC SECTION.
    METHODS:
      pbo REDEFINITION,
      pai REDEFINITION,
      free REDEFINITION.
ENDCLASS.

CLASS lcl_screen_9001 IMPLEMENTATION.
  METHOD pbo.
  ENDMETHOD.

  METHOD pai.
    CASE fcode.
      WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
        LEAVE PROGRAM.
    ENDCASE.
  ENDMETHOD.

  METHOD free.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_screen_9002 DEFINITION INHERITING FROM lcl_screen FINAL.
  PUBLIC SECTION.
    METHODS:
      pbo REDEFINITION,
      pai REDEFINITION,
      free REDEFINITION.
ENDCLASS.

CLASS lcl_screen_9002 IMPLEMENTATION.
  METHOD pbo.
  ENDMETHOD.

  METHOD pai.
    CASE fcode.
      WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
        LEAVE PROGRAM.
      WHEN 'CREA'.
        MESSAGE 'Yeni Kayıt Oluşturma Butonu Seçildi' TYPE 'I' DISPLAY LIKE 'S'.
    ENDCASE.
  ENDMETHOD.

  METHOD free.
  ENDMETHOD.
ENDCLASS.