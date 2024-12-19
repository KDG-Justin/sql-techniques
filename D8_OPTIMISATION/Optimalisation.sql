-- Milestone 8 optimalisatie
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS('PROJECT', 'winkel');
    DBMS_STATS.GATHER_TABLE_STATS('PROJECT', 'klantorder');
    DBMS_STATS.GATHER_TABLE_STATS('PROJECT', 'orderlijn');
end;

-- orderlijn
select segment_name,
       segment_type,
       sum(bytes / 1024 / 1024)            MB,
       (select COUNT(*) FROM orderlijn) as table_count
from dba_segments
where segment_name = 'ORDERLIJN'
group by segment_name, segment_type;


DROP TABLE ORDERLIJN; --CASCADE CONSTRAINTS
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


)
    PARTITION BY RANGE (prijs)
(
    -- interval werkt niet
    PARTITION prijs_100 VALUES LESS THAN (100),
    PARTITION prijs_200 VALUES LESS THAN (200),
    PARTITION prijs_300 VALUES LESS THAN (300),
    PARTITION prijs_400 VALUES LESS THAN (400),
    PARTITION prijs_500 VALUES LESS THAN (500),
    PARTITION prijs_600 VALUES LESS THAN (600),
    PARTITION prijs_700 VALUES LESS THAN (700),
    PARTITION prijs_800 VALUES LESS THAN (800),
    PARTITION prijs_900 VALUES LESS THAN (MAXVALUE)
);


-- Ik wil een overzicht van de klanten waarbij we de prijs van de orderlijnen zien die tussen 650 en 850 euro zijn
SELECT W.WINKEL_NAAM, K.NAAM, O.AANTAL, O.CONSOLE_CONSOLENAAM, o.prijs
FROM WINKEL W
         JOIN KLANTORDER KO on W.WINKEL_ID = KO.WINKEL_WINKEL_ID
         JOIN KLANT K on K.KLANTID = KO.KLANT_KLANTID
         JOIN ORDERLIJN O on KO.ORDERID = O.KLANTORDER_ORDERID and
                             KO.WINKEL_WINKEL_ID = O.KLANTORDER_WINKEL_ID and
                             KO.KLANT_KLANTID = O.KLANTORDER_KLANTID
WHERE o.prijs BETWEEN 550 AND 580
GROUP BY WINKEL_NAAM, NAAM, AANTAL, o.PRIJS, CONSOLE_CONSOLENAAM