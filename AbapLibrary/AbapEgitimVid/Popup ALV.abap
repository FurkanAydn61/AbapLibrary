REPORT zfkn_popup_alv.


DATA: lt_demo_table TYPE TABLE OF scarr.


DATA: p_title TYPE string VALUE 'Demo Scarr Table',
      p_popup TYPE xfeld VALUE 'X'.

SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE lt_demo_table
WHERE carrname NOT LIKE 'Air%'.


*Scarr tablosundan dönen değerlerin işlenerek sonuç tablosunun oluşturulacağı yapı
TYPES: BEGIN OF ty_result,
         traffic_light(4),
         carrid           TYPE s_carr_id,
         carrname         TYPE  s_carrname,
         currcode         TYPE s_currcode,
         url              TYPE  s_carrurl,

       END OF ty_result.

DATA: ls_result TYPE ty_result,
      lt_result TYPE TABLE OF ty_result.

IF sy-subrc IS INITIAL.
  FIELD-SYMBOLS: <wa_scarr_t> TYPE scarr.

*Scarr tablosundan para birimi kolonundan USD,EURO ve diğerleri şeklinde sınıflandırarak traffic lights iconları yerleştirecek

  LOOP AT lt_demo_table ASSIGNING <wa_scarr_t>.
    IF <wa_scarr_t>-currcode EQ 'USD'.
      ls_result-traffic_light = '@0A@'.
    ELSEIF <wa_scarr_t>-currcode EQ 'EUR'.
      ls_result-traffic_light = '@08@'.
    ELSE.
      ls_result-traffic_light = '@09@'.
    ENDIF.

    ls_result-carrid = <wa_scarr_t>-carrid.
    ls_result-carrname = <wa_scarr_t>-carrname.
    ls_result-currcode = <wa_scarr_t>-currcode.
    ls_result-url = <wa_scarr_t>-url.

    APPEND ls_result TO lt_result.

  ENDLOOP.

  PERFORM alv_display TABLES lt_result USING p_title p_popup.


ENDIF.
*&---------------------------------------------------------------------*
*& Form ALV_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_RESULT
*&      --> P_TITLE
*&      --> P_POPUP
*&---------------------------------------------------------------------*
FORM alv_display TABLES lt_result USING p_title p_popup.
  DATA: go_alv TYPE REF TO cl_salv_table.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table   = go_alv                          " Basis Class Simple ALV Tables
        CHANGING
          t_table        = lt_result[]
      ).

    CATCH cx_salv_msg.
  ENDTRY.


  DATA: lr_functions TYPE REF TO cl_salv_functions_list.

  lr_functions = go_alv->get_functions( ).
  lr_functions->set_all( 'X' ).

  IF go_alv IS BOUND.
    IF p_popup = 'X'.
      go_alv->set_screen_popup(
        EXPORTING
          start_column = 25
          end_column   = 100
          start_line   = 6
          end_line     = 10
      ).
    ENDIF.

    go_alv->display( ).

  ENDIF.
ENDFORM.