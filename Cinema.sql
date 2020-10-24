############################################################################
################      Script per progetto BDSI 2019/20     #################
############################################################################
#
# GRUPPO FORMATO DA:
#
# Matricola:5951846      Cognome: Levi	       Nome: Camillo     
# Matricola:6145327      Cognome: Michielin	       Nome: Nicole       
#
############################################################################




############################################################################
################   Creazione schema e vincoli database     #################
############################################################################

create database if not exists Cinema;

use Cinema;

SET SQL_SAFE_UPDATES=0;

DROP TABLE IF EXISTS tariffe;
DROP TABLE IF EXISTS biglietti;
DROP TABLE IF EXISTS proiezioni;
DROP TABLE IF EXISTS turno_addetto_pulizie;
DROP TABLE IF EXISTS turno_coordinatore;
DROP TABLE IF EXISTS turno_macchinista;
DROP TABLE IF EXISTS turni;
DROP TABLE IF EXISTS sale;
DROP TABLE IF EXISTS addetti_alle_pulizie;
DROP TABLE IF EXISTS coordinatori;
DROP TABLE IF EXISTS macchinisti;
DROP TABLE IF EXISTS film;
DROP TABLE IF EXISTS produttori;
DROP TABLE IF EXISTS errore_film;
DROP TABLE IF EXISTS errore_biglietti;
DROP PROCEDURE IF EXISTS elimina_film;
DROP PROCEDURE IF EXISTS last_ticket
DROP FUNCTION IF EXISTS incasso;
DROP VIEW IF EXISTS proiezioni_in_sala ;

CREATE TABLE produttori (
  id int(4) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  nome varchar(255) NOT NULL,
  cognome varchar(255) NOT NULL,
  ruolo enum('Regista','Attore') NOT NULL
) ENGINE=InnoDB;

CREATE TABLE film (
  id int(4) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  titolo varchar(255) NOT NULL,
  anno_uscita int(4) NOT NULL,
  durata int(4) NOT NULL,
  id_attore int(4) NOT NULL,
FOREIGN KEY(id_attore) REFERENCES Produttori(id) ON UPDATE CASCADE ON DELETE CASCADE,
  id_regista int(4) NOT NULL,
FOREIGN KEY(id_regista) REFERENCES Produttori(id) ON UPDATE CASCADE ON DELETE CASCADE,
  3D enum('sì','no') NOT NULL,
  prima_proiezione datetime NOT NULL
) ENGINE=InnoDB;

CREATE TABLE macchinisti (
  cf varchar(16) NOT NULL PRIMARY KEY,
  nome varchar(255) NOT NULL,
  cognome varchar(255) NOT NULL,
  iban varchar(27) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE coordinatori (
  cf varchar(16) NOT NULL PRIMARY KEY,
  nome varchar(255) NOT NULL,
  cognome varchar(255) NOT NULL,
  iban varchar(27) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE addetti_alle_pulizie (
  cf varchar(16) NOT NULL PRIMARY KEY,
  nome varchar(255) NOT NULL,
  cognome varchar(255) NOT NULL,
  iban varchar(27) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE sale(
  id int(4) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  nome varchar(255) NOT NULL,
  numero_posti int(11) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE turni (
  id int(4) NOT NULL AUTO_INCREMENT,
  id_sala int(4) NOT NULL,
FOREIGN KEY (id_sala) REFERENCES sale(id) ON UPDATE CASCADE ON DELETE CASCADE,
  cf_macchinista varchar(16) NOT NULL,
FOREIGN KEY (cf_macchinista) REFERENCES macchinisti(cf) ON UPDATE CASCADE ON DELETE CASCADE,
   cf_addetto_pulizie varchar(16) NOT NULL,
FOREIGN KEY(cf_addetto_pulizie) REFERENCES addetti_alle_pulizie(cf) ON UPDATE CASCADE ON DELETE CASCADE,
   cf_coordinatore varchar(16) NOT NULL,
FOREIGN KEY(cf_coordinatore) REFERENCES coordinatori(cf) ON UPDATE CASCADE ON DELETE CASCADE,
  data_inizio datetime NOT NULL,
  data_fine datetime NOT NULL,
  PRIMARY KEY(id, id_sala)
) ENGINE=InnoDB;

CREATE TABLE turno_macchinista (
	id_turno int(4),
    FOREIGN KEY (id_turno) REFERENCES turni(id) ON UPDATE CASCADE ON DELETE CASCADE,
	cf_macchinista varchar(16),
    FOREIGN KEY (cf_macchinista) REFERENCES macchinisti(cf) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY(id_turno, cf_macchinista)
)ENGINE=InnoDB;

CREATE TABLE turno_coordinatore (
	id_turno int(4),
    FOREIGN KEY (id_turno) REFERENCES turni(id) ON UPDATE CASCADE ON DELETE CASCADE,
	cf_coordinatore varchar(16),
    FOREIGN KEY (cf_coordinatore) REFERENCES coordinatori(cf) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY(id_turno, cf_coordinatore)
)ENGINE=InnoDB;

CREATE TABLE turno_addetto_pulizie (
	id_turno int(4),
    FOREIGN KEY (id_turno) REFERENCES turni(id) ON UPDATE CASCADE ON DELETE CASCADE,
	cf_addetto_pulizie varchar(16),
    FOREIGN KEY (cf_addetto_pulizie) REFERENCES addetti_alle_pulizie(cf) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY(id_turno, cf_addetto_pulizie)
)ENGINE=InnoDB;


CREATE TABLE proiezioni (
  id int(4) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  id_sala int(4) NOT NULL,
FOREIGN KEY(id_sala) REFERENCES sale(id) ON UPDATE CASCADE ON DELETE CASCADE,
  id_film int(4) NOT NULL,
FOREIGN KEY(id_film) REFERENCES film(id) ON UPDATE CASCADE ON DELETE CASCADE,
  posti_disponibili int (4) NOT NULL,
  data_inizio datetime NOT NULL,
  data_fine datetime NOT NULL
) ENGINE=InnoDB;


CREATE TABLE biglietti (
  id int(4) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  id_proiezione int(4) NOT NULL,
FOREIGN KEY(id_proiezione) REFERENCES proiezioni(id) ON UPDATE CASCADE ON DELETE CASCADE,
  numero_posto int(4) NOT NULL,
  tipo_tariffa enum('Intero','Ridotto','Intero 3D','Ridotto 3D') NOT NULL,
  prezzo decimal(4,2) NULL
) ENGINE=InnoDB;


CREATE TABLE tariffe (
	tariffa VARCHAR(15) NOT NULL PRIMARY KEY,
    prezzo decimal(4,2)
) ENGINE=InnoDB;



#############################################################################
################  Ulteriori vncoli tramite viste e/o trigger ################
#############################################################################




CREATE TRIGGER assegna_posti_sala
BEFORE INSERT 
ON proiezioni
FOR EACH ROW
SET new.posti_disponibili = (
	SELECT numero_posti FROM sale 
    WHERE id = new.id_sala
    );


CREATE TRIGGER assegna_prezzo
BEFORE INSERT
ON biglietti
FOR EACH ROW
SET NEW.prezzo = (
	SELECT prezzo FROM tariffe
    WHERE tariffa = NEW.tipo_tariffa);
  
  
CREATE TRIGGER diminuisci_posti
AFTER INSERT
ON biglietti
FOR EACH ROW
UPDATE proiezioni 
	set posti_disponibili = posti_disponibili-1
	WHERE id = new.id_proiezione;


CREATE VIEW proiezioni_in_sala AS
	SELECT S.nome, F.titolo from proiezioni P, film F, sale S
	WHERE S.id=P.id_sala and F.id=P.id_film
	order by S.nome
	WITH CHECK OPTION;


############################################################################
################  Creazione istanza: popolamento database  #################
############################################################################

insert into produttori (nome, cognome, ruolo) values
('Jack','Nicholson', 'Attore'),
('Stanley','Kubrick','Regista'),
('Leonardo','DiCaprio','Attore'),
('Quentin','Tarantino','Regista'),
('Russell','Crowe','Attore'),
('Ridley','Scott','Regista'),
('Christian','Bale','Attore'),
('Christopher','Nolan','Regista'),
('Clint','Eastwood','Attore'),
('Sergio','Leone','Regista');


insert into film (titolo, anno_uscita, durata, id_attore, id_regista, 3D, prima_proiezione) values
('shining', 1980, 119, 1, 2, 'no', '2019-03-01 12:00:00'),
('Django unchained', 2012, 165, 3, 4, 'no', '2020-05-01 12:00:00'),
('per un pugno di dollari', 1964, 100, 9, 10, 'no', '2020-04-01 12:00:00'),
('Il gladiatore', 2000, 170, 5, 6, 'sì', '2020-05-01 12:00:00'),
('Batman begins', 2005, 140, 7, 8, 'sì', '2020-05-01 12:00:00');


insert into macchinisti (cf, nome, cognome, iban) values 
('RSSMRC90F15D612F','Marco','Rossi','IT123123123123'),
('VRDGLI92A63S331Z','Giulia','Verdi','IT124124124124'),
('NREFRC90D52D612G','Franca','Neri','IT125125125125'),
('RRARSS90D52D612G','Aurora','Rossi','IT125125125185');


insert into addetti_alle_pulizie (cf, nome, cognome, iban) values 
('CLSMRC89G69S452L','Marco','Celestino','IT123123123123'),
('GRGGPP89G69S452L','Giuseppe','Grigi', 'IT127127127127'),
('CHRGDI89G69S452L','Giada','Chiara', 'IT127127127127'),
('RNCGRN92A63S331Z','Geronimo','Arancioni','IT128128128128');


insert into coordinatori (cf, nome, cognome, iban) values 
('BNCVNN89G69S452L','Vanni','Bianchi', 'IT126126126126'),
('GLLMRC89P30F552A','Marcello','Gialli','IT130130130130'),
('BNCMTT89G69S452L','Matteo','Bianco', 'IT126126126126'),
('CLSCRM89P30F552A','Carmela','Celesti','IT129129129129');



insert into sale (nome, numero_posti) values
('Auriga',100),
('Ariete',80),
('Cassiopea',60),
('Dragone',50);


insert into turni (id_sala, cf_macchinista, cf_addetto_pulizie, cf_coordinatore, data_inizio, data_fine) values
(1,'RSSMRC90F15D612F', 'CLSMRC89G69S452L','BNCVNN89G69S452L', '2020-07-01 12:00:00', '2020-07-01 20:00:00'),
(2,'VRDGLI92A63S331Z', 'GRGGPP89G69S452L','GLLMRC89P30F552A','2020-07-01 12:00:00', '2020-07-01 19:00:00'),
(3,'NREFRC90D52D612G','CHRGDI89G69S452L','BNCMTT89G69S452L','2020-07-01 16:00:00', '2020-07-02 00:30:00'),
(4,'RRARSS90D52D612G','RNCGRN92A63S331Z','CLSCRM89P30F552A','2020-07-01 20:00:00', '2020-07-04 00:00:00');


insert into proiezioni (id_sala, id_film, data_inizio, data_fine) values
(1, 1, '2020-07-01 12:00:00', '2020-07-01 15:00:00'),
(1, 2, '2020-07-01 16:00:00', '2020-07-01 19:00:00'),
(2, 3, '2020-07-01 12:00:00', '2020-07-01 14:00:00'),
(2, 5, '2020-07-01 15:00:00', '2020-07-01 18:00:00'),
(3, 5, '2020-07-01 16:00:00', '2020-07-01 19:00:00'),
(4, 4, '2020-07-01 20:00:00', '2020-07-01 23:30:00'),
(3, 4, '2020-07-01 21:00:00', '2020-07-02 00:00:00');


insert into tariffe (tariffa, prezzo) values
('intero', 10.00),
('ridotto', 7.00),
('intero 3D', 13.00),
('ridotto 3D', 9.00);


insert into biglietti (id_proiezione, numero_posto, tipo_tariffa) values
(1, 101, 'intero'),
(1, 102, 'intero'),
(1, 205, 'intero'),
(1, 206, 'intero'),
(1, 207, 'intero'),
(1, 311, 'intero'),
(1, 312, 'intero'),
(1, 111, 'intero'),
(1, 113, 'intero'),
(2, 109, 'intero'),
(2, 306, 'intero'),
(2, 307, 'intero'),
(2, 101, 'intero'),
(2, 213, 'intero'),
(2, 204, 'intero'),
(2, 201, 'intero'),
(2, 312, 'intero'),
(3, 101, 'intero'),
(3, 102, 'ridotto'),
(3, 103, 'ridotto'),
(3, 208, 'intero'),
(3, 211, 'intero'),
(3, 212, 'intero'),
(3, 418, 'intero'),
(3, 419, 'ridotto'),
(3, 420, 'ridotto'),
(3, 310, 'intero'),
(3, 307, 'intero'),
(3, 308, 'intero'),
(3, 309, 'ridotto'),
(4, 108, 'intero 3D'),
(4, 109, 'intero 3D'),
(4, 110, 'intero 3D'),
(4, 208, 'intero 3D'),
(4, 209, 'ridotto 3D'),
(4, 210, 'ridotto 3D'),
(4, 211, 'intero 3D');


############################################################################
################ 				 Interrogazioni   		   #################
############################################################################

# selezionare tutti i film che sono in 3D
select * from film where 3D='si'; 


# selezionare in ordine crescente id della sala e data e orario finali delle proiezioni aventi 80 o più posti disponibili
SELECT id_sala, data_fine from proiezioni where posti_disponibili>=80 order by id_sala ;


# selezionare in ordine decrescente l' id dell'attore e il titolo dei film che sono usciti dopo il 2000
select id_attore, titolo from film where anno_uscita > 2000 order by id desc;


# selezionare in ordine crescente gli id delle sale e la somma dei rispettivi posti disponibili per ogni proiezione
SELECT id_sala, sum(posti_disponibili) from proiezioni group by id_sala order by id_sala;


# selezionare l'anno di uscita e i posti disponibili di tutti i film che sono in proiezione (join implicito)
select f.anno_uscita, p.posti_disponibili from film f, proiezioni p where f.id=p.id_film;


# selezionare l'anno di uscita e i posti disponibili di tutti i film che sono in proiezione (join esplicito)
select f.anno_uscita, p.posti_disponibili from film f join proiezioni p on f.id=p.id_film;


# selezionare id,nome e cognome dei registi delle proiezioni che hanno più di 60 posti disponibili
select p.id, p.nome,p.cognome from produttori p where p.id IN (select f.id_regista from film f, proiezioni pr where f.id=pr.id_film and posti_disponibili > 60);


# selezionare id e titoli dei film, dividendoli in "film vecchio" o "film nuovo" a seconda che il film sia uscito prima del 2005 o dopo
select id, titolo, if(anno_uscita <2005, "Film vecchio", "Film nuovo") as TipoDiFilm from film;


############################################################################
################          Procedure e funzioni             #################
############################################################################

create table errore_film (msg CHAR(100));

DELIMITER $$
CREATE PROCEDURE elimina_film ()
BEGIN
	DECLARE EXIT HANDLER FOR 1051
    INSERT INTO errore_film VALUES ('La tabella Film non esiste');
	DELETE  FROM film 
	WHERE prima_proiezione < (now() - interval 30 day);
END
$$

DELIMITER ;

create table errore_biglietti(msg CHAR(100));

DELIMITER $$

CREATE FUNCTION incasso()
RETURNS INT
NO SQL
BEGIN
	DECLARE EXIT HANDLER FOR 1051
	INSERT INTO errore_biglietti VALUES('La tabella Biglietti non esiste');
	RETURN (SELECT SUM(prezzo) AS incasso FROM biglietti);
END
$$

DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE last_ticket (OUT ultimo_ticket VARCHAR(50))
BEGIN
	DECLARE numero VARCHAR(20);
    DECLARE tariffa VARCHAR(20);
    DECLARE flag INT;
    DECLARE cursore CURSOR FOR
		SELECT numero_posto, tipo_tariffa FROM Biglietti;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET flag =1;
    OPEN cursore;
    REPEAT 
		FETCH cursore INTO numero, tariffa;
        UNTIL flag=1
	END REPEAT;
    CLOSE cursore;
    SET ultimo_ticket = CONCAT ('posto numero', numero, 'di tipo', tariffa);
END $$
DELIMITER ;
