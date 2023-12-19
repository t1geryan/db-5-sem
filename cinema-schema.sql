-- region creating schema

DROP SCHEMA IF EXISTS cinema_schema CASCADE;
CREATE SCHEMA IF NOT EXISTS cinema_schema AUTHORIZATION movsisian_tg;
COMMENT ON SCHEMA cinema_schema IS 'cinema schema';
GRANT ALL ON SCHEMA cinema_schema TO movsisian_tg;
ALTER ROLE movsisian_tg IN DATABASE movsisian_tg_db SET search_path TO cinema_schema, public;

-- endregion
-- region deleting tables

DROP TABLE IF EXISTS soled_tickets;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS halls;
DROP TABLE IF EXISTS directors;
DROP TABLE IF EXISTS cash_registers;
DROP TABLE IF EXISTS cashiers;


-- endregion 
-- region creating tables


CREATE TABLE IF NOT EXISTS movies (
	id serial NOT NULL,
	name_eng TEXT NOT NULL,
	name_rus TEXT NOT NULL,
	release_year int NOT NULL,
	tagline TEXT NOT NULL,
	duration_seconds integer NOT NULL,
	director integer NOT NULL,
	CONSTRAINT movies_pk PRIMARY KEY (id),
	CONSTRAINT movies_duration_check CHECK (duration_seconds > 0)
) WITH (
  OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS cash_registers (
	id serial NOT NULL,
	num integer NOT NULL,
	work_start TIME NOT NULL,
	work_end TIME NOT NULL,
	cashier integer,
	CONSTRAINT cash_registers_pk PRIMARY KEY (id),
	CONSTRAINT cash_registers_num_unq UNIQUE (num)
) WITH (
  OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS directors (
	id serial NOT NULL,
	name TEXT NOT NULL,
	surname TEXT NOT NULL,
	CONSTRAINT directors_pk PRIMARY KEY (id)
) WITH (
  OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS cashiers (
	id serial NOT NULL,
	name TEXT NOT NULL,
	surname TEXT NOT NULL,
	CONSTRAINT cashiers_pk PRIMARY KEY (id)
) WITH (
  OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS halls (
	id serial NOT NULL,
	num integer NOT NULL,
	capacity integer NOT NULL,
	screen_size_inches int NOT NULL,
	square float4 NOT NULL,
	CONSTRAINT halls_pk PRIMARY KEY (id),
	CONSTRAINT halls_num_unq UNIQUE (num),
	CONSTRAINT halls_capacity_check CHECK (capacity > 0),
	CONSTRAINT halls_square_check CHECK (square > 0),
	CONSTRAINT halls_screen_size_check CHECK (screen_size_inches > 0)
) WITH (
  OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS sessions (
	id serial NOT NULL,
	start_datetime TIMESTAMP NOT NULL,
	end_datetime TIMESTAMP NOT NULL,
	movie integer,
	hall integer,
	CONSTRAINT sessions_pk PRIMARY KEY (id),
	CONSTRAINT sessions_hall_and_datetime_unq UNIQUE (hall, start_datetime, end_datetime),
	CONSTRAINT sessions_end_datetime_check CHECK (end_datetime > start_datetime)
) WITH (
  OIDS=FALSE
);



CREATE TABLE IF NOT EXISTS soled_tickets (
	id serial NOT NULL,
	session integer NOT NULL,
	cost_rub numeric(10,2) NOT NULL,
	place_num integer NOT NULL,
	cash_register integer,
	CONSTRAINT soled_tickets_pk PRIMARY KEY (id),
	CONSTRAINT soled_tickets_session_place_unq UNIQUE (session, place_num),
	CONSTRAINT soled_tickets_place_number_check CHECK (place_num > 0),
	CONSTRAINT soled_tickets_place_cost_check CHECK (cost_rub > 0)
) WITH (
  OIDS=FALSE
);


-- endregion
-- region comments 

COMMENT ON TABLE movies IS 'movies';
COMMENT ON COLUMN movies.id IS 'movie primary key id';
COMMENT ON COLUMN movies.name_eng IS 'movie name on english';
COMMENT ON COLUMN movies.name_rus IS 'movie name on russian';
COMMENT ON COLUMN movies.release_year IS 'movie realease year';
COMMENT ON COLUMN movies.tagline IS 'movie tagline';
COMMENT ON COLUMN movies.duration_seconds IS 'movie duration in seconds';
COMMENT ON COLUMN movies.director IS 'movie director foregin key id';

COMMENT ON TABLE cash_registers IS 'cash registers';
COMMENT ON COLUMN cash_registers.id IS 'cash register primary key id';
COMMENT ON COLUMN cash_registers.num IS 'cash register unique number';
COMMENT ON COLUMN cash_registers.work_start IS 'cash register time of work start (HH:MM:SS)';
COMMENT ON COLUMN cash_registers.work_end IS 'cash register time of work end (HH:MM:SS)';
COMMENT ON COLUMN cash_registers.cashier IS 'cash register foregin key cashier id';

COMMENT ON TABLE directors IS 'directors';
COMMENT ON COLUMN directors.id IS 'director primary key id';
COMMENT ON COLUMN directors.name IS 'director name';
COMMENT ON COLUMN directors.surname IS 'director surname';

COMMENT ON TABLE cashiers IS 'cashiers';
COMMENT ON COLUMN cashiers.id IS 'cashier primary key id';
COMMENT ON COLUMN cashiers.name IS 'cashier name';
COMMENT ON COLUMN cashiers.surname IS 'cashier surname';

COMMENT ON TABLE halls IS 'halls';
COMMENT ON COLUMN halls.id IS 'hall primary key id';
COMMENT ON COLUMN halls.num IS 'hall unique number';
COMMENT ON COLUMN halls.capacity IS 'hall maximum persons count';
COMMENT ON COLUMN halls.screen_size_inches IS 'hall screen size in inches';
COMMENT ON COLUMN halls.square IS 'hall square';

COMMENT ON TABLE sessions IS 'sessions';
COMMENT ON COLUMN sessions.id IS 'session primary key id';
COMMENT ON COLUMN sessions.start_datetime IS 'session start timestamp';
COMMENT ON COLUMN sessions.end_datetime IS 'session end timestamp';
COMMENT ON COLUMN sessions.movie IS 'session movie foreign key id';
COMMENT ON COLUMN sessions.hall IS 'session hall foreign key id';

COMMENT ON TABLE soled_tickets IS 'soled tickets';
COMMENT ON COLUMN soled_tickets.id IS 'soled tickets primary key id';
COMMENT ON COLUMN soled_tickets.session IS 'soled tickets session foreign key id';
COMMENT ON COLUMN soled_tickets.cost_rub IS 'soled tickets cost in russian rubles';
COMMENT ON COLUMN soled_tickets.place_num IS 'soled tickets place number';
COMMENT ON COLUMN soled_tickets.cash_register IS 'soled tickets cash register foregin key id';

-- endregion 
-- region foregin keys

ALTER TABLE movies
    ADD CONSTRAINT movies_to_directors
    FOREIGN KEY (director)
    REFERENCES directors(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE;


ALTER TABLE cash_registers
    ADD CONSTRAINT cash_registers_to_cashiers
    FOREIGN KEY (cashier) 
    REFERENCES cashiers(id)
    ON UPDATE CASCADE
    ON DELETE SET NULL;

ALTER TABLE sessions
    ADD CONSTRAINT sessions_to_movies 
    FOREIGN KEY (movie) 
    REFERENCES movies(id)
    ON UPDATE CASCADE
    ON DELETE SET NULL;

ALTER TABLE sessions
    ADD CONSTRAINT sessions_to_halls
    FOREIGN KEY (hall)
    REFERENCES halls(id)
    ON UPDATE CASCADE
    ON DELETE SET NULL;

ALTER TABLE soled_tickets
    ADD CONSTRAINT soled_tickets_to_sessions
    FOREIGN KEY (session) 
    REFERENCES sessions(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE;

ALTER TABLE soled_tickets
    ADD CONSTRAINT soled_tickets_to_cash_registers 
    FOREIGN KEY (cash_register) 
    REFERENCES cash_registers(id)
    ON UPDATE CASCADE
    ON DELETE SET NULL;


-- endregion
-- region data filling

INSERT INTO directors (id, name, surname) VALUES 
		(1, 'Alfred', 'Hitchcock'),
		(2, 'Martin', 'Scorsese'),
		(3, 'Steven', 'Spielberg'),
		(4, 'Quentin', ' Tarantino'),
		(5, 'Christopher', 'Nolan');

INSERT INTO cashiers (id, name, surname) VALUES
	(1, 'Ivan', 'Ischenko'),
	(2, 'Andrew', 'Vasilenko'),
	(3, 'Nikolay', 'Vladimirov'),
	(4, 'Anastasia', 'Kuznetsova');

INSERT INTO cash_registers (id, num, work_start, work_end, cashier) VALUES
	(1, 7, '12:00:00', '00:00:00', 2),
	(2, 9, '12:00:00', '00:00:00', 3),
	(3, 1, '14:00:00', '02:00:00', 4),
	(4, 2, '14:00:00', '02:00:00', 1),
	(5, 4, '10:00:00', '22:00:00', 1),
	(6, 3, '8:00:00', '20:00:00', 3);

INSERT INTO movies (id, name_eng, name_rus, release_year, tagline, duration_seconds, director) VALUES
	(1, 'Kill Bill', 'Убить Билла', 2003, 'In the year 2003, Uma Thurman will kill Bill.', 7253, 4),
	(2, 'Django The Unchained', 'Джанго освобождённый', 2012, 'Life, liberty and the pursuit of vengeance.', 8312, 4),
	(3, 'Inception', 'Начало', 2010, 'Your mind is the scene of the crime.', 6931, 5),
	(4, 'Schindlers List', 'Список Шиндлера', 1993, 'Whoever saves one life, saves the world entire.', 7341, 3),
	(5, 'Psycho', 'Психо', 1960, 'Exploring the blackness of the subconscious man!', 7124, 1),
	(6, 'The Irishman', 'Ирландец', 2019, 'His story changed history.', 9831, 2);

INSERT INTO halls (id, num, capacity, screen_size_inches, square) VALUES
	(1, 1, 128, 100, 316.24),
	(2, 2, 250, 120, 543.75),
	(3, 3, 16, 140, 120.12),
	(4, 4, 145, 100, 345.55);

INSERT INTO sessions (id, start_datetime, end_datetime, movie, hall) VALUES
	(1, '2023-10-25 11:45:00', '2023-10-25 13:35:00', 1, 1),
	(2, '2023-6-25 13:25:00', '2023-6-25 15:35:00', 2, 3),
	(3, '2023-8-29 16:40:00', '2023-8-29 19:45:00', 6, 4),
	(4, '2025-11-29 15:05:00', '2025-11-29 17:35:00', 5, 2),
	(5, '2025-6-30 15:45:00', '2025-6-30 17:55:00', 3, 2),
	(6, '2025-3-29 19:35:00', '2025-3-29 21:20:00', 4, 4);

INSERT INTO soled_tickets (id, session, cost_rub, place_num, cash_register) VALUES
	(1, 2, 455.99, 12, 3),
	(2, 1, 300.99, 43, 2),
	(3, 3, 300.99, 123, 1),
	(4, 4, 199.99, 65, 1),
	(5, 5, 499.99, 34, 4),
	(6, 6, 239.99, 91, 1),
	(7, 2, 199.99, 250, 2),
	(8, 3, 349.99, 22, 2),
	(9, 4, 559.99, 13, 3),
	(10, 5, 559.99, 14, 3),
	(11, 6, 199.99, 176, 2),
	(12, 6, 300.99, 99, 4);

-- endregion