REPORT zfkn_popup.

DATA: lv_ans(1).

CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
    titlebar              = 'İşlem Gerçekleştiriliyor'
    text_question         = 'Emin Misiniz ?'
    text_button_1         = 'Tamam'
    icon_button_1         = 'ICON_CHECKED'
    text_button_2         = 'İptal'
    icon_button_2         = 'ICON_CANCEL'
    default_button        = '1'
    display_cancel_button = ' '
*   USERDEFINED_F1_HELP   = ' '
*   START_COLUMN          = 25
*   START_ROW             = 6
    popup_type            = 'ICON_MESSAGE_ERROR'
*   IV_QUICKINFO_BUTTON_1 = ' '
*   IV_QUICKINFO_BUTTON_2 = ' '
  IMPORTING
    answer                = lv_ans
* TABLES
*   PARAMETER             =
* EXCEPTIONS
*   TEXT_NOT_FOUND        = 1
*   OTHERS                = 2
  .
IF lv_ans EQ 1.
  WRITE 'Eminmiş'.
ELSEIF lv_ans EQ 2.
  WRITE 'Joker hakkını kullanmak istiyor.'.
ENDIF.
