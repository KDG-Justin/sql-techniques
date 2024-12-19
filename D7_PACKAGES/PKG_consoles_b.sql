CREATE
    OR REPLACE PACKAGE BODY PKG_consoles
AS
    TYPE console_array IS VARRAY(10) OF VARCHAR2(50);
    TYPE winkel_array IS VARRAY(10) OF VARCHAR2(50);
    TYPE adres_array IS VARRAY(10) OF VARCHAR2(100);
    TYPE klant_array IS VARRAY(15) OF VARCHAR2(50);

    -- Bulk data
    TYPE type_winkels IS TABLE OF winkel%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE type_winkeladres IS TABLE OF winkel.winkel_adres%TYPE
        INDEX BY PLS_INTEGER;
    TYPE type_klantorder IS TABLE OF klantorder%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE type_orderlijn IS TABLE OF orderlijn%ROWTYPE INDEX BY PLS_INTEGER;


    -- PRIVATE FUNCTIES
    -- lookup functies
    FUNCTION lookup_console(console_name IN VARCHAR2)
        RETURN NUMBER
        IS
        console_id NUMBER;
    BEGIN
        SELECT consoleid
        INTO console_id
        FROM console
        WHERE consolenaam = console_name;
        RETURN console_id;
    END lookup_console;

    FUNCTION lookup_winkel_naam(winkelnaam IN VARCHAR2)
        RETURN NUMBER
        IS
        winkelid NUMBER;
    BEGIN
        SELECT winkel_id
        INTO winkelid
        FROM winkel
        WHERE winkel_naam = winkelnaam;
        RETURN winkelid;
    END lookup_winkel_naam;

    FUNCTION lookup_winkel_adres(winkeladres IN VARCHAR2)
        RETURN NUMBER
        IS
        winkelid NUMBER;
    BEGIN
        SELECT winkel_id
        INTO winkelid
        FROM winkel
        WHERE winkel_adres = winkeladres;
        RETURN winkelid;
    END lookup_winkel_adres;

    FUNCTION lookup_winkel_id(winkelid IN NUMBER)
        RETURN VARCHAR2
        IS
        winkeladres VARCHAR2(100);
    BEGIN
        SELECT winkel_adres
        INTO winkeladres
        FROM winkel
        WHERE winkelid = WINKEL_ID;
        RETURN winkeladres;
    END lookup_winkel_id;

    FUNCTION lookup_klant(klant_naam IN VARCHAR2)
        RETURN NUMBER
        IS
        klant_id NUMBER;
    BEGIN
        SELECT klantid
        INTO klant_id
        FROM klant
        WHERE NAAM = klant_naam;
        RETURN klant_id;
    END lookup_klant;

    FUNCTION lookup_klant_id(klant_id IN NUMBER)
        RETURN VARCHAR2
        IS
        klantnaam VARCHAR2(50);
    BEGIN
        SELECT naam
        INTO klantnaam
        FROM klant
        WHERE KLANTID = klant_id;
        RETURN klantnaam;
    END lookup_klant_id;

    FUNCTION lookup_klantorder(klant_naam IN VARCHAR2, winkeladres IN VARCHAR2, orderdatum IN DATE)
        RETURN NUMBER
        IS
        klant_id      NUMBER;
        winkel_id     NUMBER;
        klantorder_id NUMBER;
    BEGIN
        -- klantid ophalen door lookup functie
        klant_id := lookup_klant(klant_naam);

        -- winkelid ophalen door lookup functie
        winkel_id := lookup_winkel_adres(winkeladres);

        SELECT orderid
        INTO klantorder_id
        FROM klantorder
        WHERE klant_klantid = klant_id
          AND winkel_winkel_id = winkel_id
          AND order_datum = orderdatum;
        RETURN klantorder_id;
    END lookup_klantorder;



    -- random data functies
    FUNCTION random_number(p_min IN NUMBER, p_max IN NUMBER)
        RETURN NUMBER
        IS
        v_random_number NUMBER;
    BEGIN
        v_random_number := TRUNC(dbms_random.VALUE(p_min, p_max));
        RETURN v_random_number;
    END random_number;

    FUNCTION random_date(p_begin IN DATE, p_end IN DATE)
        RETURN DATE
        IS
        v_days        NUMBER;
        v_random_date DATE;
    BEGIN
        v_days := random_number(0, p_end - p_begin);
        v_random_date := p_begin + v_days;
        RETURN v_random_date;
    END random_date;

    FUNCTION random_console
        RETURN VARCHAR2
        IS
        v_consoleslijst console_array := console_array('Xbox series x',
                                                       'Nintendo Switch',
                                                       'Steam Deck', 'Playstation 4',
                                                       'Playstation 5');
        v_randomNummer  NUMBER        := random_number(1, v_consoleslijst.COUNT);
    BEGIN
        RETURN v_consoleslijst(v_randomNummer);
    END random_console;

    FUNCTION amount_winkels
        RETURN NUMBER
        IS
        v_nummer NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_nummer FROM WINKEL;
        RETURN v_nummer;
    END amount_winkels;

    FUNCTION random_winkel_naam
        RETURN VARCHAR2
        IS
        v_winkel_naam VARCHAR2(50);
        v_index       NUMBER;
    BEGIN
        v_index := amount_winkels();
        v_winkel_naam := 'winkel' || v_index;
        RETURN v_winkel_naam;
    END random_winkel_naam;

    FUNCTION random_winkel_adres
        RETURN VARCHAR2
        IS
        v_adres_lijst  ADRES_ARRAY := ADRES_ARRAY('Keyserlei 7 2000', 'Frankrijklei 28 2000',
                                                  'Huidevetterstraat 2 2000', 'Italielei 44 2000',
                                                  'Meir 100 2000', 'Meir 23 2000');
        v_randomNummer NUMBER;
    BEGIN
        v_randomNummer := random_number(1, v_adres_lijst.COUNT);
        RETURN v_adres_lijst(v_randomNummer);
    END random_winkel_adres;

    FUNCTION random_klant_name
        RETURN VARCHAR2
        IS
        v_klant_lijst  klant_array := klant_array('Sophie Vandenberghe', 'Tom Verstraeten',
                                                  'Lise De Vries', 'Karen Willems', 'Bob Debower', 'Josse Rhar',
                                                  'Oude Man', 'Kevin Durant');
        v_randomNummer NUMBER;
    BEGIN
        v_randomNummer := random_number(1, v_klant_lijst.COUNT);
        RETURN v_klant_lijst(v_randomNummer);
    END random_klant_name;

    FUNCTION timestamp_diff(a timestamp, b timestamp)
        RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT (day    from (a-b))*24*60*60 +
               EXTRACT (hour   from (a-b))*60*60+
               EXTRACT (minute from (a-b))*60+
               EXTRACT (second from (a-b));
    END;


    -- DDL insert 1 row
    PROCEDURE add_console(p_consolenaam console.consolenaam%TYPE,
                          p_prijs console.prijs%TYPE,
                          p_release console.release%TYPE
    )
    AS
    BEGIN
        INSERT INTO console (consolenaam, prijs, release)
        VALUES (p_consolenaam, p_prijs, p_release);
        COMMIT;
    END add_console;

    PROCEDURE add_winkel(p_winkel_naam winkel.winkel_naam%TYPE,
                         p_winkel_email winkel.winkel_email%TYPE,
                         p_stock winkel.stock%TYPE,
                         p_winkel_adres winkel.winkel_adres%TYPE,
                         p_winkel_telefoon winkel.winkel_telefoon%TYPE)
    AS
    BEGIN
        INSERT INTO winkel (winkel_naam, winkel_email, stock, winkel_adres, winkel_telefoon)
        VALUES (p_winkel_naam, p_winkel_email, p_stock, p_winkel_adres, p_winkel_telefoon);
        COMMIT;
    END add_winkel;

    PROCEDURE add_klant(p_naam klant.naam%TYPE,
                        p_leeftijd klant.leeftijd%TYPE,
                        p_klant_adres klant.klant_adres%TYPE)
    AS
    BEGIN
        INSERT INTO klant(naam, leeftijd, klant_adres)
        VALUES (p_naam, p_leeftijd, p_klant_adres);
        COMMIT;
    END add_klant;

    PROCEDURE add_bedrijf(
        p_naam bedrijf.naam%TYPE,
        p_bedrijf_adres bedrijf.bedrijf_adres%TYPE,
        p_bedrijf_land bedrijf.bedrijf_land%TYPE,
        p_console_name console.consolenaam%TYPE)
    AS
        v_console_id NUMBER;
    BEGIN
        v_console_id := lookup_console(p_console_name); -- gebruik de lookup_console() functie om de id van de console te krijgen
        INSERT INTO bedrijf (naam, bedrijf_adres, bedrijf_land, console_consoleid)
        VALUES (p_naam,
                p_bedrijf_adres,
                p_bedrijf_land,
                v_console_id);
        COMMIT;
    END add_bedrijf;

    PROCEDURE add_werknemer(p_werknemer_voornaam werknemer.werknemer_voornaam%TYPE,
                            p_werknemer_achternaam werknemer.werknemer_achternaam%TYPE,
                            p_is_manager werknemer.is_manager%TYPE,
                            p_winkel_adres winkel.winkel_adres%TYPE)
    AS
        v_winkel_id NUMBER;
    BEGIN
        v_winkel_id := lookup_winkel_adres(p_winkel_adres);
        INSERT INTO werknemer(werknemer_voornaam, werknemer_achternaam, is_manager, winkel_winkel_id)
        VALUES (p_werknemer_voornaam, p_werknemer_achternaam, p_is_manager, v_winkel_id);
        COMMIT;
    END add_werknemer;

    PROCEDURE add_levering(p_levering_adres levering.levering_adres%TYPE,
                           p_totale_prijs levering.totale_prijs%TYPE,
                           p_leveringsdatum levering.leveringsdatum%TYPE,
                           p_console_naam console.consolenaam%TYPE,
                           p_winkel_adres winkel.winkel_adres%TYPE)
    AS
        v_console_id NUMBER;
        v_winkel_id  NUMBER;
    BEGIN
        v_console_id := lookup_console(p_console_naam);
        v_winkel_id := lookup_winkel_adres(p_winkel_adres);
        INSERT INTO levering(levering_adres, totale_prijs, leveringsdatum, console_consoleid, winkel_winkel_id)
        VALUES (p_levering_adres, p_totale_prijs, p_leveringsdatum, v_console_id, v_winkel_id);
        COMMIT;
    END add_levering;

    PROCEDURE add_klantorder(
        p_klant_naam klant.naam%TYPE,
        p_winkel_adres winkel.winkel_adres%TYPE,
        p_prijs klantorder.prijs%TYPE,
        p_order_datum klantorder.order_datum%TYPE)
    AS
        v_klant_id  NUMBER;
        v_winkel_id NUMBER;
    BEGIN
        v_klant_id := lookup_klant(p_klant_naam);
        v_winkel_id := lookup_winkel_adres(p_winkel_adres);
        INSERT INTO klantorder(klant_klantid, winkel_winkel_id, prijs, order_datum)
        VALUES (v_klant_id, v_winkel_id, p_prijs, p_order_datum);
        COMMIT;
    END add_klantorder;

    PROCEDURE add_orderlijn(
        p_console_consolenaam orderlijn.console_consolenaam%TYPE,
        p_aantal orderlijn.aantal%TYPE,
        p_prijs orderlijn.prijs%TYPE,
        p_winkel_adres winkel.winkel_adres%TYPE,
        p_klant_naam klant.naam%TYPE,
        p_klantorder_datum klantorder.order_datum%TYPE)
    AS
        v_winkel_id     NUMBER;
        v_klant_id      NUMBER;
        v_klantorder_id NUMBER;
    BEGIN
        v_winkel_id := lookup_winkel_adres(p_winkel_adres);
        v_klant_id := lookup_klant(p_klant_naam);
        v_klantorder_id := lookup_klantorder(p_klant_naam, p_winkel_adres, p_klantorder_datum);
        INSERT INTO orderlijn(console_consolenaam, aantal, prijs, klantorder_winkel_id, klantorder_klantid,
                              klantorder_orderid)
        VALUES (p_console_consolenaam, p_aantal, p_prijs, v_winkel_id, v_klant_id, v_klantorder_id);
        COMMIT;
    END add_orderlijn;


    -- random rows generatie functies
    PROCEDURE generate_random_consoles(p_amount NUMBER)
    AS
    BEGIN
        FOR i IN 1..p_amount
            LOOP
                add_console(
                            random_console() || ' Type ' || i,
                            random_number(50, 900),
                            random_date(TO_DATE('2020-01-01', 'YYYY-MM-DD'), TO_DATE('2022-01-31', 'YYYY-MM-DD'))
                    );
            END LOOP;
    END generate_random_consoles;

    PROCEDURE generate_random_winkels(p_amount NUMBER)
    AS
    BEGIN
        FOR i IN 1..p_amount
            LOOP
                add_winkel(
                        random_winkel_naam(),
                        random_winkel_naam() || '@gmail.com',
                        random_number(0, 100),
                        'Meir ' || random_number(101, 9999) || ' 2000',
                        '03' || random_number(1000000, 9999999)
                    );
            END LOOP;
    END generate_random_winkels;

    PROCEDURE generate_leveringen(p_amount NUMBER)
    AS
        v_adres VARCHAR2(100);
    BEGIN
        FOR i IN 1..p_amount
            LOOP
                v_adres := random_winkel_adres();
                add_levering(
                        v_adres,
                        random_number(400, 9999),
                        random_date(TO_DATE('2023-03-01', 'YYYY-MM-DD'), TO_DATE('2023-03-31', 'YYYY-MM-DD')),
                        random_console(),
                        v_adres
                    );
            END LOOP;
    END generate_leveringen;

    PROCEDURE genereer_Veel_op_Veel(p_console_aantal NUMBER, p_winkel_aantal NUMBER, p_levering_aantal NUMBER)
    AS
        v_begin DATE;
        v_end   DATE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('4 - starting MANY-TO-MANY generation: genereer_Veel_op_Veel(20,20,50)');
        v_begin := SYSDATE;
        DBMS_OUTPUT.PUT_LINE('4.1 - generate_random_consoles(20)');
        generate_random_consoles(p_console_aantal);

        DBMS_OUTPUT.PUT_LINE('4.2 - generate_random_winkels(20)');
        generate_random_winkels(p_winkel_aantal);
        DBMS_OUTPUT.PUT_LINE('4.3 - generate_leveringen(50)');
        generate_leveringen(p_levering_aantal);
        v_end := SYSDATE;
        DBMS_OUTPUT.PUT_LINE('The duration of the MANY-TO-MANY generation: ' || (v_end - v_begin) * 24 * 60 * 60 ||
                             ' seconds.');
    END genereer_Veel_op_Veel;

    PROCEDURE generate_klantorders(p_amount NUMBER)
    AS
        TYPE type_winkeladres IS TABLE OF winkel.winkel_adres%TYPE
            INDEX BY PLS_INTEGER;
        t_winkel_adres type_winkeladres;
        v_counter      NUMBER := 0;
        v_klant_naam   VARCHAR2(50);
    BEGIN
        SELECT winkel_adres BULK COLLECT INTO t_winkel_adres FROM WINKEL;
        FOR i IN 1..t_winkel_adres.COUNT
            LOOP
                FOR j IN 1..p_amount
                    LOOP
                        v_klant_naam := random_klant_name();
                        add_klantorder(
                                v_klant_naam,
                                t_winkel_adres(i),
                                random_number(210, 2000),
                                random_date(to_date('4-12-2017', 'DD/MM/YYYY'), to_date('11-05-2023', 'DD/MM/YYYY'))
                            );
                        v_counter := v_counter + 1;
                    END LOOP;
            END LOOP;
        DBMS_OUTPUT.PUT_LINE('generate_klantorders(40): ' || v_counter || ' rows.');
    END generate_klantorders;

    PROCEDURE generate_orderlijnen(p_amount NUMBER)
    AS
        TYPE type_klantorders IS TABLE OF KLANTORDER%ROWTYPE
            INDEX BY PLS_INTEGER;
        t_klantorders type_klantorders;
        v_counter     NUMBER := 0;
        v_aantal NUMBER;
        v_prijs NUMBER;
        v_consolenaam VARCHAR2(50);
    BEGIN
        SELECT * BULK COLLECT
        INTO t_klantorders
        FROM klantorder;

        FOR i IN 6..t_klantorders.COUNT
            LOOP
                FOR j IN 1..p_amount
                    LOOP
                    v_consolenaam := random_console();
                    v_aantal := random_number(1, 4);
                    v_prijs := random_number(50, 900);
                        insert into ORDERLIJN(console_consolenaam, aantal, prijs, klantorder_winkel_id, klantorder_klantid, klantorder_orderid)
                        VALUES (v_consolenaam,v_aantal,v_prijs,
                                t_klantorders(i).WINKEL_WINKEL_ID,
                                t_klantorders(i).KLANT_KLANTID,
                                t_klantorders(i).ORDERID);
                        v_counter := v_counter + 1;
                    END LOOP;
            END LOOP;
        DBMS_OUTPUT.PUT_LINE('generate_orderlijnen(50): ' || v_counter || ' rows.');
    END generate_orderlijnen;

    PROCEDURE generate_2_levels(p_klantorder_amount NUMBER, p_orderlijn_amount NUMBER)
    AS
        v_begin TIMESTAMP;
        v_end   TIMESTAMP;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('GENERATE_2_LEVELS(' || p_klantorder_amount || ',' || p_orderlijn_amount || ');');
        v_begin := SYSTIMESTAMP;
        generate_klantorders(p_klantorder_amount);
        generate_orderlijnen(p_orderlijn_amount);
        v_end := SYSTIMESTAMP;
        DBMS_OUTPUT.PUT_LINE('The duration of the 2 level generation: ' || timestamp_diff(v_end, v_begin) ||
                             ' seconds.');
    END generate_2_levels;



    -- DDL functies generatie bulk
    PROCEDURE add_winkel_bulk(p_winkels IN type_winkels)
    AS
    BEGIN
        FORALL i IN p_winkels.FIRST..p_winkels.LAST
            INSERT INTO winkel(winkel_naam, winkel_email, stock, winkel_adres, winkel_telefoon)
            VALUES(p_winkels(i).winkel_naam, p_winkels(i).winkel_email, p_winkels(i).stock, p_winkels(i).winkel_adres, p_winkels(i).winkel_telefoon);
        COMMIT;
    END add_winkel_bulk;

    PROCEDURE add_klantorder_bulk(p_orders IN type_klantorder)
    AS
        v_begin TIMESTAMP;
        v_end TIMESTAMP;
    BEGIN
        v_begin := SYSTIMESTAMP;
        FORALL i IN p_orders.FIRST..p_orders.LAST
            INSERT INTO klantorder(klant_klantid, winkel_winkel_id, prijs, order_datum)
            VALUES(p_orders(i).KLANT_KLANTID, p_orders(i).WINKEL_WINKEL_ID, p_orders(i).PRIJS, p_orders(i).ORDER_DATUM);
        COMMIT;
        v_end := SYSTIMESTAMP;
    END add_klantorder_bulk;

    PROCEDURE add_orderlijn_bulk(p_orderlijnen IN type_orderlijn)
    AS
    BEGIN
        FORALL i IN p_orderlijnen.FIRST..p_orderlijnen.LAST
            INSERT INTO orderlijn(console_consolenaam, aantal, prijs, klantorder_winkel_id, klantorder_klantid, klantorder_orderid)
            VALUES(p_orderlijnen(i).CONSOLE_CONSOLENAAM, p_orderlijnen(i).AANTAL, p_orderlijnen(i).PRIJS, p_orderlijnen(i).KLANTORDER_WINKEL_ID, p_orderlijnen(i).KLANTORDER_KLANTID, p_orderlijnen(i).KLANTORDER_ORDERID);
        COMMIT;
    END add_orderlijn_bulk;

    PROCEDURE generate_winkels_bulk(p_amount NUMBER)
    AS
        v_winkels type_winkels;
    BEGIN
        FOR i IN 1..p_amount LOOP
                v_winkels(i).winkel_naam := random_winkel_naam();
                v_winkels(i).winkel_email := v_winkels(i).winkel_naam || '@gmail.com';
                v_winkels(i).stock := random_number(0, 100);
                v_winkels(i).winkel_adres := 'Meir ' || random_number(101, 9999) || ' 2000';
                v_winkels(i).winkel_telefoon := '03' || random_number(1000000, 9999999);
            END LOOP;
        add_winkel_bulk(v_winkels);
    END generate_winkels_bulk;

    PROCEDURE generate_klantorders_bulk(p_amount NUMBER)
    AS
        v_orders type_klantorder;
        v_winkels type_winkels;
        v_counter NUMBER;
        v_begin TIMESTAMP;
        v_end TIMESTAMP;
    BEGIN
        SELECT * BULK COLLECT INTO v_winkels FROM WINKEL;
        v_counter := 0;
        v_begin := SYSTIMESTAMP;
        FOR i IN 1..v_winkels.COUNT LOOP
                FOR j IN 1..p_amount LOOP
                        v_orders(j).KLANT_KLANTID := random_number(1, 9);
                        v_orders(j).WINKEL_WINKEL_ID := v_winkels(i).WINKEL_ID;
                        v_orders(j).PRIJS :=  random_number(210, 2000);
                        v_orders(j).ORDER_DATUM := random_date(to_date('4-12-2015', 'DD/MM/YYYY'), to_date('14-05-2023', 'DD/MM/YYYY'));
                        v_counter := v_counter + 1;
                    END LOOP;
                add_klantorder_bulk(v_orders);
            END LOOP;
        v_end := SYSTIMESTAMP;
        DBMS_OUTPUT.PUT_LINE('generate_klantorder(40): ' || v_counter || ' rows.');
        --DBMS_OUTPUT.PUT_LINE('BULK: table orderlijnen ready for insert (' || timestamp_diff(v_end, v_begin) ||' seconds)');
    END generate_klantorders_bulk;

    PROCEDURE generate_orderlijnen_bulk(p_amount NUMBER)
    AS
        TYPE type_klantorders IS TABLE OF KLANTORDER%ROWTYPE
            INDEX BY PLS_INTEGER;
        t_klantorders type_klantorders;
        t_orderlijnen type_orderlijn;
        v_counter     NUMBER := 0;
        v_aantal NUMBER;
        v_prijs NUMBER;
        v_consolenaam VARCHAR2(50);
        v_begin TIMESTAMP;
        v_end TIMESTAMP;
        v_duration TIMESTAMP;
        v_duration2 TIMESTAMP;
        v_verschil NUMBER;
        v_verschil2 NUMBER;
    BEGIN
        v_verschil := 0;
        v_verschil2 := 0;
        SELECT * BULK COLLECT INTO t_klantorders FROM klantorder;
        SELECT * BULK COLLECT INTO t_orderlijnen FROM ORDERLIJN;


        FOR i IN 6..t_klantorders.COUNT LOOP
                v_begin := SYSTIMESTAMP;
                FOR j IN 1..p_amount LOOP

                        v_consolenaam := random_console();
                        v_aantal := random_number(1, 4);
                        v_prijs := random_number(50, 900);
                        t_orderlijnen(j).CONSOLE_CONSOLENAAM := v_consolenaam;
                        t_orderlijnen(j).AANTAL := v_aantal;
                        t_orderlijnen(j).PRIJS := v_prijs;
                        t_orderlijnen(j).KLANTORDER_WINKEL_ID := t_klantorders(i).WINKEL_WINKEL_ID;
                        t_orderlijnen(j).KLANTORDER_KLANTID := t_klantorders(i).KLANT_KLANTID;
                        t_orderlijnen(j).KLANTORDER_ORDERID := t_klantorders(i).ORDERID;
                        v_counter := v_counter + 1;
                    END LOOP;
                v_end := SYSTIMESTAMP;
                v_verschil2 := v_verschil2 + timestamp_diff(v_end, v_begin);

                v_duration := SYSTIMESTAMP;
                add_orderlijn_bulk(t_orderlijnen);
                v_duration2 := SYSTIMESTAMP;
            v_verschil := v_verschil + timestamp_diff(v_duration2, v_duration);
            END LOOP;

        DBMS_OUTPUT.PUT_LINE('BULK: table orderlijnen ready for insert (' || v_verschil2 ||' seconds)');
        DBMS_OUTPUT.PUT_LINE('BULK: table t_orderlijnen inserted (' || v_verschil ||' seconds)');
        DBMS_OUTPUT.PUT_LINE('generate_orderlijnen('|| p_amount || ') ' || v_counter || ' rows.');
    END generate_orderlijnen_bulk;

    PROCEDURE generate_2_levels_bulk(p_klantorder_amount NUMBER, p_orderlijn_amount NUMBER)
    AS
        v_begin TIMESTAMP;
        v_end   TIMESTAMP;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('GENERATE_2_LEVELS_BULK(' || p_klantorder_amount || ',' || p_orderlijn_amount || ');');
        v_begin := SYSTIMESTAMP; --timestamp
        generate_klantorders_bulk(p_klantorder_amount);
        generate_orderlijnen_bulk(p_orderlijn_amount);
        v_end := SYSTIMESTAMP;
        DBMS_OUTPUT.PUT_LINE('The duration of the 2 level generation bulk: ' || timestamp_diff(v_end, v_begin) ||
                             ' seconds.');
    END generate_2_levels_bulk;


    -- PUBLIEKE FUNCTIES --
    -- MILESTONE 4
    PROCEDURE reset_identity
    AS
    BEGIN
        EXECUTE IMMEDIATE 'ALTER TABLE ORDERLIJN
            MODIFY(ORDERLIJNID GENERATED AS IDENTITY (START WITH 1))';
        EXECUTE IMMEDIATE 'ALTER TABLE KLANTORDER
            MODIFY(ORDERID GENERATED AS IDENTITY (START WITH 1))';
        EXECUTE IMMEDIATE 'ALTER TABLE KLANT
            MODIFY(KLANTID GENERATED AS IDENTITY (START WITH 1))';
        EXECUTE IMMEDIATE 'ALTER TABLE WINKEL
            MODIFY(WINKEL_ID GENERATED AS IDENTITY (START WITH 1))';
        EXECUTE IMMEDIATE 'ALTER TABLE WERKNEMER
            MODIFY(WERKNEMER_ID GENERATED AS IDENTITY (START WITH 1))';
        EXECUTE IMMEDIATE 'ALTER TABLE CONSOLE
            MODIFY(CONSOLEID GENERATED AS IDENTITY (START WITH 1))';
        EXECUTE IMMEDIATE 'ALTER TABLE LEVERING
            MODIFY(LEVERINGSNUMMER GENERATED AS IDENTITY (START WITH 1))';
        EXECUTE IMMEDIATE 'ALTER TABLE BEDRIJF
            MODIFY(BEDRIJFID GENERATED AS IDENTITY (START WITH 1))';
        EXECUTE IMMEDIATE 'PURGE RECYCLEBIN';
    END reset_identity;

    PROCEDURE empty_tables
        IS
    BEGIN
        reset_identity();
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ORDERLIJN';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE KLANTORDER ';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE KLANT';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE WERKNEMER';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE LEVERING';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE WINKEL';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE BEDRIJF';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE CONSOLE';
    END empty_tables;

    PROCEDURE manuele_input_m4
    AS
    BEGIN
        ADD_CONSOLE('Xbox series x', 559, to_date('10-11-2020', 'DD/MM/YYYY'));
        ADD_CONSOLE('Nintendo Switch', 210, to_date('16-3-2017', 'DD/MM/YYYY'));
        ADD_CONSOLE('Steam Deck', 779, to_date('20-2-2022', 'DD/MM/YYYY'));
        ADD_CONSOLE('Playstation 4', 420, to_date('14-10-2017', 'DD/MM/YYYY'));
        ADD_CONSOLE('Playstation 5', 599, to_date('20-11-2020', 'DD/MM/YYYY'));
        ADD_BEDRIJF('Sony Belgium', 'Leonardo da Vincilaan 7 1920', 'België', 'Playstation 4');
        ADD_BEDRIJF('Sony', 'Konan Minato-ku 171 108', 'Japan', 'Playstation 5');
        ADD_BEDRIJF('Microsoft', 'Evert van de Beekstraat 354 1118', 'Nederland', 'Xbox series x');
        ADD_BEDRIJF('Valve', 'NE St 4th 10400', 'Amerika', 'Steam Deck');
        ADD_BEDRIJF('Nintendo', 'Ave. NE Redmond 150th 4600', 'Amerika', 'Nintendo Switch');
        ADD_WINKEL('MediaMarkt', 'mediamarkt@gmail.com', 50, 'Keyserlei 7 2000', '032241040');
        ADD_WINKEL('Gamemania', 'gamemania@gmail.com', 41, 'Frankrijklei 28 2000', '032273838');
        ADD_WINKEL('The Body Shop', 'thebodyshop@gmail.com', 30, 'Huidevetterstraat 2 2000', '032333444');
        ADD_WINKEL('JBC', 'jbcstore@gmail.com', 10, 'Italielei 44 2000', '032555666');
        ADD_WINKEL('H&M', 'hmstore@gmail.com', 3, 'Meir 100 2000', '032222111');
        ADD_WINKEL('Action', 'action@gmail.com', 0, 'Meir 23 2000', '037382946');
        ADD_LEVERING(('Keyserlei 7, 2000'), 559, to_date('9-03-2023', 'DD/MM/YYYY'), 'Xbox series x',
                     'Keyserlei 7 2000');
        ADD_LEVERING('Meir 100, 2000', 630, to_date('1-04-2023', 'DD/MM/YYYY'), 'Nintendo Switch',
                     'Meir 100 2000');
        ADD_LEVERING('Meir 100, 2000', 411, to_date('1-04-2023', 'DD/MM/YYYY'), 'Playstation 4',
                     'Meir 100 2000');
        ADD_LEVERING('Frankrijklei 28, 2000', 728, to_date('1-03-2023', 'DD/MM/YYYY'), 'Playstation 5',
                     'Frankrijklei 28 2000');
        ADD_LEVERING('Italielei 44, 2000', 1558, to_date('8-03-2023', 'DD/MM/YYYY'), 'Steam Deck',
                     'Italielei 44 2000');
        ADD_WERKNEMER('John', 'White', 'false', 'Keyserlei 7 2000');
        ADD_WERKNEMER('Walter', 'White', 'true', 'Keyserlei 7 2000');
        ADD_WERKNEMER('Filip', 'Smith', 'false', 'Frankrijklei 28 2000');
        ADD_WERKNEMER('Ella', 'Bord', 'false', 'Italielei 44 2000');
        ADD_WERKNEMER('Hafsa', 'Chanoef', 'false', 'Italielei 44 2000');
        ADD_KLANT('Sophie Vandenberghe', 27, 'Korte Altaarstraat 8 2100');
        ADD_KLANT('Tom Verstraeten', 43, 'Pelikaanstraat 78 1900');
        ADD_KLANT('Lise De Vries', 32, 'Oude Leeuwenrui 8 2020');
        ADD_KLANT('Karen Willems', 29, 'Brouwersvliet 23 2100');
        ADD_KLANT('Bob Debower', 17, 'Korte Altaarstraat 8 2060');
        ADD_KLANT('Josse Rhar', 20, 'Korte VoetStraat 9 2080');
        ADD_KLANT('Oude Man', 18, 'Heilige steen 23 1800');
        ADD_KLANT('Kevin Durant', 38, 'Keyserlei 1 2060');
        ADD_KLANTORDER('Sophie Vandenberghe', 'Frankrijklei 28 2000', 840,to_date('11-12-2020', 'DD/MM/YYYY'));
        ADD_KLANTORDER('Sophie Vandenberghe','Frankrijklei 28 2000', 420,to_date('20-6-2020', 'DD/MM/YYYY'));
        ADD_KLANTORDER('Karen Willems','Huidevetterstraat 2 2000', 210,to_date('2-4-2021', 'DD/MM/YYYY'));
        ADD_KLANTORDER('Bob Debower','Keyserlei 7 2000', 779,to_date('17-4-2023', 'DD/MM/YYYY'));
        ADD_KLANTORDER('Bob Debower','Keyserlei 7 2000', 559,to_date('4-12-2019', 'DD/MM/YYYY'));
        ADD_ORDERLIJN('PlayStation 4', 2, 840,'Frankrijklei 28 2000', 'Sophie Vandenberghe', to_date('11-12-2020', 'DD/MM/YYYY'));
        ADD_ORDERLIJN('Ninetendo Switch', 1, 210,'Huidevetterstraat 2 2000', 'Karen Willems', to_date('2-4-2021', 'DD/MM/YYYY'));
        ADD_ORDERLIJN('Nintendo Switch', 2, 420,'Frankrijklei 28 2000', 'Sophie Vandenberghe', to_date('20-6-2020', 'DD/MM/YYYY'));
        ADD_ORDERLIJN('Xbox series x', 1, 559,'Keyserlei 7 2000', 'Bob Debower', to_date('4-12-2019', 'DD/MM/YYYY'));
        ADD_ORDERLIJN('Steam Deck', 1, 779,'Keyserlei 7 2000', 'Bob Debower', to_date('17-4-2023', 'DD/MM/YYYY'));
    END manuele_input_m4;

    -- MILESTONE 5
    PROCEDURE bewijs_milestone_5
    AS
    BEGIN
        -- dbms output van nummer 1 tot 3 - 4 en 5 komen ergens anders
        DBMS_OUTPUT.PUT_LINE('1 - random nummer binnen een nummerberiek');
        DBMS_OUTPUT.PUT_LINE('  random_number(10, 30) --> ' || random_number(10, 30));
        DBMS_OUTPUT.PUT_LINE('2 - random datum binnen een bereik');
        DBMS_OUTPUT.PUT_LINE('  random_date(TO_DATE(2022-01-01, YYYY-MM-DD), TO_DATE(2022-02-20, YYYY-MM-DD)) --> ' ||
                             random_date(TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2022-02-20', 'YYYY-MM-DD')));
        DBMS_OUTPUT.PUT_LINE('3 - random console naam uit lijst');
        DBMS_OUTPUT.PUT_LINE('  random_console() --> ' || random_console());
        GENEREER_VEEL_OP_VEEL(20, 20, 50);
        DBMS_OUTPUT.PUT_LINE('generate_2_levels(p_klantorder = 40, p_klantorderlijn = 50)');
        DBMS_OUTPUT.PUT_LINE('WINKEL BEVAT AL 20 AANTALLEN! --> skip winkels');
        GENERATE_2_LEVELS(40, 50);


    END bewijs_milestone_5;

    -- MILESTONE 6
    PROCEDURE print_report_2_levels(p_winkel_amount NUMBER, p_klantorder_amount NUMBER, p_orderlijn_amount NUMBER)
    AS
        neg_exception EXCEPTION;

        CURSOR cur_winkel IS
            SELECT w.winkel_id, w.winkel_naam, w.winkel_adres, AVG(w.stock) AS gemiddelde_stock
            FROM winkel w
            GROUP BY w.winkel_id, w.winkel_naam, w.winkel_adres
                FETCH FIRST p_winkel_amount ROWS ONLY;

        CURSOR cur_klantorder (winkel_id IN NUMBER) IS
            SELECT ko.*, ROUND(AVG(ko.prijs)) AS gemiddelde_prijs, ROUND(AVG(ol.AANTAL)) AS gemiddelde_aantal
            FROM klantorder ko
                     JOIN orderlijn ol ON ko.orderid = ol.klantorder_orderid
            WHERE ko.winkel_winkel_id = winkel_id
            GROUP BY ko.orderid, ko.order_datum, ko.prijs, ko.klant_klantid, ko.winkel_winkel_id
                FETCH FIRST p_klantorder_amount ROWS ONLY;

        CURSOR cur_orderlijn (winkel_id IN NUMBER, klant_id IN NUMBER, order_id IN NUMBER) IS
            SELECT o.CONSOLE_CONSOLENAAM, o.AANTAL, o.PRIJS, AVG(o.AANTAL) AS gemiddelde_aantal
            FROM orderlijn o
            WHERE klantorder_winkel_id = winkel_id
              AND klantorder_klantid = klant_id
              AND klantorder_orderid = order_id
            GROUP BY o.CONSOLE_CONSOLENAAM, o.AANTAL, o.PRIJS
                FETCH FIRST p_orderlijn_amount ROWS ONLY;
    BEGIN
        IF p_winkel_amount < 0 OR p_klantorder_amount < 0 OR p_orderlijn_amount < 0 THEN
            RAISE neg_exception;
        END IF;
        FOR winkel_rec IN cur_winkel
            LOOP
                DBMS_OUTPUT.PUT_LINE('========================================================');
                DBMS_OUTPUT.PUT_LINE('| ' || winkel_rec.WINKEL_NAAM || ' | '|| winkel_rec.WINKEL_ADRES||'  --> Gemmiddelde stock: '|| winkel_rec.gemiddelde_stock);
                DBMS_OUTPUT.PUT_LINE('========================================================');
                FOR klantorder_rec IN cur_klantorder(winkel_rec.WINKEL_ID)
                    LOOP
                        EXIT WHEN cur_klantorder%NOTFOUND;
                        DBMS_OUTPUT.PUT_LINE('       Klantorder '||klantorder_rec.ORDERID ||'-----------------------------------   --> Gemmiddelde prijs: ' || klantorder_rec.gemiddelde_prijs);
                        --DBMS_OUTPUT.PUT_LINE('      | Order-Id |    | Datum |    | Totale prijs |   ');
                        DBMS_OUTPUT.PUT_LINE('      | ' || RPAD('Order-Id', 10) || ' | ' || RPAD('Datum', 10) || ' | ' || RPAD('Totale prijs', 14) || ' |');
                        --DBMS_OUTPUT.PUT_LINE('      | '|| klantorder_rec.ORDERID ||'        | '|| '   | '|| klantorder_rec.ORDER_DATUM || ' | ' ||'    | '|| klantorder_rec.PRIJS || ' |');
                        DBMS_OUTPUT.PUT_LINE('      | '|| RPAD(klantorder_rec.ORDERID, 10) || ' | ' || RPAD(klantorder_rec.ORDER_DATUM, 10) || ' | ' || RPAD(klantorder_rec.PRIJS, 14) || ' |');
                        DBMS_OUTPUT.PUT_LINE('       ------------------------------------------------');
                        DBMS_OUTPUT.PUT_LINE('          Orderlijnen   --> Gemmiddelde aantal: ' || klantorder_rec.gemiddelde_aantal);
                        DBMS_OUTPUT.PUT_LINE('          | ' || RPAD('CONSOLE', 15) || ' | ' ||
                                             '           ' || RPAD('AANTAL', 10) || ' | ' ||
                                             '           ' || RPAD('PRIJS', 10) || ' | ');
                        FOR orderlijn_rec IN cur_orderlijn(
                                             winkel_rec.winkel_id,
                                             klantorder_rec.klant_klantid,
                                             klantorder_rec.orderid)
                            LOOP
                                EXIT WHEN cur_orderlijn%NOTFOUND;
                                --DBMS_OUTPUT.PUT_LINE('          | ' || orderlijn_rec.CONSOLE_CONSOLENAAM || ' | '||'         | '|| orderlijn_rec.AANTAL || ' | '||'         | ' || orderlijn_rec.PRIJS || ' | ');
                                DBMS_OUTPUT.PUT_LINE('          | ' || RPAD(orderlijn_rec.CONSOLE_CONSOLENAAM, 15) || ' | ' ||
                                                     '           ' || RPAD(orderlijn_rec.AANTAL, 10) || ' | ' ||
                                                     '           ' || RPAD(orderlijn_rec.PRIJS, 10) || ' | ');

                            END LOOP;
                    END LOOP;
            END LOOP;
    EXCEPTION
        WHEN neg_exception THEN DBMS_OUTPUT.PUT_LINE('Parameters moeten groter dan 0 zijn!');
    END print_report_2_levels;

    -- MILESTONE 7
    PROCEDURE Comparison_Single_Bulk_M7(p_winkel_amount NUMBER, p_klantorder_amount NUMBER, p_orderlijn_amount NUMBER)
    AS
    BEGIN
        empty_tables();
        manuele_input_m4();
        generate_random_winkels(p_winkel_amount);
        generate_2_levels(p_klantorder_amount, p_orderlijn_amount);

        empty_tables();
        manuele_input_m4();
        generate_random_winkels(p_winkel_amount);
        generate_2_levels_bulk(p_klantorder_amount, p_orderlijn_amount);
    END Comparison_Single_Bulk_M7;
END PKG_consoles;