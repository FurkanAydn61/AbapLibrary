*&---------------------------------------------------------------------*
REPORT zfkn_snro.

CLASS lcl_number_range DEFINITION.
  PUBLIC SECTION.
    METHODS: get_next_customer_number IMPORTING iv_object TYPE inri-object
                                        iv_range_nr TYPE inri-nrrangenr
                                      RETURNING VALUE(rv_formatted_number) TYPE string.
ENDCLASS.

CLASS lcl_number_range IMPLEMENTATION.
  METHOD get_next_customer_number.
    DATA: lv_next_number(50),
          lv_padded_number TYPE n LENGTH 7,
          lv_formatted_number TYPE string.

    " Number Range'den yeni numara al
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = iv_range_nr
        object      = iv_object
      IMPORTING
        number      = lv_next_number.

    lv_padded_number = lv_next_number.

    " 'CUS' ile birleştir ve formatı oluştur
    CONCATENATE 'CUS' lv_padded_number INTO lv_formatted_number.

    " Formatlı numarayı döndür
    rv_formatted_number = lv_formatted_number.
  ENDMETHOD.
ENDCLASS.