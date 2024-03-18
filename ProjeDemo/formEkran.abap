*&---------------------------------------------------------------------*
*& Include          ZABAP_EGITIM_DEMO_PROJECTFRM
*&---------------------------------------------------------------------*
FORM inserttablepers USING p_id
                           p_adi
                           p_syd
                           p_cns.
  INSERT INTO  zabap_egt_pers_t VALUES gs_pers.
  MESSAGE 'Tabloya ekleme işleminiz başarıyla gerçekleşti' TYPE 'I' DISPLAY LIKE 'S'.
ENDFORM.

FORM inserttablesal USING p_id
                          p_sal.
  INSERT INTO zabap_egt_perm_t VALUES gs_maas.
  MESSAGE 'Tabloya ekleme işleminiz başarıyla gerçekleşti' TYPE 'I' DISPLAY LIKE 'S'.
ENDFORM.

FORM deltablepers USING p_id
                        p_adi.
  DELETE FROM zabap_egt_pers_t WHERE pers_id = p_id.
  MESSAGE 'Tablodan silme işleminiz başarıyla gerçekleşti' TYPE 'I' DISPLAY LIKE 'S'.
ENDFORM.

FORM deltablesal USING p_id
                       p_sal.
  DELETE FROM zabap_egt_perm_t WHERE pers_id = p_id.
  MESSAGE 'Tablodan delete işleminiz başarıyla gerçekleşti.' TYPE 'I' DISPLAY LIKE 'S'.
ENDFORM.

FORM updtablepers USING p_id
                        p_adi
                        p_syd.
  UPDATE zabap_egt_pers_t SET pers_ad = p_adi
  WHERE pers_id = p_id.
  MESSAGE 'Tabloya yaptığnız güncelleme başarıyla gerçekleşti.' TYPE 'I' DISPLAY LIKE 'S'.

ENDFORM.

FORM updtablesal USING p_id
                       p_sal.
  UPDATE zabap_egt_perm_t SET pers_sal = p_sal
  WHERE pers_id = p_id.
  MESSAGE 'Tabloya yaptığınız güncelleme başarıyla gerçekleşti.' TYPE 'I' DISPLAY LIKE 'S'.

ENDFORM.