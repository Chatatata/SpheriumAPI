DROP SCHEMA public CASCADE; CREATE SCHEMA public;

CREATE TABLE users(
    id serial PRIMARY KEY, -- surrogate key
    username character varying (25) NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE one_time_codes(
    id serial PRIMARY KEY, -- surrogate key
    code integer NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    user_id integer REFERENCES users(id) NOT NULL
);

CREATE TABLE insecure_authentication_handles(
    id serial PRIMARY KEY, -- surrogate key
    passkey character varying (255) NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    user_id integer REFERENCES users(id) NOT NULL
);

CREATE TABLE passphrases(
    id serial PRIMARY KEY, -- surrogate key
    passkey character (5) UNIQUE NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    user_id integer REFERENCES users(id) NOT NULL
);

CREATE MATERIALIZED VIEW concrete_authentication_middleware_artifacts AS
    SELECT user_id, NULL insecure_authentication_handle_passkey, code one_time_code, inserted_at
    FROM one_time_codes

    UNION

    SELECT user_id, passkey insecure_authentication_handle_passkey, NULL one_time_code, inserted_at
    FROM insecure_authentication_handles;

INSERT INTO users(id, username) VALUES
    (1, 'brian'),
    (2, 'alice'),
    (3, 'jane'),
    (4, 'shan'),
    (5, 'marshall');

INSERT INTO one_time_codes(code, inserted_at, user_id) VALUES
    (712643, '2017-01-16 04:52:41.060506', 1),
    (127317, '2017-01-16 08:22:15.012303', 2),
    (581238, '2017-01-16 14:22:39.123123', 3);

INSERT INTO insecure_authentication_handles(passkey, inserted_at, user_id) VALUES
    ('an insecure authentication handle', '2017-01-16 10:40:45.123872', 4),
    ('another insecure authentication handle', '2017-01-16 10:41:49.123822', 4);

INSERT INTO passphrases(passkey, inserted_at, user_id) VALUES
    ('812he', '2017-01-16 04:53:18.123123', 1),
    ('1237s', '2017-01-16 08:23:02.120332', 2),
    ('asd72', '2017-01-16 10:41:52.123746', 4),
    ('asdks', '2017-01-16 14:23:11.123123', 3);

REFRESH MATERIALIZED VIEW concrete_authentication_middleware_artifacts;

EXPLAIN ANALYZE VERBOSE
SELECT max(otc.inserted_at)
FROM one_time_codes otc;

EXPLAIN ANALYZE VERBOSE
SELECT cama.*, p.passkey passphrase
FROM concrete_authentication_middleware_artifacts cama
INNER JOIN passphrases p ON cama.user_id = p.user_id AND (GREATEST(p.inserted_at, cama.inserted_at) - LEAST(p.inserted_at, cama.inserted_at) < '3 minutes'::interval);


CREATE TABLE users AS
SELECT t1.userid, md5(t1.userid::text), x AS passcodes
FROM generate_series(1,2000) AS t1(userid)
CROSS JOIN LATERAL (
  SELECT t1.userid, jsonb_agg(floor(random()*1000)) AS json
  FROM generate_series(1,200) AS t(x)
  GROUP BY true
) AS t2(userid,x);
CREATE UNIQUE INDEX ON users (userid);
ANALYZE users;

EXPLAIN ANALYZE SELECT * FROM users
WHERE passcodes @>'5' ;

SELECT * FROM users
WHERE passcodes @>'5'
AND userid = 42;
       
