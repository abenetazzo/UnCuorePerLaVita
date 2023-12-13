-- EVENTUALE PULIZIA DB

DROP INDEX IF EXISTS idx_massimale;
DROP INDEX IF EXISTS idx_lista_attesa_pr;
DROP INDEX IF EXISTS idx_lista_attesa_do;
DROP TABLE IF EXISTS lista_organi;
DROP TABLE IF EXISTS equipe_chirurgica;
DROP TABLE IF EXISTS trapianti;
DROP TABLE IF EXISTS assicurazioni;
DROP TABLE IF EXISTS compatibilita;
DROP TABLE IF EXISTS personale_medico;
DROP TABLE IF EXISTS pazienti;
DROP TABLE IF EXISTS anagrafiche;
DROP TABLE IF EXISTS gruppi_sanguigni;
DROP TABLE IF EXISTS organi;
DROP TYPE IF EXISTS RUOLO;

-- CREAZIONE TABELLE

CREATE TYPE RUOLO AS ENUM ('Chirurgo', 'Anestesista', 'Infermiere');

CREATE TABLE organi (
	id INT PRIMARY KEY,
	nome VARCHAR(255) NOT NULL UNIQUE,
	costo INT NOT NULL,
	CHECK (costo >= 0)
);

CREATE TABLE gruppi_sanguigni (
	gruppo VARCHAR(3) PRIMARY KEY
);

CREATE TABLE anagrafiche (
	codice_fiscale CHAR(16) PRIMARY KEY,
	cognome VARCHAR(255) NOT NULL,
	nome VARCHAR(255) NOT NULL,
	data_nascita DATE NOT NULL
);

CREATE TABLE pazienti (
	codice_fiscale CHAR(16) PRIMARY KEY
	REFERENCES anagrafiche(codice_fiscale)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	altezza_cm INT,
	peso_kg INT,
	gruppo_sanguigno VARCHAR(3) NOT NULL
	REFERENCES gruppi_sanguigni(gruppo)
		ON DELETE RESTRICT
		ON UPDATE RESTRICT,
	CHECK (altezza_cm > 0),
	CHECK (peso_kg > 0)
);

CREATE TABLE personale_medico (
	codice_fiscale CHAR(16) PRIMARY KEY
	REFERENCES anagrafiche(codice_fiscale)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	mansione RUOLO NOT NULL,
	compenso INT NOT NULL,
	CHECK (compenso >= 0)
);

CREATE TABLE compatibilita (
	gruppo_donatore VARCHAR(3)
		REFERENCES gruppi_sanguigni(gruppo)
		ON DELETE RESTRICT
		ON UPDATE RESTRICT,
	gruppo_ricevente VARCHAR(3)
		REFERENCES gruppi_sanguigni(gruppo)
		ON DELETE RESTRICT
		ON UPDATE RESTRICT,
	PRIMARY KEY (gruppo_donatore, gruppo_ricevente)
);

CREATE TABLE assicurazioni (
	cliente CHAR(16) PRIMARY KEY
	REFERENCES pazienti(codice_fiscale)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	massimale INT NOT NULL,
	compagnia_assicurativa VARCHAR(255) NOT NULL,
	CHECK (massimale > 0)
);

CREATE TABLE trapianti (
	id INT PRIMARY KEY,
	ricevente CHAR(16) NOT NULL
		REFERENCES pazienti(codice_fiscale)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	donatore CHAR(16) NOT NULL
		REFERENCES pazienti(codice_fiscale)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	organo INT NOT NULL
		REFERENCES organi(id)
		ON DELETE RESTRICT
		ON UPDATE RESTRICT,
	data DATE NOT NULL,
	UNIQUE (ricevente, donatore, organo, data),
	CHECK (ricevente <> donatore)
);

CREATE TABLE equipe_chirurgica (
	trapianto INT
		REFERENCES trapianti(id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	membro_equipe CHAR(16)
		REFERENCES personale_medico(codice_fiscale)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	PRIMARY KEY (trapianto, membro_equipe)
);

CREATE TABLE lista_organi (
	paziente CHAR(16)
		REFERENCES pazienti(codice_fiscale)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	organo INT
		REFERENCES organi(id)
		ON DELETE RESTRICT
		ON UPDATE RESTRICT,
	data_ora TIMESTAMP NOT NULL,
	priorita INT,
	PRIMARY KEY (paziente, organo),
	CHECK (priorita >= 0 AND priorita <= 10)
);

-- POPOLAMENTO TABELLE

INSERT INTO organi VALUES(01,'Midollo Osseo',120  );
INSERT INTO organi VALUES(02,'Pelle',		 600  );
INSERT INTO organi VALUES(03,'Muscoli',		 1100 );
INSERT INTO organi VALUES(05,'Polmoni',		 12000);
INSERT INTO organi VALUES(06,'Fegato',		 13000);
INSERT INTO organi VALUES(07,'Pancreas',	 17000);
INSERT INTO organi VALUES(10,'Reni',		 19000);
INSERT INTO organi VALUES(11,'Occhi',		 22000);
INSERT INTO organi VALUES(12,'Cuore',		 23000);
INSERT INTO organi VALUES(13,'Cervello',	 29000);

INSERT INTO gruppi_sanguigni VALUES( 'A+');
INSERT INTO gruppi_sanguigni VALUES( 'A-');
INSERT INTO gruppi_sanguigni VALUES( 'B+');
INSERT INTO gruppi_sanguigni VALUES( 'B-');
INSERT INTO gruppi_sanguigni VALUES('AB+');
INSERT INTO gruppi_sanguigni VALUES('AB-');
INSERT INTO gruppi_sanguigni VALUES( '0+');
INSERT INTO gruppi_sanguigni VALUES( '0-');

INSERT INTO compatibilita VALUES( 'A+', 'A+');
INSERT INTO compatibilita VALUES( 'A+','AB+');
INSERT INTO compatibilita VALUES( 'A-', 'A+');
INSERT INTO compatibilita VALUES( 'A-','AB+');
INSERT INTO compatibilita VALUES( 'A-', 'A-');
INSERT INTO compatibilita VALUES( 'A-','AB-');
INSERT INTO compatibilita VALUES( 'B+', 'B+');
INSERT INTO compatibilita VALUES( 'B+','AB+');
INSERT INTO compatibilita VALUES( 'B-', 'B+');
INSERT INTO compatibilita VALUES( 'B-','AB+');
INSERT INTO compatibilita VALUES( 'B-', 'B-');
INSERT INTO compatibilita VALUES( 'B-','AB-');
INSERT INTO compatibilita VALUES('AB+','AB+');
INSERT INTO compatibilita VALUES('AB-','AB+');
INSERT INTO compatibilita VALUES('AB-','AB-');
INSERT INTO compatibilita VALUES( '0+', 'A+');
INSERT INTO compatibilita VALUES( '0+', 'B+');
INSERT INTO compatibilita VALUES( '0+','AB+');
INSERT INTO compatibilita VALUES( '0+', '0+');
INSERT INTO compatibilita VALUES( '0-', 'A+');
INSERT INTO compatibilita VALUES( '0-', 'B+');
INSERT INTO compatibilita VALUES( '0-','AB+');
INSERT INTO compatibilita VALUES( '0-', '0+');
INSERT INTO compatibilita VALUES( '0-', 'A-');
INSERT INTO compatibilita VALUES( '0-', 'B-');
INSERT INTO compatibilita VALUES( '0-','AB-');
INSERT INTO compatibilita VALUES( '0-', '0-');

INSERT INTO anagrafiche VALUES ('rssfrn77a19g224z','francesco',   'rossi',     '1977-01-19');
INSERT INTO anagrafiche VALUES ('vrdfrn94b24g224z','francesco',   'verdi',     '1994-02-24');
INSERT INTO anagrafiche VALUES ('bncfrn60c04g224z','francesco',   'bianco',    '1960-03-04');
INSERT INTO anagrafiche VALUES ('nrefrn78d14g224z','francesco',   'neri',      '1978-04-14');
INSERT INTO anagrafiche VALUES ('tttfrn64e17g224z','francesco',   'totti',     '1964-05-17');
INSERT INTO anagrafiche VALUES ('cssfrn69h19g224z','francesco',   'cassano',   '1969-06-19');
INSERT INTO anagrafiche VALUES ('rnzfrn62l18g224z','francesco',   'renzi',     '1962-07-18');
INSERT INTO anagrafiche VALUES ('brlfrn69m20g224z','francesco',   'berlusconi','1969-08-20');
INSERT INTO anagrafiche VALUES ('grbfrn77p21g224z','francesco',   'garibaldi', '1977-09-21');
INSERT INTO anagrafiche VALUES ('brnfrn92r25f241y','francesco',   'bruni',     '1992-10-25');
INSERT INTO anagrafiche VALUES ('rsslbr98s02f241y','alberto',     'rossi',     '1998-11-02');
INSERT INTO anagrafiche VALUES ('vrdlbr92t25f241y','alberto',     'verdi',     '1992-12-25');
INSERT INTO anagrafiche VALUES ('bnclbr95a05f241y','alberto',     'bianco',    '1995-01-05');
INSERT INTO anagrafiche VALUES ('nrelbr67b15f241y','alberto',     'neri',      '1967-02-15');
INSERT INTO anagrafiche VALUES ('tttlbr75c21f241y','alberto',     'totti',     '1975-03-21');
INSERT INTO anagrafiche VALUES ('csslbr66d24f241y','alberto',     'cassano',   '1966-04-24');
INSERT INTO anagrafiche VALUES ('rnzlbr86e16f241y','alberto',     'renzi',     '1986-05-16');
INSERT INTO anagrafiche VALUES ('brllbr60h21g224z','alberto',     'berlusconi','1960-06-21');
INSERT INTO anagrafiche VALUES ('grblbr91l11g224z','alberto',     'garibaldi', '1991-07-11');
INSERT INTO anagrafiche VALUES ('brnlbr96m09g224z','alberto',     'bruni',     '1996-08-09');
INSERT INTO anagrafiche VALUES ('rssmss75p17g224z','massimiliano','rossi',     '1975-09-17');
INSERT INTO anagrafiche VALUES ('vrdmss65r21g224z','massimiliano','verdi',     '1965-10-21');
INSERT INTO anagrafiche VALUES ('bncmss89s16g224z','massimiliano','bianco',    '1989-11-16');
INSERT INTO anagrafiche VALUES ('nremss96t24g224z','massimiliano','neri',      '1996-12-24');
INSERT INTO anagrafiche VALUES ('tttmss82a13g224z','massimiliano','totti',     '1982-01-13');
INSERT INTO anagrafiche VALUES ('cssmss91b01g224z','massimiliano','cassano',   '1991-02-01');
INSERT INTO anagrafiche VALUES ('rnzmss95c15f241y','massimiliano','renzi',     '1995-03-15');
INSERT INTO anagrafiche VALUES ('brlmss80d16f241y','massimiliano','berlusconi','1980-04-16');
INSERT INTO anagrafiche VALUES ('grbmss64e20f241y','massimiliano','garibaldi', '1964-05-20');
INSERT INTO anagrafiche VALUES ('brnmss66h10f241y','massimiliano','bruni',     '1966-06-10');
INSERT INTO anagrafiche VALUES ('rssguo63l23f241y','ugo',         'rossi',     '1963-07-23');
INSERT INTO anagrafiche VALUES ('vrdguo87m23f241y','ugo',         'verdi',     '1987-08-23');
INSERT INTO anagrafiche VALUES ('bncguo96p16f241y','ugo',         'bianco',    '1996-09-16');
INSERT INTO anagrafiche VALUES ('nreguo63r02f241y','ugo',         'neri',      '1963-10-02');
INSERT INTO anagrafiche VALUES ('tttguo80s02f241y','ugo',         'totti',     '1980-11-02');
INSERT INTO anagrafiche VALUES ('cssguo61t07g224z','ugo',         'cassano',   '1961-12-07');
INSERT INTO anagrafiche VALUES ('rnzguo97a19g224z','ugo',         'renzi',     '1997-01-19');
INSERT INTO anagrafiche VALUES ('brlguo88b25g224z','ugo',         'berlusconi','1988-02-25');
INSERT INTO anagrafiche VALUES ('grbguo73c21g224z','ugo',         'garibaldi', '1973-03-21');
INSERT INTO anagrafiche VALUES ('brnguo74d03g224z','ugo',         'bruni',     '1974-04-03');
INSERT INTO anagrafiche VALUES ('rsslcu64e19g224z','lucia',       'rossi',     '1964-05-19');
INSERT INTO anagrafiche VALUES ('vrdlcu68h01g224z','lucia',       'verdi',     '1968-06-01');
INSERT INTO anagrafiche VALUES ('bnclcu81l25g224z','lucia',       'bianco',    '1981-07-25');
INSERT INTO anagrafiche VALUES ('nrelcu74m06g224z','lucia',       'neri',      '1974-08-06');
INSERT INTO anagrafiche VALUES ('tttlcu99p11f241y','lucia',       'totti',     '1999-09-11');
INSERT INTO anagrafiche VALUES ('csslcu82r26f241y','lucia',       'cassano',   '1982-10-26');
INSERT INTO anagrafiche VALUES ('rnzlcu79s10f241y','lucia',       'renzi',     '1979-11-10');
INSERT INTO anagrafiche VALUES ('brllcu74t24f241y','lucia',       'berlusconi','1974-12-24');
INSERT INTO anagrafiche VALUES ('grblcu85a27f241y','lucia',       'garibaldi', '1985-01-27');
INSERT INTO anagrafiche VALUES ('brnlcu80b24f241y','lucia',       'bruni',     '1980-02-24');
INSERT INTO anagrafiche VALUES ('rssmrc25c08f241y','marco',       'rossi',     '2020-03-08');
INSERT INTO anagrafiche VALUES ('vrdmrc04d09f241y','marco',       'verdi',     '2004-04-09');
INSERT INTO anagrafiche VALUES ('bncmrc12e24f241y','marco',       'bianco',    '2012-05-24');
INSERT INTO anagrafiche VALUES ('nremrc13h20g224z','marco',       'neri',      '2013-06-20');
INSERT INTO anagrafiche VALUES ('tttmrc11l13g224z','marco',       'totti',     '2011-07-13');
INSERT INTO anagrafiche VALUES ('cssmrc01m08g224z','marco',       'cassano',   '2001-08-08');
INSERT INTO anagrafiche VALUES ('rnzmrc29p11g224z','marco',       'renzi',     '2020-09-11');
INSERT INTO anagrafiche VALUES ('brlmrc16r21g224z','marco',       'berlusconi','2016-10-21');
INSERT INTO anagrafiche VALUES ('grbmrc00s25g224z','marco',       'garibaldi', '2000-11-25');
INSERT INTO anagrafiche VALUES ('brnmrc14t04g224z','marco',       'bruni',     '2014-12-04');
INSERT INTO anagrafiche VALUES ('rssmra19a18g224z','mario',       'rossi',     '2019-01-18');
INSERT INTO anagrafiche VALUES ('vrdmra09b01g224z','mario',       'verdi',     '2009-02-01');
INSERT INTO anagrafiche VALUES ('bncmra12c20f241y','mario',       'bianco',    '2012-03-20');
INSERT INTO anagrafiche VALUES ('nremra03d18f241y','mario',       'neri',      '2003-04-18');
INSERT INTO anagrafiche VALUES ('tttmra06e09f241y','mario',       'totti',     '2006-05-09');
INSERT INTO anagrafiche VALUES ('cssmra07h16f241y','mario',       'cassano',   '2007-06-16');
INSERT INTO anagrafiche VALUES ('rnzmra11l03f241y','mario',       'renzi',     '2011-07-03');
INSERT INTO anagrafiche VALUES ('brlmra06m12f241y','mario',       'berlusconi','2006-08-12');
INSERT INTO anagrafiche VALUES ('grbmra23p05f241y','mario',       'garibaldi', '2020-09-05');
INSERT INTO anagrafiche VALUES ('brnmra28r05f241y','mario',       'bruni',     '2018-10-05');
INSERT INTO anagrafiche VALUES ('rssmra10s10f241y','maria',       'rossi',     '2010-11-10');
INSERT INTO anagrafiche VALUES ('vrdmra00t17f241y','maria',       'verdi',     '2000-12-17');
INSERT INTO anagrafiche VALUES ('bncmra04a04g224z','maria',       'bianco',    '2004-01-04');
INSERT INTO anagrafiche VALUES ('nremra13b25g224z','maria',       'neri',      '2013-02-25');
INSERT INTO anagrafiche VALUES ('tttmra08c15g224z','maria',       'totti',     '2008-03-15');
INSERT INTO anagrafiche VALUES ('cssmra21d21g224z','maria',       'cassano',   '2021-04-21');
INSERT INTO anagrafiche VALUES ('rnzmra02e27g224z','maria',       'renzi',     '2002-05-27');
INSERT INTO anagrafiche VALUES ('brlmra11h26g224z','maria',       'berlusconi','2011-06-26');
INSERT INTO anagrafiche VALUES ('grbmra08l08g224z','maria',       'garibaldi', '2008-07-08');
INSERT INTO anagrafiche VALUES ('brnmra09m21g224z','maria',       'bruni',     '2009-08-21');
INSERT INTO anagrafiche VALUES ('rssgnn28p01g224z','gianni',      'rossi',     '2018-09-01');
INSERT INTO anagrafiche VALUES ('vrdgnn19r16f241y','gianni',      'verdi',     '2019-10-16');
INSERT INTO anagrafiche VALUES ('bncgnn17s18f241y','gianni',      'bianco',    '2017-11-18');
INSERT INTO anagrafiche VALUES ('nregnn23t16f241y','gianni',      'neri',      '2022-12-16');
INSERT INTO anagrafiche VALUES ('tttgnn18a06f241y','gianni',      'totti',     '2018-01-06');
INSERT INTO anagrafiche VALUES ('cssgnn11b03f241y','gianni',      'cassano',   '2011-02-03');
INSERT INTO anagrafiche VALUES ('rnzgnn18c27f241y','gianni',      'renzi',     '2018-03-27');
INSERT INTO anagrafiche VALUES ('brlgnn29d02f241y','gianni',      'berlusconi','2020-04-02');
INSERT INTO anagrafiche VALUES ('grbgnn21e09g224z','gianni',      'garibaldi', '2011-05-09');
INSERT INTO anagrafiche VALUES ('brngnn09h24g224z','gianni',      'bruni',     '2009-06-24');
INSERT INTO anagrafiche VALUES ('rsscrl03l07g224z','carla',       'rossi',     '2003-07-07');
INSERT INTO anagrafiche VALUES ('vrdcrl16m11g224z','carla',       'verdi',     '2016-08-11');
INSERT INTO anagrafiche VALUES ('bnccrl29p02g224z','carla',       'bianco',    '2022-09-02');
INSERT INTO anagrafiche VALUES ('nrecrl15r04g224z','carla',       'neri',      '2015-10-04');
INSERT INTO anagrafiche VALUES ('tttcrl02s19g224z','carla',       'totti',     '2002-11-19');
INSERT INTO anagrafiche VALUES ('csscrl14t18g224z','carla',       'cassano',   '2014-12-18');
INSERT INTO anagrafiche VALUES ('rnzcrl08a18g224z','carla',       'renzi',     '2008-01-18');
INSERT INTO anagrafiche VALUES ('brlcrl24b06f241y','carla',       'berlusconi','2020-02-06');
INSERT INTO anagrafiche VALUES ('grbcrl05c22f241y','carla',       'garibaldi', '2005-03-22');
INSERT INTO anagrafiche VALUES ('brncrl23d11f241y','carla',       'bruni',     '2013-04-11');

INSERT INTO personale_medico VALUES ('vrdfrn94b24g224z','Infermiere', 1900);
INSERT INTO personale_medico VALUES ('brnfrn92r25f241y','Chirurgo',   1900);
INSERT INTO personale_medico VALUES ('rsslbr98s02f241y','Infermiere', 1900);
INSERT INTO personale_medico VALUES ('vrdlbr92t25f241y','Chirurgo',   1900);
INSERT INTO personale_medico VALUES ('bnclbr95a05f241y','Infermiere', 1900);
INSERT INTO personale_medico VALUES ('rnzlbr86e16f241y','Anestesista',1900);
INSERT INTO personale_medico VALUES ('grblbr91l11g224z','Anestesista',1500);
INSERT INTO personale_medico VALUES ('brnlbr96m09g224z','Infermiere', 1700);
INSERT INTO personale_medico VALUES ('bncmss89s16g224z','Infermiere', 1700);
INSERT INTO personale_medico VALUES ('nremss96t24g224z','Anestesista',1700);
INSERT INTO personale_medico VALUES ('cssmss91b01g224z','Chirurgo',   1700);
INSERT INTO personale_medico VALUES ('rnzmss95c15f241y','Anestesista',1700);
INSERT INTO personale_medico VALUES ('vrdguo87m23f241y','Chirurgo',   1700);
INSERT INTO personale_medico VALUES ('bncguo96p16f241y','Chirurgo',   1700);
INSERT INTO personale_medico VALUES ('rnzguo97a19g224z','Chirurgo',   1700);
INSERT INTO personale_medico VALUES ('brlguo88b25g224z','Infermiere', 1300);
INSERT INTO personale_medico VALUES ('tttlcu99p11f241y','Infermiere', 0000);
INSERT INTO personale_medico VALUES ('grblcu85a27f241y','Infermiere', 0000);
INSERT INTO personale_medico VALUES ('cssmrc01m08g224z','Infermiere', 1300);
INSERT INTO personale_medico VALUES ('grbmrc00s25g224z','Chirurgo',   1100);
INSERT INTO personale_medico VALUES ('nremra03d18f241y','Anestesista',1100);
INSERT INTO personale_medico VALUES ('vrdmra00t17f241y','Chirurgo',   1100);
INSERT INTO personale_medico VALUES ('rnzmra02e27g224z','Infermiere', 1100);
INSERT INTO personale_medico VALUES ('rsscrl03l07g224z','Infermiere', 1100);
INSERT INTO personale_medico VALUES ('tttcrl02s19g224z','Chirurgo',   1100);

INSERT INTO pazienti VALUES ('vrdcrl16m11g224z', '94', '23','A-' );
INSERT INTO pazienti VALUES ('brlmrc16r21g224z', '90', '22','0-' );
INSERT INTO pazienti VALUES ('csslcu82r26f241y','192','120','B+' );
INSERT INTO pazienti VALUES ('brnguo74d03g224z','189', '89','A-' );
INSERT INTO pazienti VALUES ('brnfrn92r25f241y','176', '80','B+' );
INSERT INTO pazienti VALUES ('brlmss80d16f241y','182', '74','0-' );
INSERT INTO pazienti VALUES ('nremss96t24g224z','187', '86','AB+');
INSERT INTO pazienti VALUES ('bnclcu81l25g224z','189', '69','AB-');
INSERT INTO pazienti VALUES ('bncmss89s16g224z','182', '76','A+' );
INSERT INTO pazienti VALUES ('rssmra19a18g224z', '49', '13','A-' );
INSERT INTO pazienti VALUES ('vrdlcu68h01g224z','184','117','AB-');
INSERT INTO pazienti VALUES ('brlguo88b25g224z','193', '99','AB+');
INSERT INTO pazienti VALUES ('vrdgnn19r16f241y', '56', '24','0+' );
INSERT INTO pazienti VALUES ('rssfrn77a19g224z','175', '84','B+' );
INSERT INTO pazienti VALUES ('tttmra08c15g224z','151', '67','B+' );
INSERT INTO pazienti VALUES ('vrdlbr92t25f241y','176','115','AB+');
INSERT INTO pazienti VALUES ('bncgnn17s18f241y','112', '26','A-' );
INSERT INTO pazienti VALUES ('rsscrl03l07g224z','186', '73','B-' );
INSERT INTO pazienti VALUES ('brnmss66h10f241y','188','100','AB-');
INSERT INTO pazienti VALUES ('brllbr60h21g224z','178','110','AB+');
INSERT INTO pazienti VALUES ('nremra13b25g224z','132', '52','AB-');
INSERT INTO pazienti VALUES ('bncmrc12e24f241y','133', '45','A+' );
INSERT INTO pazienti VALUES ('bnccrl29p02g224z', '45', '14','AB+');
INSERT INTO pazienti VALUES ('rssmrc25c08f241y', '53', '20','A+' );
INSERT INTO pazienti VALUES ('rnzmss95c15f241y','190', '91','A-' );
INSERT INTO pazienti VALUES ('vrdfrn94b24g224z','166','107','AB-');
INSERT INTO pazienti VALUES ('bncfrn60c04g224z','192', '65','AB+');
INSERT INTO pazienti VALUES ('brngnn09h24g224z','144', '48','AB-');
INSERT INTO pazienti VALUES ('grbcrl05c22f241y','151', '65','AB+');
INSERT INTO pazienti VALUES ('tttmss82a13g224z','191', '82','B+' );
INSERT INTO pazienti VALUES ('brnlcu80b24f241y','165','115','B+' );
INSERT INTO pazienti VALUES ('tttgnn18a06f241y','110', '28','B+' );
INSERT INTO pazienti VALUES ('nreguo63r02f241y','178', '76','AB-');
INSERT INTO pazienti VALUES ('rnzfrn62l18g224z','172', '67','AB+');
INSERT INTO pazienti VALUES ('csscrl14t18g224z','183', '76','B+' );
INSERT INTO pazienti VALUES ('vrdmrc04d09f241y','154', '43','0-' );
INSERT INTO pazienti VALUES ('brlmra11h26g224z','119', '54','0-' );
INSERT INTO pazienti VALUES ('brnlbr96m09g224z','169', '67','0-' );
INSERT INTO pazienti VALUES ('cssmra07h16f241y','142', '46','B-' );
INSERT INTO pazienti VALUES ('rnzlcu79s10f241y','176', '89','A-' );
INSERT INTO pazienti VALUES ('vrdmss65r21g224z','192', '67','A-' );
INSERT INTO pazienti VALUES ('nrecrl15r04g224z', '90', '25','AB-');
INSERT INTO pazienti VALUES ('bncguo96p16f241y','165','102','0-' );
INSERT INTO pazienti VALUES ('brlmra06m12f241y','141', '45','A-' );
INSERT INTO pazienti VALUES ('bncmra12c20f241y','102', '35','0-' );
INSERT INTO pazienti VALUES ('grbgnn21e09g224z','127', '41','A-' );
INSERT INTO pazienti VALUES ('rsslcu64e19g224z','179','109','0-' );
INSERT INTO pazienti VALUES ('grbfrn77p21g224z','167', '72','A+' );
INSERT INTO pazienti VALUES ('rssguo63l23f241y','166', '65','0+' );
INSERT INTO pazienti VALUES ('brnmra28r05f241y','102', '28','0+' );
INSERT INTO pazienti VALUES ('cssguo61t07g224z','164', '85','B+' );
INSERT INTO pazienti VALUES ('grbmra23p05f241y', '65', '26','0-' );
INSERT INTO pazienti VALUES ('brncrl23d11f241y','108', '40','B-' );
INSERT INTO pazienti VALUES ('bnclbr95a05f241y','184', '90','B-' );
INSERT INTO pazienti VALUES ('tttguo80s02f241y','181','109','0+' );

INSERT INTO trapianti VALUES (36,'vrdmss65r21g224z','nremss96t24g224z',06,'2026-07-23');
INSERT INTO trapianti VALUES (31,'vrdmss65r21g224z','rnzfrn62l18g224z',07,'2026-07-23');
INSERT INTO trapianti VALUES (32,'bnclcu81l25g224z','nremss96t24g224z',11,'2026-11-06');
INSERT INTO trapianti VALUES ( 1,'vrdlbr92t25f241y','nremss96t24g224z',05,'2026-12-16');
INSERT INTO trapianti VALUES ( 2,'grbmra23p05f241y','nreguo63r02f241y',03,'2026-11-23');
INSERT INTO trapianti VALUES ( 3,'rnzlcu79s10f241y','nremra13b25g224z',12,'2026-02-10');
INSERT INTO trapianti VALUES ( 4,'bnclcu81l25g224z','vrdlcu68h01g224z',06,'2026-10-12');
INSERT INTO trapianti VALUES ( 5,'grbgnn21e09g224z','bncfrn60c04g224z',07,'2026-07-26');
INSERT INTO trapianti VALUES ( 6,'rsslcu64e19g224z','brngnn09h24g224z',13,'2024-04-07');
INSERT INTO trapianti VALUES ( 7,'vrdgnn19r16f241y','brlguo88b25g224z',06,'2024-03-07');
INSERT INTO trapianti VALUES ( 8,'brlmra06m12f241y','rnzmss95c15f241y',01,'2024-07-15');
INSERT INTO trapianti VALUES ( 9,'brnguo74d03g224z','rssmra19a18g224z',05,'2024-12-24');
INSERT INTO trapianti VALUES (10,'cssguo61t07g224z','tttgnn18a06f241y',06,'2024-03-12');
INSERT INTO trapianti VALUES (11,'rssfrn77a19g224z','tttmra08c15g224z',02,'2024-10-20');
INSERT INTO trapianti VALUES (12,'rssguo63l23f241y','tttmss82a13g224z',05,'2024-02-15');
INSERT INTO trapianti VALUES (13,'bnclbr95a05f241y','rnzfrn62l18g224z',10,'2024-10-02');
INSERT INTO trapianti VALUES (14,'vrdmrc04d09f241y','bncgnn17s18f241y',12,'2024-12-20');
INSERT INTO trapianti VALUES (15,'vrdmss65r21g224z','bncmrc12e24f241y',06,'2024-09-26');
INSERT INTO trapianti VALUES (16,'grbfrn77p21g224z','grbcrl05c22f241y',02,'2027-01-06');
INSERT INTO trapianti VALUES (17,'bncmrc12e24f241y','bncmss89s16g224z',13,'2027-04-24');
INSERT INTO trapianti VALUES (18,'brncrl23d11f241y','rnzfrn62l18g224z',10,'2027-05-04');
INSERT INTO trapianti VALUES (19,'brnmra28r05f241y','brnlcu80b24f241y',10,'2027-04-27');
INSERT INTO trapianti VALUES (20,'brlmrc16r21g224z','brnfrn92r25f241y',02,'2028-08-17');
INSERT INTO trapianti VALUES (21,'brlmss80d16f241y','vrdcrl16m11g224z',13,'2028-08-19');
INSERT INTO trapianti VALUES (22,'nrecrl15r04g224z','bnccrl29p02g224z',02,'2028-09-13');
INSERT INTO trapianti VALUES (23,'tttguo80s02f241y','csscrl14t18g224z',11,'2028-11-08');
INSERT INTO trapianti VALUES (25,'bncmra12c20f241y','vrdfrn94b24g224z',10,'2028-01-03');
INSERT INTO trapianti VALUES (26,'cssmra07h16f241y','brllbr60h21g224z',07,'2028-12-02');
INSERT INTO trapianti VALUES (27,'brnlbr96m09g224z','brnmss66h10f241y',11,'2028-01-20');
INSERT INTO trapianti VALUES (28,'bncguo96p16f241y','rssmrc25c08f241y',03,'2028-03-16');
INSERT INTO trapianti VALUES (29,'brnmra28r05f241y','csslcu82r26f241y',05,'2028-09-13');
INSERT INTO trapianti VALUES (41,'brlmra11h26g224z','rsscrl03l07g224z',10,'2028-10-23');
INSERT INTO trapianti VALUES (42,'brlmra11h26g224z','rsscrl03l07g224z',05,'2028-10-23');
INSERT INTO trapianti VALUES (43,'brlmra11h26g224z','csscrl14t18g224z',02,'2028-10-23');
INSERT INTO trapianti VALUES (44,'brlmra11h26g224z','rnzfrn62l18g224z',11,'2029-10-23');
INSERT INTO trapianti VALUES (45,'brlmra11h26g224z','rsscrl03l07g224z',06,'2029-10-23');
INSERT INTO trapianti VALUES (46,'brlmra11h26g224z','brlguo88b25g224z',07,'2029-10-23');

INSERT INTO assicurazioni VALUES ('vrdfrn94b24g224z',17999,'SERENITÀ MEDICA');
INSERT INTO assicurazioni VALUES ('brnfrn92r25f241y', 7999,'SERENITÀ MEDICA');
INSERT INTO assicurazioni VALUES ('bnclbr95a05f241y',17999,'SERENITÀ MEDICA');
INSERT INTO assicurazioni VALUES ('brnlbr96m09g224z',17999,'SERENITÀ MEDICA');
INSERT INTO assicurazioni VALUES ('bncmss89s16g224z',17999,'SERENITÀ MEDICA');
INSERT INTO assicurazioni VALUES ('nremss96t24g224z',17999,'SERENITÀ MEDICA');
INSERT INTO assicurazioni VALUES ('rnzmss95c15f241y',10999,'SERENITÀ MEDICA');
INSERT INTO assicurazioni VALUES ('bncguo96p16f241y',17999,'SERENITÀ MEDICA');
INSERT INTO assicurazioni VALUES ('brlguo88b25g224z',17999,'SERENITÀ MEDICA');
INSERT INTO assicurazioni VALUES ('rsscrl03l07g224z', 3999,'SERENITÀ MEDICA');
INSERT INTO assicurazioni VALUES ('vrdlcu68h01g224z',11999,'LSV'            );
INSERT INTO assicurazioni VALUES ('vrdgnn19r16f241y', 8799,'SDCO'           );
INSERT INTO assicurazioni VALUES ('rssfrn77a19g224z', 9999,'ROCOCO'         );
INSERT INTO assicurazioni VALUES ('tttgnn18a06f241y',19999,'ROCOCO'         );
INSERT INTO assicurazioni VALUES ('tttmra08c15g224z', 6999,'ABAB0+-'        );
INSERT INTO assicurazioni VALUES ('vrdlbr92t25f241y', 1999,'ABAB0+-'        );

INSERT INTO equipe_chirurgica VALUES (01, 'nremss96t24g224z');
INSERT INTO equipe_chirurgica VALUES (01, 'vrdfrn94b24g224z');
INSERT INTO equipe_chirurgica VALUES (01, 'cssmrc01m08g224z');
INSERT INTO equipe_chirurgica VALUES (01, 'rnzmss95c15f241y');
INSERT INTO equipe_chirurgica VALUES (02, 'bncmss89s16g224z');
INSERT INTO equipe_chirurgica VALUES (02, 'brnlbr96m09g224z');
INSERT INTO equipe_chirurgica VALUES (03, 'bncmss89s16g224z');
INSERT INTO equipe_chirurgica VALUES (04, 'bnclbr95a05f241y');
INSERT INTO equipe_chirurgica VALUES (04, 'vrdguo87m23f241y');
INSERT INTO equipe_chirurgica VALUES (05, 'vrdguo87m23f241y');
INSERT INTO equipe_chirurgica VALUES (05, 'brlguo88b25g224z');
INSERT INTO equipe_chirurgica VALUES (05, 'cssmrc01m08g224z');
INSERT INTO equipe_chirurgica VALUES (05, 'grblbr91l11g224z');
INSERT INTO equipe_chirurgica VALUES (06, 'rnzlbr86e16f241y');
INSERT INTO equipe_chirurgica VALUES (06, 'rnzmss95c15f241y');
INSERT INTO equipe_chirurgica VALUES (06, 'grbmrc00s25g224z');
INSERT INTO equipe_chirurgica VALUES (06, 'bncmss89s16g224z');
INSERT INTO equipe_chirurgica VALUES (07, 'vrdfrn94b24g224z');
INSERT INTO equipe_chirurgica VALUES (07, 'vrdlbr92t25f241y');
INSERT INTO equipe_chirurgica VALUES (07, 'brnlbr96m09g224z');
INSERT INTO equipe_chirurgica VALUES (07, 'vrdmra00t17f241y');
INSERT INTO equipe_chirurgica VALUES (08, 'rnzmra02e27g224z');
INSERT INTO equipe_chirurgica VALUES (09, 'rnzmra02e27g224z');
INSERT INTO equipe_chirurgica VALUES (09, 'rnzmss95c15f241y');
INSERT INTO equipe_chirurgica VALUES (10, 'cssmss91b01g224z');
INSERT INTO equipe_chirurgica VALUES (10, 'brlguo88b25g224z');
INSERT INTO equipe_chirurgica VALUES (10, 'vrdlbr92t25f241y');
INSERT INTO equipe_chirurgica VALUES (10, 'bnclbr95a05f241y');
INSERT INTO equipe_chirurgica VALUES (11, 'bncguo96p16f241y');
INSERT INTO equipe_chirurgica VALUES (11, 'rnzguo97a19g224z');
INSERT INTO equipe_chirurgica VALUES (12, 'nremra03d18f241y');
INSERT INTO equipe_chirurgica VALUES (12, 'tttcrl02s19g224z');
INSERT INTO equipe_chirurgica VALUES (12, 'brnlbr96m09g224z');
INSERT INTO equipe_chirurgica VALUES (12, 'rsscrl03l07g224z');
INSERT INTO equipe_chirurgica VALUES (13, 'rsscrl03l07g224z');
INSERT INTO equipe_chirurgica VALUES (14, 'brlguo88b25g224z');
INSERT INTO equipe_chirurgica VALUES (15, 'vrdlbr92t25f241y');
INSERT INTO equipe_chirurgica VALUES (15, 'rnzguo97a19g224z');
INSERT INTO equipe_chirurgica VALUES (16, 'nremra03d18f241y');
INSERT INTO equipe_chirurgica VALUES (16, 'rnzmss95c15f241y');
INSERT INTO equipe_chirurgica VALUES (16, 'brnlbr96m09g224z');
INSERT INTO equipe_chirurgica VALUES (17, 'bncguo96p16f241y');
INSERT INTO equipe_chirurgica VALUES (17, 'brnlbr96m09g224z');
INSERT INTO equipe_chirurgica VALUES (17, 'vrdguo87m23f241y');
INSERT INTO equipe_chirurgica VALUES (17, 'cssmrc01m08g224z');
INSERT INTO equipe_chirurgica VALUES (18, 'bncguo96p16f241y');
INSERT INTO equipe_chirurgica VALUES (18, 'tttlcu99p11f241y');
INSERT INTO equipe_chirurgica VALUES (18, 'brlguo88b25g224z');
INSERT INTO equipe_chirurgica VALUES (18, 'cssmss91b01g224z');
INSERT INTO equipe_chirurgica VALUES (19, 'vrdfrn94b24g224z');
INSERT INTO equipe_chirurgica VALUES (20, 'rnzlbr86e16f241y');
INSERT INTO equipe_chirurgica VALUES (21, 'rsscrl03l07g224z');
INSERT INTO equipe_chirurgica VALUES (21, 'vrdguo87m23f241y');
INSERT INTO equipe_chirurgica VALUES (21, 'vrdlbr92t25f241y');
INSERT INTO equipe_chirurgica VALUES (22, 'rnzguo97a19g224z');
INSERT INTO equipe_chirurgica VALUES (22, 'bncmss89s16g224z');
INSERT INTO equipe_chirurgica VALUES (22, 'bnclbr95a05f241y');
INSERT INTO equipe_chirurgica VALUES (22, 'brnlbr96m09g224z');
INSERT INTO equipe_chirurgica VALUES (23, 'vrdfrn94b24g224z');
INSERT INTO equipe_chirurgica VALUES (23, 'rnzmss95c15f241y');
INSERT INTO equipe_chirurgica VALUES (23, 'tttcrl02s19g224z');
INSERT INTO equipe_chirurgica VALUES (23, 'vrdmra00t17f241y');
INSERT INTO equipe_chirurgica VALUES (25, 'vrdguo87m23f241y');
INSERT INTO equipe_chirurgica VALUES (25, 'cssmrc01m08g224z');
INSERT INTO equipe_chirurgica VALUES (25, 'rnzmra02e27g224z');
INSERT INTO equipe_chirurgica VALUES (26, 'brnlbr96m09g224z');
INSERT INTO equipe_chirurgica VALUES (27, 'rsslbr98s02f241y');
INSERT INTO equipe_chirurgica VALUES (27, 'bncmss89s16g224z');
INSERT INTO equipe_chirurgica VALUES (27, 'grbmrc00s25g224z');
INSERT INTO equipe_chirurgica VALUES (27, 'tttcrl02s19g224z');
INSERT INTO equipe_chirurgica VALUES (28, 'vrdlbr92t25f241y');
INSERT INTO equipe_chirurgica VALUES (28, 'bncmss89s16g224z');
INSERT INTO equipe_chirurgica VALUES (28, 'nremra03d18f241y');
INSERT INTO equipe_chirurgica VALUES (29, 'tttlcu99p11f241y');
INSERT INTO equipe_chirurgica VALUES (29, 'rsslbr98s02f241y');
INSERT INTO equipe_chirurgica VALUES (29, 'grblcu85a27f241y');
INSERT INTO equipe_chirurgica VALUES (32, 'bnclbr95a05f241y');
INSERT INTO equipe_chirurgica VALUES (32, 'brnlbr96m09g224z');
INSERT INTO equipe_chirurgica VALUES (32, 'rnzmss95c15f241y');
INSERT INTO equipe_chirurgica VALUES (32, 'tttcrl02s19g224z');
INSERT INTO equipe_chirurgica VALUES (31, 'bncmss89s16g224z');
INSERT INTO equipe_chirurgica VALUES (31, 'cssmrc01m08g224z');
INSERT INTO equipe_chirurgica VALUES (31, 'rnzmra02e27g224z');
INSERT INTO equipe_chirurgica VALUES (36, 'rnzguo97a19g224z');
INSERT INTO equipe_chirurgica VALUES (36, 'vrdlbr92t25f241y');
INSERT INTO equipe_chirurgica VALUES (41, 'bncmss89s16g224z');
INSERT INTO equipe_chirurgica VALUES (41, 'rnzguo97a19g224z');
INSERT INTO equipe_chirurgica VALUES (41, 'tttcrl02s19g224z');
INSERT INTO equipe_chirurgica VALUES (42, 'bncmss89s16g224z');
INSERT INTO equipe_chirurgica VALUES (42, 'nremra03d18f241y');
INSERT INTO equipe_chirurgica VALUES (42, 'rsslbr98s02f241y');
INSERT INTO equipe_chirurgica VALUES (42, 'tttlcu99p11f241y');
INSERT INTO equipe_chirurgica VALUES (43, 'bnclbr95a05f241y');
INSERT INTO equipe_chirurgica VALUES (43, 'bncmss89s16g224z');
INSERT INTO equipe_chirurgica VALUES (43, 'brnlbr96m09g224z');
INSERT INTO equipe_chirurgica VALUES (43, 'nremra03d18f241y');
INSERT INTO equipe_chirurgica VALUES (43, 'vrdlbr92t25f241y');
INSERT INTO equipe_chirurgica VALUES (44, 'bnclbr95a05f241y');
INSERT INTO equipe_chirurgica VALUES (44, 'brnlbr96m09g224z');
INSERT INTO equipe_chirurgica VALUES (44, 'rnzmss95c15f241y');
INSERT INTO equipe_chirurgica VALUES (44, 'vrdfrn94b24g224z');
INSERT INTO equipe_chirurgica VALUES (45, 'vrdguo87m23f241y');
INSERT INTO equipe_chirurgica VALUES (45, 'vrdmra00t17f241y');
INSERT INTO equipe_chirurgica VALUES (46, 'bncmss89s16g224z');
INSERT INTO equipe_chirurgica VALUES (46, 'brnlbr96m09g224z');
INSERT INTO equipe_chirurgica VALUES (46, 'rsslbr98s02f241y');
INSERT INTO equipe_chirurgica VALUES (46, 'vrdfrn94b24g224z');
-- TO SORT

INSERT INTO lista_organi VALUES ('vrdmrc04d09f241y',05,'2025-07-14 00:00:00',   4);
INSERT INTO lista_organi VALUES ('vrdmss65r21g224z',13,'2025-04-06 00:00:00',  10);
INSERT INTO lista_organi VALUES ('grbfrn77p21g224z',01,'2025-07-16 00:00:00',   1);
INSERT INTO lista_organi VALUES ('bncmrc12e24f241y',11,'2025-02-10 00:00:00',NULL);
INSERT INTO lista_organi VALUES ('brncrl23d11f241y',03,'2025-04-24 00:00:00',   3);
INSERT INTO lista_organi VALUES ('brnmra28r05f241y',02,'2025-01-27 00:00:00',   1);
INSERT INTO lista_organi VALUES ('brlmrc16r21g224z',01,'2025-05-17 00:00:00',   1);
INSERT INTO lista_organi VALUES ('rnzfrn62l18g224z',11,'2024-04-20 00:00:00',   4);
INSERT INTO lista_organi VALUES ('vrdfrn94b24g224z',11,'2025-06-05 00:00:00',   7);
INSERT INTO lista_organi VALUES ('brllbr60h21g224z',11,'2025-03-22 00:00:00',   7);
INSERT INTO lista_organi VALUES ('brlmss80d16f241y',01,'2024-01-01 00:00:00',NULL);
INSERT INTO lista_organi VALUES ('brlmss80d16f241y',02,'2024-01-01 00:00:00',NULL);
INSERT INTO lista_organi VALUES ('brlmss80d16f241y',03,'2024-01-01 00:00:00',NULL);
INSERT INTO lista_organi VALUES ('brlmss80d16f241y',05,'2024-01-01 00:00:00',NULL);
INSERT INTO lista_organi VALUES ('brlmss80d16f241y',06,'2024-01-01 00:00:00',NULL);
INSERT INTO lista_organi VALUES ('brlmss80d16f241y',07,'2024-01-01 00:00:00',NULL);
INSERT INTO lista_organi VALUES ('brlmss80d16f241y',10,'2024-01-01 00:00:00',NULL);
INSERT INTO lista_organi VALUES ('brlmss80d16f241y',11,'2024-01-01 00:00:00',NULL);
INSERT INTO lista_organi VALUES ('brlmss80d16f241y',12,'2024-01-01 00:00:00',NULL);

-- CREAZIONE INDICI
CREATE INDEX idx_massimale ON assicurazioni (massimale);
CREATE INDEX idx_lista_attesa_pr ON lista_organi USING hash (priorita);
CREATE INDEX idx_lista_attesa_do ON lista_organi USING hash (data_ora);

-- QUERY

-- 1 Trapianti con ricevente (CF) e donatore (CF) aventi gruppi sanguigni non compatibili
-- VINCOLO NON ESPRIMIBILE IN SQL, DOVREBBE SEMPRE ESSERE VUOTA
SELECT errori.ricevente, riceventi.gruppo_sanguigno AS gruppo_ricevente, errori.donatore, donatori.gruppo_sanguigno AS gruppo_donatore
FROM (SELECT trapianti.ricevente, trapianti.donatore
	FROM trapianti, pazienti AS riceventi, pazienti AS donatori
	EXCEPT (SELECT donatori.donatore, riceventi.ricevente
		FROM (SELECT pazienti.codice_fiscale AS donatore, pazienti.gruppo_sanguigno AS gruppo_donatore
			FROM pazienti) AS donatori, compatibilita,
			(SELECT pazienti.codice_fiscale AS ricevente, pazienti.gruppo_sanguigno AS gruppo_ricevente
			FROM pazienti) AS riceventi
		WHERE donatori.gruppo_donatore = compatibilita.gruppo_donatore
		AND riceventi.gruppo_ricevente = compatibilita.gruppo_ricevente)) AS errori, pazienti AS riceventi, pazienti AS donatori
WHERE errori.ricevente = riceventi.codice_fiscale
AND errori.donatore = donatori.codice_fiscale;

-- 2 Costo medio dello staff medico necessario per il trapianto di ciascun organo
SELECT organi.nome AS organo, AVG(equipe.costo_equipe) AS costo_medio_equipe
FROM (SELECT equipe_chirurgica.trapianto, SUM(personale_medico.compenso) AS costo_equipe
	FROM equipe_chirurgica, personale_medico
	WHERE personale_medico.codice_fiscale = equipe_chirurgica.membro_equipe
	GROUP BY (trapianto)) AS equipe, trapianti, organi
WHERE trapianti.id = equipe.trapianto
AND trapianti.organo = organi.id
GROUP BY organi.nome;

-- 3(P) Costo a carico del ricevente (non coperto dall'assicurazione) per un trapianto (parametro = ID trapianto)
SELECT CASE
		WHEN costo_trapianto.massimale IS NULL
		THEN costo_trapianto.costo_trapianto
		WHEN costo_trapianto.costo_trapianto > costo_trapianto.massimale
		THEN costo_trapianto.costo_trapianto - costo_trapianto.massimale
		ELSE 0
	END
	AS costo_paziente
FROM (SELECT costo_trapianto.paziente, costo_trapianto.costo_trapianto, assicurazioni.massimale
	FROM (SELECT costo_staff.paziente, organi.costo + costo_staff.costo_equipe AS costo_trapianto
		FROM (SELECT compenso_equipe.paziente, compenso_equipe.organo, SUM(compenso) AS costo_equipe
			FROM (SELECT equipe.paziente, equipe.membro_equipe, personale_medico.compenso, equipe.organo
				FROM (SELECT trapianti.ricevente AS paziente, equipe_chirurgica.membro_equipe, trapianti.organo
					FROM equipe_chirurgica
					JOIN trapianti
					ON equipe_chirurgica.trapianto = trapianti.id
					WHERE trapianti.id = 2) -- ID trapianto parametrico
					AS equipe, personale_medico
				WHERE equipe.membro_equipe = personale_medico.codice_fiscale)
				AS compenso_equipe
			GROUP BY (compenso_equipe.paziente, compenso_equipe.organo)) AS costo_staff, organi
		WHERE organi.id = costo_staff.organo) AS costo_trapianto
	LEFT JOIN assicurazioni
	ON costo_trapianto.paziente = assicurazioni.cliente) AS costo_trapianto;

-- 4(P) Trapianti (passati e futuri = già programmati) di un paziente (parametro = CF paziente)
SELECT organi.nome AS organo, trapianti_paziente.data, anagrafiche.cognome AS cognome_donatore, anagrafiche.nome AS nome_donatore
FROM (SELECT trapianti.organo, trapianti.data, trapianti.donatore
	FROM trapianti
	WHERE ricevente = '01234567890') AS trapianti_paziente, organi, anagrafiche -- CF ricevente parametrico
WHERE organi.id = trapianti_paziente.organo
AND anagrafiche.codice_fiscale = trapianti_paziente.donatore;

-- 5 Trapianti (e mansione che viola il vincolo per quel trapianto) con membri del personale medico senza compenso (tirocinanti) e senza membri del personale medico con stessa mansione dei tirocinanti e compenso > 0 (non tirocinanti = supervisori)
-- VINCOLO NON ESPRIMIBILE IN SQL, DOVREBBE SEMPRE ESSERE VUOTA
SELECT DISTINCT trapianti.id AS id_trapianto, personale_medico.mansione
FROM trapianti, personale_medico, equipe_chirurgica
WHERE trapianti.id = equipe_chirurgica.trapianto
AND equipe_chirurgica.membro_equipe = personale_medico.codice_fiscale
EXCEPT (SELECT DISTINCT trapianti_equipe1.id AS id_trapianto, trapianti_equipe1.mansione
		FROM (SELECT trapianti.id, personale_medico.mansione, personale_medico.compenso
			FROM trapianti, personale_medico, equipe_chirurgica
			WHERE trapianti.id = equipe_chirurgica.trapianto
			AND personale_medico.codice_fiscale = equipe_chirurgica.membro_equipe) AS trapianti_equipe1
		JOIN (SELECT trapianti.id, personale_medico.mansione, personale_medico.compenso
			FROM trapianti, personale_medico, equipe_chirurgica
			WHERE trapianti.id = equipe_chirurgica.trapianto
			AND personale_medico.codice_fiscale = equipe_chirurgica.membro_equipe) AS trapianti_equipe2
		ON trapianti_equipe1.id = trapianti_equipe2.id
		AND trapianti_equipe1.mansione = trapianti_equipe2.mansione
		AND ((trapianti_equipe1.compenso = 0 AND trapianti_equipe2.compenso <> 0)
			 OR trapianti_equipe1.compenso <> 0)
	ORDER BY id_trapianto)
ORDER BY id_trapianto;

-- 6 Per ogni organo disponibile e per ogni paziente in lista d'attesa mostrare tutti i possibili abbinamenti ricevente-donatore con gruppo sanguigno compatibile e ordinare i risultati in base ad organo, priorità e data inserimento in lista d'attesa
SELECT abbinamenti.ricevente, abbinamenti.gruppo_ricevente, organi.nome AS organo, abbinamenti.priorita, abbinamenti.data_ora,
	abbinamenti.donatore, abbinamenti.gruppo_donatore
FROM (SELECT richieste.ricevente, richieste.gruppo_ricevente, richieste.organo_richiesto, richieste.priorita, richieste.data_ora,
		disponibilita.donatore, disponibilita.gruppo_donatore
	FROM (SELECT lista_organi.paziente AS ricevente, pazienti.gruppo_sanguigno AS gruppo_ricevente, lista_organi.organo AS organo_richiesto,
			lista_organi.priorita, lista_organi.data_ora
		FROM lista_organi, pazienti
		WHERE priorita IS NOT NULL
		AND lista_organi.paziente = pazienti.codice_fiscale
		ORDER BY lista_organi.priorita DESC, lista_organi.data_ora ASC) AS richieste
	JOIN compatibilita
	ON richieste.gruppo_ricevente = compatibilita.gruppo_ricevente
	JOIN (SELECT lista_organi.paziente AS donatore, pazienti.gruppo_sanguigno AS gruppo_donatore, lista_organi.organo AS organo_disponibile
		FROM lista_organi, pazienti
		WHERE priorita IS NULL
		AND lista_organi.paziente = pazienti.codice_fiscale) AS disponibilita
	ON disponibilita.gruppo_donatore = compatibilita.gruppo_donatore
	WHERE richieste.organo_richiesto = disponibilita.organo_disponibile) AS abbinamenti, organi
WHERE abbinamenti.organo_richiesto = organi.id
ORDER BY organo ASC, priorita DESC, data_ora ASC, ricevente ASC;

-- 7(P) Pazienti che hanno subito più di un trapianto durante un anno specifico (parametro = anno)
SELECT anagrafiche.nome, anagrafiche.cognome, COUNT(trapianti.ricevente) AS n_trapianti
FROM anagrafiche, trapianti
WHERE anagrafiche.codice_fiscale = trapianti.ricevente
AND EXTRACT(YEAR FROM trapianti.data) = 2024 -- Anno parametrico
GROUP BY anagrafiche.nome, anagrafiche.cognome
HAVING COUNT(trapianti.ricevente) > 1;

