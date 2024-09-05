*&---------------------------------------------------------------------*
*& Include          ZFI_P_MR8M_CLEARING_CLSDAT
*&---------------------------------------------------------------------*
TYPE-POOLS: slis, icon.
TABLES: bkpf.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
  PARAMETERS: p_bukrs TYPE bseg-bukrs OBLIGATORY DEFAULT '1001',
              p_gjahr TYPE bseg-gjahr OBLIGATORY DEFAULT sy-datum(4),
              p_lifnr TYPE bseg-lifnr DEFAULT '1001942' OBLIGATORY.

  SELECT-OPTIONS: s_blart FOR bkpf-blart.
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

    CONSTANTS:
      BEGIN OF mc_msg,
        id      TYPE symsgid    VALUE '00',
        success TYPE bapi_mtype VALUE 'S',
        error   TYPE bapi_mtype VALUE 'E',
        warning TYPE bapi_mtype VALUE 'W',
        info    TYPE bapi_mtype VALUE 'I',
        abort   TYPE bapi_mtype VALUE 'A',
      END OF mc_msg.

    TYPES: mtt_blart TYPE RANGE OF bkpf-blart.

    DATA:
      mt_outdat TYPE STANDARD TABLE OF zfi_s_unilever_update_alvdat,
      mr_outdat TYPE REF TO zfi_s_unilever_update_alvdat.

    METHODS:
      initialization_dat
        EXCEPTIONS
          contains_error,
      retrieve_data
        IMPORTING
          !iv_bukrs TYPE bukrs
          !iv_gjahr TYPE gjahr
          !iv_lifnr TYPE lifnr
          !iv_blart TYPE mtt_blart
        EXCEPTIONS
          contains_error.

ENDCLASS.
*----------------------------------------------------------------------*
* CLASS lcl_model IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_model IMPLEMENTATION .

  METHOD initialization_dat.

  ENDMETHOD.                    "initialization_dat
  METHOD retrieve_data.

    SELECT
      bsik_view~bukrs,
      bsik_view~belnr,
      bsik_view~buzei,
      bsik_view~gjahr,
      bsik_view~blart,
      bsik_view~lifnr,
      lfa1~name1,
      bseg~matnr,
      makt~maktx,
      bsik_view~kidno
      FROM bsik_view
      INNER JOIN bseg ON bseg~bukrs EQ bsik_view~bukrs AND "#EC CI_DB_OPERATION_OK[2431747]
                         bseg~belnr EQ bsik_view~belnr AND
                         bseg~buzei EQ bsik_view~buzei AND
                         bseg~gjahr EQ bsik_view~gjahr
      INNER JOIN mara ON mara~matnr EQ bseg~matnr
      LEFT OUTER JOIN makt ON makt~matnr EQ mara~matnr AND
                              makt~spras EQ @sy-langu
      LEFT OUTER JOIN lfa1 ON lfa1~lifnr EQ bsik_view~lifnr
      WHERE bsik_view~bukrs EQ @iv_bukrs
        AND bsik_view~gjahr EQ @iv_gjahr
        AND bsik_view~lifnr EQ @iv_lifnr
        AND bsik_view~blart IN @iv_blart
        INTO CORRESPONDING FIELDS OF TABLE @mt_outdat.

    IF NOT sy-subrc IS INITIAL.
      MESSAGE s001(00) WITH 'Seçim kriterlerine uygun veri bulunamadı!' RAISING contains_error. RETURN.
    ENDIF.

    LOOP AT mt_outdat ASSIGNING FIELD-SYMBOL(<fs_outdat>).

      IF <fs_outdat>-matnr CP '21*'.
        mr_outdat->kidnu = 'A'.
      ELSE.
        mr_outdat->kidnu = 'U'.
      ENDIF.
      <fs_outdat>-light = COND #( WHEN mr_outdat->kidno = mr_outdat->kidno THEN icon_green_light ELSE icon_yellow_light ).

    ENDLOOP.

  ENDMETHOD.                    "retrieve_data

ENDCLASS.
*----------------------------------------------------------------------*
* CLASS lcl_view DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_view DEFINITION FINAL.

  PUBLIC SECTION.
    CONSTANTS:
      mc_strname TYPE tabname VALUE 'ZFI_S_UNILEVER_UPDATE_ALVDAT'.

    TYPES: BEGIN OF ty_param,
             param_id TYPE memoryid,
             value    TYPE char100,
           END  OF ty_param,
           tt_params TYPE TABLE OF ty_param WITH DEFAULT KEY.

    DATA:
      mt_fcat  TYPE lvc_t_fcat,
      mt_exdat TYPE slis_t_extab.

    METHODS:
      display_applog
        IMPORTING
          !iv_msgdat TYPE bapiret2_tab
        EXCEPTIONS
          contains_error,
      call_transaction
        IMPORTING
          im_parameter TYPE tt_params
          im_tcode     TYPE sy-tcode,
      prepare_fcatdat
        IMPORTING
          !im_strname TYPE tabname
        EXCEPTIONS
          contains_error,
      display_alvdat
        EXCEPTIONS
          contains_error.

ENDCLASS.
*----------------------------------------------------------------------*
* CLASS lcl_view IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_view IMPLEMENTATION .

  METHOD call_transaction.

    LOOP AT im_parameter INTO DATA(wa_param).
      SET PARAMETER ID wa_param-param_id FIELD wa_param-value.
    ENDLOOP.
    IF sy-subrc IS INITIAL AND
       im_tcode IS NOT INITIAL.
      CALL TRANSACTION im_tcode AND SKIP FIRST SCREEN.
    ENDIF.

  ENDMETHOD.                    "call_transaction
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
      MESSAGE s001(00) WITH 'Fiedcatalog oluşturma sırasında hatalar oluştu!' RAISING contains_error.
    ENDIF.

    LOOP AT me->mt_fcat REFERENCE INTO DATA(r_fcat).
      CLEAR: _text.
      CASE r_fcat->fieldname .
        WHEN 'SELKZ'.
          r_fcat->tech = abap_true.
        WHEN 'LIGHT'.
          _text = 'Durum'(f01) .
          r_fcat->just = 'C'.
        WHEN 'MSGSHW'.
          _text = 'İletiler'(f02).
          r_fcat->just = 'C'.
          r_fcat->hotspot = abap_true.
        WHEN 'KINDO'.
          _text = 'Ödm. Ref.'(f03).
        WHEN 'KINDU'.
          _text = 'Ödm. Yeni Ref.'(f04).

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
        is_layout_lvc            = VALUE lvc_s_layo( col_opt = abap_true box_fname = 'SELKZ' cwidth_opt = abap_true zebra = abap_true )
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
      MESSAGE s001(00) WITH 'ALV gösterimi sırasında hatalar oluştu!' RAISING contains_error.
    ENDIF.

  ENDMETHOD.
  METHOD display_applog.

    CALL FUNCTION 'FINB_BAPIRET2_DISPLAY'
      EXPORTING
        it_message = iv_msgdat.

  ENDMETHOD.

ENDCLASS.
*----------------------------------------------------------------------*
* CLASS lcl_controller DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_controller DEFINITION FINAL.

  PUBLIC SECTION.

    CONSTANTS:
      mc_model TYPE seoclsname VALUE 'LCL_MODEL',
      mc_view  TYPE seoclsname VALUE 'LCL_VIEW'.

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
      at_selection_screen_output,
      start_of_selection,
      end_of_selection,
      alv_session
        EXCEPTIONS
          contains_error,
      show_document
        EXCEPTIONS
          contains_error,
      display_message
        IMPORTING
          im_msgdat TYPE bapiret2_tab.


      private SECTION.
    METHODS:
      message_spool_display
        IMPORTING
          it_msgdat TYPE bapiret2_tab.


ENDCLASS.
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
  METHOD at_selection_screen_output.

    LOOP AT SCREEN.
      IF screen-name CS 'P_LIFNR'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ENDMETHOD.
  METHOD start_of_selection.

    _model->retrieve_data(
      EXPORTING
        iv_bukrs       = p_bukrs
        iv_gjahr       = p_gjahr
        iv_lifnr       = p_lifnr
        iv_blart       = s_blart[]
      EXCEPTIONS
        contains_error = 1
        OTHERS         = 2
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.
  METHOD end_of_selection.
  ENDMETHOD.
  METHOD alv_session.

    IF lines( _controller->mo_model->mt_outdat ) IS INITIAL.
      MESSAGE s001(00) WITH 'Seçim kriterlerine uygun veri bulunamadı!' RAISING contains_error.
    ENDIF.

    _controller->mo_view->prepare_fcatdat(
      EXPORTING
        im_strname     = _controller->mo_view->mc_strname
      EXCEPTIONS
        contains_error = 1
        OTHERS         = 2 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING contains_error.
    ENDIF.

    _controller->mo_view->display_alvdat(
      EXCEPTIONS
        contains_error = 1
        OTHERS         = 2 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING contains_error.
    ENDIF.

  ENDMETHOD.
  METHOD show_document.

    DATA: go_alv       TYPE REF TO cl_salv_table,
          lo_settings  TYPE REF TO cl_salv_display_settings,
          lr_functions TYPE REF TO cl_salv_functions_list,
          lr_columns   TYPE REF TO cl_salv_columns_table.

    lr_functions = go_alv->get_functions( ).
    lr_functions->set_all( 'X' ).
    lr_columns = go_alv->get_columns( ).
    lr_columns->set_optimize( 'X' ).
    lo_settings = go_alv->get_display_settings( ).
    lo_settings->set_striped_pattern( cl_salv_display_settings=>true ).

    IF go_alv IS BOUND.
      go_alv->set_screen_popup(
      start_column = 25
      start_line   = 6
      end_column   = 230
      end_line     = 30 ).
    ENDIF.
    go_alv->display( ).

  ENDMETHOD.
  METHOD display_message.
    cl_rmsl_message=>display(
  EXPORTING
    it_message = im_msgdat ).

  ENDMETHOD.

  METHOD message_spool_display.

    TYPES:
      BEGIN OF mty_mesgalv,
        status TYPE char200,
      END OF mty_mesgalv,
      mtt_mesgalv TYPE STANDARD TABLE OF mty_mesgalv.

    DATA: t_alvdat   TYPE mtt_mesgalv,
          t_fieldcat TYPE slis_t_fieldcat_alv,
          s_fieldcat TYPE slis_fieldcat_alv,
          s_layo     TYPE slis_layout_alv,
          _message   TYPE string.

    APPEND VALUE #( col_pos = '1' fieldname = 'STATUS' seltext_l = 'Status' outputlen = '200' ) TO t_fieldcat.
    LOOP AT it_msgdat ASSIGNING FIELD-SYMBOL(<msgdat>).
      CLEAR: _message.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = <msgdat>-id
          msgnr               = <msgdat>-number
          msgv1               = <msgdat>-message_v1
          msgv2               = <msgdat>-message_v2
          msgv3               = <msgdat>-message_v3
          msgv4               = <msgdat>-message_v4
        IMPORTING
          message_text_output = _message.
      IF NOT _message IS INITIAL.
        APPEND VALUE #( status = _message ) TO t_alvdat.
      ENDIF.
    ENDLOOP.
    CHECK NOT t_alvdat IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        is_layout     = s_layo
        it_fieldcat   = t_fieldcat
      TABLES
        t_outtab      = t_alvdat
      EXCEPTIONS
        program_error = 1
        OTHERS        = 2.

  ENDMETHOD.

ENDCLASS.