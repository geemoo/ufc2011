--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- Name: contract; Type: TYPE; Schema: public; Owner: jean
--

CREATE TYPE contract AS ENUM (
    'AMA',
    'WFA',
    'UFN',
    'UFC'
);


ALTER TYPE public.contract OWNER TO jean;

--
-- Name: focusgroup; Type: TYPE; Schema: public; Owner: jean
--

CREATE TYPE focusgroup AS ENUM (
    'Standup',
    'Takedown',
    'Clinch',
    'Ground and Pound',
    'Grappling/Submission'
);


ALTER TYPE public.focusgroup OWNER TO jean;

--
-- Name: move_type; Type: TYPE; Schema: public; Owner: jean
--

CREATE TYPE move_type AS ENUM (
    'Strike',
    'Kick',
    'Transition',
    'Submission'
);


ALTER TYPE public.move_type OWNER TO jean;

--
-- Name: technique_type; Type: TYPE; Schema: public; Owner: jean
--

CREATE TYPE technique_type AS ENUM (
    'Strike',
    'Kick',
    'Transition',
    'Submission',
    'Ground Strike',
    'Clinch Strike',
    'Clinch Transition',
    'Takedown'
);


ALTER TYPE public.technique_type OWNER TO jean;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: buttons; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE buttons (
    id integer NOT NULL,
    abbr character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.buttons OWNER TO jean;

--
-- Name: combo; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE combo (
    move_id integer NOT NULL,
    button_id integer NOT NULL,
    seq integer NOT NULL,
    variant integer NOT NULL
);


ALTER TABLE public.combo OWNER TO jean;

--
-- Name: v_combo_buttons; Type: VIEW; Schema: public; Owner: jean
--

CREATE VIEW v_combo_buttons AS
    SELECT combo.seq, combo.move_id, combo.variant, buttons.abbr FROM (combo JOIN buttons ON ((combo.button_id = buttons.id)));


ALTER TABLE public.v_combo_buttons OWNER TO jean;

--
-- Name: f_combos(); Type: FUNCTION; Schema: public; Owner: jean
--

CREATE FUNCTION f_combos() RETURNS SETOF v_combo_buttons
    LANGUAGE plpgsql STABLE
    AS $$
        DECLARE
                my_move_id v_combo_buttons.move_id%TYPE := 0;
                my_variant v_combo_buttons.variant%TYPE := 0;
                my_combo v_combo_buttons.abbr%TYPE := '';
                rec v_combo_buttons%ROWTYPE;
        BEGIN
                FOR rec IN SELECT * FROM v_combo_buttons ORDER BY seq 
                LOOP
                        IF my_move_id <> rec.move_id THEN
                                RETURN QUERY SELECT rec.seq, my_move_id, my_variant, my_combo;
                                my_move_id := rec.move_id;
                                my_variant := rec.variant;
                                my_combo := rec.abbr;
                        ELSIF my_variant <> rec.variant THEN
                                RETURN QUERY SELECT rec.seq, my_move_id, my_variant, my_combo;
                                my_variant := rec.variant;
                                my_combo := rec.abbr;
                        ELSE
                                my_combo := my_combo || ' + ' || rec.abbr;
                        END IF;
                END LOOP;

                RETURN QUERY SELECT rec.seq, my_move_id, my_variant, my_combo;
                RETURN;
        END;
$$;


ALTER FUNCTION public.f_combos() OWNER TO jean;

--
-- Name: f_v_combos_aggregate_insert(integer, text, integer); Type: FUNCTION; Schema: public; Owner: jean
--

CREATE FUNCTION f_v_combos_aggregate_insert(move_id_ integer, move_ text, variant_in integer DEFAULT NULL::integer) RETURNS void
    LANGUAGE plpgsql STABLE
    AS $$
        DECLARE
                abbreviation RECORD;
                variant_ RECORD;
                variant_out INTEGER;
        BEGIN
                FOR variant_ IN SELECT regexp_split_to_table AS t FROM regexp_split_to_table(move_, E'[[:space:]]*,[[:space:]]*') LOOP
                        variant_out := COALESCE(variant_in, (SELECT max(variant) FROM combo WHERE move_id = move_id_ GROUP BY move_id) + 1, 1);
                        FOR abbreviation IN SELECT regexp_split_to_table AS t FROM regexp_split_to_table(variant_.t, E'[[:space:]]*\+[[:space:]]*') LOOP
                                INSERT INTO combo (move_id, button_id, variant) VALUES (
                                        move_id_,
                                        (SELECT id FROM buttons WHERE abbr = abbreviation.t),
                                        variant_out
                                );
                                variant_out := variant_out + 1;
                        END LOOP;
                END LOOP;
        END;
$$;


ALTER FUNCTION public.f_v_combos_aggregate_insert(move_id_ integer, move_ text, variant_in integer) OWNER TO jean;

--
-- Name: f_v_fighter_camps_insert(integer, text); Type: FUNCTION; Schema: public; Owner: jean
--

CREATE FUNCTION f_v_fighter_camps_insert(fighter_id integer, camp_ text) RETURNS void
    LANGUAGE plpgsql STABLE
    AS $_$
        DECLARE
                rec RECORD;
        BEGIN
                FOR rec IN SELECT regexp_split_to_table AS camp FROM regexp_split_to_table(camp_, E',[[:space:]]*')
                LOOP
                        IF NOT EXISTS (SELECT id FROM camps WHERE name = rec.camp) THEN
                                INSERT INTO camps (name) VALUES (rec.camp);
                        END IF;
                        IF NOT EXISTS (SELECT id FROM fighter_camps WHERE fighter_camps.fighter_id = $1 AND camp_id = (SELECT id FROM camps WHERE name = rec.camp)) THEN
                                INSERT INTO fighter_camps VALUES (
                                        fighter_id,
                                        (SELECT id FROM camps WHERE name = rec.camp)
                                );
                        END IF;
                END LOOP;
        END;
$_$;


ALTER FUNCTION public.f_v_fighter_camps_insert(fighter_id integer, camp_ text) OWNER TO jean;

--
-- Name: f_v_fighter_moves_insert(integer, text); Type: FUNCTION; Schema: public; Owner: jean
--

CREATE FUNCTION f_v_fighter_moves_insert(fighter_id integer, move_ text) RETURNS void
    LANGUAGE plpgsql STABLE
    AS $_$
        DECLARE
                rec RECORD;
        BEGIN
                FOR rec IN SELECT regexp_split_to_table AS move FROM regexp_split_to_table(move_, E',[[:space:]]*')
                LOOP
                        IF NOT EXISTS (SELECT id FROM fighter_moves WHERE fighter_moves.fighter_id = $1 AND move_id = (SELECT id FROM moves WHERE name = rec.move)) THEN
                                INSERT INTO fighter_moves VALUES (
                                        fighter_id,
                                        (SELECT id FROM moves WHERE name = rec.move)
                                );
                        END IF;
                END LOOP;
        END;
$_$;


ALTER FUNCTION public.f_v_fighter_moves_insert(fighter_id integer, move_ text) OWNER TO jean;

--
-- Name: camps; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE camps (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.camps OWNER TO jean;

--
-- Name: country; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE country (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.country OWNER TO jean;

--
-- Name: fighter_camps; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE fighter_camps (
    fighter_id integer NOT NULL,
    camp_id integer NOT NULL
);


ALTER TABLE public.fighter_camps OWNER TO jean;

--
-- Name: fightercontract; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE fightercontract (
    id integer NOT NULL,
    contract contract NOT NULL
);


ALTER TABLE public.fightercontract OWNER TO jean;

--
-- Name: fightercountry; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE fightercountry (
    id integer NOT NULL,
    country integer NOT NULL
);


ALTER TABLE public.fightercountry OWNER TO jean;

--
-- Name: fighternickname; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE fighternickname (
    id integer NOT NULL,
    nickname text NOT NULL
);


ALTER TABLE public.fighternickname OWNER TO jean;

--
-- Name: fighterrating; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE fighterrating (
    id integer NOT NULL,
    rating integer NOT NULL,
    CONSTRAINT fighterrating_rating_check CHECK (((rating >= 0) AND (rating <= 100)))
);


ALTER TABLE public.fighterrating OWNER TO jean;

--
-- Name: fighterrecords; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE fighterrecords (
    id integer NOT NULL,
    record text NOT NULL
);


ALTER TABLE public.fighterrecords OWNER TO jean;

--
-- Name: fighters; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE fighters (
    id integer NOT NULL,
    name character varying NOT NULL,
    weightclass integer,
    source_id integer NOT NULL
);


ALTER TABLE public.fighters OWNER TO jean;

--
-- Name: fightersource; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE fightersource (
    id integer NOT NULL,
    source character varying NOT NULL
);


ALTER TABLE public.fightersource OWNER TO jean;

--
-- Name: v_fighter_camps; Type: VIEW; Schema: public; Owner: jean
--

CREATE VIEW v_fighter_camps AS
    WITH RECURSIVE i(id, camp) AS (WITH RECURSIVE k(_grouping, _length, _count, _number, datum) AS (WITH lb(_grouping, _length, _count, _number, datum) AS (WITH grouping_datum(grouping, datum) AS (SELECT fighter_camps.fighter_id, camps.name FROM (fighter_camps JOIN camps ON ((fighter_camps.camp_id = camps.id)))) SELECT grouping_datum.grouping, 1, count(*) OVER (grouping_window) AS count, row_number() OVER (grouping_window) AS row_number, grouping_datum.datum FROM grouping_datum WINDOW grouping_window AS (PARTITION BY grouping_datum.grouping)) SELECT lb._grouping, lb._length, lb._count, lb._number, lb.datum FROM lb UNION SELECT k._grouping, (k._length + 1), k._count, k._number, (((k.datum)::text || ', '::text) || (lb.datum)::text) FROM (k JOIN lb ON (((lb._grouping = k._grouping) AND (k._length = lb._number))))) SELECT k._grouping, k.datum FROM k WHERE ((k._count = k._length) AND (k._count = k._number))) SELECT fighters.id, fighters.name, i.camp FROM (fighters LEFT JOIN i ON ((fighters.id = i.id)));


ALTER TABLE public.v_fighter_camps OWNER TO jean;

--
-- Name: weightclass; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE weightclass (
    id integer NOT NULL,
    name character varying NOT NULL,
    lbs integer NOT NULL
);


ALTER TABLE public.weightclass OWNER TO jean;

--
-- Name: v_fighters; Type: VIEW; Schema: public; Owner: jean
--

CREATE VIEW v_fighters AS
    SELECT fighters.id, fighters.name, weightclass.name AS weightclass, v_fighter_camps.camp, fightercontract.contract, fighterrating.rating, fightersource.source, weightclass.lbs AS weight, fighterrecords.record, fighternickname.nickname, country.name AS country FROM (((((((((fighters LEFT JOIN v_fighter_camps ON ((fighters.id = v_fighter_camps.id))) LEFT JOIN weightclass ON ((fighters.weightclass = weightclass.id))) LEFT JOIN fightercontract ON ((fighters.id = fightercontract.id))) LEFT JOIN fighterrecords ON ((fighters.id = fighterrecords.id))) LEFT JOIN fighternickname ON ((fighters.id = fighternickname.id))) LEFT JOIN fighterrating ON ((fighters.id = fighterrating.id))) LEFT JOIN fightercountry ON ((fighters.id = fightercountry.id))) LEFT JOIN fightersource ON ((fighters.source_id = fightersource.id))) LEFT JOIN country ON ((fightercountry.country = country.id)));


ALTER TABLE public.v_fighters OWNER TO jean;

--
-- Name: f_v_fighters_insert(v_fighters); Type: FUNCTION; Schema: public; Owner: jean
--

CREATE FUNCTION f_v_fighters_insert(data v_fighters) RETURNS void
    LANGUAGE plpgsql STABLE
    AS $$
        DECLARE
                fighter_id INTEGER;
        BEGIN
                INSERT INTO fighters (name, weightclass, source_id) VALUES (
	                data.name,
	                (SELECT id FROM weightclass WHERE name = data.weightclass),
	                (SELECT id FROM fightersource WHERE source = data.source)
	        ) 
                RETURNING id INTO fighter_id;
	        IF data.rating IS NOT NULL THEN
	                INSERT INTO fighterrating VALUES ( fighter_id, data.rating);
	        END IF;
	        IF data.record IS NOT NULL THEN
	                INSERT INTO fighterrecords VALUES ( fighter_id, data.record);
	        END IF;
	        IF data.contract IS NOT NULL THEN
	                INSERT INTO fightercontract VALUES ( fighter_id, data.contract);
	        END IF;
	        IF data.nickname IS NOT NULL THEN
	                INSERT INTO fighternickname VALUES ( fighter_id, data.nickname);
	        END IF;
	        IF data.country IS NOT NULL THEN
	                IF NOT EXISTS (SELECT id FROM country WHERE name = data.country) THEN
	                        INSERT INTO country (name) VALUES (data.country);
	                END IF;
	                INSERT INTO fightercountry VALUES (
	                        fighter_id,
	                        (SELECT id FROM country WHERE name = data.country)
	                );
	        END IF;
                SELECT f_v_fighter_camps_insert(fighter_id, data.camp);
        END;
$$;


ALTER FUNCTION public.f_v_fighters_insert(data v_fighters) OWNER TO jean;

--
-- Name: f_v_fighters_update(v_fighters); Type: FUNCTION; Schema: public; Owner: jean
--

CREATE FUNCTION f_v_fighters_update(data v_fighters) RETURNS void
    LANGUAGE plpgsql STABLE
    AS $$
        DECLARE
                fighter_id INTEGER := (SELECT id FROM fighters WHERE name = data.name);
        BEGIN
	        IF data.weightclass IS NOT NULL THEN
                        UPDATE fighters SET weightclass = (SELECT id FROM weightclass WHERE name = data.weightclass) WHERE id = fighter_id;
	        END IF;
	        IF data.source IS NOT NULL THEN
                        UPDATE fighters SET source_id = (SELECT id FROM fightersource WHERE name = data.source) WHERE id = fighter_id;
	        END IF;
	        IF data.rating IS NOT NULL THEN
	                UPDATE fighterrating SET rating = data.rating WHERE id = fighter_id;
	        END IF;
	        IF data.record IS NOT NULL THEN
	                UPDATE fighterrecords SET record = data.record WHERE id = fighter_id;
	        END IF;
	        IF data.contract IS NOT NULL THEN
	                UPDATE fightercontract SET contract = data.contract WHERE id = fighter_id;
	        END IF;
	        IF data.nickname IS NOT NULL THEN
	                UPDATE fighternickname SET nickname = data.nickname WHERE id = fighter_id;
	        END IF;
	        IF data.country IS NOT NULL THEN
	                IF NOT EXISTS (SELECT id FROM country WHERE name = data.country) THEN
	                        INSERT INTO country (name) VALUES (data.country);
	                END IF;
	                UPDATE fightercountry SET country = (SELECT id FROM country WHERE name = data.country) WHERE id = fighter_id;
	        END IF;
                SELECT f_v_fighter_camps_insert(fighter_id, data.camp);
        END;
$$;


ALTER FUNCTION public.f_v_fighters_update(data v_fighters) OWNER TO jean;

--
-- Name: f_v_moves_insert(integer, text, text, text); Type: FUNCTION; Schema: public; Owner: jean
--

CREATE FUNCTION f_v_moves_insert(move_id integer, camp text, prerequisit_moves text, prerequisit_skills text) RETURNS void
    LANGUAGE plpgsql STABLE
    AS $$
        DECLARE 
                skill TEXT[];
                camps_ RECORD;
        BEGIN
                FOR camps_ IN SELECT regexp_split_to_table AS t FROM regexp_split_to_table(camp, E'[[:space:]]*,[[:space:]]*') LOOP
                        INSERT INTO moves_camps VALUES (
                                move_id,
                                (SELECT id FROM camps WHERE name = camps_.t)
                        );
                END LOOP;
                IF prerequisit_moves IS NOT NULL THEN
                        INSERT INTO move_move_requirements VALUES ( move_id, (SELECT id FROM moves WHERE name = prerequisit_moves) );
                END IF;
                IF prerequisit_skills IS NOT NULL THEN
                        skill := regexp_split_to_array(prerequisit_skills, E'\\(|\\)');
                        INSERT INTO move_skill_requirements VALUES ( 
                                move_id,
                                (SELECT id FROM skills WHERE name = skill[1]),
                                (SELECT * FROM to_number(skill[2], '99')) 
                        );
                END IF;
        END;
$$;


ALTER FUNCTION public.f_v_moves_insert(move_id integer, camp text, prerequisit_moves text, prerequisit_skills text) OWNER TO jean;

--
-- Name: move_search(character varying); Type: FUNCTION; Schema: public; Owner: jean
--

CREATE FUNCTION move_search(character varying, OUT start_position character varying, OUT move character varying, OUT camp character varying) RETURNS record
    LANGUAGE sql
    AS $_$ select start_position, move, camp from position_move_camp_view where move like $1 $_$;


ALTER FUNCTION public.move_search(character varying, OUT start_position character varying, OUT move character varying, OUT camp character varying) OWNER TO jean;

--
-- Name: buttons_id_seq; Type: SEQUENCE; Schema: public; Owner: jean
--

CREATE SEQUENCE buttons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.buttons_id_seq OWNER TO jean;

--
-- Name: buttons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jean
--

ALTER SEQUENCE buttons_id_seq OWNED BY buttons.id;


--
-- Name: buttons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jean
--

SELECT pg_catalog.setval('buttons_id_seq', 39, true);


--
-- Name: combo_seq_seq; Type: SEQUENCE; Schema: public; Owner: jean
--

CREATE SEQUENCE combo_seq_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.combo_seq_seq OWNER TO jean;

--
-- Name: combo_seq_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jean
--

ALTER SEQUENCE combo_seq_seq OWNED BY combo.seq;


--
-- Name: combo_seq_seq; Type: SEQUENCE SET; Schema: public; Owner: jean
--

SELECT pg_catalog.setval('combo_seq_seq', 1515, true);


--
-- Name: country_id_seq; Type: SEQUENCE; Schema: public; Owner: jean
--

CREATE SEQUENCE country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.country_id_seq OWNER TO jean;

--
-- Name: country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jean
--

ALTER SEQUENCE country_id_seq OWNED BY country.id;


--
-- Name: country_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jean
--

SELECT pg_catalog.setval('country_id_seq', 29, true);


--
-- Name: fighter_moves; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE fighter_moves (
    fighter_id integer NOT NULL,
    move_id integer NOT NULL,
    level integer DEFAULT 1 NOT NULL,
    CONSTRAINT leve_range CHECK (((level >= 0) AND (level <= 3))),
    CONSTRAINT valid_level CHECK (((level >= 1) AND (level <= 3)))
);


ALTER TABLE public.fighter_moves OWNER TO jean;

--
-- Name: fighters_id_seq; Type: SEQUENCE; Schema: public; Owner: jean
--

CREATE SEQUENCE fighters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.fighters_id_seq OWNER TO jean;

--
-- Name: fighters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jean
--

ALTER SEQUENCE fighters_id_seq OWNED BY fighters.id;


--
-- Name: fighters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jean
--

SELECT pg_catalog.setval('fighters_id_seq', 349, true);


--
-- Name: fightersource_id_seq; Type: SEQUENCE; Schema: public; Owner: jean
--

CREATE SEQUENCE fightersource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.fightersource_id_seq OWNER TO jean;

--
-- Name: fightersource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jean
--

ALTER SEQUENCE fightersource_id_seq OWNED BY fightersource.id;


--
-- Name: fightersource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jean
--

SELECT pg_catalog.setval('fightersource_id_seq', 5, true);


--
-- Name: move_move_requirements; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE move_move_requirements (
    move_id integer NOT NULL,
    req_move_id integer NOT NULL
);


ALTER TABLE public.move_move_requirements OWNER TO jean;

--
-- Name: move_skill_requirements; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE move_skill_requirements (
    move_id integer NOT NULL,
    skill_id integer NOT NULL,
    level integer NOT NULL,
    CONSTRAINT level_range CHECK (((level >= 0) AND (level <= 100)))
);


ALTER TABLE public.move_skill_requirements OWNER TO jean;

--
-- Name: moves; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE moves (
    id integer NOT NULL,
    name character varying NOT NULL,
    type technique_type,
    start_position_id integer NOT NULL,
    end_position_id integer NOT NULL
);


ALTER TABLE public.moves OWNER TO jean;

--
-- Name: moves_camps; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE moves_camps (
    move_id integer NOT NULL,
    camp_id integer NOT NULL
);


ALTER TABLE public.moves_camps OWNER TO jean;

--
-- Name: positions; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE positions (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.positions OWNER TO jean;

--
-- Name: skills; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE skills (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.skills OWNER TO jean;

--
-- Name: skill_id_seq; Type: SEQUENCE; Schema: public; Owner: jean
--

CREATE SEQUENCE skill_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.skill_id_seq OWNER TO jean;

--
-- Name: skill_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jean
--

ALTER SEQUENCE skill_id_seq OWNED BY skills.id;


--
-- Name: skill_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jean
--

SELECT pg_catalog.setval('skill_id_seq', 16, true);


--
-- Name: skillfocii; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE skillfocii (
    skill_id integer NOT NULL,
    focus focusgroup NOT NULL
);


ALTER TABLE public.skillfocii OWNER TO jean;

--
-- Name: v_combos; Type: VIEW; Schema: public; Owner: jean
--

CREATE VIEW v_combos AS
    SELECT f_combos.seq, f_combos.move_id, f_combos.variant, f_combos.abbr FROM f_combos() f_combos(seq, move_id, variant, abbr) OFFSET 1;


ALTER TABLE public.v_combos OWNER TO jean;

--
-- Name: v_combos_aggregate; Type: VIEW; Schema: public; Owner: jean
--

CREATE VIEW v_combos_aggregate AS
    WITH RECURSIVE k(_grouping, _length, _count, _number, datum) AS (WITH lb(_grouping, _length, _count, _number, datum) AS (SELECT v_combos.move_id, 1, count(*) OVER (grouping_window) AS count, row_number() OVER (grouping_window) AS row_number, v_combos.abbr FROM v_combos WINDOW grouping_window AS (PARTITION BY v_combos.move_id)) SELECT lb._grouping, lb._length, lb._count, lb._number, lb.datum FROM lb UNION SELECT k._grouping, (k._length + 1), k._count, k._number, (((k.datum)::text || ', '::text) || (lb.datum)::text) FROM (k JOIN lb ON (((lb._grouping = k._grouping) AND (k._length = lb._number))))) SELECT k._grouping AS move_id, k.datum AS abbr FROM k WHERE ((k._count = k._length) AND (k._count = k._number));


ALTER TABLE public.v_combos_aggregate OWNER TO jean;

--
-- Name: v_fighter_moves; Type: VIEW; Schema: public; Owner: jean
--

CREATE VIEW v_fighter_moves AS
    SELECT fighters.id, fighter_moves.move_id, fighters.name, moves.name AS move, fighter_moves.level, moves.type FROM ((fighters LEFT JOIN fighter_moves ON ((fighters.id = fighter_moves.fighter_id))) LEFT JOIN moves ON ((fighter_moves.move_id = moves.id)));


ALTER TABLE public.v_fighter_moves OWNER TO jean;

--
-- Name: v_moves; Type: VIEW; Schema: public; Owner: jean
--

CREATE VIEW v_moves AS
    WITH x(_move, _length, camp) AS (WITH RECURSIVE z(_move, _length, _count, _number, camp) AS (WITH y(_move, _length, _count, _number, camp) AS (WITH move_camp(move, camp) AS (SELECT moves_camps.move_id, camps.name FROM (moves_camps JOIN camps ON ((moves_camps.camp_id = camps.id)))) SELECT move_camp.move, 1, count(*) OVER (move_window) AS count, row_number() OVER (move_window) AS row_number, move_camp.camp FROM move_camp WINDOW move_window AS (PARTITION BY move_camp.move)) SELECT y._move, y._length, y._count, y._number, y.camp FROM y UNION SELECT z._move, (z._length + 1), z._count, z._number, (((z.camp)::text || ', '::text) || (y.camp)::text) FROM (z JOIN y ON (((y._move = z._move) AND (z._length = y._number))))) SELECT z._move, z._length, z.camp FROM z WHERE ((z._count = z._length) AND (z._count = z._number))), j(_grouping, datum) AS (WITH RECURSIVE k(_grouping, _length, _count, _number, datum) AS (WITH lb(_grouping, _length, _count, _number, datum) AS (WITH grouping_datum(grouping, datum) AS (SELECT move_move_requirements.move_id, ((((moves.name)::text || ' ('::text) || (positions.name)::text) || ')'::text) FROM ((move_move_requirements JOIN moves ON ((move_move_requirements.req_move_id = moves.id))) JOIN positions ON ((moves.start_position_id = positions.id)))) SELECT grouping_datum.grouping, 1, count(*) OVER (grouping_window) AS count, row_number() OVER (grouping_window) AS row_number, grouping_datum.datum FROM grouping_datum WINDOW grouping_window AS (PARTITION BY grouping_datum.grouping)) SELECT lb._grouping, lb._length, lb._count, lb._number, lb.datum FROM lb UNION SELECT k._grouping, (k._length + 1), k._count, k._number, ((k.datum || ', '::text) || lb.datum) FROM (k JOIN lb ON (((lb._grouping = k._grouping) AND (k._length = lb._number))))) SELECT k._grouping, k.datum FROM k WHERE ((k._count = k._length) AND (k._count = k._number))), i(_grouping, datum) AS (WITH RECURSIVE k(_grouping, _length, _count, _number, datum) AS (WITH lb(_grouping, _length, _count, _number, datum) AS (WITH grouping_datum(grouping, datum) AS (SELECT move_skill_requirements.move_id, ((((skills.name)::text || '('::text) || move_skill_requirements.level) || ')'::text) FROM (move_skill_requirements JOIN skills ON ((move_skill_requirements.skill_id = skills.id)))) SELECT grouping_datum.grouping, 1, count(*) OVER (grouping_window) AS count, row_number() OVER (grouping_window) AS row_number, grouping_datum.datum FROM grouping_datum WINDOW grouping_window AS (PARTITION BY grouping_datum.grouping)) SELECT lb._grouping, lb._length, lb._count, lb._number, lb.datum FROM lb UNION SELECT k._grouping, (k._length + 1), k._count, k._number, ((k.datum || ', '::text) || lb.datum) FROM (k JOIN lb ON (((lb._grouping = k._grouping) AND (k._length = lb._number))))) SELECT k._grouping, k.datum FROM k WHERE ((k._count = k._length) AND (k._count = k._number))) SELECT moves.id, moves.name AS move, v_combos_aggregate.abbr AS key_combo, moves.type, a.name AS start_position, b.name AS end_position, x.camp, x._length AS camp_count, j.datum AS prerequisit_moves, i.datum AS prerequisit_skills FROM ((((((moves JOIN positions a ON ((moves.start_position_id = a.id))) JOIN positions b ON ((moves.end_position_id = b.id))) LEFT JOIN x ON ((moves.id = x._move))) LEFT JOIN j ON ((moves.id = j._grouping))) LEFT JOIN i ON ((moves.id = i._grouping))) LEFT JOIN v_combos_aggregate ON ((moves.id = v_combos_aggregate.move_id))) ORDER BY a.id, moves.id, x._length;


ALTER TABLE public.v_moves OWNER TO jean;

--
-- Name: v_position_moves; Type: VIEW; Schema: public; Owner: jean
--

CREATE VIEW v_position_moves AS
    WITH z("position", _length, moves) AS (WITH RECURSIVE x("position", _length, _count, _number, moves) AS (WITH y("position", _length, _count, _number, moves) AS (SELECT v_moves.start_position, 1, count(*) OVER (position_window) AS count, row_number() OVER (position_window) AS row_number, v_moves.move FROM v_moves WINDOW position_window AS (PARTITION BY v_moves.start_position)) SELECT y."position", y._length, y._count, y._number, y.moves FROM y UNION SELECT x."position", (x._length + 1), x._count, x._number, (((x.moves)::text || ', '::text) || (y.moves)::text) FROM (x JOIN y ON ((((y."position")::text = (x."position")::text) AND (x._length = y._number))))) SELECT x."position", x._length, x.moves FROM x WHERE ((x._count = x._length) AND (x._count = x._number))) SELECT z."position", z._length AS move_count, z.moves FROM z ORDER BY z."position", z._length;


ALTER TABLE public.v_position_moves OWNER TO jean;

--
-- Name: v_reverse_position_moves; Type: VIEW; Schema: public; Owner: jean
--

CREATE VIEW v_reverse_position_moves AS
    WITH z("position", _length, moves) AS (WITH RECURSIVE x("position", _length, _count, _number, moves) AS (WITH y("position", _length, _count, _number, moves) AS (SELECT v_moves.end_position, 1, count(*) OVER (position_window) AS count, row_number() OVER (position_window) AS row_number, v_moves.move FROM v_moves WINDOW position_window AS (PARTITION BY v_moves.end_position)) SELECT y."position", y._length, y._count, y._number, y.moves FROM y UNION SELECT x."position", (x._length + 1), x._count, x._number, (((x.moves)::text || ', '::text) || (y.moves)::text) FROM (x JOIN y ON ((((y."position")::text = (x."position")::text) AND (x._length = y._number))))) SELECT x."position", x._length, x.moves FROM x WHERE ((x._count = x._length) AND (x._count = x._number))) SELECT z."position", z._length AS move_count, z.moves FROM z ORDER BY z."position", z._length;


ALTER TABLE public.v_reverse_position_moves OWNER TO jean;

--
-- Name: v_transition_moves; Type: VIEW; Schema: public; Owner: jean
--

CREATE VIEW v_transition_moves AS
    WITH z(start_position, end_position, _length, moves) AS (WITH RECURSIVE x(start_position, end_position, _length, _count, _number, moves) AS (WITH y(start_position, end_position, _length, _count, _number, moves) AS (SELECT v_moves.start_position, v_moves.end_position, 1, count(*) OVER (position_window) AS count, row_number() OVER (position_window) AS row_number, v_moves.move FROM v_moves WHERE ((v_moves.start_position)::text <> (v_moves.end_position)::text) WINDOW position_window AS (PARTITION BY v_moves.start_position, v_moves.end_position)) SELECT y.start_position, y.end_position, y._length, y._count, y._number, y.moves FROM y UNION SELECT x.start_position, x.end_position, (x._length + 1), x._count, x._number, (((x.moves)::text || ', '::text) || (y.moves)::text) FROM (x JOIN y ON ((((y.start_position)::text = (x.start_position)::text) AND (x._length = y._number))))) SELECT x.start_position, x.end_position, x._length, x.moves FROM x WHERE ((x._count = x._length) AND (x._count = x._number))), c(start_position, end_position, _length, moves) AS (WITH RECURSIVE a(start_position, end_position, _length, _count, _number, moves) AS (WITH b(start_position, end_position, _length, _count, _number, moves) AS (SELECT v_moves.start_position, v_moves.end_position, 1, count(*) OVER (position_window) AS count, row_number() OVER (position_window) AS row_number, v_moves.move FROM v_moves WHERE ((v_moves.start_position)::text = (v_moves.end_position)::text) WINDOW position_window AS (PARTITION BY v_moves.start_position, v_moves.end_position)) SELECT b.start_position, b.end_position, b._length, b._count, b._number, b.moves FROM b UNION SELECT a.start_position, a.end_position, (a._length + 1), a._count, a._number, (((a.moves)::text || ', '::text) || (b.moves)::text) FROM (a JOIN b ON ((((b.start_position)::text = (a.start_position)::text) AND (a._length = b._number))))) SELECT a.start_position, a.end_position, a._length, a.moves FROM a WHERE ((a._count = a._length) AND (a._count = a._number))) SELECT z.start_position, z.end_position, z._length AS move_count, z.moves FROM z UNION SELECT c.start_position, c.end_position, c._length AS move_count, c.moves FROM c ORDER BY 1, 2, 3;


ALTER TABLE public.v_transition_moves OWNER TO jean;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: jean
--

ALTER TABLE buttons ALTER COLUMN id SET DEFAULT nextval('buttons_id_seq'::regclass);


--
-- Name: seq; Type: DEFAULT; Schema: public; Owner: jean
--

ALTER TABLE combo ALTER COLUMN seq SET DEFAULT nextval('combo_seq_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: jean
--

ALTER TABLE country ALTER COLUMN id SET DEFAULT nextval('country_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: jean
--

ALTER TABLE fighters ALTER COLUMN id SET DEFAULT nextval('fighters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: jean
--

ALTER TABLE fightersource ALTER COLUMN id SET DEFAULT nextval('fightersource_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: jean
--

ALTER TABLE skills ALTER COLUMN id SET DEFAULT nextval('skill_id_seq'::regclass);


--
-- Data for Name: buttons; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY buttons (id, abbr, name) FROM stdin;
1	sf	Step Forwards
2	sb	Step Backwards
3	lfu	Left Stick Flick Up
4	lfd	Left Stick Flick Down
5	lfl	Left Stick Flick Left
6	lfr	Left Stick Flick Right
7	lsu	Left Stick Up
8	lsd	Left Stick Down
9	lsl	Left Stick Left
10	lsr	Left Stick Right
11	rfu	Right Stick Flick Up
12	rfd	Right Stick Flick Down
13	rfl	Right Stick Flick Left
14	rfr	Right Stick Flick Right
15	lb	Left Bumper
16	rb	Right Bumper
17	lt	Left Trigger
18	rt	Right Trigger
19	a	A
20	b	B
21	x	X
22	y	Y
23	lsb	Left Stick Button
24	rsb	Right Stick Button
25	muc	Minor Transition Up and Clockwise
26	mdcc	Minor Transition Down and Counter Clockwise
27	mdc	Minor Transition Down and Clockwise
28	mucc	Minor Transition Up and Counter Clockwise
29	Muc	Major Transition Up and Clockwise
30	Mdcc	Major Transition Down and Counter Clockwise
31	Mdc	Major Transition Down and Clockwise
32	Mucc	Major Transition Up and Counter Clockwise
34	rsu	Right Stick Up
35	rsd	Right Stick Down
36	rsl	Right Stick Left
37	rsr	Right Stick Right
38	cage	Cage
39	ls	Left Stick
\.


--
-- Data for Name: camps; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY camps (id, name) FROM stdin;
1	10th Planet Jiu-Jitsu
2	Alliance Center
3	AMC Pankration
4	American Kickboxing Academy
5	American Top Team
6	Arizona Combat Sports
7	Brazilian Top Team
8	Cesar Gracie Jiu-Jitsu
9	Extreme MMA
10	Greg Jackson's Gym
11	Minnesota Martial Arts Academy
12	Rough House
13	Serra Jiu-Jitsu
14	Sityodtong
15	Team Blackhouse
16	Team Higashi
17	Team Link
18	Team Militant
19	Team Penn
20	Team Punishment
21	Team Quest
22	Team Tompkins
23	The Arena
24	The HIT Squad
25	The Pit
26	Wolfslair MMA Academy
27	Zahabi MMA
\.


--
-- Data for Name: combo; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY combo (move_id, button_id, seq, variant) FROM stdin;
12	39	1304	1
12	15	1305	1
12	22	1306	1
19	39	1307	1
19	15	1308	1
19	21	1309	1
19	39	1310	2
19	15	1311	2
19	22	1312	2
28	39	1313	1
28	15	1314	1
28	21	1315	1
28	39	1316	2
28	15	1317	2
28	22	1318	2
29	39	1319	1
29	15	1320	1
29	19	1321	1
29	39	1322	2
29	15	1323	2
29	20	1324	2
193	15	1325	1
193	21	1326	1
193	15	1327	2
193	22	1328	2
194	15	1329	1
194	21	1330	1
194	15	1331	2
194	22	1332	2
198	39	1333	1
198	15	1334	1
198	21	1335	1
198	39	1336	2
198	15	1337	2
198	22	1338	2
209	15	1339	1
209	25	1340	1
209	15	1341	2
209	26	1342	2
214	15	1343	1
214	21	1344	1
214	15	1345	2
214	22	1346	2
215	39	1347	1
215	15	1348	1
215	21	1349	1
215	39	1350	2
215	15	1351	2
215	22	1352	2
248	15	1353	1
248	21	1354	1
248	15	1355	2
248	22	1356	2
251	39	1357	1
251	15	1358	1
251	21	1359	1
251	39	1360	2
251	15	1361	2
251	22	1362	2
270	15	1363	1
270	21	1364	1
281	39	1365	1
281	15	1366	1
281	21	1367	1
283	39	1368	1
283	15	1369	1
283	19	1370	1
284	39	1371	1
284	15	1372	1
284	20	1373	1
305	39	1374	1
305	15	1375	1
305	21	1376	1
305	39	1377	2
305	15	1378	2
305	22	1379	2
307	15	1380	1
307	21	1381	1
308	15	1382	1
308	22	1383	1
310	15	1384	1
310	19	1385	1
310	15	1386	2
310	20	1387	2
314	15	1388	1
314	19	1389	1
315	13	1390	1
315	21	1391	1
315	11	1392	2
315	21	1393	2
315	12	1394	3
315	21	1395	3
315	14	1396	4
315	21	1397	4
316	13	1398	1
316	22	1399	1
316	11	1400	2
316	22	1401	2
316	12	1402	3
316	22	1403	3
316	14	1404	4
316	22	1405	4
10	39	1406	1
10	15	1407	1
10	24	1408	1
9	15	1409	1
9	24	1410	1
11	24	1411	1
15	24	1412	1
17	24	1413	1
16	15	1414	1
16	24	1415	1
18	24	1416	1
22	15	1417	1
22	24	1418	1
23	24	1419	1
25	15	1420	1
25	24	1421	1
24	39	1422	1
24	15	1423	1
24	24	1424	1
26	39	1425	1
26	15	1426	1
26	24	1427	1
27	24	1428	1
157	15	1429	1
157	24	1430	1
160	24	1431	1
175	24	1432	1
176	24	1433	1
181	24	1434	1
185	15	1435	1
185	24	1436	1
186	24	1437	1
189	15	1438	1
189	24	1439	1
190	15	1440	1
190	24	1441	1
191	24	1442	1
192	15	1443	1
192	24	1444	1
195	24	1445	1
196	39	1446	1
196	24	1447	1
199	39	1448	1
199	15	1449	1
199	24	1450	1
208	24	1451	1
211	24	1452	1
213	39	1453	1
213	24	1454	1
212	24	1455	1
227	39	1456	1
227	24	1457	1
228	24	1458	1
230	24	1459	1
231	24	1460	1
232	15	1461	1
232	24	1462	1
233	15	1463	1
233	24	1464	1
236	24	1465	1
237	15	1466	1
237	24	1467	1
240	15	1468	1
240	24	1469	1
243	24	1470	1
244	15	1471	1
244	24	1472	1
245	15	1473	1
245	24	1474	1
246	15	1475	1
246	24	1476	1
247	24	1477	1
249	15	1478	1
249	24	1479	1
250	15	1480	1
250	24	1481	1
252	15	1482	1
252	24	1483	1
262	15	1484	1
262	24	1485	1
263	15	1486	1
263	24	1487	1
264	24	1488	1
267	24	1489	1
269	15	1490	1
269	24	1491	1
277	15	1492	1
277	24	1493	1
278	24	1494	1
279	15	1495	1
279	24	1496	1
280	39	1497	1
280	24	1498	1
282	24	1499	1
301	24	1500	1
302	15	1501	1
302	24	1502	1
303	24	1503	1
304	39	1504	1
304	15	1505	1
304	24	1506	1
309	15	1507	1
309	24	1508	1
311	24	1509	1
312	15	1510	1
312	24	1511	1
313	15	1512	1
313	24	1513	1
317	15	1514	1
317	24	1515	1
216	15	652	1
216	25	653	1
216	19	654	1
216	15	655	2
216	26	656	2
216	19	657	2
216	15	658	3
216	25	659	3
216	20	660	3
216	15	661	4
216	26	662	4
216	20	663	4
217	15	664	1
217	19	665	1
217	15	666	2
217	20	667	2
220	15	668	1
220	21	669	1
220	15	670	2
220	22	671	2
221	15	672	1
221	19	673	1
221	15	674	2
221	20	675	2
222	19	676	1
222	20	677	2
224	15	678	1
224	25	679	1
224	19	680	1
224	15	681	2
224	26	682	2
224	19	683	2
224	15	684	3
224	25	685	3
224	20	686	3
224	15	687	4
224	26	688	4
224	20	689	4
225	15	690	1
225	19	691	1
225	15	692	2
225	20	693	2
226	15	694	1
226	21	695	1
226	15	696	2
226	22	697	2
288	15	698	1
288	19	699	1
288	15	700	2
288	20	701	2
289	15	702	1
289	21	703	1
289	15	704	2
289	22	705	2
290	15	706	1
290	22	707	1
291	15	708	1
291	19	709	1
291	15	710	2
291	20	711	2
292	15	712	1
292	21	713	1
292	15	714	2
292	22	715	2
293	17	716	1
293	22	717	1
295	15	718	1
295	22	719	1
296	15	720	1
296	22	721	1
3	25	722	1
3	26	723	2
165	29	724	1
165	30	725	2
166	15	726	1
166	25	727	1
166	15	728	2
166	26	729	2
170	15	730	1
170	25	731	1
170	15	732	2
170	26	733	2
171	29	734	1
171	30	735	2
172	15	736	1
172	25	737	1
172	15	738	2
172	26	739	2
218	15	740	1
218	25	741	1
218	15	742	2
218	26	743	2
219	29	744	1
219	30	745	2
257	25	746	1
257	26	747	2
261	25	748	1
261	26	749	2
40	17	750	1
40	19	751	1
44	15	752	1
44	20	753	1
45	17	754	1
45	20	755	1
48	17	756	1
48	10	757	1
48	19	758	1
49	17	759	1
49	10	760	1
49	20	761	1
53	1	762	1
53	15	763	1
53	10	764	1
53	19	765	1
54	15	766	1
54	9	767	1
54	19	768	1
55	15	769	1
55	9	770	1
55	20	771	1
59	15	772	1
59	19	773	1
60	15	774	1
60	19	775	1
61	15	776	1
61	19	777	1
66	15	778	1
66	9	779	1
66	19	780	1
68	15	781	1
68	9	782	1
68	19	783	1
71	15	784	1
71	19	785	1
72	15	786	1
72	9	787	1
72	19	788	1
78	1	789	1
78	15	790	1
78	10	791	1
78	19	792	1
80	15	793	1
80	19	794	1
81	15	795	1
81	10	796	1
81	19	797	1
82	1	798	1
82	15	799	1
82	10	800	1
82	19	801	1
87	15	802	1
87	9	803	1
87	19	804	1
88	15	805	1
88	9	806	1
88	19	807	1
91	1	808	1
91	15	809	1
91	10	810	1
91	19	811	1
98	15	812	1
98	19	813	1
101	15	814	1
101	20	815	1
102	15	816	1
102	10	817	1
102	19	818	1
107	15	819	1
107	19	820	1
108	15	821	1
108	9	822	1
108	20	823	1
110	15	824	1
110	10	825	1
110	20	826	1
111	15	827	1
111	20	828	1
113	15	829	1
113	10	830	1
113	20	831	1
114	1	832	1
114	15	833	1
114	10	834	1
114	20	835	1
115	15	836	1
115	9	837	1
115	20	838	1
117	15	839	1
117	20	840	1
118	15	841	1
118	9	842	1
118	20	843	1
119	15	844	1
119	20	845	1
123	15	846	1
123	9	847	1
123	20	848	1
124	15	849	1
124	9	850	1
124	20	851	1
130	15	852	1
130	9	853	1
130	20	854	1
131	15	855	1
131	20	856	1
132	15	857	1
132	10	858	1
132	20	859	1
133	1	860	1
133	15	861	1
133	10	862	1
133	20	863	1
134	15	864	1
134	10	865	1
134	20	866	1
138	1	867	1
138	15	868	1
138	10	869	1
138	20	870	1
145	1	871	1
145	15	872	1
145	10	873	1
145	20	874	1
150	17	875	1
150	10	876	1
150	19	877	1
151	17	878	1
151	10	879	1
151	20	880	1
152	15	881	1
152	19	882	1
153	1	883	1
153	15	884	1
153	10	885	1
153	19	886	1
154	1	887	1
154	15	888	1
154	10	889	1
154	20	890	1
155	1	891	1
155	15	892	1
155	10	893	1
155	20	894	1
38	15	895	1
38	21	896	1
39	15	897	1
39	22	898	1
41	15	899	1
41	10	900	1
41	21	901	1
42	16	902	1
42	5	903	1
42	21	904	1
43	15	905	1
43	22	906	1
46	15	907	1
46	10	908	1
46	22	909	1
47	16	910	1
47	5	911	1
47	22	912	1
51	15	913	1
51	9	914	1
51	22	915	1
50	15	916	1
50	10	917	1
50	22	918	1
52	15	919	1
52	10	920	1
52	22	921	1
56	15	922	1
56	10	923	1
56	22	924	1
57	15	925	1
57	21	926	1
58	15	927	1
58	22	928	1
62	15	929	1
62	22	930	1
63	15	931	1
63	10	932	1
63	22	933	1
64	15	934	1
64	10	935	1
64	22	936	1
65	15	937	1
65	22	938	1
67	15	939	1
67	21	940	1
69	15	941	1
69	9	942	1
69	21	943	1
70	15	944	1
70	21	945	1
73	16	946	1
73	5	947	1
73	21	948	1
74	16	949	1
74	6	950	1
74	21	951	1
75	16	952	1
75	3	953	1
75	21	954	1
76	16	955	1
76	4	956	1
76	21	957	1
77	15	958	1
77	9	959	1
77	21	960	1
79	15	961	1
79	10	962	1
79	21	963	1
83	15	964	1
83	21	965	1
84	15	966	1
84	21	967	1
85	11	968	1
85	21	969	1
85	14	970	2
85	21	971	2
85	13	972	3
85	21	973	3
85	12	974	4
85	21	975	4
86	15	976	1
86	21	977	1
89	15	978	1
89	10	979	1
89	21	980	1
90	15	981	1
90	10	982	1
90	21	983	1
92	15	984	1
92	10	985	1
92	21	986	1
93	15	987	1
93	10	988	1
93	21	989	1
95	15	990	1
95	9	991	1
95	21	992	1
94	15	993	1
94	9	994	1
94	21	995	1
96	15	996	1
96	10	997	1
96	21	998	1
97	15	999	1
97	10	1000	1
97	22	1001	1
99	15	1002	1
99	22	1003	1
100	1	1004	1
100	15	1005	1
100	10	1006	1
100	22	1007	1
103	16	1008	1
103	6	1009	1
103	21	1010	1
104	15	1011	1
104	22	1012	1
105	16	1013	1
105	6	1014	1
105	22	1015	1
106	16	1016	1
106	22	1017	1
109	15	1018	1
109	22	1019	1
112	15	1020	1
112	22	1021	1
116	15	1022	1
116	22	1023	1
120	16	1024	1
120	5	1025	1
120	22	1026	1
121	16	1027	1
121	3	1028	1
121	21	1029	1
122	16	1030	1
122	4	1031	1
122	22	1032	1
125	15	1033	1
125	22	1034	1
126	15	1035	1
126	22	1036	1
127	15	1037	1
127	10	1038	1
127	22	1039	1
128	15	1040	1
128	10	1041	1
128	22	1042	1
129	15	1043	1
129	22	1044	1
135	11	1045	1
135	22	1046	1
135	14	1047	2
135	22	1048	2
135	13	1049	3
135	22	1050	3
135	12	1051	4
135	22	1052	4
136	15	1053	1
136	10	1054	1
136	22	1055	1
137	15	1056	1
137	10	1057	1
137	22	1058	1
139	15	1059	1
139	10	1060	1
139	22	1061	1
140	15	1062	1
140	10	1063	1
140	22	1064	1
141	15	1065	1
141	22	1066	1
142	15	1067	1
142	9	1068	1
142	22	1069	1
143	1	1070	1
143	15	1071	1
143	10	1072	1
143	21	1073	1
146	1	1074	1
146	15	1075	1
146	10	1076	1
146	21	1077	1
147	1	1078	1
147	15	1079	1
147	10	1080	1
147	21	1081	1
148	1	1082	1
148	15	1083	1
148	10	1084	1
148	22	1085	1
149	1	1086	1
149	15	1087	1
149	10	1088	1
149	22	1089	1
156	15	1090	1
156	22	1091	1
168	15	1092	1
168	25	1093	1
168	15	1094	2
168	26	1095	2
294	15	1096	1
294	25	1097	1
294	15	1098	2
294	26	1099	2
5	15	1100	1
5	25	1101	1
5	15	1102	2
5	26	1103	2
6	15	1104	1
6	25	1105	1
6	15	1106	2
6	26	1107	2
259	15	1108	1
259	25	1109	1
259	15	1110	2
259	26	1111	2
7	15	1112	1
7	25	1113	1
7	15	1114	2
7	26	1115	2
256	15	1116	1
256	25	1117	1
1	15	1118	1
1	25	1119	1
1	15	1120	2
1	26	1121	2
258	15	1122	1
258	25	1123	1
33	15	1124	1
33	25	1125	1
33	15	1126	2
33	26	1127	2
169	15	1128	1
169	25	1129	1
169	15	1130	2
169	26	1131	2
36	15	1132	1
36	25	1133	1
36	15	1134	2
36	26	1135	2
35	15	1136	1
35	25	1137	1
35	15	1138	2
35	26	1139	2
174	15	1140	1
174	25	1141	1
174	15	1142	2
174	26	1143	2
297	15	1144	1
297	25	1145	1
297	15	1146	2
297	26	1147	2
164	15	1148	1
164	25	1149	1
164	15	1150	2
164	26	1151	2
32	15	1152	1
32	25	1153	1
32	15	1154	2
32	26	1155	2
34	15	1156	1
34	25	1157	1
34	15	1158	2
34	26	1159	2
2	15	1160	1
2	25	1161	1
2	15	1162	2
2	26	1163	2
37	15	1164	1
37	25	1165	1
37	15	1166	2
37	26	1167	2
298	15	1168	1
298	25	1169	1
298	15	1170	2
298	26	1171	2
144	17	1172	1
144	37	1173	1
223	15	1174	1
223	25	1175	1
223	15	1176	2
223	26	1177	2
260	15	1178	1
260	25	1179	1
260	15	1180	2
260	26	1181	2
167	15	1182	1
167	25	1183	1
167	15	1184	2
167	26	1185	2
173	15	1186	1
173	25	1187	1
173	15	1188	2
173	26	1189	2
4	29	1190	1
4	30	1191	2
8	29	1192	1
8	30	1193	2
14	29	1194	1
14	30	1195	2
13	15	1196	1
13	25	1197	1
13	15	1198	2
13	26	1199	2
20	29	1200	1
20	30	1201	2
21	25	1202	1
31	30	1203	1
30	29	1204	1
162	25	1205	1
162	26	1206	2
163	15	1207	1
163	25	1208	1
163	15	1209	2
163	26	1210	2
161	29	1211	1
161	30	1212	2
158	25	1213	1
158	26	1214	2
159	29	1215	1
159	30	1216	2
179	29	1217	1
178	30	1218	1
177	25	1219	1
177	26	1220	2
184	29	1221	1
183	30	1222	1
182	15	1223	1
182	25	1224	1
182	15	1225	2
182	26	1226	2
180	38	1227	1
180	25	1228	1
188	29	1229	1
187	30	1230	1
200	15	1231	1
200	26	1232	1
202	25	1233	1
201	15	1234	1
201	26	1235	1
204	25	1236	1
204	26	1237	2
203	15	1238	1
203	25	1239	1
203	15	1240	2
203	26	1241	2
207	15	1242	1
207	25	1243	1
207	15	1244	2
207	26	1245	2
206	25	1246	1
206	26	1247	2
205	38	1248	1
205	25	1249	1
229	29	1250	1
229	30	1251	2
235	29	1252	1
235	30	1253	2
234	25	1254	1
234	26	1255	2
239	29	1256	1
239	30	1257	2
238	15	1258	1
238	25	1259	1
238	15	1260	2
238	26	1261	2
242	15	1262	1
242	25	1263	1
242	15	1264	2
242	26	1265	2
241	29	1266	1
241	30	1267	2
255	15	1268	1
255	25	1269	1
255	15	1270	2
255	26	1271	2
254	15	1272	1
254	25	1273	1
254	15	1274	2
254	26	1275	2
253	25	1276	1
253	26	1277	2
266	25	1278	1
266	26	1279	2
265	29	1280	1
265	30	1281	2
268	25	1282	1
268	26	1283	2
271	25	1284	1
271	26	1285	2
276	30	1286	1
275	25	1287	1
274	15	1288	1
274	26	1289	1
273	29	1290	1
272	38	1291	1
272	25	1292	1
287	15	1293	1
287	25	1294	1
286	15	1295	1
286	26	1296	1
285	26	1297	1
300	25	1298	1
300	26	1299	2
299	29	1300	1
299	30	1301	2
306	29	1302	1
306	30	1303	2
\.


--
-- Data for Name: country; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY country (id, name) FROM stdin;
1	Armenia
2	Australia
3	Bahamas
4	Belarus
5	Brazil
6	Bulgaria
7	Canada
8	China
9	Croatia
10	Cuba
11	Cyprus
12	Czech Republic
13	Denmark
14	El Salvador
15	England
16	France
17	Germany
18	Haiti
19	Iran
20	Italy
21	Japan
22	Netherlands
23	New Zealand
24	Nigeria
25	Poland
26	Russia
27	South Korea
28	Sweden
29	United States of America
\.


--
-- Data for Name: fighter_camps; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY fighter_camps (fighter_id, camp_id) FROM stdin;
27	16
2	26
55	9
49	11
47	18
168	15
95	10
5	15
178	26
63	5
113	12
181	15
157	21
153	15
102	9
99	4
3	9
93	19
103	10
1	21
97	23
190	9
98	4
96	4
92	24
100	13
101	4
183	10
147	20
149	10
148	3
159	6
152	14
155	26
112	9
151	2
184	11
182	4
13	21
150	9
177	14
156	10
234	27
45	8
158	5
235	9
269	26
270	10
271	4
272	2
273	6
274	16
275	17
276	10
277	13
278	25
279	27
280	1
281	16
282	6
283	21
284	24
285	26
286	5
287	12
288	14
289	18
290	20
291	2
292	23
293	25
294	9
295	17
296	11
297	21
298	20
299	26
300	11
301	10
302	10
303	3
304	20
305	24
306	10
307	25
308	10
309	19
310	5
311	22
312	7
313	4
314	7
315	14
316	6
317	20
318	11
319	12
320	16
321	7
322	10
323	8
324	17
325	14
326	15
327	1
328	1
329	8
330	16
331	6
332	16
333	5
334	21
335	5
336	9
336	6
336	16
336	1
347	21
348	4
348	11
347	6
347	20
349	6
349	21
349	4
349	9
\.


--
-- Data for Name: fighter_moves; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY fighter_moves (fighter_id, move_id, level) FROM stdin;
\.


--
-- Data for Name: fightercontract; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY fightercontract (id, contract) FROM stdin;
274	UFN
286	UFN
278	UFN
269	WFA
270	UFC
283	UFC
126	UFN
94	UFN
157	UFN
179	UFN
47	UFN
63	UFN
57	UFN
75	UFN
302	UFC
271	WFA
110	UFN
102	UFN
180	UFN
168	WFA
178	UFC
95	UFC
181	UFC
49	UFC
99	UFC
43	UFC
5	UFC
153	UFC
272	WFA
273	WFA
1	UFN
190	UFN
185	UFN
106	UFN
103	UFC
97	UFC
101	UFC
147	UFC
100	UFC
96	UFC
98	UFC
93	UFC
189	UFC
92	UFC
183	UFC
12	UFN
50	UFN
156	UFN
152	UFN
15	UFN
67	UFN
161	UFN
112	UFN
17	UFN
158	UFC
13	UFC
150	UFC
182	UFC
177	UFC
45	UFC
159	UFC
336	WFA
2	UFC
155	UFC
18	UFC
3	UFC
27	UFC
7	UFC
55	UFC
160	UFC
21	UFC
113	UFC
11	UFC
162	UFC
234	UFC
151	UFC
235	UFC
184	UFC
56	UFC
119	UFC
148	UFC
149	UFC
275	WFA
276	WFA
277	WFA
279	WFA
280	WFA
281	WFA
282	WFA
284	WFA
285	WFA
287	WFA
288	WFA
290	WFA
291	WFA
292	WFA
293	WFA
296	WFA
297	WFA
298	WFA
299	WFA
300	WFA
301	WFA
303	WFA
305	WFA
307	WFA
311	WFA
312	WFA
313	WFA
314	WFA
316	WFA
318	WFA
319	WFA
320	WFA
321	WFA
323	WFA
324	WFA
326	WFA
327	WFA
328	WFA
329	WFA
330	WFA
331	WFA
332	WFA
334	WFA
306	UFC
317	UFC
333	UFC
295	UFC
322	UFC
345	UFC
346	UFC
289	UFN
310	UFN
308	UFN
294	UFN
304	UFN
315	UFN
325	UFN
309	UFN
335	UFN
337	UFN
338	UFN
339	UFN
340	UFN
341	UFN
342	UFN
343	UFN
344	UFN
\.


--
-- Data for Name: fightercountry; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY fightercountry (id, country) FROM stdin;
30	2
46	3
22	5
29	5
32	5
44	5
79	5
82	5
10	7
35	7
53	7
38	11
66	15
88	15
76	19
9	20
41	21
39	27
20	29
23	29
24	29
25	29
26	29
28	29
33	29
34	29
36	29
37	29
40	29
51	29
52	29
146	5
175	5
176	6
125	7
129	7
140	15
136	17
141	28
62	29
68	29
78	5
83	7
81	21
59	24
42	29
126	15
94	29
48	29
169	2
154	4
130	5
242	29
157	25
127	7
167	9
174	12
179	9
115	15
170	16
47	29
164	28
63	29
69	29
61	2
6	5
57	29
75	15
110	27
102	13
180	22
168	5
178	16
95	7
181	5
49	29
99	5
43	29
5	5
153	5
70	29
77	29
80	29
85	29
86	29
239	5
219	5
261	5
265	5
145	5
266	7
249	10
217	14
215	15
264	15
218	18
230	21
268	21
195	23
246	25
4	29
8	29
109	29
114	29
117	29
118	29
122	29
128	29
132	29
134	29
135	29
137	29
139	29
143	29
186	29
191	29
193	29
196	29
198	29
199	29
204	29
208	29
213	29
214	29
216	29
87	29
90	29
238	1
245	5
240	7
257	8
197	15
258	27
1	29
107	29
108	29
120	29
121	29
123	29
124	29
190	29
185	29
187	29
188	29
106	29
203	29
212	29
72	29
89	29
200	15
73	29
103	29
97	29
101	29
147	29
100	29
96	29
98	29
93	29
189	5
92	29
183	29
220	29
222	29
226	29
227	29
229	29
236	29
247	29
250	29
262	29
267	29
206	29
14	29
16	29
19	29
163	29
165	29
84	29
223	29
228	29
231	29
244	29
248	29
251	29
252	29
253	29
255	29
256	29
166	29
60	5
71	5
91	5
64	7
74	7
31	29
54	29
171	5
144	15
173	23
58	29
65	29
202	15
211	5
232	5
241	5
233	15
210	21
254	21
104	29
105	29
111	29
116	29
131	29
133	29
138	29
142	29
172	29
192	29
194	29
201	29
205	29
207	29
209	29
221	29
224	29
225	29
237	29
243	29
259	29
260	29
263	29
12	29
50	26
156	29
152	29
15	29
67	15
161	29
112	29
17	29
158	5
13	29
150	29
182	29
177	29
45	29
159	29
336	7
2	15
155	29
18	5
3	5
27	21
7	21
55	29
160	5
21	29
113	15
11	5
162	5
234	29
151	29
235	29
184	29
56	29
119	5
148	29
149	29
\.


--
-- Data for Name: fighternickname; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY fighternickname (id, nickname) FROM stdin;
30	KO
46	Thugjitsu Master
22	Toquinho
29	The Sandman
32	Sapo
44	Tibau
79	Tractor
82	Junior
10	The Athlete
35	The Promise
53	Hands of Stone
38	Costa
66	Relentless
88	Sassangle
76	Prince of Persia
9	Legionarius
41	Killer Bee
39	The Ox
20	The Doberman
23	The Barbarian
24	The Jersey Devil
25	Crazy
26	Filthy
28	The Master of Disaster
33	The Messenger
34	The Crusher
36	The All-American
37	Mayhem
40	The Gentleman
51	Lil' Heathen
52	Handsome
146	Indio
175	Markes
176	Staki
125	Ares
129	Pimp Daddy
140	Scanno
136	Panzer
141	Makambo
62	Last Call
68	Smooth
78	do Bronx
83	The Bull
81	The Fireball Kid
59	The Assassin
42	The Young Assassin
126	Lightning
94	Lights Out
48	The Cowboy
169	The Hippo
154	The Janitor
130	Ta Danado
242	Cub
157	The Polish Experiment
127	The Prince
167	The Duke
174	The Terminator
179	Cro Cop
115	The Hitman
170	The Snake
47	The King
164	The Mauler
63	Magrinho
69	The Carny
57	J-Lau
75	The Real Deal
110	Stun Gun
102	Hitman
180	Skyscraper
168	Little Nog
178	Kongo
95	Rush
181	Cigano
49	The Muscle Shark
99	Pitbull
43	The Carpenter
5	The Spider
153	The Dragon
70	Showtime
77	Christmas
80	Danny Boy
85	Big Time
86	FaloFalo
239	Junior
219	Barão
261	Marajó
265	Sertanejo
145	Beicao
266	Pato
249	Showtime
217	Pride of El Salvador
215	One-Punch
264	Shotgun
218	Tiger
230	Kid
268	Iron Broom
195	Super Samoan
246	Bartimus
4	El Conquistador
8	All American
109	Superman
114	Quicksand
117	Darkness
118	Ninja
122	Bang
128	Bad Boy
132	TJ
134	C-Murder
135	Heavy Metal
137	Fast Eddie
139	Daudi
143	Lil' Monster
186	Meathead
191	Big Country
193	Hapa
196	Big
198	Pee-Wee
199	Big Red
204	Young Guns
208	Joe-B-Wan Kenobi
213	Big Frog
214	Mighty Mouse
216	Kamikaze
87	El Cucuy
90	The Spider
238	The Anvil
245	The Gun
240	The Machine
257	The Mongolian Wolf
197	The Bear
258	The Korean Zombie
1	The Crippler
107	The Immortal
108	The Horror
120	The Juggernaut
121	The Foster Boy
123	The Raging Bull
124	The Spaniard
190	The Texas Crazy Horse
185	HD
187	The Hybrid
188	The Mexicutioner
106	Rumble
203	The California Kid
212	The Angel of Death
73	3D
103	The Natural Born Killer
97	The Dream
101	Quick
147	The Huntington Beach Bad Boy
100	The Terror
96	Kos
93	The Prodigy
189	Minotauro
183	The Engineer
220	Mayday
222	Hurricane
226	Hellbound
227	Apache Kid
229	Eagle Eye
236	Bad Boy
247	Money
250	New Breed
262	Bruce Leroy
267	The Kid
206	Dominator
14	The Filipino Wrecking Machine
16	Short Fuse
19	A-Train
163	Mr. Wonderful
165	Kingsbu
84	The Menace
223	The Barn Owl
228	El Feroz
231	The Hulk
244	The Bully
248	The Fluke
251	da Menace
252	The Real One
253	The Diamond
255	The Damage
256	The Scarecrow
166	The Fire
12	The Talent
156	Bones
152	The American Psycho
15	Rock
161	The Hitman
159	Darth
336	The Monster
2	The Count
155	Rampage
18	The Axe Murderer
3	The Phenom
27	Sexyama
7	Thunder
55	The Bully
160	Banha
21	The Robot
113	The Outlaw
162	Shogun
234	KenFlo
151	The Truth
56	The Answer
148	Ace
149	Suga
347	The Hurricane
348	Savage
349	The Dragon
\.


--
-- Data for Name: fighterrating; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY fighterrating (id, rating) FROM stdin;
274	69
286	70
278	72
270	74
283	76
126	71
94	69
157	71
179	72
47	72
63	70
57	70
75	70
302	73
110	72
102	72
180	72
178	74
95	79
181	75
49	77
99	76
43	73
5	78
153	78
1	72
190	72
185	72
106	69
103	73
97	74
101	74
147	74
100	75
96	76
98	77
93	79
189	76
92	76
183	76
12	72
50	69
156	72
152	69
15	70
67	70
161	71
112	72
17	72
158	76
13	76
150	73
182	77
177	77
45	73
159	73
2	74
155	76
18	74
3	76
27	73
7	76
55	77
160	73
21	73
113	74
11	76
162	77
234	77
151	73
235	77
184	77
56	77
119	74
148	75
149	76
306	73
317	73
333	73
295	74
322	77
345	74
346	74
289	67
310	67
308	70
294	71
304	71
315	71
325	71
309	72
335	72
337	69
338	69
339	69
340	70
341	70
342	71
343	72
344	72
\.


--
-- Data for Name: fighterrecords; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY fighterrecords (id, record) FROM stdin;
30	3–0
46	8–5
22	5–2
29	1–3
32	1–1–1
44	9–5
79	1–3
82	2–0
10	6–6
35	2–0
53	6–5
38	1–1
66	4–5
88	1–0
76	3–1–1
9	6–5 (1 NC)
41	0–1
39	1–1
20	5–3
23	4–3
24	3–2
25	3–2
26	3–2
28	1–3
33	1–2
34	2–0
36	2–0
37	1–1
40	0–1
51	7–5
52	7–4
146	0–0
175	0–0
176	0–0
125	3–1
129	1–1
140	0–1
136	1–0
141	0–0
62	6–3
68	6–1
78	2–1 (1 NC)
83	2–0
81	1–2
59	6–4
42	10–4
126	2–2
94	9–10
48	8–3 (1 NC)
169	1–3
154	7–3
130	1–1
242	5–3
157	6–2
127	3–0
167	2–3
174	1–1
179	4–5
115	5–1
170	2–1
47	7–6
164	4–1
63	6–3
69	5–0–1 (1 NC)
61	7–2
6	11–1–1
57	7–3
75	4–1
110	5–1 (1 NC)
102	8–4
180	5–3
168	2–2
178	9–4–1
95	16–2
181	7–0
49	8–4
99	10–5
43	9–5
5	13–0
153	9–2
70	5–2
77	3–2
80	1–2
85	1–1
86	0–2
239	9–0
219	3–0
261	1–0
265	0–0
145	0–0
266	0–0
249	3–3
217	2–2
215	3–1
264	0–1
218	1–3
230	0–1
268	0–0
195	1–1
246	4–3
4	7–7
8	9–3
109	3–5
114	4–3
117	3–3
118	3–3
122	3–2
128	2–0
132	1–1
134	1–0
135	1–0
137	0–1
139	0–1
143	0–0
186	5–0
191	2–2
193	2–0–1
196	1–1
198	1–0
199	0–1
204	8–3
208	6–2
213	1–5
214	4–1
216	2–2
87	1–0
90	0–1
238	5–5
245	5–2
240	6–3
257	2–1
197	1–0
258	1–2
1	12–6
107	5–4
108	6–2
120	4–1
121	3–2
123	3–1
124	3–1
190	2–3
185	3–3
187	4–1
188	3–2
106	6–3
203	9–4
212	3–3
72	3–4
89	0–1
200	0–0
73	4–2
103	9–1
97	12–4
101	9–3
147	15–9–1
100	7–7
96	13–5
98	13–1–1
93	12–6–2
189	3–2
92	18–6
183	4–2
220	3–0
222	1–1
226	1–0
227	0–1
229	0–1
236	6–6–1
247	6–0
250	4–1
262	0–1
267	0–0
206	8–1
14	8–2
16	5–5
19	6–2
163	5–0
165	4–1
84	1–1
223	1–1
228	0–1
231	0–0
244	5–2
248	4–2
251	2–3
252	1–4
253	3–1
255	2–1
256	2–1
166	3–2
60	5–4–1
71	4–3
91	0–1
64	5–4
74	3–3
31	2–1
54	9–1
171	1–1
144	0–0
173	1–1
58	7–3
65	4–5
202	0–0
211	3–3
232	0–0
241	5–4
233	0–0
210	3–4
254	0–4
104	6–4
105	8–1
111	5–2
116	4–2
131	1–1
133	1–0
138	0–1
142	0–0
172	1–1
192	3–0
194	1–2
201	0–0
205	7–3
207	7–1
209	5–3
221	1–2
224	0–2
225	0–2
237	7–5
243	3–4–1
259	1–1
260	0–2
263	0–1
12	7–4
50	8–4
156	7–1
152	7–6
15	7–3
67	5–3
161	3–3
112	5–2
17	5–4
158	5–2 (1 NC)
13	6–5
150	9–4
182	7–0
177	13–5
45	8–5
159	5–2
2	11–3
155	7–2
18	3–6
3	9–5
27	1–3
7	10–2
55	8–0–1 (1 NC)
160	4–3
21	4–4
113	4–3
11	8–3
162	3–3
234	12–4
151	7–5 (1 NC)
235	8–5
184	4–2
56	8–1–1
119	3–3
148	13–5
149	11–1–1
\.


--
-- Data for Name: fighters; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY fighters (id, name, weightclass, source_id) FROM stdin;
30	Kyle Noke	5	5
347	Jorge Horvat	3	4
46	Yves Edwards	3	5
349	Hiroshi Nakamura	4	4
22	Rousimar Palhares	5	5
29	Jorge Santiago	5	5
32	Rafael Natal	5	5
44	Gleison Tibau	3	5
79	Rafaello Oliveira	3	5
82	Edson Barboza	3	5
10	Jason MacDonald	5	5
35	Nick Ring	5	5
53	Sam Stout	3	5
38	Constantinos Philippou	5	5
66	Paul Taylor	3	5
88	Paul Sass	3	5
76	Kamal Shalorus	3	5
9	Alessio Sakara	5	5
41	Riki Fukuda	5	5
39	Dongi Yang	5	5
20	C.B. Dollaway	5	5
118	Daniel Roberts	4	5
122	Duane Ludwig	4	5
128	Brian Ebersole	4	5
132	TJ Waldburger	4	5
134	Chris Cope	4	5
135	Clay Harvison	4	5
137	Justin Edwards	4	5
139	David Mitchell	4	5
143	Jorge Lopez	4	5
186	Matt Mitrione	7	5
191	Roy Nelson	7	5
193	Travis Browne	7	5
196	Ben Rothwell	7	5
198	Dave Herman	7	5
199	Aaron Rosa	7	5
204	Scott Jorgensen	1	5
208	Joseph Benavidez	1	5
213	Jeff Curran	1	5
214	Demetrious Johnson	1	5
216	Chris Cariaso	1	5
87	Tony Ferguson	3	5
90	T.J. O'Brien	3	5
238	Manny Gamburyan	2	5
245	Diego Nunes	2	5
240	Mark Hominick	2	5
257	Tiequan Zhang	2	5
197	Rob Broughton	7	5
258	Chan Sung Jung	2	5
107	Matt Brown	4	5
108	Rick Story	4	5
120	Jake Ellenberger	4	5
121	Brian Foster	4	5
123	Rich Attonito	4	5
124	Charlie Brenneman	4	5
187	Brendan Schaub	7	5
188	Joey Beltran	7	5
203	Urijah Faber	1	5
212	Damacio Page	1	5
72	Aaron Riley	3	5
89	Ramsey Nijem	3	5
200	Philip De Fries	7	5
73	Evan Dunham	3	5
220	Michael McDonald	1	5
222	Reuben Duran	1	5
226	Jeff Hougland	1	5
227	Cole Escovedo	1	5
229	Donny Walker	1	5
236	Leonard Garcia	2	5
247	Chad Mendes	2	5
250	Erik Koch	2	5
262	Alex Caceres	2	5
267	Jimy Hettes	2	5
206	Dominick Cruz	1	5
14	Mark Muñoz	5	5
16	Ed Herman	5	5
19	Aaron Simpson	5	5
163	Phil Davis	6	5
165	Kyle Kingsbury	6	5
84	Michael Johnson	3	5
223	Ian Loveland	1	5
228	Edwin Figueroa	1	5
231	Mike Easton	1	5
244	Ricardo Lamas	2	5
248	Josh Grispi	2	5
251	Mackens Semerzier	2	5
252	Matt Grice	2	5
253	Dustin Poirier	2	5
255	Darren Elkins	2	5
256	Pablo Garza	2	5
166	Eliot Marshall	6	5
60	Thiago Tavares	3	5
71	Rafael Dos Anjos	3	5
91	Vagner Rocha	3	5
64	Mark Bocek	3	5
74	TJ Grant	3	5
31	Brad Tavares	5	5
54	Jim Miller	3	5
23	Tim Boetsch	5	5
24	Nick Catone	5	5
25	Tim Credeur	5	5
26	Tom Lawlor	5	5
28	Mike Massenzio	5	5
33	Jared Hamman	5	5
34	Court McGee	5	5
36	Chris Weidman	5	5
37	Jason Miller	5	5
40	Paul Bradley	5	5
51	Jeremy Stephens	3	5
52	Matt Wiman	3	5
146	Erick Silva	4	5
175	Ronny Markes	6	5
176	Stanislav Nedkov	6	5
125	Rory MacDonald	4	5
129	Sean Pierson	4	5
140	Mark Scanlon	4	5
136	Pascal Krauss	4	5
171	Fabio Maldonado	6	5
144	Che Mills	4	5
173	James Te Huna	6	5
58	Shane Roller	3	5
65	Mac Danzig	3	5
202	Oli Thompson	7	5
211	Raphael Assunção	1	5
232	Johnny Eduardo	1	5
241	Rani Yahya	2	5
233	Vaughan Lee	1	5
210	Takeya Mizugaki	1	5
254	Michihiro Omigawa	2	5
104	Nick Diaz	4	5
105	Johny Hendricks	4	5
111	Matthew Riddle	4	5
116	Mike Pierce	4	5
131	Jake Shields	4	5
133	Shamar Bailey	4	5
138	James Head	4	5
142	Lance Benoist	4	5
172	Ricardo Romero	6	5
192	Mike Russow	7	5
194	Christian Morecraft	7	5
201	Stipe Miocic	7	5
205	Miguel Angel Torres	1	5
207	Brian Bowles	1	5
209	Eddie Wineland	1	5
221	Nick Pace	1	5
224	Jason Reinhardt	1	5
225	Ken Stone	1	5
237	Mike Brown	2	5
243	George Roop	2	5
259	Jonathan Brookins	2	5
260	Nam Phan	2	5
263	Mike Lullo	2	5
348	Sergei Vilanova	3	4
141	Papy Abedi	4	5
62	Danny Castillo	3	5
68	Ben Henderson	3	5
78	Charles Oliveira	3	5
83	John Makdessi	3	5
81	Takanori Gomi	3	5
59	Anthony Njokuani	3	5
42	Melvin Guillard	3	5
48	Donald Cerrone	3	5
169	Anthony Perosh	6	5
154	Vladimir Matyushenko	6	5
130	Carlos Eduardo Rocha	4	5
242	Cub Swanson	2	5
274	Caol Uno	3	3
286	Denis Kang	5	3
278	Chuck Liddell	6	3
269	Adam Gunn	4	3
270	Andrei Arlovski	7	3
283	Dan Henderson	5	3
126	James Wilks	4	3
94	Chris Lytle	4	3
127	Claude Patrick	4	5
167	Igor Pokrajac	6	5
174	Karlos Vemola	6	5
115	John Hathaway	4	5
170	Cyrille Diabate	6	5
164	Alexander Gustafsson	6	5
69	Nik Lentz	3	5
61	George Sotiropoulos	3	5
6	Royce Gracie	5	5
70	Anthony Pettis	3	5
157	Krzysztof Soszynski	6	3
179	Mirko Cro Cop	7	3
47	Spencer Fisher	3	3
63	Cole Miller	3	3
57	Joe Lauzon	3	3
75	Ross Pearson	3	3
302	Joe Stevenson	3	3
271	Andrei Radaza	6	3
110	Dong Hyun Kim	4	3
102	Martin Kampmann	4	3
180	Stefan Struve	7	3
168	Antonio Nogueira	7	3
178	Cheick Kongo	7	3
95	Georges St.-Pierre	4	3
181	Junior Dos Santos	7	3
49	Sean Sherk	3	3
99	Thiago Alves	4	3
43	Clay Guida	3	3
5	Anderson Silva	5	3
153	Lyoto Machida	6	3
272	Anthony Plascencia	7	3
273	Brian Evans	5	3
77	Jacob Volkmann	3	5
80	Dan Downes	3	5
85	Cody McKenzie	3	5
86	Edward Faaloloto	3	5
239	José Aldo	2	5
219	Renan Barão	1	5
261	Yuri Alcantara	2	5
265	Felipe Arantes	2	5
145	Luis Ramos	4	5
266	Antonio Carvalho	2	5
249	Javier Vazquez	2	5
217	Ivan Menjivar	1	5
215	Brad Pickett	1	5
264	Jason Young	2	5
218	Yves Jabouin	1	5
230	Norifumi Yamamoto	1	5
268	Hatsu Hioki	2	5
195	Mark Hunt	7	5
1	Chris Leben	5	3
190	Heath Herring	7	3
185	Pat Barry	7	3
106	Anthony Johnson	4	3
103	Carlos Condit	4	3
97	Diego Sanchez	3	3
101	Mike Swick	4	3
147	Tito Ortiz	6	3
100	Matt Serra	4	3
96	Josh Koscheck	4	3
246	Bart Palaszewski	2	5
4	Jorge Rivera	5	5
8	Brian Stann	5	5
109	Dennis Hallman	4	5
114	Mike Pyle	4	5
117	DaMarques Johnson	4	5
98	Jon Fitch	4	3
93	BJ Penn	3	3
189	Minotauro Nogueira	7	3
92	Matt Hughes	4	3
183	Shane Carwin	7	3
12	Alan Belcher	5	3
50	Dennis Siver	3	3
156	Jon Jones	6	3
152	Stephan Bonnar	6	3
15	Nate Quarry	5	3
67	Terry Etim	3	3
161	Jason Brilz	6	3
112	Amir Sadollah	4	3
17	Dan Miller	5	3
158	Thiago Silva	6	3
13	Chael Sonnen	5	3
150	Forrest Griffin	6	3
182	Cain Velasquez	7	3
177	Frank Mir	7	3
45	Nate Diaz	3	3
159	Ryan Bader	6	3
336	Randy Johnson	3	4
2	Michael Bisping	5	3
155	Quinton Jackson	6	3
18	Wanderlei Silva	5	3
3	Vitor Belfort	5	3
27	Yoshihiro Akiyama	5	3
7	Yushin Okami	5	3
55	Gray Maynard	3	3
160	Luiz Cane	6	3
21	Steve Cantwell	5	3
113	Dan Hardy	4	3
11	Demian Maia	5	3
162	Mauricio Rua	6	3
234	Kenny Florian	3	3
151	Brandon Vera	6	3
235	Tyson Griffin	3	3
184	Brock Lesnar	7	3
56	Frankie Edgar	3	3
119	Paulo Thiago	4	3
148	Rich Franklin	6	3
149	Rashad Evans	6	3
275	Carmelo Melendez	3	3
276	Cesar Perez Jr.	7	3
277	Chris Price	5	3
279	Cole Gotti	7	3
280	Cory Williams	3	3
281	Daisuke Hironaka	3	3
282	Damon Blaine	7	3
284	Dan Larson	5	3
285	David Moore	6	3
287	Derrick Mitchell	6	3
288	Drew Chambers	6	3
290	Dwayne Williams	4	3
291	Ed Duran	4	3
292	Ed Hamlin	6	3
293	Frank Hill	5	3
296	Garrison Brooks	4	3
297	George Goodridge	3	3
298	Jake Carter	5	3
299	James King	3	3
300	Jeff Clayton	5	3
301	Jessie James	3	3
303	Josh Freeman	5	3
305	Karl Thomas	6	3
307	Keith Gilmore	7	3
311	Kris Graham	7	3
312	Luiz Cardoza	6	3
313	Manny Dos Santos Jr.	3	3
314	Marcello Cruz	5	3
316	Marcus Ferreira	4	3
318	Matt Williams	6	3
319	Mike Barns	7	3
320	Mitsuhiro Yoshida	4	3
321	Murilo De Souza	4	3
323	Noah Brown	6	3
324	Pablo Casillas	5	3
326	Paulo Duarte	3	3
327	PJ Bradley	4	3
328	Rich Caldwell	7	3
329	Roberto Martinez	5	3
330	Ryo Matsui	7	3
331	Sam Boberg	3	3
332	Sato Matsui	6	3
334	Travis Rothwell	7	3
306	Karo Parisyan	4	3
317	Matt Hamill	6	3
333	Todd Duffee	7	3
295	Gabriel Gonzaga	7	3
322	Nate Marquardt	5	3
345	Antoni Hardonk	7	3
346	Fabricio Werdum	7	3
289	Drew McFedries	5	3
310	Kimbo Slice	7	3
308	Keith Jardine	6	3
294	Frank Trigg	4	3
304	Justin McCully	7	3
315	Marcus Davis	4	3
325	Patrick Cote	5	3
309	Kendall Grove	5	3
335	Wilson Gouveia	5	3
337	Eddie Sanchez	3	3
338	Efrain Escudero	7	3
339	Mostapha Al Turk	7	3
340	Kurt Pellegrino	3	3
341	Ricardo Almeida	5	3
342	Hermes Franca	3	3
343	Dustin Hazelett	4	3
344	Mark Coleman	7	3
\.


--
-- Data for Name: fightersource; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY fightersource (id, source) FROM stdin;
3	Game
4	Player
5	Real World
\.


--
-- Data for Name: move_move_requirements; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY move_move_requirements (move_id, req_move_id) FROM stdin;
159	182
159	274
161	182
161	274
163	182
163	274
158	182
158	274
162	182
162	274
157	182
157	274
160	182
160	274
32	166
33	166
34	172
35	172
36	172
37	172
1	33
1	168
256	33
256	168
258	33
258	168
6	37
6	174
259	37
259	174
260	37
260	174
265	238
266	238
263	238
264	238
262	238
268	287
271	287
269	287
270	287
267	287
\.


--
-- Data for Name: move_skill_requirements; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY move_skill_requirements (move_id, skill_id, level) FROM stdin;
207	13	60
287	13	60
157	15	70
232	15	60
237	15	60
26	15	60
262	15	70
263	15	60
9	15	60
16	15	60
22	15	60
24	15	60
304	15	60
\.


--
-- Data for Name: moves; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY moves (id, name, type, start_position_id, end_position_id) FROM stdin;
3	Pummel to Double Underhook Defense	Clinch Transition	2	21
207	Transition to Open Guard Down Top	Transition	29	39
158	Transition to Open Guard Down Bottom	Transition	16	38
159	Transition to Up/Down Bottom	Transition	16	58
161	Transition to Half Guard Down Top	Transition	17	25
162	Transition to Open Guard Top	Transition	17	41
205	Cage Transition to Mount Down Top	Transition	29	30
272	Cage Transition to Side Control Top	Transition	48	50
124	Right Karate Front Kick	Kick	15	15
130	Right MMA Back Spin Kick	Kick	15	15
131	Right Muay Thai Head Kick	Kick	15	15
132	Right Muay Thai Leg Kick	Kick	15	15
163	Transition to Side Control Top	Transition	17	50
4	Transition to Both Standing	Transition	2	15
160	Triangle Choke from Butterfly Guard	Submission	16	16
264	Triangle Choke from Rubber Guard Bottom	Submission	44	44
184	Transition to Up/Down Bottom	Transition	24	58
187	Transition to Mount Down Top	Transition	25	30
190	D'arce Choke	Submission	26	26
208	Arm Triangle Choke from Mount Top	Submission	30	30
212	Arm Triangle Choke from Mount Top	Submission	32	32
228	North/South Choke from North/South Top	Submission	36	36
233	Strike Catch to Triangle Choke	Submission	37	37
240	Triangle Choke	Submission	38	38
243	Achilles Lock	Submission	40	40
231	Strike Catch to Kimura	Submission	37	37
236	Kimura	Submission	38	38
188	Transition to Side Control Top	Transition	25	50
200	Transition to Mount Down Top	Transition	27	30
133	Right Muay Thai Push Kick	Kick	15	15
134	Right Muay Thai Snap Kick	Kick	15	15
138	Right Spinning Back Kick	Kick	15	15
150	Strong Left Leg Kick	Kick	15	15
151	Strong Right Leg Kick	Kick	15	15
152	Switch Left Head Kick	Kick	15	15
155	Two Step Right Middle Kick	Kick	15	15
41	Left Muay Thai Elbow	Strike	14	14
43	Right Chopping Hook	Strike	14	14
58	Ducking Right Hook	Strike	15	15
47	Right Short Uppercut from Sway Forward	Strike	14	14
50	Backstep Right Hook from Switch Stance	Strike	15	15
46	Right Muay Thai Elbow	Strike	14	14
57	Ducking Left Hook	Strike	15	15
70	Left Guarded Hook	Strike	15	15
73	Left Hook from Sway Back	Strike	15	15
74	Left Hook from Sway Forward	Strike	15	15
76	Left Hook from Sway Right	Strike	15	15
83	Left Over Hook	Strike	15	15
84	Left Over Strong Hook	Strike	15	15
89	Left Sidestepping Upper Jab	Strike	15	15
92	Left Strong Uppercut	Strike	15	15
201	Transition to Mount Top	Transition	27	32
202	Transition to Side Control Top	Transition	27	50
203	Transition to Half Guard Bottom	Transition	28	23
204	Transition to Mount Down Bottom	Transition	28	29
206	Transition to Half Guard Down Bottom	Transition	29	24
229	Transition to Mount Down Top	Transition	36	30
234	Transition to Open Guard Down Bottom	Transition	37	38
235	Transition to Up/Down Bottom	Transition	37	58
238	Transition to Rubber Guard Down Bottom	Transition	38	44
239	Transition to Up/Down Bottom	Transition	38	58
241	Transition to Half Guard Down Top	Transition	39	25
242	Transition to Side Control Top	Transition	39	50
253	Transition to Half Guard Down Top	Transition	41	25
254	Transition to Half Guard Top	Transition	41	27
255	Transition to Side Control Top	Transition	41	50
273	Transition to Both Standing	Transition	48	15
274	Transition to Butterfly Guard Bottom	Transition	48	16
275	Transition to Half Guard Down Bottom	Transition	48	24
93	Left Undercut	Strike	15	15
164	Slam to Open Guard Down Offense	Takedown	18	39
7	Pull to Side Control	Takedown	3	50
5	Back Throw to Side Control Right Offense	Takedown	3	50
144	Shoot to Double Leg Takedown	Takedown	15	39
71	Left Head Kick	Kick	15	15
72	Left High Front Kick	Kick	15	15
114	Right Flying Knee	Kick	15	15
145	Step Right Knee	Kick	15	15
153	Two Step Left Flying Knee	Kick	15	15
154	Two Step Right Flying Knee	Kick	15	15
62	Hendo's Right Back Fist	Strike	15	15
64	Jardine's Right Superman Punch	Strike	15	15
65	Jon Jones' Right Back Fist	Strike	15	15
77	Left Jab to Sway Back	Strike	15	15
99	Lyoto's Right Straight	Strike	15	15
100	Lyoto's Stepping Straight	Strike	15	15
104	Overhand Right	Strike	15	15
105	Overhand Right from Sway Forward	Strike	15	15
106	Overhand Right Hook from Sway Forward	Strike	15	15
112	Right Ducking Uppercut to Head	Strike	15	15
116	Right Guarded Hook	Strike	15	15
120	Right Hook from Sway Back	Strike	15	15
121	Right Hook from Sway Left	Strike	15	15
59	Forrest's Left Front Kick	Kick	15	15
60	Forrest's Left Head Kick	Kick	15	15
247	Achilles Lock from Open Guard Top	Submission	41	41
250	Kneebar from Open Guard Top	Submission	41	41
10	Armbar from Back Mount Face Up Top	Submission	5	5
17	Armbar from Back Mount Top	Submission	7	7
25	Armbar from Back Side Control Top	Submission	10	10
11	Rear Naked Choke	Submission	5	5
15	Rear Naked Choke from Back Mount Rocked	Submission	6	6
18	Rear Naked Choke Facing Downward	Submission	7	7
23	Rear Naked Choke	Submission	9	9
27	Rear Naked Choke	Submission	10	10
175	Strike Catch to Armbar	Submission	23	23
211	Armbar from Mount Rocked Top	Submission	31	31
213	Armbar from Mount Top	Submission	32	32
227	Armbar from North/South Top	Submission	36	36
230	Strike Catch to Armbar	Submission	37	37
278	Armbar from Side Control Rocked Top	Submission	49	49
38	Inside Left Uppercut	Strike	14	14
39	Inside Right Uppercut	Strike	14	14
51	Backstepping Right Straight	Strike	15	15
52	Brock's Right Straight	Strike	15	15
56	Chuck's Right Straight	Strike	15	15
63	Hendo's Right Strong Straight	Strike	15	15
69	Left Flicking Jab	Strike	15	15
246	Toe Hold	Submission	40	40
21	Transition to Open Guard Bottom	Transition	8	38
30	Transition to Back Mount Face Up Top	Transition	10	5
31	Transition to Back Mount Top	Transition	10	7
177	Transition to Half Guard Down Bottom	Transition	23	24
178	Transition to Open Guard Bottom	Transition	23	37
179	Transition to Up/Down Bottom	Transition	23	58
182	Transition to Butterfly Guard Bottom	Transition	24	16
183	Transition to Open Guard Down Bottom	Transition	24	38
219	Pummel to Over/Under Hook	Clinch Transition	34	43
257	Pummel to Double Underhook Cage Offense	Clinch Transition	42	20
261	Pummel to Double Underhook Offense	Clinch Transition	43	22
180	Cage Transition to Half Guard Down Bottom	Transition	24	24
40	Left Leg Kick	Kick	14	14
44	Right Dodge Knee to the Body	Kick	14	14
45	Right Leg Kick	Kick	14	14
48	Strong Left Leg Kick	Kick	14	14
49	Strong Right Leg Kick	Kick	14	14
53	Caol's Back Spin Kick	Kick	15	15
54	Caol's Left Side Kick	Kick	15	15
55	Check Head Kick	Kick	15	15
61	GSP's Head Kick	Kick	15	15
66	Left Axe Kick	Kick	15	15
68	Left Front Upward Kick	Kick	15	15
101	Napao's Right Head Kick	Kick	15	15
102	One Feint Head Kick	Kick	15	15
107	Quick Head Kick	Kick	15	15
108	Right Axe Kick	Kick	15	15
110	Right Back Kick	Kick	15	15
111	Right Brazilian Head Kick	Kick	15	15
113	Right Flying Head Kick	Kick	15	15
216	Rear Leg Knee	Clinch Strike	33	33
217	Strong Knee	Clinch Strike	33	33
220	Arcing Elbow	Clinch Strike	35	35
221	Knee	Clinch Strike	35	35
222	Knee to Body	Clinch Strike	35	35
224	Rear Leg Knee	Clinch Strike	35	35
225	Strong Knee	Clinch Strike	35	35
226	Uppercut	Clinch Strike	35	35
304	Peruvian Neck Tie from Sprawl Top	Submission	56	56
280	Arm Triangle Choke	Submission	50	50
301	Guillotine Choke from Sprawl Rocked	Submission	55	55
302	Anaconda Choke from Sprawl Top	Submission	56	56
303	Guillotine Choke from Sprawl Top	Submission	56	56
311	Achilles Lock from Up/Down Near Top	Submission	59	59
309	Kneebar from Up/Down Near Bottom	Submission	58	58
313	Kneebar from Up/Down Near Top	Submission	59	59
317	Toe Hold from Up/Down Near Top	Submission	59	59
282	Kimura from Side Control Top	Submission	50	50
287	Transition to Salaverry Top	Transition	50	47
285	Transition to Mount Down Top	Transition	50	30
286	Transition to Mount Top	Transition	50	32
299	Transition to Both Standing	Transition	54	15
300	Transition to Open Guard Down Bottom	Transition	54	38
306	Transition to Back Mount Top	Transition	56	7
33	Suplex to Side Control Offense	Takedown	11	50
36	Suplex to Half Guard Down Offense	Takedown	13	25
37	Suplex to Side Control Offense	Takedown	13	50
34	Judo Hip Throw to Side Control Offense	Takedown	12	50
32	Pull Guard to Open Guard Down Defense	Takedown	11	38
35	Pull Guard to Open Guard Down Defense	Takedown	13	38
297	Slam to Open Guard Down Offense	Takedown	53	39
298	Slam to Side Control Offense	Takedown	53	50
294	Pull Guard to Open Guard Down Defense	Takedown	52	38
312	Heel Hook from Up/Down Near Top	Submission	59	59
281	Elbow	Ground Strike	50	50
283	Strong Left Knee to Abdomen	Ground Strike	50	50
284	Strong Right Knee to Abdomen	Ground Strike	50	50
305	Strong Hook	Ground Strike	56	56
95	Left Uppercut	Strike	15	15
94	Left Upper Jab	Strike	15	15
96	Lunging Left Hook	Strike	15	15
97	Lunging Right Hook	Strike	15	15
103	Overhand Left from Sway Forward	Strike	15	15
232	Strike Catch to Omoplata	Submission	37	37
237	Omoplata	Submission	38	38
157	Gogoplata from Butterfly Guard	Submission	16	16
245	Kneebar	Submission	40	40
265	Transition to Half Guard Down Top	Transition	45	25
266	Transition to Open Guard Top	Transition	45	41
268	Transition to Both Standing	Transition	46	15
271	Transition to Mount Top	Transition	47	32
1	German Suplex to Back Side Control Offense	Takedown	1	10
6	German Suplex to Back Side Control Offense	Takedown	3	10
2	Lift Up Slam to Side Control Offense	Takedown	1	50
122	Right Hook From Sway Right	Strike	15	15
125	Right Karate Straight	Strike	15	15
126	Right Long Straight	Strike	15	15
128	Right Long Uppercut	Strike	15	15
129	Right Over Hook	Strike	15	15
136	Right Spinning Back Elbow	Strike	15	15
139	Right Strong Straight	Strike	15	15
140	Right Strong Uppercut	Strike	15	15
142	Right Uppercut	Strike	15	15
143	Shogun's Stepping Left Hook	Strike	15	15
146	Stepping Heavy Jab	Strike	15	15
147	Stepping Over Left Hook	Strike	15	15
148	Stepping Right Undercut	Strike	15	15
149	Stepping Right Uppercut	Strike	15	15
156	Weaving Overhand Right	Strike	15	15
26	Peruvian Neck Tie	Submission	10	10
9	Arm Trap Rear Naked Choke	Submission	5	5
16	Arm Trap Rear Naked Choke	Submission	7	7
22	Arm Trap Rear Naked Choke	Submission	9	9
24	Arm Trap Rear Naked Choke	Submission	10	10
262	Gogoplata from Rubber Guard Bottom	Submission	44	44
263	Omoplata from Rubber Guard Bottom	Submission	44	44
269	Americana from Side Control Top	Submission	47	47
267	Armbar from Salaverry Top	Submission	46	46
258	Takedown to Half Guard Down Offense	Takedown	42	25
259	Hip Throw to Side Control Offense	Takedown	43	50
260	Pull Guard to Open Guard Down Defense	Takedown	43	38
256	Ouchi Gari to Open Guard Down Offense	Takedown	42	39
78	Left Jumping Front Kick	Kick	15	15
80	Left Muay Thai Head Kick	Kick	15	15
81	Left Muay Thai Leg Kick	Kick	15	15
82	Left Muay Thai Push Kick	Kick	15	15
87	Left Side Kick	Kick	15	15
88	Left Side Kick to Body	Kick	15	15
91	Left Spinning Back Kick	Kick	15	15
98	Lyoto's Left Head Kick	Kick	15	15
42	Left Short Uppercut From Sway Forward	Strike	14	14
67	Left Back Fist	Strike	15	15
90	Left Spinning Back Fist	Strike	15	15
109	Right Back Fist	Strike	15	15
137	Right Spinning Back Fist	Strike	15	15
75	Left Hook from Sway Left	Strike	15	15
79	Left Long Superman Punch	Strike	15	15
85	Left Punch from Kick Catch	Strike	15	15
86	Left Quick Superman Punch	Strike	15	15
127	Right Long Superman Punch	Strike	15	15
135	Right Punch from Kick Catch	Strike	15	15
277	Americana from Side Control Top	Submission	49	49
279	Americana from Side Control Top	Submission	50	50
252	Toe Hold from Open Guard Top	Submission	41	41
276	Transition to Open Guard Down Bottom	Transition	48	38
8	Transition to Both Standing	Transition	4	15
13	Transition to Back Mount Face Up Body Triangle Top	Transition	5	5
14	Transition to Mount Top	Transition	5	32
20	Transition to Both Standing	Transition	8	15
115	Right Front Upper Kick	Kick	15	15
117	Right Head Kick	Kick	15	15
118	Right High Front Kick	Kick	15	15
119	Right High Kick	Kick	15	15
123	Right Karate Back Spin Kick	Kick	15	15
141	Right Superman Punch	Strike	15	15
244	Heel Hook	Submission	40	40
249	Heel Hook from Open Guard Top	Submission	41	41
19	Strong Hook	Ground Strike	7	7
28	Strong Hook	Ground Strike	10	10
29	Strong Knee to Abdomen	Ground Strike	10	10
12	Strong Right Hook	Ground Strike	5	5
251	Strong Hook	Ground Strike	41	41
198	Strong Hook	Ground Strike	27	27
215	Strong Hook	Ground Strike	32	32
196	Kneebar from Half Guard Top	Submission	27	27
185	Americana from Half Guard Top	Submission	25	25
189	Americana from Half Guard Rocked Top	Submission	26	26
192	Americana from Half Guard Top	Submission	27	27
199	Toe Hold from Half Guard Top	Submission	27	27
176	Strike Catch to Kimura	Submission	23	23
181	Kimura	Submission	24	24
186	Kimura from Half Guard Top	Submission	25	25
191	Kimura from Half Guard Top	Submission	26	26
195	Kimura from Half Guard Top	Submission	27	27
170	Pummel to Double Underhook Offense	Clinch Transition	21	22
171	Pummel to Single Collar Tie	Clinch Transition	21	52
218	Pummel to Muay Thai Clinch Offense	Clinch Transition	34	35
166	Clinch to Body Lock Cage Offense	Clinch Transition	20	11
172	Clinch to Body Lock Offense	Clinch Transition	22	13
165	Left Turn Off to Double Underhook Defense	Clinch Transition	19	21
168	Suplex to Side Control Offense	Takedown	20	50
174	Suplex to Side Control Offense	Takedown	22	50
169	Judo Hip Throw to Side Control Offense	Takedown	21	50
167	Pull Guard to Open Guard Down Defense	Takedown	20	38
173	Pull Guard to Open Guard Down Defense	Takedown	22	38
223	Pull Guard to Open Guard Down Defense	Takedown	35	38
248	Elbow	Ground Strike	41	41
270	Elbow	Ground Strike	47	47
193	Elbow	Ground Strike	27	27
194	Hammer Fist	Ground Strike	27	27
209	Ground Buster from Mount Down Top	Ground Strike	30	30
214	Elbow	Ground Strike	32	32
307	Left Superman Punch	Ground Strike	57	57
308	Right Superman Punch	Ground Strike	57	57
314	Left Axe Kick to Body	Ground Strike	59	59
315	Left Superman Punch	Ground Strike	59	59
316	Right Superman Punch	Ground Strike	59	59
310	Up-Kick	Ground Strike	58	58
289	Downward Arcing Elbow	Clinch Strike	51	51
290	Strong Hook	Clinch Strike	51	51
291	Strong Knee to Abdomen	Clinch Strike	51	51
293	Uppercut to Body	Clinch Strike	51	51
295	Strong Hook	Clinch Strike	52	52
296	Uppercut	Clinch Strike	52	52
288	Crushing Knee	Clinch Strike	51	51
292	Strong Uppercut	Clinch Strike	51	51
\.


--
-- Data for Name: moves_camps; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY moves_camps (move_id, camp_id) FROM stdin;
1	9
1	10
1	18
1	21
1	24
2	9
2	10
2	21
3	4
3	9
3	11
4	4
4	9
4	11
5	10
5	18
5	21
6	9
6	10
6	11
6	18
6	21
6	24
7	1
7	11
7	13
7	15
7	18
7	19
7	21
8	3
8	6
8	7
8	13
9	19
10	1
10	3
10	8
11	6
11	14
12	5
12	26
13	8
13	13
13	15
13	27
14	1
14	19
15	3
15	6
15	9
15	14
16	19
17	1
17	13
17	16
17	23
18	3
18	6
18	9
18	14
19	2
19	7
19	11
20	3
20	6
20	13
20	16
21	25
21	27
22	19
23	6
23	14
23	24
25	1
25	13
25	16
25	23
26	1
26	6
26	8
27	6
27	14
27	24
28	3
28	21
28	22
29	10
30	1
30	19
31	1
31	19
32	1
32	9
32	11
32	13
32	15
32	19
33	10
33	18
33	21
33	24
34	9
34	10
34	11
34	21
35	1
35	9
35	11
35	13
35	15
35	18
35	19
36	10
36	18
36	21
36	24
37	10
37	18
37	21
37	24
38	10
38	19
38	20
39	10
39	19
39	20
39	25
39	26
40	5
40	9
40	10
40	12
40	22
40	25
41	2
41	5
41	7
41	14
41	17
41	27
42	3
42	12
42	25
42	26
43	21
44	2
44	5
44	14
44	17
44	23
44	27
45	5
45	9
45	10
45	12
45	22
45	25
46	2
46	5
46	7
46	14
46	17
46	27
47	3
47	12
47	25
47	26
48	5
49	5
50	4
51	26
52	11
53	16
54	16
55	10
56	25
57	4
57	3
57	5
57	7
57	14
57	17
57	20
58	4
58	3
58	5
58	7
58	14
58	17
58	20
59	9
60	9
61	10
61	27
62	21
63	21
64	10
65	10
66	4
66	12
66	16
66	22
67	3
67	9
67	26
68	15
69	3
69	10
69	19
70	9
70	20
70	26
71	12
71	25
71	26
72	15
73	4
73	6
73	12
73	22
73	24
73	25
74	12
75	4
75	6
75	12
75	22
75	24
75	25
76	4
76	6
76	12
76	22
76	24
76	25
77	19
78	10
79	4
79	7
79	25
80	2
80	5
80	14
80	17
80	22
80	23
80	27
81	2
81	5
81	14
81	17
81	22
81	23
81	27
82	2
82	5
82	7
82	14
82	19
82	27
83	4
83	21
83	23
84	21
85	15
85	23
85	25
86	10
86	22
86	25
86	27
87	12
88	12
88	26
89	11
90	3
90	26
91	4
92	6
92	23
92	26
93	9
94	4
94	6
94	12
94	25
95	6
95	23
95	25
95	26
96	6
96	23
96	26
97	6
97	23
97	26
98	15
99	15
100	15
101	17
102	15
103	4
103	18
103	20
103	22
103	24
103	25
104	25
105	4
105	18
105	20
105	22
105	24
105	25
106	12
107	12
107	25
107	26
108	4
108	12
108	16
108	22
109	3
109	9
109	26
110	4
111	7
112	14
113	5
113	7
114	5
115	15
116	9
116	20
116	26
117	12
117	25
117	26
118	15
119	20
120	4
120	6
120	12
120	20
120	22
120	24
121	4
121	6
121	12
121	20
121	22
121	24
122	4
122	6
122	12
122	20
122	22
122	24
123	10
123	27
124	15
125	15
126	9
127	4
127	7
127	25
128	23
129	4
129	21
129	23
130	10
130	27
131	2
131	5
131	14
131	17
131	22
131	23
131	27
132	2
132	5
132	14
132	17
132	22
132	23
132	27
133	2
133	5
133	7
133	14
133	19
133	27
134	2
134	5
134	14
134	17
134	22
134	23
134	27
135	15
135	23
135	25
136	10
137	3
137	26
138	4
139	3
139	6
139	12
139	23
139	25
139	26
140	9
141	10
141	12
141	20
141	26
142	3
142	6
142	12
142	23
142	26
143	7
143	15
144	4
144	10
144	11
144	20
144	24
145	15
146	3
146	6
146	12
146	23
146	26
147	23
148	3
149	25
150	5
151	5
152	2
152	5
152	10
152	14
152	17
152	23
152	27
153	5
154	15
155	4
156	11
157	1
157	8
157	13
157	16
157	19
158	1
158	8
158	13
158	16
158	19
159	1
159	8
159	13
159	16
159	19
160	1
160	8
160	13
160	16
160	19
161	1
161	8
161	13
161	16
161	19
162	1
162	8
162	13
162	16
162	19
163	1
163	8
163	13
163	16
163	19
164	9
164	10
164	11
164	18
164	20
164	22
164	24
165	9
165	11
165	18
165	21
165	24
166	4
166	6
166	9
166	11
166	18
167	8
167	13
167	16
167	19
168	9
168	11
168	18
168	21
168	24
169	9
169	11
169	18
169	21
169	24
169	25
170	9
170	11
170	18
170	21
170	24
171	9
171	11
172	4
172	6
172	9
172	11
172	18
173	8
173	13
173	16
173	19
174	9
174	11
174	16
174	18
174	21
174	24
175	8
176	18
176	21
176	23
177	3
177	7
178	20
179	12
180	1
180	8
180	13
180	19
181	18
181	21
181	23
182	1
182	8
182	13
182	16
182	19
183	7
184	8
185	5
185	7
185	17
186	5
186	17
186	21
187	3
187	6
187	7
187	22
187	23
188	3
188	6
188	7
188	22
188	23
189	17
190	1
190	5
190	7
190	9
190	19
191	5
191	17
191	21
192	5
192	7
192	17
193	7
193	11
193	15
193	20
193	24
194	12
194	20
195	5
195	17
195	21
196	2
198	11
199	16
199	17
199	18
200	3
200	6
200	7
200	22
200	23
201	1
201	8
201	13
201	16
201	19
202	3
202	6
202	7
202	22
202	23
203	1
203	6
203	8
203	13
203	16
203	19
203	22
204	8
204	13
204	23
204	25
205	1
205	8
205	13
205	19
206	8
206	16
206	20
206	23
206	27
207	7
207	27
208	1
208	8
208	13
208	23
209	1
209	8
209	13
209	16
209	19
211	3
211	6
211	10
211	12
211	18
212	1
212	8
212	13
212	23
213	3
213	6
213	10
213	12
213	16
213	18
214	7
214	11
214	15
214	20
214	24
215	14
215	20
215	27
216	2
216	4
216	14
216	15
216	17
216	26
216	27
217	2
217	14
217	15
217	26
217	27
218	2
218	14
218	15
218	17
218	26
218	27
219	9
219	11
220	2
220	12
220	15
221	2
221	4
221	14
221	15
221	17
221	26
221	27
222	2
222	4
222	14
222	15
222	17
222	26
222	27
223	1
223	8
223	13
223	16
223	19
224	2
224	4
224	14
224	15
224	17
224	26
224	27
225	2
225	14
225	15
225	26
225	27
226	14
226	17
226	22
227	7
227	13
227	17
227	20
228	1
228	8
228	18
229	11
229	24
230	16
230	27
231	2
231	3
231	18
231	21
232	1
232	8
232	13
232	16
232	19
233	6
233	19
234	1
234	8
234	13
234	16
234	19
235	4
235	25
236	2
236	3
236	18
236	21
237	1
237	8
237	13
237	16
237	19
238	1
238	8
238	13
238	16
238	19
239	11
239	14
239	25
240	6
240	19
240	20
240	23
241	3
241	6
241	7
241	22
241	23
242	6
242	22
243	3
243	5
243	13
243	17
243	18
244	5
244	7
244	8
244	12
244	27
245	5
245	7
246	5
246	7
246	16
246	18
247	3
247	5
247	13
247	17
247	18
248	7
248	11
248	15
248	20
248	24
249	5
249	7
249	8
249	12
249	27
250	5
250	7
251	12
251	20
252	5
252	7
252	16
252	18
253	3
253	6
253	7
253	22
253	23
254	3
254	6
254	7
254	22
254	23
255	7
255	8
255	10
255	17
256	9
256	11
256	18
256	21
256	24
257	9
257	11
257	18
257	21
257	24
258	9
258	11
258	18
258	21
258	24
259	9
259	11
259	18
259	21
259	24
260	1
260	8
260	13
260	16
260	19
261	9
261	11
261	18
261	21
261	24
262	1
262	8
262	13
262	16
262	19
263	1
263	8
263	13
263	16
263	19
264	1
264	8
264	13
264	16
264	19
265	1
265	8
265	13
265	16
265	19
266	1
266	8
266	13
266	16
266	19
267	3
267	11
267	21
267	24
268	1
268	4
268	3
268	5
268	7
268	24
269	3
269	11
269	21
269	24
270	9
270	11
270	18
270	20
270	21
270	24
271	24
272	1
272	8
272	13
272	19
273	21
273	23
273	25
274	1
274	8
274	16
274	19
275	13
276	21
277	2
277	6
277	17
278	5
278	6
278	21
279	2
279	6
279	17
280	1
280	8
280	13
280	17
280	23
281	10
281	11
281	20
281	21
281	24
282	5
282	6
282	21
283	10
284	10
285	3
285	6
285	7
285	13
285	22
285	23
286	3
286	6
286	7
286	22
286	23
287	6
287	10
287	24
288	15
288	26
289	2
289	15
289	16
289	17
289	22
290	20
290	26
291	2
291	14
291	15
291	26
291	27
292	12
292	14
292	20
292	25
292	26
293	26
294	1
294	13
294	15
294	18
294	19
294	20
294	22
295	20
295	26
296	26
297	9
297	10
297	18
297	20
298	10
298	20
298	22
299	12
299	23
299	25
300	12
300	25
301	2
301	4
301	3
301	7
301	10
302	3
302	5
302	9
302	12
302	17
303	2
303	4
303	3
303	7
303	10
304	1
304	6
304	8
305	5
305	26
306	11
306	24
307	9
307	10
307	14
307	20
307	25
307	27
308	9
308	10
308	14
308	20
308	25
308	27
309	1
309	2
309	3
309	13
309	17
309	18
310	16
310	23
310	25
311	2
311	3
311	17
311	18
312	1
312	5
312	7
312	8
312	12
312	27
313	5
313	7
314	2
314	5
314	7
314	23
315	4
315	3
315	5
315	6
315	12
316	4
316	3
316	5
316	6
316	12
317	13
317	16
317	17
317	18
207	1
24	19
\.


--
-- Data for Name: positions; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY positions (id, name) FROM stdin;
1	Back Clinch Cage Offense
2	Back Clinch Defense
3	Back Clinch Offense
4	Back Mount Bottom
5	Back Mount Face Up Top
6	Back Mount Rocked Top
7	Back Mount Top
8	Back Side Control Bottom
9	Back Side Control Rocked Top
10	Back Side Control Top
11	Body Lock Cage Offense
12	Body Lock Defense
13	Body Lock Offense
14	Both Standing Clinch Range
15	Both Standing Striking Range
16	Butterfly Guard Bottom
17	Butterfly Guard Top
18	Double Leg Clinch Cage Offense
19	Double Underhook Cage Defense
20	Double Underhook Cage Offense
21	Double Underhook Defense
22	Double Underhook Offense
23	Half Guard Bottom
24	Half Guard Down Bottom
25	Half Guard Down Top
26	Half Guard Rocked Top
27	Half Guard Top
28	Mount Bottom
29	Mount Down Bottom
30	Mount Down Top
31	Mount Rocked Top
32	Mount Top
33	Muay Thai Clinch Cage Offense
34	Muay Thai Clinch Defense
35	Muay Thai Clinch Offense
36	North/South Top
37	Open Guard Bottom
38	Open Guard Down Bottom
39	Open Guard Down Top
40	Open Guard Rocked Top
41	Open Guard Top
42	Over/Under Hook Cage Offense
43	Over/Under Hook Offense
44	Rubber Guard Bottom
45	Rubber Guard Top
46	Sallaverry Bottom
47	Sallaverry Top
48	Side Control Bottom
49	Side Control Rocked Top
50	Side Control Top
51	Single Collar Tie Cage Offense
52	Single Collar Tie Offense
53	Single Leg Clinch Cage Offense
54	Sprawl Bottom
55	Sprawl Rocked Top
56	Sprawl Top
57	Up/Down Far Top
58	Up/Down Near Bottom
59	Up/Down Near Top
\.


--
-- Data for Name: skillfocii; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY skillfocii (skill_id, focus) FROM stdin;
1	Standup
2	Standup
3	Standup
4	Standup
11	Takedown
12	Takedown
13	Grappling/Submission
14	Grappling/Submission
15	Grappling/Submission
16	Grappling/Submission
5	Clinch
6	Clinch
9	Clinch
10	Clinch
7	Ground and Pound
8	Ground and Pound
13	Ground and Pound
14	Ground and Pound
\.


--
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY skills (id, name) FROM stdin;
5	Clinch Striking Offense
6	Clinch Striking Defense
7	Ground Striking Offense
8	Ground Striking Defense
9	Clinch Grapple Offense
10	Clinch Grapple Defense
1	Standing Strikes Offense
2	Standing Strikes Defense
3	Standing Kicks Offense
4	Standing Kicks Defense
11	Takedown Offense
12	Takedown Defense
13	Ground Grapple Offense
14	Ground Grapple Defense
15	Submission Offense
16	Submission Defense
\.


--
-- Data for Name: weightclass; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY weightclass (id, name, lbs) FROM stdin;
1	Bantamweight	135
2	Featherweight	145
3	Lightweight	155
4	Welterweight	170
5	Middleweight	185
6	Light Heavyweight	205
7	Heavyweight	265
\.


--
-- Name: abbr_unique; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY buttons
    ADD CONSTRAINT abbr_unique UNIQUE (abbr);


--
-- Name: buttons_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY buttons
    ADD CONSTRAINT buttons_pkey PRIMARY KEY (id);


--
-- Name: camps_name_key; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY camps
    ADD CONSTRAINT camps_name_key UNIQUE (name);


--
-- Name: camps_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY camps
    ADD CONSTRAINT camps_pkey PRIMARY KEY (id);


--
-- Name: combo_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY combo
    ADD CONSTRAINT combo_pkey PRIMARY KEY (move_id, button_id, seq);


--
-- Name: country_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_pkey PRIMARY KEY (id);


--
-- Name: fighter_camps_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY fighter_camps
    ADD CONSTRAINT fighter_camps_pkey PRIMARY KEY (fighter_id, camp_id);


--
-- Name: fighter_moves_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY fighter_moves
    ADD CONSTRAINT fighter_moves_pkey PRIMARY KEY (fighter_id, move_id);


--
-- Name: fightercontract_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY fightercontract
    ADD CONSTRAINT fightercontract_pkey PRIMARY KEY (id);


--
-- Name: fightercountry_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY fightercountry
    ADD CONSTRAINT fightercountry_pkey PRIMARY KEY (id);


--
-- Name: fighternickname_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY fighternickname
    ADD CONSTRAINT fighternickname_pkey PRIMARY KEY (id);


--
-- Name: fighterrating_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY fighterrating
    ADD CONSTRAINT fighterrating_pkey PRIMARY KEY (id);


--
-- Name: fighterrecords_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY fighterrecords
    ADD CONSTRAINT fighterrecords_pkey PRIMARY KEY (id);


--
-- Name: fighters_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY fighters
    ADD CONSTRAINT fighters_pkey PRIMARY KEY (id);


--
-- Name: fightersource_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY fightersource
    ADD CONSTRAINT fightersource_pkey PRIMARY KEY (id);


--
-- Name: move_move_requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY move_move_requirements
    ADD CONSTRAINT move_move_requirements_pkey PRIMARY KEY (move_id, req_move_id);


--
-- Name: moves_camps_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY moves_camps
    ADD CONSTRAINT moves_camps_pkey PRIMARY KEY (move_id, camp_id);


--
-- Name: moves_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY moves
    ADD CONSTRAINT moves_pkey PRIMARY KEY (id);


--
-- Name: name_unique; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY country
    ADD CONSTRAINT name_unique UNIQUE (name);


--
-- Name: positions_name_key; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT positions_name_key UNIQUE (name);


--
-- Name: positions_name_unique; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT positions_name_unique UNIQUE (name);


--
-- Name: positions_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (id);


--
-- Name: skillfocii_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY skillfocii
    ADD CONSTRAINT skillfocii_pkey PRIMARY KEY (skill_id, focus);


--
-- Name: skills_name_unique; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY skills
    ADD CONSTRAINT skills_name_unique UNIQUE (name);


--
-- Name: skills_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- Name: source_unique; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY fightersource
    ADD CONSTRAINT source_unique UNIQUE (source);


--
-- Name: unique_name; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY fighters
    ADD CONSTRAINT unique_name UNIQUE (name);


--
-- Name: weight_unique; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY weightclass
    ADD CONSTRAINT weight_unique UNIQUE (name, lbs);


--
-- Name: weightclass_name_key; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY weightclass
    ADD CONSTRAINT weightclass_name_key UNIQUE (name);


--
-- Name: weightclass_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY weightclass
    ADD CONSTRAINT weightclass_pkey PRIMARY KEY (id);


--
-- Name: v_combos_aggregate_delete; Type: RULE; Schema: public; Owner: jean
--

CREATE RULE v_combos_aggregate_delete AS ON DELETE TO v_combos_aggregate DO INSTEAD DELETE FROM combo WHERE ((combo.move_id = old.move_id) AND (combo.variant IN (SELECT v_combos.variant FROM v_combos WHERE ((v_combos.move_id = old.move_id) AND ((v_combos.abbr)::text IN (SELECT regexp_split_to_table.regexp_split_to_table FROM regexp_split_to_table((old.abbr)::text, '[[:space:]]*,[[:space:]]*'::text) regexp_split_to_table(regexp_split_to_table)))))));


--
-- Name: v_combos_aggregate_insert; Type: RULE; Schema: public; Owner: jean
--

CREATE RULE v_combos_aggregate_insert AS ON INSERT TO v_combos_aggregate DO INSTEAD SELECT f_v_combos_aggregate_insert(new.move_id, (new.abbr)::text) AS f_v_combos_aggregate_insert;


--
-- Name: v_combos_aggregate_update; Type: RULE; Schema: public; Owner: jean
--

CREATE RULE v_combos_aggregate_update AS ON UPDATE TO v_combos_aggregate DO INSTEAD (DELETE FROM v_combos_aggregate WHERE ((v_combos_aggregate.move_id = old.move_id) AND ((v_combos_aggregate.abbr)::text = (old.abbr)::text)); INSERT INTO v_combos_aggregate (move_id, abbr) VALUES (new.move_id, new.abbr); );


--
-- Name: v_fighter_camps_insert; Type: RULE; Schema: public; Owner: jean
--

CREATE RULE v_fighter_camps_insert AS ON INSERT TO v_fighter_camps DO INSTEAD SELECT f_v_fighter_camps_insert((SELECT fighters.id FROM fighters WHERE ((fighters.name)::text = (new.name)::text)), (new.camp)::text) AS f_v_fighter_camps_insert;


--
-- Name: v_fighter_camps_update; Type: RULE; Schema: public; Owner: jean
--

CREATE RULE v_fighter_camps_update AS ON UPDATE TO v_fighter_camps DO INSTEAD SELECT f_v_fighter_camps_insert((SELECT fighters.id FROM fighters WHERE ((fighters.name)::text = (new.name)::text)), (new.camp)::text) AS f_v_fighter_camps_insert;


--
-- Name: v_fighter_moves_insert; Type: RULE; Schema: public; Owner: jean
--

CREATE RULE v_fighter_moves_insert AS ON INSERT TO v_fighter_moves DO INSTEAD SELECT f_v_fighter_moves_insert((SELECT fighters.id FROM fighters WHERE ((fighters.name)::text = (new.name)::text)), (new.move)::text) AS f_v_fighter_moves_insert;


--
-- Name: v_fighters_delete; Type: RULE; Schema: public; Owner: jean
--

CREATE RULE v_fighters_delete AS ON DELETE TO v_fighters DO INSTEAD DELETE FROM fighters WHERE ((fighters.name)::text = (old.name)::text);


--
-- Name: v_fighters_insert; Type: RULE; Schema: public; Owner: jean
--

CREATE RULE v_fighters_insert AS ON INSERT TO v_fighters DO INSTEAD SELECT f_v_fighters_insert(new.*) AS f_v_fighters_insert;


--
-- Name: v_fighters_update; Type: RULE; Schema: public; Owner: jean
--

CREATE RULE v_fighters_update AS ON UPDATE TO v_fighters DO INSTEAD SELECT f_v_fighters_update(new.*) AS f_v_fighters_update;


--
-- Name: v_moves_delete; Type: RULE; Schema: public; Owner: jean
--

CREATE RULE v_moves_delete AS ON DELETE TO v_moves DO INSTEAD DELETE FROM moves WHERE ((moves.name)::text = (old.move)::text);


--
-- Name: v_moves_insert; Type: RULE; Schema: public; Owner: jean
--

CREATE RULE v_moves_insert AS ON INSERT TO v_moves DO INSTEAD (INSERT INTO moves (id, name, type, start_position_id, end_position_id) VALUES (new.id, new.move, new.type, (SELECT positions.id FROM positions WHERE ((positions.name)::text = (new.start_position)::text)), (SELECT positions.id FROM positions WHERE ((positions.name)::text = (new.end_position)::text))); INSERT INTO v_combos_aggregate (move_id, abbr) VALUES (new.id, new.key_combo); SELECT f_v_moves_insert(new.id, (new.camp)::text, new.prerequisit_moves, new.prerequisit_skills) AS f_v_moves_insert; );


--
-- Name: v_moves_update; Type: RULE; Schema: public; Owner: jean
--

CREATE RULE v_moves_update AS ON UPDATE TO v_moves DO INSTEAD (DELETE FROM v_moves WHERE ((v_moves.move)::name = (old.*)::name); INSERT INTO v_moves (id, move, key_combo, type, start_position, end_position, camp, camp_count, prerequisit_moves, prerequisit_skills) VALUES (new.id, new.move, new.key_combo, new.type, new.start_position, new.end_position, new.camp, new.camp_count, new.prerequisit_moves, new.prerequisit_skills); );


--
-- Name: button_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY combo
    ADD CONSTRAINT button_id_fkey FOREIGN KEY (button_id) REFERENCES buttons(id);


--
-- Name: camp_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY fighter_camps
    ADD CONSTRAINT camp_id_fkey FOREIGN KEY (camp_id) REFERENCES camps(id);


--
-- Name: fighter_camps_fighter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY fighter_camps
    ADD CONSTRAINT fighter_camps_fighter_id_fkey FOREIGN KEY (fighter_id) REFERENCES fighters(id) ON DELETE CASCADE;


--
-- Name: fighter_moves_fighter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY fighter_moves
    ADD CONSTRAINT fighter_moves_fighter_id_fkey FOREIGN KEY (fighter_id) REFERENCES fighters(id);


--
-- Name: fightercontract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY fightercontract
    ADD CONSTRAINT fightercontract_id_fkey FOREIGN KEY (id) REFERENCES fighters(id) ON DELETE CASCADE;


--
-- Name: fightercountry_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY fightercountry
    ADD CONSTRAINT fightercountry_country_fkey FOREIGN KEY (country) REFERENCES country(id);


--
-- Name: fightercountry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY fightercountry
    ADD CONSTRAINT fightercountry_id_fkey FOREIGN KEY (id) REFERENCES fighters(id) ON DELETE CASCADE;


--
-- Name: fighternickname_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY fighternickname
    ADD CONSTRAINT fighternickname_id_fkey FOREIGN KEY (id) REFERENCES fighters(id) ON DELETE CASCADE;


--
-- Name: fighterrating_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY fighterrating
    ADD CONSTRAINT fighterrating_id_fkey FOREIGN KEY (id) REFERENCES fighters(id) ON DELETE CASCADE;


--
-- Name: fighterrecords_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY fighterrecords
    ADD CONSTRAINT fighterrecords_id_fkey FOREIGN KEY (id) REFERENCES fighters(id) ON DELETE CASCADE;


--
-- Name: fighters_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY fighters
    ADD CONSTRAINT fighters_source_id_fkey FOREIGN KEY (source_id) REFERENCES fightersource(id);


--
-- Name: move_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY move_skill_requirements
    ADD CONSTRAINT move_id_fkey FOREIGN KEY (move_id) REFERENCES moves(id);


--
-- Name: move_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY move_move_requirements
    ADD CONSTRAINT move_id_fkey FOREIGN KEY (move_id) REFERENCES moves(id);


--
-- Name: move_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY combo
    ADD CONSTRAINT move_id_fkey FOREIGN KEY (move_id) REFERENCES moves(id);


--
-- Name: move_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY fighter_moves
    ADD CONSTRAINT move_id_fkey FOREIGN KEY (move_id) REFERENCES moves(id);


--
-- Name: moves_end_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY moves
    ADD CONSTRAINT moves_end_position_id_fkey FOREIGN KEY (end_position_id) REFERENCES positions(id);


--
-- Name: moves_start_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY moves
    ADD CONSTRAINT moves_start_position_id_fkey FOREIGN KEY (start_position_id) REFERENCES positions(id);


--
-- Name: req_move_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY move_move_requirements
    ADD CONSTRAINT req_move_id_fkey FOREIGN KEY (req_move_id) REFERENCES moves(id);


--
-- Name: skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY skillfocii
    ADD CONSTRAINT skill_id_fkey FOREIGN KEY (skill_id) REFERENCES skills(id);


--
-- Name: skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY move_skill_requirements
    ADD CONSTRAINT skill_id_fkey FOREIGN KEY (skill_id) REFERENCES skills(id);


--
-- Name: valid_camp; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY moves_camps
    ADD CONSTRAINT valid_camp FOREIGN KEY (camp_id) REFERENCES camps(id);


--
-- Name: valid_move; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY moves_camps
    ADD CONSTRAINT valid_move FOREIGN KEY (move_id) REFERENCES moves(id);


--
-- Name: valid_weightclass; Type: FK CONSTRAINT; Schema: public; Owner: jean
--

ALTER TABLE ONLY fighters
    ADD CONSTRAINT valid_weightclass FOREIGN KEY (weightclass) REFERENCES weightclass(id);


--
-- PostgreSQL database dump complete
--

