-- region dropping

-- REASSIGN OWNED BY cinema_cashier TO movsisian_tg;
-- DROP OWNED BY cinema_cashier;
-- REASSIGN OWNED BY director_user TO movsisian_tg;
-- DROP OWNED BY director_user;
-- REASSIGN OWNED BY viewer_user TO movsisian_tg;
-- DROP OWNED BY viewer_user;
-- REVOKE TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA public FROM cinema_cashier, cinema_manager, cinema_viewer;
DROP ROLE IF EXISTS cinema_cashier, cinema_manager, cinema_viewer;

-- endregion
-- region creating roles

CREATE ROLE cinema_cashier WITH
	CONNECT
  	LOGIN
  	NOINHERIT
  	NOCREATEDB
  	NOCREATEROLE
  	VALID UNTIL '2024-01-25 00:00:00+00';

CREATE ROLE cinema_manager WITH
	CONNECT
  	LOGIN
  	NOINHERIT
  	NOCREATEDB
  	NOCREATEROLE
  	VALID UNTIL '2024-01-25 00:00:00+00';

CREATE ROLE cinema_viewer WITH
	CONNECT
  	LOGIN
	NOINHERIT
	NOCREATEDB
	NOCREATEROLE
	VALID UNTIL '2024-01-25 00:00:00+00';

-- endregion
-- region search path

ALTER ROLE cinema_cashier IN DATABASE movsisian_tg_db SET search_path TO cinema_schema, public;
ALTER ROLE cinema_manager IN DATABASE movsisian_tg_db SET search_path TO cinema_schema, public;
ALTER ROLE cinema_viewer IN DATABASE movsisian_tg_db SET search_path TO cinema_schema, public;

-- endregion
-- region grant privilege

GRANT CONNECT ON DATABASE movsisian_tg_db TO cinema_cashier;
GRANT USAGE ON SCHEMA cinema_schema TO cinema_cashier;
GRANT SELECT, INSERT, UPDATE ON cash_registers TO cinema_cashier;
GRANT SELECT, INSERT, UPDATE, DELETE ON soled_tickets TO cinema_cashier;
GRANT SELECT ON sessions TO cinema_cashier;
GRANT SELECT ON halls TO cinema_cashier;
GRANT SELECT ON movies TO cinema_manager;

GRANT CONNECT ON DATABASE movsisian_tg_db TO cinema_manager;
GRANT USAGE ON SCHEMA cinema_schema TO cinema_manager;
GRANT SELECT, INSERT, UPDATE ON halls TO cinema_manager;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON sessions TO cinema_manager;
GRANT SELECT, UPDATE on cash_registers TO cinema_manager;
GRANT SELECT, UPDATE ON cashiers TO cinema_manager;
GRANT SELECT ON soled_tickets TO cinema_manager;
GRANT SELECT ON movies TO cinema_manager;

GRANT CONNECT ON DATABASE movsisian_tg_db TO cinema_viewer;
GRANT USAGE ON SCHEMA cinema_schema TO cinema_viewer;
GRANT SELECT ON movies TO cinema_viewer;
GRANT SELECT ON sessions TO cinema_viewer;

-- endregion
-- region create users

CREATE USER cashier_user WITH PASSWORD 'cashier_password';
GRANT cinema_cashier TO cashier_user;

CREATE USER director_user WITH PASSWORD 'director_password';
GRANT cinema_manager TO director_user;

CREATE USER viewer_user WITH PASSWORD 'viewer_password';
GRANT cinema_viewer TO viewer_user;

-- endregion
-- region user search path

ALTER ROLE cashier_user IN DATABASE movsisian_tg_db SET search_path TO cinema_schema, public;
ALTER ROLE director_user IN DATABASE movsisian_tg_db SET search_path TO cinema_schema, public;
ALTER ROLE viewer_user IN DATABASE movsisian_tg_db SET search_path TO cinema_schema, public;

-- endregion