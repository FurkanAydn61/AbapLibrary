*&---------------------------------------------------------------------*
*& Report ZFKN_POPUP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfkn_popup.

DATA: lt_fields TYPE TABLE OF sval,
      ls_fields TYPE sval,
      lv_ret    TYPE string.

CLEAR: ls_fields.
ls_fields-tabname = 'SCARR'.
ls_fields-fieldname = 'CARRID'.
APPEND ls_fields TO lt_fields.

CLEAR: ls_fields.
ls_fields-tabname = 'SCARR'.
ls_fields-fieldname = 'CARRNAME'.
APPEND ls_fields TO lt_fields.

CLEAR: lv_ret.

CALL FUNCTION 'POPUP_GET_VALUES'
  EXPORTING
    popup_title     = 'Bilgileri Giriniz'
  importing
    returncode      = lv_ret
  tables
    fields          = lt_fields
  exceptions
    error_in_fields = 1
    others          = 2.
IF lv_ret IS INITIAL.
   READ TABLE lt_fields WITH KEY tabname = 'SCARR' fieldname = 'CARRNAME' INTO ls_fields.
   WRITE: ls_fields-value.
ENDIF.