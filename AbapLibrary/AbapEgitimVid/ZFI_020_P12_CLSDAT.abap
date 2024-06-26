*&---------------------------------------------------------------------*
*& Include          ZFI_020_P12_CLSDAT
*&---------------------------------------------------------------------*
TABLES: zfi_020_t01, sscrfields.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS:
     s_bukrs FOR zfi_020_t01-bukrs,
     s_srcid FOR zfi_020_t01-surec_id,
     s_pernr FOR zfi_020_t01-pernr MATCHCODE OBJECT perm,
     s_bldat FOR zfi_020_t01-bldat,
     s_odtur FOR zfi_020_t01-odeme_tur,
     s_waers FOR zfi_020_t01-waers,
     s_pspnr FOR zfi_020_t01-pspnr,
     s_statu FOR zfi_020_t01-statu.


SELECTION-SCREEN END OF BLOCK b1.


CLASS: lcl_controller DEFINITION DEFERRED,
       lcl_model DEFINITION DEFERRED,
       lcl_view DEFINITION DEFERRED.

DATA: _controller TYPE REF TO lcl_controller,
      _model      TYPE REF TO lcl_model,
      _view       TYPE REF TO lcl_view.

*----------------------------------------------------------------------*
* CLASS lcl_model DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_model DEFINITION.

  PUBLIC SECTION.

    DATA:
      mt_outdat TYPE STANDARD TABLE OF zfi_016_s01.

    METHODS:
      retrieve_data
        EXCEPTIONS
          handle_error.

ENDCLASS.
*----------------------------------------------------------------------*
* CLASS lcl_model IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_model IMPLEMENTATION .

  METHOD retrieve_data.


  ENDMETHOD.                    "retrieve_data

ENDCLASS.
*----------------------------------------------------------------------*
* CLASS lcl_view DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_view DEFINITION FINAL.

  PUBLIC SECTION.
    CONSTANTS:
      mc_strname TYPE tabname VALUE 'ZFI_016_S01'.

    TYPES: BEGIN OF ty_param,
             param_id TYPE memoryid,
             value    TYPE char100,
           END  OF ty_param,
           tt_params TYPE TABLE OF ty_param WITH DEFAULT KEY.

    DATA:
      mt_fcat  TYPE lvc_t_fcat,
      ms_fcat  TYPE lvc_s_fcat,
      mt_exdat TYPE slis_t_extab.

    METHODS:
      prepare_fcatdat
        IMPORTING
          !im_strname TYPE tabname
        EXCEPTIONS
          handle_error,
      display_alvdat
        EXCEPTIONS
          handle_error,
      call_transaction
        IMPORTING
          im_parameter TYPE tt_params
          im_tcode     TYPE sy-tcode.

ENDCLASS.
*----------------------------------------------------------------------*
* CLASS lcl_view IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_view IMPLEMENTATION .

  METHOD prepare_fcatdat.

    DATA: _text(40) TYPE c.

    FREE: me->mt_fcat.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = im_strname
      CHANGING
        ct_fieldcat            = me->mt_fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
      MESSAGE s001(00) WITH 'Fiedcatalog oluşturma sırasında hatalar oluştu!' RAISING handle_error.
    ENDIF.

    LOOP AT me->mt_fcat REFERENCE INTO DATA(r_fcat).

      IF r_fcat->col_pos < 9 .
        r_fcat->emphasize = 'C311'.
      ELSEIF r_fcat->col_pos < 18 .
        r_fcat->emphasize = 'C410'.
      ELSEIF r_fcat->col_pos >= 18 .
        r_fcat->emphasize = 'C511'.
      ENDIF.

      CLEAR: _text.
      CASE r_fcat->fieldname .
        WHEN 'SELKZ'.
          r_fcat->tech = 'X'.
      ENDCASE.
      IF _text <> space.
        MOVE _text TO: r_fcat->scrtext_l, r_fcat->scrtext_m, r_fcat->scrtext_s, r_fcat->reptext.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
  METHOD display_alvdat.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
      EXPORTING
        i_callback_program       = sy-repid
        i_callback_pf_status_set = 'SET_PF_STATUS'
        i_callback_user_command  = 'USER_COMMAND'
        i_callback_top_of_page   = 'TOP_OF_PAGE'
        is_layout_lvc            = VALUE lvc_s_layo( col_opt = abap_true cwidth_opt = abap_true zebra = abap_true box_fname = 'SELKZ' )
        it_fieldcat_lvc          = me->mt_fcat
        it_excluding             = me->mt_exdat
        i_default                = abap_true
        i_save                   = abap_true
      TABLES
        t_outtab                 = _model->mt_outdat
      EXCEPTIONS
        program_error            = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0 .
      MESSAGE s001(00) WITH 'ALV gösterimi sırasında hatalar oluştu!' RAISING handle_error.
    ENDIF.

  ENDMETHOD.
  METHOD call_transaction.

    LOOP AT im_parameter INTO DATA(wa_param).
      SET PARAMETER ID wa_param-param_id FIELD wa_param-value.
    ENDLOOP.
    IF sy-subrc IS INITIAL AND
       im_tcode IS NOT INITIAL.
      CALL TRANSACTION im_tcode AND SKIP FIRST SCREEN.
    ENDIF.

  ENDMETHOD.                      "call_transaction

ENDCLASS.



*----------------------------------------------------------------------*
* CLASS lcl_controller DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_controller DEFINITION FINAL.

  PUBLIC SECTION.

    CONSTANTS:
      mc_model TYPE seoclsname VALUE 'LCL_MODEL',
      mc_view  TYPE seoclsname VALUE 'LCL_VIEW'.

    CONSTANTS:
      BEGIN OF mc_msg,
        id      TYPE symsgid    VALUE '00',
        success TYPE bapi_mtype VALUE 'S',
        error   TYPE bapi_mtype VALUE 'E',
        warning TYPE bapi_mtype VALUE 'W',
        info    TYPE bapi_mtype VALUE 'I',
        abort   TYPE bapi_mtype VALUE 'A',
      END OF mc_msg.

    DATA:
      mo_model TYPE REF TO lcl_model,
      mo_view  TYPE REF TO lcl_view.

    METHODS:
      instantiate_app
        IMPORTING
          iv_model             TYPE seoclsname
          iv_view              TYPE seoclsname
        RETURNING
          VALUE(ro_controller) TYPE REF TO lcl_controller,
      alv_session
        EXCEPTIONS
          handle_error,
      initialization,
      at_selection_screen
        EXCEPTIONS
          handle_error,
      at_selection_screen_output.

ENDCLASS.                    "lcl_handle_events DEFINITION

*----------------------------------------------------------------------*
* CLASS lcl_controller IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_controller IMPLEMENTATION.

  METHOD instantiate_app.

    DATA: lo_object TYPE REF TO object.

    ro_controller = NEW lcl_controller( ).

    FREE: lo_object.
    CREATE OBJECT lo_object TYPE (iv_model).
    IF lo_object IS BOUND.
      ro_controller->mo_model ?= lo_object.
    ENDIF.

    FREE: lo_object.
    CREATE OBJECT lo_object TYPE (iv_view).
    IF lo_object IS BOUND.
      ro_controller->mo_view ?= lo_object.
    ENDIF.

    IF ro_controller->mo_model IS BOUND AND ro_controller->mo_view IS BOUND.
      _model ?= ro_controller->mo_model.
      _view  ?= ro_controller->mo_view.
    ENDIF.

  ENDMETHOD.
  METHOD alv_session.

    CHECK lines( _controller->mo_model->mt_outdat ) IS NOT INITIAL.

    _controller->mo_view->prepare_fcatdat(
      EXPORTING
        im_strname   = _controller->mo_view->mc_strname
      EXCEPTIONS
        handle_error = 1
        OTHERS       = 2 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING handle_error.
    ENDIF.

    _controller->mo_view->display_alvdat(
      EXCEPTIONS
        handle_error = 1
        OTHERS       = 2 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING handle_error.
    ENDIF.

  ENDMETHOD.
  METHOD initialization.
  ENDMETHOD.
  METHOD at_selection_screen.



  ENDMETHOD.
  METHOD at_selection_screen_output.


  ENDMETHOD.

ENDCLASS.