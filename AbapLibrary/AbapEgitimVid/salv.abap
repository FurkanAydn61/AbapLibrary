REPORT zfkn_salv.

DATA: go_alv          TYPE REF TO cl_salv_table,
      go_message      TYPE REF TO cx_salv_msg,
      columns         TYPE REF TO cl_salv_columns_table,
      column          TYPE REF TO cl_salv_column,
      layout_settings TYPE REF TO cl_salv_layout,
      layout_key      TYPE salv_s_layout_key,
      not_found       TYPE REF TO cx_salv_not_found,
      functions       TYPE REF TO cl_salv_functions_list.

SELECT * FROM mara INTO TABLE @DATA(gt_itab) UP TO 50 ROWS.

TRY.
    cl_salv_table=>factory(
      IMPORTING
        r_salv_table   =   go_alv                        " Basis Class Simple ALV Tables
      CHANGING
        t_table        =   gt_itab
    ).
    columns = go_alv->get_columns( ).

    layout_settings = go_alv->get_layout( ).

    layout_key-report = sy-repid.
    layout_settings->set_key( layout_key ).

    layout_settings->set_save_restriction(
       if_salv_c_layout=>restrict_none
    ).
    columns->set_optimize( ).
    functions = go_alv->get_functions( ).
    functions->set_all( ).

    TRY.
        column = columns->get_column('MANDT').
        column->set_visible(  if_salv_c_bool_sap=>true ).
      CATCH cx_salv_not_found INTO not_found.

    ENDTRY.
    functions = go_alv->get_functions( ).
    functions->set_all( ).

    CATCH cx_salv_msg INTO go_message.

  ENDTRY.

  GO_ALV->display( ).