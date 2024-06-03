REPORT ZABAP_FA_001.

INCLUDE zabap_fa_001_top.
INCLUDE zabap_fa_001_frm.

START-OF-SELECTION.

IF rb_1 IS NOT INITIAL.
    PERFORM call_method_static.
ELSEIF rb_2 IS NOT INITIAL.
    PERFORM call_method_instance.
ENDIF.

IF gv_check IS NOT INITIAL.
    MESSAGE 'Girdiğiniz kullanıcı bulunamadı.' TYPE 'I' DISPLAY LIKE 'E'.
    ELSE.
      PERFORM show_info.
ENDIF.


*& Include          ZABAP_FA_001_TOP
*&---------------------------------------------------------------------*

PARAMETERS: p_uname TYPE uname.

SELECTION-SCREEN SKIP 1.

PARAMETERS : rb_1 TYPE xfeld RADIOBUTTON GROUP rbg,
             rb_2 TYPE xfeld RADIOBUTTON GROUP rbg.

DATA: gs_address TYPE bapiaddr3,
      gt_return TYPE bapiret2_tt,
      gs_return LIKE LINE OF gt_return,
      gv_check.


*& Include          ZABAP_FA_001_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CALL_METHOD_STATIC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_method_static .
  CALL METHOD zcl_fu_01=>kullanici_bilgilerini_getir
    EXPORTING
      iv_uname             = p_uname                " Kullanıcı adı
    IMPORTING
      ev_address           = gs_address                " Adresler için BAPI referans yapı (İlgili kişi)
      et_return            = gt_return                " Return error table type parameter
    EXCEPTIONS
      kullanici_bulunamadi = 1                " Kullanıcı bulunmadı
      OTHERS               = 2.
  IF sy-subrc EQ 1 OR sy-subrc EQ 2.
    gv_check = ' '.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_METHOD_INSTANCE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_method_instance .
* Instance Method tanımlarken bir değişken tanımlayıp o classa referans vermemiz gerekiyor.
  DATA: go_kullanici TYPE REF TO zcl_fu_01.

  CREATE OBJECT go_kullanici.

  CALL METHOD go_kullanici->kullanici_bilgilerini_getir_2
    EXPORTING
      iv_uname = p_uname                 " Kullanıcı adı
    IMPORTING
     ev_address           = gs_address                 " Adresler için BAPI referans yapı (İlgili kişi)
     et_return            = gt_return                 " Return error table type parameter
    EXCEPTIONS
     kullanici_bulunamadi = 1                " Kullanıcı bulunmadı
     others   = 2
    .
  IF sy-subrc EQ 1 OR sy-subrc EQ 2.
    gv_check = ' '.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SHOW_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_info .
WRITE : 'AD :' , gs_address-firstname.

NEW-LINE.

WRITE : 'SOYAD :' ,  gs_address-lastname.

NEW-LINE.

WRITE: 'E-MAIL :' , gs_address-e_mail.


ENDFORM.