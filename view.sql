-- region drop views

DROP VIEW IF EXISTS active_tickets;
DROP VIEW IF EXISTS tickets_with_movies_and_halls;
DROP VIEW IF EXISTS cash_registers_with_cashiers;

-- endregion
-- region create views

CREATE VIEW active_tickets AS
	SELECT *
	FROM soled_tickets AS st
	WHERE (SELECT end_datetime FROM sessions AS s WHERE s.id = st.session) > now()::TIMESTAMP;

CREATE VIEW tickets_with_movies_and_halls AS
	SELECT st.id "Ticket ID", 
			st.cost_rub "Cost rubles",
		    (SELECT m.name_eng FROM movies AS m WHERE id = s.movie) "Movie",
			(SELECT h.num FROM halls AS h WHERE id = s.hall) "Hall #"
	FROM soled_tickets AS st
	LEFT JOIN sessions AS s
	ON st.session = s.id;

CREATE VIEW cash_registers_with_cashiers AS
	SELECT cr.num, cr.work_start, cr.work_end, c.name || ' ' || c.surname "Cashier"
	FROM cash_registers AS cr
	LEFT JOIN cashiers AS c
	ON c.id = cr.cashier
	ORDER BY cr.num;

-- endregion	
-- region comments

COMMENT ON VIEW active_tickets IS 'Returns active tickets for sessions that have not yet started';
	
COMMENT ON VIEW tickets_with_movies_and_halls IS 'Returns all soled tickets grouped by movies';

COMMENT ON VIEW cash_registers_with_cashiers IS 'Returns info about cash registers and cashiers';

-- endregion