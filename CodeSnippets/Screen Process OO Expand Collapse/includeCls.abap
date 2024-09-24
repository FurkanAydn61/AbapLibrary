*&---------------------------------------------------------------------*
*& Include          ZFKN_OO_SCREEN_CLS
*&---------------------------------------------------------------------*
CLASS lcl_screen DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS: constructor
      IMPORTING
        i_dynnr TYPE sy-dynnr.
*All screen process
    METHODS: pbo ABSTRACT,
      pai ABSTRACT
        IMPORTING
                  fcode          TYPE sy-ucomm
        RETURNING VALUE(r_fcode) TYPE sy-ucomm,
      free ABSTRACT.
* Exit Command
    METHODS: exit_command
      IMPORTING
        fcode TYPE sy-ucomm.
    TYPES: ty_text(400) TYPE c.
    METHODS: call_popup
      IMPORTING
                i_title         TYPE text60
                i_text          TYPE ty_text
      RETURNING VALUE(r_answer) TYPE char1.
* Screen static methods
    CLASS-METHODS: get_screen
      IMPORTING
                i_dynnr         TYPE sy-dynnr
      RETURNING VALUE(r_screen) TYPE REF TO lcl_screen.
    CLASS-METHODS: del_screen
      IMPORTING
        i_dynnr TYPE sy-dynnr.
  PRIVATE SECTION.
    DATA: screen TYPE sy-dynnr.
    TYPES: BEGIN OF lst_screen,
             screen TYPE REF TO lcl_screen,
           END OF lst_screen.
    CLASS-DATA: t_screen TYPE STANDARD TABLE OF lst_screen.
    CONSTANTS: c_class_name TYPE string VALUE 'LCL_SCREEN'.
ENDCLASS.

CLASS lcl_screen IMPLEMENTATION.
  METHOD constructor.
    screen = i_dynnr.
  ENDMETHOD.

  METHOD call_popup.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar       = i_title
        text_question  = i_text
      IMPORTING
        answer         = r_answer
      EXCEPTIONS
        text_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDMETHOD.

  METHOD exit_command.
    CASE fcode.
      WHEN 'EXIT'.
        LEAVE PROGRAM.
    ENDCASE.
  ENDMETHOD.

  METHOD get_screen.
    DATA: ls_screen TYPE lst_screen,
          lv_type   TYPE string.
    READ TABLE t_screen INTO ls_screen WITH KEY screen->screen = i_dynnr.
    IF sy-subrc NE 0.
      CONCATENATE c_class_name
                  i_dynnr
             INTO lv_type
             SEPARATED BY '_'.
      CREATE OBJECT ls_screen-screen TYPE (lv_type)
        EXPORTING
          i_dynnr = i_dynnr.
      APPEND ls_screen TO t_screen.
    ENDIF.
    r_screen ?= ls_screen-screen.
  ENDMETHOD.

  METHOD del_screen.
    DATA: ls_screen TYPE lst_screen,
          lv_type   TYPE string.
    READ TABLE t_screen INTO ls_screen WITH KEY screen->screen = i_dynnr.
    IF sy-subrc NE 0.
*   Screen doesnt exist
      RETURN.
    ENDIF.
    ls_screen-screen->free( ).
    DELETE t_screen
    WHERE screen->screen = i_dynnr.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_screen_9000 DEFINITION INHERITING FROM lcl_screen FINAL.
  PUBLIC SECTION.
    METHODS: pbo REDEFINITION,
      pai REDEFINITION,
      free REDEFINITION.
  PRIVATE SECTION.
* Screen 9000 methods
    METHODS: set_exclude
      RETURNING VALUE(rt_ex) TYPE status_excl_fcode_tt.
ENDCLASS.
CLASS lcl_screen_9000 IMPLEMENTATION.
  METHOD pbo.
    DATA: lt_ex TYPE status_excl_fcode_tt.
    lt_ex = set_exclude( ).
    SET PF-STATUS 'STATUS_9000' EXCLUDING lt_ex.
  ENDMETHOD.

  METHOD set_exclude.
    rt_ex = VALUE #( BASE rt_ex ( 'SAVE' ) ).
  ENDMETHOD.

  METHOD pai.
    CASE fcode.
      WHEN 'BACK'.
        IF call_popup(
             i_title = TEXT-001
             i_text  = TEXT-002
           ) EQ '1'.
          LEAVE TO SCREEN 0.
        ENDIF.
    ENDCASE.

    CASE gv_okcode.
      WHEN c_t_tabstrip-tab1.
        g_ts_control-pressed_tab = tsa_9000-activetab = c_t_tabstrip-tab1.
      WHEN c_t_tabstrip-tab2.
        g_ts_control-pressed_tab = tsa_9000-activetab = c_t_tabstrip-tab2.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.

  METHOD free.
* IF we declare global object data, we can clear or refresh here!
  ENDMETHOD.
ENDCLASS.

CLASS lcl_screen_2000 DEFINITION INHERITING FROM lcl_screen FINAL.
  PUBLIC SECTION.
    METHODS: pbo REDEFINITION,
      pai REDEFINITION,
      free REDEFINITION.

ENDCLASS.

CLASS lcl_screen_2000 IMPLEMENTATION.
  METHOD pbo.
   ENDMETHOD.
  METHOD pai.
  ENDMETHOD.

  METHOD free.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_screen_2100 DEFINITION INHERITING FROM lcl_screen FINAL.
  PUBLIC SECTION.
    METHODS: pbo REDEFINITION,
      pai REDEFINITION,
      free REDEFINITION.

ENDCLASS.

CLASS lcl_screen_2100 IMPLEMENTATION.
  METHOD pbo.
   ENDMETHOD.
  METHOD pai.
  ENDMETHOD.

  METHOD free.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_screen_2010 DEFINITION INHERITING FROM lcl_screen FINAL.
  PUBLIC SECTION.
    METHODS: pbo REDEFINITION,
      pai REDEFINITION,
      free REDEFINITION.

ENDCLASS.

CLASS lcl_screen_2010 IMPLEMENTATION.
  METHOD pbo.
   ENDMETHOD.
  METHOD pai.
  ENDMETHOD.

  METHOD free.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_screen_2020 DEFINITION INHERITING FROM lcl_screen FINAL.
  PUBLIC SECTION.
    METHODS: pbo REDEFINITION,
      pai REDEFINITION,
      free REDEFINITION.

ENDCLASS.

CLASS lcl_screen_2020 IMPLEMENTATION.
  METHOD pbo.
   ENDMETHOD.
  METHOD pai.
  ENDMETHOD.

  METHOD free.
  ENDMETHOD.
ENDCLASS.