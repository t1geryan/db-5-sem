-- region drop views

DROP VIEW IF EXISTS active_tickets_with_movies_and_halls;
DROP VIEW IF EXISTS cash_registers_with_cashiers;
DROP VIEW IF EXISTS revenue_from_each_movie;

-- endregion
-- region create views

CREATE VIEW active_tickets_with_movies_and_halls AS
	SELECT st.id "Ticket ID", 
			st.cost_rub "Cost rubles",
		    (SELECT m.name_eng FROM movies AS m WHERE id = s.movie) "Movie",
			(SELECT h.num FROM halls AS h WHERE id = s.hall) "Hall #"
	FROM soled_tickets AS st
	LEFT JOIN sessions AS s
	ON st.session = s.id
	WHERE (SELECT end_datetime FROM sessions AS s WHERE s.id = st.session) > now()::TIMESTAMP;

CREATE VIEW cash_registers_with_cashiers AS
	SELECT cr.num, cr.work_start, cr.work_end, c.name || ' ' || c.surname "Cashier"
	FROM cash_registers AS cr
	LEFT JOIN cashiers AS c
	ON c.id = cr.cashier
	ORDER BY cr.num;

CREATE VIEW revenue_from_each_movie AS
	SELECT (SELECT m.id FROM movies AS m WHERE m.id = s.movie) "Movie", sum(st.cost_rub)
	FROM soled_tickets AS st
	LEFT JOIN sessions AS s
	ON st.session = s.id
	GROUP BY (SELECT m.id FROM movies AS m WHERE m.id = s.movie);

-- endregion	
-- region comments
	
COMMENT ON VIEW active_tickets_with_movies_and_halls IS 'Returns all active soled tickets with movie name and hall number';

COMMENT ON VIEW cash_registers_with_cashiers IS 'Returns info about cash registers and cashiers';

COMMENT ON VIEW revenue_from_each_movie IS 'Returns sum of all soled tickets cost for each movie';

-- endregion