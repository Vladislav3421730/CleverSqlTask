CREATE TABLE log_table (
    id INTEGER,
    name VARCHAR(300),
    log_date DATE
);
CREATE TYPE employee AS (
    id INTEGER,
    name VARCHAR(300)
);

CREATE TEMP TABLE employees_tab (
    id INTEGER,
    name VARCHAR(300)
) ON COMMIT PRESERVE ROWS;

CREATE OR REPLACE PROCEDURE log()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO log_table (id, name, log_date)
    SELECT e.id, e.name, CURRENT_DATE
    FROM employees_tab e
    WHERE NOT EXISTS (
        SELECT 1 FROM log_table l WHERE l.id = e.id
    );
END;
$$;

CREATE OR REPLACE PROCEDURE hire(id INTEGER, Name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO employees_tab VALUES(id, Name);
    CALL log();
END;
$$;

CREATE OR REPLACE FUNCTION getlist()
RETURNS SETOF employee AS $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN SELECT id, name FROM employees_tab LOOP
        RAISE NOTICE 'Employee #% - Name: %', rec.id, rec.name;
        RETURN NEXT (rec.id, rec.name);
    END LOOP;
    RETURN;
END;
$$ LANGUAGE plpgsql;


DO $$
BEGIN
    INSERT INTO employees_tab VALUES
        (1, 'John'), 
        (2, 'Mike');
    CALL log();
END;
$$;


