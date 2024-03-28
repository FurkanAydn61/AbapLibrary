*&---------------------------------------------------------------------*
*& Report ZABAP_EGT_SCR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egt_scr.
DATA: ok_code TYPE sy-ucomm.

DATA: gv_ad  TYPE char20,
      gv_syd TYPE char20.

DATA: gv_yas TYPE int4.

DATA: gv_blok TYPE char1,
      gv_no   TYPE int4.

DATA: gv_rad1 TYPE char1,
      gv_rad2 TYPE char1.

DATA: gv_ind TYPE int4.
DATA: gv_date TYPE datum.

DATA: gv_acc TYPE char1.

DATA: gv_idy    TYPE  vrm_id,
      gt_valuey TYPE vrm_values,
      gs_valuey TYPE vrm_value.

DATA: gv_idb    TYPE vrm_id,
      gt_valueb TYPE vrm_values,
      gs_valueb TYPE vrm_value.

DATA: gv_idn TYPE vrm_id,
      gt_valuen TYPE vrm_values,
      gs_valuen TYPE vrm_value.

DATA: gs_log TYPE ZABAP_EGT_SCR_T.


gv_idy = 'GV_YAS'.
gv_idb = 'GV_BLOK'.
gv_idn = 'GV_NO'.
START-OF-SELECTION.



  gv_acc = abap_true.

  gv_ind = 18.
  DO 60 TIMES.
    gs_valuey-key = gv_ind.
    gs_valuey-text = gv_ind.
    APPEND gs_valuey TO gt_valuey.
    gv_ind = gv_ind + 1.
  ENDDO.

  gs_valueb-key = '1'.
  gs_valueb-text = 'A'.
  APPEND gs_valueb TO gt_valueb.

  gs_valueb-key = '2'.
  gs_valueb-text = 'B'.
  APPEND gs_valueb TO gt_valueb.

  gs_valueb-key = '3'.
  gs_valueb-text = 'C'.
  APPEND gs_valueb TO gt_valueb.

    gv_ind = 1.
  DO 21 TIMES.
    gs_valuen-key = gv_ind.
    gs_valuen-text = gv_ind.
    APPEND gs_valuen TO gt_valuen.
    gv_ind = gv_ind + 1.
  ENDDO.

  CALL SCREEN 0100.


*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
* SET TITLEBAR 'xxx'.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = gv_idy
      values = gt_valuey.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = gv_idb
      values = gt_valueb.
   CALL FUNCTION 'VRM_SET_VALUES'
     EXPORTING
       id                    = gv_idn
       values                = gt_valuen
             .






ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN '&BACK'.
      SET SCREEN 0.
    WHEN '&CLEAR'.
      CLEAR:gv_ad,
            gv_syd,
            gv_date,
            gv_yas,
            gv_blok,
            gv_no,
            gv_acc,
            gv_rad2.
      gv_rad1 = abap_true.
    WHEN '&SAVE'.
      gs_log-name = gv_ad.
      gs_log-sname = gv_syd.
      gs_log-dtdate = gv_date.
      gs_log-yasi = gv_yas.
      gs_log-bina_no = gv_blok.
      gs_log-daire_no = gv_no.
      gs_log-conay = gv_acc.

      IF gv_rad1 EQ abap_true.
         gs_log-cins = 'K'.
      ELSE.
        gs_log-cins = 'E'.
      ENDIF.
      INSERT ZABAP_EGT_SCR_T FROM gs_log.
      COMMIT WORK AND WAIT.
      MESSAGE 'Kaydetme İşlemi Gerçekleşti' TYPE 'I'.
  ENDCASE.
ENDMODULE.