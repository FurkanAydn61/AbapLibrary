REPORT zabap_fa_02.

INCLUDE zabap_fa_02_top.
INCLUDE zabap_fa_02_frm.

INITIALIZATION.

START-OF-SELECTION.

  PERFORM append_it_final.
  IF it_final IS NOT INITIAL.
     PERFORM build_field_catalog.
     PERFORM build_layout.
     PERFORM display_alv_report.
  ENDIF.

TYPES : BEGIN OF str_mara,
          matnr LIKE mara-matnr,
          ersda LIKE mara-ersda,
          ernam LIKE mara-ernam,
          laeda LIKE mara-laeda,
          mtart LIKE mara-mtart,
          matkl LIKE mara-matkl,
          meins LIKE mara-meins,
          lfgja LIKE mard-lfgja,
        END OF str_mara.
DATA : wa_mara TYPE str_mara,
       it_mara TYPE TABLE OF str_mara.

TYPES : BEGIN OF it_ty_final,
          matnr LIKE mara-matnr,
          ersda LIKE mara-ersda,
          ernam LIKE mara-ernam,
          laeda LIKE mara-laeda,
          mtart LIKE mara-mtart,
          matkl LIKE mara-matkl,
          meins LIKE mara-meins,
          lgort LIKE mard-lgort,
          werks LIKE mard-werks,
          lfgja LIKE mard-lfgja,
        END OF it_ty_final.

DATA : it_final TYPE TABLE OF it_ty_final.
DATA: wa_final  TYPE it_ty_final.


DATA: gt_fieldcatalog TYPE slis_t_fieldcat_alv,
      gs_fieldcatalog TYPE slis_fieldcat_alv,
      gd_tab_group    TYPE slis_t_sp_group_alv,
      gd_layout       TYPE slis_layout_alv.

PARAMETERS : plant TYPE mard-werks,
             stor  LIKE mard-lgort.


*& Include          ZABAP_FA_02_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form APPEND_IT_FINAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM append_it_final .
  SELECT mara~matnr
    INTO CORRESPONDING FIELDS OF TABLE it_mara
    FROM mara INNER JOIN makt ON ( mara~matnr = makt~matnr )
              INNER JOIN mard ON ( makt~matnr = mard~matnr )
    WHERE mard~lgort = stor AND mard~werks = plant.

  LOOP AT it_mara INTO wa_mara.
    wa_final-matnr = wa_mara-matnr.
    wa_final-ersda = wa_mara-ersda.
    wa_final-ernam = wa_mara-ernam.
    wa_final-laeda = wa_mara-laeda.
    wa_final-mtart = wa_mara-mtart.
    wa_final-matkl = wa_mara-matkl.
    wa_final-lfgja = wa_mara-lfgja.
    wa_final-lgort = stor.
    wa_final-werks = plant.
    APPEND wa_final TO it_final.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUILD_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_field_catalog .

  CLEAR gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'MATNR'.
  gs_fieldcatalog-seltext_m = 'Malzeme No'.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.

  CLEAR gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'ERSDA'.
  gs_fieldcatalog-seltext_m = 'Oluşturma Tarihi'.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.

  CLEAR gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'ERNAM'.
  gs_fieldcatalog-seltext_m = 'Oluşturan kişi'.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.

  CLEAR gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'LAEDA'.
  gs_fieldcatalog-seltext_m = 'Son Değişiklik'.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.


  CLEAR gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'MTART'.
  gs_fieldcatalog-seltext_m = 'Malzeme Türü'.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.

  CLEAR gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'MATKL'.
  gs_fieldcatalog-seltext_m = 'Mal Grubu'.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.

  CLEAR gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'LFGJA'.
  gs_fieldcatalog-seltext_m = 'Yıl'.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.

  CLEAR gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'LGORT'.
  gs_fieldcatalog-seltext_m = 'Depo Yeri'.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.

  CLEAR gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'WERKS'.
  gs_fieldcatalog-seltext_m = 'Üretim Yeri'.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUILD_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_layout .
  gd_layout-zebra = abap_true.
  gd_layout-no_input = abap_true.
  gd_layout-colwidth_optimize = abap_true.
  gd_layout-totals_text = 'Totals'(201).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_REPORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv_report .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = gd_layout
      it_fieldcat              = gt_fieldcatalog
      i_save                   = 'X'
    TABLES
      t_outtab                 = it_final
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
 SET PF-STATUS 'STANDARD'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.
IF sy-ucomm = 'BACK'.
    LEAVE PROGRAM.
ELSEIF sy-ucomm = 'CANCEL'.
  LEAVE PROGRAM.
ENDIF.
ENDMODULE.

