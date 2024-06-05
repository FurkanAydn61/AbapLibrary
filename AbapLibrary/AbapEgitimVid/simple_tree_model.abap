*&---------------------------------------------------------------------*
*& Report ZABAP_FA_007
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_fa_007.

CLASS cl_gui_cfw DEFINITION LOAD.

DATA: g_custom_container TYPE REF TO cl_gui_custom_container,
      g_tree             TYPE REF TO cl_simple_tree_model,
      g_ok_code          TYPE sy-ucomm.

DATA: item_table TYPE treemlitab,
      item       TYPE treemlitab.

DATA: ok_code_chart TYPE sy-ucomm, first_call TYPE i,
      values        TYPE TABLE OF gprval WITH HEADER LINE,
      column_texts  TYPE TABLE OF gprtxt WITH HEADER LINE.

DATA: event  TYPE cntl_simple_event,
      events TYPE cntl_simple_events.



CALL SCREEN 0100.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STANDARD'.

  IF g_tree IS INITIAL.
    CREATE OBJECT g_tree
      EXPORTING
        node_selection_mode         = cl_simple_tree_model=>node_sel_mode_single                 " Nodes: Single or Multiple Selection
      EXCEPTIONS
        illegal_node_selection_mode = 1.                " "
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name              = 'TREE_CONTAINER'                 " Name of the Screen CustCtrl Name to Link Container To
      EXCEPTIONS
        cntl_error                  = 1                " CNTL_ERROR
        cntl_system_error           = 2                " CNTL_SYSTEM_ERROR
        create_error                = 3                " CREATE_ERROR
        lifetime_error              = 4                " LIFETIME_ERROR
        lifetime_dynpro_dynpro_link = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
        OTHERS                      = 6.

    CALL METHOD g_tree->create_tree_control
      EXPORTING
        parent                       = g_custom_container                 " "
      EXCEPTIONS
        lifetime_error               = 1                " "
        cntl_system_error            = 2                " "
        create_error                 = 3                " "
        failed                       = 4                " "
        tree_control_already_created = 5.                " Tree Control Has Already Been Created

    event-eventid = cl_simple_tree_model=>eventid_node_double_click.
    event-appl_event = abap_true.
    APPEND event TO events.

    CALL METHOD g_tree->set_registered_events
      EXPORTING
        events                    = events                " Event Table
      EXCEPTIONS
        illegal_event_combination = 1                " ILLEGAL_EVENT_COMBINATION
        unknown_event             = 2.                " "
    PERFORM add_nodes.

    CALL METHOD g_tree->expand_node
      EXPORTING
        node_key       = 'F-WERKS'                 " Node Key
      EXCEPTIONS
        node_not_found = 1.                " Node does not exist

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE g_ok_code.
    WHEN 'BACK'.
      SET SCREEN 0.
    WHEN 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form ADD_NODES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_nodes .
  CALL METHOD g_tree->add_node
    EXPORTING
      node_key = 'F-WERKS'                 " Node key
      isfolder = abap_true                 " 'X': Node is Folder; ' ': Node is Leaf
      text     = 'Üretim Yerleri'                 " Node text
    EXCEPTIONS
      OTHERS   = 5.

  SELECT * FROM zdemo_table INTO TABLE @DATA(lt_werks).

  SORT lt_werks BY werks.

  DELETE ADJACENT DUPLICATES FROM lt_werks COMPARING werks.

  DATA: lv_werks_key TYPE tm_nodekey,
        lv_werks_txt TYPE tm_nodetxt.
  DATA: lv_matnr_key TYPE tm_nodekey,
        lv_matnr_txt TYPE tm_nodetxt.


  LOOP AT  lt_werks ASSIGNING FIELD-SYMBOL(<fs_werks>).
    CLEAR: lv_werks_key, lv_werks_txt.
    lv_werks_key = 'F-' && <fs_werks>-werks.
    lv_werks_txt = <fs_werks>-werks.

    CALL METHOD g_tree->add_node
      EXPORTING
        node_key          = lv_werks_key                 " Node key
        relative_node_key = 'F-WERKS'                 " Key of Related Node
        relationship      = cl_simple_tree_model=>relat_last_child                " Relationship
        isfolder          = abap_true                 " 'X': Node is Folder; ' ': Node is Leaf
        text              = lv_werks_txt                 " Node text
      EXCEPTIONS
        OTHERS            = 5.

    SELECT * FROM zdemo_table INTO TABLE @DATA(lt_matnr) WHERE werks EQ @<fs_werks>-werks.
    LOOP AT lt_matnr ASSIGNING FIELD-SYMBOL(<fs_matnr>).
      CLEAR : lv_matnr_key, lv_matnr_txt.

      lv_matnr_key = <fs_matnr>-matnr.
      lv_matnr_txt = <fs_matnr>-matnr.

      CALL METHOD g_tree->add_node
        EXPORTING
          node_key          = lv_matnr_key
          relative_node_key = lv_werks_key
          relationship      = cl_simple_tree_model=>relat_last_child
          isfolder          = abap_false
          text              = lv_matnr_txt
        EXCEPTIONS
          OTHERS            = 1.
    ENDLOOP.
  ENDLOOP.
ENDFORM.