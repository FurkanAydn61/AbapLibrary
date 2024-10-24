*&---------------------------------------------------------------------*
*&  Include           ZMM_R111_C01
*&---------------------------------------------------------------------*


CLASS lcl_main DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      init,

      at_ss_output,
      fill_listbox,

      at_ss,

      start,

      end,

      get_data,

      process_data,

      list_layout_specification
        IMPORTING
          iv_alvname     TYPE string
        RETURNING
          VALUE(rs_layo) TYPE lvc_s_layo,

      set_variant
        IMPORTING
          iv_alvname        TYPE string
        RETURNING
          VALUE(rs_variant) TYPE disvariant,

      create_field_catalog
        EXPORTING
          et_fcat TYPE lvc_t_fcat
        CHANGING
          it_data TYPE STANDARD TABLE,

      modify_fieldcat
        IMPORTING
          iv_alvname TYPE string
        CHANGING
          it_fcat    TYPE lvc_t_fcat,

      fill_sytletab
        IMPORTING
          iv_enabled      TYPE xfeld
          iv_alvname      TYPE string
        RETURNING
          VALUE(rt_style) TYPE lvc_t_styl,

      display_log
        IMPORTING
          it_return TYPE bapiret2_t,

      add_message
        IMPORTING
          iv_msgty  TYPE symsgty
          iv_msg    TYPE bapi_msg OPTIONAL
          iv_msgid  TYPE symsgid  OPTIONAL
          iv_msgno  TYPE symsgno  OPTIONAL
          iv_msgv1  TYPE clike    OPTIONAL
          iv_msgv2  TYPE clike    OPTIONAL
          iv_msgv3  TYPE clike    OPTIONAL
          iv_msgv4  TYPE clike    OPTIONAL
          iv_index  TYPE i        OPTIONAL
        CHANGING
          it_return TYPE bapiret2_t,

      main_save
      .

ENDCLASS.




CLASS lcl_main IMPLEMENTATION.
*&---------------------------------------------------------------------*
*& init
*&---------------------------------------------------------------------*
  METHOD init .
    CLEAR:
      d_ok,
      gt_fieldcat[],
      gt_events[],
      gt_excluding[],
      gs_layout,
      gt_alv[].

*    SELECT 'I' AS sign,
*           'EQ' AS option,
*           werks AS low
*      FROM t001k
*           INNER JOIN t001w ON t001w~bwkey = t001k~bwkey
*      INTO CORRESPONDING FIELDS OF TABLE @s_werks
*     WHERE bukrs EQ 'BM00'
*       AND mlbwa EQ 'X'
*      ORDER BY t001w~werks.



  ENDMETHOD.  " init

*&---------------------------------------------------------------------*
*& at_ss_output
*&---------------------------------------------------------------------*
  METHOD at_ss_output .


    fill_listbox( ).



    LOOP AT SCREEN.
      IF screen-group1 EQ 'DSP'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.  " at_ss_output

  METHOD fill_listbox.
    DATA:
      lv_id     TYPE vrm_id,
      lt_values TYPE vrm_values,
      ls_value  TYPE vrm_value.

    DATA: lt_vers TYPE TABLE OF zmm_t_depo_vers,
          ls_vers TYPE zmm_t_depo_vers.
    DATA: lv_value  TYPE text50.

    lv_id = 'P_VERS'.
    CLEAR: ls_value.
    REFRESH lt_values.
    SELECT DISTINCT zyil
      FROM zmm_t_depo_vers
      INTO CORRESPONDING FIELDS OF TABLE lt_vers.

    SORT lt_vers BY zyil DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_vers COMPARING zyil.

    LOOP AT lt_vers INTO ls_vers.
      ls_value-text = ls_vers-zyil.
      ls_value-key  = ls_vers-zyil.
      CONDENSE ls_value-text NO-GAPS.
      CONDENSE ls_value-key NO-GAPS.
      APPEND ls_value TO lt_values.
    ENDLOOP.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = lv_id
        values          = lt_values
      EXCEPTIONS
        id_illegal_name = 0
        OTHERS          = 0.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& at_ss
*&---------------------------------------------------------------------*
  METHOD at_ss .

  ENDMETHOD.  " at_ss

*&---------------------------------------------------------------------*
*& start
*&---------------------------------------------------------------------*
  METHOD start .
    get_data( ).
    process_data( ).
  ENDMETHOD.  " start

*&---------------------------------------------------------------------*
*& end
*&---------------------------------------------------------------------*
  METHOD end .
    CALL SCREEN 100.
  ENDMETHOD.  " end

*&---------------------------------------------------------------------*
*& get_data
*&---------------------------------------------------------------------*
  METHOD get_data .

    CLEAR gs_t001.
    SELECT SINGLE * FROM t001 INTO gs_t001 WHERE bukrs EQ p_bukrs.

    SELECT *
      FROM zmm_t184
      INTO TABLE gt_maint.

    CLEAR: gt_oto[].
    SELECT
      t185~zyil
      t185~werks
      t185~matnr
      t185~lgort
      t185~stk_sistem
      t185~stk_sayim
      t185~stk_fark
      t185~frkdp
      t185~mblnr
      t185~mjahr
      mara~mtart
      mara~meins
      marc~sobsl
      marc~beskz
      FROM zmm_t185 AS t185
      INNER JOIN mara
      ON mara~matnr EQ t185~matnr
      INNER JOIN marc
      ON marc~matnr = t185~matnr
      AND marc~werks = t185~werks
      INTO CORRESPONDING FIELDS OF TABLE gt_oto
      WHERE t185~zyil  EQ p_vers
      AND   t185~werks EQ p_werks
      AND   t185~matnr IN s_matnr
      AND   t185~frkdp IN s_frkdp.
  ENDMETHOD.  " get_data

*&---------------------------------------------------------------------*
*& process_data
*&---------------------------------------------------------------------*
  METHOD process_data .

*--------------------------------------------------------------------*
    DATA:
      lt_base       TYPE TABLE OF zmm_st108,
      lt_maint_temp LIKE gt_maint,
      ls_maint      LIKE LINE OF lt_maint_temp,
      lt_oto_temp   TYPE TABLE OF ty_oto,
      ls_oto_temp   LIKE LINE OF lt_oto_temp,
      lv_col_pos    TYPE int4,
      lv_fieldname  TYPE fieldname,
      ls_mara       TYPE mara,
      ls_marc       TYPE marc.

    FIELD-SYMBOLS:
       <fv_symdp> TYPE any.

    lcl_main=>create_field_catalog( IMPORTING et_fcat = gt_fieldcat
                                    CHANGING it_data = lt_base ).



    lt_maint_temp[] = gt_maint[].
    SORT lt_maint_temp BY symdp.
    DELETE ADJACENT DUPLICATES FROM lt_maint_temp COMPARING symdp.

    CLEAR lv_col_pos.
    DESCRIBE TABLE gt_fieldcat LINES lv_col_pos.
    LOOP AT lt_maint_temp INTO ls_maint.
      ADD 1 TO lv_col_pos.
      CLEAR gs_fieldcat.
      CONCATENATE 'SYMDP' ls_maint-symdp INTO gs_fieldcat-fieldname SEPARATED BY '_'.

      gs_fieldcat-ref_table = 'ZMM_T185'.
      gs_fieldcat-ref_field = 'STK_FARK'.
      gs_fieldcat-col_pos = lv_col_pos.

      gs_fieldcat-scrtext_s =
      gs_fieldcat-scrtext_m =
      gs_fieldcat-scrtext_l = ls_maint-symdp.

      APPEND gs_fieldcat TO gt_fieldcat.
    ENDLOOP.

    lcl_main=>modify_fieldcat( EXPORTING iv_alvname = gc_alvname-list
                               CHANGING it_fcat = gt_fieldcat  ).


    cl_alv_table_create=>create_dynamic_table(
      EXPORTING
*        i_style_table             =     " Add Style Table
        it_fieldcatalog           =  gt_fieldcat   " Field Catalog
*        i_length_in_byte          =     " Boolean Variable (X=True, Space=False)
      IMPORTING
        ep_table                  = go_data    " Pointer to Dynamic Data Table
*        e_style_fname             =     " ALV Control: Field Name of Internal Table Field
      EXCEPTIONS
        generate_subpool_dir_full = 1
        OTHERS                    = 2
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    ASSIGN go_data->* TO <ft_alv>.
    CHECK sy-subrc EQ 0.

    CREATE DATA go_data_line LIKE LINE OF <ft_alv>.
    ASSIGN go_data_line->* TO <fs_alv>.
    CHECK sy-subrc EQ 0.

*--------------------------------------------------------------------*

    lt_oto_temp[] = gt_oto[].
    SORT lt_oto_temp BY werks matnr frkdp.
    DELETE ADJACENT DUPLICATES FROM lt_oto_temp COMPARING werks matnr frkdp.

    LOOP AT lt_oto_temp INTO ls_oto_temp.
      CLEAR <fs_alv>.
      SELECT SINGLE bklas
                FROM mbew
                INTO ls_oto_temp-bklas
                WHERE matnr EQ ls_oto_temp-matnr AND
                bwkey EQ p_werks.
      MOVE-CORRESPONDING ls_oto_temp TO <fs_alv>.

*      SELECT SINGLE mara~mtart mara~meins marc~sobsl marc~beskz
*            INTO (ls_mara-mtart, ls_mara-meins, ls_marc-sobsl, ls_marc-beskz)
*            FROM mara
*            INNER JOIN marc ON mara~matnr = marc~matnr
*            WHERE mara~matnr EQ ls_oto_temp-matnr
*              AND marc~werks EQ p_werks.

*      MOVE-CORRESPONDING ls_oto_temp TO <fs_alv>.


      LOOP AT gt_oto INTO gs_oto WHERE werks = ls_oto_temp-werks
                                   AND matnr = ls_oto_temp-matnr
                                   AND frkdp = ls_oto_temp-frkdp.
        CONCATENATE 'SYMDP' gs_oto-lgort INTO lv_fieldname SEPARATED BY '_'.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_alv> TO <fv_symdp>.
        CHECK sy-subrc EQ 0.
        <fv_symdp> = gs_oto-stk_fark.
      ENDLOOP.

      APPEND <fs_alv> TO <ft_alv>.
    ENDLOOP.




  ENDMETHOD.  " process_data


*&---------------------------------------------------------------------*
*& list_layout_specification
*&---------------------------------------------------------------------*
  METHOD list_layout_specification .
    CLEAR rs_layo.

    rs_layo-box_fname   = 'SELKZ'.
    rs_layo-cwidth_opt  = 'X'.
    rs_layo-zebra       = 'X'.
*    rs_layo-stylefname  = 'STYLE'.
    rs_layo-sel_mode    = 'A'.

  ENDMETHOD.  " list_layout_specification


*&---------------------------------------------------------------------*
*& set_variant
*&---------------------------------------------------------------------*
  METHOD set_variant .
    CLEAR rs_variant.

    rs_variant-username = sy-uname.
    rs_variant-report   = sy-repid.

    CASE iv_alvname.
      WHEN gc_alvname-list.
        rs_variant-handle   = 'A100'.

*      WHEN OTHERS.

    ENDCASE.

  ENDMETHOD.  " set_variant

*&---------------------------------------------------------------------*
*& create_field_catalog
*&---------------------------------------------------------------------*
  METHOD create_field_catalog .
    DATA:
      lo_columns      TYPE REF TO cl_salv_columns_table,
      lo_aggregations TYPE REF TO cl_salv_aggregations,
      lo_salv_table   TYPE REF TO cl_salv_table,
      lr_table        TYPE REF TO data,
      ls_fcat         TYPE lvc_s_fcat,
      lv_dtext        TYPE scrtext_l.
    FIELD-SYMBOLS:
      <table>         TYPE STANDARD TABLE.


* create unprotected table from import data
    CREATE DATA lr_table LIKE it_data[].
    ASSIGN lr_table->* TO <table>.

*...New ALV Instance ...............................................
    TRY.
        cl_salv_table=>factory(
          EXPORTING
            list_display = abap_false
          IMPORTING
            r_salv_table = lo_salv_table
          CHANGING
            t_table      = <table> ).
      CATCH cx_salv_msg.                                "#EC NO_HANDLER
    ENDTRY.

    lo_columns      = lo_salv_table->get_columns( ).
    lo_aggregations = lo_salv_table->get_aggregations( ).
    et_fcat[]       = cl_salv_controller_metadata=>get_lvc_fieldcatalog(
                            r_columns             = lo_columns
                            r_aggregations        = lo_aggregations ).


    LOOP AT et_fcat INTO ls_fcat.
      CLEAR lv_dtext.

      CASE ls_fcat-fieldname.
        WHEN 'SELKZ'.
          ls_fcat-tech = 'X'.
        WHEN 'ICON'.
          ls_fcat-icon = 'X'.
          lv_dtext = 'Statu'.
        WHEN 'STYLE'.
          ls_fcat-tech = 'X'.
        WHEN 'INFO'.
          ls_fcat-tech = 'X'.
      ENDCASE.

      IF lv_dtext IS NOT INITIAL.
        MOVE lv_dtext TO : ls_fcat-scrtext_l,
                           ls_fcat-scrtext_m,
                           ls_fcat-scrtext_s,
                           ls_fcat-coltext.
      ENDIF.

      MODIFY et_fcat FROM ls_fcat.
    ENDLOOP.


  ENDMETHOD.  " create_field_catalog



*&---------------------------------------------------------------------*
*& modify_fieldcat
*&---------------------------------------------------------------------*
  METHOD modify_fieldcat .
    DATA:
      ls_fcat  TYPE lvc_s_fcat,
      lv_dtext TYPE lvc_s_fcat-scrtext_m.


    LOOP AT it_fcat INTO ls_fcat.

      CLEAR lv_dtext.

      CASE iv_alvname.
        WHEN gc_alvname-list.
          CASE ls_fcat-fieldname.
            WHEN 'WERKS'.
              ls_fcat-key = 'X'.
            WHEN 'MATNR'.
              ls_fcat-key = 'X'.
            WHEN 'FRKDP'.
              ls_fcat-key = 'X'.
          ENDCASE.


      ENDCASE.

      IF lv_dtext IS NOT INITIAL.
        MOVE lv_dtext TO : ls_fcat-scrtext_l,
                           ls_fcat-scrtext_m,
                           ls_fcat-scrtext_s,
                           ls_fcat-coltext.
      ENDIF.

      MODIFY it_fcat FROM ls_fcat.
    ENDLOOP.


  ENDMETHOD.  " modify_fieldcat

*&---------------------------------------------------------------------*
*& fill_sytletab
*&---------------------------------------------------------------------*
  METHOD fill_sytletab .
    DATA: lt_styl  TYPE lvc_t_styl,
          ls_styl  TYPE lvc_s_styl,
          lv_style TYPE lvc_style.

    CLEAR:
      lt_styl,
      lv_style.

    CASE iv_enabled.
      WHEN 'X'.
        lv_style = cl_gui_alv_grid=>mc_style_enabled.
      WHEN ''.
        lv_style = cl_gui_alv_grid=>mc_style_disabled.
    ENDCASE.


    CASE iv_alvname.
      WHEN gc_alvname-list.
*        INSERT VALUE #( fieldname = 'FIELD1' style = lv_style ) INTO TABLE lt_styl.
*        INSERT VALUE #( fieldname = 'FIELD2' style = lv_style ) INTO TABLE lt_styl.


      WHEN OTHERS.
    ENDCASE.


    rt_style = lt_styl.

  ENDMETHOD.  " fill_sytletab

*&---------------------------------------------------------------------*
*& display_log
*&---------------------------------------------------------------------*
  METHOD display_log .
    CHECK it_return[] IS NOT INITIAL.

    CALL FUNCTION 'FINB_BAPIRET2_DISPLAY'
      EXPORTING
        it_message = it_return[].
  ENDMETHOD.  " display_log

*&---------------------------------------------------------------------*
*& add_message
*&---------------------------------------------------------------------*
  METHOD add_message .
    DATA:
      ls_bapiret2 TYPE bapiret2.


    CLEAR
      ls_bapiret2.

    IF iv_msg IS NOT INITIAL.
      MESSAGE ID '00' TYPE 'S' NUMBER '001'
            WITH iv_msg+000(050)
                 iv_msg+050(050)
                 iv_msg+100(050)
                 iv_msg+150(050)
            INTO ls_bapiret2-message.
    ELSEIF iv_msgid IS NOT INITIAL AND
           iv_msgno IS NOT INITIAL.
      MESSAGE ID iv_msgid TYPE 'S' NUMBER iv_msgno
            WITH iv_msgv1 iv_msgv2 iv_msgv3 iv_msgv4 INTO ls_bapiret2-message.
    ELSE.
      RETURN.
    ENDIF.

    ls_bapiret2-type         = iv_msgty.
    ls_bapiret2-id           = sy-msgid.
    ls_bapiret2-number       = sy-msgno.
    ls_bapiret2-message_v1   = sy-msgv1.
    ls_bapiret2-message_v2   = sy-msgv2.
    ls_bapiret2-message_v3   = sy-msgv3.
    ls_bapiret2-message_v4   = sy-msgv4.
    ls_bapiret2-row          = iv_index.
    APPEND ls_bapiret2 TO it_return.

  ENDMETHOD.  " add_message

*&---------------------------------------------------------------------*
*& main_save
*&---------------------------------------------------------------------*
  METHOD main_save .
    DATA:
      lv_valid  TYPE xfeld,
      lt_rows   TYPE lvc_t_row,
      ls_rows   TYPE lvc_s_row,
      ls_stable TYPE lvc_s_stbl VALUE 'XX'.

    go_grid_0100->check_changed_data( IMPORTING e_valid = lv_valid ).
    CHECK lv_valid EQ abap_true.

    go_grid_0100->get_selected_rows( IMPORTING et_index_rows = lt_rows ).
    DELETE lt_rows WHERE rowtype NE space.
    CHECK lt_rows[] IS NOT INITIAL.

    CLEAR:
      gt_messtab[].

    LOOP AT lt_rows INTO ls_rows.
      READ TABLE gt_alv INTO gs_alv INDEX ls_rows-index.

      "---


      MODIFY gt_alv FROM gs_alv INDEX ls_rows-index.
    ENDLOOP.

    go_grid_0100->refresh_table_display( EXPORTING i_soft_refresh = 'X'
                                                   is_stable      = ls_stable ).

    lcl_main=>display_log( gt_messtab ).
  ENDMETHOD.  " main_save

ENDCLASS.