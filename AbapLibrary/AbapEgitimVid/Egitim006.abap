*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_006
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_006.
*Start of selection üstünde tanımlamalar
*Altında formlar, fonksiyonlar yer alır.
PARAMETERS: p_num1  TYPE int4,
            p_num2  TYPE int4.
DATA: gv_sonuc TYPE int4,
      gv_mes TYPE char20.

START-OF-SELECTION.
*  gv_num1 = 20.
*  gv_num2 = 0.
  gv_mes = 'Mesaj 1'.

  CALL FUNCTION 'ZABAP_EGITIM_FMODULU'
    EXPORTING
      iv_num1         = p_num1
      iv_num2         = p_num2
    IMPORTING
      ev_result       = gv_sonuc
    CHANGING
      cv_mes          = gv_mes
    EXCEPTIONS
      divided_by_zero = 1
      OTHERS          = 2.
  IF sy-subrc EQ 0."Sistemde bir hata olmadığında database erişebildiğinde veya fonksiyonda hata olmadığında 0 döner. Eğer subrc 0 değilse bir hata vardır demektir."
    WRITE: / 'Sonuç: ', gv_sonuc.
*    WRITE: / 'Mesaj: ', gv_mes.
  ELSEIF sy-subrc EQ 1.
    WRITE: / 'İkinci sayı birinci sayıdan küçük olamaz'.
  ENDIF.

  END-OF-SELECTION.
  WRITE: / 'Sonuç: ', gv_sonuc.
  WRITE: / 'İkinci sayı birinci sayıdan küçük olamaz'.