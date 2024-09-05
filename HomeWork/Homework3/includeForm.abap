*&---------------------------------------------------------------------*
*& Include          ZABAP_EGT_REALV_EXP_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
  SELECT
  zfurkan_t_lib_o~ogr_no
  zfurkan_t_lib_o~ogr_ad
  zfurkan_t_lib_o~ogr_syd
  zfurkan_t_lib_b~kitap_ad
  zfurkan_t_lib_y~yazar_ad
  zfurkan_t_lib_y~yazar_syd
  zfurkan_t_lib_i~atarih
  zfurkan_t_lib_i~vtarih
  zfurkan_t_lib_o~puan
  FROM zfurkan_t_lib_o INNER JOIN zfurkan_t_lib_i
  ON zfurkan_t_lib_o~ogr_no EQ zfurkan_t_lib_i~ogr_no
  INNER JOIN zfurkan_t_lib_b
  ON zfurkan_t_lib_i~kitap_no EQ zfurkan_t_lib_b~kitap_no
  INNER JOIN  zfurkan_t_lib_y
  ON zfurkan_t_lib_b~yazar_no EQ zfurkan_t_lib_y~yazar_no
  INTO CORRESPONDING FIELDS OF TABLE gt_list.

*************TRAFİK LAMBASI ICON OLUŞTURDUK********************
  LOOP AT gt_list INTO gs_list.
    IF gs_list-puan < 50.
      gs_list-icon = 1.
    ELSEIF gs_list-puan > 50 AND gs_list-puan <= 70.
      gs_list-icon = 2.
    ELSEIF gs_list-puan > 70 AND gs_list-puan <= 100.
      gs_list-icon = 3.
    ENDIF.
    MODIFY gt_list FROM gs_list TRANSPORTING icon.
    CLEAR:gs_list.
  ENDLOOP.

***********LINE COLOR RENKLENDİRMESİ YAPTIK***********
  LOOP AT gt_list INTO gs_list.
    DATA(lv_days_diff) = gs_list-vtarih - sy-datum."Gün farkını hesapladık"
    IF lv_days_diff < 0.
      gs_list-line_color = 'C600'.
      MODIFY gt_list FROM gs_list.
    ELSEIF lv_days_diff EQ 0.
      gs_list-line_color = 'C300'.
      MODIFY gt_list FROM gs_list.
    ELSEIF lv_days_diff <= 3.
      gs_list-line_color = 'C410'.
      MODIFY gt_list FROM gs_list.
    ELSE.
      gs_list-line_color = 'C510'.
      MODIFY gt_list FROM gs_list.
    ENDIF.


  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fc .

  PERFORM: set_fc_sub USING 'OGR_NO' 'OGR NO' 'Öğrenci No' 'Öğrenci Numarası' 'X' 'X',
           set_fc_sub USING 'OGR_AD' 'OGR AD' 'Öğr Adı' 'Öğrenci ADI' '' '',
           set_fc_sub USING 'OGR_SYD' 'OGR SYD' 'OGR_SOYAD' 'Öğrenci SOYADI' '' '',
           set_fc_sub USING 'KITAP_AD' 'KİTAP AD' 'KİTAP AD' 'KİTAP ADI' '' 'X',
           set_fc_sub USING 'YAZAR_AD' 'YAZAR AD' 'YAZAR AD' 'YAZAR ADI' '' '',
           set_fc_sub USING 'YAZAR_SYD' 'YAZAR SYD' 'YAZAR SOYADI' 'YAZAR SOYADI' '' '',
           set_fc_sub USING 'ATARIH' 'ALIŞ TRH' 'ALIŞ TARİHİ' 'ALIŞ TARİHİ' '' '',
           set_fc_sub USING 'VTARIH' 'VERİŞ TRH' 'VERİŞ TARİHİ' 'VERİŞ TARİHİ' '' '',
           set_fc_sub USING 'PUAN' 'PUAN' 'PUAN' 'PUAN' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout .
  gs_layout-window_titlebar = 'KÜTÜPHANE OTOMASYONU'. "ALV 'mize başlık koyduk"
  gs_layout-zebra = abap_true.                        "Bir beyaz bir siyah deseni oluşturan zebra deseni verdik satırlara"
  gs_layout-colwidth_optimize = abap_true.            "Kolonları verilerinin uzunluğuna göre optimize ettik"
  gs_layout-info_fieldname = 'LINE_COLOR'.            "Line color için gerekli"
  gs_layout-lights_fieldname = 'ICON'.                "Icon için gerekli"
  gs_layout-box_fieldname = 'SELKZ'.                   "Box için gerekli"

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv .

********ALV 'mizin üstünde boşluk bırakıp içini doldurmak için
  gs_event-name = slis_ev_top_of_page.
  gs_event-form = 'TOP_OF_PAGE'.
  APPEND gs_event TO gt_events.

********ALV'mizin altında boşluk bırakıp doldurmak için
  gs_event-name = slis_ev_end_of_list.
  gs_event-form = 'END_OF_LIST'.
  APPEND gs_event TO gt_events.

  gs_event-name = slis_ev_pf_status_set.
  gs_event-form = 'PF_STATUS_SET'.
  APPEND gs_event TO gt_events.

  gs_sort-spos = 1.
  gs_sort-tabname = 'GT_LIST'.
  gs_sort-fieldname = 'OGR_NO'.
  gs_sort-up = abap_true.
  APPEND gs_sort TO gt_sort.


***********Filtreleme İşlemleri İçin kullandık
*  gs_filter-tabname = 'GT_LIST'.
*  gs_filter-fieldname = 'KITAP_AD'.
*  gs_filter-sign0 = 'I'.
*  gs_filter-optio = 'EQ'.
*  gs_filter-valuf_int = 'KÜRK MANTOLU MADONNA'.
*  APPEND gs_filter TO gt_filter.

*********Toolbardaki istemediğimiz butonları kaldırmak için kullandık**
*  gs_exclude-fcode = '&UMC'.
*  APPEND gs_exclude TO gt_exclude.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK       = ' '
*     I_BYPASSING_BUFFER      = ' '
*     I_BUFFER_ACTIVE         = ' '
      i_callback_program      = sy-repid
*     I_CALLBACK_PF_STATUS_SET = ''
      i_callback_user_command = 'USER_COMMAND'
*     I_CALLBACK_TOP_OF_PAGE  = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME        =
*     I_BACKGROUND_ID         = ' '
*     I_GRID_TITLE            =
*     I_GRID_SETTINGS         =
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcatalog
      it_excluding            = gt_exclude
*     IT_SPECIAL_GROUPS       =
      it_sort                 = gt_sort
*     it_filter               = gt_filter
*     IS_SEL_HIDE             =
*     I_DEFAULT               = 'X'
*     I_SAVE                  = ' '
*     IS_VARIANT              =
      it_events               = gt_events
*     IT_EVENT_EXIT           =
*     IS_PRINT                =
*     IS_REPREP_ID            =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
*     I_HTML_HEIGHT_TOP       = 0
*     I_HTML_HEIGHT_END       = 0
*     IT_ALV_GRAPHICS         =
*     IT_HYPERLINK            =
*     IT_ADD_FIELDCAT         =
*     IT_EXCEPT_QINFO         =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      t_outtab                = gt_list
*   EXCEPTIONS
*     PROGRAM_ERROR           = 1
*     OTHERS                  = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FC_SUB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fc_sub USING p_fieldname
                      p_seltext_s
                      p_seltext_m
                      p_seltext_l
                      p_key
                      p_hotspot.
  CLEAR: gs_fieldcatalog.
  gs_fieldcatalog-fieldname = p_fieldname.
  gs_fieldcatalog-seltext_s = p_seltext_s.
  gs_fieldcatalog-seltext_m = p_seltext_m.
  gs_fieldcatalog-seltext_l = p_seltext_l.
  gs_fieldcatalog-key = p_key.
  gs_fieldcatalog-hotspot = p_hotspot.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form P_STATUS_SET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM top_of_page .
  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader.
  DATA: lv_date TYPE char10.
  DATA: lv_lines   TYPE i,
        lv_lines_c TYPE char4.

  CLEAR: ls_header.
  ls_header-typ = 'H'. "Başlık için kullanılır"
  ls_header-info = 'Kütüphane Otomasyon Raporu'.
  APPEND ls_header TO lt_header.

  CLEAR: ls_header.
  ls_header-typ = 'S'.
  ls_header-key = 'Tarihi :'.
  CONCATENATE sy-datum+6(2)
              '.'
              sy-datum+4(2)
              '.'
              sy-datum+0(4)
              INTO lv_date.
  ls_header-info = lv_date.
  APPEND ls_header TO lt_header.

  CLEAR: ls_header.
  DESCRIBE TABLE gt_list LINES lv_lines.
  lv_lines_c = lv_lines.
  ls_header-typ = 'A'.
  CONCATENATE 'Raporda'
               lv_lines_c
               'adet veri vardır'
               INTO ls_header-info
               SEPARATED BY space.
  APPEND ls_header TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form END_OF_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM end_of_list .
  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE  slis_listheader.

  CLEAR: ls_header.
  ls_header-typ = 'H'.
  ls_header-info = 'Hazırlayan Furkan Aydın'.
  APPEND ls_header TO lt_header.

  CLEAR: ls_header.
  ls_header-typ = 'A'.
  ls_header-info = 'Deneme amaçlı yapılmaktadır'.
  APPEND ls_header TO lt_header.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PF_STATUS_SET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM pf_status_set USING p_extab TYPE slis_t_extab.
  SET PF-STATUS '0200'.
*se41 den kopyaladık
ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command USING p_ucomm TYPE sy-ucomm
                        ps_selfield TYPE slis_selfield.
  DATA: lv_mess TYPE char200,
        lv_ind  TYPE numc2.
  CASE p_ucomm.
    WHEN '&IC1'.
      CASE ps_selfield-fieldname.
        WHEN 'OGR_NO'.
          CONCATENATE ps_selfield-value
                      'numaralı öğrenci seçilmiştir.'
                       INTO lv_mess
                       SEPARATED BY space.
          MESSAGE lv_mess TYPE 'I'.
        WHEN 'KITAP_AD'.
          CONCATENATE ps_selfield-value
                      'adlı kitap seçilmiştir.'
                      INTO lv_mess
                      SEPARATED BY space.
          MESSAGE lv_mess TYPE 'I'.
      ENDCASE.
    WHEN '&MSG'.
      LOOP AT gt_list INTO gs_list WHERE selkz EQ 'X'.
        lv_ind = lv_ind + 1.
      ENDLOOP.
      CONCATENATE lv_ind
                  'tane satır seçilmiştir.'
                  INTO lv_mess
                  SEPARATED BY space.
      MESSAGE lv_mess TYPE 'I'.
  ENDCASE.
ENDFORM.