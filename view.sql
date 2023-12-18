-- region drop views

DROP VIEW IF EXISTS active_tickets;
DROP VIEW IF EXISTS big_halls;
DROP VIEW IF EXISTS longest_movies;
DROP VIEW IF EXISTS tickets_with_movies_and_halls;

-- endregion
-- region create views

CREATE VIEW active_tickets AS
	SELECT *
	FROM soled_tickets AS st
	WHERE (SELECT end_datetime FROM sessions AS s WHERE s.id = st.session) > now()::TIMESTAMP;
	
CREATE VIEW big_halls AS
	SELECT * 
	FROM halls as h
	WHERE h.capacity > 50;

CREATE VIEW longest_movies AS
	SELECT *
	FROM movies as m
	ORDER BY duration_seconds DESC
	LIMIT 3;

CREATE VIEW tickets_with_movies_and_halls AS
	SELECT st.id "Ticket ID", 
			st.cost_rub "Cost rubles",
		    (SELECT m.name_eng FROM movies AS m WHERE id = s.movie) "Movie",
			(SELECT h.num FROM halls AS h WHERE id = s.hall) "Hall #"
	FROM soled_tickets AS st
	LEFT JOIN sessions AS s
	ON st.session = s.id;

-- endregion	
-- region comments

COMMENT ON VIEW active_tickets IS 'Returns active tickets for sessions that have not yet started';
	
COMMENT ON VIEW big_halls IS 'Returns halls with capacity bigger than 50 persons';
	
COMMENT ON VIEW longest_movies IS 'Returns top 3 movies by duration';
	
COMMENT ON VIEW tickets_with_movies_and_halls IS 'Returns all soled tickets grouped by movies';

-- endregion