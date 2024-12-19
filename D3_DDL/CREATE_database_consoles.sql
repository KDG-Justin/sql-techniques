DROP TABLE bedrijf CASCADE CONSTRAINTS;

DROP TABLE console CASCADE CONSTRAINTS;

DROP TABLE klant CASCADE CONSTRAINTS;

DROP TABLE klantorder CASCADE CONSTRAINTS;

DROP TABLE levering CASCADE CONSTRAINTS;

DROP TABLE orderlijn CASCADE CONSTRAINTS;

DROP TABLE werknemer CASCADE CONSTRAINTS;

DROP TABLE winkel CASCADE CONSTRAINTS;


CREATE TABLE bedrijf
(
    bedrijfid         NUMBER GENERATED ALWAYS AS IDENTITY,
    naam              VARCHAR2(50),
    bedrijf_adres     VARCHAR2(50),
    bedrijf_land      VARCHAR2(30),
    console_consoleid NUMBER NOT NULL
);

ALTER TABLE bedrijf
    ADD CONSTRAINT bedrijf_pk PRIMARY KEY (bedrijfid,
                                           console_consoleid);
CREATE TABLE console
(
    consoleid   NUMBER GENERATED ALWAYS AS IDENTITY,
    consolenaam VARCHAR2(50),
    prijs       NUMBER,
    release     DATE,
    CONSTRAINT ch_prijs CHECK ( prijs BETWEEN 50 AND 900)


);

ALTER TABLE console
    ADD CONSTRAINT console_pk PRIMARY KEY (consoleid);

CREATE TABLE klant
(
    klantid     NUMBER GENERATED ALWAYS AS IDENTITY,
    naam        VARCHAR2(50),
    leeftijd    NUMBER,
    klant_adres VARCHAR2(50),
    CONSTRAINT ch_leeftijd CHECK ( leeftijd > 16 )
);

ALTER TABLE klant
    ADD CONSTRAINT klant_pk PRIMARY KEY (klantid);

CREATE TABLE klantorder
(
    orderid          NUMBER GENERATED ALWAYS AS IDENTITY,
    klant_klantid    NUMBER NOT NULL,
    winkel_winkel_id NUMBER NOT NULL,
    prijs            NUMBER,
    order_datum      DATE NOT NULL
);

ALTER TABLE klantorder
    ADD CONSTRAINT klantorder_pk PRIMARY KEY (orderid,
                                              winkel_winkel_id,
                                              klant_klantid , order_datum);

CREATE TABLE levering
(
    leveringsnummer   NUMBER GENERATED ALWAYS AS IDENTITY,
    levering_adres    VARCHAR2(50),
    totale_prijs      NUMBER,
    leveringsdatum    DATE   NOT NULL,
    console_consoleid NUMBER NOT NULL,
    winkel_winkel_id  NUMBER NOT NULL
);

ALTER TABLE levering
    ADD CONSTRAINT levering_pk PRIMARY KEY (leveringsnummer,
                                            console_consoleid,
                                            winkel_winkel_id);

CREATE TABLE orderlijn
(
    orderlijnid          NUMBER GENERATED ALWAYS AS IDENTITY,
    console_consolenaam  VARCHAR2(50),
    aantal               NUMBER,
    prijs                NUMBER,
    klantorder_winkel_id NUMBER NOT NULL,
    klantorder_klantid   NUMBER NOT NULL,
    klantorder_orderid   NUMBER NOT NULL,
    constraint ch_aantal CHECK ( aantal < 4 )

);

ALTER TABLE orderlijn
    ADD CONSTRAINT orderlijn_pk PRIMARY KEY (orderlijnid,
                                             klantorder_orderid,
                                             klantorder_winkel_id,
                                             klantorder_klantid);

CREATE TABLE werknemer
(
    werknemer_id         NUMBER GENERATED ALWAYS AS IDENTITY,
    werknemer_voornaam   VARCHAR2(50),
    werknemer_achternaam VARCHAR2(50),
    is_manager           VARCHAR2(6),
    winkel_winkel_id     NUMBER NOT NULL
);

ALTER TABLE werknemer
    ADD CONSTRAINT werknemer_pk PRIMARY KEY (werknemer_id,
                                             winkel_winkel_id);

CREATE TABLE winkel
(
    winkel_id       NUMBER GENERATED ALWAYS AS IDENTITY,
    winkel_naam     VARCHAR2(50),
    winkel_email    VARCHAR2(50),
    stock           NUMBER,
    winkel_adres    VARCHAR2(50),
    winkel_telefoon VARCHAR2(50),
    CONSTRAINT ch_winkel_email CHECK ( winkel_email LIKE '%@%')
);

ALTER TABLE winkel
    ADD CONSTRAINT unique_email UNIQUE (winkel_email);
ALTER TABLE winkel
    ADD CONSTRAINT winkel_pk PRIMARY KEY (winkel_id);

ALTER TABLE bedrijf
    ADD CONSTRAINT bedrijf_console_fk FOREIGN KEY (console_consoleid)
        REFERENCES console (consoleid);

ALTER TABLE klantorder
    ADD CONSTRAINT klantorder_klant_fk FOREIGN KEY (klant_klantid)
        REFERENCES klant (klantid);

ALTER TABLE klantorder
    ADD CONSTRAINT klantorder_winkel_fk FOREIGN KEY (winkel_winkel_id)
        REFERENCES winkel (winkel_id);

ALTER TABLE levering
    ADD CONSTRAINT levering_console_fk FOREIGN KEY (console_consoleid)
        REFERENCES console (consoleid);

ALTER TABLE levering
    ADD CONSTRAINT levering_winkel_fk FOREIGN KEY (winkel_winkel_id)
        REFERENCES winkel (winkel_id);

ALTER TABLE orderlijn
    ADD CONSTRAINT orderlijn_klantorder_fk FOREIGN KEY (klantorder_orderid,
                                                        klantorder_winkel_id,
                                                        klantorder_klantid)
        REFERENCES klantorder (orderid,
                               winkel_winkel_id,
                               klant_klantid);

ALTER TABLE werknemer
    ADD CONSTRAINT werknemer_winkel_fk FOREIGN KEY (winkel_winkel_id)
        REFERENCES winkel (winkel_id);