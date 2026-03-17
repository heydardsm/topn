\echo Use "CREATE EXTENSION topn" to load this file. \quit

CREATE OR REPLACE FUNCTION topn_version()
RETURNS varchar
LANGUAGE C
STABLE
AS 'MODULE_PATHNAME', 'topn_version';

CREATE OR REPLACE FUNCTION topn_create_namespace(
    base_name varchar,
    uid_type text DEFAULT 'varchar(256)',
    key_type text DEFAULT 'varchar(256)'
)
RETURNS varchar
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    table_name varchar;
    create_sql text;
    unique_index_sql text;
    freq_index_sql text;
    valid_types text[] := ARRAY['int', 'integer', 'bigint', 'varchar', 'timestamp', 'date', 'uuid'];
BEGIN
    table_name := 'topn_' || base_name;
    
    IF table_name !~ '^[a-zA-Z_][a-zA-Z0-9_]*$' THEN
        RAISE EXCEPTION 'Invalid table name: %', table_name;
    END IF;
    
    IF EXISTS (
        SELECT 1 
        FROM pg_tables 
        WHERE tablename = table_name
          AND schemaname = current_schema()
    ) THEN
        RAISE EXCEPTION 'Table % already exists', table_name;
    END IF;
    
    IF uid_type != 'varchar' AND uid_type !~ '^varchar\(' THEN
        IF NOT (uid_type = ANY(valid_types)) THEN
            RAISE EXCEPTION 'Invalid uid_type: %. Allowed types: int, integer, bigint, varchar, timestamp, date, uuid', uid_type;
        END IF;
    END IF;
    
    IF key_type != 'varchar' AND key_type !~ '^varchar\(' THEN
        IF NOT (key_type = ANY(valid_types)) THEN
            RAISE EXCEPTION 'Invalid key_type: %. Allowed types: int, integer, bigint, varchar, timestamp, date, uuid', key_type;
        END IF;
    END IF;
    
    create_sql := format('
        CREATE TABLE %I (
            uid %s NOT NULL,
            key %s NOT NULL,
            frequently bigint NOT NULL DEFAULT 0
        )', table_name, uid_type, key_type);
    
    EXECUTE create_sql;
    
    unique_index_sql := format('
        CREATE UNIQUE INDEX %I ON %I (uid, key)',
        table_name || '_uid_key_idx', table_name
    );
    
    EXECUTE unique_index_sql;
    
    freq_index_sql := format('
        CREATE INDEX %I ON %I (uid, frequently)',
        table_name || '_uid_freq_idx', table_name
    );
    
    EXECUTE freq_index_sql;
    
    RETURN table_name;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating table: %', SQLERRM;
        RAISE;
END;
$$;

CREATE OR REPLACE FUNCTION topn_add(
    namespace varchar,
    p_uid integer,
    p_key ANYELEMENT,
    p_frequently bigint DEFAULT 1
)
RETURNS bigint
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    table_name varchar;
    new_count bigint;
BEGIN
    table_name := 'topn_' || namespace;
    
    EXECUTE format('
        INSERT INTO %I (uid, key, frequently)
        VALUES ($1, $2, $3)
        ON CONFLICT (uid, key)
        DO UPDATE SET frequently = %I.frequently + $3
        RETURNING frequently',
        table_name, table_name
    ) INTO new_count USING p_uid, p_key, p_frequently;
    RETURN new_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in topn_add: %', SQLERRM;
        RAISE;
END;
$$;

CREATE OR REPLACE FUNCTION topn_add(
    namespace varchar,
    p_uid bigint,
    p_key ANYELEMENT,
    p_frequently bigint DEFAULT 1
)
RETURNS bigint
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    table_name varchar;
    new_count bigint;
BEGIN
    table_name := 'topn_' || namespace;
    
    EXECUTE format('
        INSERT INTO %I (uid, key, frequently)
        VALUES ($1, $2, $3)
        ON CONFLICT (uid, key)
        DO UPDATE SET frequently = %I.frequently + $3
        RETURNING frequently',
        table_name, table_name
    ) INTO new_count USING p_uid, p_key, p_frequently;
    RETURN new_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in topn_add: %', SQLERRM;
        RAISE;
END;
$$;

CREATE OR REPLACE FUNCTION topn_add(
    namespace varchar,
    p_uid varchar,
    p_key ANYELEMENT,
    p_frequently bigint DEFAULT 1
)
RETURNS bigint
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    table_name varchar;
    new_count bigint;
BEGIN
    table_name := 'topn_' || namespace;
    
    EXECUTE format('
        INSERT INTO %I (uid, key, frequently)
        VALUES ($1, $2, $3)
        ON CONFLICT (uid, key)
        DO UPDATE SET frequently = %I.frequently + $3
        RETURNING frequently',
        table_name, table_name
    ) INTO new_count USING p_uid, p_key, p_frequently;
    RETURN new_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in topn_add: %', SQLERRM;
        RAISE;
END;
$$;

CREATE OR REPLACE FUNCTION topn_add(
    namespace varchar,
    p_uid timestamp,
    p_key ANYELEMENT,
    p_frequently bigint DEFAULT 1
)
RETURNS bigint
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    table_name varchar;
    new_count bigint;
BEGIN
    table_name := 'topn_' || namespace;
    
    EXECUTE format('
        INSERT INTO %I (uid, key, frequently)
        VALUES ($1, $2, $3)
        ON CONFLICT (uid, key)
        DO UPDATE SET frequently = %I.frequently + $3
        RETURNING frequently',
        table_name, table_name
    ) INTO new_count USING p_uid, p_key, p_frequently;
    RETURN new_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in topn_add: %', SQLERRM;
        RAISE;
END;
$$;

CREATE OR REPLACE FUNCTION topn_add(
    namespace varchar,
    p_uid date,
    p_key ANYELEMENT,
    p_frequently bigint DEFAULT 1
)
RETURNS bigint
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    table_name varchar;
    new_count bigint;
BEGIN
    table_name := 'topn_' || namespace;
    
    EXECUTE format('
        INSERT INTO %I (uid, key, frequently)
        VALUES ($1, $2, $3)
        ON CONFLICT (uid, key)
        DO UPDATE SET frequently = %I.frequently + $3
        RETURNING frequently',
        table_name, table_name
    ) INTO new_count USING p_uid, p_key, p_frequently;
    RETURN new_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in topn_add: %', SQLERRM;
        RAISE;
END;
$$;

CREATE OR REPLACE FUNCTION topn_add(
    namespace varchar,
    p_uid uuid,
    p_key ANYELEMENT,
    p_frequently bigint DEFAULT 1
)
RETURNS bigint
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    table_name varchar;
    new_count bigint;
BEGIN
    table_name := 'topn_' || namespace;
    
    EXECUTE format('
        INSERT INTO %I (uid, key, frequently)
        VALUES ($1, $2, $3)
        ON CONFLICT (uid, key)
        DO UPDATE SET frequently = %I.frequently + $3
        RETURNING frequently',
        table_name, table_name
    ) INTO new_count USING p_uid, p_key, p_frequently;
    RETURN new_count;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in topn_add: %', SQLERRM;
        RAISE;
END;
$$;

CREATE OR REPLACE FUNCTION topn(
    namespace varchar,
    p_uid anyelement,  -- anyelement allows any type
    n integer
)
RETURNS TABLE(key anyelement, frequently bigint)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    table_name varchar;
BEGIN
    table_name := 'topn_' || namespace;
    RETURN QUERY EXECUTE format('
        SELECT key, frequently
        FROM %I
        WHERE uid = %L
        ORDER BY frequently DESC
        LIMIT %s',
        table_name, p_uid, n
    );
END;
$$;
