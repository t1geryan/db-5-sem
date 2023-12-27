-- region deleting objects

DROP TRIGGER IF EXISTS session_creating_trigger ON movies;

DROP FUNCTION IF EXISTS create_session();
DROP FUNCTION IF EXISTS generate_director();
DROP FUNCTION IF EXISTS generate_directors(INTEGER);
DROP FUNCTION IF EXISTS random_number(INTEGER,INTEGER);
DROP FUNCTION IF EXISTS random_string(INTEGER);
DROP FUNCTION IF EXISTS generate_soled_ticket();
DROP FUNCTION IF EXISTS generate_soled_tickets(INTEGER);

DROP INDEX IF EXISTS movies_director_index;
DROP INDEX IF EXISTS movies_year_index;
DROP INDEX IF EXISTS soled_tickets_session_index;

DROP VIEW IF EXISTS active_sessions;
DROP VIEW IF EXISTS active_tickets_with_movies_and_halls;
DROP VIEW IF EXISTS cash_registers_with_cashiers;
DROP VIEW IF EXISTS revenue_from_each_movie;

DROP TABLE IF EXISTS soled_tickets;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS halls;
DROP TABLE IF EXISTS directors;
DROP TABLE IF EXISTS cash_registers;
DROP TABLE IF EXISTS cashiers;
DROP SCHEMA IF EXISTS cinema_schema;
REVOKE CONNECT ON DATABASE movsisian_tg_db FROM mt_cinema_cashier, mt_cinema_manager, mt_cinema_viewer;
DROP ROLE IF EXISTS mt_cinema_cashier, mt_cinema_manager, mt_cinema_viewer;
DROP ROLE IF EXISTS mt_cashier_user, mt_director_user, mt_viewer_user;

-- endregion 
-- region creating schema

CREATE SCHEMA IF NOT EXISTS cinema_schema AUTHORIZATION movsisian_tg;
COMMENT ON SCHEMA cinema_schema IS 'cinema schema';

GRANT ALL ON SCHEMA cinema_schema TO movsisian_tg;
ALTER ROLE movsisian_tg IN DATABASE movsisian_tg_db SET search_path TO cinema_schema, public;

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
		(DEFAULT, 'Alfred', 'Hitchcock'),
		(DEFAULT, 'Martin', 'Scorsese'),
		(DEFAULT, 'Steven', 'Spielberg'),
		(DEFAULT, 'Quentin', ' Tarantino'),
		(DEFAULT, 'Christopher', 'Nolan');

INSERT INTO cashiers (id, name, surname) VALUES
	(DEFAULT, 'Ivan', 'Ischenko'),
	(DEFAULT, 'Andrew', 'Vasilenko'),
	(DEFAULT, 'Nikolay', 'Vladimirov'),
	(DEFAULT, 'Anastasia', 'Kuznetsova');

INSERT INTO cash_registers (id, num, work_start, work_end, cashier) VALUES
	(DEFAULT, 7, '12:00:00', '00:00:00', 2),
	(DEFAULT, 9, '12:00:00', '00:00:00', 3),
	(DEFAULT, 1, '14:00:00', '02:00:00', 4),
	(DEFAULT, 2, '14:00:00', '02:00:00', 1),
	(DEFAULT, 4, '10:00:00', '22:00:00', 1),
	(DEFAULT, 3, '8:00:00', '20:00:00', 3);

INSERT INTO movies (id, name_eng, name_rus, release_year, tagline, duration_seconds, director) VALUES
	(DEFAULT, 'Kill Bill', 'Убить Билла', 2003, 'In the year 2003, Uma Thurman will kill Bill.', 7253, 4),
	(DEFAULT, 'Django The Unchained', 'Джанго освобождённый', 2012, 'Life, liberty and the pursuit of vengeance.', 8312, 4),
	(DEFAULT, 'Inception', 'Начало', 2010, 'Your mind is the scene of the crime.', 6931, 5),
	(DEFAULT, 'Schindlers List', 'Список Шиндлера', 1993, 'Whoever saves one life, saves the world entire.', 7341, 3),
	(DEFAULT, 'Psycho', 'Психо', 1960, 'Exploring the blackness of the subconscious man!', 7124, 1),
	(DEFAULT, 'The Irishman', 'Ирландец', 2019, 'His story changed history.', 9831, 2);

INSERT INTO halls (id, num, capacity, screen_size_inches, square) VALUES
	(DEFAULT, 1, 128, 100, 316.24),
	(DEFAULT, 2, 250, 120, 543.75),
	(DEFAULT, 3, 16, 140, 120.12),
	(DEFAULT, 4, 145, 100, 345.55);

INSERT INTO sessions (id, start_datetime, end_datetime, movie, hall) VALUES
	(DEFAULT, '2023-10-25 11:45:00', '2023-10-25 13:35:00', 1, 1),
	(DEFAULT, '2023-6-25 13:25:00', '2023-6-25 15:35:00', 2, 3),
	(DEFAULT, '2023-8-29 16:40:00', '2023-8-29 19:45:00', 6, 4),
	(DEFAULT, '2025-11-29 15:05:00', '2025-11-29 17:35:00', 5, 2),
	(DEFAULT, '2025-6-30 15:45:00', '2025-6-30 17:55:00', 3, 2),
	(DEFAULT, '2025-3-29 19:35:00', '2025-3-29 21:20:00', 4, 4);

INSERT INTO soled_tickets (id, session, cost_rub, place_num, cash_register) VALUES
	(DEFAULT, 2, 455.99, 12, 3),
	(DEFAULT, 1, 300.99, 43, 2),
	(DEFAULT, 3, 300.99, 123, 1),
	(DEFAULT, 4, 199.99, 65, 1),
	(DEFAULT, 5, 499.99, 34, 4),
	(DEFAULT, 6, 239.99, 91, 1),
	(DEFAULT, 2, 199.99, 250, 2),
	(DEFAULT, 3, 349.99, 22, 2),
	(DEFAULT, 4, 559.99, 13, 3),
	(DEFAULT, 5, 559.99, 14, 3),
	(DEFAULT, 6, 199.99, 176, 2),
	(DEFAULT, 6, 300.99, 99, 4);

-- endregion
-- region create views

CREATE VIEW active_sessions AS
	SELECT (SELECT m.name_eng FROM movies AS m WHERE m.id = s.movie) "Movie",
	s.start_datetime "Start time",
	s.end_datetime "End time",
	(SELECT h.num FROM halls AS h WHERE id = s.hall) "Hall #"
	FROM sessions as s
	WHERE end_datetime > now()::TIMESTAMP;

CREATE VIEW active_tickets_with_movies_and_halls AS
	SELECT st.id "Ticket ID", 
			st.cost_rub "Cost rubles",
		    (SELECT m.name_eng FROM movies AS m WHERE m.id = s.movie) "Movie",
			(SELECT h.num FROM halls AS h WHERE id = s.hall) "Hall #"
	FROM soled_tickets AS st
	LEFT JOIN sessions AS s
	ON st.session = s.id
	WHERE (SELECT end_datetime FROM sessions AS s WHERE s.id = st.session) > now()::TIMESTAMP;

CREATE VIEW cash_registers_with_cashiers AS
	SELECT cr.num "Cash Register #", cr.work_start "Work start", cr.work_end "Work end", c.name || ' ' || c.surname "Cashier"
	FROM cash_registers AS cr
	LEFT JOIN cashiers AS c
	ON c.id = cr.cashier
	ORDER BY cr.num;

CREATE VIEW revenue_from_each_movie AS
	SELECT (SELECT m.id FROM movies AS m WHERE m.id = s.movie) "Movie", sum(st.cost_rub) "Revenue"
	FROM soled_tickets AS st
	LEFT JOIN sessions AS s
	ON st.session = s.id
	GROUP BY (SELECT m.id FROM movies AS m WHERE m.id = s.movie);

-- endregion	
-- region comments

COMMENT ON VIEW active_sessions IS 'Returns info about active sessions';
	
COMMENT ON VIEW active_tickets_with_movies_and_halls IS 'Returns all active soled tickets with movie name and hall number';

COMMENT ON VIEW cash_registers_with_cashiers IS 'Returns info about cash registers and cashiers';

COMMENT ON VIEW revenue_from_each_movie IS 'Returns sum of all soled tickets cost for each movie';

-- endregion
-- region index

CREATE INDEX IF NOT EXISTS movies_director_index
	ON movies
	(director);
	
CREATE INDEX IF NOT EXISTS movies_year_index
	ON movies
	(release_year);
	
CREATE INDEX IF NOT EXISTS soled_tickets_session_index
	ON soled_tickets
	(session);

COMMENT ON INDEX movies_director_index IS 'Movies index by director';
COMMENT ON INDEX movies_year_index IS 'Movies index by year';
COMMENT ON INDEX soled_tickets_session_index IS 'Soled tickets by session id';

-- endregion
-- region create trigger

CREATE OR REPLACE FUNCTION create_session()
RETURNS TRIGGER AS $$
BEGIN
    DECLARE
        hall_id INTEGER;
    BEGIN
        SELECT id INTO hall_id FROM halls ORDER BY RANDOM() LIMIT 1;

        INSERT INTO sessions (start_datetime, end_datetime, movie, hall)
        VALUES (CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 second' * NEW.duration_seconds + INTERVAL '15 minutes', NEW.id, hall_id);
    
        RETURN NEW;
    END;
END;
$$ LANGUAGE plpgsql;
		
CREATE TRIGGER session_creating_trigger
AFTER INSERT ON movies
FOR EACH ROW
EXECUTE FUNCTION create_session();

-- endregion
-- region enable/disable trigger

--ALTER TABLE movies DISABLE TRIGGER session_creating_trigger;
--ALTER TABLE movies ENABLE TRIGGER session_creating_trigger;

-- endregion
-- region comment trigger

COMMENT ON TRIGGER session_creating_trigger ON movies IS 'Create session after new movie instertion with random hall and duration equal movie duration + 15 minutes';

-- endregion
-- region generating movies

CREATE OR REPLACE FUNCTION generate_soled_tickets(count INTEGER)
RETURNS VOID AS $$
BEGIN
    -- Generate $count sessions
    FOR i IN 1..count LOOP
        PERFORM generate_soled_ticket();
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_soled_ticket()
RETURNS VOID AS $$
DECLARE
    session_id INT;
    cash_register_id INT;
BEGIN
    session_id := (SELECT id FROM sessions ORDER BY random() LIMIT 1);
    cash_register_id := (SELECT id FROM cash_registers ORDER BY random() LIMIT 1);
    
    INSERT INTO soled_tickets (session, cost_rub, place_num, cash_register)
    VALUES (session_id, random_number(100, 1000), random_number(1, 100), cash_register_id);
END;
$$ LANGUAGE plpgsql;

-- endregion
-- region generating directors

CREATE OR REPLACE FUNCTION generate_directors(count INTEGER)
RETURNS VOID AS $$
BEGIN
    -- Generate $count directors
    FOR i IN 1..count LOOP
        PERFORM generate_director();
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_director()
RETURNS VOID AS $$
DECLARE
    name TEXT;
    surname TEXT;
BEGIN
    -- Generate name and surname with specific length
    name := random_string(5);
    surname := random_string(8);
    
    INSERT INTO directors (name, surname) VALUES (name, surname);
END;
$$ LANGUAGE plpgsql;

-- endregion
-- region utils
CREATE OR REPLACE FUNCTION random_number(min_val integer, max_val integer)
  RETURNS integer AS
$$
BEGIN
  RETURN FLOOR((RANDOM() * (max_val - min_val + 1)) + min_val);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION random_string(length INTEGER)
RETURNS TEXT AS $$
DECLARE
    i INTEGER;
    result TEXT;
BEGIN
    result := '';
    
    -- Genereate string with specific length
    FOR i IN 1..length LOOP
        -- Generate random ASCII latin upper letter
        result := result || chr(65 + floor(random() * 26)::integer);
    END LOOP;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

--endregion
-- region creating roles

CREATE ROLE mt_cinema_cashier WITH
  	NOLOGIN
  	NOINHERIT
  	NOCREATEDB
  	NOCREATEROLE
  	VALID UNTIL '2024-01-25 00:00:00+00';

CREATE ROLE mt_cinema_manager WITH
  	NOLOGIN
  	NOINHERIT
  	NOCREATEDB
  	NOCREATEROLE
  	VALID UNTIL '2024-01-25 00:00:00+00';

CREATE ROLE mt_cinema_viewer WITH
  NOLOGIN
	NOINHERIT
	NOCREATEDB
	NOCREATEROLE
	VALID UNTIL '2024-01-25 00:00:00+00';

-- endregion
-- region search path

ALTER ROLE mt_cinema_cashier IN DATABASE movsisian_tg_db SET search_path TO cinema_schema, public;
ALTER ROLE mt_cinema_manager IN DATABASE movsisian_tg_db SET search_path TO cinema_schema, public;
ALTER ROLE mt_cinema_viewer IN DATABASE movsisian_tg_db SET search_path TO cinema_schema, public;

-- endregion
-- region grant privilege

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA cinema_schema FROM mt_cinema_cashier;
GRANT CONNECT ON DATABASE movsisian_tg_db TO mt_cinema_cashier;
GRANT USAGE ON SCHEMA cinema_schema TO mt_cinema_cashier;
GRANT SELECT, INSERT, UPDATE ON cash_registers TO mt_cinema_cashier;
GRANT SELECT, INSERT, UPDATE, DELETE ON soled_tickets TO mt_cinema_cashier;
GRANT USAGE, SELECT ON SEQUENCE cash_registers_id_seq TO mt_cinema_cashier;
GRANT USAGE, SELECT ON SEQUENCE soled_tickets_id_seq TO mt_cinema_cashier;
GRANT SELECT ON sessions TO mt_cinema_cashier;
GRANT SELECT ON halls TO mt_cinema_cashier;
GRANT SELECT ON movies TO mt_cinema_cashier;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA cinema_schema FROM mt_cinema_manager;
GRANT CONNECT ON DATABASE movsisian_tg_db TO mt_cinema_manager;
GRANT USAGE ON SCHEMA cinema_schema TO mt_cinema_manager;
GRANT SELECT, INSERT, UPDATE ON halls TO mt_cinema_manager;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON sessions TO mt_cinema_manager;
GRANT USAGE, SELECT ON SEQUENCE halls_id_seq TO mt_cinema_manager;
GRANT USAGE, SELECT ON SEQUENCE sessions_id_seq TO mt_cinema_manager;
GRANT SELECT, UPDATE ON cash_registers TO mt_cinema_manager;
GRANT SELECT, UPDATE ON cashiers TO mt_cinema_manager;
GRANT SELECT ON soled_tickets TO mt_cinema_manager;
GRANT SELECT ON movies TO mt_cinema_manager;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA cinema_schema FROM mt_cinema_viewer;
REVOKE ALL PRIVILEGES ON active_sessions FROM mt_cinema_viewer;
GRANT CONNECT ON DATABASE movsisian_tg_db TO mt_cinema_viewer;
GRANT USAGE ON SCHEMA cinema_schema TO mt_cinema_viewer;
GRANT SELECT ON movies TO mt_cinema_viewer;
GRANT SELECT ON active_sessions TO mt_cinema_viewer;

-- endregion
-- region create users

CREATE USER mt_cashier_user WITH PASSWORD 'cashier_password';
GRANT mt_cinema_cashier TO mt_cashier_user;

CREATE USER mt_director_user WITH PASSWORD 'director_password';
GRANT mt_cinema_manager TO mt_director_user;

CREATE USER mt_viewer_user WITH PASSWORD 'viewer_password';
GRANT mt_cinema_viewer TO mt_viewer_user;

-- endregion
-- region user search path

ALTER ROLE mt_cashier_user IN DATABASE movsisian_tg_db SET search_path TO cinema_schema, public;
ALTER ROLE mt_director_user IN DATABASE movsisian_tg_db SET search_path TO cinema_schema, public;
ALTER ROLE mt_viewer_user IN DATABASE movsisian_tg_db SET search_path TO cinema_schema, public;

-- endregion