*&---------------------------------------------------------------------*
*& Include          ZFI_017_P01_CLSDAT
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Class           LCL_HELPER           Definition
*&---------------------------------------------------------------------*
CLASS lcl_helper DEFINITION.

  PUBLIC SECTION.

    CONSTANTS:
      mc_nr  TYPE nrnr  VALUE '01',
      mc_obj TYPE nrobj VALUE 'ZFI_017NR1'.

    CONSTANTS:
      BEGIN OF mc_msg,
        id      TYPE symsgid    VALUE 'ZFI_017',
        success TYPE bapi_mtype VALUE 'S',
        error   TYPE bapi_mtype VALUE 'E',
        warning TYPE bapi_mtype VALUE 'W',
        info    TYPE bapi_mtype VALUE 'I',
        abort   TYPE bapi_mtype VALUE 'A',
      END OF mc_msg.

    CLASS-DATA:helper TYPE REF TO lcl_helper.

    CLASS-METHODS:
      helper_instance
        RETURNING
          VALUE(mo_helper) TYPE REF TO lcl_helper.

    METHODS:
      set_description,
      set_default_values,
      field_required,
      init_listbox,
      authorization_envtp_cntl
        EXCEPTIONS
          handle_error,
      set_department_dat,
      set_fixed_asset_price,
      savedat
        EXCEPTIONS
          contains_error,
      deletedat
        EXCEPTIONS
          contains_error,
      enqueue_lock
        IMPORTING
          VALUE(iv_bukrs) TYPE bukrs
          VALUE(iv_envno) TYPE zfi_017_e001
        EXCEPTIONS
          contains_error,
      denqueue_lock
        IMPORTING
          VALUE(iv_bukrs) TYPE bukrs
          VALUE(iv_envno) TYPE zfi_017_e001
        EXCEPTIONS
          contains_error,
      check_lock
        IMPORTING
          VALUE(iv_bukrs) TYPE bukrs
          VALUE(iv_envno) TYPE zfi_017_e001
        EXCEPTIONS
          contains_error,
      get_jsondat
        EXCEPTIONS
          contains_error,
      display_history
        IMPORTING
          VALUE(iv_bukrs) TYPE bukrs
          VALUE(iv_envno) TYPE zfi_017_e001
        EXCEPTIONS
          contains_error,
      popup_confirm
        IMPORTING
          im_titlebar      TYPE clike
          im_question      TYPE clike
        RETURNING
          VALUE(rv_answer) TYPE char1,
      screen_double_click
        IMPORTING
          im_field TYPE char50
        EXCEPTIONS
          handle_error.

  PRIVATE SECTION.
    METHODS:
      get_domain_text
        IMPORTING
          im_dname       TYPE dd07l-domname
          im_value       TYPE clike
        RETURNING
          VALUE(rv_text) TYPE val_text
        EXCEPTIONS
          contains_error,
      number_get_next
        IMPORTING
          iv_range_nr      TYPE nrnr
          iv_object        TYPE nrobj
        RETURNING
          VALUE(rv_number) TYPE na_optar,
      get_timestamp
        RETURNING
          VALUE(rv_timez) TYPE tzntstmpl,
      display_message
        IMPORTING
          im_msgdat TYPE bapiret2_tab.


ENDCLASS.

*&---------------------------------------------------------------------*
*&  Class           LCL_HELPER           Implementation
*&---------------------------------------------------------------------*
CLASS lcl_helper IMPLEMENTATION.

  METHOD helper_instance.
    FREE: mo_helper, helper.
    IF lcl_helper=>helper IS NOT BOUND.
      CREATE OBJECT lcl_helper=>helper.
    ENDIF.
    mo_helper = helper.
  ENDMETHOD.
  METHOD set_description.

    SELECT SINGLE txt50 FROM zfi_017_t02 INTO @zfi_017_s01-envtp_desc WHERE envtp = @zfi_017_s01-envtp.
    IF NOT sy-subrc IS INITIAL.
      CLEAR: zfi_017_s01-envtp_desc.
    ENDIF.

    SELECT SINGLE txt50 FROM zfi_017_t17 INTO @zfi_017_s01-deprt_desc WHERE deprt = @zfi_017_s01-deprt.
    IF NOT sy-subrc IS INITIAL.
      CLEAR: zfi_017_s01-deprt_desc.
    ENDIF.

    DATA(_anln2) = COND #( WHEN zfi_017_s01-anln2 EQ space THEN '0000' ELSE zfi_017_s01-anln2 ).
    SELECT SINGLE txt50 FROM anla INTO @zfi_017_s01-txt50 WHERE bukrs = @zfi_017_s01-bukrs
                                                            AND anln1 = @zfi_017_s01-anln1
                                                            AND anln2 = @_anln2.
    IF NOT sy-subrc IS INITIAL.
      CLEAR: zfi_017_s01-txt50.
    ENDIF.

    SELECT SINGLE txt50 FROM zfi_017_t04 INTO @zfi_017_s01-krtks_desc WHERE krtks = @zfi_017_s01-krtks.
    IF NOT sy-subrc IS INITIAL.
      CLEAR: zfi_017_s01-krtks_desc.
    ENDIF.

    SELECT SINGLE txt50 FROM zfi_017_t05 INTO @zfi_017_s01-envst_desc WHERE envst = @zfi_017_s01-envst.
    IF NOT sy-subrc IS INITIAL.
      CLEAR: zfi_017_s01-envst_desc.
    ENDIF.

    get_domain_text(
      EXPORTING
        im_dname       = 'ZFI_017_D007'
        im_value       = zfi_017_s01-statu
      RECEIVING
        rv_text        = DATA(_statu_desc)
      EXCEPTIONS
        contains_error = 1
        OTHERS         = 2 ).
    IF sy-subrc IS INITIAL.
      zfi_017_s01-statu_desc = SWITCH #(
        zfi_017_s01-statu
          WHEN '01' THEN |{ icon_incoming_task }({ _statu_desc })|
          WHEN '02' THEN |{ icon_outgoing_task }({ _statu_desc })|
          WHEN '03' THEN |{ icon_incoming_employee }({ _statu_desc })|
          WHEN '04' THEN |{ icon_outgoing_employee }({ _statu_desc })|
          WHEN '05' THEN |{ icon_delete }({ _statu_desc })|
          WHEN '06' THEN |{ icon_price_analysis }({ _statu_desc })|
          ELSE |{ icon_failure }({ _statu_desc })| ).
    ENDIF.

  ENDMETHOD.
  METHOD set_default_values.

    IF zfi_017_s01-anln1 IS NOT INITIAL AND zfi_017_s01-anln2 EQ space.
      zfi_017_s01-anln2 = '0000'.
    ENDIF.

  ENDMETHOD.
  METHOD field_required.

    SELECT fname FROM zfi_017_t07
      INTO TABLE @DATA(t_required)
        WHERE required EQ @abap_true.

    LOOP AT t_required ASSIGNING FIELD-SYMBOL(<required>).
      ASSIGN COMPONENT <required>-fname OF STRUCTURE zfi_017_s01 TO FIELD-SYMBOL(<value>).
      IF <value> IS ASSIGNED.
        CHECK <value> IS INITIAL.
        get_domain_text(
          EXPORTING
            im_dname       = 'ZFI_017_D006'
            im_value       = <required>-fname
          RECEIVING
            rv_text        = DATA(_text)
          EXCEPTIONS
            contains_error = 1
            OTHERS         = 2 ).
        IF sy-subrc IS INITIAL.
          MESSAGE e002 WITH _text. EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
  METHOD init_listbox.

    DATA: t_list TYPE vrm_values.

    IF sy-ucomm EQ 'MARKA'.
      CLEAR: zfi_017_s01-model, zfi_017_s01-modtp, t_list.
      SELECT model
        FROM zfi_017_t13
          INTO @DATA(_model)
            WHERE marka = @zfi_017_s01-marka.
        APPEND VALUE #( key = _model ) TO t_list.
      ENDSELECT.

      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id     = 'ZFI_017_S01-MODEL'
          values = t_list.

      CLEAR: t_list.
      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id     = 'ZFI_017_S01-MODTP'
          values = t_list.
    ENDIF.

    IF sy-ucomm EQ 'MODEL'.
      CLEAR: zfi_017_s01-modtp, t_list.
      SELECT modtp FROM zfi_017_t14
        INTO @DATA(_modtp)
          WHERE marka = @zfi_017_s01-marka
            AND model = @zfi_017_s01-model.
        APPEND VALUE #( key = _modtp ) TO t_list.
      ENDSELECT.

      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id     = 'ZFI_017_S01-MODTP'
          values = t_list.
    ENDIF.

    IF sy-ucomm EQ 'LKSYN'.
      CLEAR: zfi_017_s01-bolum, t_list.
      SELECT bolum FROM zfi_017_t16
        INTO @DATA(_bolum)
          WHERE lksyn = @zfi_017_s01-lksyn.
        APPEND VALUE #( key = _bolum ) TO t_list.
      ENDSELECT.

      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id     = 'ZFI_017_S01-BOLUM'
          values = t_list.
    ENDIF.

  ENDMETHOD.
  METHOD set_department_dat.

    SELECT SINGLE deprt
      FROM zfi_017_t02
        INTO @zfi_017_s01-deprt
         WHERE envtp EQ @zfi_017_s01-envtp.

  ENDMETHOD.
  METHOD authorization_envtp_cntl.

    IF NOT zfi_017_s01-deprt IS INITIAL.
      zfi_017_cl01=>_authority_check(
        EXPORTING
          iv_bukrs       = COND #( WHEN zfi_017_s01-bukrs IS INITIAL THEN '*' ELSE zfi_017_s01-bukrs )
          iv_zzdepart    = zfi_017_s01-deprt
        EXCEPTIONS
          not_authorized = 1
          OTHERS         = 2 ).
      IF sy-subrc <> 0.
        CLEAR: zfi_017_s01-envtp, zfi_017_s01-deprt.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING handle_error.
      ENDIF.
    ENDIF.

  ENDMETHOD.
  METHOD set_fixed_asset_price.

    SELECT SUM( answl + kansw ), 'TRY' AS waers
      FROM anlc
        INTO (@zfi_017_s01-fiyat, @zfi_017_s01-waers)
          WHERE bukrs EQ @zfi_017_s01-bukrs
            AND anln1 EQ @zfi_017_s01-anln1
            AND anln2 EQ @zfi_017_s01-anln2
            AND afabe EQ '01'.

  ENDMETHOD.
  METHOD savedat.

    DATA: mt_msgdat  TYPE bapiret2_tab,
          s_basedat  TYPE zfi_017_t01,
          s_logdat   TYPE zfi_017_t08,
          t_jsondat  TYPE tt_jsondat,
          t_fixasset TYPE zfi_017_tt25,
          _jsondat   TYPE string,
          _descdat   TYPE string.

    FREE: t_jsondat, _jsondat.
    t_jsondat = CORRESPONDING #( gt_jsondat[] ).

    cl_fdt_json=>data_to_json(
      EXPORTING
        ia_data = t_jsondat
      RECEIVING
        rv_json = _jsondat ).

    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text   = _jsondat
      IMPORTING
        buffer = gv_jsondat.

    FREE: lt_text.
    CALL METHOD lr_text_edit->get_text_as_r3table
      IMPORTING
        table = lt_text.

    CLEAR: _descdat.
    CONCATENATE LINES OF lt_text INTO _descdat SEPARATED BY cl_abap_char_utilities=>cr_lf.

    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text   = _descdat
      IMPORTING
        buffer = gv_descdat.

    IF *zfi_017_s01 EQ zfi_017_s01 AND gv_jsondat EQ gv_jsondat_old AND gv_descdat EQ gv_descdat_old.
      MESSAGE s003 RAISING contains_error.
    ENDIF.

    CASE gv_mode.
      WHEN gc_action-create.

        zfi_017_cl01=>next_dept_number(
          EXPORTING
            iv_evntp = zfi_017_s01-envtp
          RECEIVING
            rv_envno = DATA(_envno)
          EXCEPTIONS
            error    = 1
            OTHERS   = 2 ).
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING contains_error.
        ENDIF.

        zfi_017_s01 = VALUE #( BASE zfi_017_s01 envno = _envno statu = '01' statu_desc = |{ icon_incoming_task }({ get_domain_text( im_dname = 'ZFI_017_D007' im_value = '01' ) })| ).

        CLEAR: s_basedat.
        s_basedat = CORRESPONDING #( zfi_017_s01 ).
        s_basedat = VALUE #( BASE s_basedat envoz = gv_jsondat acklm = gv_descdat ).

        MODIFY zfi_017_t01 FROM s_basedat.
        IF sy-subrc IS INITIAL.
          gv_mode = gc_action-display.
          *zfi_017_s01 = zfi_017_s01.
          gv_jsondat_old = gv_jsondat.
          gv_descdat_old = gv_descdat.

          CLEAR: s_logdat.
          s_logdat = CORRESPONDING #( s_basedat ).
          s_logdat = VALUE #( BASE s_logdat timez = get_timestamp( ) statu = 'CREATE' erdat = sy-datum erzet = sy-uzeit ernam = sy-uname ).
          MODIFY zfi_017_t08 FROM s_logdat.

          IF NOT s_basedat-anln1 IS INITIAL.
            mt_msgdat = zfi_017_cl01=>_set_fasset_inventory(
              EXPORTING
                im_fixasset = VALUE #( ( companycode = s_basedat-bukrs asset = s_basedat-anln1 subnumber = s_basedat-anln2 invent_no = s_basedat-envno ) ) ).
            IF line_exists( mt_msgdat[ type = mc_msg-error ] ).
              gv_mode = gc_action-edit.
              ROLLBACK WORK.
              display_message(
                EXPORTING
                  im_msgdat = mt_msgdat ).
              RETURN.
            ENDIF.
          ENDIF.

          COMMIT WORK AND WAIT.
          MESSAGE i004 DISPLAY LIKE 'S'.
        ENDIF.

      WHEN gc_action-edit.

        CLEAR: s_basedat.
        s_basedat = CORRESPONDING #( zfi_017_s01 ).
        s_basedat = VALUE #( BASE s_basedat envoz = gv_jsondat acklm = gv_descdat ).

        FREE: t_fixasset.
        IF *zfi_017_s01-anln1 IS NOT INITIAL AND ( *zfi_017_s01-anln1 NE s_basedat-anln1 OR *zfi_017_s01-anln2 NE s_basedat-anln2 ).
          APPEND VALUE #(
            companycode = *zfi_017_s01-bukrs
            asset = *zfi_017_s01-anln1
            subnumber = *zfi_017_s01-anln2
            invent_no = space ) TO t_fixasset.
        ENDIF.

        MODIFY zfi_017_t01 FROM s_basedat.
        IF sy-subrc IS INITIAL.
          gv_mode = gc_action-display.
          *zfi_017_s01 = zfi_017_s01.
          gv_jsondat_old = gv_jsondat.
          gv_descdat_old = gv_descdat.

          CLEAR: s_logdat.
          s_logdat = CORRESPONDING #( s_basedat ).
          s_logdat = VALUE #( BASE s_logdat timez = get_timestamp( ) statu = 'UPDATE' erdat = sy-datum erzet = sy-uzeit ernam = sy-uname ).
          MODIFY zfi_017_t08 FROM s_logdat.

          IF NOT s_basedat-anln1 IS INITIAL.
            APPEND VALUE #(
              companycode = s_basedat-bukrs
              asset = s_basedat-anln1
              subnumber = s_basedat-anln2
              invent_no = s_basedat-envno ) TO t_fixasset.
          ENDIF.

          IF NOT t_fixasset IS INITIAL.
            mt_msgdat = zfi_017_cl01=>_set_fasset_inventory(
              EXPORTING
                im_fixasset = t_fixasset ).
            IF line_exists( mt_msgdat[ type = mc_msg-error ] ).
              gv_mode = gc_action-edit.
              ROLLBACK WORK.
              display_message(
                EXPORTING
                  im_msgdat = mt_msgdat ).
              RETURN.
            ENDIF.
          ENDIF.

          COMMIT WORK AND WAIT.
          MESSAGE i004 DISPLAY LIKE 'S'.

          denqueue_lock(
            EXPORTING
              iv_bukrs       = zfi_017_s01-bukrs
              iv_envno       = zfi_017_s01-envno
            EXCEPTIONS
              contains_error = 1
              OTHERS         = 2 ).
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING contains_error.
          ENDIF.
        ENDIF.
    ENDCASE.

  ENDMETHOD.
  METHOD deletedat.

    DATA: s_logdat  TYPE zfi_017_t08,
          mt_msgdat TYPE bapiret2_tab.

    IF gv_mode NE gc_action-display.
      MESSAGE e032 RAISING contains_error.
    ENDIF.

    IF zfi_017_s01-statu EQ '01'.
      check_lock(
        EXPORTING
          iv_bukrs       = zfi_017_s01-bukrs
          iv_envno       = zfi_017_s01-envno
        EXCEPTIONS
          contains_error = 1
          OTHERS         = 2 ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING contains_error.
      ENDIF.

      UPDATE zfi_017_t01 SET statu = '05'
        WHERE bukrs = zfi_017_s01-bukrs
          AND envno = zfi_017_s01-envno.
      IF sy-subrc IS INITIAL.
        CLEAR: s_logdat.
        s_logdat = CORRESPONDING #( zfi_017_s01 ).
        s_logdat = VALUE #( BASE s_logdat timez = get_timestamp( ) statu = 'DELETE' erdat = sy-datum erzet = sy-uzeit ernam = sy-uname ).
        MODIFY zfi_017_t08 FROM s_logdat.

        IF NOT zfi_017_s01-anln1 IS INITIAL.
          mt_msgdat = zfi_017_cl01=>_set_fasset_inventory(
            EXPORTING
              im_fixasset = VALUE #( ( companycode = zfi_017_s01-bukrs asset = zfi_017_s01-anln1 subnumber = zfi_017_s01-anln2 invent_no = space ) ) ).
          IF line_exists( mt_msgdat[ type = mc_msg-error ] ).
            ROLLBACK WORK.
            display_message(
              EXPORTING
                im_msgdat = mt_msgdat ).
            RETURN.
          ENDIF.
        ENDIF.

        COMMIT WORK AND WAIT.
        MESSAGE i006.
        FREE: gt_search.
        SET SCREEN 9000.
      ENDIF.
    ELSE.
      MESSAGE e005 RAISING contains_error.
    ENDIF.

  ENDMETHOD.
  METHOD enqueue_lock.

    DATA: l_sbrc TYPE sy-subrc,
          t_ptab TYPE abap_func_parmbind_tab,
          t_enq  TYPE TABLE OF seqg3.

    TRY.
        FREE: l_sbrc, t_enq.
        l_sbrc = zfi_helper_cl04=>check_lock_object(
          EXPORTING
            iv_lock_entry    = CONV #( |ZFI_017_S10| )
            iv_key           = CONV #( |{ sy-mandt }{ iv_bukrs }{ iv_envno }| )
            iv_max_wait_time = 0
          IMPORTING
            et_enq           = t_enq ).
        IF l_sbrc IS INITIAL.
          gv_mode = gc_action-display.
          MESSAGE e031(zfi_017) WITH VALUE #( t_enq[ 1 ]-guname ) RAISING contains_error.
        ENDIF.
      CATCH zcx_bc_manage_lock INTO DATA(lx_lock).
        MESSAGE x000(zfi_017) WITH lx_lock->get_text( ).
    ENDTRY.

    FREE: t_ptab.
    t_ptab = VALUE #( BASE t_ptab ( name = 'MANDT' kind = abap_func_exporting value = REF #( sy-mandt ) )
                                  ( name = 'BUKRS' kind = abap_func_exporting value = REF #( iv_bukrs ) )
                                  ( name = 'ENVNO' kind = abap_func_exporting value = REF #( iv_envno ) ) ).
    TRY.
        DATA(t_retdat) = zfi_helper_cl04=>enqueue_lock_object(
          EXPORTING
            iv_fnam = 'ENQUEUE_EZFI_017_L01'
            iv_ptab = t_ptab ).
      CATCH zcx_bc_manage_lock INTO lx_lock.
        MESSAGE x000(zfi_017) WITH lx_lock->get_text( ) RAISING contains_error.
    ENDTRY.

  ENDMETHOD.
  METHOD denqueue_lock.

    DATA: t_ptab TYPE abap_func_parmbind_tab,
          t_enq  TYPE TABLE OF seqg3.

    FREE: t_ptab.
    t_ptab = VALUE #( BASE t_ptab ( name = 'MANDT' kind = abap_func_exporting value = REF #( sy-mandt ) )
                                  ( name = 'BUKRS' kind = abap_func_exporting value = REF #( iv_bukrs ) )
                                  ( name = 'ENVNO' kind = abap_func_exporting value = REF #( iv_envno ) ) ).
    TRY.
        DATA(t_retdat) = zfi_helper_cl04=>dequeue_lock_object(
          EXPORTING
            iv_fnam = 'DEQUEUE_EZFI_017_L01'
            iv_ptab = t_ptab ).
      CATCH zcx_bc_manage_lock INTO DATA(lx_lock).
        MESSAGE x000(zfi_017) WITH lx_lock->get_text( ) RAISING contains_error.
    ENDTRY.

  ENDMETHOD.
  METHOD check_lock.

    DATA: l_sbrc TYPE sy-subrc,
          t_enq  TYPE TABLE OF seqg3.

    TRY.
        FREE: l_sbrc, t_enq.
        l_sbrc = zfi_helper_cl04=>check_lock_object(
          EXPORTING
            iv_lock_entry    = CONV #( |ZFI_017_S10| )
            iv_key           = CONV #( |{ sy-mandt }{ iv_bukrs }{ iv_envno }| )
            iv_max_wait_time = 0
          IMPORTING
            et_enq           = t_enq ).
        IF l_sbrc IS INITIAL.
          MESSAGE e031(zfi_017) WITH VALUE #( t_enq[ 1 ]-guname ) RAISING contains_error.
        ENDIF.
      CATCH zcx_bc_manage_lock INTO DATA(lx_lock).
        MESSAGE x000(zfi_017) WITH lx_lock->get_text( ) RAISING contains_error.
    ENDTRY.

  ENDMETHOD.
  METHOD get_jsondat.

    DATA: t_jsondat TYPE tt_jsondat,
          _jsondat  TYPE string.

    FREE: gv_jsondat.
    SELECT SINGLE envoz FROM zfi_017_t01 INTO @gv_jsondat WHERE bukrs = @zfi_017_s01-bukrs AND envno = @zfi_017_s01-envno.
    IF sy-subrc IS INITIAL.
      gv_jsondat_old = gv_jsondat.
    ENDIF.

    CLEAR: _jsondat.
    CALL FUNCTION 'ECATT_CONV_XSTRING_TO_STRING'
      EXPORTING
        im_xstring = gv_jsondat
      IMPORTING
        ex_string  = _jsondat.

    cl_fdt_json=>json_to_data(
      EXPORTING
        iv_json = _jsondat
      CHANGING
        ca_data = t_jsondat ).

    IF gt_jsondat[] IS INITIAL OR zfi_017_s01-envtp <> *zfi_017_s01-envtp.
      FREE: gt_jsondat[].
      SELECT zfi_017_t03~envtp, zfi_017_t03~envoz, zfi_017_t06~txt50
        FROM zfi_017_t03
          INNER JOIN zfi_017_t06
            ON zfi_017_t06~envoz = zfi_017_t03~envoz
            INTO TABLE @DATA(t_t03dat)
            WHERE envtp = @zfi_017_s01-envtp.
      IF sy-subrc IS INITIAL.
        LOOP AT t_t03dat ASSIGNING FIELD-SYMBOL(<t03dat>).
          APPEND VALUE #( envoz = <t03dat>-envoz
                          header = <t03dat>-txt50
                          value = VALUE #( t_jsondat[ envoz = <t03dat>-envoz ]-value  OPTIONAL )
                          celltab = COND #( WHEN gv_mode <> gc_action-display THEN VALUE #( ( fieldname  = 'VALUE' style = cl_gui_alv_grid=>mc_style_enabled ) ) ) ) TO gt_jsondat.
        ENDLOOP.
      ENDIF.
      *zfi_017_s01-envtp = zfi_017_s01-envtp.
    ELSE.
      LOOP AT gt_jsondat ASSIGNING FIELD-SYMBOL(<jsondat>).
        READ TABLE t_jsondat ASSIGNING FIELD-SYMBOL(<json>) WITH TABLE KEY envoz = <jsondat>-envoz.
        IF sy-subrc IS INITIAL.
          <jsondat>-value = <json>-value.
        ENDIF.
        FREE: <jsondat>-celltab.
        <jsondat>-celltab = COND #( WHEN gv_mode <> gc_action-display THEN VALUE #( ( fieldname = 'VALUE' style = cl_gui_alv_grid=>mc_style_enabled ) ) ).
      ENDLOOP.
    ENDIF.

  ENDMETHOD.
  METHOD display_history.

    DATA: lo_alv       TYPE REF TO cl_salv_table,
          lo_settings  TYPE REF TO cl_salv_display_settings,
          lr_functions TYPE REF TO cl_salv_functions_list,
          lr_columns   TYPE REF TO cl_salv_columns_table.

    zfi_017_cl01=>debt_history(
      EXPORTING
        iv_bukrs   = zfi_017_s01-bukrs
        iv_envno   = zfi_017_s01-envno
      RECEIVING
        rv_history = DATA(_approvaldat)
      EXCEPTIONS
        cx_error   = 1
        OTHERS     = 2 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING contains_error.
    ENDIF.

    CALL FUNCTION 'ZFI_017_FM02'
      EXPORTING
        iv_historydat = _approvaldat.

  ENDMETHOD.
  METHOD popup_confirm.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = im_titlebar
        text_question         = im_question
        text_button_1         = 'Evet'
        text_button_2         = 'Hayır'
        default_button        = '2'
        display_cancel_button = abap_true
      IMPORTING
        answer                = rv_answer
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.

  ENDMETHOD.
  METHOD screen_double_click.

    CASE im_field.
      WHEN 'ZFI_017_S01-ANLN1'.
        IF zfi_017_s01-bukrs IS NOT INITIAL AND
           zfi_017_s01-anln1 IS NOT INITIAL AND
           zfi_017_s01-anln2 IS NOT INITIAL.
          zfi_017_cl01=>display_asset_card(
            EXPORTING
              im_bukrs     = zfi_017_s01-bukrs
              im_anln1     = zfi_017_s01-anln1
              im_anln2     = zfi_017_s01-anln2
            EXCEPTIONS
              handle_error = 1
              OTHERS       = 2 ).
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.


  ENDMETHOD.
  METHOD get_domain_text.

    DATA: lt_tab TYPE TABLE OF dd07v.

    FREE: lt_tab.
    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname        = im_dname
        text           = abap_true
        langu          = sy-langu
      TABLES
        dd07v_tab      = lt_tab
      EXCEPTIONS
        wrong_textflag = 1
        OTHERS         = 2.

    READ TABLE lt_tab INTO DATA(wa_tab) WITH KEY domvalue_l = im_value.
    IF sy-subrc IS INITIAL.
      rv_text = wa_tab-ddtext.
    ELSE.
    ENDIF.

  ENDMETHOD.
  METHOD number_get_next.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = iv_range_nr
        object                  = iv_object
      IMPORTING
        number                  = rv_number
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.

  ENDMETHOD.
  METHOD get_timestamp.

    GET TIME STAMP FIELD rv_timez.
    CALL METHOD cl_abap_tstmp=>add
      EXPORTING
        tstmp   = rv_timez
        secs    = sy-tzone
      RECEIVING
        r_tstmp = rv_timez.

  ENDMETHOD.
  METHOD display_message.

    cl_rmsl_message=>display(
      EXPORTING
        it_message = im_msgdat ).

  ENDMETHOD.

ENDCLASS.

*&---------------------------------------------------------------------*
*&  Class           LCL_HANDLE           Definition
*&---------------------------------------------------------------------*
CLASS lcl_handle DEFINITION.

  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          iv_screen TYPE sy-dynnr,
      handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING
          e_object
          e_interactive,
      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING
          e_row,
      handle_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING
          e_column_id
          es_row_no,
      handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING
          er_data_changed
          e_onf4
          e_ucomm.

  PRIVATE SECTION.
    DATA: mv_screen TYPE sy-dynnr.

ENDCLASS.
*&---------------------------------------------------------------------*
*&  Class           LCL_HANDLE           Implementation
*&---------------------------------------------------------------------*
CLASS lcl_handle IMPLEMENTATION.

  METHOD constructor.
    mv_screen = iv_screen.
  ENDMETHOD.
  METHOD handle_toolbar.
  ENDMETHOD.
  METHOD handle_double_click.

    CASE mv_screen.
      WHEN '9002'.
        CLEAR: gs_selected.
        READ TABLE gt_search ASSIGNING FIELD-SYMBOL(<searchdat>) INDEX e_row-index.
        IF sy-subrc IS INITIAL.
          gs_selected = VALUE #( bukrs = <searchdat>-bukrs envno = <searchdat>-envno ).
          CALL SCREEN 9003.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.
  METHOD handle_hotspot_click.
  ENDMETHOD.
  METHOD handle_data_changed.

    LOOP AT er_data_changed->mt_good_cells ASSIGNING FIELD-SYMBOL(<cell>).
      READ TABLE gt_jsondat ASSIGNING FIELD-SYMBOL(<jsondat>) INDEX <cell>-row_id.
      IF <jsondat> IS ASSIGNED.
        SELECT SINGLE formt
          FROM zfi_017_t06
            INTO @DATA(_formt)
              WHERE envoz = @<jsondat>-envoz.

        CASE _formt.
          WHEN 'CHARACTER'.
            TRANSLATE <cell>-value TO UPPER CASE.
            CONDENSE <cell>-value NO-GAPS. CHECK <cell>-value <> space.
            IF NOT <cell>-value CA sy-abcde.
              CALL METHOD er_data_changed->add_protocol_entry
                EXPORTING
                  i_msgid     = 'ZFI_017'
                  i_msgty     = 'E'
                  i_msgno     = '021'
                  i_fieldname = <cell>-fieldname
                  i_row_id    = <cell>-row_id.
            ENDIF.

          WHEN 'NUMERIC'.
            CONDENSE <cell>-value NO-GAPS. CHECK <cell>-value <> space.
            CALL FUNCTION 'CATS_NUMERIC_INPUT_CHECK'
              EXPORTING
                input      = <cell>-value
              EXCEPTIONS
                no_numeric = 1
                OTHERS     = 2.
            IF NOT sy-subrc IS INITIAL.
              CALL METHOD er_data_changed->add_protocol_entry
                EXPORTING
                  i_msgid     = sy-msgid
                  i_msgty     = sy-msgty
                  i_msgno     = sy-msgno
                  i_msgv1     = sy-msgv1
                  i_msgv2     = sy-msgv2
                  i_msgv3     = sy-msgv3
                  i_msgv4     = sy-msgv4
                  i_fieldname = <cell>-fieldname
                  i_row_id    = <cell>-row_id.
            ENDIF.

          WHEN 'DATE'.
            IF <cell>-value IS NOT INITIAL.
              CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
                EXPORTING
                  date_external            = <cell>-value
                EXCEPTIONS
                  date_external_is_invalid = 1
                  OTHERS                   = 2.
              IF NOT sy-subrc IS INITIAL.
                CALL METHOD er_data_changed->add_protocol_entry
                  EXPORTING
                    i_msgid     = sy-msgid
                    i_msgty     = sy-msgty
                    i_msgno     = sy-msgno
                    i_msgv1     = sy-msgv1
                    i_msgv2     = sy-msgv2
                    i_msgv3     = sy-msgv3
                    i_msgv4     = sy-msgv4
                    i_fieldname = <cell>-fieldname
                    i_row_id    = <cell>-row_id.
              ENDIF.
            ENDIF.

          WHEN OTHERS.
        ENDCASE.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

*&---------------------------------------------------------------------*
*&  Class           LCL_SCREEN           Definition
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

    CLASS-METHODS:
      del_screen
        IMPORTING
          i_dynnr TYPE sy-dynnr.

  PRIVATE SECTION.
    DATA : screen TYPE sy-dynnr.
    TYPES :
      BEGIN OF lst_screen,
        screen TYPE REF TO lcl_screen,
      END OF lst_screen.

    CLASS-DATA : t_screen TYPE STANDARD TABLE OF lst_screen.
    CONSTANTS : c_class_name TYPE string VALUE 'LCL_SCREEN'.

ENDCLASS.                    "lcl_screen DEFINITION

*&---------------------------------------------------------------------*
*&  Class           LCL_SCREEN           Implementation
*&---------------------------------------------------------------------*
CLASS lcl_screen IMPLEMENTATION.
  METHOD constructor.
    screen = i_dynnr.
  ENDMETHOD.                    "constructor
  METHOD exit_command.
    CASE fcode.
      WHEN 'EXIT'.
        LEAVE PROGRAM.
    ENDCASE.
  ENDMETHOD.                    "exit_command
  METHOD get_screen.
    DATA : ls_screen TYPE lst_screen,
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
  ENDMETHOD.                    "get_screen
  METHOD del_screen.
    DATA : ls_screen TYPE lst_screen,
           lv_type   TYPE string.

    READ TABLE t_screen INTO ls_screen WITH KEY screen->screen = i_dynnr.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.
    ls_screen-screen->free( ).
    DELETE t_screen WHERE screen->screen = i_dynnr.
  ENDMETHOD.                    "del_screen
ENDCLASS.                    "lcl_screen IMPLEMENTATION

*&---------------------------------------------------------------------*
*&  Class           LCL_SCREEN_9000           Definition
*&---------------------------------------------------------------------*
CLASS lcl_screen_9000 DEFINITION INHERITING FROM lcl_screen FINAL.

  PUBLIC SECTION.
    METHODS:
      pbo REDEFINITION,
      pai REDEFINITION,
      free REDEFINITION.

  PRIVATE SECTION.
    METHODS:
      set_exclude
        RETURNING
          VALUE(rt_ex) TYPE status_excl_fcode_tt.
ENDCLASS.                    "lcl_screen_9000 DEFINITION

*&---------------------------------------------------------------------*
*&  Class           LCL_SCREEN_9000           Implementation
*&---------------------------------------------------------------------*
CLASS lcl_screen_9000 IMPLEMENTATION.
  METHOD pbo.
    DATA : lt_ex TYPE status_excl_fcode_tt.
    lt_ex = set_exclude( ).
    SET PF-STATUS 'STATUS_9000' EXCLUDING lt_ex.
    SET TITLEBAR '9000'.

    mo_helper = lcl_helper=>helper_instance( ).

  ENDMETHOD.                    "pbo
  METHOD set_exclude.
    DATA : lv_ex TYPE fcode.
    lv_ex = 'SAVE'.
    APPEND lv_ex
        TO rt_ex.
  ENDMETHOD.                    "set_exclude
  METHOD pai.
    CASE fcode.
      WHEN 'CREATE'.
        gv_mode = gc_action-create.
        CALL SCREEN 9003.
      WHEN 'BACK' OR 'CANC'.
        LEAVE PROGRAM.
    ENDCASE.
  ENDMETHOD.                    "pai
  METHOD free.

  ENDMETHOD.                    "free
ENDCLASS.                    "lcl_screen_9000 IMPLEMENTATION

*&---------------------------------------------------------------------*
*&  Class           LCL_SCREEN_9001           Definition
*&---------------------------------------------------------------------*
CLASS lcl_screen_9001 DEFINITION INHERITING FROM lcl_screen FINAL.
  PUBLIC SECTION.
    METHODS:
      pbo REDEFINITION,
      pai REDEFINITION,
      free REDEFINITION.
ENDCLASS.
*&---------------------------------------------------------------------*
*&  Class           LCL_SCREEN_9001           Implementation
*&---------------------------------------------------------------------*
CLASS lcl_screen_9001 IMPLEMENTATION.
  METHOD pbo.

  ENDMETHOD.                    "pbo
  METHOD pai.
    CASE fcode.
      WHEN 'ENTER'.
        IF zfi_017_s02-bukrs IS INITIAL AND zfi_017_s02-envno IS INITIAL.
          MESSAGE s019(zfi_017) DISPLAY LIKE 'E'. RETURN.
        ENDIF.

        SELECT SINGLE t01~bukrs, t01~envno, t01~envtp, t02~deprt
          FROM zfi_017_t01 AS t01
            LEFT OUTER JOIN zfi_017_t02 AS t02
              ON t02~envtp EQ t01~envtp
            INTO @DATA(_basedat)
              WHERE t01~bukrs = @zfi_017_s02-bukrs
                AND t01~envno = @zfi_017_s02-envno.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE s020(zfi_017) WITH zfi_017_s02-bukrs zfi_017_s02-envno DISPLAY LIKE 'E'. RETURN.
        ELSE.
          zfi_017_cl01=>_authority_check(
            EXPORTING
              iv_bukrs       = _basedat-bukrs
              iv_zzdepart    = _basedat-deprt
              iv_actvt       = zfi_017_cl01=>mc_actvt-display
            EXCEPTIONS
              not_authorized = 1
              OTHERS         = 2 ).
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4. RETURN.
          ENDIF.
        ENDIF.

        gv_mode = gc_action-display.
        gs_selected = VALUE #( bukrs = zfi_017_s02-bukrs envno = zfi_017_s02-envno ).
        CALL SCREEN 9003.
    ENDCASE.
  ENDMETHOD.                    "pai
  METHOD free.

  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*&  Class           LCL_SCREEN_9002           Definition
*&---------------------------------------------------------------------*
CLASS lcl_screen_9002 DEFINITION INHERITING FROM lcl_screen FINAL.
  PUBLIC SECTION.

    DATA: mo_cust   TYPE REF TO cl_gui_custom_container,
          mo_alv    TYPE REF TO cl_gui_alv_grid,
          mo_handle TYPE REF TO lcl_handle.

    METHODS:
      pbo REDEFINITION,
      pai REDEFINITION,
      free REDEFINITION,
      get_searchdat,
      display_alv
        EXCEPTIONS
          contains_error.


ENDCLASS.
*&---------------------------------------------------------------------*
*&  Class           LCL_SCREEN_9002           Implementation
*&---------------------------------------------------------------------*
CLASS lcl_screen_9002 IMPLEMENTATION.
  METHOD pbo.

    IF zfi_017_s02-maxhi IS INITIAL.
      zfi_017_s02-maxhi = 100.
    ENDIF.

    display_alv(
      EXCEPTIONS
        contains_error = 1
        OTHERS         = 2 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.                    "pbo
  METHOD pai.
    CASE fcode.
      WHEN 'ENTER' OR 'START'.
        get_searchdat( ).
      WHEN 'DELETE'.
        CLEAR: zfi_017_s02-bukrs, zfi_017_s02-envno.
    ENDCASE.
  ENDMETHOD.                    "pai
  METHOD free.

  ENDMETHOD.
  METHOD get_searchdat.

    DATA: t_bukrs_rng TYPE RANGE OF zfi_017_t01-bukrs,
          _likedat    TYPE string,
          _uptodat    TYPE numc4.

    FREE: t_bukrs_rng.
    IF NOT zfi_017_s02-bukrs IS INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = zfi_017_s02-bukrs ) TO t_bukrs_rng.
    ENDIF.

    CLEAR: _likedat.
    _likedat = COND #( WHEN zfi_017_s02-envno IS INITIAL THEN '*' ELSE zfi_017_s02-envno ).
    REPLACE ALL OCCURRENCES OF '*' IN  _likedat WITH '%'.

    CLEAR: _uptodat.
    _uptodat =  COND #( WHEN zfi_017_s02-maxhi IS INITIAL THEN '1' ELSE zfi_017_s02-maxhi ).

    FREE: gt_search.
    SELECT
      t01~bukrs,
      t01~envno,
      t01~envtp,
      t02~txt50 AS envtp_txt,
      t17~deprt,
      t17~txt50 AS deprt_txt,
      anla~anln1,
      anla~txt50
      FROM zfi_017_t01 AS t01
        LEFT OUTER JOIN zfi_017_t02 AS t02
          ON t02~envtp = t01~envtp
        LEFT OUTER JOIN zfi_017_t17 AS t17
          ON t17~deprt = t02~deprt
        LEFT OUTER JOIN anla
          ON anla~bukrs = t01~bukrs AND
             anla~anln1 = t01~anln1
        INTO TABLE @gt_search UP TO @_uptodat ROWS
        WHERE t01~bukrs IN @t_bukrs_rng
          AND t01~envno LIKE @_likedat.

    LOOP AT gt_search ASSIGNING FIELD-SYMBOL(<search>).
      zfi_017_cl01=>_authority_check(
        EXPORTING
          iv_bukrs       = <search>-bukrs
          iv_zzdepart    = <search>-deprt
          iv_actvt       = zfi_017_cl01=>mc_actvt-display
        EXCEPTIONS
          not_authorized = 1
          OTHERS         = 2 ).
      IF NOT sy-subrc IS INITIAL.
        DELETE gt_search.
      ENDIF.
    ENDLOOP.
    MESSAGE s001(zfi_017) WITH |{ lines( gt_search ) }|.

  ENDMETHOD.
  METHOD display_alv.

    DATA: t_fieldcat TYPE lvc_t_fcat,
          t_exclude  TYPE ui_functions,
          s_exclude  TYPE ui_func,
          s_layout   TYPE lvc_s_layo,
          s_variant  TYPE disvariant,
          t_sort     TYPE lvc_t_sort.

    DEFINE fill_exclude.
      s_exclude = &1  .
      APPEND s_exclude TO t_exclude.
    END-OF-DEFINITION.

    IF mo_alv IS NOT BOUND.
      CREATE OBJECT mo_cust
        EXPORTING
          container_name = 'CONT_9002'.

      CREATE OBJECT mo_alv
        EXPORTING
          i_parent = mo_cust.

      CREATE OBJECT mo_handle
        EXPORTING
          iv_screen = sy-dynnr.

      FREE: t_fieldcat.
      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name = 'ZFI_017_S03'
        CHANGING
          ct_fieldcat      = t_fieldcat.

      FREE: t_exclude.
      fill_exclude :
        cl_gui_alv_grid=>mc_fc_maintain_variant,
        cl_gui_alv_grid=>mc_fc_sort,
        cl_gui_alv_grid=>mc_fc_sort_asc,
        cl_gui_alv_grid=>mc_fc_sort_dsc,
        cl_gui_alv_grid=>mc_fc_sum,
        cl_gui_alv_grid=>mc_mb_sum,
        cl_gui_alv_grid=>mc_fc_subtot,
        cl_gui_alv_grid=>mc_fc_print,
        cl_gui_alv_grid=>mc_mb_export,
        cl_gui_alv_grid=>mc_mb_view,
        cl_gui_alv_grid=>mc_fc_info.

      LOOP AT t_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fieldcat>).
        CASE <fs_fieldcat>-fieldname.
          WHEN 'BUKRS'.
            <fs_fieldcat>-outputlen = '10'.
          WHEN 'ENVNO'.
            <fs_fieldcat>-outputlen = '15'.
          WHEN 'ENVTP'.
            <fs_fieldcat>-outputlen = '15'.
          WHEN 'ANLN1'.
            <fs_fieldcat>-outputlen = '15'.
          WHEN 'TXT50'.
            <fs_fieldcat>-outputlen = '80'.
        ENDCASE.
      ENDLOOP.

      CLEAR: s_layout.
      s_layout = VALUE #( col_opt = abap_false no_rowmark = abap_true ).

      CLEAR: s_variant.
      s_variant = VALUE #( report = sy-repid username = sy-uname ).

      FREE: t_sort.
      t_sort = VALUE #( ( fieldname  = 'ENVNO' up = abap_true ) ).

      SET HANDLER:
        mo_handle->handle_toolbar FOR mo_alv,
        mo_handle->handle_double_click FOR mo_alv,
        mo_handle->handle_hotspot_click FOR mo_alv.

      CALL METHOD mo_alv->set_table_for_first_display
        EXPORTING
          is_layout            = s_layout
          is_variant           = s_variant
          i_structure_name     = 'ZFI_017_S03'
          i_buffer_active      = 'X'
          i_bypassing_buffer   = 'X'
          i_save               = 'A'
          it_toolbar_excluding = t_exclude
        CHANGING
          it_outtab            = gt_search
          it_fieldcatalog      = t_fieldcat
          it_sort              = t_sort.
    ELSE.
      mo_alv->refresh_table_display(
        EXPORTING
          is_stable = VALUE #( row = abap_true col = abap_true )
        EXCEPTIONS
          finished  = 1
          OTHERS    = 2 ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING contains_error.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
*&---------------------------------------------------------------------*
*&  Class           LCL_SCREEN_9003           Definition
*&---------------------------------------------------------------------*
CLASS lcl_screen_9003 DEFINITION INHERITING FROM lcl_screen FINAL.
  PUBLIC SECTION.

    DATA: mo_cust   TYPE REF TO cl_gui_custom_container,
          mo_alv    TYPE REF TO cl_gui_alv_grid,
          mo_handle TYPE REF TO lcl_handle.

    METHODS:
      pbo REDEFINITION,
      pai REDEFINITION,
      free REDEFINITION,
      display_alv
        EXCEPTIONS
          contains_error.
  PRIVATE SECTION.
    METHODS:
      set_exclude
        RETURNING
          VALUE(rt_ex) TYPE status_excl_fcode_tt.
ENDCLASS.
*&---------------------------------------------------------------------*
*&  Class           LCL_SCREEN_9003           Implementation
*&---------------------------------------------------------------------*
CLASS lcl_screen_9003 IMPLEMENTATION.
  METHOD pbo.

    DATA: t_text TYPE TABLE OF as4text WITH DEFAULT KEY,
          _text  TYPE string,
          _left  TYPE string,
          _right TYPE string.

    mo_helper->set_default_values( ).
    mo_helper->init_listbox( ).

    IF gv_mode NE gc_action-display.
      LOOP AT SCREEN.
        IF screen-group1 EQ 'M1' AND screen-group2 NE 'KEY'.
          screen-input = 1.
        ENDIF.
        IF gv_mode EQ gc_action-create AND screen-group3 EQ 'M2'.
          screen-input = 1.
        ENDIF.
        SPLIT screen-name AT 'ZFI_017_S01-' INTO _left _right.
        SELECT SINGLE * FROM zfi_017_t07 INTO @DATA(zfi_017_t07) WHERE fname = @_right AND required EQ @abap_true.
        IF sy-subrc IS INITIAL.
          screen-required = 2.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.

    LOOP AT gt_jsondat ASSIGNING FIELD-SYMBOL(<jsondat>).
      FREE: <jsondat>-celltab.
      <jsondat>-celltab = COND #( WHEN gv_mode <> gc_action-display THEN VALUE #( ( fieldname  = 'VALUE' style = cl_gui_alv_grid=>mc_style_enabled ) )
                                  ELSE VALUE #( ( fieldname  = 'VALUE' style = cl_gui_alv_grid=>mc_style_disabled ) ) ).
    ENDLOOP.

    IF lr_custom_cont IS NOT BOUND.
      CREATE OBJECT lr_custom_cont
        EXPORTING
          container_name = 'CONT_DESC'
          repid          = sy-repid
          dynnr          = sy-dynnr.
    ENDIF.

    IF lr_text_edit IS NOT BOUND.
      CREATE OBJECT lr_text_edit
        EXPORTING
          wordwrap_mode              = cl_gui_textedit=>wordwrap_at_fixed_position
          wordwrap_position          = 100
          wordwrap_to_linebreak_mode = cl_gui_textedit=>true
          parent                     = lr_custom_cont.

      CALL METHOD lr_text_edit->set_toolbar_mode
        EXPORTING
          toolbar_mode = '0'.

      CALL METHOD lr_text_edit->set_statusbar_mode
        EXPORTING
          statusbar_mode = cl_gui_textedit=>false.
    ENDIF.

    IF gv_mode EQ gc_action-display.
      CALL METHOD lr_text_edit->set_readonly_mode
        EXPORTING
          readonly_mode = 1.
    ELSE.
      CALL METHOD lr_text_edit->set_readonly_mode
        EXPORTING
          readonly_mode = 0.
    ENDIF.

    IF gs_selected-bukrs IS NOT INITIAL AND gs_selected-envno IS NOT INITIAL.
      CLEAR: zfi_017_s01.
      SELECT SINGLE
        t01~bukrs,
        t01~envno,
        t01~envtp,
        t02~deprt,
        t01~anln1,
        t01~anln2,
        t01~marka,
        t01~model,
        t01~modtp,
        t01~serno,
        t01~krtks,
        t01~envst,
        t01~lksyn,
        t01~bolum,
        t01~fiyat,
        t01~waers,
        t01~acklm,
        t01~envoz,
        t01~statu,
        t01~owner
        FROM zfi_017_t01 AS t01
        LEFT OUTER JOIN zfi_017_t02 AS t02
          ON t02~envtp = t01~envtp
          INTO @DATA(basedat)
            WHERE t01~bukrs = @gs_selected-bukrs
              AND t01~envno = @gs_selected-envno.
      IF sy-subrc IS INITIAL.

        zfi_017_s01 = CORRESPONDING #( basedat ).
        mo_helper->set_description( ).

        *zfi_017_s01 = zfi_017_s01.

        IF NOT basedat-acklm IS INITIAL.

          gv_descdat = gv_descdat_old = basedat-acklm.

          CLEAR: _text.
          CALL FUNCTION 'ECATT_CONV_XSTRING_TO_STRING'
            EXPORTING
              im_xstring = basedat-acklm
            IMPORTING
              ex_string  = _text.

          SPLIT _text AT cl_abap_char_utilities=>cr_lf INTO TABLE t_text.

          CALL METHOD lr_text_edit->set_text_as_stream
            EXPORTING
              text            = t_text
            EXCEPTIONS
              error_dp        = 1
              error_dp_create = 2
              OTHERS          = 3.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ENDIF.
        CLEAR: gs_selected.
      ENDIF.
    ENDIF.

    mo_helper->get_jsondat(
      EXCEPTIONS
        contains_error = 1
        OTHERS         = 2 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    display_alv(
      EXCEPTIONS
        contains_error = 1
        OTHERS         = 2 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    DATA(t_exclude) = set_exclude( ).
    SET PF-STATUS 'STATUS_9003' EXCLUDING t_exclude.

  ENDMETHOD.                    "pbo
  METHOD pai.

    DATA: _cursor TYPE char50.

*->Check Auth. {
    IF boolc( fcode EQ 'EDIT' OR fcode EQ 'SAVE' OR fcode EQ 'DELETE' ) = abap_true.
      zfi_017_cl01=>_authority_check(
        EXPORTING
          iv_bukrs       = zfi_017_s01-bukrs
          iv_zzdepart    = zfi_017_s01-deprt
          iv_actvt       = COND #( WHEN fcode EQ 'EDIT' THEN COND #( WHEN gv_mode EQ gc_action-edit THEN zfi_017_cl01=>mc_actvt-display ELSE zfi_017_cl01=>mc_actvt-edit )
                                   WHEN fcode EQ 'SAVE' THEN zfi_017_cl01=>mc_actvt-create
                                   WHEN fcode EQ 'DELETE' THEN zfi_017_cl01=>mc_actvt-delete )
        EXCEPTIONS
          not_authorized = 1
          OTHERS         = 2 ).
      IF NOT sy-subrc IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty
          NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4. RETURN.
      ENDIF.
    ENDIF.
*<-Check Auth. }

    CASE fcode.
      WHEN 'BACK' OR 'CANC'.
        LEAVE PROGRAM.

      WHEN 'EDIT'.
        gv_mode = COND #( WHEN gv_mode EQ gc_action-edit THEN gc_action-display ELSE gc_action-edit ).

        CASE gv_mode.
          WHEN gc_action-edit.
            mo_helper->enqueue_lock(
              EXPORTING
                iv_bukrs       = zfi_017_s01-bukrs
                iv_envno       = zfi_017_s01-envno
              EXCEPTIONS
                contains_error = 1
                OTHERS         = 2 ).
            IF sy-subrc IS NOT INITIAL.
              MESSAGE ID sy-msgid TYPE sy-msgty
                NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.

          WHEN gc_action-display.
            mo_helper->denqueue_lock(
              EXPORTING
                iv_bukrs       = zfi_017_s01-bukrs
                iv_envno       = zfi_017_s01-envno
              EXCEPTIONS
                contains_error = 1
                OTHERS         = 2 ).
            IF sy-subrc IS NOT INITIAL.
              MESSAGE ID sy-msgid TYPE sy-msgty
                NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.

      WHEN 'SAVE'.
        mo_helper->savedat(
          EXCEPTIONS
            contains_error = 1
            OTHERS         = 2 ).
        IF sy-subrc IS NOT INITIAL.
          MESSAGE ID sy-msgid TYPE sy-msgty
            NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

      WHEN 'DELETE'.
        CHECK mo_helper->popup_confirm(
          EXPORTING
            im_titlebar = TEXT-t01
            im_question = TEXT-t02 ) EQ '1'.

        mo_helper->deletedat(
          EXCEPTIONS
            contains_error = 1
            OTHERS         = 2 ).
        IF sy-subrc IS NOT INITIAL.
          MESSAGE ID sy-msgid TYPE sy-msgty
            NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

      WHEN 'HISTORY'.
        mo_helper->display_history(
          EXPORTING
            iv_bukrs       = zfi_017_s01-bukrs
            iv_envno       = zfi_017_s01-envno
          EXCEPTIONS
            contains_error = 1
            OTHERS         = 2 ).
        IF sy-subrc IS NOT INITIAL.
          MESSAGE ID sy-msgid TYPE sy-msgty
            NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      WHEN 'PICK'.

        CLEAR: _cursor.
        GET CURSOR FIELD _cursor.
        mo_helper->screen_double_click(
          EXPORTING
            im_field     = _cursor
          EXCEPTIONS
            handle_error = 1
            OTHERS       = 2 ).
        IF sy-subrc IS NOT INITIAL.
          MESSAGE ID sy-msgid TYPE sy-msgty
            NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

    ENDCASE.
  ENDMETHOD.                    "pai
  METHOD free.

  ENDMETHOD.
  METHOD display_alv.

    DATA: t_fieldcat TYPE lvc_t_fcat,
          t_exclude  TYPE ui_functions,
          s_exclude  TYPE ui_func,
          s_layout   TYPE lvc_s_layo,
          s_variant  TYPE disvariant,
          t_sort     TYPE lvc_t_sort.

    DEFINE fill_exclude.
      s_exclude = &1  .
      APPEND s_exclude TO t_exclude.
    END-OF-DEFINITION.

    IF mo_alv IS NOT BOUND.
      CREATE OBJECT mo_cust
        EXPORTING
          container_name = 'CONT_9003'.

      CREATE OBJECT mo_alv
        EXPORTING
          i_parent = mo_cust.

      CREATE OBJECT mo_handle
        EXPORTING
          iv_screen = sy-dynnr.

      FREE: t_fieldcat.
      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name = 'ZFI_017_S04'
        CHANGING
          ct_fieldcat      = t_fieldcat.

      LOOP AT t_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fieldcat>).
        CASE <fs_fieldcat>-fieldname.
          WHEN 'ENVOZ'.
            <fs_fieldcat>-no_out = abap_true.
        ENDCASE.
      ENDLOOP.

      FREE: t_exclude.
      fill_exclude :
        cl_gui_alv_grid=>mc_fc_maintain_variant,
        cl_gui_alv_grid=>mc_fc_sort,
        cl_gui_alv_grid=>mc_fc_sort_asc,
        cl_gui_alv_grid=>mc_fc_sort_dsc,
        cl_gui_alv_grid=>mc_fc_sum,
        cl_gui_alv_grid=>mc_mb_sum,
        cl_gui_alv_grid=>mc_fc_subtot,
        cl_gui_alv_grid=>mc_fc_print,
        cl_gui_alv_grid=>mc_mb_export,
        cl_gui_alv_grid=>mc_mb_view,
        cl_gui_alv_grid=>mc_fc_info,
        cl_gui_alv_grid=>mc_fc_loc_copy_row,
        cl_gui_alv_grid=>mc_fc_loc_delete_row,
        cl_gui_alv_grid=>mc_fc_loc_append_row,
        cl_gui_alv_grid=>mc_fc_loc_insert_row,
        cl_gui_alv_grid=>mc_fc_loc_move_row,
        cl_gui_alv_grid=>mc_fc_loc_copy,
        cl_gui_alv_grid=>mc_fc_loc_cut,
        cl_gui_alv_grid=>mc_fc_loc_paste,
        cl_gui_alv_grid=>mc_fc_loc_paste_new_row,
        cl_gui_alv_grid=>mc_fc_loc_undo,
        cl_gui_alv_grid=>mc_fc_graph,
        cl_gui_alv_grid=>mc_fc_info,
        cl_gui_alv_grid=>mc_fc_refresh,
        cl_gui_alv_grid=>mc_fc_print,
        cl_gui_alv_grid=>mc_fc_detail,
        cl_gui_alv_grid=>mc_fc_check.

      CLEAR: s_layout.
      s_layout = VALUE #( col_opt = abap_false no_rowmark = abap_true   stylefname = 'CELLTAB' ).

      CLEAR: s_variant.
      s_variant = VALUE #( report = sy-repid username = sy-uname ).

*      FREE: t_sort.
*      t_sort = VALUE #( ( fieldname  = 'ENVNO' up = abap_true ) ).

      SET HANDLER:
        mo_handle->handle_toolbar FOR mo_alv,
        mo_handle->handle_double_click FOR mo_alv,
        mo_handle->handle_hotspot_click FOR mo_alv,
        mo_handle->handle_data_changed FOR mo_alv.

      CALL METHOD mo_alv->set_table_for_first_display
        EXPORTING
          is_layout            = s_layout
          is_variant           = s_variant
          i_structure_name     = 'ZFI_017_S04'
          i_buffer_active      = 'X'
          i_bypassing_buffer   = 'X'
          i_save               = 'A'
          it_toolbar_excluding = t_exclude
        CHANGING
          it_outtab            = gt_jsondat
          it_fieldcatalog      = t_fieldcat
          it_sort              = t_sort.

      CALL METHOD mo_alv->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_modified.

      mo_alv->set_ready_for_input(
        EXPORTING
          i_ready_for_input = '1' ).

    ELSE.
      mo_alv->refresh_table_display(
        EXPORTING
          is_stable = VALUE #( row = abap_true col = abap_true )
        EXCEPTIONS
          finished  = 1
          OTHERS    = 2 ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING contains_error.
      ENDIF.
    ENDIF.

  ENDMETHOD.
  METHOD set_exclude.

    CASE gv_mode.
      WHEN gc_action-create.
        rt_ex = VALUE #( ( 'EDIT' ) ( 'DELETE' ) ( 'HISTORY' ) ).
      WHEN gc_action-display.
        rt_ex = VALUE #( ( 'SAVE' ) ).
    ENDCASE.

    CASE zfi_017_s01-statu.
      WHEN '02' OR '03' OR '04' OR '05'.
        rt_ex = VALUE #( BASE rt_ex ( 'DELETE' ) ( 'EDIT' ) ( 'DELETE' ) ( 'SAVE' ) ).
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.