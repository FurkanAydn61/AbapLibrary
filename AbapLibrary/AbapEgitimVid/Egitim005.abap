REPORT zabap_egitim_005.

PARAMETERS: p_num TYPE int4.
*            p_ad TYPE zfurkan_persad_de.


INITIALIZATION."Ekrana girilen user input parametrelerinden önce çalışmasını isteyeceğimiz alan"
  p_num = 14.
*  p_ad = 'Adınızı Giriniz'.


AT SELECTION-SCREEN.
*  IF p_num EQ 15.
    p_num = p_num + 1.
*
*  ELSEIF p_num > 15.
*
*    p_num = p_num + 2."Enter a bastığı zaman birer birer artıracak"
*  ELSE .
*  p_num = p_num * p_num.
*  ENDIF.

START-OF-SELECTION.

WRITE: p_num.

END-OF-SELECTION.
*
*  WRITE: 'END OF SELECTION ÇALIŞTI'.


************************************FORM KULLANIMI**********************************************
*DATA: gv_num1 TYPE int4,
*      gv_num3 TYPE int4,
*      gv_num4 TYPE int4.
*
*INITIALIZATION.
*
*AT SELECTION-SCREEN.
*
*START-OF-SELECTION.
*  PERFORM sayi_arttir.
*  PERFORM sayi_arttir.
*  PERFORM sayi_arttir.
*  PERFORM sayi_arttir.
*  WRITE gv_num1.
*  PERFORM iki_sayinin_carpimi USING 10
*                                    5.
*  gv_num3 = 15.
*  gv_num4 = 9.
*  PERFORM iki_sayinin_farki USING gv_num3
*                                  gv_num4.
*
*END-OF-SELECTION.
*FORM sayi_arttir.
*  gv_num1 = gv_num1 + 1.
*
*ENDFORM.
*FORM iki_sayinin_carpimi USING p_num1
*                               p_num2.
*  DATA: lv_sonuc TYPE int4.
*  lv_sonuc = p_num1 * p_num2.
*  WRITE: 'Sonuç:',lv_sonuc.
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form IKI_SAYININ_FARKI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_NUM3
*&      --> GV_NUM4
*&---------------------------------------------------------------------*
FORM iki_sayinin_farki  USING    p_num3
                                 p_num4.
  DATA: lv_sonuc TYPE int4.
  lv_sonuc = p_num3 - p_num4.
  WRITE: 'Farkı:',lv_sonuc.

ENDFORM.
******************************GLOBAL&LOCAL KULLANIMI*************************
*START-OF-SELECTION.
*
*DATA: gv_num1 TYPE int4.
*
*PERFORM form1.
*PERFORM form2.
*
*
*FORM form1 .
*  gv_num1 = gv_num1 + 1.
**  DATA: lv_num2 TYPE int4.
**  lv_num2 = lv_num2 + 1.
*ENDFORM.
*
*FORM form2 .
*gv_num1 = gv_num1 + 1.
**lv_num2 = lv_num2 + 1. --> lv_num2 değişkeni local olduğu için çalışmaz.
*ENDFORM.
********************************INCLUDE KULLANIMI*****************************
*INCLUDE ZABAP_EGITIM_005_TOP.
*INCLUDE ZABAP_EGITIM_005_frm.
*START-OF-SELECTION.
*
*
*PERFORM form1.
*PERFORM form2.