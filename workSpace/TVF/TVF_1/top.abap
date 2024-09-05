*----------------------------------------------------------------------*
*   INCLUDE ZFI_017_P01_TOPDAT                                                   *
*----------------------------------------------------------------------*
PROGRAM  zfi_017_p01 MESSAGE-ID zfi_017.

TABLES: zfi_017_s01, *zfi_017_s01, zfi_017_s02.

DATA  ok_code TYPE sy-ucomm.

CONSTANTS: BEGIN OF c_ts_control,
             tab1 LIKE sy-ucomm VALUE 'TAB01',
             tab2 LIKE sy-ucomm VALUE 'TAB02',
           END OF c_ts_control.

CONTROLS:  ts_control TYPE TABSTRIP.
DATA: BEGIN OF g_ts_control,
        subscreen   LIKE sy-dynnr,
        prog        LIKE sy-repid VALUE 'ZFI_017_P01',
        pressed_tab LIKE sy-ucomm VALUE c_ts_control-tab2,
      END OF g_ts_control.

DATA: gt_search  TYPE STANDARD TABLE OF zfi_017_s03 WITH DEFAULT KEY,
      gt_jsondat TYPE STANDARD TABLE OF zfi_017_s04 WITH  DEFAULT KEY.

TYPES:
  BEGIN OF ty_selected,
    bukrs TYPE zfi_017_t01-bukrs,
    envno TYPE zfi_017_t01-envno,
  END OF ty_selected.
DATA: gs_selected TYPE ty_selected.

CONSTANTS:
  BEGIN OF gc_action,
    create  TYPE c LENGTH 1 VALUE 'C',
    display TYPE c LENGTH 1 VALUE 'D',
    edit    TYPE c LENGTH 1 VALUE 'E',
  END OF gc_action.

DATA: gv_mode TYPE c LENGTH 1 VALUE gc_action-display.

DATA : lr_custom_cont TYPE REF TO cl_gui_custom_container,
       lr_text_edit   TYPE REF TO cl_gui_textedit,
       lt_text        TYPE TABLE OF char255.

CLASS lcl_helper DEFINITION DEFERRED.

DATA: mo_helper TYPE REF TO lcl_helper.

TYPES:
  BEGIN OF ty_jsondat,
    envoz  TYPE zfi_017_e002,
    header TYPE zfi_017_e018,
    value  TYPE zfi_017_e019,
  END OF ty_jsondat,
  tt_jsondat TYPE SORTED TABLE OF ty_jsondat WITH NON-UNIQUE KEY envoz.

DATA: gv_jsondat     TYPE xstring,
      gv_jsondat_old TYPE xstring.

DATA: gv_descdat     TYPE xstring,
      gv_descdat_old TYPE xstring.