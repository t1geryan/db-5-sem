-- region generating movies

CREATE OR REPLACE FUNCTION generate_movies(count INTEGER)
RETURNS VOID AS $$
BEGIN
    -- Generate $count movies
    FOR i IN 1..count LOOP
        PERFORM generate_movie();
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_movie()
RETURNS VOID AS $$
DECLARE
    name_eng TEXT;
    name_rus TEXT;
    release_year INT;
    tagline TEXT;
    duration_seconds INT;
    director_id INT;
BEGIN
    -- Generate random data for movie
    name_eng := random_string(10);
    name_rus := random_string(10);
    release_year := floor(random() * 100) + date_part('year', CURRENT_DATE);
    tagline := random_string(20);
    duration_seconds := floor(random() * 7200) + 3600;
    -- Generate director is there no one
    IF (SELECT COUNT(*) FROM directors) = 0 THEN
        PERFORM generate_director();
    END IF;
    director_id := (SELECT id FROM directors ORDER BY random() LIMIT 1);
    
    INSERT INTO movies (name_eng, name_rus, release_year, tagline, duration_seconds, director)
    VALUES (name_eng, name_rus, release_year, tagline, duration_seconds, director_id);
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

-- SELECT generate_directors(num);
-- SELECT generate_movies(num);