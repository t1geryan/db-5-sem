DROP INDEX IF EXISTS movies_director_index;
DROP INDEX IF EXISTS movies_year_index;
DROP INDEX IF EXISTS soled_tickets_session_index

CREATE INDEX IF NOT EXISTS movies_director_index
	ON movies
	(director);
	
CREATE INDEX IF NOT EXISTS movies_year_index
	ON movies
	(realese_year);
	
CREATE INDEX IF NOT EXISTS soled_tickets_session_index
	ON soled_tickets
	(session);

COMMENT ON INDEX movies_director_index IS 'Movies index by director';
COMMENT ON INDEX movies_year_index IS 'Movies index by year';
COMMENT ON INDEX soled_tickets_session_index IS 'Soled tickets by session id';