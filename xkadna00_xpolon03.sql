
/*************************************************
SQL skript pro vytvoøení objektù schématu databáze
Zadanie è.15 (IUS) Požièovòa hudobných nosièov
Autor: Peter Polóni xpolon03
Autor: Šimon Kadnár xkadna00
*************************************************/

set serveroutput on;
---------------------------------DROP------------------------------------------

DROP TABLE uzivatel             CASCADE CONSTRAINTS;
DROP TABLE prihlaseny_zakaznik  CASCADE CONSTRAINTS;
DROP TABLE zamestnanec          CASCADE CONSTRAINTS;
DROP TABLE pozicanie            CASCADE CONSTRAINTS;
DROP TABLE pokuta               CASCADE CONSTRAINTS;
DROP TABLE nosic                CASCADE CONSTRAINTS;
DROP TABLE album                CASCADE CONSTRAINTS;
DROP TABLE skladba              CASCADE CONSTRAINTS;
DROP TABLE zaner                CASCADE CONSTRAINTS;
DROP TABLE autor                CASCADE CONSTRAINTS;
DROP TABLE interpret            CASCADE CONSTRAINTS;

DROP TABLE pozicanie_nosic      CASCADE CONSTRAINTS;
DROP TABLE album_skladba        CASCADE CONSTRAINTS;

DROP TABLE album_zaner          CASCADE CONSTRAINTS;
DROP TABLE album_interpret      CASCADE CONSTRAINTS;

DROP TABLE skladba_zaner        CASCADE CONSTRAINTS;
DROP TABLE skladba_autor        CASCADE CONSTRAINTS;
DROP TABLE skladba_interpret    CASCADE CONSTRAINTS;

DROP SEQUENCE uzivatel_insert;
DROP SEQUENCE skontrlouj_cenu;

DROP MATERIALIZED VIEW uzivatel_pocet_pozicani;

-----------------------------CREATE---------------------------------------------
CREATE TABLE prihlaseny_zakaznik (
	id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,            
    datum_registracie DATE DEFAULT NULL                                              
);

CREATE TABLE zamestnanec (
	id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,            
    bankovy_ucet  VARCHAR(15) NOT NULL,
        CHECK(REGEXP_LIKE(bankovy_ucet, '^[0123456789]{10}\\[0123456789]{4}$', 'i')),                          
    opravnenia  VARCHAR(80) NOT NULL 
        CHECK(REGEXP_LIKE(opravnenia, '^((Admin)|(Basic))$', 'i')), 
    datum_nastupu DATE DEFAULT NULL,                              
    datum_ukoncenia_PP DATE DEFAULT NULL                          
);

CREATE TABLE uzivatel (
	--id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,         
    id NUMBER NOT NULL PRIMARY KEY,  
	meno VARCHAR(80) NOT NULL,                                    
	priezvisko VARCHAR(80) NOT NULL,                              
    bydlisko VARCHAR(80) NOT NULL,                                
    telefon VARCHAR(80) NOT NULL
        CHECK(REGEXP_LIKE(telefon, '^((\+[0123456789]{3}9[0123456789]{8})|(09[0123456789]{8}))$')),   
    email VARCHAR(255) NOT NULL                                   
        CHECK(REGEXP_LIKE(email, '^[a-z]+[a-z0-9\.]*@[a-z0-9\.-]+\.[a-z]{2,}$', 'i')),   
        
    typ VARCHAR(80) CHECK ( typ IN ('prihlaseny_zakaznik', 'zamestnanec')),
        
    zamestnanec_id INT DEFAULT NULL,
    CONSTRAINT uzivatel_zamestnanec_fk FOREIGN KEY (zamestnanec_id) REFERENCES zamestnanec ON DELETE CASCADE,       
    
    prihlaseny_zakaznik_id INT DEFAULT NULL,
    CONSTRAINT uzivatel_prihlaseny_zakaznik_fk FOREIGN KEY (prihlaseny_zakaznik_id) REFERENCES prihlaseny_zakaznik ON DELETE CASCADE 
);

CREATE TABLE pozicanie (
    id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,  
    datum_pozicania DATE DEFAULT NULL,                              
    datum_vratenia DATE DEFAULT NULL,
    cena INT DEFAULT NULL,
    
    prihlaseny_zakaznik_id INT DEFAULT NULL,
    CONSTRAINT pozicanie_prihlaseny_zakaznik_fk FOREIGN KEY (prihlaseny_zakaznik_id) REFERENCES prihlaseny_zakaznik ON DELETE SET NULL,
    
    zamestnanec_vydal_id INT DEFAULT NULL,
    CONSTRAINT pozicanie_zamestnanec_vydal_fk FOREIGN KEY (zamestnanec_vydal_id) REFERENCES zamestnanec ON DELETE SET NULL,
    
    zamestnanec_prijal_id INT DEFAULT NULL,
    CONSTRAINT pozicanie_zamestnanec_prijal_fk FOREIGN KEY (zamestnanec_prijal_id) REFERENCES zamestnanec ON DELETE SET NULL
);

CREATE TABLE pokuta (
    id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,  
    datum_udelenia DATE DEFAULT NULL,                              
    cena INT DEFAULT NULL,
    stav INT NOT NULL,
    
    pozicanie_id INT DEFAULT NULL,
    CONSTRAINT pozicanie_zakaznik_fk FOREIGN KEY (pozicanie_id) REFERENCES pozicanie ON DELETE SET NULL
);
CREATE TABLE autor (
    id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY, 
	meno VARCHAR(80) NOT NULL                              
);

CREATE TABLE album (
	id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,          
	nazov VARCHAR(80) NOT NULL,                                    
    producent VARCHAR(80) NOT NULL, 
    vydaavatel VARCHAR(80) NOT NULL,
    
    autor_id INT,
    CONSTRAINT album_autor_fk FOREIGN KEY (autor_id) REFERENCES autor ON DELETE SET NULL
);

CREATE TABLE nosic (
    id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,  
    kvalita VARCHAR(80) NOT NULL,
    
    album_id INT,
    CONSTRAINT nosic_album_fk FOREIGN KEY (album_id) REFERENCES album ON DELETE SET NULL
);

CREATE TABLE skladba (
	id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,            
	nazov VARCHAR(80) NOT NULL,                                    
    producent VARCHAR(80) NOT NULL, 
    vydaavatel VARCHAR(80) NOT NULL
);
CREATE TABLE zaner (
	id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,            
	zaner VARCHAR(80) NOT NULL                                                        
);

CREATE TABLE interpret (
    id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY, 
	meno VARCHAR(80)                              
);

CREATE TABLE pozicanie_nosic (  
    pozicanie_id INT,
	nosic_id INT,
	CONSTRAINT pozicanie_nosic_pk PRIMARY KEY (pozicanie_id, nosic_id),
	CONSTRAINT nosic_pozicanie_fk FOREIGN KEY (nosic_id) REFERENCES nosic ON DELETE CASCADE,
	CONSTRAINT pozicanie_nosic_fk FOREIGN KEY (pozicanie_id) REFERENCES pozicanie ON DELETE CASCADE
);

CREATE TABLE album_skladba (  
    album_id INT NOT NULL,
	skladba_id INT NOT NULL,
	CONSTRAINT album_skladba_pk PRIMARY KEY (album_id, skladba_id),
	CONSTRAINT album_skladba_fk FOREIGN KEY (album_id) REFERENCES album ON DELETE CASCADE,
	CONSTRAINT skladba_album_fk FOREIGN KEY (skladba_id) REFERENCES skladba ON DELETE CASCADE
);

CREATE TABLE album_zaner (  
    album_id INT,
	zaner_id INT,
	CONSTRAINT album_zaner_pk PRIMARY KEY (album_id, zaner_id),
	CONSTRAINT album_zaner_fk FOREIGN KEY (album_id) REFERENCES album ON DELETE CASCADE,
	CONSTRAINT zaner_album_fk FOREIGN KEY (zaner_id) REFERENCES zaner ON DELETE CASCADE
);

CREATE TABLE album_interpret (  
    album_id INT,
	interpret_id INT,
	CONSTRAINT album_interpret_pk PRIMARY KEY (album_id, interpret_id),
	CONSTRAINT album_interpret_fk FOREIGN KEY (album_id) REFERENCES album ON DELETE CASCADE,
	CONSTRAINT interpret_album_fk FOREIGN KEY (interpret_id) REFERENCES interpret ON DELETE CASCADE
);

CREATE TABLE skladba_zaner (  
    skladba_id INT,
	zaner_id INT,
	CONSTRAINT skladba_zaner_pk PRIMARY KEY (skladba_id, zaner_id),
	CONSTRAINT skladba_zaner_fk FOREIGN KEY (skladba_id) REFERENCES skladba ON DELETE CASCADE,
	CONSTRAINT zaner_skladba_fk FOREIGN KEY (zaner_id) REFERENCES zaner ON DELETE CASCADE
);
CREATE TABLE skladba_autor (  
    skladba_id INT,
	autor_id INT,
	CONSTRAINT skladba_autor_pk PRIMARY KEY (skladba_id, autor_id),
	CONSTRAINT skladba_autor_fk FOREIGN KEY (skladba_id) REFERENCES skladba ON DELETE CASCADE,
	CONSTRAINT autor_skladba_fk FOREIGN KEY (autor_id) REFERENCES autor ON DELETE CASCADE
);
CREATE TABLE skladba_interpret (  
    skladba_id INT,
	interpret_id INT,
	CONSTRAINT skladba_interpret_pk PRIMARY KEY (skladba_id, interpret_id),
	CONSTRAINT skladba_interpret_fk FOREIGN KEY (skladba_id) REFERENCES skladba ON DELETE CASCADE,
	CONSTRAINT interpret_skladba_fk FOREIGN KEY (interpret_id) REFERENCES interpret ON DELETE CASCADE
);

-----------------------------TRIGGER--------------------------------------------

CREATE SEQUENCE uzivatel_insert;

CREATE OR REPLACE TRIGGER TUTO BEFORE
    INSERT ON uzivatel
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := uzivatel_seq.nextval;
END;
/

--automaticke generovaie ceny pre pozicanie
CREATE SEQUENCE skontrlouj_cenu;

CREATE OR REPLACE TRIGGER AHA BEFORE
    INSERT ON pozicanie_nosic
    FOR EACH ROW
DECLARE
    od_dna   DATE;
    do_dna   DATE;
    primerana_cena number;
BEGIN
    SELECT datum_pozicania INTO od_dna FROM pozicanie WHERE pozicanie.id =: new.pozicanie_id;
    SELECT datum_vratenia INTO do_dna FROM pozicanie WHERE pozicanie.id =: new.pozicanie_id;
    
    primerana_cena := do_dna - od_dna;
    
    UPDATE pozicanie SET cena = primerana_cena where pozicanie.id =: new.pozicanie_id;
END;
/

-----------------------------INSERT1---------------------------------------------

INSERT INTO prihlaseny_zakaznik VALUES (DEFAULT,DATE '2022-07-30');
INSERT INTO prihlaseny_zakaznik VALUES (DEFAULT,DATE '2021-01-20');
INSERT INTO zamestnanec VALUES (DEFAULT,'1234554321\0101','Basic',DATE '2022-08-01',DATE '2030-08-01');
INSERT INTO zamestnanec VALUES (DEFAULT,'0123456789\1010','Admin',DATE '2020-06-10', DATE '2035-08-01');

----------------------------------DEMONšTRÁCIA TRIGGERU1------------------------

INSERT INTO uzivatel (meno, priezvisko, bydlisko, telefon, email, typ, prihlaseny_zakaznik_id)
VALUES ('Ernest','Kabelaz','Patince','0945823102','kabelaz@vutbr.cz','prihlaseny_zakaznik',(select id from prihlaseny_zakaznik where datum_registracie=DATE '2022-07-30'));
INSERT INTO uzivatel VALUES (DEFAULT,'Hemis','Gonzales','Kralovsky chlmec','+421985813102','hemis@gmail.com','prihlaseny_zakaznik',(select id from prihlaseny_zakaznik where datum_registracie=DATE '2021-01-20'),DEFAULT);
INSERT INTO uzivatel VALUES (DEFAULT,'Lojza','Pasteka','Cernochov','+421983803202','pasteka@gmail.com','zamestnanec',DEFAULT,(select id from zamestnanec where bankovy_ucet='0123456789\1010'));
INSERT INTO uzivatel VALUES (DEFAULT,'Chonker','Vilis','Svabovce','+421981103032','vilis@gmail.com','zamestnanec',DEFAULT,(select id from zamestnanec where bankovy_ucet='0123456789\1010'));

-----------------------------INSERT2--------------------------------------------

INSERT INTO autor VALUES (DEFAULT,'autor1');
INSERT INTO autor VALUES (DEFAULT,'autor2');

INSERT INTO pozicanie VALUES (DEFAULT, DATE '2022-03-25', DATE '2022-05-25', NULL,(select id from prihlaseny_zakaznik where datum_registracie=DATE '2022-07-30'),(select id from zamestnanec where bankovy_ucet='0123456789\1010'),DEFAULT);
INSERT INTO pozicanie VALUES (DEFAULT, DATE '2022-02-06', DATE '2022-03-06', NULL,(select id from prihlaseny_zakaznik where datum_registracie=DATE '2021-01-20'),(select id from zamestnanec where bankovy_ucet='0123456789\1010'),DEFAULT);

INSERT INTO pozicanie VALUES (DEFAULT, DATE '2022-05-06', DATE '2022-08-08', NULL,(select id from prihlaseny_zakaznik where datum_registracie=DATE '2021-01-20'),(select id from zamestnanec where bankovy_ucet='0123456789\1010'),DEFAULT);


INSERT INTO album VALUES (DEFAULT,'album1','producent1','vydavatel1',(select id from autor where meno='autor1'));
INSERT INTO album VALUES (DEFAULT,'album2','producent2','vydavatel2',(select id from autor where meno='autor2'));

INSERT INTO pokuta VALUES (DEFAULT, DATE '2022-06-03',5, 0,(select id from pozicanie where datum_pozicania=DATE '2022-03-25'));

INSERT INTO nosic VALUES (DEFAULT,'CD',(select id from album where nazov='album1'));
INSERT INTO nosic VALUES (DEFAULT,'LP',(select id from album where nazov='album2'));
INSERT INTO nosic VALUES (DEFAULT,'Kazeta',DEFAULT);

INSERT INTO skladba VALUES (DEFAULT,'skladba1','producent1','vydavatel1');
INSERT INTO skladba VALUES (DEFAULT,'skladba2','producent1','vydavatel1');

INSERT INTO zaner VALUES (DEFAULT,'Pop');
INSERT INTO zaner VALUES (DEFAULT,'Metal');

INSERT INTO interpret VALUES (DEFAULT,'interpret1');
INSERT INTO interpret VALUES (DEFAULT,'interpret2');

----------------------------------DEMONšTRÁCIA TRIGGERU2------------------------

SELECT cena FROM pozicanie;
INSERT INTO pozicanie_nosic VALUES ((select id from pozicanie where datum_pozicania=DATE '2022-03-25'),(select id from nosic where kvalita='LP'));
INSERT INTO pozicanie_nosic VALUES ((select id from pozicanie where datum_pozicania=DATE '2022-02-06'),(select id from nosic where kvalita='CD'));

INSERT INTO pozicanie_nosic VALUES ((select id from pozicanie where datum_pozicania=DATE '2022-05-06'),(select id from nosic where kvalita='LP'));

SELECT cena FROM pozicanie;

-----------------------------INSERT3--------------------------------------------

INSERT INTO album_skladba VALUES ((select id from album where nazov='album1'),(select id from skladba where nazov='skladba1'));

INSERT INTO album_zaner VALUES ((select id from album where nazov='album1'),(select id from zaner where zaner='Metal'));
INSERT INTO album_interpret VALUES ((select id from album where nazov='album1'),(select id from interpret where meno='interpret1'));

INSERT INTO skladba_zaner VALUES ((select id from skladba where nazov='skladba1'),(select id from zaner where zaner='Metal'));
INSERT INTO skladba_autor VALUES ((select id from skladba where nazov='skladba1'),(select id from autor where meno='autor1'));
INSERT INTO skladba_interpret VALUES ((select id from skladba where nazov='skladba1'),(select id from interpret where meno='interpret1'));

-------------------------------PROCEDURE----------------------------------------

--pomer poctu uzivatelov k poctu pozicani
CREATE OR REPLACE PROCEDURE pocet_pozicani_na_uzivatela
IS
	priemerny_pocet_pozicani NUMBER;
    pocet_pozicani NUMBER;
	pocet_uzivatelov NUMBER;

BEGIN
    
	SELECT COUNT(*) INTO pocet_uzivatelov FROM uzivatel;
	SELECT COUNT(*) INTO pocet_pozicani FROM pozicanie;

	priemerny_pocet_pozicani := pocet_pozicani / pocet_uzivatelov;

	DBMS_OUTPUT.put_line('celokovy pocet uzivatelov:' || pocet_uzivatelov );
    	DBMS_OUTPUT.put_line('celokovy pocet pozicani:' || pocet_pozicani );
	DBMS_OUTPUT.put_line('premerny pocet pozicani na uzivatela:'|| priemerny_pocet_pozicani );

	EXCEPTION WHEN ZERO_DIVIDE THEN
		IF pocet_uzivatelov = 0 THEN
			DBMS_OUTPUT.put_line('Nemate uzivatelov');
		END IF;

		IF pocet_pozicani = 0 THEN
			DBMS_OUTPUT.put_line('Ziaden z nosicov nebol pozicany');
		END IF;
END;
/


--kolko nosicov obsahuje dany album
CREATE OR REPLACE PROCEDURE mnozstvo_nosicov
	(hladany_album IN VARCHAR)
AS
	vsetky_nosice NUMBER; 
	ziadane_nosice NUMBER; 
	album_id album.id%TYPE; 
	ziadany_album_id album.id%TYPE; 
	CURSOR cursor_albumov IS SELECT id FROM album;  
BEGIN
	SELECT COUNT(*) INTO vsetky_nosice FROM nosic;

	ziadane_nosice := 0;

	SELECT id INTO ziadany_album_id FROM album WHERE nazov = hladany_album;

	OPEN cursor_albumov;
	LOOP
		FETCH cursor_albumov INTO album_id;

		EXIT WHEN cursor_albumov%NOTFOUND;

		IF album_id  = ziadany_album_id THEN
			ziadane_nosice := ziadane_nosice + 1;
		END IF;
	END LOOP;
	CLOSE cursor_albumov;

	DBMS_OUTPUT.put_line( hladany_album || ' je na ' || ziadane_nosice || ' nosicoch z ' || vsetky_nosice || ' nosciov ');

	EXCEPTION WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.put_line('Dany album  nebol najdeny: ' || hladany_album);
END;
/

----------------------------DEMONšTRÁCIA PROCEDUR-------------------------------

EXEC pocet_pozicani_na_uzivatela ();
EXEC mnozstvo_nosicov ('album1');

-----------------------------------VIEW-----------------------------------------

--pohlad na vsetkych uzivatelov a ich pozicania
CREATE MATERIALIZED VIEW uzivatel_pocet_pozicani AS
SELECT
	prihlaseny_zakaznik.id,
	prihlaseny_zakaznik.datum_registracie,
	COUNT(pozicanie.prihlaseny_zakaznik_id) AS pocet_pozicani
FROM prihlaseny_zakaznik
LEFT JOIN pozicanie ON pozicanie.prihlaseny_zakaznik_id = prihlaseny_zakaznik.id
GROUP BY prihlaseny_zakaznik.id, prihlaseny_zakaznik.datum_registracie ;

--vypis pohladu
SELECT * FROM uzivatel_pocet_pozicani;

--aktualizacia dat pohladu
UPDATE pozicanie SET prihlaseny_zakaznik_id = 2 WHERE id = 1;

------------------------------EXPLAIN PLAN--------------------------------------

-- ktory pouzivatelia s emailom maju koncovku gmail.com a pozicali si viac nez jeden nosic(pocet pozicani)

EXPLAIN PLAN FOR
SELECT u.email AS email, COUNT(po.id) AS count
FROM  prihlaseny_zakaznik pz,  pozicanie po, uzivatel u 
WHERE  po.prihlaseny_zakaznik_id = pz.id and u.id = pz.id and u.email LIKE '%gmail.com'
GROUP BY u.id, u.email HAVING COUNT(po.prihlaseny_zakaznik_id) > 1 ORDER BY email;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--rychlejsie vyhladavanie vdaka indexu na email
CREATE INDEX uzivatel_email ON uzivatel (email);

EXPLAIN PLAN FOR
SELECT u.email AS email,COUNT(po.id) AS count
FROM  prihlaseny_zakaznik pz,  pozicanie po, uzivatel u 
WHERE  po.prihlaseny_zakaznik_id = pz.id and u.id = pz.id and u.email LIKE '%gmail.com' 
GROUP BY u.id, u.email HAVING COUNT(po.prihlaseny_zakaznik_id) > 1 ORDER BY email;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

---------------------------------PRÁVA------------------------------------------

GRANT ALL ON uzivatel TO xpolon03;
GRANT ALL ON prihlaseny_zakaznik TO xpolon03;
GRANT ALL ON zamestnanec TO xpolon03;
GRANT ALL ON pozicanie TO xpolon03;
GRANT ALL ON pokuta TO xpolon03;
GRANT ALL ON nosic TO xpolon03;
GRANT ALL ON album TO xpolon03;
GRANT ALL ON skladba TO xpolon03;
GRANT ALL ON zaner TO xpolon03;
GRANT ALL ON autor TO xpolon03;
GRANT ALL ON interpret TO xpolon03;

GRANT ALL ON pozicanie_nosic TO xpolon03;
GRANT ALL ON album_skladba TO xpolon03;
GRANT ALL ON album_zaner TO xpolon03;
GRANT ALL ON album_interpret TO xpolon03;
GRANT ALL ON skladba_zaner TO xpolon03;
GRANT ALL ON skladba_autor TO xpolon03;
GRANT ALL ON skladba_interpret TO xpolon03;

GRANT EXECUTE ON pocet_pozicani_na_uzivatela TO xpolon03;
GRANT EXECUTE ON mnozstvo_nosicov TO xpolon03;

GRANT ALL ON uzivatel_pocet_pozicani TO xpolon03;