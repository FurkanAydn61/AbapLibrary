*&---------------------------------------------------------------------*
*& Report ZABAP_TUTORIAL_007
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_tutorial_007.

PARAMETERS: p_d1 TYPE zfurkan_de_ograd,
            p_d2 TYPE kunnr. "Kunnr tipinde bir parametre alırken f4 search help açılır"

TYPES: BEGIN OF ty_first_name,
         first_name TYPE zfurkan_de_ograd,
       END OF ty_first_name.

DATA: it_first_name TYPE TABLE OF ty_first_name,
      ls_first_name TYPE ty_first_name.


"Search Help kulakçığı üretme

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_d1.
  MESSAGE 'Selam kullanıcı p_d1 kullanıldı' TYPE 'I'.

  SELECT ogr_ad FROM zfurkan_t_lib_o INTO  TABLE it_first_name UP TO 6 ROWS.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      retfield     = 'OGR_AD'
*     PVALKEY      = ' '
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
      dynprofield  = 'OGR_AD'
*     STEPL        = 0
*      window_title = 'Hoşgeldiniz'
      VALUE        = ' '
      value_org    = 'S'
*     MULTIPLE_CHOICE        = ' '
*     DISPLAY      = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     CALLBACK_METHOD        =
*     MARK_TAB     =
*     IMPORTING
*     USER_RESET   =
    TABLES
      value_tab    = it_first_name
*     FIELD_TAB    =
*     RETURN_TAB   =
*     DYNPFLD_MAPPING        =
*     EXCEPTIONS
*     PARAMETER_ERROR        = 1
*     NO_VALUES_FOUND        = 2
*     OTHERS       = 3
    .
  IF sy-subrc EQ 0.
    WRITE : / 'İşlem başarıyla  gerçekleşti'.
  ENDIF.