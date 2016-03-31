
CREATE OR REPLACE FUNCTION blep(foo text) RETURNS text AS $$
    BEGIN
        RETURN '[Stage 18: ' || $1 || ']';
    END;
$$ LANGUAGE PLPGSQL;
