REPORT ZABAP_EGITIM_013.
*INITIALIZATION.
*DATA: gv_degs1 TYPE i.


START-OF-SELECTION.

CALL SCREEN 0100."Oluşturduğumuz screeni ekrana getirmek için kullandığımız komut"


*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT. "PBO, Screen ekrana gelmeden önce çalışacak kısımdır. Ekran tasarımlarıyla alakalı bazı parametreleri düzenleyebiliriz"
SET PF-STATUS 'STATUS_0100'. "GUI STATUS: Menü bar , tool bar gibi kısımlardaki yapıları aktif edip kullanmamızı sağlayan yapıdır"
SET TITLEBAR 'TITLE_0100 '."GUI TITLE: Başlık diye düşünebiliriz."
ENDMODULE.


MODULE user_command_0100 INPUT."PAI, Screen ekrana geldikten sonra butona bastığımız zaman tetiklenecek kısımdır.Butona tıklandığında da ne işlevselliğinin olmasını kodladık"
DATA: lv_text TYPE char200.

CONCATENATE sy-ucomm"İkiden fazla string ifadeyi birleştirip tek bir yapıda tutmamıza yarayan yapıdır"
            'butonuna basılmıştır'
            INTO lv_text
            SEPARATED BY space."Birleştiridğimiz screen ifadelerin arasına bir boşluk koyar"
MESSAGE lv_text TYPE  'I'.
CASE sy-ucomm."Anlık olarak ekrana vermiş olduğum butonun fuction kodunu tutar "
  WHEN 'BACK'.
    LEAVE TO SCREEN 0.
  WHEN 'EXIT'.
    SET SCREEN 0.
  WHEN 'CANCEL'.
    SET SCREEN 0.
ENDCASE.

ENDMODULE.