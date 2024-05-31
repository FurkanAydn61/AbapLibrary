*&---------------------------------------------------------------------*
*& Report ZABAP_TUTORIAL_002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_tutorial_002.
DATA: ls_scarr TYPE scarr.
PARAMETERS: p_carr TYPE scarr-carrid.

START-OF-SELECTION.

SET PF-STATUS 'STANDARD'.

SELECT SINGLE * FROM scarr INTO ls_scarr WHERE carrid = p_carr.

  IF sy-subrc EQ 0.
    CALL FUNCTION 'ENQUEUE_EZ_FLIGHT'
     EXPORTING
       MODE_SCARR           = 'E'
       MANDT                = sy-mandt
       CARRID               = p_carr
     EXCEPTIONS
       FOREIGN_LOCK         = 1
       SYSTEM_FAILURE       = 2
       OTHERS               = 3
              .
    IF sy-subrc <> 0.
     MESSAGE 'Diğer kullanıcı programı şu anda kaydı düzenliyor' TYPE 'E'.
    ENDIF.
    WRITE: / ls_scarr-carrid, ls_scarr-carrname, ls_scarr-currcode, ls_scarr-url.

  ENDIF.

  AT USER-COMMAND.
*Bu yapıyı yapmamız şart değil zaten ilk kullanıcı programdan çıktıktan sonra kuyruktaki programı açabilecek.
    CASE sy-ucomm.
      WHEN 'OPEN'.
        CALL FUNCTION 'DEQUEUE_EZ_FLIGHT'
         EXPORTING
           MODE_SCARR       = 'E'
           MANDT            = SY-MANDT
           CARRID           = p_carr
                  .

      WHEN '&F03'.
        LEAVE PROGRAM.
      WHEN OTHERS.
    ENDCASE.