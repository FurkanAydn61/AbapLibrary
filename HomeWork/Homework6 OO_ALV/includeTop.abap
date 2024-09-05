*&---------------------------------------------------------------------*
*& Include          ZABAP_FA_TUTORIAL_008_TOP
*&---------------------------------------------------------------------*
TABLES sscrfields.
DATA: it_vrm TYPE vrm_values,
      wa_vrm TYPE vrm_value.

DATA: wa_bseg TYPE bseg.

DATA: gt_cus_detail     TYPE TABLE OF zfkn_cus_detail,
      gs_cus_detail     TYPE zfkn_cus_detail,
      gt_cus_master     TYPE TABLE OF zfkn_cus_master,
      gs_cus_master     TYPE zfkn_cus_master,
      gt_cus_all_detail TYPE TABLE OF zfkn_cus_detail,
      gt_sel_detail     TYPE TABLE OF zfkn_sel_detail,
      gs_sel_detail     TYPE zfkn_sel_detail,
      gt_sel_master     TYPE TABLE OF zfkn_sel_master,
      gs_sel_master     TYPE zfkn_sel_master,
      gt_sel_all_detail TYPE TABLE OF zfkn_sel_detail.




DATA: go_alv  TYPE REF TO cl_gui_alv_grid,
      go_alv2 TYPE REF TO cl_gui_alv_grid.

DATA: go_cust TYPE REF TO cl_gui_custom_container.

DATA: go_splitter TYPE REF TO cl_gui_splitter_container,
      go_gui1     TYPE REF TO cl_gui_container,
      go_gui2     TYPE REF TO cl_gui_container.

DATA: go_docu TYPE REF TO cl_dd_document.

DATA: gt_fcat   TYPE lvc_t_fcat,
      gs_fcat   TYPE lvc_s_fcat,
      gt_fcat2  TYPE lvc_t_fcat,
      gs_fcat2  TYPE lvc_s_fcat,
      gs_layout TYPE lvc_s_layo.





CLASS cl_event_receiver DEFINITION DEFERRED.
DATA: go_event_receiver TYPE REF TO cl_event_receiver.

CLASS lcl_alv_operations DEFINITION DEFERRED.
DATA go_alv_operation TYPE REF TO lcl_alv_operations.

CLASS lcl_events DEFINITION DEFERRED.
DATA: go_events TYPE REF TO lcl_events.