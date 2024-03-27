*&---------------------------------------------------------------------*
*& Report ZABAP_EGT_SEKIL_CL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egt_sekil_cl.

INCLUDE zabap_egt_sekil_cl_top.
INCLUDE zabap_egt_sekil_cl_ss.
INCLUDE zabap_egt_sekil_cl_ats.

START-OF-SELECTION.


  CASE 'X'.
    WHEN p_cbox1.
      IF p_rad1 EQ abap_true.
        go_kno->sekil_alan(
          EXPORTING
            iv_kenar  =    p_num1             " Doğal sayı
*        iv_ukenar =                  " Doğal sayı
*        iv_yuksek =                  " Doğal sayı
            iv_cho    =    'K'              " Şekiller için Data Element
          IMPORTING
            iv_alan   =    gv_alan              " Number Type int4
*      EXCEPTIONS
*        cv_eq     = 1                " Uzun kenar kısa kenara eşit ya da kısa olamaz
*        others    = 2
        ).
        IF sy-subrc EQ 0.
          gv_text = 'Alanı :' && gv_alan.
        ENDIF.
      ELSEIF p_rad2 EQ abap_true.
        go_kno->sekil_cevre(
          EXPORTING
            iv_kenar  =   p_num1               " Doğal sayı
*          iv_ukenar =                  " Doğal sayı
*          iv_yuksek =                  " Doğal sayı
            iv_cho    =   'K'               " Şekiller için Data Element
          IMPORTING
            ev_result =    gv_cevre              " Number Type int4
*        EXCEPTIONS
*          cv_eq     = 1                " Kısa kenar uzun kenardan uzun olamaz.
*          others    = 2
        ).
        IF sy-subrc EQ 0.
          gv_text = 'Karenin Çevresi : ' && gv_cevre.
        ENDIF.
      ENDIF.
    WHEN p_cbox2.
      IF p_rad1 EQ abap_true.
        go_kno->sekil_alan(
          EXPORTING
            iv_kenar  =  p_num1                " Doğal sayı
            iv_ukenar =  p_num2                " Doğal sayı
*          iv_yuksek =                  " Doğal sayı
            iv_cho    =  'D'                " Şekiller için Data Element
          IMPORTING
            iv_alan   =  gv_alan                " Number Type int4
          EXCEPTIONS
            cv_eq     = 1                " Uzun kenar kısa kenara eşit ya da kısa olamaz
            OTHERS    = 2
        ).
        IF sy-subrc EQ 0.
          gv_text = 'Dikdörtgen Alanı : ' && gv_alan.
        ELSEIF sy-subrc EQ 1.
          MESSAGE text-004 TYPE 'I' DISPLAY LIKE 'E'.
          gv_text = 'Tekrar Deneyiniz !'.
        ENDIF.
      ELSEIF p_rad2 EQ abap_true.
        go_kno->sekil_cevre(
          EXPORTING
            iv_kenar  =  p_num1                " Doğal sayı
            iv_ukenar =  p_num2                " Doğal sayı
*            iv_yuksek =                  " Doğal sayı
            iv_cho    =  'D'                " Şekiller için Data Element
          IMPORTING
            ev_result =  gv_cevre                " Number Type int4
          EXCEPTIONS
            cv_eq     = 1                " Kısa kenar uzun kenardan uzun olamaz.
            OTHERS    = 2
        ).
        IF sy-subrc EQ 0.
          gv_text = 'Dikdörtgenin Çevresi : ' && gv_cevre.
        ELSEIF sy-subrc EQ 1.
          MESSAGE text-005 TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.

    WHEN p_cbox3.
      IF p_rad1 EQ abap_true.
        go_kno->sekil_alan(
          EXPORTING
            iv_kenar  =  p_num1                " Doğal sayı
*            iv_ukenar =                  " Doğal sayı
            iv_yuksek =  p_num3                " Doğal sayı
            iv_cho    =  'U'                " Şekiller için Data Element
          IMPORTING
            iv_alan   =  gv_alan               " Number Type int4
*          EXCEPTIONS
*            cv_eq     = 1                " Uzun kenar kısa kenara eşit ya da kısa olamaz
*            others    = 2
        ).
        IF sy-subrc EQ 0.
          gv_text = 'Üçgenin alanı : ' && gv_alan.
        ENDIF.
        ELSEIF p_rad2 EQ abap_true.
          go_kno->sekil_cevre(
            EXPORTING
              iv_kenar  =  p_num1                " Doğal sayı
              iv_ukenar =  p_num2                " Doğal sayı
              iv_yuksek =  p_num3                " Doğal sayı
              iv_cho    =  'U'                " Şekiller için Data Element
            IMPORTING
              ev_result =   gv_cevre               " Number Type int4
            EXCEPTIONS
              cv_eq     = 1                " Kısa kenar uzun kenardan uzun olamaz.
              OTHERS    = 2
          ).
          IF sy-subrc EQ 0.
            gv_text = 'Üçgenin Çevresi : ' && gv_cevre.
                    ELSEIF sy-subrc EQ 1.
          MESSAGE text-005 TYPE 'I' DISPLAY LIKE 'E'.
          gv_text = 'Tekrar Deneyiniz !!'
          ENDIF.

        ENDIF.
  ENDCASE.


  WRITE: gv_text.