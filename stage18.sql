
CREATE OR REPLACE FUNCTION stage19_blep(foo text) RETURNS text
  AS '/home/jaseg/ffi/libstage19.so', 'stage19_blep'
  LANGUAGE C STRICT;

CREATE OR REPLACE FUNCTION blep(foo text) RETURNS text AS $$
    BEGIN
        RETURN stage19_blep($1);
    END;
$$ LANGUAGE PLPGSQL;
