*-----------------------------------------------------------------------
* Report: ZAAQB - Z Anton ABAP Query Builder
* Author: Anton Sikidin
*  adapted for SAP Release.............. "620"
*  can contain some bug
*-----------------------------------------------------------------------
*  This program is an easy way to create complex queries
*-----------------------------------------------------------------------


REPORT zaaqb .

TYPE-POOLS: icon.

*--------my---------------------

*/-----------my-types-------------------------
TYPES:
*>>>--join_wizard
  sgname LIKE aqadef-sgname,      " Sachgebiet (mit Prafix)
  tindx  LIKE aqadef-tindx,       " Textindex
  wsid   LIKE aqadef-wsid,        " Arbeitsbereich
*<<<--join_wizard
  BEGIN OF ty_field_desc,
    fieldname TYPE fieldname,        " fieldname
    ddtext    TYPE as4text,          " description
    checkbox,
  END OF ty_field_desc,

  BEGIN OF t_tabname,
    tabname TYPE tabname,
    alias   TYPE tabname,
  END OF t_tabname,

  BEGIN OF t_select,
    but(1)     TYPE  c,
    sselect    TYPE tabname,
    cellstyles TYPE lvc_t_styl,
  END OF t_select,

  BEGIN OF t_join,
    but(1)            TYPE  c,
    ttype             TYPE tabname,
    jjoin             TYPE tabname,
    left              TYPE tabname,
    right             TYPE tabname,
    cellstyles        TYPE lvc_t_styl,
    lv_key_select(30) TYPE c,
  END OF t_join,

  BEGIN OF t_join_condition,
    left(61)          TYPE c,
    right(61)         TYPE c,
    lv_key_select(30) TYPE c,
    lv_key_join(61)   TYPE c,
  END OF t_join_condition,


  BEGIN OF t_where,
    output(1)           TYPE c,
    expression(61)      TYPE c,
    alias(30)           TYPE c,
    aggregate(15)       TYPE c,
    sorttype(10)        TYPE c,
    sortorder           TYPE i,
    "grouping(1) TYPE c,
    criteriafor(12)     TYPE c,
    disable_criteria(1) TYPE c,
    or1(80)             TYPE c,
    or2(80)             TYPE c,
    or3(80)             TYPE c,
    or4(80)             TYPE c,
    lv_key_select(30)   TYPE c,
    selectable(1)       TYPE c,
    title               TYPE lvc_txtcol,
  END OF t_where,

  BEGIN OF t_where_2,
    expression(61) TYPE c,
    alias(30)      TYPE c,
    or1(80)        TYPE c,
    or2(80)        TYPE c,
    or3(80)        TYPE c,
    or4(80)        TYPE c,
  END OF t_where_2,

  BEGIN OF t_where_3,
    or TYPE btctext80,
  END OF t_where_3,
  BEGIN OF t_subquery,
    sselect TYPE tabname,
  END OF t_subquery.

TYPES:
  BEGIN OF t_zaaqb_h                  ,
    clnt    TYPE  mandt,
    bname   TYPE  xubname,
    ddtext  TYPE  as4text,
    version TYPE  tdversion,
    id      TYPE  f_id,
  END OF t_zaaqb_h                    ,

  BEGIN OF t_zaaqb_ddtext             ,
    ddtext TYPE  as4text,
  END OF t_zaaqb_ddtext               ,

  BEGIN OF t_zaaqb_s                  ,
    clnt          TYPE  mandt,
    id            TYPE  f_id,
    line          TYPE  f_id,
    t_type        TYPE  classttype,
    tabname       TYPE  tabname,
    jjoin         TYPE  tabname,
    left1         TYPE  tabname,
    right1        TYPE  tabname,
    lv_key_select TYPE  tabname,
    left_61       TYPE  fdname61,
    right_61      TYPE  fdname61,
    lv_key_join   TYPE  fdname61,
    sortorder     TYPE  anzst,
    criteriafor   TYPE  addifctcod,
    disable       TYPE  classttype,
    or1           TYPE  akb_note,
    or2           TYPE  akb_note,
    or3           TYPE  akb_note,
    or4           TYPE  akb_note,
    selectable    TYPE  classttype,
    title         TYPE  lvc_txtcol,
  END OF   t_zaaqb_s                  .

CLASS cls_event_handler DEFINITION DEFERRED.

*>>>--zcl_zaaqb_query_join_cntrl
CLASS zcl_zaaqb_query_join_cntrl DEFINITION.
  PUBLIC SECTION.
    "-------------------
    DATA: zaaqb_key_word TYPE aqtdban.
*>>>---zaaqb
    DATA p_r_join_cntrl TYPE REF TO if_gui_aqqgraphic .
    DATA p_join_data_r TYPE REF TO cl_query_join_data .
    DATA pt_tfield TYPE aqq_t_tfield .
    DATA lv_key_select(30) TYPE c.
*<<<---zaaqb

    METHODS set_keywords IMPORTING it_key_word TYPE aqtdban .
    METHODS get_keywords EXPORTING it_key_word TYPE aqtdban .
    METHODS remove_keywords IMPORTING it_key_word TYPE aqtdban .

*>>> old class
    TYPE-POOLS icon .

    METHODS check_conditions
      EXPORTING
        !e_tname TYPE aqs_tname
      EXCEPTIONS
        not_right
        zero_tables
        only_one_table .
    TYPE-POOLS aqqis .
    METHODS constructor
      IMPORTING
        !i_r_container_parent TYPE REF TO cl_gui_container
        "!i_r_container_parent type ref to cl_gui_custom_container
        !i_join_data_r        TYPE REF TO cl_query_join_data
        !i_mode               TYPE aqqis_mode .
    METHODS handle_fcode
      IMPORTING
        !i_fcode    TYPE syucomm
        !ir_table   TYPE REF TO if_aqqgraphic_table OPTIONAL
        !ir_link    TYPE REF TO if_aqqgraphic_link OPTIONAL
        !i_rowindex TYPE int2 OPTIONAL .
    METHODS delete_all_table.
    METHODS set_mode
      IMPORTING
        !i_mode TYPE aqqis_mode .
    METHODS synchronize_positions
      EXCEPTIONS
        no_data_on_control .
*>>>---zaaqb
    METHODS add_table
      IMPORTING i_tabname TYPE tabname.
    METHODS get_selected_link
      EXPORTING
        !e_link TYPE aqq_t_objects.
    METHODS remove_tobject .
*<<<---zaaqb

*<<< old class


    "METHODS display_attributes REDEFINITION.

  PRIVATE SECTION.

    TYPE-POOLS aqqis .
    DATA p_mode TYPE aqqis_mode .
    DATA pt_tpos TYPE aqq_t_tpos .
    DATA pt_join TYPE aqq_t_join .
*>>>---zaaqb
*  data p_r_join_cntrl type ref to if_gui_aqqgraphic .
*<<<---zaaqb
    DATA p_t_tobj_join TYPE aqq_t_tobj_join .
    DATA p_t_links_join TYPE aqq_t_links_join .
*>>>---zaaqb
*  data p_join_data_r type ref to cl_query_join_data .
*<<<---zaaqb
    DATA p_default_linkstyle TYPE aqq_style .
    DATA pt_tablepos TYPE aqq_t_tablepos .
    DATA ps_search TYPE aqssearch .
    DATA p_start_tabix TYPE sytabix .
    DATA p_search_obj TYPE REF TO if_aqqgraphic_table .
    DATA p_tab_startx TYPE i VALUE 50 .
    DATA p_tab_starty TYPE i VALUE 50 .
    DATA p_tab_width TYPE i VALUE 250 .
    DATA p_tab_height TYPE i VALUE 200 .

    METHODS abs_2_rel
      IMPORTING
        !is_tablepos TYPE aqstabpos
      EXPORTING
        !es_tpos     TYPE aqq_s_tpos .
    METHODS add_links_to_join .
    METHODS add_tables_to_join .
    METHODS add_tfield
      IMPORTING
        !i_tname TYPE aqs_tname
      EXCEPTIONS
        existing .
    METHODS add_tobject .
    METHODS add_tpos
      IMPORTING
        !i_tname TYPE aqs_tname
      EXCEPTIONS
        existing .
    METHODS aliastable .
    METHODS check .
    METHODS check_remove_tobject
      IMPORTING
        !i_tname TYPE aqs_tname
      EXCEPTIONS
        only_one_table
        table_is_used
        no_remove_in_quickview .
    METHODS cnt_marked_lines_per_tab
      IMPORTING
        !ir_table             TYPE REF TO if_aqqgraphic_table
      RETURNING
        VALUE(e_lines_marked) TYPE i .
    METHODS cnt_marked_tabs
      RETURNING
        VALUE(e_marked_tabs) TYPE i .
    METHODS cnvt_fname_one_2_two
      IMPORTING
        !i_fname TYPE aqs_fname
      EXPORTING
        !e_tname TYPE aqs_tname
        !e_fname TYPE aqs_fname .
    METHODS cnvt_tables_to_new
      IMPORTING
        !i_first_table_apos TYPE flag .
    METHODS cnvt_table_to_old .
    METHODS cnvt_table_to_old_dbjc .
    METHODS cnvt_table_to_old_dbjt .
    METHODS create_link
      IMPORTING
        !ir_tabl TYPE REF TO if_aqqgraphic_table
        !ir_tabr TYPE REF TO if_aqqgraphic_table
        !i_rowl  TYPE sytabix
        !i_rowr  TYPE sytabix .
    METHODS create_links
      IMPORTING
        !it_join TYPE aqq_t_join .
    METHODS display_ddic
      IMPORTING
        !ir_table TYPE REF TO if_aqqgraphic_table .
    METHODS execute_join_modification
      IMPORTING
        !is_join TYPE aqq_s_join
        !ir_link TYPE REF TO if_aqqgraphic_link .
    METHODS fetch_outerflag_text
      IMPORTING
        !ir_tabl      TYPE REF TO if_aqqgraphic_table
        !ir_tabr      TYPE REF TO if_aqqgraphic_table
      RETURNING
        VALUE(r_text) TYPE aqq_text .
    METHODS fielddocu
      IMPORTING
        !ir_table TYPE REF TO if_aqqgraphic_table
        !i_row    TYPE aqq_rownr .
    METHODS fieldreference
      IMPORTING
        !ir_table TYPE REF TO if_aqqgraphic_table
        !i_row    TYPE aqq_rownr .
    METHODS fill_table_fields
      IMPORTING
        !is_dbjt      TYPE aqdbjt
      EXPORTING
        !es_tobj_join TYPE aqstobjjoi .
    METHODS force_jointype
      IMPORTING
        !i_change_old TYPE boolean
      CHANGING
        !cs_join      TYPE aqq_s_join
      EXCEPTIONS
        inconsistent .
    METHODS get_selected_table
      EXPORTING
        !e_tname TYPE aqs_tname
      EXCEPTIONS
        no_table_selected
        several_tables_selected .
    METHODS get_tab
      IMPORTING
        !i_tabname TYPE aqs_tname
      EXPORTING
        !et_tab    TYPE aqqis_t_tab .
    METHODS handle_link_changed
      IMPORTING
        !i_r_link       TYPE REF TO if_aqqgraphic_link
        !i_r_tab_new    TYPE REF TO if_aqqgraphic_table
        !i_row_kept     TYPE aqq_rownr
        !i_row_new      TYPE aqq_rownr
        !i_r_tab_kept   TYPE REF TO if_aqqgraphic_table
        !i_succ_changed TYPE boolean
      RETURNING
        VALUE(r_ok)     TYPE boolean .
    METHODS init
      IMPORTING
        !i_r_container_parent TYPE REF TO cl_gui_container .
    METHODS init_join_cntrl
      IMPORTING
        !i_r_container_parent TYPE REF TO cl_gui_container .
    METHODS is_valid_link
      IMPORTING
        !i_r_succtab TYPE REF TO if_aqqgraphic_table
        !i_r_predtab TYPE REF TO if_aqqgraphic_table
        !i_succrow   TYPE aqq_rownr
        !i_predrow   TYPE aqq_rownr
      EXPORTING
        !e_valid     TYPE boolean
        !e_tname1    TYPE aqs_tname
        !e_tname2    TYPE aqs_tname
        !e_fname1    TYPE aqs_fname
        !e_fname2    TYPE aqs_fname .
    METHODS join_modification
      IMPORTING
        !i_join_typ TYPE aqqis_join_typ
        !ir_link    TYPE REF TO if_aqqgraphic_link .
    METHODS navigator .
    METHODS on_condition .
    METHODS on_handle_ctxmnureq
          FOR EVENT ctxmnurequest OF if_gui_aqqgraphic
      IMPORTING
          !r_table
          !rowindex
          !r_link
          !background
          !r_ctxmnu .
    METHODS on_handle_ctxmnusel
          FOR EVENT ctxmnufcodesel OF if_gui_aqqgraphic
      IMPORTING
          !r_table
          !rowindex
          !r_link
          !background
          !fcode .
    METHODS on_handle_link_created
          FOR EVENT link_created OF if_gui_aqqgraphic
      IMPORTING
          !r_newlink
          !r_succtab
          !succ_row
          !r_predtab
          !pred_row
          !r_doit .
    METHODS on_handle_objdblclick
          FOR EVENT object_double_click OF if_gui_aqqgraphic
      IMPORTING
          !r_link
          !r_table
          !row .
    METHODS on_handle_pred_changed
          FOR EVENT link_pred_changed OF if_gui_aqqgraphic
      IMPORTING
          !r_link
          !r_predtab
          !predrow
          !r_doit .
    METHODS on_handle_succ_changed
          FOR EVENT link_succ_changed OF if_gui_aqqgraphic
      IMPORTING
          !r_link
          !r_succtab
          !succrow
          !r_doit .
    METHODS print_control .
    METHODS propose_on_condition
      IMPORTING
        !i_tabnamel TYPE aqs_tname
        !i_tabnamer TYPE aqs_tname
      EXCEPTIONS
        no_joins_found
        no_further_joins_found
        join_addition_invalid .
    METHODS propose_on_condition_add_link
      IMPORTING
        !is_join TYPE aqq_s_join .
    METHODS recreate_links .
    METHODS reduce_distance .
    METHODS referenzfield
      IMPORTING
        !is_tab  TYPE aqq_s_tab
        !i_tname TYPE aqs_tname .
    METHODS rel_2_abs
      IMPORTING
        !is_dbjt     TYPE aqdbjt
      EXPORTING
        !es_tpos_abs TYPE aqstposabs .
    METHODS remove_link
      IMPORTING
        !ir_link TYPE REF TO if_aqqgraphic_link
        !r_doit  TYPE REF TO cl_aqqgraphic_doit OPTIONAL .

    METHODS reorder_joins
      IMPORTING
        !it_tpos_new TYPE aqq_t_tpos
        !it_tpos_old TYPE aqq_t_tpos
      EXPORTING
        !e_forced    TYPE boolean .
    METHODS save_as_jpg .
    METHODS scale .
    METHODS search .
    METHODS search_domain_in_tabobj
      IMPORTING
        !is_search     TYPE aqssearch
        !it_tab        TYPE aqq_t_tab
        !i_start_tabix TYPE sytabix
        !i_tname       TYPE aqs_tname
      EXPORTING
        !e_found       TYPE boolean
        !e_row         TYPE sytabix
        !es_tobj_join  TYPE aqstobjjoi .
    METHODS search_in_tabobj
      IMPORTING
        !is_search     TYPE aqssearch
        !it_tab        TYPE aqq_t_tab
        !i_start_tabix TYPE sytabix
        !i_tname       TYPE aqs_tname
      EXPORTING
        !e_found       TYPE boolean
        !e_row         TYPE sytabix
        !es_tobj_join  TYPE aqstobjjoi .
    METHODS search_next .
    METHODS search_text_in_tabobj
      IMPORTING
        !is_search     TYPE aqssearch
        !it_tab        TYPE aqq_t_tab
        !i_start_tabix TYPE sytabix
        !i_tname       TYPE aqs_tname
      EXPORTING
        !e_found       TYPE boolean
        !e_row         TYPE sytabix
        !es_tobj_join  TYPE aqstobjjoi .
    METHODS search_type_in_tabobj
      IMPORTING
        !is_search     TYPE aqssearch
        !it_tab        TYPE aqq_t_tab
        !i_start_tabix TYPE sytabix
        !i_tname       TYPE aqs_tname
      EXPORTING
        !e_found       TYPE boolean
        !e_row         TYPE sytabix
        !es_tobj_join  TYPE aqstobjjoi .
    METHODS send_tables_to_cntrl
      IMPORTING
        !i_t_tobj_join TYPE aqq_t_tobj_join .
    METHODS set_cell_properties
      IMPORTING
        !i_s_tobj_join TYPE aqstobjjoi .
    METHODS set_changed
      IMPORTING
        !i_changed TYPE flag .
    METHODS skalierung_popup
      EXPORTING
        !e_scalex TYPE i
        !e_scaley TYPE i
      EXCEPTIONS
        cancelled .
    METHODS synchronize_control_data
      IMPORTING
        !it_tpos TYPE aqq_t_tpos .
    METHODS test_join_validity
      IMPORTING
        !is_join    TYPE aqq_s_join
      EXPORTING
        !e_tabname1 TYPE aqs_tname
        !e_tabname2 TYPE aqs_tname
        !e_tabname3 TYPE aqs_tname
      EXCEPTIONS
        mode_invalid
        join_type_invalid_left
        join_type_invalid_right
        join_type_invalid_side
        join_type_invalid_twice
        join_type_inconsistent
        tab_not_found
        field_not_found
        fields_invalid .
    METHODS zoomin .
    METHODS zoomout .

ENDCLASS. "zcl_zaaqb_query_join_cntrl DEFINITION

*----------------------------------------------------------------------*
*       CLASS zcl_zaaqb_query_join_cntrl IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS zcl_zaaqb_query_join_cntrl IMPLEMENTATION.

  METHOD set_keywords.

    DATA wa_key_word LIKE LINE OF zaaqb_key_word.

    LOOP AT it_key_word INTO  wa_key_word.

      READ TABLE zaaqb_key_word WITH KEY table = wa_key_word-table TRANSPORTING NO FIELDS.

      IF sy-subrc = 4.
        APPEND wa_key_word TO zaaqb_key_word.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "set_keywords

  METHOD get_keywords.
    it_key_word = zaaqb_key_word.
  ENDMETHOD.                    "set_keywords

  METHOD remove_keywords.

    DATA wa_key_word LIKE LINE OF zaaqb_key_word.

    LOOP AT zaaqb_key_word INTO  wa_key_word.

      READ TABLE it_key_word WITH KEY table = wa_key_word-table TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.
        DELETE zaaqb_key_word WHERE table = wa_key_word-table.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "remove_keywords

  METHOD check_conditions.

    DATA: l_lin_tpos TYPE i,
          ls_tpos    TYPE aqq_s_tpos,
          ls_join    TYPE aqq_s_join.

    DESCRIBE TABLE pt_tpos LINES l_lin_tpos.

    IF     l_lin_tpos = 0.
      RAISE zero_tables.
    ELSEIF l_lin_tpos = 1.
      RAISE only_one_table.
    ENDIF.

    SORT pt_tpos BY xpos.

    LOOP AT pt_tpos FROM 2 INTO ls_tpos.
      READ TABLE pt_join INTO ls_join WITH KEY tabnamer = ls_tpos-tabname.
      IF sy-subrc NE 0 .
        e_tname = ls_tpos-tabname.
        RAISE not_right.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "check_conditions

  METHOD test_join_validity.
* exceptions
*  tab_not_found                   "table not found
*  field_not_found2                "field not found
*
*  fields_invalid                  "fields cannot be combined.
*  join_type_inconsistent          "other join-types between tables have
*                                  "different type, on return
*                                  "l_wa_joins2 contains different type
*                                  "method force_join can be used to set/reset
*                                  "current join.
*  join_type_invalid_loe,          "left outer is defined between other
*                                  "tables
*
* join_type_invalid_twice:
*   making join lo would lead to:     T1-(join)LO--T2
*    (illegal #1)                                  T2
*                                         T3-------T2

    DATA: l_wx_join2      TYPE aqq_s_join,
          ls_join         TYPE aqq_s_join,
          ls_tpos         TYPE aqq_s_tpos,
          l_join_reversed TYPE flag.

* check whether fields are present.
*  IF MOVE_MODE <> 'X'.
*    RAISE MODE_INVALID.
*  ENDIF.
    ls_join = is_join.

    READ TABLE pt_tfield WITH TABLE KEY tabname = ls_join-tabnamel
                                        colname = ls_join-colnamel
                                        TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      RAISE tab_not_found.
    ENDIF.

    READ TABLE pt_tfield WITH TABLE KEY tabname = ls_join-tabnamer
                                        colname = ls_join-colnamer
                                        TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      RAISE tab_not_found.
    ENDIF.

    DATA: lt_ltab TYPE aqq_t_tab,
          ls_ltab TYPE aqq_s_tab,
          lt_rtab TYPE aqq_t_tab,
          ls_rtab TYPE aqq_s_tab.

    get_tab( EXPORTING i_tabname = ls_join-tabnamel
             IMPORTING et_tab    = lt_ltab ).
    get_tab( EXPORTING i_tabname = ls_join-tabnamer
             IMPORTING et_tab    = lt_rtab ).

* check whether fields can be combined.
    READ TABLE lt_ltab INTO ls_ltab WITH KEY feld = ls_join-colnamel.
    IF sy-subrc <> 0.
      RAISE field_not_found.
    ENDIF.

    READ TABLE lt_rtab INTO ls_rtab WITH KEY feld = ls_join-colnamer.
    IF sy-subrc <> 0.
      RAISE field_not_found.
    ENDIF.

    IF ls_ltab-dtype <> ls_rtab-dtype OR
       ls_ltab-dleng <> ls_rtab-dleng OR
       ls_ltab-ddec  <> ls_rtab-ddec.
      RAISE fields_invalid.
    ENDIF.


    DATA l_wx_join TYPE aqq_s_join.
* check whether join-definition has to be reversed.
    READ TABLE pt_tpos INTO ls_tpos WITH KEY tabname = ls_join-tabnamel.
    DATA l_xl TYPE i.
    l_xl = ls_tpos-xpos.
    READ TABLE pt_tpos INTO ls_tpos WITH KEY tabname = ls_join-tabnamer.
    CLEAR l_join_reversed.
    IF ( l_xl > ls_tpos-xpos ).
* reverse join.
      l_wx_join = ls_join.
      ls_join-tabnamel = l_wx_join-tabnamer.
      ls_join-tabnamer = l_wx_join-tabnamel.
      ls_join-colnamel = l_wx_join-colnamer.
      ls_join-colnamer = l_wx_join-colnamel.
      l_join_reversed  = aqqis_c_true.
* set flag join_reversed.
    ENDIF.

    IF ls_join-type = aqqis_c_join_typ-left_outer.
*check whether join-type left_outer is illegal here.
* it is illegal if:
* II: Join-Jain T1---LO---T2---LO---T3 would be created.

* IIa)   left table is already right table of other left outer join.
      READ TABLE pt_join INTO l_wx_join WITH KEY tabnamer = ls_join-tabnamel
                                                 type     = aqqis_c_join_typ-left_outer.
      IF sy-subrc = 0.
        e_tabname2 = ls_join-tabnamel.
        e_tabname3 = ls_join-tabnamer.
        e_tabname1 = l_wx_join-tabnamel.
        RAISE join_type_invalid_left.
      ENDIF.

* IIb)  or :  right table is left table of other left-outer join.
      READ TABLE pt_join INTO l_wx_join WITH KEY tabnamel = ls_join-tabnamer
                                                 type     = aqqis_c_join_typ-left_outer.
      IF sy-subrc = 0.
        e_tabname1 = ls_join-tabnamel.
        e_tabname2 = ls_join-tabnamer.
        e_tabname3 = l_wx_join-tabnamer.
        RAISE join_type_invalid_right.
      ENDIF.

*   or :    a join which would be forced would lead to an error:
*          == is a join with right table tabnamer defined
*             between a table with a left outer join?
      LOOP AT pt_join INTO l_wx_join WHERE tabnamer = ls_join-tabnamer.
        LOOP AT pt_join INTO l_wx_join2 WHERE tabnamer = l_wx_join-tabnamel
                                          AND type     = aqqis_c_join_typ-left_outer.
          e_tabname1 = l_wx_join2-tabnamel.
          e_tabname2 = l_wx_join2-tabnamer.
          e_tabname3 = l_wx_join-tabnamer.
          RAISE join_type_invalid_side.
        ENDLOOP.
      ENDLOOP.

*   or I)  a join which would be forced would lead to an error:
*         new join is type left_outer , but r.h.s. table is
*         connected to more than one table.
      LOOP AT pt_join INTO l_wx_join WHERE tabnamer = ls_join-tabnamer.
        IF l_wx_join-tabnamel <> ls_join-tabnamel.
          e_tabname1 = ls_join-tabnamel.
          e_tabname2 = ls_join-tabnamer.
          e_tabname3 = l_wx_join-tabnamel.
          RAISE join_type_invalid_twice.
        ENDIF.
      ENDLOOP.
    ENDIF.                             "new join is left outer".

* is the type of the joins between the tables inconsistent?
* = Are there other joins towards the right table of different type?
    LOOP AT pt_join INTO l_wx_join WHERE tabnamer = ls_join-tabnamer.
      IF ( NOT (     l_wx_join-tabnamel = ls_join-tabnamel
                 AND l_wx_join-colnamel = ls_join-colnamel
                 AND l_wx_join-colnamer = ls_join-colnamer ) ). "not same join!
        IF l_wx_join-type <> ls_join-type.
          RAISE join_type_inconsistent.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "test_join_validity

  METHOD check_remove_tobject.

    DATA: lt_dbjt     TYPE aqtdbjt,
          lt_dbsf     TYPE aqtdbsf,
          l_cnt_dbjt  TYPE i,
          l_caller_id TYPE c.

    p_join_data_r->get_info( IMPORTING et_dbjt     = lt_dbjt
                                       et_dbsf     = lt_dbsf
                                       e_caller_id = l_caller_id ).

    DESCRIBE TABLE lt_dbjt LINES l_cnt_dbjt.

    IF l_cnt_dbjt = 1.
      RAISE only_one_table.
    ENDIF.

    READ TABLE lt_dbsf WITH KEY sgna = i_tname
                                addy = space
                       TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      IF ( l_caller_id <> 'Q' ).
        RAISE table_is_used.
      ELSE.
        RAISE no_remove_in_quickview.
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "check_remove_tobject

  METHOD constructor.
* change/display mode
    p_mode        = i_mode.

    p_join_data_r = i_join_data_r.

    init( i_r_container_parent = i_r_container_parent ).

  ENDMETHOD.                    "constructor

  METHOD handle_fcode.

    synchronize_positions( EXCEPTIONS no_data_on_control = 1 ).
    CALL FUNCTION 'RSAQ_CNTRL_SYNCHRONIZE_TABLES'.

    CASE i_fcode.
      WHEN aqqis_c_ok_altb.       "Aliastabelle
        aliastable( ).

      WHEN aqqis_c_ok_check.      "Verk#pfungsbedingungen pr#fen
        check( ).

      WHEN aqqis_c_ok_ddic.       "Absprung ins DDic
        display_ddic( ir_table ).

      WHEN aqqis_c_ok_f_jpg.      "jpg
        save_as_jpg( ).

      WHEN aqqis_c_ok_f_ldel.     "Link l#schen
        remove_link( ir_link = ir_link ).

      WHEN aqqis_c_ok_f_navi.     "Navigator
        navigator( ).

      WHEN aqqis_c_ok_f_print.    "Control drucken
        print_control( ).

      WHEN aqqis_c_ok_f_tdel.     "Tabelle l#schen
        remove_tobject( ).

      WHEN aqqis_c_ok_f_scale.    "Skalierung
        scale( ).

      WHEN aqqis_c_ok_f_zoomin.   "zoom in
        zoomin( ).

      WHEN aqqis_c_ok_f_zoomout.  "zoom out
        zoomout( ).

      WHEN aqqis_c_ok_fdoc.       "Felddokumentation
        fielddocu( ir_table = ir_table
                   i_row    = i_rowindex ).

      WHEN aqqis_c_ok_fref.       "Referenzfeld
        fieldreference( ir_table = ir_table
                        i_row    = i_rowindex ).

      WHEN aqqis_c_ok_jpro.       "Joinbedingung vorschlagen
        on_condition( ).

      WHEN aqqis_c_ok_lijoin.     "inner join
        join_modification( ir_link    = ir_link
                           i_join_typ = aqqis_c_join_typ-inner ).

      WHEN aqqis_c_ok_lojoin.     "outer join
        join_modification( ir_link    = ir_link
                           i_join_typ = aqqis_c_join_typ-left_outer ).

      WHEN aqqis_c_ok_such.       "suchen
        search( ).

      WHEN aqqis_c_ok_sucw.       "weiter suchen
        search_next( ).

      WHEN aqqis_c_ok_tins.       "Tabelle einf#gen
        add_tobject( ).

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.                    "handle_fcode

  METHOD set_mode.

    p_mode = i_mode.

  ENDMETHOD.                    "set_mode

  METHOD delete_all_table.
    DATA: wa_tobj_join LIKE LINE OF p_t_tobj_join,
          it_objects   TYPE  aqq_t_objects,
          wa_objects   LIKE LINE OF it_objects.

    LOOP AT p_t_tobj_join INTO wa_tobj_join.

      CLEAR: wa_objects,
            it_objects[].
      wa_objects-r_table = wa_tobj_join-tabref.
      APPEND wa_objects TO it_objects.

      CALL METHOD p_r_join_cntrl->set_selected_objects
        EXPORTING
          i_t_objects = it_objects.

      remove_tobject( ).

    ENDLOOP.

*    DATA: l_t_objects   TYPE aqq_t_objects,
*          wa_t_objects LIKE LINE OF l_t_objects ,
*             l_lin_objects TYPE i,
*             lt_del_links  TYPE aqq_t_links,
*             ls_link       TYPE aqslinks,
*             lt_dban       TYPE aqtdban,
*             lt_dbsg       TYPE aqtdbsg.
*
*    FIELD-SYMBOLS: <objects>   TYPE aqsobjects,
*                   <tobj_join> TYPE aqstobjjoi,
*                   <link>      TYPE aqslinkjoi.
*
*    LOOP AT p_t_tobj_join INTO wa_tobj_join.
*
*      REFRESH l_t_objects.
*      wa_t_objects-r_table = wa_tobj_join-TABREF.
*      APPEND wa_t_objects TO l_t_objects.
*
*      READ TABLE l_t_objects ASSIGNING <objects> INDEX 1.
*      READ TABLE p_t_tobj_join ASSIGNING <tobj_join> INDEX sy-tabix ."WITH KEY tabref = <objects>-r_table.
*      IF sy-subrc NE 0.
**   fatal error
*        MESSAGE a008(aqqis_cntrl) WITH 'ZCL_ZAAQB_QUERY_JOIN_CNTRL' 'REMOVE_TOBJECT'.
*      ENDIF.
*
*      check_remove_tobject( EXPORTING  i_tname                = <tobj_join>-tname
*                            EXCEPTIONS only_one_table         = 1
*                                       table_is_used          = 2
*                                       no_remove_in_quickview = 3 ).
*      IF     sy-subrc = 1.
**   Es d#rfen nicht alle Tabellen gel#scht werden
**        MESSAGE s009(aqqis_cntrl).
**        EXIT.
*      ELSEIF sy-subrc = 2.
**   Tabelle &1 wird noch verwendet
*        MESSAGE s010(aqqis_cntrl) WITH <tobj_join>-tname.
*        EXIT.
*      ELSEIF sy-subrc = 3.
**   Tabellen des Joins k#nnen im QuickViewer nicht mehr gel#scht werden
*        MESSAGE s011(aqqis_cntrl).
*        EXIT.
*      ENDIF.
*
*      set_changed( EXPORTING i_changed = aqqis_c_changed-updated ).
*
** L#schen Datentabellen
**   beim L#schen m#ssen folgende Tabellen ber#cksichtigt werden
**   dbjt   - verwendete Tabellen
**   dbsg   - Struktur logische DB -> Baum
**            Join                 -> alle Jointabellen
**            HR-DB                -> Infotypen
**            wird parallel zur dbjt gehalten
**   dbsf   - Felder aus Sachgebiet
**            hier mu# gepr#ft werden, ob noch Felder verwendet werden
**            falls ja, wird das L#schen abgelehnt
**            wird in ZCL_ZAAQB_QUERY_JOIN_CNTRL gepr#ft
**   dban   - Aliasnamen, also ggf.
**   dbjc   - Tabellen-Join-Bedingung
*
*      DELETE pt_join   WHERE tabnamel = <tobj_join>-tname.
*      DELETE pt_join   WHERE tabnamer = <tobj_join>-tname.
*      DELETE pt_tpos   WHERE tabname  = <tobj_join>-tname.
*      DELETE pt_tfield WHERE tabname  = <tobj_join>-tname.
*      p_join_data_r->get_info( IMPORTING et_dban = lt_dban
*                                         et_dbsg = lt_dbsg ).
*      LOOP AT lt_dbsg TRANSPORTING NO FIELDS WHERE name = <tobj_join>-tname.
*        DELETE lt_dbsg INDEX sy-tabix.
*      ENDLOOP.
** L#schen Alias-Beziehung
**  loop at lt_dban transporting no fields where alias = <tobj_join>-tname.
**    delete lt_dban index sy-tabix.
**  endloop.
*      p_join_data_r->set_info( EXPORTING it_dban = lt_dban
*                                         it_dbsg = lt_dbsg ).
*
** L#schen Frontend-Komponenten
*      LOOP AT p_t_links_join ASSIGNING <link> WHERE tnameleft  = <tobj_join>-tname
*                                                 OR tnameright = <tobj_join>-tname.
*        ls_link-r_link = <link>-linkref .
*        APPEND ls_link TO lt_del_links.
*      ENDLOOP.
*
*      p_r_join_cntrl->delete_objects( EXPORTING i_r_table  = <tobj_join>-tabref ).
*      p_r_join_cntrl->delete_objects( EXPORTING i_t_link   = lt_del_links ).
*
*      DELETE p_t_links_join WHERE tnameleft  = <tobj_join>-tname.
*      DELETE p_t_links_join WHERE tnameright = <tobj_join>-tname.
*      DELETE p_t_tobj_join  WHERE tabref      = <objects>-r_table.
*
*      cnvt_table_to_old( ).
*
*    ENDLOOP.


  ENDMETHOD.                    "delete_all_table

  METHOD synchronize_positions.

    DATA: lt_tablepos    TYPE aqq_t_tablepos,
          ls_tablepos    TYPE aqstabpos,
          l_lin_tablepos TYPE i,
          lt_tpos        TYPE aqq_t_tpos,
          ls_tpos        TYPE aqq_s_tpos,
          l_forced       TYPE boolean.

*--- Positionen d#rfen nur im #nderungsmodus aktualisiert werden
    IF p_mode = aqqis_c_mode-display.
      EXIT.
    ENDIF.

*--- aktuelle Positionen von dem Control holen
    lt_tablepos = p_r_join_cntrl->get_position_of_objects( ).

    DESCRIBE TABLE lt_tablepos LINES l_lin_tablepos.
    IF l_lin_tablepos <= 0.
      RAISE no_data_on_control.
    ENDIF.

*  if lt_tablepos[] = pt_tablepos[].
*  keine Ver#nderung
*    exit.  "changed CR 31.10.2002
*            -> Errorhandling: links might have been changed and so
*               reorder_joins should be called
*  endif.

* lt_tpos updaten
    LOOP AT lt_tablepos INTO ls_tablepos.
      abs_2_rel( EXPORTING is_tablepos = ls_tablepos
                 IMPORTING es_tpos     = ls_tpos ).
      APPEND ls_tpos TO lt_tpos.
    ENDLOOP.

* pt_join an die neuen Koordinaten anpassen
    reorder_joins( EXPORTING it_tpos_new = lt_tpos
                             it_tpos_old = pt_tpos
                   IMPORTING e_forced    = l_forced ).

* Frontendtabellen aktualisieren.
* p_t_tobj_join, p_t_links_join
    synchronize_control_data( it_tpos = lt_tpos ).

* Links neu zeichnen
    IF l_forced = aqqis_c_true.
      recreate_links( ).
    ENDIF.

    SORT lt_tpos BY xpos.
    pt_tpos[]     = lt_tpos[].
    pt_tablepos[] = lt_tablepos[].

* dbjt und dbjc aktualisieren
    cnvt_table_to_old( ).

  ENDMETHOD.                    "synchronize_positions

  METHOD abs_2_rel.

    FIELD-SYMBOLS: <tobj_join> TYPE aqstobjjoi.

    READ TABLE p_t_tobj_join ASSIGNING <tobj_join> WITH KEY tabref = is_tablepos-r_table.
    CHECK sy-subrc = 0.

*--- rel
    es_tpos-tabname   = <tobj_join>-tname.
    es_tpos-xpos      = is_tablepos-leftpos.
    es_tpos-ypos      = is_tablepos-toppos.
    es_tpos-width     = is_tablepos-rightpos - is_tablepos-leftpos.
    es_tpos-height    = is_tablepos-bottompos - is_tablepos-toppos.

  ENDMETHOD.                                                "abs_2_rel

  METHOD add_links_to_join.

    DATA: lt_join TYPE aqq_t_join,
          l_row_l TYPE sytabix,
          l_row_r TYPE sytabix.

    FIELD-SYMBOLS: <join>        TYPE aqq_s_join,
                   <tobj_join_l> TYPE aqstobjjoi,
                   <tobj_join_r> TYPE aqstobjjoi,
                   <fobj_join_l> TYPE aqsfobjjoi,
                   <fobj_join_r> TYPE aqsfobjjoi.

    lt_join[] = pt_join[].

    LOOP AT lt_join ASSIGNING <join>.
      READ TABLE p_t_tobj_join ASSIGNING <tobj_join_l> WITH KEY tname = <join>-tabnamel.
      READ TABLE <tobj_join_l>-fobj ASSIGNING <fobj_join_l> WITH KEY fname = <join>-colnamel.
      l_row_l = sy-tabix.
      READ TABLE p_t_tobj_join ASSIGNING <tobj_join_r> WITH KEY tname = <join>-tabnamer.
      READ TABLE <tobj_join_r>-fobj ASSIGNING <fobj_join_r> WITH KEY fname = <join>-colnamer.
      l_row_r = sy-tabix.

      create_link( EXPORTING ir_tabl = <tobj_join_l>-tabref
                             ir_tabr = <tobj_join_r>-tabref
                             i_rowl  = l_row_l
                             i_rowr  = l_row_r ).

    ENDLOOP.

    p_r_join_cntrl->send_data_to_frontend( ).

  ENDMETHOD.                    "add_links_to_join

  METHOD add_tables_to_join.

    DATA: lt_dbjt      TYPE aqtdbjt,
          lt_dbjc      TYPE aqtdbjc,
          ls_tobj_join TYPE aqstobjjoi.

    FIELD-SYMBOLS: <dbjt>    TYPE aqdbjt.

    p_join_data_r->get_info( IMPORTING et_dbjt   = lt_dbjt
                                       et_dbjc   = lt_dbjc ).

    LOOP AT lt_dbjt ASSIGNING <dbjt>.
      IF <dbjt>-left_vz IS INITIAL.
        <dbjt>-left_vz  = p_tab_startx.
      ENDIF.
      IF <dbjt>-top_vz IS INITIAL.
        <dbjt>-top_vz = p_tab_starty.
      ENDIF.
      <dbjt>-width_vz  = p_tab_width.
      <dbjt>-height_vz = p_tab_height.

      fill_table_fields( EXPORTING is_dbjt      = <dbjt>
                         IMPORTING es_tobj_join = ls_tobj_join ).

      APPEND ls_tobj_join TO p_t_tobj_join.
    ENDLOOP.

    send_tables_to_cntrl( EXPORTING i_t_tobj_join = p_t_tobj_join ).
    p_r_join_cntrl->send_data_to_frontend( ).

  ENDMETHOD.                    "add_tables_to_join

  METHOD add_tfield.

    DATA: lt_tfield TYPE aqq_t_tfield,
          ls_tfield TYPE aqstfield,
          lt_tab    TYPE aqq_t_tab.

    FIELD-SYMBOLS: <tab> TYPE aqq_s_tab.

    lt_tfield[] = pt_tfield[].

    READ TABLE lt_tfield WITH KEY tabname = i_tname TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      RAISE existing.
    ENDIF.

    get_tab( EXPORTING i_tabname = i_tname
             IMPORTING et_tab    = lt_tab ).


    LOOP AT lt_tab ASSIGNING <tab>.

      ls_tfield-tabname = i_tname.
      ls_tfield-colname = <tab>-feld.
      IF <tab>-key = aqqis_c_true.
        ls_tfield-iskey = 1.
      ELSE.
        ls_tfield-iskey = 0.
      ENDIF.
      APPEND ls_tfield TO lt_tfield.

    ENDLOOP.

    pt_tfield[] = lt_tfield[].
  ENDMETHOD.                    "add_tfield

  METHOD add_table.

    DATA: l_tab_new    TYPE aq_segname,
          lt_dbjt      TYPE aqtdbjt,
          lt_ttab      TYPE aqq_t_ttab,
          ls_tobj_join TYPE aqstobjjoi,
          lt_tobj_join TYPE aqq_t_tobj_join,

*>>>---zaaqb
          lt_tab       TYPE aqq_t_tab,
          l_count      TYPE i,
          lv_count     TYPE i.
*<<<---zaaqb

    FIELD-SYMBOLS: <dbjt> TYPE aqdbjt.



    IF p_mode = aqqis_c_mode-display.
*   Funktion nur im #nderungsmodus unterst#tzt
      MESSAGE s005(aqqis_cntrl).
      EXIT.
    ENDIF.

*--- Popup: welche Tabelle eingef#gt werden soll
*    Die Abfrage, ob Tabelle schon auf dem Control existiert, erfolgt in der
*    Dynprologik
*    call function 'RSAQ_CNTRL_ADD_TAB_0300'
*      importing
*        e_tab     = l_tab_new
*      exceptions
*        cancelled = 1
*        others    = 99.
*
*    if sy-subrc ne 0.
**   Aktion abgebrochen
*      message s001(aqqis_cntrl).
*      exit.
*    endif.
    l_tab_new = i_tabname.
    CLEAR lv_count.
    SELECT COUNT( * )
  FROM dd02l
  INTO lv_count
  WHERE tabname = i_tabname AND
      tabclass IN ('TRANSP', 'VIEW').

    IF lv_count = 0.
      EXIT.
    ENDIF.

*>>>---zaaqb
    get_tab( EXPORTING i_tabname = l_tab_new
             IMPORTING et_tab    = lt_tab ).

    DESCRIBE TABLE lt_tab LINES l_count.
    IF l_count = 0.
      EXIT.
    ENDIF.
*<<<---zaaqb

* ttab Aufbauen
    CALL FUNCTION 'RSAQ_CNTRL_BUILD_TTAB'
      EXPORTING
        i_tab   = l_tab_new
      IMPORTING
        et_ttab = lt_ttab.
    p_join_data_r->set_info( EXPORTING it_ttab   = lt_ttab ).

* setzen #nderungsflag
    set_changed( EXPORTING i_changed = aqqis_c_changed-updated ).

* F#llen von pt_tfield
    add_tfield( EXPORTING i_tname = l_tab_new
                EXCEPTIONS existing     = 1 ).
    IF sy-subrc = 1.
      EXIT.
    ENDIF.

* Positionen neue Tabelle bestimmen - F#llen von pt_tpos
    add_tpos( EXPORTING i_tname  = l_tab_new ).

* pt_tpos, pt_tfield, pt_join -> dbjc, dbjt
    cnvt_table_to_old( ).

* Tabelle ans Frontend senden
    p_join_data_r->get_info( IMPORTING et_dbjt = lt_dbjt ).
    READ TABLE lt_dbjt ASSIGNING <dbjt> WITH KEY table = l_tab_new.
    IF sy-subrc = 0.

      fill_table_fields( EXPORTING is_dbjt      = <dbjt>
                         IMPORTING es_tobj_join = ls_tobj_join ).
      APPEND ls_tobj_join TO lt_tobj_join.
      APPEND ls_tobj_join TO p_t_tobj_join.

      send_tables_to_cntrl( EXPORTING i_t_tobj_join = lt_tobj_join ).
      p_r_join_cntrl->send_data_to_frontend( ).
    ENDIF.

* Links
* Vorschl#ge on-Bedingung
    DATA: lt_tpos    TYPE aqq_t_tpos,
          ls_tposr   TYPE aqq_s_tpos,
          ls_tposl   TYPE aqq_s_tpos,
          l_lin_tpos TYPE i.

    lt_tpos[] = pt_tpos[].
    DESCRIBE TABLE lt_tpos LINES l_lin_tpos.
    CHECK l_lin_tpos >= 2.
    READ TABLE lt_tpos INTO ls_tposr INDEX l_lin_tpos.
    l_lin_tpos = l_lin_tpos - 1.
    READ TABLE lt_tpos INTO ls_tposl INDEX l_lin_tpos.

    propose_on_condition( EXPORTING  i_tabnamel             = ls_tposl-tabname
                                     i_tabnamer             = ls_tposr-tabname
                          EXCEPTIONS no_joins_found         = 1
                                     no_further_joins_found = 2
                                     join_addition_invalid  = 3 ).
    IF     sy-subrc = 1.
*   Keine Verkn#pfungen gefunden
      MESSAGE s002(aqqis_cntrl).
      EXIT.
    ELSEIF sy-subrc = 2.
*   Keine weiteren Verkn#pfungen gefunden
      MESSAGE s003(aqqis_cntrl).
      EXIT.
    ELSEIF sy-subrc = 3.
*   Verkn#pfungen lassen sich nicht als Left-outer Bedingung einf#gen
      MESSAGE s004(aqqis_cntrl).
      EXIT.
    ENDIF.

    p_r_join_cntrl->send_data_to_frontend( ).

  ENDMETHOD.                    "add_tobject

  METHOD add_tobject.

    DATA: l_tab_new    TYPE aq_segname,
          lt_dbjt      TYPE aqtdbjt,
          lt_ttab      TYPE aqq_t_ttab,
          ls_tobj_join TYPE aqstobjjoi,
          lt_tobj_join TYPE aqq_t_tobj_join,

*>>>---zaaqb
          oref         TYPE REF TO cx_root,
          lt_tab       TYPE aqq_t_tab,
          l_count      TYPE i.
*<<<---zaaqb

    FIELD-SYMBOLS: <dbjt> TYPE aqdbjt.



    IF p_mode = aqqis_c_mode-display.
*   Funktion nur im #nderungsmodus unterst#tzt
      MESSAGE s005(aqqis_cntrl).
      EXIT.
    ENDIF.

*--- Popup: welche Tabelle eingef#gt werden soll
*    Die Abfrage, ob Tabelle schon auf dem Control existiert, erfolgt in der
*    Dynprologik
    CALL FUNCTION 'RSAQ_CNTRL_ADD_TAB_0300'
      IMPORTING
        e_tab     = l_tab_new
      EXCEPTIONS
        cancelled = 1
        OTHERS    = 99.

    IF sy-subrc NE 0.
*   Aktion abgebrochen
      MESSAGE s001(aqqis_cntrl).
      EXIT.
    ENDIF.

*>>>---zaaqb
    p_join_data_r->get_info( IMPORTING et_dbjt = lt_dbjt ).
    READ TABLE lt_dbjt TRANSPORTING NO FIELDS WITH KEY table = l_tab_new.
    IF ( sy-subrc = 0 ).
*   Die Tabelle wird bereits verwendet
      EXIT.
    ENDIF.

    get_tab( EXPORTING i_tabname = l_tab_new
             IMPORTING et_tab    = lt_tab ).

    DESCRIBE TABLE lt_tab LINES l_count.
    IF l_count = 0.
      EXIT.
    ENDIF.
*<<<---zaaqb

* ttab Aufbauen
    CALL FUNCTION 'RSAQ_CNTRL_BUILD_TTAB'
      EXPORTING
        i_tab   = l_tab_new
      IMPORTING
        et_ttab = lt_ttab.
    p_join_data_r->set_info( EXPORTING it_ttab   = lt_ttab ).

* setzen #nderungsflag
    set_changed( EXPORTING i_changed = aqqis_c_changed-updated ).

    add_tfield( EXPORTING i_tname = l_tab_new
                EXCEPTIONS existing     = 1 ).


* Positionen neue Tabelle bestimmen - F#llen von pt_tpos
    add_tpos( EXPORTING i_tname  = l_tab_new ).

* pt_tpos, pt_tfield, pt_join -> dbjc, dbjt
    cnvt_table_to_old( ).

* Tabelle ans Frontend senden
    p_join_data_r->get_info( IMPORTING et_dbjt = lt_dbjt ).
    READ TABLE lt_dbjt ASSIGNING <dbjt> WITH KEY table = l_tab_new.
    IF sy-subrc = 0.

      fill_table_fields( EXPORTING is_dbjt      = <dbjt>
                         IMPORTING es_tobj_join = ls_tobj_join ).
      APPEND ls_tobj_join TO lt_tobj_join.
      APPEND ls_tobj_join TO p_t_tobj_join.

      send_tables_to_cntrl( EXPORTING i_t_tobj_join = lt_tobj_join ).
      p_r_join_cntrl->send_data_to_frontend( ).
    ENDIF.

* Links
* Vorschl#ge on-Bedingung
    DATA: lt_tpos    TYPE aqq_t_tpos,
          ls_tposr   TYPE aqq_s_tpos,
          ls_tposl   TYPE aqq_s_tpos,
          l_lin_tpos TYPE i.

    lt_tpos[] = pt_tpos[].
    DESCRIBE TABLE lt_tpos LINES l_lin_tpos.
    CHECK l_lin_tpos >= 2.
    READ TABLE lt_tpos INTO ls_tposr INDEX l_lin_tpos.
    l_lin_tpos = l_lin_tpos - 1.
    READ TABLE lt_tpos INTO ls_tposl INDEX l_lin_tpos.

    propose_on_condition( EXPORTING  i_tabnamel             = ls_tposl-tabname
                                     i_tabnamer             = ls_tposr-tabname
                          EXCEPTIONS no_joins_found         = 1
                                     no_further_joins_found = 2
                                     join_addition_invalid  = 3 ).
    IF     sy-subrc = 1.
*   Keine Verkn#pfungen gefunden
      MESSAGE s002(aqqis_cntrl).
      EXIT.
    ELSEIF sy-subrc = 2.
*   Keine weiteren Verkn#pfungen gefunden
      MESSAGE s003(aqqis_cntrl).
      EXIT.
    ELSEIF sy-subrc = 3.
*   Verkn#pfungen lassen sich nicht als Left-outer Bedingung einf#gen
      MESSAGE s004(aqqis_cntrl).
      EXIT.
    ENDIF.

    p_r_join_cntrl->send_data_to_frontend( ).

  ENDMETHOD.                    "add_tobject

  METHOD add_tpos.

    DATA: lt_tablepos  TYPE aqq_t_tablepos,
          lt_tpos      TYPE aqq_t_tpos,
          ls_tpos_last TYPE aqq_s_tpos,
          ls_tpos_new  TYPE aqq_s_tpos,
          l_cnt_tpos   TYPE i.

*--- lesen Tabellenpositionen
    lt_tablepos = p_r_join_cntrl->get_position_of_objects( ).

    lt_tpos[] = pt_tpos[].
    DESCRIBE TABLE lt_tpos LINES l_cnt_tpos.

* schon Eintr#ge vorhanden - sprich Tabellen auf dem Control
    IF l_cnt_tpos > 0.
      READ TABLE lt_tpos TRANSPORTING NO FIELDS WITH KEY tabname = i_tname.
      IF sy-subrc = 0.
        RAISE existing.
      ENDIF.

      SORT lt_tpos BY xpos.

      READ TABLE lt_tpos INTO ls_tpos_last INDEX l_cnt_tpos.
      ls_tpos_new          = ls_tpos_last.
      ls_tpos_new-tabname  = i_tname.
      ls_tpos_new-xpos     = ls_tpos_last-xpos + ls_tpos_last-width + 50.
      ls_tpos_new-width    = p_tab_width.
      ls_tpos_new-height   = p_tab_height.
*    XPOS
*    YPOS
*    WIDTH
*    HEIGHT
      APPEND ls_tpos_new TO lt_tpos.

* erste Tabelle auf dem Control
    ELSE.
      ls_tpos_new-tabname  = i_tname.
      ls_tpos_new-xpos     = p_tab_startx.
      ls_tpos_new-ypos     = p_tab_starty.
      ls_tpos_new-width    = p_tab_width.
      ls_tpos_new-height   = p_tab_height.
      APPEND ls_tpos_new TO lt_tpos.
    ENDIF.

    pt_tpos[] = lt_tpos[].

  ENDMETHOD.                    "add_tpos
  METHOD aliastable.

    DATA:  l_sgname       TYPE aqs_sgname,
           l_actworkspace TYPE aqs_wsid,
           l_headsg       TYPE aqhdsg,
           l_maxsg_tindx  TYPE aqs_tindx,
           l_mode         TYPE i,
           lt_clogsg      TYPE aqtclsg,
           lt_dbsa        TYPE aqtdbsa,
           lt_dbob        TYPE aqtdbob,
           lt_dbos        TYPE aqtdbos,
           lt_dbif        TYPE aqtdbif,
           lt_dbsf        TYPE aqtdbsf,
           lt_dbsg        TYPE aqtdbsg,
           lt_dban        TYPE aqtdban,
           lt_dbjt        TYPE aqtdbjt,
           lt_dbjc        TYPE aqtdbjc,
           lt_dbzt        TYPE aqtdbzt,
           lt_dbzc        TYPE aqtdbzc,
           lt_dbzl        TYPE aqtdbzl,
           lt_dbdp        TYPE aqtdbdp_stdkey,
           lt_dbpa        TYPE aqtdbpa,
           lt_dbwr        TYPE aqtdbwr,
           lt_dbar        TYPE aqtdbar,
           lt_dbft        TYPE aqtdbft,
           lt_sgtext      TYPE aqttxsg,
           lt_exdbfi      TYPE aqq_t_exdbfi,
           lt_ttab        TYPE aqq_t_ttab.

    p_join_data_r->get_info( IMPORTING  e_sgname        = l_sgname
                                        e_actworkspace  = l_actworkspace
                                        e_headsg        = l_headsg
                                        e_maxsg_tindx   = l_maxsg_tindx
                                        e_mode          = l_mode
                                        et_dbdp         = lt_dbdp
                                        et_dbpa         = lt_dbpa
                                        et_dbwr         = lt_dbwr
                                        et_dbar         = lt_dbar
                                        et_dbft         = lt_dbft
                                        et_sgtext       = lt_sgtext
                                        et_exdbfi       = lt_exdbfi
                                        et_ttab         = lt_ttab
                                        et_dbzl         = lt_dbzl
                                        et_clogsg       = lt_clogsg
                                        et_dbsa         = lt_dbsa
                                        et_dbob         = lt_dbob
                                        et_dbos         = lt_dbos
                                        et_dbif         = lt_dbif
                                        et_dbsf         = lt_dbsf
                                        et_dbsg         = lt_dbsg
                                        et_dban         = lt_dban
                                        et_dbjt         = lt_dbjt
                                        et_dbjc         = lt_dbjc
                                        et_dbzt         = lt_dbzt
                                        et_dbzc         = lt_dbzc ).
* MS38OF81
* check_ddic_interface
    CALL FUNCTION 'RSAQ_DJ_DEFINE_ALIASTABLES'
      EXPORTING
        sgname_input        = l_sgname
        act_workspace_input = l_actworkspace
      TABLES
        clogsg_input        = lt_clogsg
        dbsa_input          = lt_dbsa
        dbob_input          = lt_dbob
        dbos_input          = lt_dbos
        dbif_input          = lt_dbif
        dbsf_input          = lt_dbsf
        dbsg_input          = lt_dbsg
        dban_input          = lt_dban
        dbjt_input          = lt_dbjt
        dbjc_input          = lt_dbjc
        dbzt_input          = lt_dbzt
        dbzc_input          = lt_dbzc
        dbzl_input          = lt_dbzl
        dbdp_input          = lt_dbdp
        dbpa_input          = lt_dbpa
        dbwr_input          = lt_dbwr
        dbar_input          = lt_dbar
        dbft_input          = lt_dbft
        sgtext_input        = lt_sgtext
        exdbfi_input        = lt_exdbfi
        ttab_input          = lt_ttab
      CHANGING
        headsg_input        = l_headsg
        maxsg_tindx_input   = l_maxsg_tindx
        mode_input          = l_mode.

    p_join_data_r->set_info( EXPORTING  i_sgname       = l_sgname
                                        i_actworkspace = l_actworkspace
                                        i_headsg       = l_headsg
                                        i_maxsg_tindx  = l_maxsg_tindx
                                        i_mode         = l_mode
                                        it_dbdp        = lt_dbdp
                                        it_dbpa        = lt_dbpa
                                        it_dbwr        = lt_dbwr
                                        it_dbar        = lt_dbar
                                        it_dbft        = lt_dbft
                                        it_sgtext      = lt_sgtext
                                        it_exdbfi      = lt_exdbfi
                                        it_ttab        = lt_ttab
                                        it_dbzl        = lt_dbzl
                                        it_clogsg      = lt_clogsg
                                        it_dbsa        = lt_dbsa
                                        it_dbob        = lt_dbob
                                        it_dbos        = lt_dbos
                                        it_dbif        = lt_dbif
                                        it_dbsf        = lt_dbsf
                                        it_dbsg        = lt_dbsg
                                        it_dban        = lt_dban
                                        it_dbjt        = lt_dbjt
                                        it_dbjc        = lt_dbjc
                                        it_dbzt        = lt_dbzt
                                        it_dbzc        = lt_dbzc ).

  ENDMETHOD.                    "aliastable

  METHOD check.

    DATA: l_tname TYPE aqs_tname.

    check_conditions( IMPORTING  e_tname        = l_tname
                      EXCEPTIONS not_right      = 1
                                 zero_tables    = 2
                                 only_one_table = 3 ).

    IF     sy-subrc = 0.
*   Die definierten Join-Bedingungen sind korrekt
      MESSAGE s015(aqqis_cntrl).
    ELSEIF sy-subrc = 1.
*   Tabelle &1 mu# rechte Tabelle in einem Join sein
      MESSAGE s016(aqqis_cntrl) WITH l_tname.
    ELSEIF sy-subrc = 2.
*   Es ist keine Tabelle vorhanden
      MESSAGE s012(aqqis_cntrl).
    ELSEIF sy-subrc = 3.
*   Es ist nur eine Tabelle vorhanden
      MESSAGE s013(aqqis_cntrl).
    ENDIF.

  ENDMETHOD.                    "check



  METHOD cnt_marked_lines_per_tab.

    DATA: l_t_objects    TYPE aqq_t_objects,
          l_lines_marked TYPE i.

    l_t_objects = p_r_join_cntrl->get_selected_objects( ).

    LOOP AT l_t_objects TRANSPORTING NO FIELDS WHERE r_table  EQ ir_table
                                               AND   rowindex NE 0.
      l_lines_marked = l_lines_marked + 1.
    ENDLOOP.

    e_lines_marked = l_lines_marked.

  ENDMETHOD.                    "cnt_marked_lines_per_tab


  METHOD cnt_marked_tabs.

    DATA: l_t_objects   TYPE aqq_t_objects,
          l_lin_objects TYPE i.

    l_t_objects = p_r_join_cntrl->get_selected_objects( ).
* Tabelle
    LOOP AT l_t_objects TRANSPORTING NO FIELDS WHERE NOT r_table IS INITIAL
                                               AND       rowindex = 0.
      l_lin_objects = l_lin_objects + 1.
    ENDLOOP.

    e_marked_tabs = l_lin_objects.
  ENDMETHOD.                    "cnt_marked_tabs

  METHOD cnvt_fname_one_2_two.

    SPLIT i_fname AT '-' INTO e_tname e_fname.
    IF sy-subrc NE 0.
      e_fname = i_fname.
    ENDIF.

  ENDMETHOD.                    "cnvt_fname_one_2_two

  METHOD cnvt_tables_to_new.

    DATA: lt_dbjt   TYPE aqtdbjt,
          ls_dbjt   TYPE aqdbjt,
          lt_dbjc   TYPE aqtdbjc,
          ls_dbjc   TYPE aqdbjc,
          lt_tpos   TYPE aqq_t_tpos,
          ls_tpos   TYPE aqq_s_tpos,
          lt_tfield TYPE aqq_t_tfield,
          ls_tfield TYPE aqstfield,
          lt_join   TYPE aqq_t_join,
          ls_join   TYPE aqq_s_join,
          l_tabix   TYPE sytabix.

    p_join_data_r->get_info( IMPORTING et_dbjt = lt_dbjt
                                       et_dbjc = lt_dbjc ).
* set tables & fields.
* set tfields table, load table infos.

    LOOP AT lt_dbjt INTO ls_dbjt.
      l_tabix = sy-tabix.

      ls_tfield-tabname = ls_dbjt-table.
* set positions in tpos.
      CLEAR ls_tpos.
      ls_tpos-tabname = ls_dbjt-table.

*   ls_dbjt-left_vz    => k#nnen auch negative Werte enthalten, ohne _vz
*   ls_dbjt-top_vz        sind nur positive Werte m#glich
*   ls_dbjt-width_vz
*   ls_dbjt-heigth_vz
      IF ls_dbjt-left_vz    IS INITIAL AND
         ls_dbjt-top_vz     IS INITIAL AND
         ls_dbjt-width_vz   IS INITIAL AND
         ls_dbjt-height_vz  IS INITIAL.

        IF ( i_first_table_apos = aqqis_c_true AND sy-tabix = 1 ).
          ls_tpos-xpos = 50.
          ls_tpos-ypos = 50.
          IF  NOT ( ls_dbjt-width IS INITIAL ).
            ls_tpos-width  = ls_dbjt-width_vz  = ls_dbjt-width.
            ls_tpos-height = ls_dbjt-height_vz = ls_dbjt-height.
          ENDIF.
          APPEND ls_tpos TO lt_tpos.
        ELSE.
          IF  NOT ( ls_dbjt-top IS INITIAL ).
            ls_tpos-xpos = ls_dbjt-left_vz = ls_dbjt-left.
            ls_tpos-ypos = ls_dbjt-top_vz  = ls_dbjt-top.
          ENDIF.
          IF  NOT ( ls_dbjt-width IS INITIAL ).
            ls_tpos-width  = ls_dbjt-width_vz  = ls_dbjt-width.
            ls_tpos-height = ls_dbjt-height_vz = ls_dbjt-height.
          ENDIF.
          APPEND ls_tpos TO lt_tpos.
        ENDIF.
        MODIFY lt_dbjt FROM ls_dbjt INDEX l_tabix.
        p_join_data_r->set_info( EXPORTING it_dbjt = lt_dbjt ).
      ELSE.

        IF ( i_first_table_apos = aqqis_c_true AND sy-tabix = 1 ).
          ls_tpos-xpos = 50.
          ls_tpos-ypos = 50.
          IF  NOT ( ls_dbjt-width_vz IS INITIAL ).
            ls_tpos-width  = ls_dbjt-width_vz.
            ls_tpos-height = ls_dbjt-height_vz.
          ENDIF.
          APPEND ls_tpos TO lt_tpos.
        ELSE.
          IF  NOT ( ls_dbjt-top_vz IS INITIAL ).
            ls_tpos-xpos = ls_dbjt-left_vz.
            ls_tpos-ypos = ls_dbjt-top_vz.
          ENDIF.
          IF  NOT ( ls_dbjt-width_vz IS INITIAL ).
            ls_tpos-width  = ls_dbjt-width_vz.
            ls_tpos-height = ls_dbjt-height_vz.
          ENDIF.
          APPEND ls_tpos TO lt_tpos.
        ENDIF.

      ENDIF.

* get object tabobj with fieldinfos for fields of table.
*  (like former ltab/rtab, (= includes Dictionary & type information)
*  but now: for all tables in join!
*  tabstore stores these objects and manages them.
      DATA:   lt_ltab TYPE aqqis_t_tab,
              ls_ltab TYPE aqqis_s_tab.

      get_tab( EXPORTING i_tabname  = ls_dbjt-table
               IMPORTING et_tab     = lt_ltab ).

      LOOP AT lt_ltab INTO ls_ltab.
        ls_tfield-colname = ls_ltab-feld.
        IF ( ls_ltab-key = aqqis_c_true ).
          ls_tfield-iskey = 1.
        ELSE.
          ls_tfield-iskey = 0.
        ENDIF.
        APPEND ls_tfield TO lt_tfield.
      ENDLOOP.
    ENDLOOP.

* joins:
    ls_join-op   = aqqis_c_join_typ-inner.

    LOOP AT lt_dbjc INTO ls_dbjc.
* we look only for join-conditions:
      IF ls_dbjc-jind IS INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE lt_dbjt TRANSPORTING NO FIELDS WITH KEY table =  ls_dbjc-rtable.
      IF sy-subrc <> 0 OR sy-tabix = 1.
        ls_dbjt-outerflag = aqqis_c_join-inner.
      ELSE.

        DATA: l_i TYPE i.
        l_i = sy-tabix - 1.
        READ TABLE lt_dbjt INTO ls_dbjt INDEX l_i.
      ENDIF.

* the table is used in a left outer join if the PRECEDING table
* of the right table
* has marked an 'L' in dbjt.
      IF ( ls_dbjt-outerflag <> aqqis_c_join-left_outer ).
        ls_join-type = aqqis_c_join_typ-inner.
      ELSE.
        ls_join-type = aqqis_c_join_typ-left_outer.
      ENDIF.
* set tables
      ls_join-tabnamer = ls_dbjc-rtable.
      ls_join-tabnamel = ls_dbjc-ltable.

* determine colnames!
      ls_join-colnamel = ls_dbjc-lname.
      SHIFT ls_join-colnamel UP TO '-'. SHIFT ls_join-colnamel.
      ls_join-colnamer = ls_dbjc-rname.
      SHIFT ls_join-colnamer UP TO '-'. SHIFT ls_join-colnamer.

      APPEND ls_join TO lt_join.
    ENDLOOP.

    pt_join[]   = lt_join[].
    pt_tpos[]   = lt_tpos[].
    pt_tfield[] = lt_tfield[].
  ENDMETHOD.                    "cnvt_tables_to_new

  METHOD cnvt_table_to_old.

    cnvt_table_to_old_dbjt( ).
    cnvt_table_to_old_dbjc( ).

  ENDMETHOD.                    "cnvt_table_to_old

  METHOD cnvt_table_to_old_dbjc.

    DATA: l_cnt   TYPE i VALUE 0,
          ls_join TYPE aqq_s_join,
          lt_join TYPE aqq_t_join,
          ls_dbjc TYPE aqdbjc,
          lt_dbjc TYPE aqtdbjc.

    lt_join[]   = pt_join[].

* clear table dbjc:
    REFRESH lt_dbjc.
* add all tables:
    LOOP AT lt_join INTO ls_join.
      CLEAR ls_dbjc.
      ls_dbjc-rtable = ls_join-tabnamer.
      ls_dbjc-ltable = ls_join-tabnamel.
      COLLECT ls_dbjc INTO lt_dbjc.
    ENDLOOP.

* add all the joins:
* copy all join-conditions. generate index.
    SORT lt_join BY tabnamel tabnamer colnamel.
    LOOP AT lt_join INTO ls_join.
      AT NEW tabnamel.
        l_cnt = 0.
      ENDAT.

      l_cnt = l_cnt + 1.
      WRITE l_cnt TO ls_dbjc-jind(2).
      ls_dbjc-ltable = ls_join-tabnamel.
      CONCATENATE ls_dbjc-ltable '-' ls_join-colnamel INTO ls_dbjc-lname.
      ls_dbjc-rtable = ls_join-tabnamer.
      CONCATENATE ls_dbjc-rtable '-' ls_join-colnamer INTO ls_dbjc-rname.
      APPEND ls_dbjc TO lt_dbjc.
    ENDLOOP.
* copy all join-conditions. generate index.

    p_join_data_r->set_info( EXPORTING it_dbjc = lt_dbjc ).

  ENDMETHOD.                    "cnvt_table_to_old_dbjc

  METHOD cnvt_table_to_old_dbjt.

    DATA: l_anz   TYPE int4,
          l_o     TYPE int4,
          l_cnt   TYPE i VALUE 0,
          ls_join TYPE aqq_s_join,
          lt_join TYPE aqq_t_join,
          ls_dbjt TYPE aqdbjt,
          lt_dbjt TYPE aqtdbjt,
          ls_tpos TYPE aqq_s_tpos,
          lt_tpos TYPE aqq_t_tpos.

    lt_tpos[]   = pt_tpos[].
    lt_join[]   = pt_join[].

    REFRESH lt_dbjt.

    SORT lt_tpos BY xpos.
    DESCRIBE TABLE lt_tpos LINES l_anz.

    LOOP AT lt_tpos INTO ls_tpos.
      l_o = sy-tabix + 1.
      ls_dbjt-table     = ls_tpos-tabname.
      ls_dbjt-outerflag = ' '.
      ls_dbjt-top_vz       = ls_tpos-ypos.
      ls_dbjt-left_vz      = ls_tpos-xpos.
      ls_dbjt-width_vz     = ls_tpos-width.
      ls_dbjt-height_vz    = ls_tpos-height.

      IF l_o <= l_anz.
        READ TABLE lt_tpos INTO ls_tpos INDEX l_o.
        READ TABLE lt_join INTO ls_join WITH KEY tabnamer = ls_tpos. " next table is:
        IF ls_join-type = '1'.
          ls_dbjt-outerflag = aqqis_c_join-left_outer.
        ELSE.
          ls_dbjt-outerflag = aqqis_c_join-inner.
        ENDIF.
      ENDIF.
      APPEND ls_dbjt TO lt_dbjt.
    ENDLOOP.

* clear flag in last join.
    DESCRIBE TABLE lt_dbjt LINES l_cnt.
    READ TABLE lt_dbjt INTO ls_dbjt INDEX l_cnt.
    IF l_cnt > 0 .
      CLEAR: ls_dbjt-outerflag.
      MODIFY lt_dbjt FROM ls_dbjt INDEX l_cnt.
    ENDIF.

    p_join_data_r->set_info( EXPORTING it_dbjt = lt_dbjt ).

  ENDMETHOD.                    "cnvt_table_to_old_dbjt


  METHOD create_link.

    DATA: l_r_link TYPE REF TO if_aqqgraphic_link,
          l_s_link TYPE     aqslinkjoi,
          l_text   TYPE     aqq_text,
          l_rowl   TYPE     int2,
          l_rowr   TYPE     int2.

    FIELD-SYMBOLS: <tobj_join_l> TYPE aqstobjjoi,
                   <tobj_join_r> TYPE aqstobjjoi,
                   <fobj_join_l> TYPE aqsfobjjoi,
                   <fobj_join_r> TYPE aqsfobjjoi.

    l_rowl = i_rowl.
    l_rowr = i_rowr.

    l_r_link = p_r_join_cntrl->get_new_link( ).

    l_r_link->set_attributes( EXPORTING i_moveable     = aqqis_c_true
*                                     I_SELECTABLE   = aqqis_C_TRUE
                                        i_editable     = aqqis_c_false
*                                     I_MOUSEOVER    = aqqis_C_TRUE
*                                     I_ELBOWLINK    = aqqis_C_FALSE
*                                     I_ANGLELINK    = aqqis_C_TRUE
*                                     I_BUNCHLINK    = aqqis_C_FALSE
*                                     I_SIMPLELINK   = aqqis_C_FALSE
*                                     I_DESMERGELINK = aqqis_C_TRUE
    ).

    l_r_link->set_status( ).

    l_text = fetch_outerflag_text( ir_tabl  = ir_tabl
                                   ir_tabr  = ir_tabr ).

    l_r_link->set_properties( EXPORTING i_linkstyle = p_default_linkstyle
                                        i_text      = l_text ).

*   set left and right table of link
    l_r_link->set_predecessor( EXPORTING i_r_table  = ir_tabl
                                         i_rowindex = l_rowl ) .
    l_r_link->set_successor( EXPORTING i_r_table  = ir_tabr
                                       i_rowindex = l_rowr ) .

    READ TABLE p_t_tobj_join ASSIGNING <tobj_join_l> WITH KEY tabref = ir_tabl.
    READ TABLE <tobj_join_l>-fobj ASSIGNING <fobj_join_l> INDEX i_rowl.
    READ TABLE p_t_tobj_join ASSIGNING <tobj_join_r> WITH KEY tabref = ir_tabr.
    READ TABLE <tobj_join_r>-fobj ASSIGNING <fobj_join_r> INDEX i_rowr.

*   add link to attribute
    CLEAR l_s_link.
    l_s_link-tnameleft   = <tobj_join_l>-tname.
    CONCATENATE <tobj_join_l>-tname '-' <fobj_join_l>-fname INTO l_s_link-fnameleft.
    l_s_link-tnameright  = <tobj_join_r>-tname.
    CONCATENATE <tobj_join_r>-tname '-' <fobj_join_r>-fname INTO l_s_link-fnameright.
    l_s_link-linkref      = l_r_link.

    APPEND l_s_link TO p_t_links_join.

*   add link to control
    p_r_join_cntrl->add_link( i_r_link = l_r_link ).

  ENDMETHOD.                    "create_link

  METHOD create_links.

    DATA: l_tabref_left  TYPE REF TO if_aqqgraphic_table,
          l_tabref_right TYPE REF TO if_aqqgraphic_table,
          l_tabix_left   TYPE        sytabix,
          l_tabix_right  TYPE        sytabix,
          l_tname_left   TYPE        aqs_tname,
          l_tname_right  TYPE        aqs_tname,
          l_s_tobj_join  TYPE        aqstobjjoi,
          l_r_link       TYPE REF TO if_aqqgraphic_link,
          lt_join        TYPE        aqq_t_join.

    FIELD-SYMBOLS: <join> TYPE aqq_s_join.

    lt_join[] = it_join[].
*  p_join_data_r->get_info( importing et_dbjc = lt_dbjc ).

    LOOP AT lt_join ASSIGNING <join>.
      CHECK NOT <join>-tabnamel IS INITIAL AND NOT <join>-tabnamer IS INITIAL.

* 1. Seite
      READ TABLE p_t_tobj_join INTO l_s_tobj_join WITH KEY tname = <join>-tabnamel.
      CHECK sy-subrc = 0.
      READ TABLE l_s_tobj_join-fobj WITH KEY fname = <join>-colnamel TRANSPORTING NO FIELDS.
      CHECK sy-subrc = 0.

      l_tname_left  = l_s_tobj_join-tname.
      l_tabix_left  = sy-tabix.
      l_tabref_left = l_s_tobj_join-tabref.

* 2. Seite
      READ TABLE p_t_tobj_join INTO l_s_tobj_join WITH KEY tname = <join>-tabnamer.
      CHECK sy-subrc = 0.
      READ TABLE l_s_tobj_join-fobj WITH KEY fname = <join>-colnamer TRANSPORTING NO FIELDS.
      CHECK sy-subrc = 0.

      l_tname_right  = l_s_tobj_join-tname.
      l_tabix_right  = sy-tabix.
      l_tabref_right = l_s_tobj_join-tabref.

*   create link object
      create_link( EXPORTING ir_tabl = l_tabref_left
                             ir_tabr = l_tabref_right
                             i_rowl  = l_tabix_left
                             i_rowr  = l_tabix_right ).
    ENDLOOP.
  ENDMETHOD.                    "create_links

  METHOD display_ddic.

    DATA: l_s_tobj_join TYPE aqstobjjoi,
          l_s_fobj      TYPE aqsfobjjoi,
          lt_tab        TYPE aqq_t_tab,
          l_ref         TYPE flag,
          ls_exdbfi     TYPE aqsexdbfi,
          lt_exdbfi     TYPE aqq_t_exdbfi,
          l_objname     TYPE ddobjname,
          l_objtype     TYPE ddeutype,
          lt_dban       TYPE aqtdban.

    FIELD-SYMBOLS: <dban> TYPE aqdban,
                   <tab>  TYPE aqq_s_tab.

    IF NOT ir_table IS INITIAL.
      READ TABLE p_t_tobj_join INTO l_s_tobj_join WITH KEY tabref = ir_table.
      CHECK sy-subrc = 0.

      get_tab( EXPORTING i_tabname = l_s_tobj_join-tname
               IMPORTING et_tab    = lt_tab ).

      READ TABLE lt_tab ASSIGNING <tab> WITH KEY feld = l_s_fobj-fname.

      p_join_data_r->get_info( IMPORTING et_dban = lt_dban ).

      l_objname = l_s_tobj_join-tname.

      READ TABLE lt_dban ASSIGNING <dban> WITH KEY alias = l_objname.
      IF sy-subrc = 0.
        l_objname = <dban>-table.
      ENDIF.

      l_objtype = 'T'.
      CALL FUNCTION 'RS_DD_SHOW'
        EXPORTING
          objname              = l_objname
          objtype              = l_objtype
*         POPUP                = ' '
*         SECNAME              =
*         MONITOR_ACTIVATE     = 'X'
*       IMPORTING
*         FCODE                =
        EXCEPTIONS
          object_not_found     = 1
          object_not_specified = 2
          permission_failure   = 3
          type_not_valid       = 4.

    ENDIF.

  ENDMETHOD.                    "display_ddic

  METHOD execute_join_modification.

    DATA: ls_join TYPE aqq_s_join,
          l_text  TYPE aqq_text.

    FIELD-SYMBOLS: <links_join> TYPE aqslinkjoi.

* Text f#r den link
    CASE is_join-type.
      WHEN aqqis_c_join_typ-inner.
      WHEN aqqis_c_join_typ-left_outer.
        l_text = text-013.  "left outer join
      WHEN OTHERS.
    ENDCASE.

* pt_join aktualisieren
    LOOP AT pt_join INTO ls_join WHERE tabnamer = is_join-tabnamer.
      ls_join-type = is_join-type.
      MODIFY pt_join FROM ls_join.
    ENDLOOP.

* aktuellen link ans frontend senden
    LOOP AT p_t_links_join ASSIGNING <links_join> WHERE tnameleft  = is_join-tabnamel
                                                    AND tnameright = is_join-tabnamer.

      <links_join>-linkref->set_properties( i_linkstyle = p_default_linkstyle
                                            i_text      = l_text ).
      p_r_join_cntrl->add_link( i_r_link = <links_join>-linkref ).
    ENDLOOP.
    p_r_join_cntrl->send_data_to_frontend( ).

* Tabellen konvertieren
    cnvt_table_to_old( ).

  ENDMETHOD.                    "execute_join_modification

  METHOD fetch_outerflag_text.

    FIELD-SYMBOLS: <tobj_join_l> TYPE aqstobjjoi,
                   <tobj_join_r> TYPE aqstobjjoi,
                   <join>        TYPE aqq_s_join.

    READ TABLE p_t_tobj_join ASSIGNING <tobj_join_l> WITH KEY tabref = ir_tabl.
    READ TABLE p_t_tobj_join ASSIGNING <tobj_join_r> WITH KEY tabref = ir_tabr.

    READ TABLE pt_join ASSIGNING <join> WITH KEY tabnamel = <tobj_join_l>-tname
                                                 tabnamer = <tobj_join_r>-tname.

    IF     <join>-type = aqqis_c_join_typ-inner.

    ELSEIF <join>-type = aqqis_c_join_typ-left_outer.
      r_text = text-013.
    ENDIF.

  ENDMETHOD.                    "fetch_outerflag_text


  METHOD fielddocu.
    DATA: l_s_tobj_join TYPE aqstobjjoi,
          l_s_fobj      TYPE aqsfobjjoi,
          lt_tab        TYPE aqq_t_tab,
          ls_exdbfi     TYPE aqsexdbfi,
          lt_exdbfi     TYPE aqq_t_exdbfi.

    DATA: lr_table       TYPE REF TO if_aqqgraphic_table.
    DATA: l_t_objects    TYPE aqq_t_objects,
          l_lin_objects  TYPE i,
          l_lines_marked TYPE i,
          l_row          TYPE sytabix.

    FIELD-SYMBOLS: <tab>       TYPE aqq_s_tab.
    FIELD-SYMBOLS: <objects>   TYPE aqsobjects.
    FIELD-SYMBOLS: <lines>     TYPE aqsobjects.

    IF ir_table IS INITIAL.

      IF cnt_marked_tabs( ) = 0.
*     Kein Objekt markiert.
        MESSAGE s006(aqqis_cntrl).
        EXIT.
      ELSEIF cnt_marked_tabs( ) > 1.
*     Mehrere Objekte markiert
        MESSAGE s007(aqqis_cntrl).
        EXIT.
      ENDIF.

      l_t_objects = p_r_join_cntrl->get_selected_objects( ).
      READ TABLE l_t_objects ASSIGNING <objects> WITH KEY rowindex = 0.
      IF sy-subrc = 0.
        lr_table = <objects>-r_table.
      ENDIF.

      IF cnt_marked_lines_per_tab( lr_table ) = 0.
*     Keine Tabellenzeile markiert
        MESSAGE s033(aqqis_cntrl).
        EXIT.
      ELSEIF cnt_marked_lines_per_tab( lr_table ) > 1.
*     Mehr ale eine Tabellenzeile markiert
        MESSAGE s034(aqqis_cntrl).
        EXIT.
      ENDIF.

      LOOP AT l_t_objects ASSIGNING <lines> WHERE rowindex NE 0.
      ENDLOOP.
      IF sy-subrc = 0.
        l_row = <lines>-rowindex.
      ENDIF.
    ELSE.
      lr_table = ir_table.
      l_row    = i_row.
    ENDIF.

    IF NOT lr_table IS INITIAL.
      READ TABLE p_t_tobj_join INTO l_s_tobj_join WITH KEY tabref = lr_table.
      CHECK sy-subrc = 0.

      READ TABLE l_s_tobj_join-fobj INTO l_s_fobj INDEX l_row.
      CHECK sy-subrc = 0.

      get_tab( EXPORTING i_tabname = l_s_tobj_join-tname
               IMPORTING et_tab    = lt_tab ).

      READ TABLE lt_tab ASSIGNING <tab> WITH KEY feld = l_s_fobj-fname.

      CALL FUNCTION 'RSAQ_CNTRL_BUILD_EXDBFI'
        EXPORTING
          i_tab     = l_s_tobj_join-tname
        IMPORTING
          et_exdbfi = lt_exdbfi.

      READ TABLE lt_exdbfi INTO ls_exdbfi WITH KEY ddic-fieldname = <tab>-feld.

      CALL FUNCTION 'RSAQ_CNTRL_FIELD_DOCU'
        EXPORTING
          is_exdbfi = ls_exdbfi.
    ENDIF.

  ENDMETHOD.                    "fielddocu

  METHOD fieldreference.

    DATA: l_s_tobj_join TYPE aqstobjjoi,
          l_s_fobj      TYPE aqsfobjjoi,
          lt_tab        TYPE aqq_t_tab,
          ls_exdbfi     TYPE aqsexdbfi,
          lt_exdbfi     TYPE aqq_t_exdbfi.

    DATA: lr_table       TYPE REF TO if_aqqgraphic_table.
    DATA: l_t_objects    TYPE aqq_t_objects,
          l_lin_objects  TYPE i,
          l_lines_marked TYPE i,
          l_row          TYPE sytabix.

    FIELD-SYMBOLS: <tab>       TYPE aqq_s_tab.
    FIELD-SYMBOLS: <objects>   TYPE aqsobjects.
    FIELD-SYMBOLS: <lines>     TYPE aqsobjects.

    IF ir_table IS INITIAL.
      IF cnt_marked_tabs( ) = 0.
*     Kein Objekt markiert.
        MESSAGE s006(aqqis_cntrl).
        EXIT.
      ELSEIF cnt_marked_tabs( ) > 1.
*     Mehrere Objekte markiert
        MESSAGE s007(aqqis_cntrl).
        EXIT.
      ENDIF.

      l_t_objects = p_r_join_cntrl->get_selected_objects( ).
      READ TABLE l_t_objects ASSIGNING <objects> WITH KEY rowindex = 0.
      IF sy-subrc = 0.
        lr_table = <objects>-r_table.
      ENDIF.

      IF cnt_marked_lines_per_tab( lr_table ) = 0.
*     Keine Tabellenzeile markiert
        MESSAGE s033(aqqis_cntrl).
        EXIT.
      ELSEIF cnt_marked_lines_per_tab( lr_table ) > 1.
*     Mehr ale eine Tabellenzeile markiert
        MESSAGE s034(aqqis_cntrl).
        EXIT.
      ENDIF.

      LOOP AT l_t_objects ASSIGNING <lines> WHERE rowindex NE 0.
      ENDLOOP.
      IF sy-subrc = 0.
        l_row = <lines>-rowindex.
      ENDIF.
    ELSE.
      lr_table = ir_table.
      l_row    = i_row.
    ENDIF.

    IF NOT lr_table IS INITIAL.
      READ TABLE p_t_tobj_join INTO l_s_tobj_join WITH KEY tabref = lr_table.
      CHECK sy-subrc = 0.

      READ TABLE l_s_tobj_join-fobj INTO l_s_fobj INDEX l_row.
      CHECK sy-subrc = 0.

      get_tab( EXPORTING i_tabname = l_s_tobj_join-tname
               IMPORTING et_tab    = lt_tab ).

      READ TABLE lt_tab ASSIGNING <tab> WITH KEY feld = l_s_fobj-fname.

      referenzfield( is_tab  = <tab>
                     i_tname = l_s_tobj_join-tname ).

    ENDIF.
  ENDMETHOD.                    "fieldreference

  METHOD fill_table_fields.

    DATA: lt_ttab       TYPE aqq_t_ttab,
          l_s_tobj_join TYPE aqstobjjoi,
          l_s_fobj_join TYPE aqsfobjjoi,
          ls_tpos_abs   TYPE aqstposabs,
          lt_tab        TYPE aqq_t_tab.

    FIELD-SYMBOLS: <ttab> TYPE aqq_s_ttab,
                   <tab>  TYPE aqq_s_tab.

    p_join_data_r->get_info( IMPORTING et_ttab   = lt_ttab ).

    get_tab( EXPORTING i_tabname = is_dbjt-table
             IMPORTING et_tab    = lt_tab ).

    CLEAR: l_s_tobj_join.
* Tabellenname
    l_s_tobj_join-tname   = is_dbjt-table.

* Tabellenreferenz
    l_s_tobj_join-tabref  = p_r_join_cntrl->get_new_table( ).

* Titel, tooltip
    READ TABLE lt_ttab ASSIGNING <ttab> WITH KEY ddic-tabname  = is_dbjt-table.
    IF sy-subrc = 0.
      CONCATENATE is_dbjt-table ':' <ttab>-ddic-ddtext INTO l_s_tobj_join-title SEPARATED BY space.
    ELSE.
      l_s_tobj_join-title = is_dbjt-table.
    ENDIF.
    l_s_tobj_join-tooltip = l_s_tobj_join-title.

* Positionen
    rel_2_abs( EXPORTING is_dbjt     = is_dbjt
               IMPORTING es_tpos_abs = ls_tpos_abs ).
    MOVE-CORRESPONDING ls_tpos_abs TO l_s_tobj_join-tpos.

*--- Felder, tiefe Struktur
    LOOP AT lt_tab ASSIGNING <tab>.

      CLEAR: l_s_fobj_join.
      IF <tab>-key = aqqis_c_true.
        l_s_fobj_join-keyicon = icon_foreign_key.           "1. Spalte
      ENDIF.
      l_s_fobj_join-fname = <tab>-feld.                     "2. Spalte
      l_s_fobj_join-txtlg = <tab>-ftext.                    "3. Spalte
      APPEND l_s_fobj_join TO l_s_tobj_join-fobj[].


    ENDLOOP.

    es_tobj_join = l_s_tobj_join.
  ENDMETHOD.                    "fill_table_fields


  METHOD force_jointype.

* change_old = 'X' : new jointype is used to CHANGE Data of other Joins linking table!
* change_old = ' ' : jointype of new join is set back.

    DATA: l_wa_join TYPE aqq_s_join.
    IF i_change_old = aqqis_c_true.
      LOOP AT pt_join INTO l_wa_join WHERE tabnamer = cs_join-tabnamer.
        l_wa_join-type = cs_join-type.
        MODIFY pt_join FROM l_wa_join.
      ENDLOOP.
    ELSE.                              " change new jointype backwards:
      LOOP AT pt_join INTO l_wa_join WHERE   tabnamer =  cs_join-tabnamer
                                     AND (   tabnamel <> cs_join-tabnamel
                                          OR colnamer <> cs_join-colnamer
                                          OR colnamel <> cs_join-colnamel ).

        cs_join-type = l_wa_join-type.
        EXIT.
      ENDLOOP.

      IF sy-subrc <> 0.
        RAISE inconsistent.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "force_jointype

  METHOD get_selected_link.
    DATA:   lt_objects    TYPE aqq_t_objects.
    lt_objects = p_r_join_cntrl->get_selected_objects( ).
    e_link = lt_objects.
  ENDMETHOD.                    "get_selected_link

  METHOD get_selected_table.

    DATA:   lt_objects    TYPE aqq_t_objects,
            l_lin_objects TYPE i,
            lt_dbjt       TYPE aqtdbjt.

    FIELD-SYMBOLS: <objects>   TYPE aqsobjects,
                   <tobj_join> TYPE aqstobjjoi.

    p_join_data_r->get_info( IMPORTING et_dbjt = lt_dbjt ).

    lt_objects = p_r_join_cntrl->get_selected_objects( ).

* wenn nur ein Objekt auf dem Control markiert ist, dann wird der Name dieser
* Tabelle in die obere dropdown-Box gestellt - sind mehrere Objekte markiert oder
* gar keins, dann bleibt dieses Feld inital
    LOOP AT lt_objects TRANSPORTING NO FIELDS WHERE NOT r_table IS INITIAL.
      l_lin_objects = l_lin_objects + 1.
    ENDLOOP.

    IF     l_lin_objects = 0.
      RAISE no_table_selected.
    ELSEIF l_lin_objects = 1.
      READ TABLE lt_objects ASSIGNING <objects> INDEX 1.
      READ TABLE p_t_tobj_join ASSIGNING <tobj_join> WITH KEY tabref = <objects>-r_table.
      e_tname = <tobj_join>-tname.
    ELSE.
      RAISE several_tables_selected.
    ENDIF.

  ENDMETHOD.                    "get_selected_table

  METHOD get_tab.

    DATA: l_tabname TYPE aqs_tname,
          lt_dban   TYPE aqtdban,
*>>>---zaaqb
          wa_tab    LIKE LINE OF et_tab,
          et_tab_t  TYPE aqqis_t_tab.
*<<<---zaaqb
    FIELD-SYMBOLS: <dban> TYPE aqdban.

    p_join_data_r->get_info( IMPORTING et_dban = lt_dban ).
    READ TABLE lt_dban ASSIGNING <dban> WITH KEY alias = i_tabname.
    IF sy-subrc = 0.
      l_tabname = <dban>-table.
    ELSE.
      l_tabname = i_tabname.
    ENDIF.
    PERFORM fill_join_tab IN PROGRAM saplaqjd TABLES et_tab
                                              USING  l_tabname.
*>>>---zaaqb
    LOOP AT et_tab INTO wa_tab.
      READ TABLE zaaqb_key_word WITH KEY table = wa_tab-feld TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND wa_tab TO et_tab_t.
      ENDIF.
    ENDLOOP.

    REFRESH et_tab.
    APPEND LINES OF et_tab_t TO et_tab.
*<<<---zaaqb
  ENDMETHOD.                    "get_tab


  METHOD handle_link_changed.

    DATA: ls_link       TYPE aqslinkjoi,
          lt_join_sav   TYPE aqq_t_join,
          ls_join       TYPE aqq_s_join,
          l_tname_new   TYPE aqs_tname,
          l_tname_kept  TYPE aqs_tname,
          l_fname_new   TYPE aqs_fname,
          l_fname_kept  TYPE aqs_fname,
          l_link_index  TYPE sytabix,
          l_fname_akt_r TYPE aqs_fname,
          l_tname_akt_r TYPE aqs_tname,
          l_fname_akt_l TYPE aqs_fname,
          l_tname_akt_l TYPE aqs_fname.

    FIELD-SYMBOLS: <tobj_join_new>  TYPE aqstobjjoi,
                   <tobj_join_kept> TYPE aqstobjjoi,
                   <fobj_join_new>  TYPE aqsfobjjoi,
                   <fobj_join_kept> TYPE aqsfobjjoi,
                   <join>           TYPE aqq_s_join.

    READ TABLE p_t_links_join INTO ls_link WITH KEY linkref = i_r_link.
    CHECK sy-subrc = 0.
    l_link_index   = sy-tabix.

* betroffene Felder holen
* urspr#nglicher link
    SPLIT ls_link-fnameleft  AT '-' INTO l_tname_akt_l l_fname_akt_l.
    SPLIT ls_link-fnameright AT '-' INTO l_tname_akt_r l_fname_akt_r.

* neues Ende
    READ TABLE p_t_tobj_join ASSIGNING <tobj_join_new> WITH KEY tabref = i_r_tab_new.
    READ TABLE <tobj_join_new>-fobj ASSIGNING <fobj_join_new> INDEX i_row_new.
    l_tname_new = <tobj_join_new>-tname.
    CONCATENATE l_tname_new '-' <fobj_join_new>-fname INTO l_fname_new.

* altes Ende
    READ TABLE p_t_tobj_join ASSIGNING <tobj_join_kept> WITH KEY tabref = i_r_tab_kept.
    READ TABLE <tobj_join_kept>-fobj ASSIGNING <fobj_join_kept> INDEX i_row_kept.
    l_tname_kept = <tobj_join_kept>-tname.
    CONCATENATE l_tname_kept '-' <fobj_join_kept>-fname INTO l_fname_kept.

* vorhandenen Link aus Datentabelle l#schen, sofern vorhanden
* wenn is_valid_link auf false pr#ft, wird der eben gel#schte link wieder in die
* Datentabelle eingef#gt
    lt_join_sav[] = pt_join[].
    READ TABLE pt_join[] WITH KEY tabnamel = l_tname_akt_l
                                  colnamel = l_fname_akt_l
                                  tabnamer = l_tname_akt_r
                                  colnamer = l_fname_akt_r
                                  TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      DELETE pt_join INDEX sy-tabix.
    ELSE.
      READ TABLE pt_join[] WITH KEY tabnamel = l_tname_akt_r
                                    colnamel = l_fname_akt_r
                                    tabnamer = l_tname_akt_l
                                    colnamer = l_fname_akt_l
                                    TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        DELETE pt_join INDEX sy-tabix.
      ENDIF.
    ENDIF.


* check new link
    IF i_succ_changed = aqqis_c_true.
      is_valid_link( EXPORTING i_r_succtab = i_r_tab_new
                               i_succrow   = i_row_new
                               i_r_predtab = i_r_tab_kept
                               i_predrow   = i_row_kept
                     IMPORTING e_valid     = r_ok ).
    ELSE.
      is_valid_link( EXPORTING i_r_succtab = i_r_tab_kept
                               i_succrow   = i_row_kept
                               i_r_predtab = i_r_tab_new
                               i_predrow   = i_row_new
                     IMPORTING e_valid     = r_ok ).
    ENDIF.

    IF r_ok = aqqis_c_true.
* p_t_links_join
      IF l_fname_kept = ls_link-fnameleft.
        ls_link-fnameright = l_fname_new.
        ls_link-tnameright = l_tname_new.
        MODIFY p_t_links_join FROM ls_link INDEX l_link_index TRANSPORTING fnameright tnameright.

        READ TABLE pt_join ASSIGNING <join> WITH KEY tabnamer = l_tname_new
                                                     tabnamel = l_tname_kept.
        IF sy-subrc = 0.
          ls_join-type = <join>-type.
        ENDIF.
        ls_join-tabnamer = l_tname_new.
        ls_join-colnamer = <fobj_join_new>-fname.
        ls_join-tabnamel = l_tname_kept.
        ls_join-colnamel = <fobj_join_kept>-fname.
        APPEND ls_join TO pt_join.
      ELSEIF l_fname_kept = ls_link-fnameright.
        READ TABLE pt_join ASSIGNING <join> WITH KEY tabnamel = l_tname_new
                                                     tabnamer = l_tname_kept.
        IF sy-subrc = 0.
          ls_join-type = <join>-type.
        ENDIF.
        ls_link-fnameleft = l_fname_new.
        ls_link-tnameleft = l_tname_new.
        MODIFY p_t_links_join FROM ls_link INDEX l_link_index TRANSPORTING fnameleft tnameleft.

        ls_join-tabnamel = l_tname_new.
        ls_join-colnamel = <fobj_join_new>-fname.
        ls_join-tabnamer = l_tname_kept.
        ls_join-colnamer = <fobj_join_kept>-fname.
        APPEND ls_join TO pt_join.
      ENDIF.

      set_changed( EXPORTING i_changed = aqqis_c_changed-updated ).

      cnvt_table_to_old( ).

    ELSE.
      pt_join[] = lt_join_sav[].
*   Die Felder &1 und &2 k#nnen nicht verkn#pft werden
      MESSAGE s022(aqqis_cntrl) WITH l_fname_kept l_fname_new.
    ENDIF.
  ENDMETHOD.                    "handle_link_changed

  METHOD init.

    DATA: l_headsg TYPE aqhdsg.

*--- Aufbau pt_join,
*           pt_tpos,
*           pt_tfield
*    so wie im alten Control
    cnvt_tables_to_new( EXPORTING i_first_table_apos = aqqis_c_false ).

*--- Umstellung altes Koordinatensystem -> neues Koordinatensystem
    p_join_data_r->get_info( IMPORTING e_headsg = l_headsg ).
    IF l_headsg-control = aqqis_c_false.
      reduce_distance( ).
      l_headsg-control = aqqis_c_true.
      p_join_data_r->set_info( EXPORTING i_headsg = l_headsg ).
    ENDIF.

*--- Aufbau GUI-Komponenten neues Control
    init_join_cntrl( i_r_container_parent = i_r_container_parent ).
    add_tables_to_join( ).

    add_links_to_join( ).

  ENDMETHOD.                    "init

  METHOD init_join_cntrl.

    DATA: l_s_event      TYPE  cntl_simple_event,
          l_t_event      TYPE  cntl_simple_events,
          l_s_ctxmnu_use TYPE  aqqis_s_ctxmnu_use,
          l_on           TYPE  boolean.

    DEFINE m_append_event.
      l_s_event-eventid = aqqis_c_event-&1.
      append l_s_event to l_t_event.
    END-OF-DEFINITION.

*--- create Control p_r_join_ctrl
    m_append_event:
*                 objectdoubleclick,       "Doppelklick
*                 contextmenusel,          "Kontextmenueintrag selektiert
                    contextmenureq,
*                 leftbuttondown,          "linke Maustaste gedr#ckt
*                 leftbuttonup,            "linke Maustaste loslassen
                    leftbuttondoubleclick,   "Linke Maustaste Doppelklick
*                 linkleftbuttondblclk,    "Link: linke Maust. Doppelklick
*                 linkrightbuttondown,     "Link: rechte Maust. gedr#ckt
*                 linktextchanged,         "Link: Text#nderung
*                 PREDROPROWOBJECT,
                    prechangedstobject,      "neues Zielobject m#glich
                    prechangesrcobject,      "neues Quellobject m#glich?
*                 dstobjectchanged,        "Link: neues Zielobject
*                 srcobjectchanged,        "Link: neues Quellobject
                    newlink,                 "Neuer Link
                    checkboxclick.           "Checkbox
*                 newtable.                "Neue Tabelle

*--- contextmenue
    l_s_ctxmnu_use-table       = aqqis_c_true.
    l_s_ctxmnu_use-link        = aqqis_c_true.
    l_s_ctxmnu_use-background  = aqqis_c_true.

    cl_gui_aqqgraphic_netplan=>get_netplan_object( EXPORTING i_r_parent     = i_r_container_parent
                                                             i_t_events     = l_t_event
                                                             i_s_ctxmnu_use = l_s_ctxmnu_use
                                                   IMPORTING e_r_netplan    = p_r_join_cntrl ).

*--- set handler
    SET HANDLER: on_handle_ctxmnureq     FOR p_r_join_cntrl,
                 on_handle_ctxmnusel     FOR p_r_join_cntrl,
*              on_handle_CHECKBOXCLICK for p_r_join_cntrl,
                 on_handle_succ_changed  FOR p_r_join_cntrl,
                 on_handle_pred_changed  FOR p_r_join_cntrl,
                 on_handle_link_created  FOR p_r_join_cntrl,
                 on_handle_objdblclick   FOR p_r_join_cntrl.
*              on_handle_drop          for p_r_join_cntrl.

* set active mode to create links by Drag&drop
    p_r_join_cntrl->set_activemode( EXPORTING  i_mode           = aqqis_c_cntrlmode-createlinkbydd
                                    EXCEPTIONS wrong_activemode = 1
                                               OTHERS           = 2 ).
    IF sy-subrc <> 0.
*   fatal error &1 &2 &3 &4
      MESSAGE a008(aqqis_cntrl) WITH 'INIT_JOIN_CNTRL' 'SET_ACTIVEMODE'.
    ENDIF.

* backgroundcolor: switch between display and change
    IF     p_mode = aqqis_c_mode-display.
      l_on = aqqis_c_true.
    ELSEIF p_mode = aqqis_c_mode-maint.
      l_on = aqqis_c_false.
    ENDIF.
*    p_r_join_cntrl->set_displayonly( EXPORTING  i_on              = l_on
**                                             I_CHANGEBACKCOLOR = AQQIS_C_TRUE
*                                     EXCEPTIONS wrong_inputvalue  = 1
*                                                OTHERS            = 2 ).
    IF sy-subrc <> 0.
      MESSAGE a008(aqqis_cntrl) WITH 'INIT_JOIN_CNTRL' 'SET_DISPLAYONLY'.
    ENDIF.


    p_default_linkstyle = p_r_join_cntrl->create_new_link_style( i_arrowstart = aqqis_c_false
                                                                 i_arrowend   = aqqis_c_false
                                                                 i_width      = 30
                                                                 i_color      = aqqis_c_defval-linkcolor ).
* Personalisierung
    DATA: l_r_pers TYPE REF TO cl_query_join_pers.
    l_r_pers = cl_query_join_pers=>factory( ).

    p_r_join_cntrl->set_zoom( EXPORTING i_zoom     = l_r_pers->p_s_data-zoom
                                        i_autozoom = aqqis_c_false ).

    p_r_join_cntrl->set_navigation_visible( EXPORTING i_visible = l_r_pers->p_s_data-navvisible ) .

  ENDMETHOD.                    "init_join_cntrl

  METHOD is_valid_link.

    DATA: lt_tab1  TYPE aqq_t_tab,
          lt_tab2  TYPE aqq_t_tab,
          l_fname1 TYPE aqs_fname,
          l_fname2 TYPE aqs_fname.

    FIELD-SYMBOLS: <tobj_join1> TYPE aqstobjjoi,
                   <tobj_join2> TYPE aqstobjjoi,
                   <fobj_join1> TYPE aqsfobjjoi,
                   <fobj_join2> TYPE aqsfobjjoi,
                   <join>       TYPE aqq_s_join,
                   <tab1>       TYPE aqq_s_tab,
                   <tab2>       TYPE aqq_s_tab.

    e_valid = aqqis_c_true.

*--- DDIC-Eigenschaften
    READ TABLE p_t_tobj_join WITH KEY tabref = i_r_succtab ASSIGNING <tobj_join1>.
    CHECK sy-subrc = 0.
    READ TABLE <tobj_join1>-fobj ASSIGNING <fobj_join1> INDEX i_succrow.
    CHECK sy-subrc = 0.

    READ TABLE p_t_tobj_join WITH KEY tabref = i_r_predtab ASSIGNING <tobj_join2>.
    CHECK sy-subrc = 0.
    READ TABLE <tobj_join2>-fobj ASSIGNING <fobj_join2> INDEX i_predrow.
    CHECK sy-subrc = 0.

    e_tname1 = <tobj_join1>-tname.
    e_tname2 = <tobj_join2>-tname.
    e_fname1 = <fobj_join1>-fname.
    e_fname2 = <fobj_join2>-fname.

    get_tab( EXPORTING i_tabname = <tobj_join1>-tname
             IMPORTING et_tab    = lt_tab1 ).

    get_tab( EXPORTING i_tabname = <tobj_join2>-tname
             IMPORTING et_tab    = lt_tab2 ).

* Felder derselben Tabelle verlinken
    IF <tobj_join1>-tname = <tobj_join2>-tname.
      e_valid = aqqis_c_false.
      EXIT.
    ENDIF.

* Pr#fen technische Eingenschaften
    READ TABLE lt_tab1 ASSIGNING <tab1> WITH KEY feld = <fobj_join1>-fname.
    READ TABLE lt_tab2 ASSIGNING <tab2> WITH KEY feld = <fobj_join2>-fname.

    IF <tab1>-dleng NE <tab2>-dleng OR
       <tab1>-dtype NE <tab2>-dtype OR
       <tab1>-ddec  NE <tab2>-ddec.
      e_valid = aqqis_c_false.
      EXIT.
    ENDIF.

* Pr#fen, ob dieser link schon existiert
    CONCATENATE <tobj_join1>-tname '-' <fobj_join1>-fname INTO l_fname1.
    CONCATENATE <tobj_join2>-tname '-' <fobj_join2>-fname INTO l_fname2.
    READ TABLE p_t_links_join WITH KEY tnameleft  = <tobj_join1>-tname
                                       fnameleft  = l_fname1
                                       tnameright = <tobj_join2>-tname
                                       fnameright = l_fname2
                                       TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      e_valid = aqqis_c_false.
      EXIT.
    ENDIF.
    READ TABLE p_t_links_join WITH KEY tnameleft  = <tobj_join2>-tname
                                       fnameleft  = l_fname2
                                       tnameright = <tobj_join1>-tname
                                       fnameright = l_fname1
                                       TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      e_valid = aqqis_c_false.
      EXIT.
    ENDIF.

*---
*   unzul#ssig:
*   tab1-f1---     tab2-f1
*   tab1-f2   \    tab2-f2
*   tab1-f3    \   tab2-f3
*   tab1-f4------- tab2-f4
    LOOP AT pt_join ASSIGNING <join> WHERE tabnamel = <tobj_join1>-tname
                                       AND colnamel = <fobj_join1>-fname.
      IF <join>-tabnamer = <tobj_join2>-tname.
        e_valid = aqqis_c_false.
        EXIT.
      ENDIF.
    ENDLOOP.

    LOOP AT pt_join ASSIGNING <join> WHERE tabnamel = <tobj_join2>-tname
                                       AND colnamel = <fobj_join2>-fname.
      IF <join>-tabnamer = <tobj_join1>-tname.
        e_valid = aqqis_c_false.
        EXIT.
      ENDIF.
    ENDLOOP.

    LOOP AT pt_join ASSIGNING <join> WHERE tabnamer = <tobj_join1>-tname
                                       AND colnamer = <fobj_join1>-fname.
      IF <join>-tabnamel = <tobj_join2>-tname.
        e_valid = aqqis_c_false.
        EXIT.
      ENDIF.
    ENDLOOP.

    LOOP AT pt_join ASSIGNING <join> WHERE tabnamer = <tobj_join2>-tname
                                       AND colnamer = <fobj_join2>-fname.
      IF <join>-tabnamel = <tobj_join1>-tname.
        e_valid = aqqis_c_false.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "is_valid_link

  METHOD join_modification.

    DATA: ls_join  TYPE aqq_s_join,
          l_fnamel TYPE aqs_fname,
          l_fnamer TYPE aqs_fname,
          l_fname  TYPE aqs_fname,
          l_tab1   TYPE aqs_tname,
          l_tab2   TYPE aqs_tname,
          l_tab3   TYPE aqs_tname.

    FIELD-SYMBOLS: <links_join> TYPE aqslinkjoi.

    READ TABLE p_t_links_join ASSIGNING <links_join> WITH KEY linkref = ir_link.

    l_fname = <links_join>-fnameleft.
    cnvt_fname_one_2_two( EXPORTING i_fname = l_fname
                          IMPORTING e_fname = l_fnamel ).
    l_fname = <links_join>-fnameright.
    cnvt_fname_one_2_two( EXPORTING i_fname = l_fname
                          IMPORTING e_fname = l_fnamer ).

    READ TABLE pt_join INTO ls_join WITH KEY tabnamel = <links_join>-tnameleft
                                             colnamel = l_fnamel
                                             tabnamer = <links_join>-tnameright
                                             colnamer = l_fnamer.

    ls_join-type = i_join_typ.
    test_join_validity( EXPORTING  is_join                 = ls_join
                        IMPORTING  e_tabname1              = l_tab1
                                   e_tabname2              = l_tab2
                                   e_tabname3              = l_tab3
                        EXCEPTIONS mode_invalid            = 1
                                   join_type_invalid_left  = 2
                                   join_type_invalid_right = 2
                                   join_type_invalid_side  = 2
                                   join_type_invalid_twice = 3
                                   join_type_inconsistent  = 4 ).

    CASE sy-subrc.
      WHEN 2.
*     Illegale Left-outer-join-Kette zwischen Tabellen &1 &2 &3
        MESSAGE s020(aqqis_cntrl) WITH l_tab1 l_tab2 l_tab3.
        EXIT.
      WHEN 3.
*     &1 kann nicht mit zwei Tabellen durch Left-outer-Join verbunden werden
        MESSAGE s021(aqqis_cntrl) WITH l_tab2.
        EXIT.
      WHEN 4.
*     on modification this means force the join-type for all joins
        execute_join_modification( is_join = ls_join
                                   ir_link = ir_link ).
        set_changed( EXPORTING i_changed = aqqis_c_changed-updated ).
        EXIT.
      WHEN OTHERS.
    ENDCASE.

    execute_join_modification( is_join = ls_join
                               ir_link = ir_link ).
    set_changed( EXPORTING i_changed = aqqis_c_changed-updated ).

  ENDMETHOD.                    "join_modification

  METHOD navigator.

    DATA: l_r_pers TYPE REF TO cl_query_join_pers.

    l_r_pers = cl_query_join_pers=>factory( ).

    IF     l_r_pers->p_s_data-navvisible = aqqis_c_false.
      p_r_join_cntrl->set_navigation_visible( EXPORTING i_visible = aqqis_c_true ).
      l_r_pers->p_s_data-navvisible = aqqis_c_true.
    ELSEIF l_r_pers->p_s_data-navvisible = aqqis_c_true.
      p_r_join_cntrl->set_navigation_visible( EXPORTING i_visible = aqqis_c_false ).
      l_r_pers->p_s_data-navvisible = aqqis_c_false.
    ENDIF.

  ENDMETHOD.                    "navigator


  METHOD on_condition.

    DATA: l_lin_tpos    TYPE i,
          l_tname1      TYPE aqs_tname,
          l_tname2      TYPE aqs_tname,
          l_tname_dummy TYPE aqs_tname,
          lt_dbjt       TYPE aqtdbjt,
          ls_tpos1      TYPE aqq_s_tpos,
          ls_tpos2      TYPE aqq_s_tpos.

    FIELD-SYMBOLS: <tobj_join1> TYPE aqstobjjoi,
                   <tobj_join2> TYPE aqstobjjoi.

    IF p_mode = aqqis_c_mode-display.
*   Funktion nur im #nderungsmodus unterst#tzt
      MESSAGE s005(aqqis_cntrl).
      EXIT.
    ENDIF.

    DESCRIBE TABLE pt_tpos LINES l_lin_tpos.
    IF     l_lin_tpos <= 0.
*   Es ist keine Tabelle vorhanden
      MESSAGE s012(aqqis_cntrl).
      EXIT.

    ELSEIF l_lin_tpos = 1.
*   Es ist nur eine Tabelle vorhanden
      MESSAGE s013(aqqis_cntrl).
      EXIT.

    ELSEIF l_lin_tpos = 2.
      READ TABLE pt_tpos INTO ls_tpos1 INDEX 1.
      READ TABLE pt_tpos INTO ls_tpos2 INDEX 2.
      propose_on_condition( EXPORTING  i_tabnamel             = ls_tpos1-tabname
                                       i_tabnamer             = ls_tpos2-tabname
                            EXCEPTIONS no_joins_found         = 1
                                       no_further_joins_found = 2
                                       join_addition_invalid  = 3 ).

* mehr als 2 Tabellen auf dem Control
    ELSE.
      get_selected_table( IMPORTING  e_tname                 = l_tname1
                          EXCEPTIONS no_table_selected       = 1
                                     several_tables_selected = 2 ).

* Popup: Angabe beider Tabellen, f#r die die Vorschl#ge gemacht werden sollen
      p_join_data_r->get_info( IMPORTING et_dbjt = lt_dbjt ).
      CALL FUNCTION 'RSAQ_CNTRL_PROPOSE_ON_0500'
        EXPORTING
          it_dbjt   = lt_dbjt
          i_tname   = l_tname1
        IMPORTING
          e_tname1  = l_tname1
          e_tname2  = l_tname2
        EXCEPTIONS
          cancelled = 1.
      IF sy-subrc NE 0.
*     Aktion abgebrochen
        MESSAGE s001(aqqis_cntrl).
        EXIT.
      ENDIF.

* Positionen von rechter und linker Tabelle bestimmen, ggf. tauschen
* damit rechts auch wirklich rechts ist und links auch wirklich links
* reads m#ssen gutgehen
      READ TABLE p_t_tobj_join ASSIGNING <tobj_join1> WITH KEY tname = l_tname1.
      READ TABLE p_t_tobj_join ASSIGNING <tobj_join2> WITH KEY tname = l_tname2.
      IF <tobj_join1>-tpos-leftpos < <tobj_join2>-tpos-leftpos.
      ELSE.
        l_tname_dummy = l_tname1.
        l_tname1      = l_tname2.
        l_tname2      = l_tname_dummy.
      ENDIF.

* Vorschl#ge on-Bedingung
      propose_on_condition( EXPORTING  i_tabnamel             = l_tname1
                                       i_tabnamer             = l_tname2
                            EXCEPTIONS no_joins_found         = 1
                                       no_further_joins_found = 2
                                       join_addition_invalid  = 3 ).
    ENDIF.

    IF     sy-subrc = 1.
*   Keine Verkn#pfungen gefunden
      MESSAGE s002(aqqis_cntrl).
      EXIT.
    ELSEIF sy-subrc = 2.
*   Keine weiteren Verkn#pfungen gefunden
      MESSAGE s003(aqqis_cntrl).
      EXIT.
    ELSEIF sy-subrc = 3.
*   Verkn#pfungen lassen sich nicht als Left-outer Bedingung einf#gen
      MESSAGE s004(aqqis_cntrl).
      EXIT.
    ENDIF.

    p_r_join_cntrl->send_data_to_frontend( ).

  ENDMETHOD.                    "on_condition

  METHOD on_handle_ctxmnureq.
* durch die Paramter  R_TABLE
*                     ROWINDEX
*                     R_LINK
*                     BACKGROUND
* erh#lt man das Objekt, auf dem das Kontextmenue gerufen wurde.

    DATA: l_submnu  TYPE REF TO cl_ctmenu,
          l_laymnu  TYPE REF TO cl_ctmenu,
          l_fcode   TYPE        ui_func,
          l_t_fcode TYPE        ui_functions.
    DATA: l_s_tobj_join TYPE        aqstobjjoi.

*--- table objects
    IF NOT r_table IS INITIAL.
*    read table p_t_tobj_join with key tabref = r_table
*               into l_s_tobj_join.
      IF rowindex <= 0.
        l_fcode = aqqis_c_ok_ddic.
        APPEND l_fcode TO l_t_fcode.
        r_ctxmnu->add_function( EXPORTING fcode = l_fcode
                                          text  = text-015 ).     " Absprung ins Dictionary

        l_fcode = aqqis_c_ok_f_tdel.
        APPEND l_fcode TO l_t_fcode.
        r_ctxmnu->add_function( EXPORTING fcode = l_fcode
                                          text  = text-001 ).     " Objekt l#schen

      ELSE.
        l_fcode = aqqis_c_ok_fdoc.
        APPEND l_fcode TO l_t_fcode.
        r_ctxmnu->add_function( EXPORTING fcode = l_fcode
                                          text  = text-016 ).     " Felddokumentation

        l_fcode = aqqis_c_ok_fref.
        APPEND l_fcode TO l_t_fcode.
        r_ctxmnu->add_function( EXPORTING fcode = l_fcode
                                          text  = text-017 ).     " Referenzfeld
      ENDIF.

*    if is_left_outer( r_table ) = aqqis_c_true.
*      l_fcode = aqqis_c_ok_lijoin.
*      append l_fcode to l_t_fcode.
*      r_ctxmnu->add_function( EXPORTING FCODE = l_fcode
*                                        TEXT  = text-002 ).   " inner join
**      change_link_text( ir_table = r_table
**                        i_outer  = aqqis_c_false ).
*    else.
*      l_fcode = aqqis_c_ok_lojoin.
*      append l_fcode to l_t_fcode.
*      r_ctxmnu->add_function( EXPORTING FCODE = l_fcode
*                                        TEXT  = text-003 ).   " left outer join
**      change_link_text( ir_table = r_table
**                        i_outer  = aqqis_c_true ).
*    endif.

    ENDIF.

*--- link objects
    IF NOT r_link IS INITIAL.
      DATA: l_fnamel TYPE aqs_fname,
            l_fnamer TYPE aqs_fname,
            l_fname  TYPE aqs_fname.

      FIELD-SYMBOLS: <links_join> TYPE aqslinkjoi,
                     <join>       TYPE aqq_s_join.

      READ TABLE p_t_links_join ASSIGNING <links_join> WITH KEY linkref = r_link.

      l_fname = <links_join>-fnameleft.
      cnvt_fname_one_2_two( EXPORTING i_fname = l_fname
                            IMPORTING e_fname = l_fnamel ).
      l_fname = <links_join>-fnameright.
      cnvt_fname_one_2_two( EXPORTING i_fname = l_fname
                            IMPORTING e_fname = l_fnamer ).

      READ TABLE pt_join ASSIGNING <join> WITH KEY tabnamel = <links_join>-tnameleft
                                                   colnamel = l_fnamel
                                                   tabnamer = <links_join>-tnameright
                                                   colnamer = l_fnamer.
      IF     <join>-type = aqqis_c_join_typ-inner.
        l_fcode = aqqis_c_ok_lojoin.
        APPEND l_fcode TO l_t_fcode.
        r_ctxmnu->add_function( EXPORTING fcode = l_fcode
                                          text  = text-003 ).   " left outer join
      ELSEIF <join>-type = aqqis_c_join_typ-left_outer.
        l_fcode = aqqis_c_ok_lijoin.
        APPEND l_fcode TO l_t_fcode.
        r_ctxmnu->add_function( EXPORTING fcode = l_fcode
                                          text  = text-002 ).   " inner join
      ENDIF.

      l_fcode = aqqis_c_ok_f_ldel.
      APPEND l_fcode TO l_t_fcode.
      r_ctxmnu->add_function( EXPORTING fcode = l_fcode
                                        text  = text-014 ).   " Link l#schen
    ENDIF.

*--- on background
    IF background = aqqis_c_true.
      l_fcode = aqqis_c_ok_f_zoomin.
      APPEND l_fcode TO l_t_fcode.
      r_ctxmnu->add_function( EXPORTING fcode = l_fcode
                                        text  = text-004 ).   " Zoom in

      l_fcode = aqqis_c_ok_f_zoomout.
      APPEND l_fcode TO l_t_fcode.
      r_ctxmnu->add_function( EXPORTING fcode = l_fcode
                                        text  = text-005 ).   " Zoom out

*    l_fcode = aqqis_c_ok_F_fit.
*    append l_fcode to l_t_fcode.
*    r_ctxmnu->add_function( EXPORTING FCODE = l_fcode
*                                      TEXT  = text-006 ).   " autoarrange

      l_fcode = aqqis_c_ok_f_navi.
      APPEND l_fcode TO l_t_fcode.
      r_ctxmnu->add_function( EXPORTING fcode = l_fcode
                                        text  = text-007 ).   " Navigation ein/aus

*    l_fcode = aqqis_c_ok_F_link.
*    append l_fcode to l_t_fcode.
*    r_ctxmnu->add_function( EXPORTING FCODE = l_fcode
*                                      TEXT  = text-008 ).   " Linkpflege

      l_fcode = aqqis_c_ok_f_scale.
      APPEND l_fcode TO l_t_fcode.
      r_ctxmnu->add_function( EXPORTING fcode = l_fcode
                                        text  = text-012 ).   " Navigation ein/aus

    ENDIF.

    IF NOT r_table IS INITIAL.
    ELSE.
      IF p_mode = aqqis_c_mode-display.
        r_ctxmnu->disable_functions( EXPORTING fcodes = l_t_fcode ).
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "on_handle_ctxmnureq

  METHOD on_handle_ctxmnusel.

    DATA: l_fcode_ui TYPE ui_func.

    l_fcode_ui = fcode.
    handle_fcode( EXPORTING i_fcode    = l_fcode_ui
                            ir_table   = r_table
                            i_rowindex = rowindex
                            ir_link    = r_link  ).

  ENDMETHOD.                    "on_handle_ctxmnusel

  METHOD on_handle_link_created.

    DATA: l_valid  TYPE        boolean,
          l_tname1 TYPE        aqs_tname,
          l_tname2 TYPE        aqs_tname,
          l_fname1 TYPE        aqs_fname,
          l_fname2 TYPE        aqs_fname,
          l_fnamel TYPE        aqs_fname,
          l_fnamer TYPE        aqs_fname,
          ls_link  TYPE        aqslinkjoi,
          ls_join  TYPE        aqq_s_join,
          l_text   TYPE        aqq_text,
          lr_tabl  TYPE REF TO if_aqqgraphic_table,
          lr_tabr  TYPE REF TO if_aqqgraphic_table,
          l_r_link TYPE REF TO if_aqqgraphic_link.

    FIELD-SYMBOLS: <tpos1>     TYPE aqq_s_tpos,
                   <tpos2>     TYPE aqq_s_tpos,
                   <join>      TYPE aqq_s_join,
                   <tobj_join> TYPE aqstobjjoi.

    IF p_mode = aqqis_c_mode-display.
*   Funktion nur im #nderungsmodus unterst#tzt
      r_doit->o_ok = aqqis_c_false.
      MESSAGE s005(aqqis_cntrl).
      EXIT.
    ENDIF.

* setzen #nderungsflag
    set_changed( EXPORTING i_changed = aqqis_c_changed-updated ).
*>>>
    DATA: ls_join_n     TYPE aqq_s_join,
          l_tab1        TYPE aqs_tname,
          l_tab2        TYPE aqs_tname,
          l_tab3        TYPE aqs_tname,
          l_check       TYPE boolean,
          ls_join_check TYPE aqq_s_join.

    FIELD-SYMBOLS: <tobj_join_1> TYPE aqstobjjoi,
                   <tobj_join_2> TYPE aqstobjjoi,
                   <fobj_join_1> TYPE aqsfobjjoi,
                   <fobj_join_2> TYPE aqsfobjjoi.

    READ TABLE p_t_tobj_join ASSIGNING <tobj_join_1> WITH KEY tabref = r_predtab.
    ls_join_n-tabnamel = <tobj_join_1>-tname.
    READ TABLE <tobj_join_1>-fobj ASSIGNING <fobj_join_1> INDEX pred_row.
    ls_join_n-colnamel = <fobj_join_1>-fname.

    READ TABLE p_t_tobj_join ASSIGNING <tobj_join_2> WITH KEY tabref = r_succtab.
    ls_join_n-tabnamer = <tobj_join_2>-tname.
    READ TABLE <tobj_join_2>-fobj ASSIGNING <fobj_join_2> INDEX succ_row.
    ls_join_n-colnamer = <fobj_join_2>-fname.

* check if join already exists between these two tables.
    READ TABLE pt_join INTO ls_join_check WITH KEY tabnamel = ls_join_n-tabnamel
                                                   tabnamer = ls_join_n-tabnamer.
    IF sy-subrc = 0.
      ls_join_n-type = ls_join_check-type.
    ELSE.
      READ TABLE pt_join INTO ls_join_check WITH KEY tabnamel = ls_join_n-tabnamer
                                                     tabnamer = ls_join_n-tabnamel.
      IF sy-subrc = 0.
        ls_join_n-type = ls_join_check-type.
      ELSE.
        ls_join_n-type = aqqis_c_join_typ-inner.
      ENDIF.
    ENDIF.

    test_join_validity( EXPORTING  is_join                 = ls_join_n
                        IMPORTING  e_tabname1              = l_tab1
                                   e_tabname2              = l_tab2
                                   e_tabname3              = l_tab3
                        EXCEPTIONS mode_invalid            = 1
                                   join_type_invalid_left  = 2
                                   join_type_invalid_right = 2
                                   join_type_invalid_side  = 2
                                   join_type_invalid_twice = 3
                                   join_type_inconsistent  = 4
                                   OTHERS                  = 99 ).
    CASE sy-subrc.
      WHEN 0.
      WHEN 2.
        r_doit->o_ok = aqqis_c_false.
*     Illegale Left-outer-join-Kette zwischen Tabellen &1 &2 &3
        MESSAGE s020(aqqis_cntrl) WITH l_tab1 l_tab2 l_tab3.
        EXIT.
      WHEN 3.
        r_doit->o_ok = aqqis_c_false.
*     &1 kann nicht mit zwei Tabellen durch Left-outer-Join verbunden werden
        MESSAGE s021(aqqis_cntrl) WITH l_tab2.
        EXIT.
      WHEN 4.
        r_doit->o_ok = aqqis_c_false.
*     on modification this means force the join-type for all joins
        execute_join_modification( is_join = ls_join
                                   ir_link = r_newlink ).
        set_changed( EXPORTING i_changed = aqqis_c_changed-updated ).
*     Ein (Left-Outer) Join kann hier nicht definiert werden.
        MESSAGE s036(aqqis_cntrl).
        EXIT.
      WHEN OTHERS.
        r_doit->o_ok = aqqis_c_false.
*     Illegale Join-Bedingungen
        MESSAGE s035(aqqis_cntrl).
        EXIT.
    ENDCASE.
*<<<
    synchronize_positions( EXCEPTIONS no_data_on_control = 1 ).

* check if link is valid
    is_valid_link( EXPORTING i_r_succtab = r_succtab
                             i_succrow   = succ_row
                             i_r_predtab = r_predtab
                             i_predrow   = pred_row
                   IMPORTING e_valid     = l_valid
                             e_tname1    = l_tname1
                             e_tname2    = l_tname2
                             e_fname1    = l_fname1
                             e_fname2    = l_fname2 ).

    IF l_valid = aqqis_c_true.

      l_r_link = r_newlink.

* p_t_links_join erg#nzen
      READ TABLE pt_tpos ASSIGNING <tpos1> WITH KEY tabname = l_tname1.
      READ TABLE pt_tpos ASSIGNING <tpos2> WITH KEY tabname = l_tname2.

      IF <tpos1>-xpos < <tpos2>-xpos.
        ls_link-tnameleft  = l_tname1.
        CONCATENATE l_tname1 '-' l_fname1 INTO ls_link-fnameleft.
        ls_link-tnameright = l_tname2.
        CONCATENATE l_tname2 '-' l_fname2 INTO ls_link-fnameright.
        l_fnamel = l_fname1.
        l_fnamer = l_fname2.
      ELSE.
        ls_link-tnameleft  = l_tname2.
        CONCATENATE l_tname2 '-' l_fname2 INTO ls_link-fnameleft.
        ls_link-tnameright = l_tname1.
        CONCATENATE l_tname1 '-' l_fname1 INTO ls_link-fnameright.
        l_fnamel = l_fname2.
        l_fnamer = l_fname1.
      ENDIF.
      ls_link-linkref = l_r_link.
      APPEND ls_link TO p_t_links_join.

* pt_join erg#nzen
      READ TABLE pt_join ASSIGNING <join> WITH KEY tabnamel = ls_link-tnameleft
                                                   tabnamer = ls_link-tnameright.
      IF sy-subrc = 0.
        ls_join-type = <join>-type.
      ELSE.
        ls_join-type = aqqis_c_join_typ-inner.
      ENDIF.

      ls_join-tabnamel = ls_link-tnameleft.
      ls_join-colnamel = l_fnamel.
      ls_join-tabnamer = ls_link-tnameright.
      ls_join-colnamer = l_fnamer.
      APPEND ls_join TO pt_join.

* Text des links besorgen
      READ TABLE p_t_tobj_join ASSIGNING <tobj_join> WITH KEY tabref = r_succtab.
      IF <tobj_join>-tname = ls_join-tabnamel.
        lr_tabl = r_succtab.
        lr_tabr = r_predtab.
      ELSE.
        lr_tabr = r_succtab.
        lr_tabl = r_predtab.
      ENDIF.
      l_text = fetch_outerflag_text( ir_tabl = lr_tabl
                                     ir_tabr = lr_tabr ).

      l_r_link->set_attributes( EXPORTING i_moveable     = aqqis_c_true
*                                       I_SELECTABLE   = aqqis_C_TRUE
                                          i_editable     = aqqis_c_false
*                                       I_MOUSEOVER    = aqqis_C_TRUE
*                                       I_ELBOWLINK    = aqqis_C_FALSE
*                                       I_ANGLELINK    = aqqis_C_TRUE
*                                       I_BUNCHLINK    = aqqis_C_FALSE
*                                       I_SIMPLELINK   = aqqis_C_FALSE
*                                       I_DESMERGELINK = aqqis_C_TRUE
      ).

      l_r_link->set_status( ).

      l_r_link->set_properties( EXPORTING i_linkstyle = p_default_linkstyle
                                          i_text      = l_text ).
    ELSE.
      r_doit->o_ok = aqqis_c_false.
      CONCATENATE l_tname2 '-' l_fname2 INTO l_fname2.
      CONCATENATE l_tname1 '-' l_fname1 INTO l_fname1.
*   Die Felder &1 &2 k#nnen nicht verkn#pft werden
      MESSAGE s022(aqqis_cntrl) WITH l_fname1 l_fname2.
      EXIT.
    ENDIF.

    cnvt_table_to_old_dbjc( ).

  ENDMETHOD.                    "on_handle_link_created

  METHOD on_handle_objdblclick.

    DATA: l_s_tobj_join TYPE aqstobjjoi,
          l_s_fobj      TYPE aqsfobjjoi,
          lt_tab        TYPE aqq_t_tab,
          l_ref         TYPE flag,
          ls_exdbfi     TYPE aqsexdbfi,
          lt_exdbfi     TYPE aqq_t_exdbfi.

    FIELD-SYMBOLS: <tab> TYPE aqq_s_tab.

    IF NOT r_table IS INITIAL.
      READ TABLE p_t_tobj_join INTO l_s_tobj_join WITH KEY tabref = r_table.
      CHECK sy-subrc = 0.

      READ TABLE l_s_tobj_join-fobj INTO l_s_fobj INDEX row.
      CHECK sy-subrc = 0.

      get_tab( EXPORTING i_tabname = l_s_tobj_join-tname
               IMPORTING et_tab    = lt_tab ).

      READ TABLE lt_tab ASSIGNING <tab> WITH KEY feld = l_s_fobj-fname.
      IF sy-subrc = 0.
*--- Referenzfeld
*      break rueger.
        IF l_ref = aqqis_c_true.
          referenzfield( is_tab  = <tab>
                         i_tname = l_s_tobj_join-tname ).

*--- Felddokumentation
        ELSEIF l_ref = aqqis_c_false.
          CALL FUNCTION 'RSAQ_CNTRL_BUILD_EXDBFI'
            EXPORTING
              i_tab     = l_s_tobj_join-tname
            IMPORTING
              et_exdbfi = lt_exdbfi.

          READ TABLE lt_exdbfi INTO ls_exdbfi WITH KEY ddic-fieldname = <tab>-feld.

          CALL FUNCTION 'RSAQ_CNTRL_FIELD_DOCU'
            EXPORTING
              is_exdbfi = ls_exdbfi.
*--- DDic Absprung
        ELSE.
          DATA: l_objname TYPE ddobjname,
                l_objtype TYPE ddeutype,
                lt_dban   TYPE aqtdban.
          FIELD-SYMBOLS: <dban> TYPE aqdban.

          p_join_data_r->get_info( IMPORTING et_dban = lt_dban ).

          l_objname = l_s_tobj_join-tname.
          READ TABLE lt_dban ASSIGNING <dban> WITH KEY alias = l_objname.
          IF sy-subrc = 0.
            l_objname = <dban>-table.
          ENDIF.

          l_objtype = 'T'.
          CALL FUNCTION 'RS_DD_SHOW'
            EXPORTING
              objname              = l_objname
              objtype              = l_objtype
*             POPUP                = ' '
*             SECNAME              =
*             MONITOR_ACTIVATE     = 'X'
*       IMPORTING
*             FCODE                =
            EXCEPTIONS
              object_not_found     = 1
              object_not_specified = 2
              permission_failure   = 3
              type_not_valid       = 4.

          IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
        ENDIF.

      ENDIF.
    ENDIF.

  ENDMETHOD.                    "on_handle_objdblclick

  METHOD on_handle_pred_changed.

    DATA: l_r_succ  TYPE REF TO if_aqqgraphic_table,
          l_succrow TYPE        aqq_rownr.

    IF p_mode = aqqis_c_mode-display.
*   Funktion nur im #nderungsmodus unterst#tzt
      r_doit->o_ok = aqqis_c_false.
      MESSAGE s005(aqqis_cntrl).
      EXIT.
    ENDIF.

* setzen #nderungsflag
    set_changed( EXPORTING i_changed = aqqis_c_changed-updated ).

    synchronize_positions( EXCEPTIONS no_data_on_control = 1 ).

    r_link->get_successor( IMPORTING e_r_table   = l_r_succ
                                     e_rowindex  = l_succrow ).

* o_ok = ' '  -> change not possible
* o_ok = 'X'  -> link can be changed
    r_doit->o_ok = handle_link_changed( i_r_link       = r_link
                                        i_r_tab_new    = r_predtab
                                        i_row_new      = predrow
                                        i_r_tab_kept   = l_r_succ
                                        i_row_kept     = l_succrow
                                        i_succ_changed = aqqis_c_false ).

  ENDMETHOD.                    "on_handle_pred_changed

  METHOD on_handle_succ_changed.

    DATA: l_r_pred  TYPE REF TO if_aqqgraphic_table,
          l_predrow TYPE        aqq_rownr.

    IF p_mode = aqqis_c_mode-display.
*   Funktion nur im #nderungsmodus unterst#tzt
      r_doit->o_ok = aqqis_c_false.
      MESSAGE s005(aqqis_cntrl).
      EXIT.
    ENDIF.

* setzen #nderungsflag
    set_changed( EXPORTING i_changed = aqqis_c_changed-updated ).

    synchronize_positions( EXCEPTIONS no_data_on_control = 1 ).

    r_link->get_predecessor( IMPORTING e_r_table   = l_r_pred
                                       e_rowindex  = l_predrow ).

* o_ok = ' '  -> change not possible
* o_ok = 'X'  -> link can be changed
    r_doit->o_ok = handle_link_changed( i_r_link       = r_link
                                        i_r_tab_new    = r_succtab
                                        i_row_new      = succrow
                                        i_r_tab_kept   = l_r_pred
                                        i_row_kept     = l_predrow
                                        i_succ_changed = aqqis_c_true ).
  ENDMETHOD.                    "on_handle_succ_changed

  METHOD print_control.

    CALL METHOD p_r_join_cntrl->print.

  ENDMETHOD.                    "print_control

  METHOD propose_on_condition.

    DATA: l_join_found TYPE flag VALUE ' ',
          l_tabname    TYPE tname,
          l_state      TYPE objstate,     " (like ddrefstruc-state, )
          lt_head      TYPE STANDARD TABLE OF dd08v,
          ls_fkey      TYPE dd05m,
          lt_fkey      TYPE STANDARD TABLE OF dd05m,
          lt_hdum      TYPE STANDARD TABLE OF dd08v,
          lt_fdum      TYPE STANDARD TABLE OF dd05m,
          ls_join      TYPE aqq_s_join,
          lt_join      TYPE aqq_t_join,
          ls_headsg    TYPE aqhdsg,
*>>>---zaaqb
          lt_fkey_t    TYPE STANDARD TABLE OF dd05m,
          wa_fkey      LIKE LINE OF lt_fkey_t,
          lt_fdum_t    TYPE STANDARD TABLE OF dd05m,
          wa_fdum      LIKE LINE OF lt_fdum_t,
          lt_head_t    TYPE STANDARD TABLE OF dd08v,
          wa_head      LIKE LINE OF lt_head_t,
          lt_hdum_t    TYPE STANDARD TABLE OF dd08v,
          wa_hdum      LIKE LINE OF lt_hdum_t.
*<<<---zaaqb

    lt_join[] = pt_join[].

    p_join_data_r->get_info( IMPORTING e_headsg = ls_headsg ).

* Fremdschl#sselbeziehungen auswerten
    ls_join-op   = aqqis_c_join_operator-eq.
    ls_join-type = aqqis_c_join_typ-inner.

* Fremdschl#sselbeziehungen LTAB -> RTAB
    l_tabname = i_tabnamel.
    CALL FUNCTION 'DD_TBFK_GET'
      EXPORTING
        tabl_name   = l_tabname
      IMPORTING
        got_state   = l_state
      TABLES
        dd05m_tab_a = lt_fkey
        dd05m_tab_n = lt_fdum
        dd08v_tab_a = lt_head
        dd08v_tab_n = lt_hdum
      EXCEPTIONS
        OTHERS      = 1.

*>>>---zaaqb
    REFRESH lt_fkey_t.
    LOOP AT lt_fkey INTO wa_fkey.
      READ TABLE zaaqb_key_word WITH KEY table = wa_fkey-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        READ TABLE zaaqb_key_word WITH KEY table = wa_fkey-forkey TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          APPEND wa_fkey TO lt_fkey_t.
        ENDIF.
      ENDIF.
    ENDLOOP.
    REFRESH lt_fkey.
    APPEND LINES OF lt_fkey_t TO lt_fkey.

    REFRESH lt_fdum_t.
    LOOP AT lt_fdum INTO wa_fdum.
      READ TABLE zaaqb_key_word WITH KEY table = wa_fdum-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND wa_fdum TO lt_fdum_t.
      ENDIF.
    ENDLOOP.
    REFRESH lt_fdum.
    APPEND LINES OF lt_fdum_t TO lt_fdum.

    REFRESH lt_head_t.
    LOOP AT lt_head INTO wa_head.
      READ TABLE zaaqb_key_word WITH KEY table = wa_head-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND wa_head TO lt_head_t.
      ENDIF.
    ENDLOOP.
    REFRESH lt_head.
    APPEND LINES OF lt_head_t TO lt_head.

    REFRESH lt_hdum_t.
    LOOP AT lt_hdum INTO wa_hdum.
      READ TABLE zaaqb_key_word WITH KEY table = wa_hdum-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND wa_hdum TO lt_hdum_t.
      ENDIF.
    ENDLOOP.
    REFRESH lt_hdum.
    APPEND LINES OF lt_hdum_t TO lt_hdum.
*<<<---zaaqb
    LOOP AT lt_fkey INTO ls_fkey WHERE datatype <> 'CLNT'
                                   AND fortable   = i_tabnamel
                                   AND checktable = i_tabnamer.

      ls_join-op       = aqqis_c_join_operator-eq.
      ls_join-type     = aqqis_c_join_typ-inner.
      ls_join-tabnamel = i_tabnamel.
      ls_join-colnamel = ls_fkey-forkey.
      ls_join-tabnamer = i_tabnamer.
      ls_join-colnamer = ls_fkey-checkfield.

      READ TABLE lt_join WITH KEY tabnamel = ls_join-tabnamel
                                  colnamel = ls_join-colnamel
                                  tabnamer = ls_join-tabnamer
                                  TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        READ TABLE lt_join WITH KEY tabnamer = ls_join-tabnamel
                                    colnamer = ls_join-colnamel
                                    tabnamel = ls_join-tabnamer
                                    TRANSPORTING NO FIELDS.

        IF sy-subrc <> 0.
          READ TABLE lt_join WITH KEY tabnamel = ls_join-tabnamel
                                      tabnamer = ls_join-tabnamer
                                      colnamer = ls_join-colnamer
                                      TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            READ TABLE lt_join WITH KEY tabnamer = ls_join-tabnamel
                                        tabnamel = ls_join-tabnamer
                                        colnamel = ls_join-colnamer
                                        TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0.
              test_join_validity( EXPORTING  is_join                 = ls_join
                                  EXCEPTIONS mode_invalid            = 1
                                             join_type_invalid_left  = 2
                                             join_type_invalid_right = 2
                                             join_type_invalid_side  = 2
                                             join_type_invalid_twice = 2
                                             join_type_inconsistent  = 3
                                             tab_not_found           = 4
                                             field_not_found         = 4 ).
              IF sy-subrc = 2.
                RAISE join_addition_invalid.
              ENDIF.
              IF ( sy-subrc = 3 ).
                force_jointype( EXPORTING  i_change_old = aqqis_c_false
                                CHANGING   cs_join      = ls_join
                                EXCEPTIONS inconsistent = 1 ).
                test_join_validity( EXPORTING  is_join                 = ls_join
                                    EXCEPTIONS join_type_invalid_left  = 2
                                               join_type_invalid_right = 2
                                               join_type_invalid_side  = 2
                                               join_type_invalid_twice = 2 ).
                IF sy-subrc <> 0.
                  RAISE join_addition_invalid.
                ENDIF.
              ENDIF.

              APPEND: ls_join TO lt_join,
                      ls_join TO pt_join.
              l_join_found = aqqis_c_true.
              ls_headsg-state = aqqis_c_changed-updated.
              propose_on_condition_add_link( EXPORTING is_join = ls_join ).
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

* Fremdschl#sselbeziehungen LTAB <- RTAB
    l_tabname = i_tabnamer.
    CALL FUNCTION 'DD_TBFK_GET'
      EXPORTING
        tabl_name   = l_tabname
      IMPORTING
        got_state   = l_state
      TABLES
        dd05m_tab_a = lt_fkey
        dd05m_tab_n = lt_fdum
        dd08v_tab_a = lt_head
        dd08v_tab_n = lt_hdum
      EXCEPTIONS
        OTHERS      = 1.

*>>>---zaaqb
    REFRESH lt_fkey_t.
    LOOP AT lt_fkey INTO wa_fkey.
      READ TABLE zaaqb_key_word WITH KEY table = wa_fkey-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND wa_fkey TO lt_fkey_t.
      ENDIF.
    ENDLOOP.
    REFRESH lt_fkey.
    APPEND LINES OF lt_fkey_t TO lt_fkey.

    REFRESH lt_fdum_t.
    LOOP AT lt_fdum INTO wa_fdum.
      READ TABLE zaaqb_key_word WITH KEY table = wa_fdum-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND wa_fdum TO lt_fdum_t.
      ENDIF.
    ENDLOOP.
    REFRESH lt_fdum.
    APPEND LINES OF lt_fdum_t TO lt_fdum.

    REFRESH lt_head_t.
    LOOP AT lt_head INTO wa_head.
      READ TABLE zaaqb_key_word WITH KEY table = wa_head-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND wa_head TO lt_head_t.
      ENDIF.
    ENDLOOP.
    REFRESH lt_head.
    APPEND LINES OF lt_head_t TO lt_head.

    REFRESH lt_hdum_t.
    LOOP AT lt_hdum INTO wa_hdum.
      READ TABLE zaaqb_key_word WITH KEY table = wa_hdum-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND wa_hdum TO lt_hdum_t.
      ENDIF.
    ENDLOOP.
    REFRESH lt_hdum.
    APPEND LINES OF lt_hdum_t TO lt_hdum.
*<<<---zaaqb

    LOOP AT lt_fkey INTO ls_fkey WHERE datatype <> 'CLNT'
                                   AND fortable   = i_tabnamer
                                   AND checktable = i_tabnamel.
      ls_join-tabnamel = i_tabnamel.
      ls_join-colnamel = ls_fkey-checkfield.
      ls_join-tabnamer = i_tabnamer.
      ls_join-colnamer = ls_fkey-forkey.

      READ TABLE lt_join WITH KEY tabnamel = ls_join-tabnamel
                                  colnamel = ls_join-colnamel
                                  tabnamer = ls_join-tabnamer
                                  TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        READ TABLE lt_join WITH KEY tabnamer = ls_join-tabnamel
                                    colnamer = ls_join-colnamel
                                    tabnamel = ls_join-tabnamer
                                    TRANSPORTING NO FIELDS.

        IF sy-subrc <> 0.
          READ TABLE lt_join WITH KEY tabnamel = ls_join-tabnamel
                                      tabnamer = ls_join-tabnamer
                                      colnamer = ls_join-colnamer
                                      TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            READ TABLE lt_join WITH KEY tabnamer = ls_join-tabnamel
                                        tabnamel = ls_join-tabnamer
                                        colnamel = ls_join-colnamer
                                        TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0.
              test_join_validity( EXPORTING  is_join                 = ls_join
                                  EXCEPTIONS mode_invalid            = 1
                                             join_type_invalid_left  = 2
                                             join_type_invalid_right = 2
                                             join_type_invalid_side  = 2
                                             join_type_invalid_twice = 2
                                             join_type_inconsistent  = 3
                                             tab_not_found           = 4
                                             field_not_found         = 4
                                             fields_invalid          = 5 ).
              IF sy-subrc = 2.
                RAISE join_addition_invalid.
              ENDIF.
              IF sy-subrc = 3.
                force_jointype( EXPORTING  i_change_old = aqqis_c_false
                                CHANGING   cs_join      = ls_join
                                EXCEPTIONS inconsistent = 1 ).
                test_join_validity( EXPORTING  is_join                 = ls_join
                                    EXCEPTIONS join_type_invalid_left  = 2
                                               join_type_invalid_right = 2
                                               join_type_invalid_side  = 2
                                               join_type_invalid_twice = 2 ).
                IF sy-subrc <> 0.
                  RAISE join_addition_invalid.
                ENDIF.
              ENDIF.
              IF sy-subrc = 5.
                CONTINUE.
              ENDIF.

              APPEND: ls_join TO lt_join,
                      ls_join TO pt_join.
              l_join_found = aqqis_c_true.
              ls_headsg-state = aqqis_c_changed-updated.
              propose_on_condition_add_link( EXPORTING is_join = ls_join ).
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF l_join_found = aqqis_c_true.                 " Fremdschl#sselbeziehungen gef.
      p_join_data_r->set_info( EXPORTING i_headsg = ls_headsg ).
      cnvt_table_to_old( ).
      EXIT.
    ENDIF.

* Standardvorschl#ge #ber Dom#nenbeziehungen
    DATA: lt_ltab TYPE aqq_t_tab,
          ls_ltab TYPE aqq_s_tab,
          lt_rtab TYPE aqq_t_tab,
          ls_rtab TYPE aqq_s_tab.

    get_tab( EXPORTING i_tabname = i_tabnamel
             IMPORTING et_tab    = lt_ltab ).
    get_tab( EXPORTING i_tabname = i_tabnamer
             IMPORTING et_tab    = lt_rtab ).

    LOOP AT lt_ltab INTO ls_ltab WHERE key <> space.
*    check not ls_ltab-dom is initial.
      LOOP AT lt_rtab INTO ls_rtab WHERE dom = ls_ltab-dom.
        ls_join-tabnamel = i_tabnamel.
        ls_join-colnamel = ls_ltab-feld.
        ls_join-tabnamer = i_tabnamer.
        ls_join-colnamer = ls_rtab-feld.

        READ TABLE lt_join WITH KEY tabnamel = ls_join-tabnamel
                                    colnamel = ls_join-colnamel
                                    tabnamer = ls_join-tabnamer
                                    TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          READ TABLE lt_join WITH KEY tabnamer = ls_join-tabnamel
                                      colnamer = ls_join-colnamel
                                      tabnamel = ls_join-tabnamer
                                      TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            READ TABLE lt_join WITH KEY tabnamel = ls_join-tabnamel
                                        tabnamer = ls_join-tabnamer
                                        colnamer = ls_join-colnamer
                                        TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0.
              READ TABLE lt_join WITH KEY tabnamer = ls_join-tabnamel
                                          tabnamel = ls_join-tabnamer
                                          colnamel = ls_join-colnamer
                                          TRANSPORTING NO FIELDS.
              IF sy-subrc <> 0.
                test_join_validity( EXPORTING  is_join                 = ls_join
                                    EXCEPTIONS mode_invalid            = 1
                                               join_type_invalid_left  = 2
                                               join_type_invalid_right = 2
                                               join_type_invalid_side  = 2
                                               join_type_invalid_twice = 2
                                               join_type_inconsistent  = 3
                                               tab_not_found           = 4
                                               field_not_found         = 4
                                               fields_invalid          = 5 ).
                IF sy-subrc = 2.
                  RAISE join_addition_invalid.
                ENDIF.
                IF sy-subrc = 3.
                  force_jointype( EXPORTING  i_change_old = aqqis_c_false
                                  CHANGING   cs_join      = ls_join
                                  EXCEPTIONS inconsistent = 1 ).
                  test_join_validity( EXPORTING  is_join                 = ls_join
                                      EXCEPTIONS join_type_invalid_left  = 2
                                                 join_type_invalid_right = 2
                                                 join_type_invalid_side  = 2
                                                 join_type_invalid_twice = 2 ).
                  IF sy-subrc <> 0.
                    RAISE join_addition_invalid.
                  ENDIF.
                ENDIF.
                IF sy-subrc = 5.
                  CONTINUE.
                ENDIF.

                APPEND: ls_join TO lt_join,
                        ls_join TO pt_join.
                l_join_found = aqqis_c_true.
                ls_headsg-state = aqqis_c_changed-updated.
                propose_on_condition_add_link( EXPORTING is_join = ls_join ).
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_rtab INTO ls_rtab WHERE key <> space.
*    check not ls_rtab-dom is initial.
      LOOP AT lt_ltab INTO ls_ltab WHERE dom = ls_rtab-dom.
*      DBJC-JIND   = SPACE.
        ls_join-tabnamel = i_tabnamel.
        ls_join-colnamel = ls_ltab-feld.
        ls_join-tabnamer = i_tabnamer.
        ls_join-colnamer = ls_rtab-feld.

        READ TABLE lt_join WITH KEY tabnamel = ls_join-tabnamel
                                    colnamel = ls_join-colnamel
                                    tabnamer = ls_join-tabnamer
                                    TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          READ TABLE lt_join WITH KEY tabnamer = ls_join-tabnamel
                                      colnamer = ls_join-colnamel
                                      tabnamel = ls_join-tabnamer
                                      TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            READ TABLE lt_join WITH KEY tabnamel = ls_join-tabnamel
                                        tabnamer = ls_join-tabnamer
                                        colnamer = ls_join-colnamer
                                        TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0.
              READ TABLE lt_join WITH KEY tabnamer = ls_join-tabnamel
                                          tabnamel = ls_join-tabnamer
                                          colnamel = ls_join-colnamer
                                          TRANSPORTING NO FIELDS.
              IF sy-subrc <> 0.
                test_join_validity( EXPORTING  is_join                 = ls_join
                                    EXCEPTIONS mode_invalid            = 1
                                               join_type_invalid_left  = 2
                                               join_type_invalid_right = 2
                                               join_type_invalid_side  = 2
                                               join_type_invalid_twice = 2
                                               join_type_inconsistent  = 3
                                               tab_not_found           = 4
                                               field_not_found         = 4
                                               fields_invalid          = 5 ).
                IF sy-subrc = 2.
                  RAISE join_addition_invalid.
                ENDIF.
                IF sy-subrc = 3.
                  force_jointype( EXPORTING  i_change_old = aqqis_c_false
                                  CHANGING   cs_join      = ls_join
                                  EXCEPTIONS inconsistent = 1 ).
                  test_join_validity( EXPORTING  is_join                 = ls_join
                                      EXCEPTIONS join_type_invalid_left  = 2
                                                 join_type_invalid_right = 2
                                                 join_type_invalid_side  = 2
                                                 join_type_invalid_twice = 2 ).
                  IF sy-subrc <> 0.
                    RAISE join_addition_invalid.
                  ENDIF.
                ENDIF.
                IF sy-subrc = 5.
                  CONTINUE.
                ENDIF.

                APPEND: ls_join TO lt_join,
                        ls_join TO pt_join.
                l_join_found = aqqis_c_true.
                ls_headsg-state = aqqis_c_changed-updated.
                propose_on_condition_add_link( EXPORTING is_join = ls_join ).
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    IF l_join_found = aqqis_c_false.
      READ TABLE lt_join WITH KEY tabnamer = i_tabnamer
                                  tabnamel = i_tabnamel
                                  TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        RAISE no_further_joins_found.
      ENDIF.

      READ TABLE lt_join WITH KEY tabnamer = i_tabnamel
                                  tabnamel = i_tabnamer
                                  TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        RAISE no_further_joins_found.
      ENDIF.

      RAISE no_joins_found.
    ENDIF.

    p_join_data_r->set_info( EXPORTING i_headsg = ls_headsg ).
    cnvt_table_to_old( ).

  ENDMETHOD.                    "propose_on_condition


  METHOD propose_on_condition_add_link.

    DATA: l_tabix_l TYPE sytabix,
          l_tabix_r TYPE sytabix.

    FIELD-SYMBOLS: <tobj_join_l> TYPE aqstobjjoi,
                   <tobj_join_r> TYPE aqstobjjoi,
                   <fobj_join_l> TYPE aqsfobjjoi,
                   <fobj_join_r> TYPE aqsfobjjoi.

    READ TABLE p_t_tobj_join ASSIGNING <tobj_join_l> WITH KEY tname = is_join-tabnamel.
    READ TABLE <tobj_join_l>-fobj ASSIGNING <fobj_join_l> WITH KEY fname = is_join-colnamel.
    l_tabix_l = sy-tabix.
    READ TABLE p_t_tobj_join ASSIGNING <tobj_join_r> WITH KEY tname = is_join-tabnamer.
    READ TABLE <tobj_join_r>-fobj ASSIGNING <fobj_join_r> WITH KEY fname = is_join-colnamer.
    l_tabix_r = sy-tabix.
    create_link( EXPORTING ir_tabl = <tobj_join_l>-tabref
                           ir_tabr = <tobj_join_r>-tabref
                           i_rowl  = l_tabix_l
                           i_rowr  = l_tabix_r ).
  ENDMETHOD.                    "propose_on_condition_add_link


  METHOD recreate_links.

    DATA: ls_join  TYPE aqq_s_join,
          l_fnamel TYPE aqs_fname,
          l_fnamer TYPE aqs_fname,
          l_text   TYPE aqq_text.

    FIELD-SYMBOLS: <links_join> TYPE aqslinkjoi.

* Links
    LOOP AT pt_join INTO ls_join.
      CASE ls_join-type.
        WHEN aqqis_c_join_typ-inner.
        WHEN aqqis_c_join_typ-left_outer.
          l_text = text-013.  "left outer join
        WHEN OTHERS.
      ENDCASE.

      CONCATENATE ls_join-tabnamel '-' ls_join-colnamel INTO l_fnamel.
      CONCATENATE ls_join-tabnamer '-' ls_join-colnamer INTO l_fnamer.
      READ TABLE p_t_links_join ASSIGNING <links_join> WITH KEY fnameleft  = l_fnamel
                                                                fnameright = l_fnamer.
      <links_join>-linkref->set_properties( i_linkstyle = p_default_linkstyle
                                            i_text      = l_text ).
      p_r_join_cntrl->add_link( i_r_link = <links_join>-linkref ).
    ENDLOOP.
    p_r_join_cntrl->send_data_to_frontend( ).
  ENDMETHOD.                    "recreate_links

  METHOD reduce_distance.

    DATA: lt_tpos     TYPE aqq_t_tpos,
          l_tabwidth  TYPE i,
          l_tabheight TYPE i,
          l_tabix     TYPE sytabix,
          l_x1        TYPE int4,
          l_x2        TYPE int4,
          l_y1        TYPE int4,
          l_y2        TYPE int4,
          l_distx     TYPE int4,
          l_disty     TYPE int4.

    FIELD-SYMBOLS: <tpos1> TYPE aqq_s_tpos,
                   <tpos2> TYPE aqq_s_tpos.

    l_tabwidth  = '400'.
    l_tabheight = '100'.

    lt_tpos[]   = pt_tpos[].

* x-Richtung
    SORT lt_tpos BY xpos.
    READ TABLE lt_tpos ASSIGNING <tpos1> INDEX 1.
    CHECK sy-subrc = 0.
    IF <tpos1>-xpos > 100.
      l_distx = <tpos1>-xpos - 50.
      LOOP AT lt_tpos ASSIGNING <tpos1>.
        <tpos1>-xpos = <tpos1>-xpos - l_distx.
      ENDLOOP.
    ENDIF.

    LOOP AT lt_tpos ASSIGNING <tpos1>.
      l_tabix = sy-tabix + 1.
      READ TABLE lt_tpos ASSIGNING <tpos2> INDEX l_tabix.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.

      DO.
        l_x1       = <tpos1>-xpos + l_tabwidth + 50.
        l_x2       = <tpos2>-xpos - 100.
        IF l_x2 < l_x1.
          EXIT.
        ENDIF.
        <tpos2>-xpos = <tpos2>-xpos - 100.
      ENDDO.
    ENDLOOP.

* y-Richtung
    SORT lt_tpos BY ypos.
    READ TABLE lt_tpos ASSIGNING <tpos1> INDEX 1.
    CHECK sy-subrc = 0.
    IF <tpos1>-ypos > 100.
      l_disty = <tpos1>-ypos - 50.
      LOOP AT lt_tpos ASSIGNING <tpos1>.
        <tpos1>-ypos = <tpos1>-ypos - l_disty.
      ENDLOOP.
    ENDIF.

    LOOP AT lt_tpos ASSIGNING <tpos1>.
      l_tabix = sy-tabix + 1.
      READ TABLE lt_tpos ASSIGNING <tpos2> INDEX l_tabix.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.

      DO.
        l_y1       = <tpos1>-ypos + l_tabheight + 50.
        l_y2       = <tpos2>-ypos - 100.
        IF l_y2 < l_y1.
          EXIT.
        ENDIF.
        <tpos2>-ypos = <tpos2>-ypos - 100.
      ENDDO.
    ENDLOOP.

    pt_tpos[] = lt_tpos[].

    cnvt_table_to_old( ).
  ENDMETHOD.                    "reduce_distance

  METHOD referenzfield.

    DATA:   l_feldname TYPE aqs_fname,
            l_refname  TYPE aqs_fname,
            ls_exdbfi  TYPE aqsexdbfi,
            lt_exdbfi  TYPE aqq_t_exdbfi.

    CALL FUNCTION 'RSAQ_CNTRL_BUILD_EXDBFI'
      EXPORTING
        i_tab     = i_tname
      IMPORTING
        et_exdbfi = lt_exdbfi.

    READ TABLE lt_exdbfi INTO ls_exdbfi WITH KEY ddic-fieldname = is_tab-feld.

    IF ls_exdbfi-info-curry = 'F' OR ls_exdbfi-info-curry = 'M'.
      CONCATENATE ls_exdbfi-ddic-reftable '-' ls_exdbfi-ddic-reffield
                  INTO l_refname.
*   Referenzfeld: &1
      MESSAGE i027(aqqis_cntrl) WITH l_refname.
    ELSE.
      CONCATENATE ls_exdbfi-ddic-tabname '-' ls_exdbfi-ddic-fieldname
                  INTO l_feldname.
*   &1 besitzt kein Referenzfeld
      MESSAGE i028(aqqis_cntrl) WITH l_feldname.
    ENDIF.
  ENDMETHOD.                    "referenzfield

  METHOD rel_2_abs.

    DATA: ls_tobj_join TYPE aqstobjjoi.

    READ TABLE p_t_tobj_join INTO ls_tobj_join WITH KEY tname = is_dbjt-table.

*--- abs
    es_tpos_abs-tname     = is_dbjt-table.
    es_tpos_abs-r_table   = ls_tobj_join-tabref.
*  es_tpos_abs-LEFTPOS   = is_dbjt-left.
*  es_tpos_abs-TOPPOS    = is_dbjt-top.
*  es_tpos_abs-RIGHTPOS  = is_dbjt-left + is_dbjt-width.
*  es_tpos_abs-BOTTOMPOS = is_dbjt-top + is_dbjt-height.
    es_tpos_abs-leftpos   = is_dbjt-left_vz.
    es_tpos_abs-toppos    = is_dbjt-top_vz.
    es_tpos_abs-rightpos  = is_dbjt-left_vz + is_dbjt-width_vz.
    es_tpos_abs-bottompos = is_dbjt-top_vz + is_dbjt-height_vz.

  ENDMETHOD.                                                "rel_2_abs

  METHOD remove_link.

    DATA: l_s_link TYPE aqslinkjoi,
          l_index  TYPE sytabix,
          lt_join  TYPE aqq_t_join,
          l_tnamel TYPE aqs_tname,
          l_tnamer TYPE aqs_tname,
          l_fnamel TYPE aqs_fname,
          l_fnamer TYPE aqs_fname.

* removes a link from control and iset
    IF p_mode = aqqis_c_mode-display.
*   Funktion nur im #nderungsmodus unterst#tzt
      IF NOT r_doit IS INITIAL.
        r_doit->o_ok = aqqis_c_false.
      ENDIF.
      MESSAGE s005(aqqis_cntrl).
      EXIT.
    ENDIF.

    lt_join[] = pt_join[].

* setzen #nderungsflag
    set_changed( EXPORTING i_changed = aqqis_c_changed-updated ).

    CHECK NOT ir_link IS INITIAL.

    READ TABLE p_t_links_join WITH KEY linkref = ir_link INTO l_s_link.
    IF sy-subrc = 0.
      l_index = sy-tabix.

*   delete from control
      p_r_join_cntrl->delete_objects( EXPORTING i_r_link  = ir_link ).
      DELETE p_t_links_join INDEX l_index.

      cnvt_fname_one_2_two( EXPORTING i_fname = l_s_link-fnameleft
                            IMPORTING e_tname = l_tnamel
                                      e_fname = l_fnamel ).

      cnvt_fname_one_2_two( EXPORTING i_fname = l_s_link-fnameright
                            IMPORTING e_tname = l_tnamer
                                      e_fname = l_fnamer ).

* Datentabelle
      DELETE TABLE lt_join WITH TABLE KEY tabnamel = l_tnamel
                                          tabnamer = l_tnamer
                                          colnamel = l_fnamel
                                          colnamer = l_fnamer.

      DELETE TABLE lt_join WITH TABLE KEY tabnamel = l_tnamel
                                          tabnamer = l_tnamer
                                          colnamel = l_fnamel
                                          colnamer = l_fnamer.
    ENDIF.

    pt_join[] = lt_join[].
    cnvt_table_to_old( ).

  ENDMETHOD.                    "remove_link


  METHOD remove_tobject.

    DATA: l_t_objects   TYPE aqq_t_objects,
          l_lin_objects TYPE i,
          lt_del_links  TYPE aqq_t_links,
          ls_link       TYPE aqslinks,
          lt_dban       TYPE aqtdban,
          lt_dbsg       TYPE aqtdbsg.

    FIELD-SYMBOLS: <objects>   TYPE aqsobjects,
                   <tobj_join> TYPE aqstobjjoi,
                   <link>      TYPE aqslinkjoi.

    IF p_mode = aqqis_c_mode-display.
*   Funktion nur im #nderungsmodus unterst#tzt
      MESSAGE s005(aqqis_cntrl).
      EXIT.
    ENDIF.

    l_t_objects = p_r_join_cntrl->get_selected_objects( ).
    LOOP AT l_t_objects TRANSPORTING NO FIELDS WHERE NOT r_table IS INITIAL
                                               AND   rowindex = 0.
      l_lin_objects = l_lin_objects + 1.
    ENDLOOP.

    IF l_lin_objects = 0.
*   Kein Objekt markiert.
      MESSAGE s006(aqqis_cntrl).
      EXIT.
    ELSEIF l_lin_objects > 1.
*   Mehrere Objekte markiert
      MESSAGE s007(aqqis_cntrl).
      EXIT.
    ENDIF.

    READ TABLE l_t_objects ASSIGNING <objects> INDEX 1.
    READ TABLE p_t_tobj_join ASSIGNING <tobj_join> WITH KEY tabref = <objects>-r_table.
    IF sy-subrc NE 0.
*   fatal error
      MESSAGE a008(aqqis_cntrl) WITH 'ZCL_ZAAQB_QUERY_JOIN_CNTRL' 'REMOVE_TOBJECT'.
    ENDIF.

    check_remove_tobject( EXPORTING  i_tname                = <tobj_join>-tname
                          EXCEPTIONS only_one_table         = 1
                                     table_is_used          = 2
                                     no_remove_in_quickview = 3 ).
    IF     sy-subrc = 1.
*   Es d#rfen nicht alle Tabellen gel#scht werden
*>>>---zaaqb
*      MESSAGE s009(aqqis_cntrl).
*      EXIT.
*<<<---zaaqb
    ELSEIF sy-subrc = 2.
*   Tabelle &1 wird noch verwendet
      MESSAGE s010(aqqis_cntrl) WITH <tobj_join>-tname.
      EXIT.
    ELSEIF sy-subrc = 3.
*   Tabellen des Joins k#nnen im QuickViewer nicht mehr gel#scht werden
      MESSAGE s011(aqqis_cntrl).
      EXIT.
    ENDIF.

    set_changed( EXPORTING i_changed = aqqis_c_changed-updated ).

* L#schen Datentabellen
*   beim L#schen m#ssen folgende Tabellen ber#cksichtigt werden
*   dbjt   - verwendete Tabellen
*   dbsg   - Struktur logische DB -> Baum
*            Join                 -> alle Jointabellen
*            HR-DB                -> Infotypen
*            wird parallel zur dbjt gehalten
*   dbsf   - Felder aus Sachgebiet
*            hier mu# gepr#ft werden, ob noch Felder verwendet werden
*            falls ja, wird das L#schen abgelehnt
*            wird in ZCL_ZAAQB_QUERY_JOIN_CNTRL gepr#ft
*   dban   - Aliasnamen, also ggf.
*   dbjc   - Tabellen-Join-Bedingung

    DELETE pt_join   WHERE tabnamel = <tobj_join>-tname.
    DELETE pt_join   WHERE tabnamer = <tobj_join>-tname.
    DELETE pt_tpos   WHERE tabname  = <tobj_join>-tname.
    DELETE pt_tfield WHERE tabname  = <tobj_join>-tname.
    p_join_data_r->get_info( IMPORTING et_dban = lt_dban
                                       et_dbsg = lt_dbsg ).
    LOOP AT lt_dbsg TRANSPORTING NO FIELDS WHERE name = <tobj_join>-tname.
      DELETE lt_dbsg INDEX sy-tabix.
    ENDLOOP.
* L#schen Alias-Beziehung
*  loop at lt_dban transporting no fields where alias = <tobj_join>-tname.
*    delete lt_dban index sy-tabix.
*  endloop.
    p_join_data_r->set_info( EXPORTING it_dban = lt_dban
                                       it_dbsg = lt_dbsg ).

* L#schen Frontend-Komponenten
    LOOP AT p_t_links_join ASSIGNING <link> WHERE tnameleft  = <tobj_join>-tname
                                               OR tnameright = <tobj_join>-tname.
      ls_link-r_link = <link>-linkref .
      APPEND ls_link TO lt_del_links.
    ENDLOOP.

    p_r_join_cntrl->delete_objects( EXPORTING i_r_table  = <tobj_join>-tabref ).
    p_r_join_cntrl->delete_objects( EXPORTING i_t_link   = lt_del_links ).

    DELETE p_t_links_join WHERE tnameleft  = <tobj_join>-tname.
    DELETE p_t_links_join WHERE tnameright = <tobj_join>-tname.
    DELETE p_t_tobj_join  WHERE tabref      = <objects>-r_table.

    cnvt_table_to_old( ).

  ENDMETHOD.                    "remove_tobject

  METHOD reorder_joins.
* user wants to fix table positions at new positions,
* we reorder all the joins, check for (now) illegal jointypes,
* correct them and rebuild joins at the frontend.
* if we are operationg on a functional area,
* we also check that the FIRST table has not switched order.

* the following statements are currently not implemented by the ABAP
* SQL interface:
*
* I)        T1 ----LO------T2              r.h.s. table can be
*                          T2                     linked to only one
*                T3---LO---T2                     table to left
*                                                 via LO join.
*
* II)    T1---LO---T2---LO---T3            r.h.s. table of a LO join
*                                                 cannot be l.h.s table
*                                                 of another l.o. join.

    DATA: ls_first_tpos TYPE        aqq_s_tpos,
          lt_save_tpos  TYPE        aqq_t_tpos,
          lt_tpos       TYPE        aqq_t_tpos,
          lt_join       TYPE        aqq_t_join,
          ls_join       TYPE        aqq_s_join,
          l_p           TYPE        int4,
          l_l           TYPE        int4,
          l_r           TYPE        int4,
          l_wa_join2    TYPE        aqq_s_join.

    lt_save_tpos[] = it_tpos_old[].
    lt_tpos[]      = it_tpos_new[].
    lt_join[]      = pt_join[].

    SORT lt_save_tpos BY xpos.
    READ TABLE lt_save_tpos INTO ls_first_tpos INDEX 1.

    SORT lt_tpos BY xpos.

    LOOP AT lt_join INTO ls_join.
      l_p = sy-tabix.
      READ TABLE lt_tpos WITH KEY tabname = ls_join-tabnamel
                                  TRANSPORTING NO FIELDS.
      l_l = sy-tabix.
      READ TABLE lt_tpos WITH KEY tabname = ls_join-tabnamer
                                  TRANSPORTING NO FIELDS.
      l_r = sy-tabix.
      IF ( l_l > l_r ).      " join has to be reversed.
        l_wa_join2       = ls_join.
        ls_join-tabnamer = l_wa_join2-tabnamel.
        ls_join-tabnamel = l_wa_join2-tabnamer.
        ls_join-colnamer = l_wa_join2-colnamel.
        ls_join-colnamel = l_wa_join2-colnamer.
        MODIFY lt_join FROM ls_join INDEX l_p.
      ENDIF.
    ENDLOOP.

* by rearranging tables, the user might have created an
* illegal join-situation II): * T1--LO1--T2--LO---T3
*                                (join)    (wa_join2)
*
* all these joins (wa-join2) are reset to inner joins.
    DATA: l_forced TYPE flag.

    l_forced = aqqis_c_false.

    SORT lt_join BY tabnamel tabnamer.
    LOOP AT lt_join INTO ls_join WHERE type = aqqis_c_join_typ-left_outer.
      LOOP AT lt_join INTO l_wa_join2 WHERE tabnamel = ls_join-tabnamer
                                        AND type     = aqqis_c_join_typ-left_outer.
        l_wa_join2-type = aqqis_c_join_typ-inner.
        MODIFY lt_join FROM l_wa_join2 INDEX sy-tabix.
        l_forced = aqqis_c_true.
      ENDLOOP.
    ENDLOOP.

* he might have created inconsistent joins.
* these are corrected here.
    DATA: l_ok TYPE flag.

    LOOP AT lt_join INTO ls_join WHERE type = aqqis_c_join_typ-left_outer.
*   recheck this, since state is changed in loop!
      READ TABLE lt_join WITH KEY tabnamel = ls_join-tabnamer
                                  type     = aqqis_c_join_typ-left_outer
                                  TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        l_ok = aqqis_c_true.
        LOOP AT lt_join INTO l_wa_join2 WHERE tabnamer = ls_join-tabnamer
                                          AND type     = aqqis_c_join_typ-inner.
*       (normal joins leading into this table.)
          READ TABLE lt_join WITH KEY tabnamer = l_wa_join2-tabnamel
                                      type     = aqqis_c_join_typ-left_outer
                                      TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.          " one of these is right table of other
            l_ok = aqqis_c_false.   " left outer join!
          ENDIF.
        ENDLOOP.

        IF l_ok = aqqis_c_true.     " we can change all these ...
          LOOP AT lt_join INTO l_wa_join2 WHERE tabnamer = ls_join-tabnamer
                                            AND type     = aqqis_c_join_typ-inner.
            l_wa_join2-type = aqqis_c_join_typ-left_outer.
            MODIFY lt_join FROM l_wa_join2 INDEX sy-tabix.
            l_forced = aqqis_c_true.
          ENDLOOP.
        ELSE.
          ls_join-type = aqqis_c_join_typ-inner.
          MODIFY pt_join FROM ls_join.                      "#EC *
          l_forced = aqqis_c_true.
        ENDIF.
      ELSE.
        ls_join-type = aqqis_c_join_typ-inner.
        MODIFY pt_join FROM ls_join.                        "#EC *
        l_forced = aqqis_c_true.
      ENDIF.
    ENDLOOP.

* now we check for illegal join situation 1:
* e.g. T1--T2 was reset to inner join by above procedure:
* i.e.
*               T1 ---(join)------------ T2
*                                        T2
*                    T3------LO----------T2
*                        (wa_join2)
* These joins (wa_join2)  MUST be reset to inner joins too.
*
    LOOP AT lt_join INTO ls_join WHERE type = aqqis_c_join_typ-inner.
      LOOP AT lt_join INTO l_wa_join2 WHERE tabnamer = ls_join-tabnamer.
        IF l_wa_join2-type = aqqis_c_join_typ-left_outer.
          l_wa_join2-type = aqqis_c_join_typ-inner.
          MODIFY lt_join FROM l_wa_join2.
          l_forced = aqqis_c_true.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    DATA: l_index TYPE i.
    LOOP AT lt_join INTO ls_join WHERE type = aqqis_c_join_typ-left_outer.
      l_index = sy-tabix.
      LOOP AT lt_join INTO l_wa_join2 WHERE tabnamer = ls_join-tabnamer.
        IF l_wa_join2-tabnamel <> ls_join-tabnamel.
          l_wa_join2-type = aqqis_c_join_typ-inner.
          ls_join-type = aqqis_c_join_typ-inner.
          MODIFY lt_join FROM l_wa_join2.
          MODIFY lt_join FROM ls_join INDEX l_index.
          l_forced = aqqis_c_true.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    IF l_forced = aqqis_c_true.
*   Beachten Sie die #nderung von Join-Typen
      MESSAGE i017(aqqis_cntrl).
    ENDIF.
    e_forced = l_forced.

    pt_join[] = lt_join[].

  ENDMETHOD.                    "reorder_joins


  METHOD save_as_jpg.

    DATA:   l_filename   TYPE rlgrap-filename,
            l_file       TYPE string,
            l_path       TYPE string,
            l_fullpath   TYPE string,
            l_useraction TYPE i.

    CALL METHOD cl_gui_frontend_services=>file_save_dialog
      EXPORTING
*       WINDOW_TITLE         =
        default_extension    = 'jpg'
*       DEFAULT_FILE_NAME    =
        file_filter          = '*.jpg'
*       INITIAL_DIRECTORY    =
      CHANGING
        filename             = l_file
        path                 = l_path
        fullpath             = l_fullpath
        user_action          = l_useraction
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        OTHERS               = 4.

    IF sy-subrc = 0.

      IF l_useraction = 0.
        l_filename = l_fullpath.

        p_r_join_cntrl->save_as_jpg( EXPORTING i_filename = l_filename ).
*     Die Datei &1 wurde erfolgreich gesichert
        MESSAGE s018(aqqis_cntrl) WITH l_fullpath.
      ELSEIF l_useraction = 9.
*     Aktion abgebrochen
        MESSAGE s001(aqqis_cntrl).
      ENDIF.

    ELSE.
*   interner Fehler beim Erzeugen einer jpg-Datei aufgetreten
      MESSAGE s019(aqqis_cntrl).
    ENDIF.

  ENDMETHOD.                    "save_as_jpg


  METHOD scale.

    DATA: l_scalex      TYPE i,
          l_scaley      TYPE i,
          l_x1          TYPE i,                "von der ersten Tabelle x-Position (links)
          l_y1          TYPE i,                "von der ersten Tabelle y-Position (top)
          "die neuen Positionen aller weiteren Tabellen (ab sy-tabix 2)
          "werden relative zur ersten berechnet
          l_tabix       TYPE sy-tabix,
          ls_tobj_join  TYPE aqstobjjoi,
          lt_tobj_join  TYPE aqq_t_tobj_join,
          lt_dbjt       TYPE aqtdbjt,
          lt_tpos       TYPE aqq_t_tpos,
          lt_links_join TYPE aqq_t_links_join,
          lt_join       TYPE aqq_t_join.

    FIELD-SYMBOLS: <tobj_join>  TYPE aqstobjjoi,
                   <links_join> TYPE aqslinkjoi,
                   <tpos>       TYPE aqq_s_tpos,
                   <dbjt>       TYPE aqdbjt.

*break rueger.
*--- besorgen der Skalierungsfaktoren -> Popup
    skalierung_popup( IMPORTING  e_scalex  = l_scalex
                                 e_scaley  = l_scaley
                      EXCEPTIONS cancelled = 1 ).
    IF sy-subrc NE 0.
*   Aktion abgebrochen
      MESSAGE s001(aqqis_cntrl).
      EXIT.
    ENDIF.

* setzen #nderungsflag
    set_changed( EXPORTING i_changed = aqqis_c_changed-updated ).

    lt_tpos[] = pt_tpos[].

* Positionen tpos, dbjt
    LOOP AT lt_tpos ASSIGNING <tpos>.
      l_tabix = sy-tabix.

      IF l_tabix = 1.
        l_x1 = <tpos>-xpos.
        l_y1 = <tpos>-ypos.
      ELSE.

* Skalierungsfaktor ber#cksichtigen
        <tpos>-ypos = ( ( <tpos>-ypos - l_y1 ) * l_scaley / 100 ) + l_y1.
        <tpos>-xpos = ( ( <tpos>-xpos - l_x1 ) * l_scalex / 100 ) + l_x1.
      ENDIF.
    ENDLOOP.
    pt_tpos[] = lt_tpos[].
    cnvt_table_to_old_dbjt( ).


    p_join_data_r->get_info( IMPORTING et_dbjt = lt_dbjt ).
    LOOP AT lt_dbjt ASSIGNING <dbjt>.
* Tabelle l#schen
      READ TABLE p_t_tobj_join ASSIGNING <tobj_join> WITH KEY tname = <dbjt>-table.
      CHECK sy-subrc = 0.
      l_tabix = sy-tabix.
      p_r_join_cntrl->delete_objects( i_r_table = <tobj_join>-tabref ).

* Tabelle neu aufbauen
      CLEAR: ls_tobj_join.
      fill_table_fields( EXPORTING is_dbjt       = <dbjt>
                         IMPORTING es_tobj_join  = ls_tobj_join ).

      APPEND ls_tobj_join TO lt_tobj_join.
      MODIFY p_t_tobj_join FROM ls_tobj_join INDEX l_tabix.
    ENDLOOP.

*--- Tabellen an das Control senden
    send_tables_to_cntrl( EXPORTING i_t_tobj_join = lt_tobj_join ).

*--- alle links l#schen
    lt_links_join[] = p_t_links_join[].
    lt_join[]       = pt_join[].
    LOOP AT lt_links_join ASSIGNING <links_join>.
      remove_link( EXPORTING ir_link = <links_join>-linkref ).
    ENDLOOP.
*--- Links anlegen
    pt_join[] = lt_join[].
    create_links( pt_join ).

*--- alles an die Oberfl#che senden
    p_r_join_cntrl->send_data_to_frontend( ).

    cnvt_table_to_old_dbjc( ).
  ENDMETHOD.                    "scale


  METHOD search.
    DATA: l_t_objects   TYPE aqq_t_objects,
          l_lin_objects TYPE i,
          lt_tab        TYPE aqq_t_tab,
          l_tname       TYPE aqs_tname,
          l_row         TYPE sytabix,
          l_found       TYPE boolean,
          l_s_tobj_join TYPE aqstobjjoi.

    FIELD-SYMBOLS: <objects>   TYPE aqsobjects,
                   <tobj_join> TYPE aqstobjjoi.

*--- selektierte Objekte holen und pr#fen, ob genau ein Objekt markiert ist
    l_t_objects = p_r_join_cntrl->get_selected_objects( ).

    LOOP AT l_t_objects TRANSPORTING NO FIELDS WHERE NOT r_table  IS INITIAL
                                               AND       rowindex IS INITIAL.
      l_lin_objects = l_lin_objects + 1.
    ENDLOOP.

    IF l_lin_objects > 1.
*   Mehrere Objekte markiert
      MESSAGE s007(aqqis_cntrl).
      EXIT.
    ELSEIF l_lin_objects = 0.
*   Kein Objekt markiert.
      MESSAGE s006(aqqis_cntrl).
      EXIT.
    ENDIF.

    READ TABLE l_t_objects ASSIGNING <objects> INDEX 1.
    READ TABLE p_t_tobj_join ASSIGNING <tobj_join> WITH KEY tabref = <objects>-r_table.
    get_tab( EXPORTING i_tabname = <tobj_join>-tname
             IMPORTING et_tab    = lt_tab ).

*--- Suchpopup
    l_tname = <tobj_join>-tname.
    CALL FUNCTION 'RSAQ_CNTRL_SEARCH_0400'
      EXPORTING
        i_tname   = l_tname
      IMPORTING
        es_search = ps_search
      EXCEPTIONS
        not_found = 1
        cancelled = 2
        OTHERS    = 3.

    IF sy-subrc <> 0.
*   Aktion abgebrochen
      MESSAGE s001(aqqis_cntrl).
      EXIT.
    ENDIF.

* globale Variable setzen
    p_start_tabix = 1.
    p_search_obj  = <objects>-r_table.

    search_in_tabobj( EXPORTING is_search     = ps_search
                                it_tab        = lt_tab          "Felder der markierten Tabelle
                                i_start_tabix = p_start_tabix
                                i_tname       = l_tname
                      IMPORTING e_found       = l_found
                                e_row         = l_row
                                es_tobj_join  = l_s_tobj_join ).

    IF     l_found = aqqis_c_true.
*   Treffer - Zeile: &1
*   todo
      MESSAGE s023(aqqis_cntrl) WITH l_row.
      <objects>-rowindex = l_row.
      p_r_join_cntrl->set_selected_objects( l_t_objects ).
    ELSEIF l_found = aqqis_c_false.
*   Suchbegriff wurde nicht gefunden
      MESSAGE s024(aqqis_cntrl).
      EXIT.
    ENDIF.

  ENDMETHOD.                    "search


  METHOD search_domain_in_tabobj.

    DATA: l_found     TYPE flag,
          l_tabix     TYPE sytabix,
          l_tabix_end TYPE sytabix.

    FIELD-SYMBOLS: <tab>       TYPE aqq_s_tab,
                   <tobj_join> TYPE aqstobjjoi.

    l_found = aqqis_c_false.

    LOOP AT it_tab ASSIGNING <tab> FROM i_start_tabix.
      l_tabix       = sy-tabix.
      p_start_tabix = l_tabix + 1.

      IF <tab>-dom CS is_search-searchdom.

        l_found       = aqqis_c_true.

        READ TABLE p_t_tobj_join ASSIGNING <tobj_join> WITH KEY tname = i_tname.
        READ TABLE <tobj_join>-fobj TRANSPORTING NO FIELDS WITH KEY fname = <tab>-feld.

        e_row        = sy-tabix.
        es_tobj_join = <tobj_join>.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF l_found = aqqis_c_false AND i_start_tabix > 1.
      l_tabix_end = i_start_tabix - 1.
      LOOP AT it_tab ASSIGNING <tab> FROM 1 TO l_tabix_end.
        l_tabix       = sy-tabix.
        p_start_tabix = l_tabix + 1.

        IF <tab>-dom CS is_search-searchdom.

          l_found       = aqqis_c_true.

          READ TABLE p_t_tobj_join ASSIGNING <tobj_join> WITH KEY tname = i_tname.
          READ TABLE <tobj_join>-fobj TRANSPORTING NO FIELDS WITH KEY fname = <tab>-feld.

          e_row        = sy-tabix.
          es_tobj_join = <tobj_join>.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    e_found = l_found.
  ENDMETHOD.                    "search_domain_in_tabobj

  METHOD search_in_tabobj.

    CASE is_search-art.
      WHEN aqqis_c_search-text.
        search_text_in_tabobj( EXPORTING is_search     = is_search
                                         it_tab        = it_tab
                                         i_start_tabix = i_start_tabix
                                         i_tname       = i_tname
                               IMPORTING e_found       = e_found
                                         e_row         = e_row
                                         es_tobj_join  = es_tobj_join ).

      WHEN aqqis_c_search-domain.
        search_domain_in_tabobj( EXPORTING is_search     = is_search
                                           it_tab        = it_tab
                                           i_start_tabix = i_start_tabix
                                           i_tname       = i_tname
                                 IMPORTING e_found       = e_found
                                           e_row         = e_row
                                           es_tobj_join  = es_tobj_join ).
      WHEN aqqis_c_search-stype.
        search_type_in_tabobj( EXPORTING is_search     = is_search
                                         it_tab        = it_tab
                                         i_start_tabix = i_start_tabix
                                         i_tname       = i_tname
                               IMPORTING e_found       = e_found
                                         e_row         = e_row
                                         es_tobj_join  = es_tobj_join ).
    ENDCASE.

  ENDMETHOD.                    "search_in_tabobj

  METHOD search_next.

    DATA: lt_tab         TYPE aqq_t_tab,
          ls_tobj_join   TYPE aqstobjjoi,
          lt_objects     TYPE aqq_t_objects,
          lt_objects_sel TYPE aqq_t_objects,
          l_row          TYPE sytabix,
          l_found        TYPE boolean,
          l_lin_objects  TYPE i,
          l_lin_tab      TYPE i.

    FIELD-SYMBOLS: <tobj_join> TYPE aqstobjjoi,
                   <objects>   TYPE aqsobjects.

    IF p_search_obj IS INITIAL.
*   Es sind keine Suchbegriffe vorhanden
      MESSAGE s025(aqqis_cntrl).
      EXIT.
    ENDIF.

*--- selektierte Objekte holen und pr#fen, ob genau ein Objekt markiert ist
    lt_objects = p_r_join_cntrl->get_selected_objects( ).

    LOOP AT lt_objects ASSIGNING <objects> WHERE NOT r_table  IS INITIAL
                                           AND       rowindex IS INITIAL.
      l_lin_objects = l_lin_objects + 1.
      APPEND <objects> TO lt_objects_sel.
    ENDLOOP.
    p_r_join_cntrl->set_selected_objects( lt_objects_sel ).

    IF l_lin_objects > 1.
*   Mehrere Objekte markiert
      MESSAGE s007(aqqis_cntrl).
      EXIT.
    ELSEIF l_lin_objects = 0.
*   Kein Objekt markiert
      MESSAGE s006(aqqis_cntrl).
      EXIT.
    ENDIF.

    READ TABLE lt_objects ASSIGNING <objects> INDEX 1.
    READ TABLE p_t_tobj_join ASSIGNING <tobj_join> WITH KEY tabref = p_search_obj.
    IF <objects>-r_table NE p_search_obj.
*   Tabelle &1 ist nicht markiert
      MESSAGE s026(aqqis_cntrl) WITH <tobj_join>-tname.
      EXIT.
    ENDIF.

    get_tab( EXPORTING i_tabname = <tobj_join>-tname
             IMPORTING et_tab    = lt_tab ).

*--- wenn mit der Suche am Ende der Tabelle angekommen, wieder von vorne beginnen
    DESCRIBE TABLE lt_tab LINES l_lin_tab.
    IF l_lin_tab < p_start_tabix.
      p_start_tabix = 1.
    ENDIF.

    search_in_tabobj( EXPORTING is_search     = ps_search
                                it_tab        = lt_tab         "Felder der markierten Tabelle
                                i_start_tabix = p_start_tabix
                                i_tname       = <tobj_join>-tname
                      IMPORTING e_found       = l_found
                                e_row         = l_row
                                es_tobj_join  = ls_tobj_join ).

    IF     l_found = aqqis_c_true.
*   Treffer - Zeile: &1
      MESSAGE s023(aqqis_cntrl) WITH l_row.
      <objects>-rowindex = l_row.
      p_r_join_cntrl->set_selected_objects( lt_objects ).
    ELSEIF l_found = aqqis_c_false.
*   Suchbegriff wurde nicht gefunden
      MESSAGE s024(aqqis_cntrl).
      EXIT.
    ENDIF.

  ENDMETHOD.                    "search_next

  METHOD search_text_in_tabobj.

    DATA: l_found     TYPE flag,
          l_tabix     TYPE sytabix,
          l_tabix_end TYPE sytabix.

    FIELD-SYMBOLS: <tab>       TYPE aqq_s_tab,
                   <tobj_join> TYPE aqstobjjoi.

    l_found = aqqis_c_false.

    LOOP AT it_tab ASSIGNING <tab> FROM i_start_tabix.
      l_tabix = sy-tabix.
      p_start_tabix = l_tabix + 1.

      IF <tab>-feld  CS is_search-searchtext OR
         <tab>-ftext CS is_search-searchtext.

        l_found       = aqqis_c_true.

        READ TABLE p_t_tobj_join ASSIGNING <tobj_join> WITH KEY tname = i_tname.
        READ TABLE <tobj_join>-fobj TRANSPORTING NO FIELDS WITH KEY fname = <tab>-feld.

        e_row        = sy-tabix.
        es_tobj_join = <tobj_join>.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF l_found = aqqis_c_false AND i_start_tabix > 1.
      l_tabix_end = i_start_tabix - 1.
      LOOP AT it_tab ASSIGNING <tab> FROM 1 TO l_tabix_end.
        l_tabix       = sy-tabix.
        p_start_tabix = l_tabix + 1.

        IF <tab>-feld  CS is_search-searchtext OR
           <tab>-ftext CS is_search-searchtext.

          l_found       = aqqis_c_true.

          READ TABLE p_t_tobj_join ASSIGNING <tobj_join> WITH KEY tname = i_tname.
          READ TABLE <tobj_join>-fobj TRANSPORTING NO FIELDS WITH KEY fname = <tab>-feld.

          e_row        = sy-tabix.
          es_tobj_join = <tobj_join>.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
    e_found = l_found.

  ENDMETHOD.                    "search_text_in_tabobj

  METHOD search_type_in_tabobj.

    DATA: l_found     TYPE flag,
          l_tabix     TYPE sytabix,
          l_tabix_end TYPE sytabix.

    FIELD-SYMBOLS: <tab>       TYPE aqq_s_tab,
                   <tobj_join> TYPE aqstobjjoi.

    l_found = aqqis_c_false.

    LOOP AT it_tab ASSIGNING <tab> FROM i_start_tabix.
      l_tabix       = sy-tabix.
      p_start_tabix = l_tabix + 1.

      IF <tab>-dtype CS is_search-searchtype.
        l_found = aqqis_c_true.

        IF is_search-cleng IS INITIAL.
        ELSE.
          IF NOT <tab>-dleng = is_search-cleng.
            l_found = aqqis_c_false.
          ENDIF.
        ENDIF.

        IF is_search-decnumb IS INITIAL.
        ELSE.
          IF NOT <tab>-ddec = is_search-decnumb.
            l_found = aqqis_c_false.
          ENDIF.
        ENDIF.
      ENDIF.

      IF l_found = aqqis_c_true.
        READ TABLE p_t_tobj_join ASSIGNING <tobj_join> WITH KEY tname = i_tname.
        READ TABLE <tobj_join>-fobj TRANSPORTING NO FIELDS WITH KEY fname = <tab>-feld.

        e_row        = sy-tabix.
        es_tobj_join = <tobj_join>.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF l_found = aqqis_c_false AND i_start_tabix > 1.
      l_tabix_end = i_start_tabix - 1.

      LOOP AT it_tab ASSIGNING <tab> FROM 1 TO l_tabix_end.
        l_tabix       = sy-tabix.
        p_start_tabix = l_tabix + 1.

        IF <tab>-dtype CS is_search-searchtype.
          l_found = aqqis_c_true.

          IF is_search-cleng IS INITIAL.
          ELSE.
            IF NOT <tab>-dleng = is_search-cleng.
              l_found = aqqis_c_false.
            ENDIF.
          ENDIF.

          IF is_search-decnumb IS INITIAL.
          ELSE.
            IF NOT <tab>-ddec = is_search-decnumb.
              l_found = aqqis_c_false.
            ENDIF.
          ENDIF.
        ENDIF.

        IF l_found = aqqis_c_true.
          READ TABLE p_t_tobj_join ASSIGNING <tobj_join> WITH KEY tname = i_tname.
          READ TABLE <tobj_join>-fobj TRANSPORTING NO FIELDS WITH KEY fname = <tab>-feld.

          e_row        = sy-tabix.
          es_tobj_join = <tobj_join>.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    e_found = l_found.
  ENDMETHOD.                    "search_type_in_tabobj

  METHOD send_tables_to_cntrl.

    DATA: l_title      TYPE        aqq_title,
          l_tooltip    TYPE        aqtooltip,
          lt_tobj_join TYPE        aqq_t_tobj_join.

    FIELD-SYMBOLS: <tobj_join> TYPE aqstobjjoi.

    lt_tobj_join = i_t_tobj_join.
    LOOP AT lt_tobj_join ASSIGNING <tobj_join>.

      <tobj_join>-tabref->set_tabledata( EXPORTING i_t_table = <tobj_join>-fobj ) .

      <tobj_join>-tabref->set_table_properties( EXPORTING  i_title           = <tobj_join>-title
                                                           i_tooltip         = <tobj_join>-tooltip
                                                           i_level           = <tobj_join>-objlevel
                                                           i_linecolor       = aqqis_c_defval-linecolor
                                                           i_scrollbarcolor  = aqqis_c_defval-scrollbarcolor
                                                           i_s_position      = <tobj_join>-tpos ).

      <tobj_join>-tabref->set_table_attributes( EXPORTING i_moveable            = aqqis_c_true
                                                          i_resizeable          = aqqis_c_true
                                                          i_autoarranging       = aqqis_c_false
                                                          i_tableconnectable    = aqqis_c_false
                                                          i_allrowsconnectable  = aqqis_c_true
                                                          i_dragdroprows        = aqqis_c_false
                                                          i_selectablerows      = aqqis_c_true
                                                          i_multiselectablerows = aqqis_c_false
                                                          i_tooltip             = aqqis_c_false
                                                          i_vscrollbar          = aqqis_c_true
                                                          i_autocolwidth        = aqqis_c_true
                                                          i_autocolwidth_wh     = aqqis_c_false
                                                          i_hscrollbar          = aqqis_c_true ) .

****************************************************************************************
*
*    Columns
*
****************************************************************************************
*--- set title and tooltip of columns
*--- KEYICON
      CLEAR: l_title, l_tooltip.
      l_tooltip = text-009. " Schl#sselfeld
      <tobj_join>-tabref->set_column_properties(  EXPORTING i_column_nr     = 1
                                                            i_title         = l_title
                                                            i_tooltip       = l_tooltip
                                                            i_visible       = aqqis_c_false ) .

*--- KEYFLAG_ICON
      CLEAR: l_title, l_tooltip.
      l_tooltip = text-009. " Schl#sselfeld
      <tobj_join>-tabref->set_column_properties(  EXPORTING i_column_nr     = 2
                                                            i_title         = l_title
                                                            i_tooltip       = l_tooltip ).

*--- FNAME
      CLEAR: l_title, l_tooltip.
      l_tooltip = l_title = text-010. "technischer Name
      <tobj_join>-tabref->set_column_properties(  EXPORTING i_column_nr     = 3
                                                            i_title         = l_title
                                                            i_tooltip       = l_tooltip ).

*--- TXTLG
      CLEAR: l_title, l_tooltip.
      l_tooltip = l_title = text-011. "Langtext
      <tobj_join>-tabref->set_column_properties(  EXPORTING i_column_nr     = 4
                                                            i_title         = l_title
                                                            i_tooltip       = l_tooltip ).
*--- cells
      set_cell_properties( EXPORTING i_s_tobj_join = <tobj_join> ).

*--- add table to join
      p_r_join_cntrl->add_table( EXPORTING i_r_table =  <tobj_join>-tabref )  .

    ENDLOOP.
  ENDMETHOD.                    "send_tables_to_cntrl

  METHOD set_cell_properties.

    DATA: l_rowindex TYPE        int2,
          l_colindex TYPE        int2,
          l_icon     TYPE        aqicon.

    FIELD-SYMBOLS: <fobj> TYPE aqsfobjjoi.

    LOOP AT i_s_tobj_join-fobj ASSIGNING <fobj>.
      CLEAR: l_icon.

      l_rowindex = l_rowindex + 1.

      l_colindex = 2.
      i_s_tobj_join-tabref->set_cell_properties( EXPORTING  i_rowindex    = l_rowindex
                                                            i_colindex    = l_colindex
                                                            i_icon        = <fobj>-keyicon
                                                 EXCEPTIONS row_not_exist = 1
                                                            OTHERS        = 2 ).
    ENDLOOP.

  ENDMETHOD.                    "set_cell_properties

  METHOD set_changed.

    DATA: ls_headsg TYPE aqhdsg.

    p_join_data_r->get_info( IMPORTING e_headsg = ls_headsg ).
    ls_headsg-state = i_changed.
    p_join_data_r->set_info( EXPORTING i_headsg = ls_headsg ).

  ENDMETHOD.                    "set_changed


  METHOD skalierung_popup.

    DATA: l_scalex TYPE aqqproz,
          l_scaley TYPE aqqproz.

    CALL FUNCTION 'RSAQ_CNTRL_SCALE'
      IMPORTING
        e_x       = l_scalex
        e_y       = l_scaley
      EXCEPTIONS
        cancelled = 1.

    IF sy-subrc NE 0.
      RAISE cancelled.
    ELSE.
      e_scalex = l_scalex.
      e_scaley = l_scaley.
    ENDIF.

  ENDMETHOD.                    "skalierung_popup


  METHOD synchronize_control_data.

    DATA: ls_links_join_dummy TYPE aqslinkjoi.

    FIELD-SYMBOLS: <tpos>       TYPE aqq_s_tpos,
                   <join>       TYPE aqq_s_join,
                   <tobj_join>  TYPE aqstobjjoi,
                   <links_join> TYPE aqslinkjoi.

* p_t_tobj_join - Tabellenobjekte
    LOOP AT it_tpos ASSIGNING <tpos>.
      READ TABLE p_t_tobj_join ASSIGNING <tobj_join> WITH KEY tname = <tpos>-tabname.
      <tobj_join>-tpos-leftpos   = <tpos>-xpos.
      <tobj_join>-tpos-toppos    = <tpos>-ypos.
      <tobj_join>-tpos-rightpos  = <tpos>-xpos + <tpos>-width.
      <tobj_join>-tpos-bottompos = <tpos>-ypos + <tpos>-height.
    ENDLOOP.

* p_t_links_join - Linkobjekte
    LOOP AT pt_join ASSIGNING <join>.
      READ TABLE p_t_links_join WITH KEY tnameleft  = <join>-tabnamel
                                         tnameright = <join>-tabnamer
                                         TRANSPORTING NO FIELDS.

      IF sy-subrc NE 0. " linke und rechte Seite m#ssen getauscht werden.
        READ TABLE p_t_links_join WITH KEY tnameleft  = <join>-tabnamer
                                           tnameright = <join>-tabnamel
                                           TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
*       fatal error
          MESSAGE a008(aqqis_cntrl) WITH 'ZCL_ZAAQB_QUERY_JOIN_CNTRL' 'SYNCHRONIZE_CONTROL_DATA'.
        ENDIF.
        LOOP AT p_t_links_join ASSIGNING <links_join> WHERE tnameleft  = <join>-tabnamer
                                                        AND tnameright = <join>-tabnamel.
          ls_links_join_dummy = <links_join>.
          <links_join>-tnameleft  = ls_links_join_dummy-tnameright.
          <links_join>-fnameleft  = ls_links_join_dummy-fnameright.
          <links_join>-tnameright = ls_links_join_dummy-tnameleft.
          <links_join>-fnameright = ls_links_join_dummy-fnameleft.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "synchronize_control_data



  METHOD zoomin.

    DATA: l_zoom   TYPE i,
          l_r_pers TYPE REF TO cl_query_join_pers.

    l_r_pers = cl_query_join_pers=>factory( ).

    set_changed( EXPORTING i_changed = aqqis_c_false ).

    l_zoom = p_r_join_cntrl->get_zoom( ).
    ADD 10 TO l_zoom.

    p_r_join_cntrl->set_zoom( EXPORTING i_zoom     = l_zoom
                                        i_autozoom = aqqis_c_false ).
    l_r_pers->p_s_data-zoom = l_zoom.

* Zoom: &1 %
    MESSAGE s014(aqqis_cntrl) WITH l_zoom.

  ENDMETHOD.                    "zoomin

  METHOD zoomout.

    DATA: l_zoom   TYPE i,
          l_r_pers TYPE REF TO cl_query_join_pers.

    l_r_pers = cl_query_join_pers=>factory( ).

    set_changed( EXPORTING i_changed = aqqis_c_false ).

    l_zoom = p_r_join_cntrl->get_zoom( ).
    SUBTRACT 10 FROM l_zoom.

    p_r_join_cntrl->set_zoom( EXPORTING i_zoom     = l_zoom
                                        i_autozoom = aqqis_c_false ).
    l_r_pers->p_s_data-zoom = l_zoom.

* Zoom: &1 %
    MESSAGE s014(aqqis_cntrl) WITH l_zoom.

  ENDMETHOD.                    "zoomout

ENDCLASS. "lcl_zaaqb_join_cntrl IMPLEMENTATION
*<<<--zcl_zaaqb_query_join_cntrl

DATA: it_tabname                 TYPE TABLE OF t_tabname WITH HEADER LINE,
      it_select                  TYPE TABLE OF t_select  WITH HEADER LINE,
      it_join                    TYPE TABLE OF t_join    WITH HEADER LINE,
      it_join_condition          TYPE TABLE OF t_join_condition    WITH HEADER LINE,
      it_where                   TYPE TABLE OF t_where   WITH HEADER LINE,
      it_subquery                TYPE TABLE OF t_subquery WITH HEADER LINE,

      gt_fieldcat_tabname        TYPE lvc_t_fcat,
      gt_fieldcat_select         TYPE lvc_t_fcat,
      gt_fieldcat_join           TYPE lvc_t_fcat,
      gt_fieldcat_join_condition TYPE lvc_t_fcat,
      gt_fieldcat_where          TYPE lvc_t_fcat,
      gt_fieldcat_output         TYPE lvc_t_fcat,


      gs_layout_tabname          TYPE lvc_s_layo,
      gs_layout_select           TYPE lvc_s_layo,
      gs_layout_join             TYPE lvc_s_layo,
      gs_layout_join_condition   TYPE lvc_s_layo,
      gs_layout_where            TYPE lvc_s_layo,
      gs_layout_output           TYPE lvc_s_layo,

      gt_exclude_tabname         TYPE ui_functions,
      gt_exclude_where           TYPE ui_functions,


      wa_where                   TYPE t_where,
      wa_where2                  TYPE t_where,
      wa_field                   TYPE ty_field_desc,


*navigate pointer

      lv_key_select(30)          TYPE c,
      lv_key_join(61)            TYPE c,
      lv_str_tab                 TYPE string,

* Data displayed
      gt_field                   TYPE TABLE OF ty_field_desc WITH HEADER LINE,

*filter
      pt_filt                    TYPE lvc_t_filt,
      ls_filt                    TYPE lvc_s_filt,

*try catch
      oref                       TYPE REF TO cx_root,
      text                       TYPE string.



*--------my---------------------

DATA: join_wizard TYPE REF TO zcl_zaaqb_query_join_cntrl, "lcl_zaaqb_join_cntrl,
      g_join_data TYPE REF TO cl_query_join_data.

DATA: itext TYPE TABLE OF tline-tdline,
      xtext LIKE LINE OF itext.

DATA:
  docking_left       TYPE REF TO cl_gui_docking_container,

  alv_tabname        TYPE REF TO cl_gui_alv_grid,
  alv_select         TYPE REF TO cl_gui_alv_grid,
  alv_join           TYPE REF TO cl_gui_alv_grid,
  alv_join_condition TYPE REF TO cl_gui_alv_grid,
  alv_where          TYPE REF TO cl_gui_alv_grid,
  alv_output         TYPE REF TO cl_gui_alv_grid,


  splitter           TYPE REF TO cl_gui_splitter_container,
  splitter2          TYPE REF TO cl_gui_splitter_container,
  splitter3          TYPE REF TO cl_gui_splitter_container,

  dock_sub_cont1_1   TYPE REF TO cl_gui_container,
  dock_sub_cont1_2   TYPE REF TO cl_gui_container,
  dock_sub_cont1_3   TYPE REF TO cl_gui_container,
  dock_sub_cont1_4   TYPE REF TO cl_gui_container,

  dock_sub_cont1     TYPE REF TO cl_gui_container,
  dock_sub_cont2     TYPE REF TO cl_gui_container,
  dock_sub_cont3     TYPE REF TO cl_gui_container,
  dock_sub_cont4     TYPE REF TO cl_gui_container,
*>>>---join_wizard
  dock_sub_cont5     TYPE REF TO cl_gui_container,
  dock_sub_cont5_1   TYPE REF TO cl_gui_container,
  dock_sub_cont5_2   TYPE REF TO cl_gui_container,

*<<<---join_wizard

  text_editor_top    TYPE REF TO cl_gui_textedit,
*>>>--toolbar
  go_toolbar         TYPE REF TO cl_gui_toolbar,
  go_event_handler   TYPE REF TO cls_event_handler,
  gt_button_group    TYPE ttb_button,
  gt_events          TYPE cntl_simple_events,
  gs_event           TYPE cntl_simple_event,
*<<<--toolbar

  repid              TYPE syrepid.

*/------------ dynamic sql--------------------
DATA: it_s_result TYPE TABLE OF edpline,
      it_s_from   TYPE TABLE OF edpline,
      it_s_where  TYPE TABLE OF edpline,
      it_s_group  TYPE TABLE OF edpline,
      it_s_having TYPE TABLE OF edpline,
      it_s_order  TYPE TABLE OF edpline,

      dref        TYPE REF TO data,
      itab_type   TYPE REF TO cl_abap_tabledescr,
      struct_type TYPE REF TO cl_abap_structdescr,
      elem_type   TYPE REF TO cl_abap_elemdescr,
      comp_tab    TYPE abap_compdescr_tab,
      comp_line   TYPE abap_compdescr,
      comp_tab_t  TYPE abap_compdescr_tab,
      comp_fld    LIKE LINE OF comp_tab.

FIELD-SYMBOLS : <it_outtab> TYPE ANY TABLE,
                <wa_outtab> TYPE any,
                <l_fld>     TYPE any.
*/---------------------end------------------------

*>>>---join_wizard
*>>>------join_data
DATA: BEGIN OF dbpa OCCURS 10.
        INCLUDE STRUCTURE aqdbpa .
*       NAME(8),             " Name Parameter/Select-Option
*       SEL(1),              " X = Select-Option
*       STDSEL(1),           " X = Standard-Select-Option (log Db)
*       ORDER(2) TYPE N,     " Reihenfolge im Parameterteil des
*                            " Selektionsdynpros
*       TINDX1(5) TYPE N,    " Textindex Bedeutung      (SGTEXT)
*       TINDX2(5) TYPE N,    " Textindex Selektionstext (SGTEXT)
*       TYPE(1),             " Typ des Parameters (Y= is DDIC Type (see LIKE))
*       LENGTH(3),           " Lange des Parameters
*       LI KE(70),            " LIKE-Angabe (od er leer) bei Parametern
*                            " Referenzfeld bei Select-Option
*       CODE(132),           " ABAP/4 gerechte weitere Zusatze
*       SET(1),              " X = zusatzlicher SET-P  arameter bei
*                              "     Select-Options
*       SETNAME(8),          " Setparametername
*       TINDXS1(5) TYPE N,   " Textindex Bedeutung SET      (SGTEXT)
*       TINDXS2(5) TYPE N,   " Textindex Selektionstext SET (SGTEXT)
*       NO_DISPLAY(1),       " wird in Query nicht zur Sel.angeboten
*       DISPLAY(1),          " Feld kommt per Default auf Selektionsbild
*       OBLIGATORY(1),       " ist MUSS-Feld
DATA: END OF dbpa,
dbpa_text(60).         " Bedeutung des Parameters/Select-Option
DATA wa_dbpa TYPE aqdbpa. " work area for dbpa.
DATA: BEGIN OF headsg.
        INCLUDE STRUCTURE aqhdsg.
*       CLAS(24),            " Name des Sachgebietes
*       ART(1),              " Herkunft der Daten
*                            " SPACE = logische Datenbank
*                            " S     = sequentieller Bestand
*                            " D     = Datenbeschaffungsprogramm
*                            " T     = Tabelle
*                            " J     = Tabellenjoin
*       LOGDB(20),           " logische Datenbank
*       TSTRUC(30),          " Tabellenstruktur fur ART <> SPACE
*       RP(1),               "  X = RP-Datenbank
*       TINDX(5 ) TYPE N,     " Index Erlauterungstext (SGTEXT)
*       SECU(8),               Berech tigungsgruppe
*       FIXPOINT(1),          " X = Festpunktarithmetik an
*       SELSCREEN(3),        " Version des Selektionsbildes
*       SSETSG(1),           " X = Start nur uber Variante
*                            "     (Festlegung  aus Sachgebiet)
*       DSNNAME(60) ,         " Filename des sequ. Bestandes
*       DSNMODE(1),          " SPACE = Standard (Binar)
*                             " T     = Text
*       PROGRAM(40),         " Datenbeschaffungsprogramm
*        STATE(1),            " Zustand des Sachgebiets, das in
*                            " SQ02 in Bearbeitung ist
*                            " U     = ungesichert
*                            " S     = gesichert
*                            " G     = generiert, aber nicht
*                            "         unbedingt fehlerfrei
*       GENERATED(1),        " X = eine fehlerfrei generierte Form
*                            "     existiert
*       OPTGEN(1),           " X = Generierung erfolgte optimiert
*                            " ab 5.0 immer X
*       SGCNAM(12),          " Autor des Sachgebietes
*       SGCDAT TYPE D,       " Erstellungsdatum
*       SGUNAM(12),          " letzter Anderer
*       SGU DAT TYPE D,       " Datum der letzten  Anderung
*       SGUTIM TYPE T,       " Zeit der letzten Anderung
*       MAXTI  ME(6),          " SPACE = keine Zeitu   berwachung
*                            " sonst = max. Zeit in Sekunden
*        MAXDBACC(6),         " SPACE = keine Zugriffsuberwachung
*                            " sonst = max. DB-Zugriffe
*        QREL(6),             " Query-Release f ur Umsetzungen
*       DEVC(30),            " Entwicklungsklasse
*       OBJS EL(1),           " space = keine Objektsel ektion
*                            " 1     = Treffermengen
*                            " 2     = Treffermengen & Auswertemengen
*       OBJSTRUC(30),        " DDIC-Struktur fur Objektschlussel
*                            " enthalt Fel   der aus DBOB
*                            " und ein Textfeld(132)
*                             " und einen Marker fur A LV (1)
*       WITH_TEXTS(1),       " X = automatische Texterkennung
*        DATA_PROG(1),        " X = Datenvers.prog. in DBDP
*       API(1),              " X = Infoset uber ISQ API erzeugt
*       CONTROL(1),          " X = neues Contro l verwenden

DATA: END OF headsg.

DATA: maxsg_tindx TYPE tindx, " maximaler Textindex
      BEGIN OF sgtext OCCURS 100.
        INCLUDE STRUCTURE aqtxsg.
*       SPRSL(1),            " Sprachschlussel
*       TINDX(5) TYPE N,     " Textindex
*       MODIF(4) TYPE N,     "  Modifikationsnummer
*        MAXL(3)  TYPE N,     " maximale Textlange
*       TEXT(80),            " Text
DATA: END OF sgtext.

DATA: g_mode TYPE i.

DATA: g_sgname      TYPE sgname,
      act_workspace TYPE wsid,    " Flag aktueller Arbeitsbereich
*      g_grafic    type flag,
      g_caller_id   TYPE c.     " Char indicating caller:
" determines GUI-Title for 110, 120.
" 'S' = Sachgebietspflege
" 'Q' = Quickview.


* Anderungs-Log fur Sachgebiet
DATA: BEGIN OF clogsg OCCURS 10.
        INCLUDE STRUCTURE aqclsg.
*       SGU  DAT TYPE D,       " Datum der Anderung
*       SG UNAM(12),          " Name des Anderers
DATA: END OF clogsg.

* Sachg  ruppen
DATA: BEGIN OF dbsa OCCURS 40.
        INCLUDE STRUCTURE aqdbsa.
*       NUMB(2),             " Name der Sachgruppe
*       TINDX(5) TYPE N,     " Index Sachgruppenname (SGTEXT)
DATA: END OF dbsa,
dbsa_name TYPE aq_satext.         " Text zur Sachgruppe
DATA: wa_dbsa TYPE aqdbsa.

*  Objektschlussel
DATA: BEGIN OF dbob OCCURS 0.
        INCLUDE STRUCTURE aqdbob.
*       SGNA(30),            " S egmentname
*       NAME(70),            " Feldname
*       ORDER(2) TYPE n      " Reihenfolgenummer
*       COMPNAME(30)         " Komponentenname in DDIC-Struktur
*       NO_KEY type flag     " nicht verwendet
DATA: END OF dbob.

* Selektionen zum Objektschlussel
DATA: BEGIN OF dbos OCCURS 0.
        INCLUDE STRUCTURE aqdbos.
*       SGNA(30),            "  Segmentname (Schlusselfeld DBOB)
*       NAME(70),            "  Feldname (Schlusselfeld DBOB)
*       KIND(1),               " Art der Selektion (P, S)
*       SIGN(1),             "  Kennzeichen I / E
*       OPTION(2),           " Selektionsoption (EQ, NE,...)
*       LOW(45),             " unterer Wert
*       HIGH(45),            " oberer Wert
DATA: END OF dbos.

* Interfaces zur Anwendung
DATA: BEGIN OF dbif OCCURS 0.
        INCLUDE STRUCTURE aqdbif.
*       ACTION(30)          "Name des Zeitpunkts
*       CLSNAME(30)         "Name der Klasse (Basiskl. o. Erbe)
*       MTHDNAME(30)        "wird nicht benutzt
DATA: END OF dbif.

* mogliche Werte fur   dbif-action: -> siehe RSAQCOMC


* ausgewahlte Felder    (einschliesslich Tabellen- und Zusatzfelder)
DATA: BEGIN OF dbsf OCCURS 100.
        INCLUDE STRUCTURE aqdbsf.
*       NUMB(2),             " Sachgruppe
*       SGNA(30),            " Segmentname
*       NAME(70),            " Feldname
*       TINDX(5) TYPE N,     " Index Text zum Feldnamen (SGTEXT)
*       TINDXU1(5) TYPE N,   " Index Uberschriftszeile 1 ( SGTEXT)
*       TINDXU2(5) TYPE N,   " Index Uberschriftsze  ile 2 (SGTEXT)
*       TYPE(1),             " Typ
*       OL ENG(3),            " Ausgabelange
*       DECIMALS(2),          " Dezimalstellen
*       ADDY(1),             " F = Zusa tzfeld, Zusatzstruktur
*                            " T = Tabellenfeld
*                            " space sonst
*       CURRY(1),            " F = Wahrungsbetragsfeld
*                             " W = Wahrungsfeld
*                              " M = Mengenfeld
*                            "  E = Einheitenfeld
*                            " space sonst
*       GTYPE(1),            " S = Symbol, I = Ikone
*       OBJSEL(1),           " 'X' = Obj.sel. zulassig-> NICHT VERWEN DET
*       NO_SUM(1)            " 'X' = nicht summierb ar
*       IS_TEXT(1)           " 'X' = Feld ist Textfeld
*       TEXTSGNA(30)         " Segmentname des Textfeldes
*       TEXTNAME(70)         " Feldname des Textfeldes
*       INTSORT(5) Type N    " Sortier-Index
*       OBLIGATORY(1)        " X = Feld muss in Query ausgewahlt werden
*       NO_SELEC T(1)         " X = Feld nicht als Selektion verwenden
DATA: END OF dbsf,
dbsf_text(60).         " Text zum Feldnamen
DATA wa_dbsf TYPE aqdbsf. " work-area

* Struktur der verwendeten logischen Datenbank / Tabellen
DATA: BEGIN OF dbsg OCCURS 40.
        INCLUDE STRUCTURE aqdbsg.
*       NAME(30),            " Segmentname
*       PARENT(30),          " Segmentname des ubergeordneten Segm.
*       TINDX(5)  TYPE N,     " Index Text Tabellenbedeutung (SGTEXT)
*       STRUC (30),           " DDIC-Struktur bei TYPE = S
*       TYPE(1),             " Knotentyp bei logDb (space, S, C)
*       TYPEPOOL(5),         " Typepool bei TYPE = C
*       COMMENT(30),         " Kommentare (fur HR)
DATA: END OF dbsg,
dbsg_text(40).         " Bedeutung der Tabelle
DATA wa_dbsg TYPE aqdbsg.

* Alias-Namen fur Tabellen
DATA: BEGIN OF dban OCCURS 10.
        INCLUDE STRUCTURE aqdban.
*        TABLE(30),           " Tabellenname
*       ALIAS(30),           " Aliasname der Tabelle
DATA: END OF dban.

* Tabellen im Tabellen-Join
DATA: BEGIN OF dbjt OCCURS 10.
        INCLUDE STRUCTURE aqdbjt.
*       TABLE(30),           " Tabellenname
*       OUTERFLAG(1),        " OUTER-Kennzeichen (mit Folgetabelle)
*                            " I - inner Join
*                            " L - left outer Join
*                            " R - right outer Join
*                            " space - letzte Tabelle im Join
*       TOP(8) type n,       " Top coordinate in graphical Join-Definit.
*       LEFT(8) type n,      " LEFT coordinate in graphical Join-Def.
*       WIDTH(8) type n,     " WIDTH in graphical Join-Def..
*       HEIGHT(8) type n,    " HEIGHT in graphical Join-Def.
*
DATA: END OF dbjt.
DATA wa_dbjt TYPE aqdbjt. " work area for dbjt.

* Verknupfungsbedingungen im Tabellenjoin
DATA: BEGIN OF dbjc OCCURS 40.
        INCLUDE STRUCTURE aqdbjc.
*       JIND(2),             " Index der Bedingung
*                            " space falls Feldnamen leer
*       LTABLE(30),          " linke Tabelle
*       LNAME(70),           " Feldname aus LTABLE
*       RTABLE(30),          " rechte Tabelle
*       RNAME(70),           " Feldname aus RTABLE
DATA: END OF dbjc.

* Zusatztabellen (SAP-Tabellen)
DATA: BEGIN OF dbzt OCCURS 50.
        INCLUDE STRUCTURE aqdbzt.
*       SGNA(30),            " Segmentname
*       TNAME(30),           " Tabellenname
*       FNAME(70),           " Keyelement der WHERE-Clausel
*       WNAME(70),           " Vorschlagswert zum Keyelement
*       ORDER(2) TYPE N,     " Rang der Zusatztabelle innerhalb der
*                            " Zusatzfelder und -tabellen des
*                            " Segments ( 0 .. 9 )
*       IBUFF(1),            " X = interne Pufferung bei Zugriff
DATA: END OF dbzt.
DATA: wa_dbzt TYPE aqdbzt. " work area for dbzt.

* Zusatzfelder/-strukturen und  Zusatzcodings
DATA: BEGIN OF dbzc OCCURS 50.
        INCLUDE STRUCTURE aqdbzc.
*       SGNA(30),            " Segmentname
*                            " leer (Sachgebiet ohne DB,
*                            "  DATA/START/END/TOP/SELOPTIPON-Coding)
*       NAME(70),            " Name des Zusatzfeldes (21 Zeichen) oder
*                            " Spezialzeichenfolge fur Coding
*       ORDER(2) T YPE N,     " Rang des Zusatzfeldes oder des Get/
*                            " GetLate-Codings innerhalb der
*                            " Zusatzfelder und -tabellen des
*                            " Segments ( 0 .. 9 )
*       TINDX(5) TYPE N,     " Index Text zum Zusatzfeld (SGTEXT)
*       TINDXU1(5) TYPE N,   " Index Uberschriftszeile 1 (SGTEXT)
*        TINDXU2(5) TYPE N,   " Index Uberschriftsze  ile 2 (SGTEXT)
*       TYPE(1),             " Typ
*       LENG(3),              " Lange
*       OLENG(3),            "  Ausgabelange
*       DECIMALS(2),         " Dezimalstellen
*       DDICT  YPE(4),         " DDIC-Typ
*       LIKE(70),             " LIKE-Feld
*       GTYPE(1),            " S = Symbol, I = Ikone
*       IS_TEXT(1)           " 'X' = Feld ist Textfeld
*       VALUESGNA(30)        " Segmentname des Wertfeldes
*       VALUENAME(70)        " Feldname des Wertfeldes
*       IS_STRUC(1)          " 'X' = Zusatzstruktur
*       check_text(1)        " 'X' = Text bestimmen (uber LIKE)
DATA: END OF dbzc.

DATA: wa_dbzc TYPE aqdbzc.

* Codingzeilen fur Zusatz  felder und Zusatzcodings
DATA: BEGIN OF dbzl OCCURS 100.
        INCLUDE STRUCTURE aqdbzl.
*       SGNA(30),            " Segmentname
*                            " leer (Sachgebiet ohne DB,
*                            "  DATA/START/END/TOP-Coding)
*       NAME(70),            " Name des Zusatzfeldes (21 Zeichen) oder
*                            " Spezialzeichenfolge fur Coding
*       LINENR(4) T YPE N,    " Zeilennummer
*       CODE(132),           " Codingzeile
DATA: END OF dbzl.
* Coding Datenversorgungsprogramm (falls intergriert in InfoSet)
DATA: BEGIN OF dbdp OCCURS 0.
        INCLUDE STRUCTURE aqdbdp.
*       ID(2) TYPE N,        " zusatzl. Ordnungskriterium (not used)
*       LINENR(4) TYPE N,    " Zeilennummer
*       CODE(132)            " Codin g
DATA: END OF dbdp.

* Parameter/Select-Options (zusatzlich zum Selektionsbild jeder Query)
*data: begin of dbpa occurs  10.
*        include structure aqdbpa .
**       NAME(8),             " Name Parameter/Select-Option
**       SEL(1),              " X = Select-Option
**       STDSEL(1),           " X = Standard-Select-Option (log Db)
**       ORDER(2) TYPE N,     " Reihenfolge im Parameterteil des
**                            " Selektionsdynpros
**       TINDX1(5) TYPE N,    " Textindex Bedeutung      (SGTEXT)
**       TINDX2(5) TYPE N,    " Textindex Selektionstext (SGTEXT)
**       TYPE(1),             " Typ des Parameters (Y= is DDIC Type (see LIKE))
**       LENGTH(3),           " Lange des Parameters
**       LI KE(70),            " LIKE-Angabe (od er leer) bei Parametern
**                            " Referenzfeld bei Select-Option
**       CODE(132),           " ABAP/4 gerechte weitere Zusatze
**       SET(1),              " X = zusatzlicher SET-P  arameter bei
**                              "     Select-Options
**       SETNAME(8),          " Setparametername
**       TINDXS1(5) TYPE N,   " Textindex Bedeutung SET      (SGTEXT)
**       TINDXS2(5) TYPE N,   " Textindex Selektionstext SET (SGTEXT)
**       NO_DISPLAY(1),       " wird in Query nicht zur Sel.angeboten
**       DISPLAY(1),          " Feld kommt per Default auf Selektionsbild
**       OBLIGATORY(1),       " ist MUSS-Feld
*data: end of dbpa,
*      dbpa_text(60).         " Bedeutung des Parameters/Select-Option
*data wa_dbpa type aqdbpa.    " work area for dbpa.

* Wahrungs- und Mengen felder
DATA: BEGIN OF dbwr OCCURS 10.
        INCLUDE STRUCTURE aqdbwr.
*       SGNA(30),            " Segmentname Betragsfeld
*       NAME(70),            " Betragsfeld
*       TABNAME(30),         " Segmentname Einheitenfeld
*       CURRNAME(70),        " Einheitenfeld
*       TINDXC(5) TYPE N,    " Index Text zum Einheitenfeld (SGTEXT)
*       TINDXCU1(5) TYPE N,  " Index Uberschriftsze ile 1 (SGTEXT)
*       TINDXCU2(5) TYPE N,  " Index Uberschriftszeile 2 (SGTEXT)
*         CURRLENGTH(2),       " Lang  e des Einheitenfeldes
*       SELECTED(1),         " in Query ( SQ01 ) ausgewahlt
*         LINE(2),             " Ausg abezeile des Feldes
*       CONTD(1),            " Fortsetzungszeile
* TINDX, TINDXU1 und TINDXU2 werden erst ab 005.00 beim Generieren des
* Sachgebietes gefullt
DATA: END OF dbwr.
DATA wa_dbwr TYPE aqdbwr.

*  Zugriffsreferenzen
DATA: BEGIN OF dbar OCCURS 10.
        INCLUDE STRUCTURE aqdbar.
*       SGNA(30),            " Segmentname
*       NAME(70),            " Feldname
*       ADDY(1),             " F = Zusatzfeld
*                            " T = Tabellenfeld
*                            " space sonst
*       RSGNA(30),           " Segmentname des referierten Feldes
*       RNAME(70),           " Name des referierten Feldes
*                            " tab-* = alle Felder von tab referiert
*       RADDY(1),            " space = Datenbankfeld
*                            " F = Zusatzfeld
*                            " T = Tabellenfeld
*                            " space sonst
*       DIRECT(1),           " X = direkte Referenz
DATA: END OF dbar.

* geanderte Texte
DATA: BEGIN OF dbft OCCURS 50.
        INCLUDE STRUCTURE aqdbft.
*                             " Felder, denen ein neuer Text anstelle
*                            " - Text aus DDIC fur Segmentfelder
*                             " - Text aus DDIC fur Tabellenfelder
*                            " -   Uberschrift aus DDIC
*                              " zugeordnet wurde
*       NAME(70),            " Feldname
*       TI NDX(5) TYPE N,     " Index neuer Text zum Feld (SGTEXT)
*       TINDXU1(5) TYPE N,   " Index Uberschriftszeile 1 (SGTEX T)
*       TINDXU2(5) T YPE N,   " Index Uberschriftszeile 2 (SGTEXT)
DATA: END OF dbft.



* Sachgebiet skatalog
DATA: BEGIN OF sucat OCCURS 50.
        INCLUDE STRUCTURE aqcasg.
*       CLAS(24),            " Name des Sachgebietes
*       ART(1),              " Herkunft der Daten
*                            " SPACE = logische Datenbank
*                            " S     = sequentieller Bestand
*                            " D     = Datenbeschaffungsprogramm
*                            " T     = Tabelle
*                            " J     = Tabellenjoin
*       LOGDB(20),           " logische Datenbank
*       TSTRUC(30),          " Tabellenstruktur fur ART <> SPACE
DATA: END OF sucat.

DATA: BEGIN OF ttab OCCURS 20, " Table of used Tables
        ddic      LIKE dd02v,        " DDIC-information
        derived   TYPE flag,         " X = not Orginal DDIC
        orig_name TYPE tname,      " for derived tables:
        " orignal name from dban (alias)
        " or dbsg-structure (log. node)
      END OF ttab.

DATA: BEGIN OF exdbfi OCCURS 200, " extended Field-infor-table
        ddic    LIKE dfies,           " DDIC-Information
        BEGIN OF info,             " refinded Informationen
          type     LIKE dbsf-type,       " Typ               C1
          leng     LIKE dbpa-length,     " Length            C3
          oleng    LIKE dbsf-oleng,      " Output-Length     C3
          decimals LIKE dbsf-decimals,   " Decimals          C2
          curry    LIKE dbsf-curry,      " Currencyflag      C1
          locked   TYPE flag,  " X = locked   for Selection in
          " Functional-Area
          " - OLENG > 999
          " - Mandantenfeld
        END OF info,
        derived TYPE flag,         " X = nicht original DDIC
      END OF exdbfi.
*<<<<---join_data


*>>>>>>>>---------class-data
DATA: l_lin_dbjt        TYPE i,
      ls_dbjt           TYPE aqdbjt,
      l_headsg_sav      TYPE aqhdsg,
      l_maxsg_tindx_sav TYPE aqs_tindx,
      l_mode_sav        TYPE i,
      lt_clogsg_sav     TYPE aqtclsg,
      lt_dbsa_sav       TYPE aqtdbsa,
      lt_dbob_sav       TYPE aqtdbob,
      lt_dbos_sav       TYPE aqtdbos,
      lt_dbif_sav       TYPE aqtdbif,
      lt_dbsf_sav       TYPE aqtdbsf,
      lt_dbsg_sav       TYPE aqtdbsg,
      lt_dban_sav       TYPE aqtdban,
      lt_dbjt_sav       TYPE aqtdbjt,
      lt_dbjc_sav       TYPE aqtdbjc,
      lt_dbzt_sav       TYPE aqtdbzt,
      lt_dbzc_sav       TYPE aqtdbzc,
      lt_dbzl_sav       TYPE aqtdbzl,
      lt_dbdp_sav       TYPE aqtdbdp_stdkey,
      lt_dbpa_sav       TYPE aqtdbpa,
      lt_dbwr_sav       TYPE aqtdbwr,
      lt_dbar_sav       TYPE aqtdbar,
      lt_dbft_sav       TYPE aqtdbft,
      lt_sgtext_sav     TYPE aqttxsg,
      lt_exdbfi_sav     TYPE aqq_t_exdbfi,
      lt_ttab_sav       TYPE aqq_t_ttab.
*<<<<<<---------class-data
*<<<---join_wizard

PARAMETERS: p_check TYPE c.

*---------classes-------------
CLASS lcl_event_handler DEFINITION .
  PUBLIC SECTION .
    METHODS:
*--Double-click control
*/------------tabname------------
      handle_double_click_tabname
                    FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column   es_row_no  ,
      handle_data_changed_tabname
                    FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed    e_ucomm,

*/----------------select-------------------------
      handle_button_click_select
                    FOR EVENT button_click OF cl_gui_alv_grid
        IMPORTING es_col_id es_row_no,
      handle_data_changed_select
                    FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed  e_ucomm,
      handle_data_changed_fi_select
                    FOR EVENT data_changed_finished OF cl_gui_alv_grid
        IMPORTING e_modified,

*/-----------------join---------------------------
      handle_button_click_join
                    FOR EVENT button_click OF cl_gui_alv_grid
        IMPORTING es_col_id es_row_no,
      handle_data_changed_join
                    FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed  e_ucomm,
      handle_data_changed_fi_join
                    FOR EVENT data_changed_finished OF cl_gui_alv_grid
        IMPORTING e_modified,
      handle_f4_join
                    FOR EVENT onf4 OF cl_gui_alv_grid
        IMPORTING e_fieldname es_row_no er_event_data et_bad_cells e_display,
*/---------------join---condition----------------
      handle_data_changed_join_cond
                    FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed  e_ucomm,
      handle_f4_join_condition
                    FOR EVENT onf4 OF cl_gui_alv_grid
        IMPORTING e_fieldname es_row_no er_event_data et_bad_cells e_display,
*/------------------where--------------------------------
      handle_data_changed_where
                    FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed  e_ucomm,
      handle_data_changed_fi_where
                    FOR EVENT data_changed_finished OF cl_gui_alv_grid
        IMPORTING e_modified,
      handle_f4_where
                    FOR EVENT onf4 OF cl_gui_alv_grid
        IMPORTING e_fieldname es_row_no er_event_data et_bad_cells e_display,
      handle_toolbar_where FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive          ,
      handle_user_command_where
                    FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm .

  PRIVATE SECTION.
ENDCLASS. "lcl_event_handler DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION .
*------------tabname------------------
  METHOD handle_double_click_tabname .
    " MESSAGE 'asdasd' TYPE 'I'.
    PERFORM handle_double_click USING e_row e_column es_row_no  .

  ENDMETHOD .                    "handle_double_click

  METHOD  handle_data_changed_tabname.

    FIELD-SYMBOLS: <fs> TYPE table.    " Output table
    DATA: wa_outtab TYPE t_tabname,
          lv_count  TYPE i.

    ASSIGN er_data_changed->mp_mod_rows->* TO <fs>.
    LOOP AT <fs> INTO wa_outtab.

      SELECT COUNT( * )
        FROM dd03l
        INTO lv_count
        WHERE tabname = wa_outtab-tabname.

      IF sy-subrc NE 0.

        wa_outtab-tabname = ''.

      ENDIF.


      MODIFY <fs> FROM wa_outtab INDEX sy-tabix.
    ENDLOOP.

  ENDMETHOD.                    "handle_data_changed

  METHOD handle_button_click_select  .
    DATA: lv_id(10) TYPE c,
          wa_select TYPE t_select,
          wa_join   TYPE t_join.
    WRITE  es_row_no-row_id TO lv_id.

    READ TABLE it_select INDEX es_row_no-row_id INTO wa_select.

    IF wa_select-sselect NE ''.
      lv_key_select = wa_select-sselect.
    ELSE.
      LOOP AT it_select INTO wa_select WHERE sselect NE '' .
        lv_key_select = wa_select-sselect.
      ENDLOOP.
    ENDIF.
    lv_key_join = ''.
    LOOP AT it_join INTO wa_join WHERE lv_key_select = lv_key_select AND jjoin NE '' .
      lv_key_join = wa_join-jjoin.
    ENDLOOP.

    PERFORM set_filter_where USING lv_key_select.
    PERFORM set_filter_join USING lv_key_select.
    PERFORM set_filter_join_condition USING lv_key_select  lv_key_join.

    PERFORM recalc_cwidth_opt USING alv_where.

    CALL METHOD alv_where->refresh_table_display .

    MESSAGE lv_key_select  TYPE 'S'.

  ENDMETHOD .                    "handle_hotspot_click_select

  METHOD handle_data_changed_select.
    DATA: dl_ins_row TYPE lvc_s_moce.   " Insert Row
    FIELD-SYMBOLS: <fs> TYPE table.    " Output table

    DATA: ls_style TYPE lvc_s_styl,
          lv_row   TYPE t_select.
    CLEAR ls_style.

    ls_style-fieldname = 'BUT' .
    ls_style-style = cl_gui_alv_grid=>mc_style_button .

* Loop at the inserted rows table and assign default values
    LOOP AT er_data_changed->mt_inserted_rows INTO dl_ins_row.
      ASSIGN er_data_changed->mp_mod_rows->* TO <fs>.
      LOOP AT <fs> INTO lv_row.
        CLEAR lv_row-cellstyles.
        APPEND ls_style TO lv_row-cellstyles .
        MODIFY <fs> FROM lv_row INDEX sy-tabix.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_select

  METHOD handle_data_changed_fi_select.

    DATA: wa_select      TYPE t_select,
          lv_sselect(30) TYPE c,
          ls_style       TYPE lvc_s_styl.

    lv_sselect = ''.


    READ TABLE it_select WITH KEY sselect = lv_key_select TRANSPORTING NO FIELDS.

    IF sy-subrc NE 0.

      LOOP AT it_select INTO wa_select WHERE sselect NE ''.
        lv_sselect = wa_select-sselect.
        lv_key_select = wa_select-sselect.
      ENDLOOP.

      IF lv_sselect EQ ''.
        wa_select-sselect = 'ZMAIN'.
        ls_style-fieldname = 'BUT' .
        ls_style-style = cl_gui_alv_grid=>mc_style_button .
        APPEND ls_style TO wa_select-cellstyles.
        APPEND wa_select TO it_select.
        lv_key_select = 'ZMAIN'.

      ENDIF.
      MESSAGE lv_key_select  TYPE 'S'.

      PERFORM set_filter_where USING lv_key_select.
      PERFORM set_filter_join USING lv_key_select.
      PERFORM set_filter_join_condition USING lv_key_select  lv_key_join.

    ENDIF.

    READ TABLE it_select WITH KEY sselect ='ZMAIN' TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      CLEAR: ls_style,
             wa_select.
      wa_select-sselect = 'ZMAIN'.
      ls_style-fieldname = 'BUT' .
      ls_style-style = cl_gui_alv_grid=>mc_style_button .
      APPEND ls_style TO wa_select-cellstyles.
      APPEND wa_select TO it_select.
    ENDIF.

    SORT it_select BY sselect DESCENDING.

    IF e_modified = 'X'.
      PERFORM recalc_cwidth_opt USING alv_select.
      CALL METHOD alv_select->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.

  ENDMETHOD.                    "handle_data_changed_fi_select

  METHOD handle_button_click_join  .
    DATA: lv_id(10)         TYPE c,
          wa_join           TYPE t_join,
          wa_join_condition TYPE t_join_condition.

    lv_key_join = ''.

    READ TABLE it_join INDEX es_row_no-row_id INTO wa_join.

    IF wa_join-jjoin NE ''.
      lv_key_join = wa_join-jjoin.
    ELSE.
      LOOP AT it_join INTO wa_join WHERE jjoin NE '' AND lv_key_select = lv_key_select.
        lv_key_join = wa_join-jjoin.
      ENDLOOP.
    ENDIF.

    PERFORM set_filter_join_condition USING lv_key_select  lv_key_join.

    WRITE  es_row_no-row_id TO lv_id.

    MESSAGE lv_key_join  TYPE 'S'.

  ENDMETHOD .                    "handle_hotspot_click_select


  METHOD handle_data_changed_join.
    DATA: dl_ins_row TYPE lvc_s_moce.   " Insert Row
    FIELD-SYMBOLS: <fs> TYPE table.    " Output table

    DATA: ls_style        TYPE lvc_s_styl,
          lv_row          TYPE t_join,
          lv_count(2)     TYPE n,
          lv_str_join(10) TYPE c.
    CLEAR ls_style.

    ls_style-fieldname = 'BUT' .
    ls_style-style = cl_gui_alv_grid=>mc_style_button .

* Loop at the inserted rows table and assign default values
    LOOP AT er_data_changed->mt_inserted_rows INTO dl_ins_row.

      CLEAR lv_count.
      LOOP AT it_join TRANSPORTING NO FIELDS  WHERE lv_key_select = lv_key_select .
        ADD 1 TO lv_count.
      ENDLOOP.
      "      DESCRIBE TABLE it_join LINES lv_count.
      ADD 1 TO lv_count.

      CONCATENATE 'JOIN' lv_count INTO lv_str_join.
      lv_key_join = lv_str_join.
      PERFORM set_filter_join_condition USING lv_key_select  lv_key_join .

      SUBTRACT 1 FROM lv_count .
      IF lv_count < 1.
        lv_str_join = ''.
      ELSE.
        CONCATENATE 'JOIN' lv_count INTO lv_str_join.
      ENDIF.



      ASSIGN er_data_changed->mp_mod_rows->* TO <fs>.
      LOOP AT <fs> INTO lv_row.
        CLEAR lv_row-cellstyles.
        APPEND ls_style TO lv_row-cellstyles .
        lv_row-lv_key_select = lv_key_select.
        lv_row-jjoin = lv_key_join.
        lv_row-ttype = 'INNER JOIN'.
        lv_row-left  = lv_str_join.
        MODIFY <fs> FROM lv_row INDEX sy-tabix.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.                    "handle_data_changed_join

  METHOD handle_data_changed_fi_join.

    IF e_modified = 'X'.
      PERFORM recalc_cwidth_opt USING alv_join.
      CALL METHOD alv_join->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.

  ENDMETHOD.                    "handle_data_changed_fi_join

  METHOD handle_f4_join.
    DATA: wa_join TYPE t_join.

    CASE e_fieldname.
      WHEN 'LEFT'.
        READ TABLE it_join INTO wa_join INDEX es_row_no-row_id.
        IF sy-subrc = 0.
          PERFORM sub_help_left CHANGING wa_join-left.
          IF wa_join-left IS NOT INITIAL.
            MODIFY it_join FROM wa_join INDEX es_row_no-row_id.
            PERFORM recalc_cwidth_opt USING alv_join.
            CALL METHOD alv_join->refresh_table_display.
          ENDIF.
        ENDIF.
      WHEN 'RIGHT'.
        READ TABLE it_join INTO wa_join INDEX es_row_no-row_id.
        IF sy-subrc = 0.
          PERFORM sub_help_right CHANGING wa_join-right.
          IF wa_join-right IS NOT INITIAL.
            MODIFY it_join FROM wa_join INDEX es_row_no-row_id.
            PERFORM recalc_cwidth_opt USING alv_join.
            CALL METHOD alv_join->refresh_table_display.
          ENDIF.
        ENDIF.

    ENDCASE.

  ENDMETHOD.                    "handle_f4_join

  METHOD handle_data_changed_join_cond.
    DATA: dl_ins_row TYPE lvc_s_moce.   " Insert Row
    FIELD-SYMBOLS: <fs> TYPE table.    " Output table

    DATA: lv_row     TYPE t_join_condition.

* Loop at the inserted rows table and assign default values
    LOOP AT er_data_changed->mt_inserted_rows INTO dl_ins_row.
      ASSIGN er_data_changed->mp_mod_rows->* TO <fs>.
      LOOP AT <fs> INTO lv_row.
        lv_row-lv_key_select = lv_key_select.
        lv_row-lv_key_join   = lv_key_join.
        MODIFY <fs> FROM lv_row INDEX sy-tabix.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.                    "handle_data_changed_join

  METHOD handle_f4_join_condition.
    DATA: wa_join_condition TYPE t_join_condition.

    CASE e_fieldname.
      WHEN 'LEFT'.
        READ TABLE it_join_condition INTO wa_join_condition INDEX es_row_no-row_id.
        IF sy-subrc = 0.
          PERFORM sub_help_left_jco CHANGING wa_join_condition-left.
          IF wa_join_condition-left IS NOT INITIAL.
            MODIFY it_join_condition FROM wa_join_condition INDEX es_row_no-row_id.
            PERFORM recalc_cwidth_opt USING alv_join_condition.
            CALL METHOD alv_join_condition->refresh_table_display.
          ENDIF.
        ENDIF.
      WHEN 'RIGHT'.
        READ TABLE it_join_condition INTO wa_join_condition INDEX es_row_no-row_id.
        IF sy-subrc = 0.
          PERFORM sub_help_right_jco CHANGING wa_join_condition-right.
          IF wa_join_condition-right IS NOT INITIAL.
            MODIFY it_join_condition FROM wa_join_condition INDEX es_row_no-row_id.
            PERFORM recalc_cwidth_opt USING alv_join_condition.
            CALL METHOD alv_join_condition->refresh_table_display.
          ENDIF.
        ENDIF.
    ENDCASE.

  ENDMETHOD.                    "handle_f4_join_condition
  METHOD handle_data_changed_where.
    DATA: dl_ins_row TYPE lvc_s_moce.   " Insert Row
    FIELD-SYMBOLS: <fs> TYPE table.    " Output table

    DATA: ls_style        TYPE lvc_s_styl,
          lv_row          TYPE t_where,
          lv_count(2)     TYPE n,
          lv_str_join(10) TYPE c.
    CLEAR ls_style.


* Loop at the inserted rows table and assign default values
    LOOP AT er_data_changed->mt_inserted_rows INTO dl_ins_row.

      ASSIGN er_data_changed->mp_mod_rows->* TO <fs>.
      LOOP AT <fs> INTO lv_row.
        lv_row-lv_key_select = lv_key_select.
        MODIFY <fs> FROM lv_row INDEX sy-tabix.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.                    "handle_data_changed_where

  METHOD handle_data_changed_fi_where.
    DATA: wa_where      TYPE t_where,
          lv_sort_count TYPE i.
    CLEAR lv_sort_count.

    IF e_modified = 'X'.

      LOOP AT it_where INTO wa_where WHERE lv_key_select = lv_key_select.
        IF wa_where-sorttype NE ''.
          ADD 1 TO lv_sort_count.
        ENDIF.
      ENDLOOP.

      DO lv_sort_count TIMES.
        READ TABLE it_where TRANSPORTING NO FIELDS WITH KEY sortorder = sy-index.

        IF sy-subrc NE 0.
          LOOP AT it_where INTO wa_where WHERE lv_key_select = lv_key_select AND sorttype NE '' AND ( ( sortorder = 0 ) OR ( sortorder > lv_sort_count ) ).
            wa_where-sortorder = sy-index.
            MODIFY it_where FROM wa_where.
            EXIT.
          ENDLOOP.
        ENDIF.
      ENDDO.

      "no group
*      LOOP AT it_where INTO wa_where WHERE grouping = 'X'.
*        wa_where-aggregate = ''.
*        MODIFY it_where FROM wa_where.
*      ENDLOOP.
      PERFORM recalc_cwidth_opt USING alv_where.
      CALL METHOD alv_where->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.

  ENDMETHOD.                    "handle_data_changed_fi_where

  METHOD handle_f4_where.
    DATA: wa_where TYPE t_where.

    CASE e_fieldname.
      WHEN 'OR1'.
        READ TABLE it_where INTO wa_where INDEX es_row_no-row_id.
        IF sy-subrc = 0.
          PERFORM sub_help_where CHANGING wa_where-or1.
          IF wa_where-or1 IS NOT INITIAL.
            MODIFY it_where FROM wa_where INDEX es_row_no-row_id.
            PERFORM recalc_cwidth_opt USING alv_where.
            CALL METHOD alv_where->refresh_table_display.
          ENDIF.
        ENDIF.
      WHEN 'OR2'.
        READ TABLE it_where INTO wa_where INDEX es_row_no-row_id.
        IF sy-subrc = 0.
          PERFORM sub_help_where CHANGING wa_where-or2.
          IF wa_where-or2 IS NOT INITIAL.
            MODIFY it_where FROM wa_where INDEX es_row_no-row_id.
            PERFORM recalc_cwidth_opt USING alv_where.
            CALL METHOD alv_where->refresh_table_display.
          ENDIF.
        ENDIF.
      WHEN 'OR3'.
        READ TABLE it_where INTO wa_where INDEX es_row_no-row_id.
        IF sy-subrc = 0.
          PERFORM sub_help_where CHANGING wa_where-or3.
          IF wa_where-or3 IS NOT INITIAL.
            MODIFY it_where FROM wa_where INDEX es_row_no-row_id.
            PERFORM recalc_cwidth_opt USING alv_where.
            CALL METHOD alv_where->refresh_table_display.
          ENDIF.
        ENDIF.
      WHEN 'OR4'.
        READ TABLE it_where INTO wa_where INDEX es_row_no-row_id.
        IF sy-subrc = 0.
          PERFORM sub_help_where CHANGING wa_where-or4.
          IF wa_where-or4 IS NOT INITIAL.
            MODIFY it_where FROM wa_where INDEX es_row_no-row_id.
            PERFORM recalc_cwidth_opt USING alv_where.
            CALL METHOD alv_where->refresh_table_display.
          ENDIF.
        ENDIF.



    ENDCASE.

  ENDMETHOD.                    "handle_f4_join

  METHOD handle_toolbar_where.
    "e_object e_interactive
    DATA: ls_toolbar  TYPE stb_button.

    CLEAR ls_toolbar.
    MOVE 'MOVEUP' TO ls_toolbar-function.                   "#EC NOTEXT
    MOVE  icon_next_value TO ls_toolbar-icon.
    MOVE 'Move row up'(201) TO ls_toolbar-quickinfo.
    "MOVE 'Execute Query'(201) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.                        "#EC NOTEXT
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    MOVE 'MOVEDOWN' TO ls_toolbar-function.                 "#EC NOTEXT
    MOVE  icon_previous_value TO ls_toolbar-icon.
    MOVE 'Move row down'(201) TO ls_toolbar-quickinfo.
    "MOVE 'Execute Query'(201) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.                        "#EC NOTEXT
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    MOVE 'IMPORT' TO ls_toolbar-function.                   "#EC NOTEXT
    MOVE  icon_import TO ls_toolbar-icon.
    MOVE 'Import Query'(201) TO ls_toolbar-quickinfo.
    "MOVE 'Execute Query'(201) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.                        "#EC NOTEXT
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    MOVE 'EXPORT' TO ls_toolbar-function.                   "#EC NOTEXT
    MOVE  icon_export TO ls_toolbar-icon.
    MOVE 'Export Query'(201) TO ls_toolbar-quickinfo.
    "MOVE 'Execute Query'(201) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.                        "#EC NOTEXT
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    MOVE 'SAVE' TO ls_toolbar-function.                     "#EC NOTEXT
    MOVE  icon_system_save TO ls_toolbar-icon.
    MOVE 'Save Query'(201) TO ls_toolbar-quickinfo.
    "MOVE 'Execute Query'(201) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.                        "#EC NOTEXT
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    MOVE 'LIST' TO ls_toolbar-function.                     "#EC NOTEXT
    MOVE  icon_list TO ls_toolbar-icon.
    MOVE 'List Query'(201) TO ls_toolbar-quickinfo.
    "MOVE 'Execute Query'(201) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.                        "#EC NOTEXT
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    MOVE 'LIST2' TO ls_toolbar-function.                    "#EC NOTEXT
    MOVE  icon_list TO ls_toolbar-icon.
    MOVE 'List all Query'(201) TO ls_toolbar-quickinfo.
    "MOVE 'Execute Query'(201) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.                        "#EC NOTEXT
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    MOVE 'IMPORT_BD' TO ls_toolbar-function.                "#EC NOTEXT
    MOVE  icon_import TO ls_toolbar-icon.
    MOVE 'Import ALL Query'(201) TO ls_toolbar-quickinfo.
    "MOVE 'Execute Query'(201) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.                        "#EC NOTEXT
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    MOVE 'EXPORT_BD' TO ls_toolbar-function.                "#EC NOTEXT
    MOVE  icon_export TO ls_toolbar-icon.
    MOVE 'Export ALL Query'(201) TO ls_toolbar-quickinfo.
    "MOVE 'Execute Query'(201) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.                        "#EC NOTEXT
    APPEND ls_toolbar TO e_object->mt_toolbar.


    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    MOVE 'RUN' TO ls_toolbar-function.                      "#EC NOTEXT
    MOVE  icon_release TO ls_toolbar-icon.
    MOVE 'Execute Query'(201) TO ls_toolbar-quickinfo.
    "MOVE 'Execute Query'(201) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.                        "#EC NOTEXT
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    MOVE 'SHOW' TO ls_toolbar-function.                     "#EC NOTEXT
    MOVE  icon_display_text TO ls_toolbar-icon.
    MOVE 'Show Code'(201) TO ls_toolbar-quickinfo.
    "MOVE 'Show Code'(201) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.                        "#EC NOTEXT
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.


    CLEAR ls_toolbar.
    MOVE 'FLY' TO ls_toolbar-function.                      "#EC NOTEXT
    MOVE  icon_flight TO ls_toolbar-icon.
    MOVE 'Run Join Wizard'(201) TO ls_toolbar-quickinfo.
    "MOVE 'Show Code'(201) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.                        "#EC NOTEXT
    APPEND ls_toolbar TO e_object->mt_toolbar.


  ENDMETHOD.                    "handle_toolbar_where

  METHOD handle_user_command_where.
    CASE e_ucomm .

      WHEN 'MOVEUP' .
        PERFORM move_row_up.
      WHEN 'MOVEDOWN' .
        PERFORM move_row_down.
      WHEN 'RUN' .
        PERFORM run_query.
      WHEN 'FLY' .
        PERFORM fly.
      WHEN 'SHOW' .
        PERFORM show_code.
      WHEN 'IMPORT' .
        PERFORM import_select.
      WHEN 'IMPORT_BD' .
        PERFORM import_select_bd.
      WHEN 'EXPORT_BD' .
        PERFORM export_select_bd.
      WHEN 'EXPORT' .
        PERFORM export_select.
      WHEN 'SAVE' .
        PERFORM save.
      WHEN 'LIST' .
        PERFORM list USING ''.
      WHEN 'LIST2' .
        PERFORM list USING 'all_query'.
    ENDCASE .


  ENDMETHOD.                    "handle_user_command_where

ENDCLASS . "lcl_event_handler IMPLEMENTATION
*----------------endclass----------------------------

CLASS cls_event_handler DEFINITION.

  PUBLIC SECTION.
    METHODS:
*     Handles method function_selected  for the toolbar control
      on_function_selected FOR EVENT function_selected
                    OF cl_gui_toolbar
        IMPORTING fcode.

ENDCLASS. "cls_event_handler DEFINITION

*----------------------------------------------------------------------*
*       CLASS cls_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cls_event_handler IMPLEMENTATION.

* Handles method function_selected  for the toolbar control
  METHOD on_function_selected.
    DATA: l_t_objects   TYPE aqq_t_objects,
          wa_t_objects  LIKE LINE OF l_t_objects,
          l_lin_objects TYPE i.

    REFRESH l_t_objects.
    CLEAR: l_lin_objects,
           wa_t_objects.

    CASE fcode.
      WHEN 'EXIT'.
        PERFORM join_wizard_exit.
      WHEN 'TABLE'.
        join_wizard->handle_fcode( EXPORTING i_fcode = 'TINS' ).
      WHEN 'F_LDEL'.
        join_wizard->get_selected_link( IMPORTING e_link = l_t_objects ).
        LOOP AT l_t_objects TRANSPORTING NO FIELDS WHERE NOT r_link IS INITIAL.
          l_lin_objects = l_lin_objects + 1.
        ENDLOOP.
        IF l_lin_objects = 1.
          LOOP AT l_t_objects INTO wa_t_objects WHERE  NOT r_link IS INITIAL.
          ENDLOOP.
          join_wizard->handle_fcode( EXPORTING i_fcode    = 'F_LDEL'
                                               ir_table   = wa_t_objects-r_table
                                               i_rowindex = 0
                                               ir_link    = wa_t_objects-r_link  ).
        ENDIF.

        CLEAR l_lin_objects.
        LOOP AT l_t_objects TRANSPORTING NO FIELDS WHERE NOT r_table IS INITIAL.
          l_lin_objects = l_lin_objects + 1.
        ENDLOOP.
        IF l_lin_objects = 1.
          join_wizard->remove_tobject( ).
        ENDIF.
      WHEN 'ALIAS'.
        join_wizard->handle_fcode( EXPORTING i_fcode    = 'ALTB' ).
      WHEN 'F_NAVI'.
        join_wizard->handle_fcode( EXPORTING i_fcode    = 'F_NAVI' ).
      WHEN 'F_ZOOMIN'.
        join_wizard->handle_fcode( EXPORTING i_fcode    = 'F_ZOOMIN' ).
      WHEN 'F_ZOOMOUT'.
        join_wizard->handle_fcode( EXPORTING i_fcode    = 'F_ZOOMOUT' ).
      WHEN 'REMOVETEXT'.
        PERFORM remove_text.
      WHEN 'SAVE'.
        PERFORM save_join.
      WHEN 'FILLTEXT'.
        PERFORM transport_text.
      WHEN 'DELETE_ALL'.
        join_wizard->delete_all_table(  ).
    ENDCASE.
  ENDMETHOD.                    "on_function_selected

ENDCLASS. "cls_event_handler IMPLEMENTATION


*//--------- event hendler------------------
DATA gr_event_handler TYPE REF TO lcl_event_handler .

INITIALIZATION.

  lv_key_select = 'ZMAIN'.

START-OF-SELECTION.

AT SELECTION-SCREEN OUTPUT.
  repid = sy-repid.



  IF docking_left IS INITIAL.



*Create the docking and splitter containers
    CREATE OBJECT:

    docking_left
    EXPORTING repid = repid
    dynnr = sy-dynnr
    side = docking_left->dock_at_top
    extension = 1000,

    splitter
    EXPORTING parent = docking_left
    rows = 5
    columns = 1.

    CALL METHOD:

    splitter->set_border
    EXPORTING border = space,

    splitter->get_container
    EXPORTING row = 1
    column = 1
    RECEIVING container = dock_sub_cont1,

    splitter->set_row_height
    EXPORTING id = 1
    height = '30',

    splitter->set_row_height
    EXPORTING id = 4
    height = '0',

    splitter->set_row_height
    EXPORTING id = 5
    height = '0',




    splitter->get_container
    EXPORTING row = 2
    column = 1
    RECEIVING container = dock_sub_cont2,

    splitter->get_container
    EXPORTING row = 3
    column = 1
    RECEIVING container = dock_sub_cont3,

    splitter->get_container
    EXPORTING row = 4
    column = 1
    RECEIVING container = dock_sub_cont4,

    splitter->get_container
    EXPORTING row = 5
    column = 1
    RECEIVING container = dock_sub_cont5.

    CREATE OBJECT splitter3
      EXPORTING
        parent  = dock_sub_cont5
        rows    = 2
        columns = 1.

    CALL METHOD:

     splitter3->set_border
     EXPORTING border = space,

     splitter3->get_container
     EXPORTING row = 1
     column = 1
     RECEIVING container = dock_sub_cont5_1,

    splitter3->set_row_height
    EXPORTING id = 1
    height = '12',

     splitter3->get_container
     EXPORTING row = 2
     column = 1
     RECEIVING container = dock_sub_cont5_2.

*>>>---join_wizard  heigh #################
    g_mode = 1.
    CREATE OBJECT g_join_data
      EXPORTING
        i_sgname       = g_sgname
        i_actworkspace = act_workspace
        i_headsg       = headsg
        i_maxsg_tindx  = maxsg_tindx
        i_mode         = g_mode
        i_caller_id    = g_caller_id
        it_clogsg      = clogsg[]
        it_dbsa        = dbsa[]
        it_dbob        = dbob[]
        it_dbos        = dbos[]
        it_dbif        = dbif[]
        it_dbsf        = dbsf[]
        it_dbsg        = dbsg[]
        it_dban        = dban[]
        it_dbjt        = dbjt[]
        it_dbjc        = dbjc[]
        it_dbzt        = dbzt[]
        it_dbzc        = dbzc[]
        it_dbzl        = dbzl[]
        it_dbdp        = dbdp[]
        it_dbpa        = dbpa[]
        it_dbwr        = dbwr[]
        it_dbar        = dbar[]
        it_dbft        = dbft[]
        it_sgtext      = sgtext[]
        it_exdbfi      = exdbfi[]
        it_ttab        = ttab[].

    CREATE OBJECT join_wizard
      EXPORTING
        i_r_container_parent = dock_sub_cont5_2
        i_join_data_r        = g_join_data
        i_mode               = g_mode.

*<<<---join_wizard



    CREATE OBJECT splitter2
      EXPORTING
        parent  = dock_sub_cont1
        rows    = 1
        columns = 4.

    CALL METHOD:

    splitter2->set_border
    EXPORTING border = space,

    splitter2->get_container
    EXPORTING row = 1
    column = 1
    RECEIVING container = dock_sub_cont1_1,

    splitter2->get_container
    EXPORTING row = 1
    column = 2
    RECEIVING container = dock_sub_cont1_2,

    splitter2->get_container
    EXPORTING row = 1
    column = 3
    RECEIVING container = dock_sub_cont1_3,

    splitter2->get_container
    EXPORTING row = 1
    column = 4
    RECEIVING container = dock_sub_cont1_4,

    splitter2->set_column_width
    EXPORTING id = 1
    width = '18'.



*/-----------------------------------------
    CREATE OBJECT text_editor_top
      EXPORTING
        parent = dock_sub_cont3.


    xtext = 'This is a test for aRs'.
    APPEND xtext TO itext.
    xtext = 'Good Luck!!'.
    APPEND xtext TO itext.

    CALL METHOD text_editor_top->set_text_as_r3table
      EXPORTING
        table  = itext
      EXCEPTIONS
        OTHERS = 1.

    PERFORM fil_table.

*/------------------------------------
    CREATE OBJECT alv_tabname
      EXPORTING
        i_parent = dock_sub_cont1_1.

    PERFORM prepare_field_catalog_tabname CHANGING gt_fieldcat_tabname .
    PERFORM prepare_layout_tabname CHANGING gs_layout_tabname .
    PERFORM exclude_tb_functions_tabname CHANGING gt_exclude_tabname.

    "---------event-edit-register
    CALL METHOD alv_tabname->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

    CALL METHOD alv_tabname->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    CREATE OBJECT gr_event_handler.

    SET HANDLER gr_event_handler->handle_double_click_tabname FOR alv_tabname  .
    SET HANDLER gr_event_handler->handle_data_changed_tabname FOR alv_tabname  .

    "-----------------------------

    CALL METHOD alv_tabname->set_table_for_first_display
      EXPORTING
        it_toolbar_excluding = gt_exclude_tabname
        is_layout            = gs_layout_tabname
      CHANGING
        it_outtab            = it_tabname[]
        it_fieldcatalog      = gt_fieldcat_tabname.
*/------------------------------------
    CREATE OBJECT alv_select
      EXPORTING
        i_appl_events = 'X'
        i_parent      = dock_sub_cont1_2.

    PERFORM prepare_field_catalog_select CHANGING gt_fieldcat_select .
    PERFORM prepare_layout_select CHANGING gs_layout_select .
    PERFORM exclude_tb_functions_tabname CHANGING gt_exclude_tabname.

    CALL METHOD alv_select->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

    CALL METHOD alv_select->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.


    SET HANDLER gr_event_handler->handle_button_click_select FOR alv_select  .
    SET HANDLER gr_event_handler->handle_data_changed_select FOR alv_select  .
    SET HANDLER gr_event_handler->handle_data_changed_fi_select FOR alv_select  .


    CALL METHOD alv_select->set_table_for_first_display
      EXPORTING
        it_toolbar_excluding = gt_exclude_tabname
        is_layout            = gs_layout_select
      CHANGING
        it_outtab            = it_select[]
        it_fieldcatalog      = gt_fieldcat_select.

*/------------------------------------
    CREATE OBJECT alv_join
      EXPORTING
        i_appl_events = 'X'
        i_parent      = dock_sub_cont1_3.

    PERFORM prepare_field_catalog_join CHANGING gt_fieldcat_join .
    PERFORM prepare_layout_join CHANGING gs_layout_join .
    PERFORM exclude_tb_functions_tabname CHANGING gt_exclude_tabname.
    PERFORM register_f4_join .

    CALL METHOD alv_join->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

    CALL METHOD alv_join->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    SET HANDLER gr_event_handler->handle_button_click_join FOR alv_join  .
    SET HANDLER gr_event_handler->handle_data_changed_join FOR alv_join  .
    SET HANDLER gr_event_handler->handle_data_changed_fi_join FOR alv_join  .
    SET HANDLER gr_event_handler->handle_f4_join FOR alv_join  .

    PERFORM set_drdn_table_join.

    CALL METHOD alv_join->set_table_for_first_display
      EXPORTING
        it_toolbar_excluding = gt_exclude_tabname
        is_layout            = gs_layout_join
      CHANGING
        it_outtab            = it_join[]
        it_fieldcatalog      = gt_fieldcat_join.
*/------------------------------------
    CREATE OBJECT alv_join_condition
      EXPORTING
        i_parent = dock_sub_cont1_4.

    PERFORM prepare_field_catalog_join_co CHANGING gt_fieldcat_join_condition .
    PERFORM prepare_layout_join_condition CHANGING gs_layout_join_condition .
    PERFORM exclude_tb_functions_tabname CHANGING gt_exclude_tabname.
    PERFORM register_f4_join_condition .

    CALL METHOD alv_join_condition->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    SET HANDLER gr_event_handler->handle_data_changed_join_cond FOR alv_join_condition  .
    SET HANDLER gr_event_handler->handle_f4_join_condition FOR alv_join_condition  .


    CALL METHOD alv_join_condition->set_table_for_first_display
      EXPORTING
        it_toolbar_excluding = gt_exclude_tabname
        is_layout            = gs_layout_join_condition
      CHANGING
        it_outtab            = it_join_condition[]
        it_fieldcatalog      = gt_fieldcat_join_condition.

*/------------------------------------
    CREATE OBJECT alv_where
      EXPORTING
        i_appl_events = 'X'
        i_parent      = dock_sub_cont2.


    PERFORM prepare_field_catalog_where CHANGING gt_fieldcat_where .
    PERFORM prepare_layout_where CHANGING gs_layout_where .
    PERFORM exclude_tb_functions_where CHANGING gt_exclude_where.
    PERFORM register_f4_where .
*>>>>--bug update

    CALL METHOD alv_where->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.


    SET HANDLER gr_event_handler->handle_data_changed_where FOR alv_where  .
    SET HANDLER gr_event_handler->handle_data_changed_fi_where FOR alv_where  .
    SET HANDLER gr_event_handler->handle_f4_where FOR alv_where  .
    SET HANDLER gr_event_handler->handle_toolbar_where FOR alv_where  .
    SET HANDLER gr_event_handler->handle_user_command_where FOR alv_where  .

    PERFORM set_drdn_table_where.

    " CALL METHOD alv_where->set_toolbar_interactive.

    CALL METHOD alv_where->set_table_for_first_display
      EXPORTING
        it_toolbar_excluding = gt_exclude_where
        is_layout            = gs_layout_where
      CHANGING
        it_outtab            = it_where[]
        it_fieldcatalog      = gt_fieldcat_where.

*/--------------toolbar_here----------------------
    CREATE OBJECT go_toolbar
      EXPORTING
        parent = dock_sub_cont5_1.
* Add buttons to the toolbar
    PERFORM add_button_group.

* Create event table. The event ID must be found in the
* documentation of the specific control
    CLEAR gs_event.
    REFRESH gt_events.
    gs_event-eventid    = go_toolbar->m_id_function_selected.
    gs_event-appl_event = 'X'.           " This is an application event
    APPEND gs_event TO gt_events.

* Use the events table to register events for the control
    CALL METHOD go_toolbar->set_registered_events
      EXPORTING
        events = gt_events.

* Create event handlers
    CREATE OBJECT go_event_handler.

    SET HANDLER go_event_handler->on_function_selected
            FOR go_toolbar.

    "-------------event handler-----------------
*/------------------------------------------------


  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  prepare_field_catalog_tabname
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM prepare_field_catalog_tabname CHANGING pt_fieldcat TYPE lvc_t_fcat .
  DATA ls_fcat TYPE lvc_s_fcat .
  REFRESH: pt_fieldcat.
  ls_fcat-fieldname = 'TABNAME' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '30' .
  ls_fcat-coltext   = 'Table' .
  ls_fcat-seltext   = 'Table' .
  ls_fcat-edit      = 'X'.
  APPEND ls_fcat TO pt_fieldcat .

  CLEAR ls_fcat.
  ls_fcat-fieldname = 'ALIAS' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '30' .
  ls_fcat-coltext   = '___Alias___' .
  ls_fcat-seltext   = '___Alias___' .
  ls_fcat-edit      = 'X'.
  APPEND ls_fcat TO pt_fieldcat .
ENDFORM. "prepare_field_catalog_tabname

*&---------------------------------------------------------------------*
*&      Form  prepare_field_catalog_Select
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM prepare_field_catalog_select CHANGING pt_fieldcat TYPE lvc_t_fcat .
  DATA ls_fcat TYPE lvc_s_fcat .
  REFRESH: pt_fieldcat.

  ls_fcat-fieldname = 'BUT' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '5' .
  ls_fcat-coltext   = '__X__' .

  APPEND ls_fcat TO pt_fieldcat .

  ls_fcat-fieldname = 'SSELECT' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '30' .
  ls_fcat-coltext   = 'Select' .
  ls_fcat-seltext   = 'Select' .
  ls_fcat-edit      = 'X'.
  APPEND ls_fcat TO pt_fieldcat .



ENDFORM. "prepare_field_catalog_tabname
*&---------------------------------------------------------------------*
*&      Form  prepare_field_catalog_join
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM prepare_field_catalog_join CHANGING pt_fieldcat TYPE lvc_t_fcat .
  DATA ls_fcat TYPE lvc_s_fcat .
  REFRESH: pt_fieldcat.

  ls_fcat-fieldname = 'BUT' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '5' .
  ls_fcat-coltext   = '__X__' .

  APPEND ls_fcat TO pt_fieldcat .

  ls_fcat-fieldname = 'JJOIN' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '30' .
  ls_fcat-coltext   = 'JOIN' .
  ls_fcat-seltext   = 'JOIN' .
  ls_fcat-col_opt   = 'X' .
  ls_fcat-edit      = 'X'.
  APPEND ls_fcat TO pt_fieldcat .

  ls_fcat-fieldname = 'TTYPE' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '30' .
  ls_fcat-coltext   = 'TYPE' .
  ls_fcat-seltext   = 'TYPE' .
  ls_fcat-col_opt   = 'X' .
  ls_fcat-edit      = 'X'.
  ls_fcat-drdn_hndl = '1'.
  APPEND ls_fcat TO pt_fieldcat .
  CLEAR ls_fcat.

  ls_fcat-fieldname = 'LEFT' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '30' .
  ls_fcat-coltext   = 'Left' .
  ls_fcat-seltext   = 'Left' .
  ls_fcat-col_opt   = 'X' .
  ls_fcat-edit      = 'X'.
  ls_fcat-f4availabl     =  'X'.
  APPEND ls_fcat TO pt_fieldcat .
  CLEAR ls_fcat.

  ls_fcat-fieldname = 'RIGHT' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '30' .
  ls_fcat-coltext   = 'Right' .
  ls_fcat-seltext   = 'Right' .
  ls_fcat-col_opt   = 'X' .
  ls_fcat-edit      = 'X'.
  ls_fcat-f4availabl     =  'X'.
  APPEND ls_fcat TO pt_fieldcat .
ENDFORM. "prepare_field_catalog_tabname

*&---------------------------------------------------------------------*
*&      Form  prepare_field_catalog_join_co
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM prepare_field_catalog_join_co CHANGING pt_fieldcat TYPE lvc_t_fcat .
  DATA ls_fcat TYPE lvc_s_fcat .

  ls_fcat-fieldname = 'LEFT' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '30' .
  ls_fcat-coltext   = 'Left field' .
  ls_fcat-seltext   = 'Left field' .
  ls_fcat-col_opt   = 'X' .
  ls_fcat-edit      = 'X'.
  ls_fcat-f4availabl     =  'X'.
  APPEND ls_fcat TO pt_fieldcat .
  CLEAR ls_fcat.

  ls_fcat-fieldname = 'RIGHT' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '30' .
  ls_fcat-coltext   = 'Right field' .
  ls_fcat-seltext   = 'Right field' .
  ls_fcat-col_opt   = 'X' .
  ls_fcat-edit      = 'X'.
  ls_fcat-f4availabl     =  'X'.
  APPEND ls_fcat TO pt_fieldcat .
  CLEAR ls_fcat.
ENDFORM. "prepare_field_catalog_tabname



*-------------my-definition------------

*&---------------------------------------------------------------------*
*&      Form  exclude_tb_functions
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_EXCLUDE text
*----------------------------------------------------------------------*
FORM exclude_tb_functions_tabname CHANGING pt_exclude TYPE ui_functions.
  APPEND '&CHECK' TO pt_exclude.
  APPEND '&REFRESH' TO pt_exclude.
  APPEND '&LOCAL&CUT' TO pt_exclude.
  APPEND '&LOCAL#' TO pt_exclude.
  APPEND '&LOCAL&PASTE' TO pt_exclude.
  APPEND '&LOCAL&UNDO' TO pt_exclude.
  APPEND '&DETAIL' TO pt_exclude.
  APPEND '&LOCAL&COPY_ROW' TO pt_exclude.
  APPEND '&LOCAL&INSERT_ROW' TO pt_exclude.
  APPEND '&SORT_ASC' TO pt_exclude.
  APPEND '&SORT_DSC' TO pt_exclude.
  APPEND '&FIND' TO pt_exclude.
  APPEND '&FIND_MORE' TO pt_exclude.
  APPEND '&MB_FILTER' TO pt_exclude.
  APPEND '&MB_SUM' TO pt_exclude.
  APPEND '&MB_SUBTOT' TO pt_exclude.
  APPEND '&PRINT_BACK' TO pt_exclude.
  APPEND '&MB_VIEW' TO pt_exclude.
  APPEND '&MB_EXPORT' TO pt_exclude.
  APPEND '&MB_VARIANT' TO pt_exclude.
  APPEND '&GRAPH' TO pt_exclude.
  APPEND '&INFO' TO pt_exclude.
ENDFORM. " EXCLUDE_TB_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  exclude_tb_functions_where
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_EXCLUDE text
*----------------------------------------------------------------------*
FORM exclude_tb_functions_where CHANGING pt_exclude TYPE ui_functions.
  APPEND '&CHECK' TO pt_exclude.
  APPEND '&REFRESH' TO pt_exclude.
  APPEND '&LOCAL&CUT' TO pt_exclude.
  APPEND '&LOCAL#' TO pt_exclude.
  APPEND '&LOCAL&PASTE' TO pt_exclude.
  APPEND '&LOCAL&UNDO' TO pt_exclude.
  APPEND '&DETAIL' TO pt_exclude.

  APPEND '&LOCAL&INSERT_ROW' TO pt_exclude.
  APPEND '&SORT_ASC' TO pt_exclude.
  APPEND '&SORT_DSC' TO pt_exclude.
  APPEND '&FIND' TO pt_exclude.
  APPEND '&FIND_MORE' TO pt_exclude.
  APPEND '&MB_FILTER' TO pt_exclude.
  APPEND '&MB_SUM' TO pt_exclude.
  APPEND '&MB_SUBTOT' TO pt_exclude.
  APPEND '&PRINT_BACK' TO pt_exclude.
  APPEND '&MB_VIEW' TO pt_exclude.
  APPEND '&MB_EXPORT' TO pt_exclude.
  APPEND '&MB_VARIANT' TO pt_exclude.
  APPEND '&GRAPH' TO pt_exclude.
  APPEND '&INFO' TO pt_exclude.
ENDFORM. "exclude_tb_functions_where
*&---------------------------------------------------------------------*
*&      Form  PREPARE_LAYOUT_TABNAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_LAYOUT_TABNAME  text
*----------------------------------------------------------------------*
FORM prepare_layout_tabname CHANGING p_gs_layout_tabname TYPE lvc_s_layo.
  p_gs_layout_tabname-cwidth_opt = 'X'.
  p_gs_layout_tabname-grid_title = 'Tables'.
  p_gs_layout_tabname-sel_mode   = 'A'.
  p_gs_layout_tabname-zebra      = 'X'.
ENDFORM. " PREPARE_LAYOUT_TABNAME
*&---------------------------------------------------------------------*
*&      Form  prepare_layout_select
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT_SELECT  text
*----------------------------------------------------------------------*
FORM prepare_layout_select CHANGING p_gs_layout_select TYPE lvc_s_layo.
  p_gs_layout_select-cwidth_opt = 'X'.
  p_gs_layout_select-grid_title = 'Select'.
  p_gs_layout_select-sel_mode   = 'C'.
  p_gs_layout_select-no_rowmark = 'X'.
  p_gs_layout_select-zebra      = 'X'.
  p_gs_layout_select-stylefname = 'CELLSTYLES' .
ENDFORM. " PREPARE_LAYOUT_TABNAME
*&---------------------------------------------------------------------*
*&      Form  prepare_layout_join
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT_SELECT  text
*----------------------------------------------------------------------*
FORM prepare_layout_join CHANGING p_gs_layout_join TYPE lvc_s_layo.
  p_gs_layout_join-cwidth_opt = ' '.
  p_gs_layout_join-grid_title = 'Join'.
  p_gs_layout_join-sel_mode   = 'A'.
  p_gs_layout_join-no_rowmark = 'X'.
  p_gs_layout_join-zebra      = 'X'.
  p_gs_layout_join-stylefname = 'CELLSTYLES' .
ENDFORM. " PREPARE_LAYOUT_TABNAME
*&---------------------------------------------------------------------*
*&      Form  prepare_layout_join_condition
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT_JOIN_CO  text
*----------------------------------------------------------------------*
FORM prepare_layout_join_condition CHANGING p_gs_layout_join_co TYPE lvc_s_layo.
  p_gs_layout_join_co-cwidth_opt = ' '.
  p_gs_layout_join_co-grid_title = 'Join condition'.
  p_gs_layout_join_co-sel_mode   = 'A'.
  p_gs_layout_join_co-zebra      = 'X'.
ENDFORM. " PREPARE_LAYOUT_TABNAME
*&---------------------------------------------------------------------*
*&      Form  PREPARE_FIELD_CATALOG_WHERE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_FIELDCAT_WHERE  text
*----------------------------------------------------------------------*
FORM prepare_field_catalog_where CHANGING pt_fieldcat TYPE lvc_t_fcat .

  DATA ls_fcat TYPE lvc_s_fcat .
  REFRESH: pt_fieldcat.

  CLEAR  ls_fcat.
  ls_fcat-fieldname = 'OUTPUT' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '1' .
  ls_fcat-coltext   = 'OUTPUT' .
  ls_fcat-seltext   = 'OUTPUT' .
  ls_fcat-edit      = 'X'.
  ls_fcat-checkbox  = 'X'.
  APPEND ls_fcat TO pt_fieldcat .

  CLEAR  ls_fcat.
  ls_fcat-fieldname = 'EXPRESSION' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '60' .
  ls_fcat-coltext   = '____Fields____' .
  ls_fcat-seltext   = '____Fields____' .
  ls_fcat-edit      = 'X'.
  APPEND ls_fcat TO pt_fieldcat .

  CLEAR  ls_fcat.
  ls_fcat-fieldname = 'ALIAS' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '30' .
  ls_fcat-coltext   = 'Alias' .
  ls_fcat-seltext   = 'Alias' .
  ls_fcat-edit      = 'X'.
  APPEND ls_fcat TO pt_fieldcat .

  CLEAR  ls_fcat.
  ls_fcat-fieldname = 'TITLE' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '40' .
  ls_fcat-coltext   = 'Title' .
  ls_fcat-seltext   = 'Title' .
  ls_fcat-ref_table   = 'ZAAQB_S' .
  ls_fcat-ref_field   = 'TITLE' .
  ls_fcat-edit      = 'X'.
  APPEND ls_fcat TO pt_fieldcat .

  CLEAR  ls_fcat.
  ls_fcat-fieldname = 'AGGREGATE' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '15' .
  ls_fcat-coltext   = 'Agregate' .
  ls_fcat-seltext   = 'Agregate' .
  ls_fcat-edit      = 'X'.
  ls_fcat-drdn_hndl = '1'.
  APPEND ls_fcat TO pt_fieldcat .
  CLEAR ls_fcat.

  CLEAR  ls_fcat.
  ls_fcat-fieldname = 'SORTTYPE' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '10' .
  ls_fcat-coltext   = 'Sort Type' .
  ls_fcat-seltext   = 'Sort Type' .
  ls_fcat-edit      = 'X'.
  ls_fcat-drdn_hndl = '2'.
  APPEND ls_fcat TO pt_fieldcat .
  CLEAR ls_fcat.

  CLEAR  ls_fcat.
  ls_fcat-fieldname = 'SORTORDER' .
  ls_fcat-inttype   = 'I' .
  ls_fcat-outputlen = '10' .
  ls_fcat-coltext   = 'Sort Order' .
  ls_fcat-seltext   = 'Sort Order' .
  ls_fcat-edit      = 'X'.
  APPEND ls_fcat TO pt_fieldcat .
*no group
*  CLEAR  ls_fcat.
*  ls_fcat-fieldname = 'GROUPING' .
*  ls_fcat-inttype   = 'C' .
*  ls_fcat-outputlen = '1' .
*  ls_fcat-coltext   = '###########' .
*  ls_fcat-seltext   = '###########' .
*  ls_fcat-edit      = 'X'.
*  ls_fcat-checkbox  = 'X'.
*  APPEND ls_fcat TO pt_fieldcat .

  CLEAR  ls_fcat.
  ls_fcat-fieldname = 'CRITERIAFOR' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '12' .
  ls_fcat-coltext   = 'CRITERIAFOR' .
  ls_fcat-seltext   = 'CRITERIAFOR' .
  ls_fcat-edit      = 'X'.
  ls_fcat-drdn_hndl = '3'.
  APPEND ls_fcat TO pt_fieldcat .
  CLEAR ls_fcat.

  CLEAR  ls_fcat.
  ls_fcat-fieldname = 'DISABLE_CRITERIA' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '1' .
  ls_fcat-coltext   = 'NO_CHECK' .
  ls_fcat-seltext   = 'NO_CHECK' .
  ls_fcat-edit      = 'X'.
  ls_fcat-checkbox  = 'X'.
  APPEND ls_fcat TO pt_fieldcat .

  CLEAR  ls_fcat.
  ls_fcat-fieldname = 'OR1' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '80' .
  ls_fcat-coltext   = '_____or_____' .
  ls_fcat-seltext   = '_____or_____' .
  ls_fcat-edit      = 'X'.
  ls_fcat-f4availabl     =  'X'.
  APPEND ls_fcat TO pt_fieldcat .
  CLEAR ls_fcat.

  CLEAR  ls_fcat.
  ls_fcat-fieldname = 'OR2' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '80' .
  ls_fcat-coltext   = '_____or_____' .
  ls_fcat-seltext   = '_____or_____' .
  ls_fcat-edit      = 'X'.
  ls_fcat-f4availabl     =  'X'.
  APPEND ls_fcat TO pt_fieldcat .
  CLEAR ls_fcat.

  CLEAR  ls_fcat.
  ls_fcat-fieldname = 'OR3' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '80' .
  ls_fcat-coltext   = '_____or_____' .
  ls_fcat-seltext   = '_____or_____' .
  ls_fcat-edit      = 'X'.
  ls_fcat-f4availabl     =  'X'.
  APPEND ls_fcat TO pt_fieldcat .
  CLEAR ls_fcat.

  CLEAR  ls_fcat.
  ls_fcat-fieldname = 'OR4' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '80' .
  ls_fcat-coltext   = '_____or_____' .
  ls_fcat-seltext   = '_____or_____' .
  ls_fcat-edit      = 'X'.
  ls_fcat-f4availabl     =  'X'.
  APPEND ls_fcat TO pt_fieldcat .
  CLEAR ls_fcat.

  CLEAR  ls_fcat.
  ls_fcat-fieldname = 'SELECTABLE' .
  ls_fcat-inttype   = 'C' .
  ls_fcat-outputlen = '1' .
  ls_fcat-coltext   = 'SELECTABLE' .
  ls_fcat-seltext   = 'SELECTABLE' .
  ls_fcat-edit      = 'X'.
  ls_fcat-checkbox  = 'X'.
  APPEND ls_fcat TO pt_fieldcat .

ENDFORM. " PREPARE_FIELD_CATALOG_WHERE


*&---------------------------------------------------------------------*
*&      Form  prepare_field_catalog_output
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM prepare_field_catalog_output CHANGING pt_fieldcat TYPE lvc_t_fcat .
  DATA
        : ls_fcat TYPE lvc_s_fcat
        , str1 TYPE string
        , str2 TYPE string
        .

  REFRESH: pt_fieldcat.

  LOOP AT comp_tab INTO comp_fld .
    CLEAR ls_fcat.
    ls_fcat-fieldname  = comp_fld-name.
    ls_fcat-inttype    = comp_fld-type_kind.
    ls_fcat-outputlen  = comp_fld-length.
    READ TABLE it_where WITH KEY output = 'X' alias = comp_fld-name.
    IF sy-subrc = 0.
      IF it_where-title IS NOT INITIAL .
        ls_fcat-coltext = it_where-title.
      ENDIF.
    ELSE.

      LOOP AT it_where WHERE output = 'X' AND alias EQ ''.

        SPLIT it_where-expression AT '~' INTO str1 str2.

        IF str2 = comp_fld-name.
          IF it_where-title IS NOT INITIAL .
            ls_fcat-coltext = it_where-title.
            EXIT.
          ENDIF.
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF ls_fcat-coltext IS INITIAL .
      ls_fcat-coltext    = comp_fld-name.
    ENDIF.

    ls_fcat-emphasize  = 'X'.
    ls_fcat-decimals_o = comp_fld-decimals.
    APPEND ls_fcat TO pt_fieldcat .

  ENDLOOP.

ENDFORM. "prepare_field_catalog_output
*&---------------------------------------------------------------------*
*&      Form  PREPARE_LAYOUT_WHERE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_LAYOUT_WHERE  text
*----------------------------------------------------------------------*
FORM prepare_layout_where CHANGING p_gs_layout_where TYPE lvc_s_layo.

  p_gs_layout_where-cwidth_opt = 'X'.
  p_gs_layout_where-grid_title = 'Where'.
  p_gs_layout_where-sel_mode   = 'A'.
  p_gs_layout_where-zebra      = 'X'.

ENDFORM. " PREPARE_LAYOUT_WHERE

*&---------------------------------------------------------------------*
*&      Form  prepare_layout_output
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT_OUTPUT  text
*----------------------------------------------------------------------*
FORM prepare_layout_output CHANGING p_gs_layout_output TYPE lvc_s_layo.

  p_gs_layout_output-cwidth_opt = 'X'.
  p_gs_layout_output-grid_title = 'Output'.
  p_gs_layout_output-sel_mode   = 'A'.
  p_gs_layout_output-zebra      = 'X'.

ENDFORM. " PREPARE_LAYOUT_WHERE
*&---------------------------------------------------------------------*
*&      Form  FIL_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fil_table .
  DATA ls_style TYPE lvc_s_styl .

  CLEAR: it_where,
         it_tabname.
  DO 9 TIMES.
    it_where-lv_key_select = 'ZMAIN'.
    APPEND it_where.
    APPEND it_tabname.

    CLEAR: it_select,
            it_join.

    ls_style-fieldname = 'BUT' .
    ls_style-style = cl_gui_alv_grid=>mc_style_button .
    APPEND ls_style TO it_select-cellstyles .

    APPEND it_select.

    " it_join_condition-lv_key_select = 'ZMAIN'.
    "APPEND it_join_condition.
  ENDDO.
  READ TABLE it_select INDEX 1.
  it_select-sselect = 'ZMAIN'.
  MODIFY it_select INDEX 1.


ENDFORM. " FIL_TABLE
*&---------------------------------------------------------------------*
*&      Form  HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM handle_double_click USING p_e_row TYPE lvc_s_row
                                   p_e_column TYPE lvc_s_col
                                   p_es_row_no TYPE lvc_s_roid.
  READ TABLE it_tabname INDEX p_es_row_no-row_id .
  IF sy-subrc = 0  .

    PERFORM f_read_field USING it_tabname-tabname.
    PERFORM f_display_data USING it_tabname-tabname it_tabname-alias.
  ENDIF .

ENDFORM. " HANDLE_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  f_read_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_TABLE    text
*----------------------------------------------------------------------*
FORM f_read_field USING t_table TYPE tabname.

  DATA:
    comp_tab    TYPE abap_compdescr_tab,
    wa_comp_tab LIKE LINE OF comp_tab,
    struct_type TYPE REF TO cl_abap_structdescr.

  REFRESH gt_field.
  PERFORM get_struct TABLES  comp_tab[]  USING t_table  struct_type  .

  LOOP AT comp_tab INTO wa_comp_tab.
    gt_field-fieldname = wa_comp_tab-name.
    SELECT SINGLE dd04t~ddtext
      INTO gt_field-ddtext
      FROM dd03l JOIN dd04t ON dd03l~rollname = dd04t~rollname
      WHERE dd04t~ddlanguage = sy-langu AND
            dd03l~fieldname = wa_comp_tab-name.

    IF sy-subrc <> 0.
      gt_field-ddtext = gt_field-fieldname.
    ENDIF.

    APPEND gt_field.

  ENDLOOP.

** Read fields and description of tabname
*  SELECT dd03l~fieldname dd04t~ddtext
*    INTO CORRESPONDING FIELDS OF TABLE gt_field
*    FROM dd03l JOIN dd04t ON dd03l~rollname = dd04t~rollname
*    WHERE dd03l~tabname    = t_table AND
*          dd04t~ddlanguage = sy-langu AND
*          dd03l~rollname   <> '' .

ENDFORM. "f_read_field

*&---------------------------------------------------------------------*
*&      Form  f_display_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_display_data USING t_table TYPE tabname t_alias TYPE tabname.

  TYPE-POOLS: slis.                    " ALV Global types

  DATA:
    l_exit,
    ls_private            TYPE slis_data_caller_exit,
    ls_field              TYPE ty_field_desc,
    ls_fieldcat           TYPE slis_fieldcat_alv,
    lt_fieldcat           TYPE slis_t_fieldcat_alv,
    lv_fieldname          TYPE reptext,
    lv_rollname           TYPE reptext,

    lv_str_expression(61) TYPE c
    .

  IF t_alias IS  INITIAL.
    t_alias = t_table.
  ENDIF.

  SELECT SINGLE reptext
    FROM dd04t
    INTO lv_fieldname
    WHERE ddlanguage = sy-langu AND
          rollname   = 'FIELDNAME' .

  SELECT SINGLE reptext
    FROM dd04t
    INTO lv_rollname
    WHERE ddlanguage = sy-langu AND
          rollname   = 'ROLLNAME' .

* Build the field catalog


  ls_fieldcat-fieldname = 'FIELDNAME' .
  ls_fieldcat-inttype   = 'C' .
  ls_fieldcat-outputlen = '30' .
  "ls_fieldcat-coltext   = 'fieldname' .
  ls_fieldcat-seltext_l    = lv_fieldname .
  APPEND ls_fieldcat TO lt_fieldcat.

  ls_fieldcat-fieldname = 'DDTEXT' .
  ls_fieldcat-inttype   = 'C' .
  ls_fieldcat-outputlen = '60' .
  "ls_fieldcat-coltext   = 'fieldname' .
  ls_fieldcat-seltext_l    = lv_rollname .
  APPEND ls_fieldcat TO lt_fieldcat.


* Optimize column width
  ls_private-columnopt = 'X'.

  LOOP AT gt_field INTO wa_field .

    CONCATENATE t_alias '~' wa_field-fieldname INTO lv_str_expression.

    READ TABLE it_where WITH KEY expression = lv_str_expression lv_key_select = lv_key_select TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      wa_field-checkbox = 'X'.
      MODIFY gt_field FROM wa_field.
    ENDIF.


  ENDLOOP.

* Display data in a POPUP
  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_screen_start_column = 20
      i_selection           = 'X'
      i_zebra               = 'X'
      it_fieldcat           = lt_fieldcat
      i_tabname             = 'GT_FIELD'
      i_checkbox_fieldname  = 'CHECKBOX'
      is_private            = ls_private
    IMPORTING
      e_exit                = l_exit
    TABLES
      t_outtab              = gt_field[].

  CHECK l_exit = space.

  LOOP AT gt_field INTO wa_field WHERE checkbox = 'X'.
    CLEAR wa_where.
    wa_where-lv_key_select = lv_key_select.
    CONCATENATE t_alias '~' wa_field-fieldname INTO lv_str_expression.
    wa_where-expression    = lv_str_expression.
    wa_where-output = 'X'.

    READ TABLE it_where WITH KEY expression = lv_str_expression lv_key_select = lv_key_select TRANSPORTING NO FIELDS.
    IF sy-subrc = 4.
      READ TABLE it_where INTO wa_where2 WITH KEY expression = '' or1 = ''  lv_key_select = lv_key_select.
      IF sy-subrc NE 0.
        APPEND wa_where TO  it_where.
      ELSE.
        MOVE wa_where TO wa_where2.
        MODIFY it_where FROM wa_where2 INDEX sy-tabix.
      ENDIF.

    ENDIF.


  ENDLOOP.


  PERFORM recalc_cwidth_opt USING alv_where.
  CALL METHOD alv_where->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'.



ENDFORM. "f_display_data

*&---------------------------------------------------------------------*
*&      Form  set_filter_where
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LV_KEY_SELECT  text
*----------------------------------------------------------------------*
FORM set_filter_where USING lv_key_select TYPE c.
  CLEAR:    pt_filt  ,
            ls_filt  .

  ls_filt-fieldname = 'LV_KEY_SELECT' .
  ls_filt-sign = 'I' .
  ls_filt-option = 'EQ' .
  ls_filt-low = lv_key_select .

  APPEND ls_filt TO pt_filt .

  CALL METHOD alv_where->set_filter_criteria
    EXPORTING
      it_filter = pt_filt.

  PERFORM recalc_cwidth_opt USING alv_where.
  CALL METHOD alv_where->refresh_table_display .
ENDFORM. "set_filter_where

*&---------------------------------------------------------------------*
*&      Form  set_filter_join
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LV_KEY_SELECT  text
*----------------------------------------------------------------------*
FORM set_filter_join USING lv_key_select TYPE c.
  CLEAR:    pt_filt  ,
            ls_filt  .

  ls_filt-fieldname = 'LV_KEY_SELECT' .
  ls_filt-sign = 'I' .
  ls_filt-option = 'EQ' .
  ls_filt-low = lv_key_select .

  APPEND ls_filt TO pt_filt .

  CALL METHOD alv_join->set_filter_criteria
    EXPORTING
      it_filter = pt_filt.

  PERFORM recalc_cwidth_opt USING alv_join.
  CALL METHOD alv_join->refresh_table_display .
  lv_key_join = ''.
  LOOP AT it_join WHERE lv_key_select = lv_key_select AND jjoin NE ''.
    lv_key_join = it_join-jjoin.
  ENDLOOP.

ENDFORM. "set_filter_join

*&---------------------------------------------------------------------*
*&      Form  set_filter_join_condition
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LV_KEY_SELECT  text
*      -->LV_KEY_JOIN    text
*----------------------------------------------------------------------*
FORM set_filter_join_condition USING lv_key_select TYPE c lv_key_join TYPE c.
  CLEAR:    pt_filt  ,
            ls_filt  .

  ls_filt-fieldname = 'LV_KEY_SELECT' .
  ls_filt-sign = 'I' .
  ls_filt-option = 'EQ' .
  ls_filt-low = lv_key_select .

  APPEND ls_filt TO pt_filt .

  ls_filt-fieldname = 'LV_KEY_JOIN' .
  ls_filt-sign = 'I' .
  ls_filt-option = 'EQ' .
  ls_filt-low = lv_key_join .

  APPEND ls_filt TO pt_filt .

  CALL METHOD alv_join_condition->set_filter_criteria
    EXPORTING
      it_filter = pt_filt.

  PERFORM recalc_cwidth_opt USING alv_join_condition.
  CALL METHOD alv_join_condition->refresh_table_display .
ENDFORM. "set_filter_join_condition

*&---------------------------------------------------------------------*
*&      Form  set_drdn_table_join
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_drdn_table_join.

  DATA: lt_dropdown TYPE lvc_t_drop,
        ls_dropdown TYPE lvc_s_drop.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'INNER JOIN'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'JOIN'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'LEFT JOIN'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'LEFT outer JOIN'.
  APPEND ls_dropdown TO lt_dropdown.


  CALL METHOD alv_join->set_drop_down_table
    EXPORTING
      it_drop_down = lt_dropdown.

ENDFORM. " set_drdn_table

*&---------------------------------------------------------------------*
*&      Form  set_drdn_table_where
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_drdn_table_where.

  DATA: lt_dropdown TYPE lvc_t_drop,
        ls_dropdown TYPE lvc_s_drop.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'max'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'max distinct'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'count distinct'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'distinct'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'min'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'min distinct'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'avg'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'avg distinct'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'sum'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'sum distinct'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'count'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '2'.
  ls_dropdown-value = ''.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '2'.
  ls_dropdown-value = 'ASCENDING'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '2'.
  ls_dropdown-value = 'DESCENDING'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '3'.
  ls_dropdown-value = ''.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '3'.
  ls_dropdown-value = 'values'.
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = '3'.
  ls_dropdown-value = 'groups'.
  APPEND ls_dropdown TO lt_dropdown.




  CALL METHOD alv_where->set_drop_down_table
    EXPORTING
      it_drop_down = lt_dropdown.

ENDFORM. " set_drdn_table

*&---------------------------------------------------------------------*
*&      Form  sub_help_left
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LEFT       text
*----------------------------------------------------------------------*
FORM sub_help_left CHANGING left TYPE c.


  DATA: BEGIN OF inttab OCCURS 10,
          tabname TYPE tabname,
        END OF inttab,
        ret_tab    LIKE ddshretval OCCURS 0 WITH HEADER LINE,
        wa_tabname TYPE t_tabname.

  REFRESH inttab.
  LOOP AT it_tabname WHERE tabname NE ''.
    IF it_tabname-alias IS NOT INITIAL.
      wa_tabname = it_tabname-alias.
    ELSE.
      wa_tabname = it_tabname-tabname.
    ENDIF.
    APPEND wa_tabname TO inttab.
  ENDLOOP.

  LOOP AT it_join WHERE jjoin NE ''.
    wa_tabname = it_join-jjoin.
    APPEND wa_tabname TO inttab.
  ENDLOOP.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'TABNAME'
      window_title    = 'Select Table'
      value_org       = 'S'
      multiple_choice = ' '
    TABLES
      value_tab       = inttab
      return_tab      = ret_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc = 0.
    LOOP AT ret_tab.
      left =  ret_tab-fieldval.
    ENDLOOP.
  ENDIF.

ENDFORM. "sub_help_left

*&---------------------------------------------------------------------*
*&      Form  sub_help_right
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RIGHT      text
*----------------------------------------------------------------------*
FORM sub_help_right CHANGING right TYPE c.
  DATA: BEGIN OF inttab OCCURS 10,
          tabname TYPE tabname,
        END OF inttab,
        ret_tab    LIKE ddshretval OCCURS 0 WITH HEADER LINE,
        wa_tabname TYPE t_tabname.

  REFRESH inttab.
  LOOP AT it_tabname WHERE tabname NE ''.
    IF it_tabname-alias IS NOT INITIAL.
      wa_tabname = it_tabname-alias.
    ELSE.
      wa_tabname = it_tabname-tabname.
    ENDIF.
    APPEND wa_tabname TO inttab.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'TABNAME'
      window_title    = 'Select Table'
      value_org       = 'S'
      multiple_choice = ' '
    TABLES
      value_tab       = inttab
      return_tab      = ret_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc = 0.
    LOOP AT ret_tab.
      right =  ret_tab-fieldval.
    ENDLOOP.
  ENDIF.
ENDFORM. "sub_help_right

*&---------------------------------------------------------------------*
*&      Form  register_f4_join
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM register_f4_join .
  DATA lt_f4 TYPE lvc_t_f4 WITH HEADER LINE.

  lt_f4-fieldname  = 'LEFT'.
  lt_f4-register   = 'X'.
  lt_f4-getbefore  = 'X'.
  lt_f4-chngeafter = 'X'.
  lt_f4-internal   = 'X'.
  INSERT TABLE lt_f4.

  lt_f4-fieldname  = 'RIGHT'.
  lt_f4-register   = 'X'.
  lt_f4-getbefore  = 'X'.
  lt_f4-chngeafter = 'X'.
  lt_f4-internal   = 'X'.
  INSERT TABLE lt_f4.

  CALL METHOD alv_join->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4[].
ENDFORM. "register_f4_join

*&---------------------------------------------------------------------*
*&      Form  sub_help_left_jco
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LEFT       text
*----------------------------------------------------------------------*
FORM sub_help_left_jco CHANGING left TYPE c.

  DATA: BEGIN OF inttab OCCURS 10,
          fieldname TYPE fieldname,        " fieldname
          ddtext    TYPE as4text,          " description
        END OF inttab,

        BEGIN OF inttab2 OCCURS 10,
          tabname TYPE tabname,
        END OF inttab2,

        lv_tabname TYPE tabname,
        lv_alias   TYPE tabname,

        ret_tab    LIKE ddshretval OCCURS 0 WITH HEADER LINE,
        wa_tabname TYPE t_tabname.

  REFRESH inttab.
  REFRESH inttab2.

  LOOP AT it_tabname WHERE tabname NE ''.
    IF it_tabname-alias IS NOT INITIAL.
      wa_tabname = it_tabname-alias.
    ELSE.
      wa_tabname = it_tabname-tabname.
    ENDIF.
    APPEND wa_tabname TO inttab2.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'TABNAME'
      window_title    = 'Select Table'
      value_org       = 'S'
      multiple_choice = ' '
    TABLES
      value_tab       = inttab2
      return_tab      = ret_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc = 0.
    LOOP AT ret_tab.
      lv_alias =  ret_tab-fieldval.
    ENDLOOP.

    READ TABLE it_tabname WITH  KEY alias = lv_alias.
    IF sy-subrc = 0.
      lv_tabname = it_tabname-tabname.
    ELSE.
      lv_tabname = lv_alias.
      CLEAR lv_alias.
    ENDIF.

    SELECT dd03l~fieldname dd04t~ddtext
      INTO CORRESPONDING FIELDS OF TABLE inttab
      FROM dd03l JOIN dd04t ON dd03l~rollname = dd04t~rollname
      WHERE    dd03l~tabname    = lv_tabname AND
               dd04t~ddlanguage = sy-langu AND
               dd03l~rollname   <> '' .

    IF lv_alias IS NOT INITIAL.
      lv_tabname = lv_alias.
    ENDIF.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'FIELDNAME'
        window_title    = 'Select Field'
        value_org       = 'S'
        multiple_choice = ' '
      TABLES
        value_tab       = inttab
        return_tab      = ret_tab
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc = 0.
      LOOP AT ret_tab.
        CONCATENATE lv_tabname '~' ret_tab-fieldval INTO left.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM. "sub_help_left_jco

*&---------------------------------------------------------------------*
*&      Form  sub_help_right_jco
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RIGHT      text
*----------------------------------------------------------------------*
FORM sub_help_right_jco CHANGING right TYPE c.
  DATA: BEGIN OF inttab OCCURS 10,
          fieldname TYPE fieldname,        " fieldname
          ddtext    TYPE as4text,          " description
        END OF inttab,
        ret_tab    LIKE ddshretval OCCURS 0 WITH HEADER LINE,
        wa_tabname TYPE t_tabname,
        lv_alias   TYPE tabname,
        lv_tabname TYPE tabname.

  REFRESH inttab.

  READ TABLE it_join WITH KEY jjoin = lv_key_join lv_key_select = lv_key_select.

  IF sy-subrc EQ 0.

    lv_alias = it_join-right.

    READ TABLE it_tabname WITH  KEY alias = lv_alias.
    IF sy-subrc = 0.
      lv_tabname = it_tabname-tabname.
    ELSE.
      lv_tabname = lv_alias.
      CLEAR lv_alias.
    ENDIF.


    SELECT dd03l~fieldname dd04t~ddtext
      INTO CORRESPONDING FIELDS OF TABLE inttab
      FROM dd03l JOIN dd04t ON dd03l~rollname = dd04t~rollname
      WHERE    dd03l~tabname    = lv_tabname AND
               dd04t~ddlanguage = sy-langu AND
               dd03l~rollname   <> '' .

    IF lv_alias IS NOT INITIAL.
      lv_tabname = lv_alias.
    ENDIF.


    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'FIELDNAME'
        window_title    = 'Select Field'
        value_org       = 'S'
        multiple_choice = ' '
      TABLES
        value_tab       = inttab
        return_tab      = ret_tab
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc = 0.
      LOOP AT ret_tab.
        CONCATENATE lv_tabname '~' ret_tab-fieldval INTO right.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM. "sub_help_right_jco
*&---------------------------------------------------------------------*
*&      Form  register_f4_join_condition
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM register_f4_join_condition .
  DATA lt_f4 TYPE lvc_t_f4 WITH HEADER LINE.

  lt_f4-fieldname  = 'LEFT'.
  lt_f4-register   = 'X'.
  lt_f4-getbefore  = 'X'.
  lt_f4-chngeafter = 'X'.
  lt_f4-internal   = 'X'.
  INSERT TABLE lt_f4.

  lt_f4-fieldname  = 'RIGHT'.
  lt_f4-register   = 'X'.
  lt_f4-getbefore  = 'X'.
  lt_f4-chngeafter = 'X'.
  lt_f4-internal   = 'X'.
  INSERT TABLE lt_f4.

  CALL METHOD alv_join_condition->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4[].
ENDFORM. "register_f4_join

*&---------------------------------------------------------------------*
*&      Form  register_f4_where
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM register_f4_where .
  DATA lt_f4 TYPE lvc_t_f4 WITH HEADER LINE.

  lt_f4-fieldname  = 'OR1'.
  lt_f4-register   = 'X'.
  lt_f4-getbefore  = 'X'.
  lt_f4-chngeafter = 'X'.
  lt_f4-internal   = 'X'.
  INSERT TABLE lt_f4.
  lt_f4-fieldname  = 'OR2'.
  lt_f4-register   = 'X'.
  lt_f4-getbefore  = 'X'.
  lt_f4-chngeafter = 'X'.
  lt_f4-internal   = 'X'.
  INSERT TABLE lt_f4.
  lt_f4-fieldname  = 'OR3'.
  lt_f4-register   = 'X'.
  lt_f4-getbefore  = 'X'.
  lt_f4-chngeafter = 'X'.
  lt_f4-internal   = 'X'.
  INSERT TABLE lt_f4.
  lt_f4-fieldname  = 'OR4'.
  lt_f4-register   = 'X'.
  lt_f4-getbefore  = 'X'.
  lt_f4-chngeafter = 'X'.
  lt_f4-internal   = 'X'.
  INSERT TABLE lt_f4.


  CALL METHOD alv_where->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4[].
ENDFORM. "register_f4_join

*&---------------------------------------------------------------------*
*&      Form  sub_help_where
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->WHERE      text
*----------------------------------------------------------------------*
FORM sub_help_where CHANGING where.

  DATA: BEGIN OF inttab OCCURS 10,
          or1 TYPE btctext80,
        END OF inttab,
        ret_tab    LIKE ddshretval OCCURS 0 WITH HEADER LINE,
        wa_where   LIKE LINE OF inttab,
        wa_select  TYPE t_select,
        lv_str(80) TYPE c.

  REFRESH inttab.
  LOOP AT it_select INTO wa_select WHERE sselect NE 'ZMAIN' AND sselect NE ''.

    CONCATENATE 'in SUBQUERY' wa_select-sselect INTO lv_str SEPARATED BY space.
    wa_where-or1 = lv_str.
    APPEND wa_where TO inttab.

    CONCATENATE 'not in SUBQUERY' wa_select-sselect INTO lv_str SEPARATED BY space.
    wa_where-or1 = lv_str.
    APPEND wa_where TO inttab.

  ENDLOOP.

  wa_where-or1 = '= '.
  APPEND wa_where TO inttab.

  wa_where-or1 = '<> '.
  APPEND wa_where TO inttab.

  wa_where-or1 = '< '.
  APPEND wa_where TO inttab.

  wa_where-or1 = '> '.
  APPEND wa_where TO inttab.

  wa_where-or1 = '<= '.
  APPEND wa_where TO inttab.

  wa_where-or1 = '>= '.
  APPEND wa_where TO inttab.

  wa_where-or1 = 'like '''''.
  APPEND wa_where TO inttab.

  wa_where-or1 = 'not like '''''.
  APPEND wa_where TO inttab.

  wa_where-or1 = 'in (  ,   ,  )'.
  APPEND wa_where TO inttab.

  wa_where-or1 = 'not in (   ,   ,   )'.
  APPEND wa_where TO inttab.

  wa_where-or1 = 'is null'.
  APPEND wa_where TO inttab.

  wa_where-or1 = 'is not null'.
  APPEND wa_where TO inttab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'OR1'
      window_title    = 'Select CONDITION'
      value_org       = 'S'
      multiple_choice = ' '
    TABLES
      value_tab       = inttab
      return_tab      = ret_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc = 0.
    LOOP AT ret_tab.
      where =  ret_tab-fieldval.
    ENDLOOP.
  ENDIF.

ENDFORM. "sub_help_where

*&---------------------------------------------------------------------*
*&      Form  move_row_up
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM move_row_up.
  DATA : wa_where_1   TYPE t_where,
         wa_where_2   TYPE t_where,
         it_rows      TYPE lvc_t_row  WITH HEADER LINE,
         wa_row       TYPE lvc_s_row,
         lv_row_no    TYPE lvc_t_roid,
         lv_row_num   TYPE i,
         lv_index(10) TYPE n.

  CALL METHOD alv_where->get_selected_rows
    IMPORTING
      et_index_rows = it_rows[]
      et_row_no     = lv_row_no.

  DESCRIBE TABLE it_rows LINES   lv_row_num.
  IF lv_row_num EQ 1.
    LOOP AT it_rows.
      IF it_rows-index > 1.
        READ TABLE it_where INDEX it_rows-index INTO wa_where_1.
        lv_index = it_rows-index - 1.
        READ TABLE it_where INDEX lv_index INTO wa_where_2.

        MODIFY it_where FROM wa_where_2 INDEX it_rows-index.
        MODIFY it_where FROM wa_where_1 INDEX lv_index.
      ENDIF.
    ENDLOOP.

    PERFORM recalc_cwidth_opt USING alv_where.
    CALL METHOD alv_where->refresh_table_display.

    REFRESH it_rows.
    wa_row-index = lv_index.
    APPEND wa_row TO it_rows.


    CALL METHOD alv_where->set_selected_rows
      EXPORTING
        it_index_rows = it_rows[].

  ENDIF.
ENDFORM. "move_row_up

*&---------------------------------------------------------------------*
*&      Form  move_row_down
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM move_row_down.
  DATA : wa_where_1   TYPE t_where,
         wa_where_2   TYPE t_where,
         it_rows      TYPE lvc_t_row  WITH HEADER LINE,
         wa_row       TYPE lvc_s_row,
         lv_row_no    TYPE lvc_t_roid,
         lv_row_num   TYPE i,
         lv_index(10) TYPE n,
         lv_count     TYPE i.

  DESCRIBE TABLE it_where LINES lv_count.

  CALL METHOD alv_where->get_selected_rows
    IMPORTING
      et_index_rows = it_rows[]
      et_row_no     = lv_row_no.

  DESCRIBE TABLE it_rows LINES   lv_row_num.
  IF lv_row_num EQ 1.
    LOOP AT it_rows.
      IF it_rows-index < lv_count.
        READ TABLE it_where INDEX it_rows-index INTO wa_where_1.
        lv_index = it_rows-index + 1.
        READ TABLE it_where INDEX lv_index INTO wa_where_2.

        MODIFY it_where FROM wa_where_2 INDEX it_rows-index.
        MODIFY it_where FROM wa_where_1 INDEX lv_index.
      ENDIF.
    ENDLOOP.

    PERFORM recalc_cwidth_opt USING alv_where.
    CALL METHOD alv_where->refresh_table_display.

    REFRESH it_rows.
    wa_row-index = lv_index.
    APPEND wa_row TO it_rows.


    CALL METHOD alv_where->set_selected_rows
      EXPORTING
        it_index_rows = it_rows[].

  ENDIF.
ENDFORM. "move_row_down

*&---------------------------------------------------------------------*
*&      Form  show_code
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM show_code.
  DATA: it_tabname2        TYPE TABLE OF t_tabname WITH HEADER LINE,
        sselect            TYPE tabname,
        it_join_condition2 TYPE TABLE OF t_join_condition WITH HEADER LINE,
        it_where_2         TYPE TABLE OF t_where_2 WITH HEADER LINE,
        it_where_3         TYPE TABLE OF t_where_3 WITH HEADER LINE,
        it_where_t         TYPE TABLE OF t_where   WITH HEADER LINE,
        lv_str             TYPE string,
        str1               TYPE string,
        str2               TYPE string,
        lv_lines           TYPE i,
        lv_join            TYPE string,
        it_join_t          TYPE TABLE OF string,
        lv_flag            TYPE c,
        lv_flag_2          TYPE c,
        lv_flag_last       TYPE c,
        it_split           TYPE TABLE OF edpline,
        lv_alias           TYPE tabname,
        lv_tabname         TYPE tabname.


  alv_tabname->check_changed_data( ).
  alv_select->check_changed_data( ).
  alv_join->check_changed_data( ).
  alv_join_condition->check_changed_data( ).
  alv_where->check_changed_data( ).
*alv_output->check_changed_data( ).

  REFRESH: itext,
           it_tabname2,
           it_subquery,
           it_subquery[].

*/-------prepare to dynamic select
  REFRESH:  it_s_result ,
            it_s_from   ,
            it_s_where  ,
            it_s_group  ,
            it_s_having ,
            it_s_order  .
*/---------end--------------------

  DEFINE add_line.
    xtext = &1.
    append xtext to itext.
  END-OF-DEFINITION.

  DEFINE add_result.
    clear: it_split,
       it_split[].
    condense &1.
    split &1 at space into: table it_split.
    append lines of it_split to it_s_result.
    "append &1 to it_s_result.
  END-OF-DEFINITION.

  DEFINE add_from.
    clear: it_split,
       it_split[].
    condense &1.
    split &1 at space into: table it_split.
    append lines of it_split to it_s_from.
    "append &1 to it_s_from.
  END-OF-DEFINITION.

  DEFINE add_where.
    clear: it_split,
       it_split[].
    condense &1.
    split &1 at space into: table it_split.
    append lines of it_split to it_s_where.
    "append &1 to it_s_where.
  END-OF-DEFINITION.

  DEFINE add_group.
    clear: it_split,
       it_split[].
    condense &1.
    split &1 at space into: table it_split.
    append lines of it_split to it_s_group.
    "append &1 to it_s_group.
  END-OF-DEFINITION.

  DEFINE add_having .
    clear: it_split,
       it_split[].
    condense &1.
    split &1 at space into: table it_split.
    append lines of it_split to it_s_having.
    "append &1 to it_s_having .
  END-OF-DEFINITION.

  DEFINE add_order.
    clear: it_split,
       it_split[].
    condense &1.
    split &1 at space into: table it_split.
    append lines of it_split to it_s_order.
    "append &1 to it_s_order.
  END-OF-DEFINITION.

*program
  add_line 'program zaaqb_1 .'.

*tables
  add_line 'Tables:'.

  LOOP AT it_tabname WHERE  tabname NE ''.
    READ TABLE it_tabname2 WITH  KEY tabname = it_tabname-tabname TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      APPEND it_tabname-tabname TO it_tabname2.
    ENDIF.
  ENDLOOP.

  LOOP AT it_tabname2 WHERE  tabname NE ''.
    CONCATENATE '$     $' it_tabname2 ',' INTO xtext.
    AT LAST.
      TRANSLATE  xtext USING ',.'.
    ENDAT.
    TRANSLATE  xtext USING '$ '.
    add_line xtext .
  ENDLOOP.

  add_line  ''.

*types
  add_line 'Types:'.
  add_line  'begin of t_zaaqb,'.
  LOOP AT it_where WHERE lv_key_select = 'ZMAIN' AND output EQ 'X'.
    SPLIT it_where-expression AT '~' INTO: str1 str2.
    READ TABLE it_tabname WITH  KEY alias = str1 .

    IF sy-subrc = 0.
      CONCATENATE it_tabname-tabname '~' str2 INTO it_where-expression.
    ENDIF.

    IF it_where-alias IS NOT   INITIAL.
      IF it_where-aggregate NE  'COUNT DISTINCT' AND  it_where-aggregate NE  'COUNT'.
        CONCATENATE '$   $' it_where-alias 'like' it_where-expression ',' INTO lv_str SEPARATED BY space.
      ELSE.
        CONCATENATE '$   $' it_where-alias 'like' 'ADACACHE~DA_HIT'  ',' INTO lv_str SEPARATED BY space.
      ENDIF.

      TRANSLATE lv_str USING '$ ~-'.
      add_line lv_str.
    ELSE.
      SPLIT it_where-expression AT '~' INTO: str1 str2 .
      IF it_where-aggregate NE  'COUNT DISTINCT' AND  it_where-aggregate NE  'COUNT'.
        CONCATENATE '$   $' str2 'like' it_where-expression ',' INTO lv_str SEPARATED BY space.
      ELSE.
        CONCATENATE '$   $' str2 'like ' 'ADACACHE~DA_HIT' ',' INTO lv_str SEPARATED BY space.
      ENDIF.

      TRANSLATE lv_str USING '$ ~-'.
      add_line lv_str.
    ENDIF.
  ENDLOOP.
  add_line  'end   of t_zaaqb.'.
  add_line  ''.

*data
  add_line  'Data:'.
  add_line  '   wa_zaaqb TYPE t_zaaqb,'.
  add_line  '   it_zaaqb TYPE TABLE OF t_zaaqb    WITH HEADER LINE.'.
  add_line  ''.

*select
  add_line  'select'.

  LOOP AT it_where WHERE lv_key_select = 'ZMAIN' AND output EQ 'X'.

    lv_str = '$   $'.

    CASE it_where-aggregate.
      WHEN 'MAX'.
        CONCATENATE lv_str 'max(' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'MAX DISTINCT'.
        CONCATENATE lv_str 'max( DISTINCT' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'DISTINCT'.
        CONCATENATE lv_str 'DISTINCT' it_where-expression  INTO lv_str SEPARATED BY space.
      WHEN 'MIN'.
        CONCATENATE lv_str 'MIN(' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'MIN DISTINCT'.
        CONCATENATE lv_str 'MIN( DISTINCT' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'AVG'.
        CONCATENATE lv_str 'AVG(' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'AVG DISTINCT'.
        CONCATENATE lv_str 'AVG( DISTINCT' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'SUM'.
        CONCATENATE lv_str 'SUM(' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'SUM DISTINCT'.
        CONCATENATE lv_str 'SUM( DISTINCT' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'COUNT DISTINCT'.
        CONCATENATE lv_str 'COUNT( DISTINCT' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'COUNT'.
        CONCATENATE lv_str 'COUNT(' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN OTHERS.
        CONCATENATE lv_str it_where-expression INTO lv_str SEPARATED BY space.
    ENDCASE.

    IF it_where-alias IS NOT INITIAL.
      CONCATENATE lv_str 'as' it_where-alias INTO lv_str SEPARATED BY space.
    ENDIF.

    TRANSLATE lv_str USING'$ '.

    add_line lv_str.
    add_result lv_str.

  ENDLOOP.

*into

  add_line 'into corresponding fields of table it_zaaqb'  .

*from
  add_line 'from'.

  CLEAR lv_lines.
  LOOP AT it_join WHERE lv_key_select = 'ZMAIN'.
    ADD 1 TO lv_lines.
  ENDLOOP.

  IF lv_lines IS INITIAL.
    LOOP AT it_where WHERE expression NE '' AND lv_key_select = 'ZMAIN' AND output = 'X'.
      SPLIT it_where-expression AT '~' INTO: str1 str2 .
      lv_str = str1.
    ENDLOOP.

*//-----------table alias in join----------------------
    READ TABLE it_tabname WITH  KEY alias = lv_str.
    IF sy-subrc = 0.
      CONCATENATE it_tabname-tabname 'AS' it_tabname-alias INTO lv_str SEPARATED BY space.
    ENDIF.
*//----------------------------------------------------

    CONCATENATE '$   $' lv_str INTO lv_str .
    TRANSLATE lv_str USING '$ '.
    add_line lv_str.
    add_from lv_str.
  ELSE.
    lv_join = 'JOIN01'.
    READ TABLE it_join WITH  KEY jjoin = lv_join lv_key_select = 'ZMAIN'.

*//-----------table alias in join----------------------
    READ TABLE it_tabname WITH  KEY alias = it_join-left.
    IF sy-subrc = 0.
      CONCATENATE it_tabname-tabname 'AS' it_tabname-alias INTO str1 SEPARATED BY space.
    ELSE.
      str1 = it_join-left.
    ENDIF.

    READ TABLE it_tabname WITH  KEY alias = it_join-right.
    IF sy-subrc = 0.
      CONCATENATE it_tabname-tabname 'AS' it_tabname-alias INTO str2 SEPARATED BY space.
    ELSE.
      str2 = it_join-right.
    ENDIF.
*//---------------------------------------------------
    CONCATENATE str1  it_join-ttype str2 'on'  INTO lv_str SEPARATED BY space.
    add_line lv_str.
    add_from lv_str.

    REFRESH it_join_condition2.
    LOOP AT it_join_condition WHERE lv_key_select = 'ZMAIN' AND lv_key_join = lv_join.
      APPEND it_join_condition TO it_join_condition2.
    ENDLOOP.

    LOOP AT it_join_condition2 .
      lv_flag = 'X'.
      CONCATENATE '$$$$$$$$$$' it_join_condition2-left '=' it_join_condition2-right 'and' INTO lv_str SEPARATED BY space.
      AT LAST.
        CLEAR lv_flag.
      ENDAT.
      IF lv_flag IS INITIAL.
        CONCATENATE '$$$$$$$$$$' it_join_condition2-left '=' it_join_condition2-right  INTO lv_str SEPARATED BY space.
      ENDIF.
      TRANSLATE lv_str USING '$ '.
      add_line lv_str.
      add_from lv_str.
    ENDLOOP.

    READ TABLE it_join WITH  KEY lv_key_select = 'ZMAIN'  left = lv_join.


    WHILE sy-subrc = 0.
      READ TABLE it_join_t TRANSPORTING NO FIELDS WITH KEY table_line = lv_join.
      IF sy-subrc = 0.
        EXIT.
      ENDIF.
      APPEND lv_join TO it_join_t.

*//-----------table alias in join----------------------
      READ TABLE it_tabname WITH  KEY alias = it_join-right.
      IF sy-subrc = 0.
        CONCATENATE it_tabname-tabname 'AS' it_tabname-alias INTO str2 SEPARATED BY space.
      ELSE.
        str2 = it_join-right.
      ENDIF.
*//---------------------------------------------------

      CONCATENATE   it_join-ttype str2 'on'  INTO lv_str SEPARATED BY space.
      add_line lv_str.
      add_from lv_str.
      lv_join = it_join-jjoin.

      REFRESH it_join_condition2.
      LOOP AT it_join_condition WHERE lv_key_select = 'ZMAIN' AND lv_key_join = lv_join.
        APPEND it_join_condition TO it_join_condition2.
      ENDLOOP.

      LOOP AT it_join_condition2 .
        lv_flag = 'X'.
        CONCATENATE '$$$$$$$$$$' it_join_condition2-left '=' it_join_condition2-right 'and' INTO lv_str SEPARATED BY space.
        AT LAST.
          CLEAR lv_flag.
        ENDAT.
        IF lv_flag IS INITIAL.
          CONCATENATE '$$$$$$$$$$' it_join_condition2-left '=' it_join_condition2-right  INTO lv_str SEPARATED BY space.
        ENDIF.
        TRANSLATE lv_str USING '$ '.
        add_line lv_str.
        add_from lv_str.
      ENDLOOP.

      READ TABLE it_join WITH  KEY lv_key_select = 'ZMAIN'  left = lv_join.

    ENDWHILE.

  ENDIF.

*WHERE
  CLEAR: lv_lines,
        it_where_2,
        it_where_2[].
*-------------count condition
  LOOP AT it_where WHERE lv_key_select = 'ZMAIN' AND ( or1 IS NOT INITIAL OR or2 IS NOT INITIAL OR or3 IS NOT INITIAL OR or4 IS NOT INITIAL ) AND disable_criteria IS INITIAL AND (  criteriafor = '' OR  criteriafor = 'VALUES' ).
    MOVE-CORRESPONDING it_where TO it_where_2.
    APPEND  it_where_2.
    ADD 1 TO lv_lines.
  ENDLOOP.

  IF lv_lines IS NOT INITIAL.
    add_line 'Where'.
    DESCRIBE TABLE it_where_2 LINES lv_lines.
    IF lv_lines > 1.
      lv_flag = 'X'.
    ELSE.
      CLEAR lv_flag.
    ENDIF.

    LOOP AT it_where_2.
      CLEAR: it_where_3,
            it_where_3[].
*--------- accumulate condition in internal table
      it_where_3-or = it_where_2-or1.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      it_where_3-or = it_where_2-or2.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      it_where_3-or = it_where_2-or3.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      it_where_3-or = it_where_2-or4.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      DESCRIBE TABLE it_where_3 LINES lv_lines.
*--------count or condition
      IF lv_lines > 1.
        lv_flag_2 = 'X'.
      ELSE.
        CLEAR lv_flag_2.
      ENDIF.

      IF lv_flag_2 IS NOT INITIAL.
        lv_str = '( '.
      ELSE.
        lv_str = ''.
      ENDIF.
*-------------build 'or' string
      LOOP AT it_where_3.
        lv_flag_last = ''.
        AT LAST.
          lv_flag_last = 'X'.
        ENDAT.

        CONCATENATE lv_str it_where_2-expression   INTO lv_str SEPARATED BY space.

        "$$$$$$$$$$$$$$$$
        FIND  'SUBQUERY' IN it_where_3-or IGNORING CASE .

        IF sy-subrc = 0.
          SPLIT it_where_3-or AT 'SUBQUERY' INTO: str1 str2 .
          CONCATENATE lv_str str1 INTO lv_str SEPARATED BY space.
          CONDENSE str2.
          CONCATENATE '$   $' lv_str INTO lv_str SEPARATED BY space.
          TRANSLATE lv_str USING '$ '.
          add_line lv_str.
          add_where lv_str.
          lv_str  = ''.
          sselect = str2.
          PERFORM subquery USING sselect 'W'.
        ELSE.
          CONCATENATE lv_str it_where_3-or INTO lv_str SEPARATED BY space.

        ENDIF.

        REPLACE ' ='  WITH ' = '  INTO lv_str.
        REPLACE ' <>' WITH ' <> ' INTO lv_str.
        REPLACE ' <=' WITH ' <= ' INTO lv_str.
        REPLACE ' >=' WITH ' >= ' INTO lv_str.

        FIND  '<>' IN lv_str  .
        IF sy-subrc NE 0.
          FIND  '<=' IN lv_str  .
          IF sy-subrc NE 0.
            REPLACE ' <'  WITH ' < '  INTO lv_str.
          ENDIF.
        ENDIF.

        FIND  '>=' IN lv_str  .
        IF sy-subrc NE 0.
          REPLACE ' >'  WITH ' > '  INTO lv_str.
        ENDIF.

        str2 = lv_str.
        CONDENSE str2 NO-GAPS.
        str1 = str2.
        TRANSLATE str1 TO UPPER CASE .

        FIND  'NOTIN(''' IN str1.
        IF sy-subrc = 0 .
          REPLACE FIRST OCCURRENCE OF 'notin(' IN str2  WITH ' not in (' IGNORING CASE.
          REPLACE ALL OCCURRENCES OF ''',''' IN str2 WITH ''', ''' .
          lv_str = str2.
        ENDIF.

        FIND  'IN(''' IN str1.
        IF sy-subrc = 0 .
          REPLACE FIRST OCCURRENCE OF 'in(' IN str2  WITH ' in (' IGNORING CASE.
          REPLACE ALL OCCURRENCES OF ''',''' IN str2 WITH ''', ''' .
          lv_str = str2.
        ENDIF.


        IF lv_flag_last IS INITIAL.
          CONCATENATE lv_str 'or' INTO lv_str SEPARATED BY space.
        ENDIF.

      ENDLOOP.

      IF lv_flag_2 IS NOT INITIAL.
        CONCATENATE lv_str ')' INTO lv_str SEPARATED BY space.
      ENDIF.
*------- deside to use or not 'and' at last condition
      lv_flag_last = ''.

      AT LAST.
        lv_flag_last = 'X'.
      ENDAT.

      CONCATENATE '$   $' lv_str INTO lv_str SEPARATED BY space.

      IF lv_flag_last IS INITIAL.
        CONCATENATE lv_str 'and' INTO lv_str SEPARATED BY space.
      ENDIF.

      TRANSLATE lv_str USING '$ '.
      add_line lv_str.
      add_where lv_str.
    ENDLOOP.

  ENDIF.


*GROUP BY group
  CLEAR lv_flag.
  LOOP AT it_where WHERE lv_key_select = 'ZMAIN' AND output EQ 'X'.
    IF it_where-aggregate IS NOT INITIAL.
      lv_flag = 'X'.
    ENDIF.
  ENDLOOP.

  IF lv_flag IS NOT INITIAL.
    CLEAR lv_flag.
    LOOP AT it_where WHERE lv_key_select = 'ZMAIN' AND output EQ 'X'.
      IF it_where-aggregate IS  INITIAL.
        lv_flag = 'X'.
      ENDIF.
    ENDLOOP.

    IF lv_flag IS NOT INITIAL.
      add_line 'GROUP BY'.
      LOOP AT it_where WHERE lv_key_select = 'ZMAIN' AND output EQ 'X'.
        IF it_where-aggregate IS  INITIAL.
          CONCATENATE '$    $' it_where-expression INTO lv_str.
          TRANSLATE lv_str USING '$ '.
          add_line lv_str.
          add_group lv_str.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDIF.

*HAVING group_cond
  CLEAR: lv_lines,
        it_where_2,
        it_where_2[].
*-------------count condition
  LOOP AT it_where WHERE lv_key_select = 'ZMAIN' AND ( or1 IS NOT INITIAL OR or2 IS NOT INITIAL OR or3 IS NOT INITIAL OR or4 IS NOT INITIAL ) AND disable_criteria IS INITIAL AND   criteriafor = 'GROUPS' AND aggregate IS NOT INITIAL.
    MOVE-CORRESPONDING it_where TO it_where_2.
    APPEND  it_where_2.
    ADD 1 TO lv_lines.
  ENDLOOP.

  IF lv_lines IS NOT INITIAL.
    add_line 'HAVING'.
    DESCRIBE TABLE it_where_2 LINES lv_lines.
    IF lv_lines > 1.
      lv_flag = 'X'.
    ELSE.
      CLEAR lv_flag.
    ENDIF.

    LOOP AT it_where_2.
      CLEAR: it_where_3,
            it_where_3[].
*--------- accumulate condition in internal table
      it_where_3-or = it_where_2-or1.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      it_where_3-or = it_where_2-or2.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      it_where_3-or = it_where_2-or3.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      it_where_3-or = it_where_2-or4.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      DESCRIBE TABLE it_where_3 LINES lv_lines.
*--------count or condition
      IF lv_lines > 1.
        lv_flag_2 = 'X'.
      ELSE.
        CLEAR lv_flag_2.
      ENDIF.

      IF lv_flag_2 IS NOT INITIAL.
        lv_str = '( '.
      ELSE.
        lv_str = ''.
      ENDIF.
*-------------build 'or' string
      LOOP AT it_where_3.
        lv_flag_last = ''.
        AT LAST.
          lv_flag_last = 'X'.
        ENDAT.
*/------- was  --------------
*         CONCATENATE lv_str it_where_2-expression it_where_3-or  INTO lv_str SEPARATED BY space.
*/------  das ---------------
        CONCATENATE lv_str it_where_2-expression   INTO lv_str SEPARATED BY space.

        "$$$$$$$$$$$$$$$$
        FIND  'SUBQUERY' IN it_where_3-or IGNORING CASE .

        IF sy-subrc = 0.
          SPLIT it_where_3-or AT 'SUBQUERY' INTO: str1 str2 .
          CONCATENATE lv_str str1 INTO lv_str SEPARATED BY space.
          CONDENSE str2.
          CONCATENATE '$   $' lv_str INTO lv_str SEPARATED BY space.
          TRANSLATE lv_str USING '$ '.
          add_line lv_str.
          add_having  lv_str.
          lv_str  = ''.
          sselect = str2.
          PERFORM subquery USING sselect 'H'.
        ELSE.
          CONCATENATE lv_str it_where_3-or INTO lv_str SEPARATED BY space.

        ENDIF.
*/------ end ----------------

        REPLACE ' ='  WITH ' = '  INTO lv_str.
        REPLACE ' <>' WITH ' <> ' INTO lv_str.
        REPLACE ' <'  WITH ' < '  INTO lv_str.
        REPLACE ' >'  WITH ' > '  INTO lv_str.
        REPLACE ' <=' WITH ' <= ' INTO lv_str.
        REPLACE ' >=' WITH ' >= ' INTO lv_str.

        FIND  '<>' IN lv_str  .
        IF sy-subrc NE 0.
          FIND  '<=' IN lv_str  .
          IF sy-subrc NE 0.
            REPLACE ' <'  WITH ' < '  INTO lv_str.
          ENDIF.
        ENDIF.

        FIND  '>=' IN lv_str  .
        IF sy-subrc NE 0.
          REPLACE ' >'  WITH ' > '  INTO lv_str.
        ENDIF.


        IF lv_flag_last IS INITIAL.
          CONCATENATE lv_str 'or' INTO lv_str SEPARATED BY space.
        ENDIF.

      ENDLOOP.

      IF lv_flag_2 IS NOT INITIAL.
        CONCATENATE lv_str ')' INTO lv_str SEPARATED BY space.
      ENDIF.
*------- deside to use or not 'and' at last condition
      lv_flag_last = ''.

      AT LAST.
        lv_flag_last = 'X'.
      ENDAT.

      CONCATENATE '$   $' lv_str INTO lv_str SEPARATED BY space.

      IF lv_flag_last IS INITIAL.
        CONCATENATE lv_str 'and' INTO lv_str SEPARATED BY space.
      ENDIF.

      TRANSLATE lv_str USING '$ '.
      add_line lv_str.
      add_having  lv_str.
    ENDLOOP.

  ENDIF.

*ORDER BY sort_key
  CLEAR lv_lines.
  LOOP AT it_where WHERE  lv_key_select = 'ZMAIN' AND  output IS NOT INITIAL AND sorttype IS NOT INITIAL.
    ADD 1 TO lv_lines.
  ENDLOOP.

  CLEAR it_where_t[].
  APPEND LINES OF it_where TO it_where_t.

  IF lv_lines IS NOT INITIAL.
    add_line 'ORDER BY'.
    SORT it_where_t BY sortorder.

    LOOP AT it_where_t WHERE  lv_key_select = 'ZMAIN' AND  output IS NOT INITIAL AND sorttype IS NOT INITIAL.
      IF it_where_t-alias IS NOT INITIAL.
        CONCATENATE '$   $' it_where_t-alias it_where_t-sorttype INTO lv_str SEPARATED BY space.
      ELSE.
        CONCATENATE '$   $' it_where_t-expression it_where_t-sorttype INTO lv_str SEPARATED BY space.
      ENDIF.

      TRANSLATE lv_str USING '$ '.
      add_line lv_str.
      add_order lv_str.

    ENDLOOP.
  ENDIF.

  add_line '.'.
  add_line ''.
  add_line 'break-point.'.


  CALL METHOD text_editor_top->set_text_as_r3table
    EXPORTING
      table  = itext
    EXCEPTIONS
      OTHERS = 1.

  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 4
      height = '0'.

  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 3
      height = '40'.

ENDFORM. "show_code

*&---------------------------------------------------------------------*
*&      Form  subquery
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->SSELECT    text
*----------------------------------------------------------------------*
FORM subquery USING sselect TYPE tabname switch TYPE c.
  DATA: lv_str             TYPE string,
        lv_d_str           TYPE string,
        str1               TYPE string,
        str2               TYPE string,
        lv_lines           TYPE i,
        lv_join            TYPE string,
        it_join_condition2 TYPE TABLE OF t_join_condition WITH HEADER LINE,
        it_join_t          TYPE TABLE OF string,
        it_where_2         TYPE TABLE OF t_where_2 WITH HEADER LINE,
        it_where_3         TYPE TABLE OF t_where_3 WITH HEADER LINE,
        lv_flag            TYPE c,
        lv_flag_2          TYPE c,
        lv_flag_last       TYPE c,
        it_sub             TYPE TABLE OF string.

  DEFINE add_line.
    concatenate &1 &2 into xtext.
    translate xtext using '$ '.
    append xtext to itext.
  END-OF-DEFINITION.

  DEFINE add_line_2.
    clear: it_sub,
   it_sub[].
    lv_d_str = &1.
    translate lv_d_str using '$ '.
    condense lv_d_str.

    split lv_d_str at space into: table it_sub.

    case switch.
      when 'W'.
        append lines of it_sub to it_s_where.
      when 'H'.
        append lines of it_sub to it_s_having.
    endcase.

  END-OF-DEFINITION.


  CONCATENATE lv_str_tab '$   $' INTO lv_str_tab.
  READ TABLE it_subquery WITH  KEY  sselect = sselect.
  IF sy-subrc = 0.
    EXIT.
  ELSE.
    APPEND sselect TO it_subquery.
  ENDIF.

*( SELECT      <result>
  add_line lv_str_tab '( select '.
  add_line_2 '( select '.

  LOOP AT it_where WHERE lv_key_select = sselect AND output EQ 'X'.

    lv_str = '$   $'.

    CASE it_where-aggregate.
      WHEN 'MAX'.
        CONCATENATE lv_str 'max(' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'MAX DISTINCT'.
        CONCATENATE lv_str 'max( DISTINCT' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'MIN'.
        CONCATENATE lv_str 'MIN(' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'MIN DISTINCT'.
        CONCATENATE lv_str 'MIN( DISTINCT' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'AVG'.
        CONCATENATE lv_str 'AVG(' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'AVG DISTINCT'.
        CONCATENATE lv_str 'AVG( DISTINCT' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'SUM'.
        CONCATENATE lv_str 'SUM(' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'SUM DISTINCT'.
        CONCATENATE lv_str 'SUM( DISTINCT' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN 'COUNT'.
        CONCATENATE lv_str 'COUNT(' it_where-expression ')' INTO lv_str SEPARATED BY space.
      WHEN OTHERS.
        CONCATENATE lv_str it_where-expression INTO lv_str SEPARATED BY space.
    ENDCASE.

    IF it_where-alias IS NOT INITIAL.
      CONCATENATE lv_str 'as' it_where-alias INTO lv_str SEPARATED BY space.
    ENDIF.

    add_line lv_str_tab lv_str.
    add_line_2 lv_str.

  ENDLOOP.

*    FROM      <source>
  add_line lv_str_tab 'from'.
  add_line_2 'from'.
  CLEAR lv_lines.
  LOOP AT it_join WHERE lv_key_select = sselect.
    ADD 1 TO lv_lines.
  ENDLOOP.

  IF lv_lines IS INITIAL.
    LOOP AT it_where WHERE expression NE '' AND lv_key_select = sselect AND output = 'X'.
      SPLIT it_where-expression AT '~' INTO: str1 str2 .
      lv_str = str1.
    ENDLOOP.
*//-----------table alias in join----------------------
    READ TABLE it_tabname WITH  KEY alias = lv_str.
    IF sy-subrc = 0.
      CONCATENATE it_tabname-tabname 'AS' it_tabname-alias INTO lv_str SEPARATED BY space.
    ENDIF.
*//----------------------------------------------------

    CONCATENATE '$   $' lv_str INTO lv_str .
    add_line  lv_str_tab lv_str.
    add_line_2 lv_str.
  ELSE.
    lv_join = 'JOIN01'.
    READ TABLE it_join WITH  KEY jjoin = lv_join lv_key_select = sselect.
*//-----------table alias in join----------------------
    READ TABLE it_tabname WITH  KEY alias = it_join-left.
    IF sy-subrc = 0.
      CONCATENATE it_tabname-tabname 'AS' it_tabname-alias INTO str1 SEPARATED BY space.
    ELSE.
      str1 = it_join-left.
    ENDIF.

    READ TABLE it_tabname WITH  KEY alias = it_join-right.
    IF sy-subrc = 0.
      CONCATENATE it_tabname-tabname 'AS' it_tabname-alias INTO str2 SEPARATED BY space.
    ELSE.
      str2 = it_join-right.
    ENDIF.
*//---------------------------------------------------

*    CONCATENATE it_join-left  it_join-ttype it_join-right 'on'  INTO lv_str SEPARATED BY space.
    CONCATENATE str1  it_join-ttype str2 'on'  INTO lv_str SEPARATED BY space.
*//---------------------------------------------------
    add_line lv_str_tab lv_str.
    add_line_2 lv_str.

    REFRESH it_join_condition2.
    LOOP AT it_join_condition WHERE lv_key_select = sselect AND lv_key_join = lv_join.
      APPEND it_join_condition TO it_join_condition2.
    ENDLOOP.

    LOOP AT it_join_condition2 .
      lv_flag = 'X'.
      CONCATENATE '$$$$$$$$$$' it_join_condition2-left '=' it_join_condition2-right 'and' INTO lv_str SEPARATED BY space.
      AT LAST.
        CLEAR lv_flag.
      ENDAT.
      IF lv_flag IS INITIAL.
        CONCATENATE '$$$$$$$$$$' it_join_condition2-left '=' it_join_condition2-right  INTO lv_str SEPARATED BY space.
      ENDIF.
      add_line lv_str_tab lv_str.
      add_line_2 lv_str.
    ENDLOOP.

    READ TABLE it_join WITH  KEY lv_key_select = sselect  left = lv_join.


    WHILE sy-subrc = 0.
      READ TABLE it_join_t TRANSPORTING NO FIELDS WITH KEY table_line = lv_join.
      IF sy-subrc = 0.
        EXIT.
      ENDIF.
      APPEND lv_join TO it_join_t.

*//-----------table alias in join----------------------
      READ TABLE it_tabname WITH  KEY alias = it_join-right.
      IF sy-subrc = 0.
        CONCATENATE it_tabname-tabname 'AS' it_tabname-alias INTO str2 SEPARATED BY space.
      ELSE.
        str2 = it_join-right.
      ENDIF.
*//---------------------------------------------------

*      CONCATENATE   it_join-ttype it_join-right 'on'  INTO lv_str SEPARATED BY space.
      CONCATENATE   it_join-ttype str2 'on'  INTO lv_str SEPARATED BY space.
*//---------------------------------------------------

      add_line lv_str_tab lv_str.
      add_line_2 lv_str.
      lv_join = it_join-jjoin.

      REFRESH it_join_condition2.
      LOOP AT it_join_condition WHERE lv_key_select = sselect AND lv_key_join = lv_join.
        APPEND it_join_condition TO it_join_condition2.
      ENDLOOP.

      LOOP AT it_join_condition2 .
        lv_flag = 'X'.
        CONCATENATE '$$$$$$$$$$' it_join_condition2-left '=' it_join_condition2-right 'and' INTO lv_str SEPARATED BY space.
        AT LAST.
          CLEAR lv_flag.
        ENDAT.
        IF lv_flag IS INITIAL.
          CONCATENATE '$$$$$$$$$$' it_join_condition2-left '=' it_join_condition2-right  INTO lv_str SEPARATED BY space.
        ENDIF.
        add_line lv_str_tab lv_str.
        add_line_2 lv_str.
      ENDLOOP.

      READ TABLE it_join WITH  KEY lv_key_select = sselect  left = lv_join.

    ENDWHILE.

  ENDIF.

*    [WHERE    <condition>]
  CLEAR: lv_lines,
         it_where_2,
         it_where_2[].
*-------------count condition
  LOOP AT it_where WHERE lv_key_select = sselect AND ( or1 IS NOT INITIAL OR or2 IS NOT INITIAL OR or3 IS NOT INITIAL OR or4 IS NOT INITIAL ) AND disable_criteria IS INITIAL AND (  criteriafor = '' OR  criteriafor = 'VALUES' ).
    MOVE-CORRESPONDING it_where TO it_where_2.
    APPEND  it_where_2.
    ADD 1 TO lv_lines.
  ENDLOOP.

  IF lv_lines IS NOT INITIAL.
    add_line lv_str_tab 'Where'.
    add_line_2 'Where'.
    DESCRIBE TABLE it_where_2 LINES lv_lines.
    IF lv_lines > 1.
      lv_flag = 'X'.
    ELSE.
      CLEAR lv_flag.
    ENDIF.

    LOOP AT it_where_2.
      CLEAR: it_where_3,
            it_where_3[].
*--------- accumulate condition in internal table
      it_where_3-or = it_where_2-or1.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      it_where_3-or = it_where_2-or2.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      it_where_3-or = it_where_2-or3.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      it_where_3-or = it_where_2-or4.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      DESCRIBE TABLE it_where_3 LINES lv_lines.
*--------count or condition
      IF lv_lines > 1.
        lv_flag_2 = 'X'.
      ELSE.
        CLEAR lv_flag_2.
      ENDIF.

      IF lv_flag_2 IS NOT INITIAL.
        lv_str = '( '.
      ELSE.
        lv_str = ''.
      ENDIF.
*-------------build 'or' string
      LOOP AT it_where_3.
        lv_flag_last = ''.
        AT LAST.
          lv_flag_last = 'X'.
        ENDAT.
*/---------was--------------
*        CONCATENATE lv_str it_where_2-expression it_where_3-or  INTO lv_str SEPARATED BY space.
*/---------das -------------
        CONCATENATE lv_str it_where_2-expression   INTO lv_str SEPARATED BY space.

        "$$$$$$$$$$$$$$$$
        FIND  'SUBQUERY' IN it_where_3-or IGNORING CASE .

        IF sy-subrc = 0.
          SPLIT it_where_3-or AT 'SUBQUERY' INTO: str1 str2 .
          CONCATENATE lv_str str1 INTO lv_str SEPARATED BY space.
          CONDENSE str2.
          CONCATENATE '$   $' lv_str INTO lv_str SEPARATED BY space.
          TRANSLATE lv_str USING '$ '.
          add_line lv_str_tab lv_str.
          add_line_2 lv_str.
          lv_str  = ''.
          sselect = str2.
          PERFORM subquery USING sselect switch.
        ELSE.
          CONCATENATE lv_str it_where_3-or INTO lv_str SEPARATED BY space.

        ENDIF.
*/---------end--------------

        IF lv_flag_last IS INITIAL.
          CONCATENATE lv_str 'or' INTO lv_str SEPARATED BY space.
        ENDIF.

      ENDLOOP.

      IF lv_flag_2 IS NOT INITIAL.
        CONCATENATE lv_str ')' INTO lv_str SEPARATED BY space.
      ENDIF.
*------- deside to use or not 'and' at last condition
      lv_flag_last = ''.

      AT LAST.
        lv_flag_last = 'X'.
      ENDAT.

      CONCATENATE '$   $' lv_str INTO lv_str SEPARATED BY space.

      IF lv_flag_last IS INITIAL.
        CONCATENATE lv_str 'and' INTO lv_str SEPARATED BY space.
      ENDIF.

      add_line lv_str_tab lv_str.
      add_line_2 lv_str.
    ENDLOOP.

  ENDIF.

*    [GROUP BY <fields>]
  CLEAR lv_flag.
  LOOP AT it_where WHERE lv_key_select = sselect AND output EQ 'X'.
    IF it_where-aggregate IS NOT INITIAL.
      lv_flag = 'X'.
    ENDIF.
  ENDLOOP.

  IF lv_flag IS NOT INITIAL.
    CLEAR lv_flag.
    LOOP AT it_where WHERE lv_key_select = sselect AND output EQ 'X'.
      IF it_where-aggregate IS  INITIAL.
        lv_flag = 'X'.
      ENDIF.
    ENDLOOP.

    IF lv_flag IS NOT INITIAL.
      add_line lv_str_tab 'GROUP BY'.
      add_line_2 'GROUP BY'.
      LOOP AT it_where WHERE lv_key_select = sselect AND output EQ 'X'.
        IF it_where-aggregate IS  INITIAL.
          CONCATENATE '$    $' it_where-expression INTO lv_str.
          add_line lv_str_tab lv_str.
          add_line_2 lv_str.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDIF.

*    [HAVING   <cond>]
  CLEAR: lv_lines,
         it_where_2,
         it_where_2[].
*-------------count condition
  LOOP AT it_where WHERE lv_key_select = sselect AND ( or1 IS NOT INITIAL OR or2 IS NOT INITIAL OR or3 IS NOT INITIAL OR or4 IS NOT INITIAL ) AND disable_criteria IS INITIAL AND   criteriafor = 'GROUPS' AND aggregate IS NOT INITIAL.
    MOVE-CORRESPONDING it_where TO it_where_2.
    APPEND  it_where_2.
    ADD 1 TO lv_lines.
  ENDLOOP.

  IF lv_lines IS NOT INITIAL.
    add_line lv_str_tab 'HAVING'.
    add_line_2 'HAVING'.
    DESCRIBE TABLE it_where_2 LINES lv_lines.
    IF lv_lines > 1.
      lv_flag = 'X'.
    ELSE.
      CLEAR lv_flag.
    ENDIF.

    LOOP AT it_where_2.
      CLEAR: it_where_3,
            it_where_3[].
*--------- accumulate condition in internal table
      it_where_3-or = it_where_2-or1.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      it_where_3-or = it_where_2-or2.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      it_where_3-or = it_where_2-or3.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      it_where_3-or = it_where_2-or4.
      IF it_where_3-or IS NOT INITIAL .
        APPEND it_where_3.
      ENDIF.

      DESCRIBE TABLE it_where_3 LINES lv_lines.
*--------count or condition
      IF lv_lines > 1.
        lv_flag_2 = 'X'.
      ELSE.
        CLEAR lv_flag_2.
      ENDIF.

      IF lv_flag_2 IS NOT INITIAL.
        lv_str = '( '.
      ELSE.
        lv_str = ''.
      ENDIF.
*-------------build 'or' string
      LOOP AT it_where_3.
        lv_flag_last = ''.
        AT LAST.
          lv_flag_last = 'X'.
        ENDAT.
*/-----------------was-------------
*        CONCATENATE lv_str it_where_2-expression it_where_3-or  INTO lv_str SEPARATED BY space.
*/----------------das---------------
        CONCATENATE lv_str it_where_2-expression   INTO lv_str SEPARATED BY space.

        "$$$$$$$$$$$$$$$$
        FIND  'SUBQUERY' IN it_where_3-or IGNORING CASE .

        IF sy-subrc = 0.
          SPLIT it_where_3-or AT 'SUBQUERY' INTO: str1 str2 .
          CONCATENATE lv_str str1 INTO lv_str SEPARATED BY space.
          CONDENSE str2.
          CONCATENATE '$   $' lv_str INTO lv_str SEPARATED BY space.
          TRANSLATE lv_str USING '$ '.
          add_line lv_str_tab lv_str.
          add_line_2 lv_str.
          lv_str  = ''.
          sselect = str2.
          PERFORM subquery USING sselect switch.
        ELSE.
          CONCATENATE lv_str it_where_3-or INTO lv_str SEPARATED BY space.

        ENDIF.
*/----------------end---------------------------------

        IF lv_flag_last IS INITIAL.
          CONCATENATE lv_str 'or' INTO lv_str SEPARATED BY space.
        ENDIF.

      ENDLOOP.

      IF lv_flag_2 IS NOT INITIAL.
        CONCATENATE lv_str ')' INTO lv_str SEPARATED BY space.
      ENDIF.
*------- deside to use or not 'and' at last condition
      lv_flag_last = ''.

      AT LAST.
        lv_flag_last = 'X'.
      ENDAT.

      CONCATENATE '$   $' lv_str INTO lv_str SEPARATED BY space.

      IF lv_flag_last IS INITIAL.
        CONCATENATE lv_str 'and' INTO lv_str SEPARATED BY space.
      ENDIF.

      add_line lv_str_tab lv_str.
      add_line_2 lv_str.
    ENDLOOP.

  ENDIF.

* )
  add_line lv_str_tab ')'.
  add_line_2 ')'.



  DELETE  it_subquery WHERE sselect = sselect.
  SHIFT lv_str_tab LEFT BY 5 PLACES.
ENDFORM. "subquery

*&---------------------------------------------------------------------*
*&      Form  IMPORT_select
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM export_select_bd.
  DATA: p_fname(120) TYPE c.

  CALL FUNCTION 'TMP_GUI_BROWSE_FOR_FOLDER'
    EXPORTING
      window_title    = 'Select the Appropriate Folder'
    IMPORTING
      selected_folder = p_fname    "initial_folder = p_folder
    EXCEPTIONS
      cntl_error      = 1
      OTHERS          = 2.

  IF p_fname IS INITIAL.
    EXIT.
  ENDIF.

  PERFORM export_table USING 'ZAAQB_H' p_fname.
  PERFORM export_table USING 'ZAAQB_S' p_fname.

ENDFORM. "export_select_bd

*&---------------------------------------------------------------------*
*&      Form  export_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TABLE    text
*      -->PATH       text
*----------------------------------------------------------------------*
FORM export_table USING p_table TYPE tabname path TYPE c.
  DATA: filename    TYPE string,
        struct_type TYPE REF TO cl_abap_structdescr,
        itab_type   TYPE REF TO cl_abap_tabledescr,
        dref        TYPE REF TO data,
        comp_tab    TYPE abap_compdescr_tab,
        comp_line   TYPE abap_compdescr,
        lv_count    TYPE i,
        path1(120)  TYPE c,

        xfc         TYPE lvc_s_fcat,
        ifc         TYPE lvc_t_fcat.

  CLEAR: comp_tab[],
  struct_type.
  CONCATENATE path '\' p_table '.dat' INTO path1.

  FIELD-SYMBOLS : <it_outtab> TYPE ANY TABLE,
                  <wa_outtab> TYPE any,
                  <l_fld>     TYPE any.

  SELECT COUNT( * )
  FROM dd03l
  INTO lv_count
  WHERE tabname = p_table.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  PERFORM get_struct TABLES  comp_tab[]  USING p_table  struct_type  .

  LOOP AT comp_tab INTO comp_line.
    CLEAR xfc.
    xfc-fieldname = comp_line-name .
    xfc-datatype = comp_line-type_kind.
    xfc-inttype = comp_line-type_kind.
    xfc-intlen = comp_line-length.
    xfc-decimals = comp_line-decimals.
    APPEND xfc TO ifc.
  ENDLOOP.


  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog = ifc
    IMPORTING
      ep_table        = dref.
  ASSIGN dref->* TO <it_outtab>.

  CREATE DATA dref LIKE LINE OF <it_outtab>.
  ASSIGN dref->* TO <wa_outtab>.

**generate structure & internal table types
*  struct_type = cl_abap_structdescr=>create( comp_tab ).
*  itab_type   = cl_abap_tabledescr=>create( struct_type ).
*
**create structure & internaltable
*
*  CREATE DATA dref TYPE HANDLE itab_type.
*  ASSIGN dref->* TO <it_outtab>.
*  CREATE DATA dref TYPE HANDLE struct_type.
*  ASSIGN dref->* TO <wa_outtab>.

  SELECT * FROM (p_table) INTO TABLE <it_outtab>.
  PERFORM wrap_download USING <it_outtab> path1.

ENDFORM. "export_table


*&---------------------------------------------------------------------*
*&      Form  wrap_download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IT_TABLE   text
*      -->PATH       text
*----------------------------------------------------------------------*
FORM wrap_download USING it_table TYPE STANDARD TABLE path TYPE c.
  DATA: filename TYPE  string.
  filename = path.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*     BIN_FILESIZE            =
      filename                = filename
*     FILETYPE                = 'ASC'
*     APPEND                  = ' '
      write_field_separator   = 'X'
*     HEADER                  = '00'
      trunc_trailing_blanks   = 'X'
*     WRITE_LF                = 'X'
*     COL_SELECT              = ' '
*     COL_SELECT_MASK         = ' '
* IMPORTING
*     FILELENGTH              =
    TABLES
      data_tab                = it_table
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
ENDFORM. "wrap_download

*&---------------------------------------------------------------------*
*&      Form  import_select_bd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM import_select_bd.
  DATA: p_fname(120) TYPE c,
        d_ans        TYPE c.

  CALL FUNCTION 'TMP_GUI_BROWSE_FOR_FOLDER'
    EXPORTING
      window_title    = 'Select the Appropriate Folder'
    IMPORTING
      selected_folder = p_fname    "initial_folder = p_folder
    EXCEPTIONS
      cntl_error      = 1
      OTHERS          = 2.

  IF p_fname IS INITIAL.
    EXIT.
  ENDIF.



  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption = 'N'
      textline1     = 'All Query in DataBase will be overwritten.'
      textline2     = 'Are You Sure?'
      titel         = 'Rewrite all Query?'
      start_column  = 25
      start_row     = 6
*     CANCEL_DISPLAY =
    IMPORTING
      answer        = d_ans
    EXCEPTIONS
      OTHERS        = 1.

  IF d_ans <> 'J'.
    EXIT.
  ENDIF.

  PERFORM import_table USING 'ZAAQB_H' p_fname.
  PERFORM import_table USING 'ZAAQB_S' p_fname.

ENDFORM. "import_select_bd

*&---------------------------------------------------------------------*
*&      Form  import_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TABLE    text
*      -->PATH       text
*----------------------------------------------------------------------*
FORM import_table USING p_table TYPE tabname path TYPE c.
  DATA: filename    TYPE string,
        struct_type TYPE REF TO cl_abap_structdescr,
        itab_type   TYPE REF TO cl_abap_tabledescr,
        dref        TYPE REF TO data,
        comp_tab    TYPE abap_compdescr_tab,
        comp_line   TYPE abap_compdescr,
        lv_count    TYPE i,
        path1(120)  TYPE c,

        xfc         TYPE lvc_s_fcat,
        ifc         TYPE lvc_t_fcat.

  CLEAR: comp_tab[],
  struct_type.
  CONCATENATE path '\' p_table '.dat' INTO path1.

  FIELD-SYMBOLS : <it_outtab> TYPE ANY TABLE,
                  <wa_outtab> TYPE any,
                  <l_fld>     TYPE any.

  SELECT COUNT( * )
  FROM dd03l
  INTO lv_count
  WHERE tabname = p_table.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

*  perform get_struct tables  comp_tab[]  using p_table  struct_type  .
*
*  loop at comp_tab into comp_line.
*    clear xfc.
*    xfc-fieldname = comp_line-name .
*    xfc-datatype = comp_line-type_kind.
*    xfc-inttype = comp_line-type_kind.
*    xfc-intlen = comp_line-length.
*    xfc-decimals = comp_line-decimals.
*    append xfc to ifc.
*  endloop.
*
*
*  call method cl_alv_table_create=>create_dynamic_table
*    EXPORTING
*      it_fieldcatalog = ifc
*    IMPORTING
*      ep_table        = dref.
*  assign dref->* to <it_outtab>.

  CREATE DATA dref TYPE TABLE OF (p_table).
  ASSIGN dref->* TO <it_outtab>.

*  create data dref like line of <it_outtab>.
*  assign dref->* to <wa_outtab>.



  DELETE FROM (p_table).
  PERFORM wrap_upload CHANGING <it_outtab> path1.
  MODIFY   (p_table) FROM TABLE <it_outtab>.
*  loop at <it_outtab> into <wa_outtab>.
*    modify   (p_table) from <wa_outtab>.
*  endloop.

ENDFORM. "import_table

*&---------------------------------------------------------------------*
*&      Form  wrap_upload
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IT_TABLE   text
*      -->PATH       text
*----------------------------------------------------------------------*
FORM wrap_upload CHANGING it_table TYPE STANDARD TABLE path TYPE c.
  DATA: filename TYPE  string.
  filename = path.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename            = filename
*     FILETYPE            = 'ASC'
      has_field_separator = 'X'
*     HEADER_LENGTH       = 0
*     READ_BY_LINE        = 'X'
*     DAT_MODE            = ' '
*     CODEPAGE            = ' '
*     IGNORE_CERR         = ABAP_TRUE
*     REPLACEMENT         = '#'
*     CHECK_BOM           = ' '
*     VIRUS_SCAN_PROFILE  =
*     NO_AUTH_CHECK       = ' '
* IMPORTING
*     FILELENGTH          =
*     HEADER              =
    TABLES
      data_tab            = it_table
* EXCEPTIONS
*     FILE_OPEN_ERROR     = 1
*     FILE_READ_ERROR     = 2
*     NO_BATCH            = 3
*     GUI_REFUSE_FILETRANSFER       = 4
*     INVALID_TYPE        = 5
*     NO_AUTHORITY        = 6
*     UNKNOWN_ERROR       = 7
*     BAD_DATA_FORMAT     = 8
*     HEADER_NOT_ALLOWED  = 9
*     SEPARATOR_NOT_ALLOWED         = 10
*     HEADER_TOO_LONG     = 11
*     UNKNOWN_DP_ERROR    = 12
*     ACCESS_DENIED       = 13
*     DP_OUT_OF_MEMORY    = 14
*     DISK_FULL           = 15
*     DP_TIMEOUT          = 16
*     OTHERS              = 17
    .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM. "wrap_upload



*&---------------------------------------------------------------------*
*&      Form  import_select
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM import_select.
  DATA: _it_file_table    TYPE TABLE OF file_table,
        _rc               TYPE i,
        lv_fname          TYPE  string,
        it_import         TYPE TABLE OF string WITH HEADER LINE,
        lv_case           TYPE string,
        wa_tabname        TYPE   t_tabname,
        wa_select         TYPE   t_select,
        wa_join           TYPE   t_join,
        wa_join_condition TYPE   t_join_condition,
        wa_where          TYPE   t_where,
        ls_style          TYPE lvc_s_styl,
        lv_sortorder(10)  TYPE n.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = 'File'
      default_extension = '*.txt'
      file_filter       = 'Text file (*.txt)|*.txt|File with delimiter ";" (*.csv)|*.csv|Excel (*.xls)|*.xls|All (*.*)|*.*'
    CHANGING
      file_table        = _it_file_table      "initial_directory = 'C:\'
      rc                = _rc.

  IF sy-subrc <> 0.
    EXIT.
  ELSE.
    READ TABLE _it_file_table INTO lv_fname INDEX 1.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  ENDIF.

  CLEAR: it_tabname[]        ,
         it_select[]         ,
         it_join[]           ,
         it_join_condition[] ,
         it_where[]          .


  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_fname
    TABLES
      data_tab                = it_import
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT it_import.
    IF it_import = ''.
      CONTINUE.
    ENDIF.

    CASE it_import.
      WHEN '*it_tabname'.
        lv_case = 'it_tabname'.
        CONTINUE.
      WHEN '*it_select'.
        lv_case = 'it_select'.
        CONTINUE.
      WHEN '*it_join'.
        lv_case = 'it_join'.
        CONTINUE.
      WHEN '*it_join_condition'.
        lv_case = 'it_join_condition'.
        CONTINUE.
      WHEN '*it_where'.
        lv_case = 'it_where'.
        CONTINUE.
    ENDCASE.

    CASE lv_case.
      WHEN 'it_tabname'.
        SPLIT it_import AT '|' INTO: wa_tabname-tabname wa_tabname-alias.
        APPEND wa_tabname TO it_tabname.
      WHEN 'it_select'.
        CLEAR: wa_select,
               ls_style.

        ls_style-fieldname = 'BUT' .
        ls_style-style = cl_gui_alv_grid=>mc_style_button .
        APPEND ls_style TO wa_select-cellstyles .
        wa_select-sselect = it_import.
        APPEND wa_select TO it_select.
      WHEN 'it_join'.
        CLEAR:  wa_join,
                ls_style.
        SPLIT it_import AT '|' INTO: wa_join-ttype   wa_join-jjoin   wa_join-left   wa_join-right   wa_join-lv_key_select.

        ls_style-fieldname = 'BUT' .
        ls_style-style = cl_gui_alv_grid=>mc_style_button .
        APPEND ls_style TO wa_join-cellstyles .
        APPEND wa_join TO it_join.
      WHEN 'it_join_condition'.
        SPLIT it_import AT '|' INTO: wa_join_condition-left  wa_join_condition-right  wa_join_condition-lv_key_select  wa_join_condition-lv_key_join.
        APPEND wa_join_condition TO it_join_condition.
      WHEN 'it_where'.
        SPLIT it_import AT '|' INTO: wa_where-output  wa_where-expression  wa_where-alias  wa_where-aggregate  wa_where-sorttype  lv_sortorder   wa_where-criteriafor
      wa_where-disable_criteria  wa_where-or1   wa_where-or2  wa_where-or3  wa_where-or4  wa_where-lv_key_select wa_where-selectable.
        wa_where-sortorder = lv_sortorder.
        APPEND wa_where TO it_where.
    ENDCASE.
  ENDLOOP.


  PERFORM recalc_cwidth_opt USING alv_tabname.
  CALL METHOD alv_tabname->refresh_table_display .

  PERFORM recalc_cwidth_opt USING alv_select.
  CALL METHOD alv_select->refresh_table_display .

  PERFORM recalc_cwidth_opt USING alv_join.
  CALL METHOD alv_join->refresh_table_display .

  PERFORM recalc_cwidth_opt USING alv_join_condition.
  CALL METHOD alv_join_condition->refresh_table_display .

  PERFORM recalc_cwidth_opt USING alv_where.
  CALL METHOD alv_where->refresh_table_display .

  CALL METHOD gr_event_handler->handle_data_changed_fi_select.



ENDFORM. "IMPORT_select

*&---------------------------------------------------------------------*
*&      Form  EXPORT_select
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM export_select.

  DATA: it_export      TYPE TABLE OF string,
        lv_str         TYPE string,
        lv_str2(10)    TYPE c,
        _it_file_table TYPE TABLE OF file_table,
        _rc            TYPE i,
        lv_fname       TYPE  string.

  REFRESH it_export[].

*         it_tabname[]
  APPEND  '*it_tabname' TO it_export.
  LOOP AT it_tabname.
    CONCATENATE it_tabname-tabname it_tabname-alias INTO lv_str SEPARATED BY '|'.
    APPEND lv_str TO it_export.
  ENDLOOP.

*         it_select[]
  APPEND  '*it_select' TO it_export.
  LOOP AT it_select.
    APPEND  it_select-sselect  TO it_export.
  ENDLOOP.

*         it_join[]
  APPEND  '*it_join' TO it_export.
  LOOP AT it_join.
    CONCATENATE it_join-ttype   it_join-jjoin   it_join-left   it_join-right   it_join-lv_key_select INTO lv_str SEPARATED BY '|'.
    APPEND lv_str TO it_export.
  ENDLOOP.

*         it_join_condition[]
  APPEND  '*it_join_condition' TO it_export.
  LOOP AT it_join_condition.
    CONCATENATE   it_join_condition-left  it_join_condition-right  it_join_condition-lv_key_select  it_join_condition-lv_key_join INTO lv_str SEPARATED BY '|'.
    APPEND lv_str TO it_export.
  ENDLOOP.

*         it_where[]
  APPEND  '*it_where' TO it_export.
  LOOP AT it_where.
    WRITE it_where-sortorder TO lv_str2.
    CONCATENATE   it_where-output  it_where-expression  it_where-alias  it_where-aggregate  it_where-sorttype  lv_str2   it_where-criteriafor
      it_where-disable_criteria  it_where-or1   it_where-or2  it_where-or3  it_where-or4  it_where-lv_key_select it_where-selectable INTO lv_str SEPARATED BY '|'.
    APPEND lv_str TO it_export.
  ENDLOOP.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = 'File'
      default_extension = '*.txt'
      file_filter       = 'Text file (*.txt)|*.txt|File with delimiter ";" (*.csv)|*.csv|Excel (*.xls)|*.xls|All (*.*)|*.*'
    CHANGING
      file_table        = _it_file_table
      rc                = _rc.

  IF sy-subrc <> 0.
    EXIT.
  ELSE.
    READ TABLE _it_file_table INTO lv_fname INDEX 1.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  ENDIF.


  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename = lv_fname
      append   = ' '
      write_lf = 'X'
    TABLES
      data_tab = it_export.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM. "EXPORT_select

*&---------------------------------------------------------------------*
*&      Form  run_query
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM run_query.
  DATA: lv_tabname   TYPE tabname,
        str1         TYPE string,
        str2         TYPE string,
        it_t_tabname TYPE TABLE OF t_tabname WITH HEADER LINE,
        lv_str       TYPE string,
        lv_count     TYPE i,
        xfc          TYPE lvc_s_fcat,
        ifc          TYPE lvc_t_fcat.

  PERFORM show_code.

  CLEAR: lv_tabname,
         comp_tab[],
         comp_tab_t[],
         str1,
         str2,
         it_t_tabname[],
         it_t_tabname.

* generate set of components to select
  LOOP AT it_where WHERE lv_key_select = 'ZMAIN' AND output = 'X'.

    SPLIT it_where-expression AT '~' INTO: str1 str2 .
    IF ( it_where-aggregate = 'COUNT DISTINCT' ) OR  ( it_where-aggregate =  'COUNT' ).
      str1 = 'ADACACHE'.
      str2 = 'DA_HIT'.
    ENDIF.

    IF  str1 <> lv_tabname.
      lv_tabname = str1.

      READ TABLE it_tabname WITH  KEY alias = str1 .

      IF sy-subrc = 0.
        lv_tabname =  it_tabname-tabname .
      ENDIF.

      PERFORM get_struct TABLES  comp_tab_t[]  USING lv_tabname struct_type  .

*      struct_type ?= cl_abap_typedescr=>describe_by_name( lv_tabname ).
*      comp_tab_t = struct_type->get_components( ).
    ENDIF.

    LOOP AT comp_tab_t INTO comp_fld WHERE name = str2. "$$$$$$$$$$$$
      IF it_where-alias IS NOT INITIAL .
        comp_fld-name = it_where-alias.
      ENDIF.
      READ TABLE it_t_tabname WITH  KEY tabname = comp_fld-name.
      IF sy-subrc NE 0.
        it_t_tabname-tabname = comp_fld-name.
        APPEND it_t_tabname.
      ELSE.
        CONCATENATE 'Duplicate field' comp_fld-name  INTO lv_str SEPARATED BY space.
        MESSAGE lv_str TYPE 'E'.
        EXIT.
      ENDIF.

      IF comp_fld-type_kind = 'P'.

        comp_fld-length = comp_fld-length * 2 + 1.

      ENDIF.

      APPEND comp_fld TO comp_tab.
      EXIT.
    ENDLOOP.

  ENDLOOP.

  DESCRIBE TABLE comp_tab LINES lv_count.
  IF lv_count IS INITIAL.
    MESSAGE 'Create a query' TYPE 'E'.
  ENDIF.

  LOOP AT it_where WHERE  output EQ 'X'.
    IF it_where-aggregate IS NOT INITIAL AND it_where-alias IS INITIAL.
      CONCATENATE 'Fill the Alias for ' it_where-expression INTO lv_str SEPARATED BY space.
      MESSAGE lv_str TYPE 'E'.
    ENDIF.
  ENDLOOP.

  LOOP AT comp_tab INTO comp_line.
    CLEAR xfc.
    xfc-fieldname = comp_line-name .
    xfc-datatype = comp_line-type_kind.
    xfc-inttype = comp_line-type_kind.
    xfc-intlen = comp_line-length.
    xfc-decimals = comp_line-decimals.
    APPEND xfc TO ifc.
  ENDLOOP.


  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog = ifc
    IMPORTING
      ep_table        = dref.
  ASSIGN dref->* TO <it_outtab>.

  CREATE DATA dref LIKE LINE OF <it_outtab>.
  ASSIGN dref->* TO <wa_outtab>.

*//---------old select
*  TRY .
** THE dynamic select
*      SELECT          (it_s_result)
*             FROM     (it_s_from)
*             INTO CORRESPONDING FIELDS OF TABLE <it_outtab>
*             WHERE    (it_s_where)
*             GROUP BY (it_s_group)
*             HAVING   (it_s_having)
*             ORDER BY (it_s_order)
*        .
*
*    CATCH  cx_sy_dynamic_osql_semantics  INTO oref.
*      text = oref->get_text( ).
*      BREAK-POINT.
*
*    CATCH  cx_sy_dynamic_osql_syntax INTO oref.
*      text = oref->get_text( ).
*      BREAK-POINT.
*
*
*  ENDTRY.
*//----------------new
  PERFORM perform_select.


  IF alv_output IS NOT INITIAL.
    CALL METHOD alv_output->free.
  ENDIF.

  CREATE OBJECT alv_output
    EXPORTING
      i_appl_events = 'X'
      i_parent      = dock_sub_cont4.

  PERFORM prepare_field_catalog_output CHANGING gt_fieldcat_output .
  PERFORM prepare_layout_output CHANGING gs_layout_output .

  CALL METHOD alv_output->set_table_for_first_display
    EXPORTING
      is_layout       = gs_layout_output
    CHANGING
      it_outtab       = <it_outtab>
      it_fieldcatalog = gt_fieldcat_output.

  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 3
      height = '0'.

  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 4
      height = '40'.

ENDFORM. "run_query

*&---------------------------------------------------------------------*
*&      Form  detect_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM detect_table.
  DATA:           lv_count  TYPE i,
                  lv_flag_h,
                  lv_flag_s,
                  lv_flag.
  lv_flag = lv_flag_h = lv_flag_s = 'X'.

  SELECT COUNT( * )
    FROM dd03l
    INTO lv_count
    WHERE tabname = 'ZAAQB_H'.

  IF sy-subrc NE 0.
    CLEAR: lv_flag,
           lv_flag_h.
  ENDIF.

  SELECT COUNT( * )
    FROM dd03l
    INTO lv_count
    WHERE tabname = 'ZAAQB_S'.

  IF sy-subrc NE 0.
    CLEAR: lv_flag,
           lv_flag_s.
  ENDIF.

  IF lv_flag IS INITIAL.
    CLEAR itext[].
    APPEND '                      !!! ATTENTION !!!!  ' TO itext.
    APPEND '    ' TO itext.
    APPEND '  to use this aaditional functionality  ' TO itext.
    APPEND '  please create 2 z_table with folowing structure,  ' TO itext.
    APPEND '    ' TO itext.
    APPEND '  all data type alredy exist in ABAP DICTIONARY ' TO itext.
    APPEND '    ' TO itext.
    APPEND '    ' TO itext.
    APPEND '  1) ZAAQB_H  ' TO itext.
    APPEND '    ' TO itext.
    APPEND '  key      field_name                    data_type          ' TO itext.
    APPEND '  ----------------------------------------------------------- ' TO itext.
    APPEND '   X        CLNT                              MANDT           ' TO itext.
    APPEND '   X        BNAME                           XUBNAME         ' TO itext.
    APPEND '   X        DDTEXT                         AS4TEXT        ' TO itext.
    APPEND '   X        VERSION                      TDVERSION      ' TO itext.
    APPEND '   X        ID                                    F_ID          ' TO itext.
    APPEND '    ' TO itext.
    APPEND '    ' TO itext.
    APPEND '  2) ZAAQB_S  ' TO itext.
    APPEND '    ' TO itext.
    APPEND '    ' TO itext.
    APPEND '  key      field_name                    data_type          ' TO itext.
    APPEND '  ----------------------------------------------------------- ' TO itext.
    APPEND '    ' TO itext.
    APPEND '   X        CLNT                              MANDT         ' TO itext.
    APPEND '   X        ID                                     F_ID           ' TO itext.
    APPEND '   X        LINE                               CIFCOUNT       ' TO itext.
    APPEND '             T_TYPE                          CLASSTTYPE ' TO itext.
    APPEND '             TABNAME                      TABNAME ' TO itext.
    APPEND '             JJOIN                             TABNAME  ' TO itext.
    APPEND '             LEFT1                            TABNAME ' TO itext.
    APPEND '             RIGHT1                         TABNAME ' TO itext.
    APPEND '             LV_KEY_SELECT       TABNAME  ' TO itext.
    APPEND '             LEFT_61                       ECP_FIELDNAME  ' TO itext.
    APPEND '             RIGHT_61                    ECP_FIELDNAME  ' TO itext.
    APPEND '             LV_KEY_JOIN             ECP_FIELDNAME  ' TO itext.
    APPEND '             SORTORDER             ANZST  ' TO itext.
    APPEND '             CRITERIAFOR            ADDIFCTCOD  ' TO itext.
    APPEND '             DISABLE                      CLASSTTYPE  ' TO itext.
    APPEND '             OR1                              AKB_NOTE  ' TO itext.
    APPEND '             OR2                              AKB_NOTE  ' TO itext.
    APPEND '             OR3                              AKB_NOTE  ' TO itext.
    APPEND '             OR4                              AKB_NOTE  ' TO itext.
    APPEND '             selectable                              CLASSTTYPE  ' TO itext.
    APPEND '             title                                   LVC_TXTCOL  ' TO itext.

    CALL METHOD text_editor_top->set_text_as_r3table
      EXPORTING
        table  = itext
      EXCEPTIONS
        OTHERS = 1.
    CALL METHOD splitter->set_row_height
      EXPORTING
        id     = 4
        height = '0'.

    CALL METHOD splitter->set_row_height
      EXPORTING
        id     = 3
        height = '40'.


    MESSAGE 'Create Z_table.' TYPE 'E'.

  ENDIF.

ENDFORM. "detect_table

*&---------------------------------------------------------------------*
*&      Form  save
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM save.


  DATA: wa_zaaqb_h      TYPE t_zaaqb_h,
        wa_zaaqb_s      TYPE t_zaaqb_s,

        i_answer        TYPE c,
        i_valueout      TYPE as4text,
        lv_version      TYPE  tdversion,
        lv_id           TYPE  f_id,
        lv_line         LIKE wa_zaaqb_s-line,
        wa_zaaqb_ddtext TYPE t_zaaqb_ddtext,
        ret_tab         LIKE ddshretval OCCURS 0 WITH HEADER LINE,
        it_zaaqb_h_t    TYPE TABLE OF t_zaaqb_h WITH HEADER LINE,
        it_zaaqb_h      TYPE TABLE OF t_zaaqb_h WITH HEADER LINE,
        it_zaaqb_ddtext TYPE TABLE OF t_zaaqb_ddtext WITH HEADER LINE,
        lv_count        TYPE i.


  CLEAR lv_count.
  LOOP AT it_tabname WHERE tabname <> ''.
    ADD 1 TO lv_count.
  ENDLOOP.
  IF lv_count IS INITIAL.
    MESSAGE 'No save empty query' TYPE 'E'.
  ENDIF.

  CLEAR lv_count.
  LOOP AT it_where WHERE lv_key_select = 'ZMAIN' AND output = 'X'.
    ADD 1 TO lv_count.
  ENDLOOP.
  IF lv_count IS INITIAL.
    MESSAGE 'No save empty query' TYPE 'E'.
  ENDIF.


  PERFORM detect_table.
  SELECT (' BNAME   DDTEXT MAX( VERSION ) AS VERSION    ID')
        FROM ('ZAAQB_H')
        INTO CORRESPONDING FIELDS OF TABLE it_zaaqb_h_t
        GROUP BY ('BNAME   DDTEXT   ID')
        ORDER BY ('ID DESCENDING') .

  LOOP AT it_zaaqb_h_t.
    MOVE-CORRESPONDING it_zaaqb_h_t TO wa_zaaqb_ddtext.
    COLLECT wa_zaaqb_ddtext INTO it_zaaqb_ddtext.
  ENDLOOP.


  LOOP AT it_zaaqb_ddtext.
    CLEAR lv_version .
    LOOP AT it_zaaqb_h_t WHERE ddtext = it_zaaqb_ddtext-ddtext.
      IF lv_version < it_zaaqb_h_t-version.
        lv_version = it_zaaqb_h_t-version.
      ENDIF.
    ENDLOOP.

    READ TABLE it_zaaqb_h_t WITH KEY ddtext = it_zaaqb_ddtext-ddtext version = lv_version.
    APPEND it_zaaqb_h_t TO it_zaaqb_h.

  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'DDTEXT'
      window_title    = 'Select Query'
      value_org       = 'S'
      multiple_choice = ' '
    TABLES
      value_tab       = it_zaaqb_h
      return_tab      = ret_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc = 0.
    LOOP AT ret_tab.
      i_valueout  = ret_tab-fieldval .
    ENDLOOP.
  ENDIF.

  IF i_valueout IS INITIAL.
    CALL FUNCTION 'POPUP_TO_GET_VALUE'
      EXPORTING
        fieldname           = 'DDTEXT'
        tabname             = 'DD90T'
        titel               = 'Please enter the query name'
        valuein             = sy-uname
      IMPORTING
        answer              = i_answer
        valueout            = i_valueout
      EXCEPTIONS
        fieldname_not_found = 1
        OTHERS              = 2.

    IF i_answer = 'C'.
      EXIT.
    ENDIF.
  ENDIF.



  SELECT  COUNT( * )  FROM ('ZAAQB_H')
*    into wa_zaaqb_h
    WHERE ddtext = i_valueout.

  IF sy-subrc = 0.
    SELECT  MAX( version ) INTO lv_version
            FROM ('ZAAQB_H')
            WHERE  ddtext = i_valueout.

    SELECT  MAX( id ) INTO lv_id
            FROM ('ZAAQB_H').

    ADD 1 TO lv_version.
    ADD 1 TO lv_id.
  ELSE.
    lv_version = 1.
    SELECT  MAX( id ) INTO lv_id
            FROM ('ZAAQB_H').
    IF sy-subrc NE 0.
      lv_id = 1.
    ELSE.
      ADD 1 TO lv_id.
    ENDIF.

  ENDIF.

  wa_zaaqb_h-bname   = sy-uname.
  wa_zaaqb_h-ddtext  = i_valueout.
  wa_zaaqb_h-version = lv_version.
  wa_zaaqb_h-id      = lv_id.

  INSERT ('ZAAQB_H') FROM wa_zaaqb_h.
  lv_line = 0.

  LOOP AT it_tabname.
    CLEAR wa_zaaqb_s.
    ADD 1 TO lv_line.
    wa_zaaqb_s-t_type  = 'T'.
    wa_zaaqb_s-id      = lv_id.
    wa_zaaqb_s-line    = lv_line.

    wa_zaaqb_s-tabname = it_tabname-tabname.
    wa_zaaqb_s-jjoin   = it_tabname-alias.

    INSERT ('ZAAQB_S') FROM wa_zaaqb_s.
  ENDLOOP.

  LOOP AT it_select.
    CLEAR wa_zaaqb_s.
    ADD 1 TO lv_line.
    wa_zaaqb_s-t_type  = 'S'.
    wa_zaaqb_s-id      = lv_id.
    wa_zaaqb_s-line    = lv_line.

    wa_zaaqb_s-tabname = it_select-sselect.

    INSERT ('ZAAQB_S') FROM wa_zaaqb_s.
  ENDLOOP.

  LOOP AT it_join.
    CLEAR wa_zaaqb_s.
    ADD 1 TO lv_line.
    wa_zaaqb_s-t_type        = 'J'.
    wa_zaaqb_s-id            = lv_id.
    wa_zaaqb_s-line          = lv_line.

    wa_zaaqb_s-tabname       = it_join-ttype.
    wa_zaaqb_s-jjoin         = it_join-jjoin.
    wa_zaaqb_s-left1         = it_join-left.
    wa_zaaqb_s-right1        = it_join-right.
    wa_zaaqb_s-lv_key_select = it_join-lv_key_select.


    INSERT ('ZAAQB_S') FROM wa_zaaqb_s.
  ENDLOOP.

  LOOP AT it_join_condition.
    CLEAR wa_zaaqb_s.
    ADD 1 TO lv_line.
    wa_zaaqb_s-t_type               = 'C'.
    wa_zaaqb_s-id                   = lv_id.
    wa_zaaqb_s-line                 = lv_line.

    wa_zaaqb_s-left_61              = it_join_condition-left.
    wa_zaaqb_s-right_61             = it_join_condition-right.
    wa_zaaqb_s-lv_key_select        = it_join_condition-lv_key_select.
    wa_zaaqb_s-lv_key_join          = it_join_condition-lv_key_join.


    INSERT ('ZAAQB_S') FROM wa_zaaqb_s.
  ENDLOOP.

  LOOP AT it_where.
    CLEAR wa_zaaqb_s.
    ADD 1 TO lv_line.
    wa_zaaqb_s-t_type               = 'W'.
    wa_zaaqb_s-id                   = lv_id.
    wa_zaaqb_s-line                 = lv_line.

    wa_zaaqb_s-tabname              = it_where-output.
    wa_zaaqb_s-lv_key_join          = it_where-expression.
    wa_zaaqb_s-left1                = it_where-alias.
    wa_zaaqb_s-right1               = it_where-aggregate.
    wa_zaaqb_s-jjoin                = it_where-sorttype.
    wa_zaaqb_s-sortorder            = it_where-sortorder.
    wa_zaaqb_s-criteriafor          = it_where-criteriafor.
    wa_zaaqb_s-disable              = it_where-disable_criteria.
    wa_zaaqb_s-or1                  = it_where-or1.
    wa_zaaqb_s-or2                  = it_where-or2.
    wa_zaaqb_s-or3                  = it_where-or3.
    wa_zaaqb_s-or4                  = it_where-or4.
    wa_zaaqb_s-lv_key_select        = it_where-lv_key_select.
    wa_zaaqb_s-selectable           = it_where-selectable.
    wa_zaaqb_s-title                = it_where-title.

    INSERT ('ZAAQB_S') FROM wa_zaaqb_s.
  ENDLOOP.

ENDFORM. "save
*&---------------------------------------------------------------------*
*&      Form  list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM list USING p_all TYPE c.


  DATA: wa_zaaqb_h        TYPE t_zaaqb_h,
        wa_zaaqb_s        TYPE t_zaaqb_s,
        wa_zaaqb_ddtext   TYPE t_zaaqb_ddtext,
        it_zaaqb_ddtext   TYPE TABLE OF t_zaaqb_ddtext WITH HEADER LINE,

        it_zaaqb_h_t      TYPE TABLE OF t_zaaqb_h WITH HEADER LINE,
        it_zaaqb_h        TYPE TABLE OF t_zaaqb_h WITH HEADER LINE,
        it_zaaqb_s        TYPE TABLE OF t_zaaqb_s WITH HEADER LINE,
        ret_tab           LIKE ddshretval OCCURS 0 WITH HEADER LINE,
        lv_version        TYPE tdversion,
        lv_id             TYPE f_id,
        ls_style          TYPE lvc_s_styl,


        wa_tabname        TYPE  t_tabname,
        wa_select         TYPE  t_select,
        wa_join           TYPE  t_join,
        wa_join_condition TYPE  t_join_condition,
        wa_where          TYPE  t_where.

  PERFORM detect_table.


  IF p_all IS INITIAL.

    SELECT (' BNAME   DDTEXT MAX( VERSION ) AS VERSION    ID')
     " SELECT (' BNAME   DDTEXT  VERSION    ID')
              FROM ('ZAAQB_H')
              INTO CORRESPONDING FIELDS OF TABLE it_zaaqb_h_t
              GROUP BY ('BNAME   DDTEXT   ID')
              ORDER BY ('ID DESCENDING') .

  ELSE.
*>>> all version
*SELECT (' BNAME   DDTEXT MAX( VERSION ) AS VERSION    ID')
    SELECT (' BNAME   DDTEXT  VERSION    ID')
            FROM ('ZAAQB_H')
            INTO CORRESPONDING FIELDS OF TABLE it_zaaqb_h_t
            "GROUP BY ('BNAME   DDTEXT   ID')
            ORDER BY ('ID DESCENDING') .
*<<< all version
  ENDIF.



  LOOP AT it_zaaqb_h_t.
    MOVE-CORRESPONDING it_zaaqb_h_t TO wa_zaaqb_ddtext.
    COLLECT wa_zaaqb_ddtext INTO it_zaaqb_ddtext.
  ENDLOOP.

  IF p_all IS  INITIAL.
*>>last version
    LOOP AT it_zaaqb_ddtext.
      CLEAR lv_version .
      LOOP AT it_zaaqb_h_t WHERE ddtext = it_zaaqb_ddtext-ddtext.
        IF lv_version < it_zaaqb_h_t-version.
          lv_version = it_zaaqb_h_t-version.
        ENDIF.
      ENDLOOP.

      READ TABLE it_zaaqb_h_t WITH KEY ddtext = it_zaaqb_ddtext-ddtext version = lv_version.
      APPEND it_zaaqb_h_t TO it_zaaqb_h.

    ENDLOOP.
*<<last version
  ELSE.
*>> all version

    CLEAR   it_zaaqb_h.
    APPEND LINES OF it_zaaqb_h_t TO it_zaaqb_h.
*<< all version
  ENDIF.



  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ID'
      window_title    = 'Select Query'
      value_org       = 'S'
      multiple_choice = ' '
    TABLES
      value_tab       = it_zaaqb_h
      return_tab      = ret_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc = 0.
    LOOP AT ret_tab.
      lv_id  = ret_tab-fieldval .
    ENDLOOP.
  ENDIF.

  IF lv_id IS INITIAL.
    EXIT.
  ENDIF.

  SELECT (' * ')
          INTO CORRESPONDING FIELDS OF TABLE it_zaaqb_s
          FROM ('ZAAQB_S')
          WHERE id = lv_id.

  CLEAR:  it_tabname          ,
          it_tabname[]        ,
          it_select           ,
          it_select[]         ,
          it_join             ,
          it_join[]           ,
          it_join_condition   ,
          it_join_condition[] ,
          it_where            ,
          it_where[]          .

  LOOP AT it_zaaqb_s WHERE t_type = 'T'.
    CLEAR wa_tabname.
    wa_tabname-tabname = it_zaaqb_s-tabname.
    wa_tabname-alias   = it_zaaqb_s-jjoin.
    APPEND wa_tabname TO it_tabname.
  ENDLOOP.

  LOOP AT it_zaaqb_s WHERE t_type = 'S'.
    CLEAR wa_select.
    wa_select-sselect  = it_zaaqb_s-tabname.

    ls_style-fieldname = 'BUT' .
    ls_style-style = cl_gui_alv_grid=>mc_style_button .
    APPEND ls_style TO wa_select-cellstyles .

    APPEND wa_select TO it_select.
  ENDLOOP.


  LOOP AT it_zaaqb_s WHERE t_type = 'J'.
    CLEAR wa_join.
    wa_join-ttype          = it_zaaqb_s-tabname.
    wa_join-jjoin          = it_zaaqb_s-jjoin.
    wa_join-left           = it_zaaqb_s-left1.
    wa_join-right          = it_zaaqb_s-right1.
    wa_join-lv_key_select  = it_zaaqb_s-lv_key_select .

    ls_style-fieldname = 'BUT' .
    ls_style-style = cl_gui_alv_grid=>mc_style_button .
    APPEND ls_style TO wa_join-cellstyles .

    APPEND wa_join TO it_join.
  ENDLOOP.

  LOOP AT it_zaaqb_s WHERE t_type = 'C'.
    CLEAR wa_join_condition.
    wa_join_condition-left                  = it_zaaqb_s-left_61.
    wa_join_condition-right                 = it_zaaqb_s-right_61.
    wa_join_condition-lv_key_select         = it_zaaqb_s-lv_key_select.
    wa_join_condition-lv_key_join           = it_zaaqb_s-lv_key_join.

    APPEND wa_join_condition TO it_join_condition.
  ENDLOOP.

  LOOP AT it_zaaqb_s WHERE t_type = 'W'.
    CLEAR wa_where  .
    wa_where-output                   = it_zaaqb_s-tabname.
    wa_where-expression               = it_zaaqb_s-lv_key_join.
    wa_where-alias                    = it_zaaqb_s-left1.
    wa_where-aggregate                = it_zaaqb_s-right1.
    wa_where-sorttype                 = it_zaaqb_s-jjoin.
    wa_where-sortorder                = it_zaaqb_s-sortorder.
    wa_where-criteriafor              = it_zaaqb_s-criteriafor .
    wa_where-disable_criteria         = it_zaaqb_s-disable.
    wa_where-or1                      = it_zaaqb_s-or1 .
    wa_where-or2                      = it_zaaqb_s-or2 .
    wa_where-or3                      = it_zaaqb_s-or3.
    wa_where-or4                      = it_zaaqb_s-or4 .
    wa_where-lv_key_select            = it_zaaqb_s-lv_key_select.
    wa_where-selectable               = it_zaaqb_s-selectable.
    wa_where-title                    = it_zaaqb_s-title.


    APPEND wa_where TO it_where.
  ENDLOOP.

  PERFORM recalc_cwidth_opt USING alv_tabname.
  CALL METHOD alv_tabname->refresh_table_display .

  PERFORM recalc_cwidth_opt USING alv_select.
  CALL METHOD alv_select->refresh_table_display .

  PERFORM recalc_cwidth_opt USING alv_join.
  CALL METHOD alv_join->refresh_table_display .

  PERFORM recalc_cwidth_opt USING alv_join_condition.
  CALL METHOD alv_join_condition->refresh_table_display .

  PERFORM recalc_cwidth_opt USING alv_where.
  CALL METHOD alv_where->refresh_table_display .


  MESSAGE 'list' TYPE 'S'.
ENDFORM. "list
*&---------------------------------------------------------------------*
*&      Form  f_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_delete.
  PERFORM detect_table.
  MESSAGE 'f_delete' TYPE 'S'.
ENDFORM. "f_delete

*&---------------------------------------------------------------------*
*&      Form  get_struct
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->COMP_TAB     text
*      -->TABNAME      text
*      -->STRUCT_TYPE  text
*----------------------------------------------------------------------*
FORM get_struct TABLES comp_tab TYPE abap_compdescr_tab USING tabname TYPE tabname struct_type TYPE REF TO cl_abap_structdescr .

  DATA:comp_tab_t  TYPE abap_compdescr_tab WITH HEADER LINE,
       comp_tab_t2 TYPE abap_compdescr_tab WITH HEADER LINE.

  IF tabname IS NOT INITIAL.
    struct_type ?= cl_abap_typedescr=>describe_by_name( tabname ).
  ENDIF.

  comp_tab_t[] = struct_type->components[].

  LOOP AT comp_tab_t.
*    IF comp_tab_t-as_include IS NOT INITIAL.
*      CLEAR: comp_tab_t2,
*             comp_tab_t2[].
*      MOVE comp_tab_t-type ?TO  struct_type.
*      "struct_type = COMP_TAB_T-type .
*      PERFORM get_struct TABLES comp_tab_t2[] USING '' struct_type   .
*      APPEND LINES OF comp_tab_t2 TO comp_tab.
*    ELSE.
    IF comp_tab_t-name IS NOT INITIAL.
      APPEND comp_tab_t TO comp_tab.
    ELSE.
*        CLEAR: comp_tab_t2,
*               comp_tab_t2[].
*        MOVE comp_tab_t-type_kind TO  struct_type.
*        "struct_type = COMP_TAB_T-type .
*        PERFORM get_struct TABLES comp_tab_t2[] USING '' struct_type   .
*        APPEND LINES OF comp_tab_t2 TO comp_tab.
    ENDIF.
*    ENDIF.

  ENDLOOP.

ENDFORM. "get_struct

*&---------------------------------------------------------------------*
*&      Form  dynamic_select
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM perform_select.
  TYPES: t_source(72).

  DATA: routine(32)  VALUE 'DYNAMIC_SELECT_ZAAQB',
        program(8),
        message(128),
        line         TYPE i.

  DATA: isource  TYPE TABLE OF t_source,
        xsource  TYPE t_source,
        it_split TYPE TABLE OF edpline.


  DATA: itext_t TYPE TABLE OF tline-tdline WITH HEADER LINE.
  CALL METHOD text_editor_top->get_text_as_r3table
    IMPORTING
      table  = itext_t[]
    EXCEPTIONS
      OTHERS = 1.

  DELETE itext_t INDEX 1.

  LOOP AT itext_t .
    IF itext_t = 'break-point.'.
      DELETE itext_t INDEX sy-tabix.
    ENDIF.
    IF itext_t = 'into corresponding fields of table it_zaaqb'.
      itext_t = 'INTO CORRESPONDING FIELDS OF TABLE it_table_zaaqb'.
      MODIFY itext_t.
    ENDIF.
  ENDLOOP.

  xsource = 'REPORT ZTEMP_ZAAQB.'.
  INSERT xsource  INTO itext_t INDEX 1.


  xsource = 'FORM DYNAMIC_SELECT_ZAAQB CHANGING it_table_zaaqb TYPE ANY TABLE.'.
  INSERT xsource INTO itext_t INDEX 2.

  xsource = 'ENDFORM.'.
  APPEND xsource TO itext_t.

  REFRESH isource.
  LOOP AT itext_t.
    CONDENSE itext_t.
    SPLIT itext_t AT space INTO: TABLE it_split.
    APPEND LINES OF it_split TO isource.
  ENDLOOP.

  LOOP AT isource INTO  xsource.
    IF xsource = '*'.
      xsource = ' *'.
      MODIFY isource FROM xsource INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

  GENERATE SUBROUTINE POOL isource NAME program
                         MESSAGE message
                         LINE line.
  IF sy-subrc = 0.
    PERFORM (routine) IN PROGRAM (program) CHANGING <it_outtab>.
  ELSE.
    MESSAGE message TYPE 'E' .
  ENDIF.

ENDFORM. "dynamic_select

*>>>--join_wizard
FORM zaaqb_set_keyword TABLES key_word USING ref TYPE REF TO zcl_zaaqb_query_join_cntrl."lcl_zaaqb_join_cntrl.
  DATA: it_key_word TYPE aqtdban,
        wa_key_word LIKE LINE OF it_key_word,
        wa_tabname  TYPE tabname.

  LOOP AT key_word INTO wa_tabname.
    wa_key_word-table = wa_tabname.
    APPEND wa_key_word TO it_key_word.
  ENDLOOP.

  ref->set_keywords( EXPORTING it_key_word = it_key_word ).

ENDFORM. "zaaqb_set_keyword

*&---------------------------------------------------------------------*
*&      Form  zaaqb_remove_keyword
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->KEY_WORD   text
*      -->REF        text
*----------------------------------------------------------------------*
FORM zaaqb_remove_keyword TABLES key_word USING ref TYPE REF TO zcl_zaaqb_query_join_cntrl."lcl_zaaqb_join_cntrl.
  DATA: it_key_word TYPE aqtdban,
        wa_key_word LIKE LINE OF it_key_word,
        wa_tabname  TYPE tabname.

  LOOP AT key_word INTO wa_tabname.
    wa_key_word-table = wa_tabname.
    APPEND wa_key_word TO it_key_word.
  ENDLOOP.

  ref->remove_keywords( EXPORTING it_key_word = it_key_word ).

ENDFORM. "zaaqb_remove_keyword

*&---------------------------------------------------------------------*
*&      Form  transport_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM transport_text.
  DATA: key_word    TYPE STANDARD TABLE OF tabname,
        it_key_word TYPE aqtdban,
        wa_key_word LIKE LINE OF it_key_word,
        it_split    TYPE STANDARD TABLE OF tabname,
        wa_tabname  TYPE tabname,
        itext_t     TYPE TABLE OF tline-tdline WITH HEADER LINE,
        lv_count    TYPE i,
        it_dban     TYPE  aqtdban,
        lv_len      TYPE i,
        lv_index    TYPE i.

  join_wizard->delete_all_table(  ).

  CALL METHOD text_editor_top->get_text_as_r3table
    IMPORTING
      table  = itext_t[]
    EXCEPTIONS
      OTHERS = 1.

  LOOP AT itext_t.
    "CONDENSE itext_t .
    TRANSLATE itext_t TO UPPER CASE.
    DESCRIBE FIELD itext_t LENGTH  lv_len IN CHARACTER MODE.
    DO lv_len  TIMES.
      lv_index = sy-index - 1.
      IF ( itext_t+lv_index(1) CN sy-abcde ) AND ( itext_t+lv_index(1) CN '1234567890_' ).
        itext_t+lv_index(1) = ' '.
      ENDIF.
    ENDDO.
*    REPLACE ALL OCCURRENCES OF REGEX '[^A-Za-z0-9_]' IN itext_t WITH '\$'.

    TRANSLATE itext_t USING '$ '.

    CONDENSE itext_t .
    SPLIT itext_t AT ' ' INTO TABLE it_split.
    LOOP AT it_split INTO wa_tabname .
      READ TABLE key_word TRANSPORTING NO FIELDS WITH KEY table_line = wa_tabname .
      IF sy-subrc = 4 .
        APPEND wa_tabname TO key_word.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  PERFORM zaaqb_set_keyword TABLES key_word USING join_wizard.

  join_wizard->get_keywords( IMPORTING it_key_word = it_key_word ).

  join_wizard->p_join_data_r->get_info( IMPORTING et_dban = it_dban ).

  LOOP AT it_key_word INTO wa_key_word.
    SELECT COUNT( * )
  FROM dd03l
  INTO lv_count
  WHERE tabname = wa_key_word-table.

    IF sy-subrc = 0.
      join_wizard->add_table( EXPORTING i_tabname = wa_key_word-table ).
    ELSE.
      READ TABLE it_dban WITH KEY alias = wa_key_word-table TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        join_wizard->add_table( EXPORTING i_tabname = wa_key_word-table ).
      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH itext_t.
  CALL METHOD text_editor_top->set_text_as_r3table
    EXPORTING
      table  = itext_t[]
    EXCEPTIONS
      OTHERS = 1.


ENDFORM. "transport_text
*&---------------------------------------------------------------------*
*&      Form  REMOVE_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM remove_text .
  DATA: key_word    TYPE STANDARD TABLE OF tabname,
        it_key_word TYPE aqtdban,
        wa_key_word LIKE LINE OF it_key_word,
        it_split    TYPE STANDARD TABLE OF tabname,
        itext_t     TYPE TABLE OF tline-tdline WITH HEADER LINE,
        wa_tabname  TYPE tabname,
        lv_count    TYPE i,
        it_dban     TYPE  aqtdban,
        lv_len      TYPE i,
        lv_index    TYPE i.

  join_wizard->delete_all_table(  ).

  CALL METHOD text_editor_top->get_text_as_r3table
    IMPORTING
      table  = itext_t[]
    EXCEPTIONS
      OTHERS = 1.

  LOOP AT itext_t.
    "CONDENSE itext_t .

    DESCRIBE FIELD itext_t LENGTH  lv_len IN CHARACTER MODE.
    DO lv_len  TIMES.
      lv_index = sy-index - 1.
      IF ( itext_t+lv_index(1) CN sy-abcde ) AND ( itext_t+lv_index(1) CN '1234567890_' ).
        itext_t+lv_index(1) = ' '.
      ENDIF.
    ENDDO.

    TRANSLATE itext_t TO UPPER CASE.
    TRANSLATE itext_t USING '$ '.
    CONDENSE itext_t .
    SPLIT itext_t AT ' ' INTO TABLE it_split.
    LOOP AT it_split INTO wa_tabname .
      READ TABLE key_word TRANSPORTING NO FIELDS WITH KEY table_line = wa_tabname .
      IF sy-subrc = 4 .
        APPEND wa_tabname TO key_word.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  PERFORM zaaqb_remove_keyword TABLES key_word USING join_wizard.

  join_wizard->get_keywords( IMPORTING it_key_word = it_key_word ).
  join_wizard->p_join_data_r->get_info( IMPORTING et_dban = it_dban ).

  LOOP AT it_key_word INTO wa_key_word.
*    SELECT COUNT( * )
*  FROM dd03l
*  INTO lv_count
*  WHERE tabname = wa_key_word-table.

    CLEAR lv_count.
    SELECT COUNT( * )
  FROM dd02l
  INTO lv_count
  WHERE tabname = wa_key_word-table AND
      tabclass IN ('TRANSP', 'VIEW').


    IF lv_count <> 0.
      join_wizard->add_table( EXPORTING i_tabname = wa_key_word-table ).
    ELSE.
      READ TABLE it_dban WITH KEY alias = wa_key_word-table TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        join_wizard->add_table( EXPORTING i_tabname = wa_key_word-table ).
      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH itext_t.
  CALL METHOD text_editor_top->set_text_as_r3table
    EXPORTING
      table  = itext_t[]
    EXCEPTIONS
      OTHERS = 1.

ENDFORM. " REMOVE_TEXT
*&---------------------------------------------------------------------*
*&      Form  SAVE_JOIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_join .

  DATA: itt_tabname        TYPE TABLE OF t_tabname,
        itt_select         TYPE TABLE OF t_select,
        itt_join           TYPE TABLE OF t_join,
        wa_tjoin           TYPE t_join,
        itt_join_condition TYPE TABLE OF t_join_condition,
        wa_join_condition  TYPE  t_join_condition,
        itt_where          TYPE TABLE OF t_where,
        it_where_t         TYPE TABLE OF t_where WITH HEADER LINE,

        it_dban            TYPE aqtdban,
        wa_dban            LIKE LINE OF it_dban,
        it_dbjt            TYPE aqtdbjt,
        wa_dbjt            LIKE LINE OF it_dbjt,
        it_dbjc            TYPE aqtdbjc, "join link
        it_dbjc2           TYPE aqtdbjc, "join condition
        it_tfield          TYPE aqq_t_tfield,
        wa_tfield          LIKE LINE OF it_tfield,
        lv_ind(2)          TYPE n,

        wa_dbjc            LIKE LINE OF it_dbjc,

        wa_tabname         TYPE   t_tabname,
        wa_select          TYPE   t_select,
        wa_join            TYPE   t_join,
        wa_where           TYPE   t_where,
        ls_style           TYPE lvc_s_styl,
        lv_str             TYPE string.


*>>>---
*tables
*join-wizard-P_JOIN_DATA_R-PT_DBJT
*
**alias
*join-wizard-P_JOIN_DATA_R-PT_DBAN
*
*
**join
*join-wizard-P_JOIN_DATA_R-PT_DBJC
*
*
**select
*join-wizard-PT_TFIELD
*<<---

*delete lv_key_select ###################3

  join_wizard->p_join_data_r->get_info( IMPORTING et_dban = it_dban
                                                 et_dbjt = it_dbjt
                                                 et_dbjc = it_dbjc ).

  join_wizard->p_join_data_r->get_info( IMPORTING  et_dbjc = it_dbjc2 ).

  it_tfield = join_wizard->pt_tfield.

  DELETE  it_dbjc  WHERE jind IS NOT INITIAL.
  DELETE  it_dbjc2 WHERE jind IS INITIAL.

  LOOP AT it_dbjc INTO wa_dbjc.

    READ TABLE it_dbjc TRANSPORTING NO FIELDS WITH KEY ltable = wa_dbjc-rtable.

    IF sy-subrc = 0.
      wa_dbjc-jind = sy-tabix.
      MODIFY it_dbjc FROM wa_dbjc.
    ENDIF.

  ENDLOOP.

  READ TABLE it_dbjc INTO wa_dbjc WITH KEY jind = ''.

  wa_dbjc-jind = 99.

  IF sy-tabix <>  0.
    MODIFY it_dbjc FROM wa_dbjc INDEX sy-tabix.
  ENDIF.


  SORT it_dbjc BY jind ASCENDING  .

*table
  LOOP AT it_dbjt INTO wa_dbjt .
    CLEAR wa_tabname.
    wa_tabname-tabname = wa_dbjt-table.
    APPEND  wa_tabname TO itt_tabname.
  ENDLOOP.

*alias

  LOOP AT it_dban INTO wa_dban.
    READ TABLE itt_tabname INTO wa_tabname  WITH KEY tabname = wa_dban-alias alias = ''.
    IF sy-subrc = 0.
      wa_tabname-alias = wa_dban-alias.
      wa_tabname-tabname = wa_dban-table.
      MODIFY itt_tabname FROM wa_tabname INDEX sy-tabix . "##########
    ENDIF.
  ENDLOOP.

*join
  lv_str = ''.
  LOOP AT it_dbjc INTO wa_dbjc.
    CLEAR: wa_join,
          ls_style.

    wa_join-ttype = 'INNER JOIN'.

    lv_ind = sy-tabix.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_ind
      IMPORTING
        output = lv_ind.

    IF lv_str IS NOT INITIAL.
      wa_join-left  = lv_str.
    ELSE.
      wa_join-left  = wa_dbjc-ltable .
    ENDIF.


    CONCATENATE 'JOIN' lv_ind INTO wa_join-jjoin.
    lv_str = wa_join-jjoin.

    wa_join-right = wa_dbjc-rtable .
    wa_join-lv_key_select = join_wizard->lv_key_select.

    ls_style-fieldname = 'BUT' .
    ls_style-style = cl_gui_alv_grid=>mc_style_button .
    APPEND ls_style TO wa_join-cellstyles .

    APPEND wa_join TO itt_join.


  ENDLOOP.

*join_condition
  LOOP AT it_dbjc2 INTO wa_dbjc.
    CLEAR: wa_join_condition,
          wa_join.

    wa_join_condition-left  = wa_dbjc-lname.
    TRANSLATE wa_join_condition-left USING '-~'.
    wa_join_condition-right = wa_dbjc-rname.
    TRANSLATE wa_join_condition-right USING '-~'.

    wa_join_condition-lv_key_select = join_wizard->lv_key_select.

    READ TABLE itt_join INTO wa_join WITH KEY      right = wa_dbjc-rtable. "left = wa_dbjc-ltable
    IF sy-subrc = 0.
      wa_join_condition-lv_key_join = wa_join-jjoin.
    ENDIF.

    APPEND wa_join_condition TO itt_join_condition.

  ENDLOOP.


*where

  LOOP AT it_tfield INTO wa_tfield.
    CLEAR wa_where.
    wa_where-output = 'X'.
    CONCATENATE wa_tfield-tabname '~' wa_tfield-colname INTO  wa_where-expression.
    wa_where-lv_key_select = join_wizard->lv_key_select.

    APPEND wa_where TO itt_where.

  ENDLOOP.


  DELETE it_tabname WHERE tabname IS INITIAL.
  LOOP AT itt_tabname INTO wa_tabname.
    COLLECT wa_tabname INTO it_tabname.
  ENDLOOP.

  DELETE it_join WHERE lv_key_select = join_wizard->lv_key_select.
  APPEND LINES OF itt_join TO it_join.

  DELETE it_join_condition WHERE lv_key_select = join_wizard->lv_key_select.
  APPEND LINES OF itt_join_condition TO it_join_condition.

  LOOP AT it_where WHERE lv_key_select = join_wizard->lv_key_select.
    APPEND it_where TO it_where_t.
  ENDLOOP.

  DELETE it_where WHERE lv_key_select = join_wizard->lv_key_select.
  APPEND LINES OF itt_where TO it_where.

  LOOP AT it_where WHERE lv_key_select = join_wizard->lv_key_select.
    READ TABLE it_where_t WITH  KEY lv_key_select = join_wizard->lv_key_select  expression = it_where-expression alias = it_where-alias.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING it_where_t TO it_where.
      MODIFY it_where.
    ENDIF.
  ENDLOOP.

  PERFORM recalc_cwidth_opt USING alv_tabname.
  CALL METHOD alv_tabname->refresh_table_display .

  PERFORM recalc_cwidth_opt USING alv_select.
  CALL METHOD alv_select->refresh_table_display .

  PERFORM recalc_cwidth_opt USING alv_join.
  CALL METHOD alv_join->refresh_table_display .

  PERFORM recalc_cwidth_opt USING alv_join_condition.
  CALL METHOD alv_join_condition->refresh_table_display .

  PERFORM recalc_cwidth_opt USING alv_where.
  CALL METHOD alv_where->refresh_table_display .

  PERFORM join_wizard_exit.
  MESSAGE 'SAVE' TYPE 'S'.

ENDFORM. " SAVE_JOIN
*<<<--join_wizard

*>>>---tool_bar
FORM add_button_group.

  DEFINE m_add_button.
    call method cl_gui_toolbar=>fill_buttons_data_table
      EXPORTING
        fcode      = &1
        icon       = &2
        butn_type  = cntb_btype_button
        text       = &3
        quickinfo  = &4
      CHANGING
        data_table = gt_button_group.
  END-OF-DEFINITION.

  DEFINE separator.

    call method cl_gui_toolbar=>fill_buttons_data_table
      EXPORTING
        fcode      = ''
        icon       = ''
        butn_type  = 3
        text       = ''
        quickinfo  = ''
      CHANGING
        data_table = gt_button_group.
  END-OF-DEFINITION.

  m_add_button 'EXIT'    icon_cancel  'Exit'     'Exit'.
  separator.
  m_add_button 'TABLE'    icon_header  'Add table'     'Add table'.
  m_add_button 'ALIAS'    icon_oo_alias  'ALIAS'     'ALIAS'.
  m_add_button 'F_LDEL'    icon_delete  ''     ''.
  separator.
  m_add_button 'FILLTEXT'    icon_page_down  'ADD text'     'ADD text'.
  m_add_button 'REMOVETEXT'    icon_page_up  'REMOVE  text'     'REMOVE  text'.
  separator.
  m_add_button 'F_NAVI'    icon_set_intersection  ''     ''.
  m_add_button 'F_ZOOMIN'    icon_zoom_in  ''     ''.
  m_add_button 'F_ZOOMOUT'    icon_zoom_out  ''     ''.
  separator.
  m_add_button 'DELETE_ALL'    icon_delete_favorites  'DELETE_ALL'     'DELETE_ALL'.
  m_add_button 'SAVE'    icon_system_save  ''     ''.

* Add button group to toolbar
  CALL METHOD go_toolbar->add_button_group
    EXPORTING
      data_table = gt_button_group.

ENDFORM. " ADD_BUTTON_GROUP
*<<<---tool_bar

FORM fly .
  DATA:        it_dban           TYPE aqtdban,
               wa_dban           LIKE LINE OF it_dban,
               wa_join           TYPE t_join,
               wa_where          TYPE t_where,
               wa_join_condition TYPE t_join_condition,
               itt_table         TYPE TABLE OF t_tabname,
               wa_tabname        TYPE t_tabname,
               lv_str1           TYPE string,
               lv_str2           TYPE string,
               itext_t           TYPE TABLE OF tline-tdline WITH HEADER LINE.

  join_wizard->delete_all_table( ).
  REFRESH join_wizard->zaaqb_key_word.

  LOOP AT it_join INTO wa_join WHERE lv_key_select = lv_key_select.
    READ TABLE it_tabname INTO wa_tabname WITH KEY  alias = wa_join-left .
    IF sy-subrc = 0.
      COLLECT wa_tabname INTO itt_table.
    ENDIF.
    READ TABLE it_tabname INTO wa_tabname WITH KEY  alias = wa_join-right .
    IF sy-subrc = 0.
      COLLECT wa_tabname INTO itt_table.
    ENDIF.
  ENDLOOP.

  LOOP AT it_where INTO wa_where WHERE lv_key_select = lv_key_select.
    SPLIT wa_where-expression AT '~' INTO lv_str1 lv_str2.

    READ TABLE it_tabname INTO wa_tabname WITH KEY  alias = lv_str1 .
    IF sy-subrc = 0.
      COLLECT wa_tabname INTO itt_table.
    ENDIF.
  ENDLOOP.

  LOOP AT itt_table INTO wa_tabname WHERE alias IS NOT INITIAL.
    CLEAR wa_dban.
    wa_dban-table = wa_tabname-tabname.
    wa_dban-alias = wa_tabname-alias.
    APPEND wa_dban TO it_dban.
  ENDLOOP.

  join_wizard->p_join_data_r->set_info( EXPORTING it_dban = it_dban ).

  join_wizard->lv_key_select = lv_key_select.

  LOOP AT it_join_condition INTO wa_join_condition WHERE lv_key_select = lv_key_select.
    CONCATENATE     wa_join_condition-left wa_join_condition-right INTO itext_t SEPARATED BY space.
    APPEND itext_t.
  ENDLOOP.

  LOOP AT it_where INTO wa_where.
    itext_t = wa_where-expression.
    APPEND itext_t.
  ENDLOOP.

  CALL METHOD text_editor_top->set_text_as_r3table
    EXPORTING
      table  = itext_t[]
    EXCEPTIONS
      OTHERS = 1.

  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 4
      height = '0'.
  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 1
      height = '0'.
  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 2
      height = '0'.

  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 5
      height = '200'.

  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 3
      height = '30'.

  CALL METHOD splitter3->set_row_height
    EXPORTING
      id     = 1
      height = '10'.

  PERFORM transport_text.

ENDFORM. " FLY

*&---------------------------------------------------------------------*
*&      Form  JOIN_WIZARD_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM join_wizard_exit .

  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 4
      height = '0'.
  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 1
      height = '35'.
  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 2
      height = '35'.

  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 5
      height = '0'.

  CALL METHOD splitter->set_row_height
    EXPORTING
      id     = 3
      height = '40'.

  CALL METHOD splitter3->set_row_height
    EXPORTING
      id     = 1
      height = '10'.


ENDFORM. " JOIN_WIZARD_EXIT

*&---------------------------------------------------------------------*
*&      Form  recalc_cwidth_opt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ALV_GRID   text
*----------------------------------------------------------------------*
FORM recalc_cwidth_opt USING alv_grid TYPE REF TO cl_gui_alv_grid.

  DATA layout   TYPE lvc_s_layo.

  CALL METHOD alv_grid->get_frontend_layout
    IMPORTING
      es_layout = layout.

  layout-cwidth_opt = 'X'.

  CALL METHOD alv_grid->set_frontend_layout
    EXPORTING
      is_layout = layout.
ENDFORM.                    "recalc_cwidth_opt

*Messages
*----------------------------------------------------------
*
* Message class: AQQIS_CNTRL
*001   ######## ########.
*002   ########## ## #######.
*003   ###### ########## ## #######
*004   ########## ###### ######## ### ####### Left-outer
*005   ####### ############## ###### # ###### #########
*006   ###### ## #######
*007   ######## ######### ########
*008   ######### ######: &1 &2 &3 &4
*010   ####### &1 ### ############
*011   ####### ######### ########## # QuickViewer ####### ###### ##########
*012   ###### ###
*013   #### ###### #### #######
*014   ###############: &1 %
*015   ############ ####### ######### ########## #########
*016   ####### &1 ###### #### ###### ######## # ######### ##########
*017   ######## ######## ## ######### ##### ######### ##########
*018   #### &1 ####### ########
*019   ########## ###### ### ######## ##### jpg
*020   ########### ####### ########## Left-outer ##### ######### &1, &2 # &3
*021   &1 ## ##### ########### # ##### ######### ########. ########## Left-outer
*022   ######### #### &1 # &2 ##########
*023   ########## - ######: &1
*024   ######## ###### ## ######.
*025   ######### ###### ###
*026   ####### &1 ## ########
*027   ######### ####: &1
*028   &1 - ### ########## ####
*033   ## ##### ###### ####### ## ########.
*034   ######## ###### ##### ###### #######.
*035   ############ ####### ##########
*036   ########## (Left-Outer) ##### ########## ######.
*