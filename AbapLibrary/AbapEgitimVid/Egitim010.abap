*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_010 MESSAGE-ID zabap.

START-OF-SELECTION.

*MESSAGE 'Hello ABAP World' TYPE 'S'. "Success mesajı  verir"
*MESSAGE 'Hello ABAP World' TYPE 'I'. " Pop up şeklinde bilgi verebildiğimiz mesajımız."
*MESSAGE 'Hello ABAP World' TYPE 'W'."Programın akışını kesen mesajlar. Düzeltilebilir hata gibi yerlerde kullanılır."
*MESSAGE 'Hello ABAP World' TYPE 'E'."Düzenlenmek zorunda olan hatalar için kullanılır"
*MESSAGE 'Hello ABAP World' TYPE 'A'."Pop up şeklinde gelir programı durdurur.Ve çıkış butonuna basıldığı zaman ana ekrana geri gönderir."
*MESSAGE 'Hello ABAP World' TYPE 'X'. "Dump ekranı verir"

*MESSAGE 'Hello ABAP World' TYPE 'S' DISPLAY LIKE 'X'."Çalışma mantığından çok yanındaki ikonu değiştirebilirz"
*MESSAGE 'Hello ABAP World' TYPE 'I' DISPLAY LIKE 'E'.
*MESSAGE 'Hello ABAP World' TYPE 'W'.
*MESSAGE 'Hello ABAP World' TYPE 'E'.
*MESSAGE 'Hello ABAP World' TYPE 'A'.
*MESSAGE 'Hello ABAP World' TYPE 'X'.


*MESSAGE text-000 TYPE 'I'.
*MESSAGE text-001 TYPE 'I' DISPLAY LIKE 'E'.

*MESSAGE i000(zabap). "Message Class oluşturduk ve mesajlarımızı buradan çektik".

*MESSAGE i001 WITH 'Perşembe'."SE91 den message class a ulaştık ortak dinamik vermek istediğimiz kelimenin yerine '&' işareti koyarak yazdırdık"
MESSAGE i002 WITH 'Pazartesi' 'Cuma'."Birden fazla parametreli message kullanımı"
WRITE: 'Message Eğitim Videosu'.