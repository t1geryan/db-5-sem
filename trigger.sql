-- region drop

DROP TRIGGER IF EXISTS session_creating_trigger ON movies CASCADE;

-- endregion
-- region create

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
-- region comment 

COMMENT ON TRIGGER session_creating_trigger ON movies IS 'Create session after new movie instertion with random hall and duration equal movie duration + 15 minutes';

-- endregion