REPORT zfkn_pop_up.



*DATA: lv_ans(1).
*CALL FUNCTION 'POPUP_TO_CONFIRM'
*  EXPORTING
*    titlebar              = 'İşlem gerçekleştirliyor'
**   DIAGNOSE_OBJECT       = ' '
*    text_question         = 'Emin Misiniz?'
*    text_button_1         = 'Evet'(001)
*    icon_button_1         = 'ICON_CHECKED'
*    text_button_2         = 'Hayır'(002)
*    icon_button_2         = 'ICON_CANCEL '
*    default_button        = '1'
*    display_cancel_button = 'X'
**   USERDEFINED_F1_HELP   = ' '
**   START_COLUMN          = 25
**   START_ROW             = 6
*    popup_type            = 'ICON_MESSAGE_ERROR'
**   IV_QUICKINFO_BUTTON_1 = ' '
**   IV_QUICKINFO_BUTTON_2 = ' '
*  IMPORTING
*    answer                = lv_ans
**    TABLES
**   PARAMETER             =
**                 EXCEPTIONS
**   TEXT_NOT_FOUND        = 1
**   OTHERS                = 2
*  .
*IF lv_ans EQ '1'.
*  WRITE 'Eminmiş'.
*ELSEIF lv_ans EQ '2'.
*  WRITE 'Joker hakkını kullanmak istiyor.'.
*ENDIF.

*INCLUDE <icon>.

DATA: lt_fields     TYPE STANDARD TABLE OF sval,
      ls_fields     TYPE sval,
      lv_ret TYPE string.

CLEAR ls_fields.
ls_fields-tabname = 'MARA'.
ls_fields-fieldname = 'MATNR'.

APPEND ls_fields TO lt_fields.

CLEAR ls_fields.
ls_fields-tabname = 'MARA'.
ls_fields-fieldname = 'MTART'.
APPEND ls_fields TO lt_fields.

CLEAR lv_ret.

CALL FUNCTION 'POPUP_GET_VALUES'
  EXPORTING
    popup_title          = 'Bilgileri Giriniz'
   START_COLUMN          = '5'
   START_ROW             = '5'
 IMPORTING
   RETURNCODE            = lv_ret
  tables
    fields                = lt_fields
 EXCEPTIONS
   ERROR_IN_FIELDS       = 1
   OTHERS                = 2
          .
IF lv_ret IS INITIAL.
  READ TABLE lt_fields WITH KEY tabname = 'MARA' fieldname = 'MATNR' TRANSPORTING NO FIELDS.
  WRITE ls_fields-value.
ENDIF.
