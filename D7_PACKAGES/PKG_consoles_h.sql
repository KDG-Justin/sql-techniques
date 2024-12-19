CREATE
    OR REPLACE PACKAGE PKG_consoles
AS

    PROCEDURE empty_tables;
    PROCEDURE manuele_input_m4;

    --MILESTONE 5
    PROCEDURE bewijs_milestone_5;

    --MILESTONE 6
    PROCEDURE print_report_2_levels(p_winkel_amount NUMBER, p_klantorder_amount NUMBER, p_orderlijn_amount NUMBER);

    --MILESTONE 7
    PROCEDURE Comparison_Single_Bulk_M7(p_winkel_amount NUMBER, p_klantorder_amount NUMBER, p_orderlijn_amount NUMBER);
END PKG_consoles;