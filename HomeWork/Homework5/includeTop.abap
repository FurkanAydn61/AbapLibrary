TYPES:gty_list TYPE zfkn_ogr_s.
DATA: gt_list TYPE TABLE OF gty_list,
      gs_list TYPE gty_list.

DATA: gt_ogr  TYPE TABLE OF zfkn_student,
      gt_less TYPE TABLE OF zfkn_lessons,
      gs_ogr  TYPE zfkn_student,
      gs_less TYPE zfkn_lessons.

DATA: gt_fcat   TYPE  lvc_t_fcat,
      gs_fcat   TYPE lvc_s_fcat,
      gs_layout TYPE  lvc_s_layo.

DATA: gt_events TYPE  slis_t_event,
      gs_events TYPE slis_alv_event.

DATA:go_grid TYPE REF TO cl_gui_alv_grid.

DATA: gs_stbl TYPE lvc_s_stbl.
DATA: gs_variant TYPE  disvariant,
      gv_exit    TYPE xfeld.

DATA: gt_sort TYPE  lvc_t_sort,
      gs_sort TYPE  LVC_S_SORT.

      class   lcl_user_command DEFINITION DEFERRED.
DATA: go_command TYPE REF TO lcl_user_command.

CLASS     lcl_event DEFINITION DEFERRED.
DATA: go_events TYPE REF TO lcl_event.

CLASS lcl_alv_operations DEFINITION  DEFERRED.
DATA: go_alv_operations TYPE REF TO lcl_alv_operations.