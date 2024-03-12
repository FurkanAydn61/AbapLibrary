FUNCTION ZABAP_EGITIM_FMODULU.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_NUM1) TYPE  INT4 DEFAULT 10
*"     REFERENCE(IV_NUM2) TYPE  INT4 DEFAULT 2
*"  EXPORTING
*"     REFERENCE(EV_RESULT) TYPE  INT4
*"  CHANGING
*"     REFERENCE(CV_MES) TYPE  CHAR20 OPTIONAL
*"  EXCEPTIONS
*"      DIVIDED_BY_ZERO
*"----------------------------------------------------------------------

  IF iv_num2 < iv_num1 ."Hiçbir parametre girilmediğinde parametrenin default values ına erişmemize yarar. Int değerlerin default values 0 olduğundan kullanırız. String ve char değişkenlerinde kullanılmaz."
     RAISE divided_by_zero.
  ENDIF.

ev_result = iv_num1 / iv_num2.
cv_mes = 'Değiştirilmiş Mesaj'.

*Import: Fonksiyona dışarıdan vereceğimiz parametrelerdir.
*Export: Fonksiyonun bize döneceği parametrelerdir.
*Changing:Fonksiyon inputunda alıcak ve içerisi değiştirilip bize değişmiş yapıyı geri verebilecek kısımlar
*Exceptions:İçeride bir hata alabileceği durumları önceden kodlayabildiğimiz kısım.

*Optional: Seçersek eğer bu parametreyi bu fonksiyona göndermek zorunda değilim.
*Pass by Value:Input parametresinin içeride değiştirilsin veya değiştirilemesin demek.




ENDFUNCTION.