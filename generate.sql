-- region drop

DROP FUNCTION IF EXISTS generate_soled_tickets(count INTEGER);
DROP FUNCTION IF EXISTS generate_soled_ticket();
DROP FUNCTION IF EXISTS generate_directors(count INTEGER);
DROP FUNCTION IF EXISTS generate_director();
DROP FUNCTION IF EXISTS random_number(min_val integer, max_val integer);
DROP FUNCTION IF EXISTS random_string(length INTEGER);

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