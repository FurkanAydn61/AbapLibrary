REPORT zabap_egitim_004.
TABLES:zfurkan_pers_t.
DATA: gv_perssoyad TYPE zfurkan_perssoyad_de.

PARAMETERS: p_num1   TYPE int4,
            p_persad TYPE zfurkan_persad_de,
            p_persyd TYPE zfurkan_perssoyad_de.

SELECT-OPTIONS: s_perssd FOR gv_perssoyad,
                s_perscn FOR zfurkan_pers_t-pers_cins.
*BREAK-POINT.

PARAMETERS: p_cbox1 AS CHECKBOX.
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
PARAMETERS: p_rad1 RADIOBUTTON GROUP gr1,
            p_rad2 RADIOBUTTON GROUP gr1,
            p_rad3 RADIOBUTTON GROUP gr1.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
PARAMETERS: p_rad4 RADIOBUTTON GROUP gr2,
            p_rad5 RADIOBUTTON GROUP gr2.
SELECTION-SCREEN END OF BLOCK bl2.