
REPORT zfkn_block_alv.

INCLUDE zfkn_block_alv_top.
INCLUDE zfkn_block_alv_cls.
INCLUDE zfkn_block_alv_frm.


INITIALIZATION.
  v_repid = sy-repid.
  v_user  = sy-uname.
  v_date  = sy-datum.

  DATA: obj1 TYPE REF TO lcl_cls1.

  CREATE OBJECT obj1.

START-OF-SELECTION.


  CALL METHOD: obj1->m_ekko,
              obj1->m_ekpo,
              obj1->m_fcat,
              obj1->m_layout,
              obj1->m_event1,
              obj1->m_event2,
              obj1->m_disp.

TOP-OF-PAGE.
  PERFORM top1.
  PERFORM top2.


*************************************

TYPE-POOLS: slis.

TABLES: ekko,ekpo.

DATA: v_repid TYPE sy-repid,
      v_user  TYPE  sy-uname,
      v_date  TYPE char12.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_ebeln FOR ekko-ebeln OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

**************************************

CLASS lcl_cls1 DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_ekko,
             ebeln TYPE ekko-ebeln,
             bukrs TYPE ekko-bukrs,
             lifnr TYPE ekko-lifnr,
             sel   TYPE char1,
           END OF ty_ekko.

    TYPES: BEGIN OF ty_ekpo,
             ebeln TYPE ekpo-ebeln,
             ebelp TYPE ekpo-ebelp,
             matnr TYPE ekpo-matnr,
             werks TYPE ekpo-werks,
             lgort TYPE ekpo-lgort,
             menge TYPE ekpo-menge,
             meins TYPE ekpo-meins,
             sel   TYPE char1,
           END OF ty_ekpo.


    DATA: wa_ekko TYPE ty_ekko,
          it_ekko TYPE STANDARD TABLE OF ty_ekko,
          wa_ekpo TYPE ty_ekpo,
          it_ekpo TYPE STANDARD TABLE OF ty_ekpo.


    DATA: wa_layout TYPE  slis_layout_alv,
          it_fcat1  TYPE  slis_t_fieldcat_alv,
          it_fcat2  TYPE  slis_t_fieldcat_alv,
          it_event1 TYPE  slis_t_event,
          wa_event1 TYPE slis_alv_event,
          it_event2 TYPE  slis_t_event,
          wa_event2 TYPE slis_alv_event.

    DATA: it_print TYPE  slis_print_alv.
    DATA:wa_fcat1 TYPE slis_fieldcat_alv,
         wa_fcat2 TYPE slis_fieldcat_alv.

    METHODS: m_ekko, m_ekpo, m_fcat, m_layout,
      m_event1, m_event2, m_disp.


ENDCLASS.

CLASS lcl_cls1 IMPLEMENTATION.
  METHOD m_ekko.
    SELECT ebeln bukrs lifnr
      FROM ekko INTO TABLE it_ekko WHERE ebeln IN s_ebeln.

    IF sy-subrc EQ 0.
      SORT it_ekko BY ebeln.
    ELSE.
      MESSAGE 'Purchase Order Doesnt exist' TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDMETHOD.

  METHOD m_ekpo.
    IF it_ekko IS NOT INITIAL.
      SELECT
        ebeln
        ebelp
        matnr
        werks
        lgort
        menge
        meins
        FROM ekpo INTO TABLE it_ekpo
        FOR ALL ENTRIES IN it_ekko
        WHERE ebeln = it_ekko-ebeln.
    ENDIF.
  ENDMETHOD.

  METHOD m_fcat.

    CLEAR wa_fcat1.
    REFRESH it_fcat1.

    DATA: lv_col TYPE i VALUE 1.

    wa_fcat1-col_pos = lv_col.
    wa_fcat1-fieldname = 'EBELN'.
    wa_fcat1-tabname = 'IT_EKKO'.
    wa_fcat1-seltext_l = 'Purchase Order'.
    APPEND wa_fcat1 TO it_fcat1.
    CLEAR  wa_fcat1.

    lv_col = 1 + lv_col.
    wa_fcat1-col_pos = lv_col.
    wa_fcat1-fieldname = 'BUKRS'.
    wa_fcat1-tabname = 'IT_EKKO'.
    wa_fcat1-seltext_l = 'Company Code'.
    APPEND wa_fcat1 TO it_fcat1.
    CLEAR  wa_fcat1.

    lv_col = 1 + lv_col.
    wa_fcat1-col_pos = lv_col.
    wa_fcat1-fieldname = 'LIFNR'.
    wa_fcat1-tabname = 'IT_EKKO'.
    wa_fcat1-seltext_l = 'Vendor'.
    APPEND wa_fcat1 TO it_fcat1.
    CLEAR  wa_fcat1.

    CLEAR wa_fcat2.
    REFRESH it_fcat2.

    lv_col = 1.
    wa_fcat2-col_pos = lv_col.
    wa_fcat2-fieldname = 'EBELN'.
    wa_fcat2-tabname = 'IT_EKPO'.
    wa_fcat2-seltext_l = 'Purchase Order'.
    APPEND wa_fcat2 TO it_fcat2.
    CLEAR  wa_fcat2.

    lv_col = 1 + lv_col.
    wa_fcat2-col_pos = lv_col.
    wa_fcat2-fieldname = 'EBELP'.
    wa_fcat2-tabname = 'IT_EKPO'.
    wa_fcat2-seltext_l = 'Item'.
    APPEND wa_fcat2 TO it_fcat2.
    CLEAR  wa_fcat2.

    lv_col = 1 + lv_col.
    wa_fcat2-col_pos = lv_col.
    wa_fcat2-fieldname = 'MATNR'.
    wa_fcat2-tabname = 'IT_EKPO'.
    wa_fcat2-seltext_l = 'Material'.
    APPEND wa_fcat2 TO it_fcat2.
    CLEAR  wa_fcat2.

    lv_col = 1 + lv_col.
    wa_fcat2-col_pos = lv_col.
    wa_fcat2-fieldname = 'WERKS'.
    wa_fcat2-tabname = 'IT_EKPO'.
    wa_fcat2-seltext_l = 'Plant'.
    APPEND wa_fcat2 TO it_fcat2.
    CLEAR  wa_fcat2.

    lv_col = 1 + lv_col.
    wa_fcat2-col_pos = lv_col.
    wa_fcat2-fieldname = 'LGORT'.
    wa_fcat2-tabname = 'IT_EKPO'.
    wa_fcat2-seltext_l = 'Storage Location'.
    APPEND wa_fcat2 TO it_fcat2.
    CLEAR  wa_fcat2.

    lv_col = 1 + lv_col.
    wa_fcat2-col_pos = lv_col.
    wa_fcat2-fieldname = 'MENGE'.
    wa_fcat2-tabname = 'IT_EKPO'.
    wa_fcat2-seltext_l = 'Quantity'.
    APPEND wa_fcat2 TO it_fcat2.
    CLEAR  wa_fcat2.

    lv_col = 1 + lv_col.
    wa_fcat2-col_pos = lv_col.
    wa_fcat2-fieldname = 'MEINS'.
    wa_fcat2-tabname = 'IT_EKPO'.
    wa_fcat2-seltext_l = 'Unit'.
    APPEND wa_fcat2 TO it_fcat2.
    CLEAR  wa_fcat2.
  ENDMETHOD.

  METHOD m_layout.
    wa_layout-zebra = abap_true.
    wa_layout-colwidth_optimize = abap_true.
    wa_layout-box_fieldname = 'SEL'.
  ENDMETHOD.

  METHOD m_event1.
    CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
* EXPORTING
*   I_LIST_TYPE           = 0
      IMPORTING
        et_events       = it_event1
      EXCEPTIONS
        list_type_wrong = 1
        OTHERS          = 2.

    IF sy-subrc = 0.
      CLEAR wa_event1.
      READ TABLE it_event1 INTO wa_event1
      WITH KEY name = 'TOP_OF_PAGE'.
      IF sy-subrc = 0.
        wa_event1-form = 'TOP1'.
        MODIFY it_event1 FROM wa_event1
        INDEX sy-tabix TRANSPORTING form.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD m_event2.
    CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
*   EXPORTING
*     I_LIST_TYPE           = 0
      IMPORTING
        et_events       = it_event2
      EXCEPTIONS
        list_type_wrong = 1
        OTHERS          = 2.

    IF sy-subrc = 0.
      CLEAR wa_event2.
      READ TABLE it_event2 INTO wa_event2
      WITH KEY name = 'TOP_OF_PAGE'.
      IF sy-subrc = 0.
        wa_event2-form = 'TOP2'.
        MODIFY it_event2 FROM wa_event2
        INDEX sy-tabix TRANSPORTING form.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD m_disp.
    CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_INIT'
      EXPORTING
        i_callback_program = v_repid.

    CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
      EXPORTING
        is_layout                  = wa_layout
        it_fieldcat                = it_fcat1
        i_tabname                  = 'IT_EKKO'
        it_events                  = it_event1
*       IT_SORT                    =
*       I_TEXT                     = ' '
      TABLES
        t_outtab                   = it_ekko
      EXCEPTIONS
        program_error              = 1
        maximum_of_appends_reached = 2
        OTHERS                     = 3.

    CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
      EXPORTING
        is_layout                  = wa_layout
        it_fieldcat                = it_fcat2
        i_tabname                  = 'IT_EKPO'
        it_events                  = it_event2
*       IT_SORT                    =
*       I_TEXT                     = ' '
      TABLES
        t_outtab                   = it_ekpo
      EXCEPTIONS
        program_error              = 1
        maximum_of_appends_reached = 2
        OTHERS                     = 3.

    it_print-reserve_lines = 2.
    CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_DISPLAY'
      EXPORTING
*       I_INTERFACE_CHECK             = ' '
        is_print = it_print
*       I_SCREEN_START_COLUMN         = 0
*       I_SCREEN_START_LINE           = 0
*       I_SCREEN_END_COLUMN           = 0
*       I_SCREEN_END_LINE             = 0
*       IMPORTING
*       E_EXIT_CAUSED_BY_CALLER       =
*       ES_EXIT_CAUSED_BY_USER        =
*       EXCEPTIONS
*       PROGRAM_ERROR                 = 1
*       OTHERS   = 2
      .
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDMETHOD.
ENDCLASS.

******************************************

FORM top1 .
  DATA: d_heading TYPE slis_t_listheader.

  d_heading = VALUE #( ( typ = 'H' info = 'PURCHASE ORDER HEADER' )
                       ( typ = 'S' info = |Kullanıcı Adı: { sy-uname } | )
                       ( typ = 'S' info = |Tarih / Saat : { sy-datum DATE = USER } / { sy-uzeit TIME = USER }| ) ).

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = d_heading.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOP2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM top2 .
  DATA: d_heading2 TYPE slis_t_listheader.

  d_heading2 = VALUE #( ( typ = 'H' info = 'PURCHASE ORDER ITEM DOCUMENT' ) ).

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = d_heading2.
ENDFORM.