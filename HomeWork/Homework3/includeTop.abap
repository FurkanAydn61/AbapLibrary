*&---------------------------------------------------------------------*
*& Include          ZABAP_EGT_REALV_EXP_TOP
*&---------------------------------------------------------------------*
TYPES: BEGIN OF gty_list,
         selkz      TYPE char2,            "Box yapmak için"
         icon       TYPE c,                "Trafik lambaları oluşturmak için"
         ogr_no     TYPE zfurkan_de_ogrnno,
         ogr_ad     TYPE zfurkan_de_ograd,
         ogr_syd    TYPE zfurkan_de_ogrsoyad,
         kitap_ad   TYPE zfurkan_de_kitapad,
         yazar_ad   TYPE zfurkan_de_yazarad,
         yazar_syd  TYPE zfurkan_de_yazarsoyad,
         atarih     TYPE zfurkan_de_atarih,
         vtarih     TYPE zfurkan_de_vtarih,
         puan       TYPE zfurkan_de_puan,
         line_color TYPE char4,
         cell_color TYPE slis_t_specialcol_alv,
       END OF gty_list.


DATA:gs_cell_color TYPE slis_specialcol_alv. "Hücresel renklendirme yapmak için"

DATA: gt_list TYPE TABLE OF gty_list, "Oluşturduğumuz TYPES ' ı internal table ve structure yapısına bağladık"
      gs_list TYPE gty_list.

DATA: gt_fieldcatalog TYPE slis_t_fieldcat_alv,  "Fielcatalog özelliğini açtık"
      gs_fieldcatalog TYPE slis_fieldcat_alv.

DATA: gs_layout TYPE  slis_layout_alv.    "Layout özelliğini açtık"

DATA: gt_events TYPE slis_t_event,    "Events özelliğini açtık"
      gs_event  TYPE slis_alv_event.

DATA: gt_sort TYPE slis_t_sortinfo_alv, "Sort özelliği yani sıralama için kullandık"
      gs_sort TYPE slis_sortinfo_alv.

DATA: gt_filter TYPE SLIS_T_FILTER_ALV,  "Filtreleme özelliği için kullandık"
      gs_filter TYPE slis_filter_alv.

DATA: gt_exclude TYPE  SLIS_T_EXTAB,
      gs_exclude TYPE slis_extab.