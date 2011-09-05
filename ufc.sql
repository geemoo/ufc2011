--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- Name: contract; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE contract AS ENUM (
    'AMA',
    'WFA',
    'UFN',
    'UFC'
);


--
-- Name: focusgroup; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE focusgroup AS ENUM (
    'Standup',
    'Takedown',
    'Clinch',
    'Ground and Pound',
    'Grappling/Submission'
);


--
-- Name: move_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE move_type AS ENUM (
    'Strike',
    'Kick',
    'Transition',
    'Submission'
);


--
-- Name: technique_type; Type: TYPE; Schema: public; Owner: -
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


--
-- Name: move_search(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION move_search(character varying, OUT start_position character varying, OUT move character varying, OUT camp character varying) RETURNS record
    LANGUAGE sql
    AS $_$ select start_position, move, camp from position_move_camp_view where move like $1 $_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: buttons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE buttons (
    id integer NOT NULL,
    abbr character varying NOT NULL,
    name character varying NOT NULL
);


--
-- Name: buttons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE buttons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: buttons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE buttons_id_seq OWNED BY buttons.id;


--
-- Name: buttons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('buttons_id_seq', 38, true);


--
-- Name: camps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE camps (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- Name: combo; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE combo (
    move_id integer NOT NULL,
    button_id integer NOT NULL,
    seq integer NOT NULL,
    variant integer NOT NULL
);


--
-- Name: combo_seq_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE combo_seq_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: combo_seq_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE combo_seq_seq OWNED BY combo.seq;


--
-- Name: combo_seq_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('combo_seq_seq', 1, false);


--
-- Name: country; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE country (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- Name: country_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE country_id_seq OWNED BY country.id;


--
-- Name: country_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('country_id_seq', 29, true);


--
-- Name: fighter_camps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fighter_camps (
    fighter_id integer NOT NULL,
    camp_id integer NOT NULL
);


--
-- Name: fighter_moves; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fighter_moves (
    fighter_id integer NOT NULL,
    move_id integer NOT NULL,
    level integer DEFAULT 1 NOT NULL,
    CONSTRAINT leve_range CHECK (((level >= 0) AND (level <= 3))),
    CONSTRAINT valid_level CHECK (((level >= 1) AND (level <= 3)))
);


--
-- Name: fightercontract; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fightercontract (
    id integer NOT NULL,
    contract contract NOT NULL
);


--
-- Name: fightercountry; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fightercountry (
    id integer NOT NULL,
    country integer NOT NULL
);


--
-- Name: fighternickname; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fighternickname (
    id integer NOT NULL,
    nickname text NOT NULL
);


--
-- Name: fighterrating; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fighterrating (
    id integer NOT NULL,
    rating integer NOT NULL,
    CONSTRAINT fighterrating_rating_check CHECK (((rating >= 0) AND (rating <= 100)))
);


--
-- Name: fighterrecords; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fighterrecords (
    id integer NOT NULL,
    record text NOT NULL
);


--
-- Name: fighters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fighters (
    id integer NOT NULL,
    name character varying NOT NULL,
    weightclass integer,
    source_id integer NOT NULL
);


--
-- Name: fightersource; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fightersource (
    id integer NOT NULL,
    source character varying NOT NULL
);


--
-- Name: weightclass; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE weightclass (
    id integer NOT NULL,
    name character varying NOT NULL,
    lbs integer NOT NULL
);


--
-- Name: fighter_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW fighter_view AS
    WITH i(_grouping, datum) AS (WITH RECURSIVE k(_grouping, _length, _count, _number, datum) AS (WITH lb(_grouping, _length, _count, _number, datum) AS (WITH grouping_datum(grouping, datum) AS (SELECT fighter_camps.fighter_id, camps.name FROM (fighter_camps JOIN camps ON ((fighter_camps.camp_id = camps.id)))) SELECT grouping_datum.grouping, 1, count(*) OVER (grouping_window) AS count, row_number() OVER (grouping_window) AS row_number, grouping_datum.datum FROM grouping_datum WINDOW grouping_window AS (PARTITION BY grouping_datum.grouping)) SELECT lb._grouping, lb._length, lb._count, lb._number, lb.datum FROM lb UNION SELECT k._grouping, (k._length + 1), k._count, k._number, (((k.datum)::text || ', '::text) || (lb.datum)::text) FROM (k JOIN lb ON (((lb._grouping = k._grouping) AND (k._length = lb._number))))) SELECT k._grouping, k.datum FROM k WHERE ((k._count = k._length) AND (k._count = k._number))) SELECT fighters.id, fighters.name, weightclass.name AS weightclass, i.datum AS camp, fightercontract.contract, fighterrating.rating, fightersource.source, weightclass.lbs AS weight, fighterrecords.record, fighternickname.nickname, country.name AS country FROM (((((((((fighters LEFT JOIN i ON ((fighters.id = i._grouping))) LEFT JOIN weightclass ON ((fighters.weightclass = weightclass.id))) LEFT JOIN fightercontract ON ((fighters.id = fightercontract.id))) LEFT JOIN fighterrecords ON ((fighters.id = fighterrecords.id))) LEFT JOIN fighternickname ON ((fighters.id = fighternickname.id))) LEFT JOIN fighterrating ON ((fighters.id = fighterrating.id))) LEFT JOIN fightercountry ON ((fighters.id = fightercountry.id))) LEFT JOIN fightersource ON ((fighters.source_id = fightersource.id))) LEFT JOIN country ON ((fightercountry.country = country.id)));


--
-- Name: fighters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fighters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: fighters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fighters_id_seq OWNED BY fighters.id;


--
-- Name: fighters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('fighters_id_seq', 347, true);


--
-- Name: fightersource_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fightersource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: fightersource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fightersource_id_seq OWNED BY fightersource.id;


--
-- Name: fightersource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('fightersource_id_seq', 5, true);


--
-- Name: move_move_requirements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE move_move_requirements (
    move_id integer NOT NULL,
    req_move_id integer NOT NULL
);


--
-- Name: move_skill_requirements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE move_skill_requirements (
    move_id integer NOT NULL,
    skill_id integer NOT NULL,
    level integer NOT NULL,
    CONSTRAINT level_range CHECK (((level >= 0) AND (level <= 100)))
);


--
-- Name: moves; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE moves (
    id integer NOT NULL,
    name character varying NOT NULL,
    type technique_type
);


--
-- Name: moves_camps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE moves_camps (
    move_id integer NOT NULL,
    camp_id integer NOT NULL
);


--
-- Name: positions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE positions (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- Name: positions_moves; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE positions_moves (
    position_id integer NOT NULL,
    move_id integer NOT NULL,
    end_position_id integer NOT NULL
);


--
-- Name: skills; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE skills (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- Name: position_move_camp_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW position_move_camp_view AS
    WITH x(_move, _length, camp) AS (WITH RECURSIVE z(_move, _length, _count, _number, camp) AS (WITH y(_move, _length, _count, _number, camp) AS (WITH move_camp(move, camp) AS (SELECT moves_camps.move_id, camps.name FROM (moves_camps JOIN camps ON ((moves_camps.camp_id = camps.id)))) SELECT move_camp.move, 1, count(*) OVER (move_window) AS count, row_number() OVER (move_window) AS row_number, move_camp.camp FROM move_camp WINDOW move_window AS (PARTITION BY move_camp.move)) SELECT y._move, y._length, y._count, y._number, y.camp FROM y UNION SELECT z._move, (z._length + 1), z._count, z._number, (((z.camp)::text || ', '::text) || (y.camp)::text) FROM (z JOIN y ON (((y._move = z._move) AND (z._length = y._number))))) SELECT z._move, z._length, z.camp FROM z WHERE ((z._count = z._length) AND (z._count = z._number))), j(_grouping, datum) AS (WITH RECURSIVE k(_grouping, _length, _count, _number, datum) AS (WITH lb(_grouping, _length, _count, _number, datum) AS (WITH grouping_datum(grouping, datum) AS (SELECT move_move_requirements.move_id, ((((moves.name)::text || ' ('::text) || (positions.name)::text) || ')'::text) FROM (((move_move_requirements JOIN moves ON ((move_move_requirements.req_move_id = moves.id))) JOIN positions_moves ON ((positions_moves.move_id = moves.id))) JOIN positions ON ((positions_moves.position_id = positions.id)))) SELECT grouping_datum.grouping, 1, count(*) OVER (grouping_window) AS count, row_number() OVER (grouping_window) AS row_number, grouping_datum.datum FROM grouping_datum WINDOW grouping_window AS (PARTITION BY grouping_datum.grouping)) SELECT lb._grouping, lb._length, lb._count, lb._number, lb.datum FROM lb UNION SELECT k._grouping, (k._length + 1), k._count, k._number, ((k.datum || ', '::text) || lb.datum) FROM (k JOIN lb ON (((lb._grouping = k._grouping) AND (k._length = lb._number))))) SELECT k._grouping, k.datum FROM k WHERE ((k._count = k._length) AND (k._count = k._number))), i(_grouping, datum) AS (WITH RECURSIVE k(_grouping, _length, _count, _number, datum) AS (WITH lb(_grouping, _length, _count, _number, datum) AS (WITH grouping_datum(grouping, datum) AS (SELECT move_skill_requirements.move_id, ((((skills.name)::text || '('::text) || move_skill_requirements.level) || ')'::text) FROM (move_skill_requirements JOIN skills ON ((move_skill_requirements.skill_id = skills.id)))) SELECT grouping_datum.grouping, 1, count(*) OVER (grouping_window) AS count, row_number() OVER (grouping_window) AS row_number, grouping_datum.datum FROM grouping_datum WINDOW grouping_window AS (PARTITION BY grouping_datum.grouping)) SELECT lb._grouping, lb._length, lb._count, lb._number, lb.datum FROM lb UNION SELECT k._grouping, (k._length + 1), k._count, k._number, ((k.datum || ', '::text) || lb.datum) FROM (k JOIN lb ON (((lb._grouping = k._grouping) AND (k._length = lb._number))))) SELECT k._grouping, k.datum FROM k WHERE ((k._count = k._length) AND (k._count = k._number))), h(_grouping, datum) AS (WITH RECURSIVE k(_grouping, _length, _count, _number, datum) AS (WITH lb(_grouping, _length, _count, _number, datum) AS (WITH grouping_datum(grouping, datum) AS (SELECT combo.button_id, buttons.abbr FROM (combo JOIN buttons ON ((combo.button_id = buttons.id))) ORDER BY combo.seq) SELECT grouping_datum.grouping, 1, count(*) OVER (grouping_window) AS count, row_number() OVER (grouping_window) AS row_number, grouping_datum.datum FROM grouping_datum WINDOW grouping_window AS (PARTITION BY grouping_datum.grouping)) SELECT lb._grouping, lb._length, lb._count, lb._number, lb.datum FROM lb UNION SELECT k._grouping, (k._length + 1), k._count, k._number, (((k.datum)::text || ', '::text) || (lb.datum)::text) FROM (k JOIN lb ON (((lb._grouping = k._grouping) AND (k._length = lb._number))))) SELECT k._grouping, k.datum FROM k WHERE ((k._count = k._length) AND (k._count = k._number))) SELECT moves.name AS move, h.datum AS key_combo, moves.type, a.name AS start_position, b.name AS end_position, x.camp, x._length AS camp_count, j.datum AS prerequisite_moves, i.datum AS prerequisite_skills FROM (((((((positions_moves JOIN moves ON ((positions_moves.move_id = moves.id))) JOIN positions a ON ((positions_moves.position_id = a.id))) JOIN positions b ON ((positions_moves.end_position_id = b.id))) LEFT JOIN x ON ((moves.id = x._move))) LEFT JOIN j ON ((moves.id = j._grouping))) LEFT JOIN i ON ((moves.id = i._grouping))) LEFT JOIN h ON ((moves.id = h._grouping))) ORDER BY a.id, moves.id, x._length;


--
-- Name: position_moves_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW position_moves_view AS
    WITH z("position", _length, moves) AS (WITH RECURSIVE x("position", _length, _count, _number, moves) AS (WITH y("position", _length, _count, _number, moves) AS (SELECT position_move_camp_view.start_position, 1, count(*) OVER (position_window) AS count, row_number() OVER (position_window) AS row_number, position_move_camp_view.move FROM position_move_camp_view WINDOW position_window AS (PARTITION BY position_move_camp_view.start_position)) SELECT y."position", y._length, y._count, y._number, y.moves FROM y UNION SELECT x."position", (x._length + 1), x._count, x._number, (((x.moves)::text || ', '::text) || (y.moves)::text) FROM (x JOIN y ON ((((y."position")::text = (x."position")::text) AND (x._length = y._number))))) SELECT x."position", x._length, x.moves FROM x WHERE ((x._count = x._length) AND (x._count = x._number))) SELECT z."position", z._length AS move_count, z.moves FROM z ORDER BY z."position", z._length;


--
-- Name: reverse_position_moves_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW reverse_position_moves_view AS
    WITH z("position", _length, moves) AS (WITH RECURSIVE x("position", _length, _count, _number, moves) AS (WITH y("position", _length, _count, _number, moves) AS (SELECT position_move_camp_view.end_position, 1, count(*) OVER (position_window) AS count, row_number() OVER (position_window) AS row_number, position_move_camp_view.move FROM position_move_camp_view WINDOW position_window AS (PARTITION BY position_move_camp_view.end_position)) SELECT y."position", y._length, y._count, y._number, y.moves FROM y UNION SELECT x."position", (x._length + 1), x._count, x._number, (((x.moves)::text || ', '::text) || (y.moves)::text) FROM (x JOIN y ON ((((y."position")::text = (x."position")::text) AND (x._length = y._number))))) SELECT x."position", x._length, x.moves FROM x WHERE ((x._count = x._length) AND (x._count = x._number))) SELECT z."position", z._length AS move_count, z.moves FROM z ORDER BY z."position", z._length;


--
-- Name: skill_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE skill_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: skill_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE skill_id_seq OWNED BY skills.id;


--
-- Name: skill_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('skill_id_seq', 16, true);


--
-- Name: skillfocii; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE skillfocii (
    skill_id integer NOT NULL,
    focus focusgroup NOT NULL
);


--
-- Name: transition_moves_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW transition_moves_view AS
    WITH z(start_position, end_position, _length, moves) AS (WITH RECURSIVE x(start_position, end_position, _length, _count, _number, moves) AS (WITH y(start_position, end_position, _length, _count, _number, moves) AS (SELECT position_move_camp_view.start_position, position_move_camp_view.end_position, 1, count(*) OVER (position_window) AS count, row_number() OVER (position_window) AS row_number, position_move_camp_view.move FROM position_move_camp_view WHERE ((position_move_camp_view.start_position)::text <> (position_move_camp_view.end_position)::text) WINDOW position_window AS (PARTITION BY position_move_camp_view.start_position, position_move_camp_view.end_position)) SELECT y.start_position, y.end_position, y._length, y._count, y._number, y.moves FROM y UNION SELECT x.start_position, x.end_position, (x._length + 1), x._count, x._number, (((x.moves)::text || ', '::text) || (y.moves)::text) FROM (x JOIN y ON ((((y.start_position)::text = (x.start_position)::text) AND (x._length = y._number))))) SELECT x.start_position, x.end_position, x._length, x.moves FROM x WHERE ((x._count = x._length) AND (x._count = x._number))), c(start_position, end_position, _length, moves) AS (WITH RECURSIVE a(start_position, end_position, _length, _count, _number, moves) AS (WITH b(start_position, end_position, _length, _count, _number, moves) AS (SELECT position_move_camp_view.start_position, position_move_camp_view.end_position, 1, count(*) OVER (position_window) AS count, row_number() OVER (position_window) AS row_number, position_move_camp_view.move FROM position_move_camp_view WHERE ((position_move_camp_view.start_position)::text = (position_move_camp_view.end_position)::text) WINDOW position_window AS (PARTITION BY position_move_camp_view.start_position, position_move_camp_view.end_position)) SELECT b.start_position, b.end_position, b._length, b._count, b._number, b.moves FROM b UNION SELECT a.start_position, a.end_position, (a._length + 1), a._count, a._number, (((a.moves)::text || ', '::text) || (b.moves)::text) FROM (a JOIN b ON ((((b.start_position)::text = (a.start_position)::text) AND (a._length = b._number))))) SELECT a.start_position, a.end_position, a._length, a.moves FROM a WHERE ((a._count = a._length) AND (a._count = a._number))) SELECT z.start_position, z.end_position, z._length AS move_count, z.moves FROM z UNION SELECT c.start_position, c.end_position, c._length AS move_count, c.moves FROM c ORDER BY 1, 2, 3;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE buttons ALTER COLUMN id SET DEFAULT nextval('buttons_id_seq'::regclass);


--
-- Name: seq; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE combo ALTER COLUMN seq SET DEFAULT nextval('combo_seq_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE country ALTER COLUMN id SET DEFAULT nextval('country_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE fighters ALTER COLUMN id SET DEFAULT nextval('fighters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE fightersource ALTER COLUMN id SET DEFAULT nextval('fightersource_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE skills ALTER COLUMN id SET DEFAULT nextval('skill_id_seq'::regclass);


--
-- Data for Name: buttons; Type: TABLE DATA; Schema: public; Owner: -
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
\.


--
-- Data for Name: camps; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: combo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY combo (move_id, button_id, seq, variant) FROM stdin;
\.


--
-- Data for Name: country; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: fighter_camps; Type: TABLE DATA; Schema: public; Owner: -
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
\.


--
-- Data for Name: fighter_moves; Type: TABLE DATA; Schema: public; Owner: -
--

COPY fighter_moves (fighter_id, move_id, level) FROM stdin;
\.


--
-- Data for Name: fightercontract; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: fightercountry; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: fighternickname; Type: TABLE DATA; Schema: public; Owner: -
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
\.


--
-- Data for Name: fighterrating; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: fighterrecords; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: fighters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY fighters (id, name, weightclass, source_id) FROM stdin;
30	Kyle Noke	5	5
347	Jorge Horvat	3	4
46	Yves Edwards	3	5
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
-- Data for Name: fightersource; Type: TABLE DATA; Schema: public; Owner: -
--

COPY fightersource (id, source) FROM stdin;
3	Game
4	Player
5	Real World
\.


--
-- Data for Name: move_move_requirements; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: move_skill_requirements; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: moves; Type: TABLE DATA; Schema: public; Owner: -
--

COPY moves (id, name, type) FROM stdin;
3	Pummel to Double Underhook Defense	Clinch Transition
207	Transition to Open Guard Down Top	Transition
158	Transition to Open Guard Down Bottom	Transition
159	Transition to Up/Down Bottom	Transition
161	Transition to Half Guard Down Top	Transition
162	Transition to Open Guard Top	Transition
205	Cage Transition to Mount Down Top	Transition
272	Cage Transition to Side Control Top	Transition
124	Right Karate Front Kick	Kick
130	Right MMA Back Spin Kick	Kick
131	Right Muay Thai Head Kick	Kick
132	Right Muay Thai Leg Kick	Kick
163	Transition to Side Control Top	Transition
4	Transition to Both Standing	Transition
160	Triangle Choke from Butterfly Guard	Submission
264	Triangle Choke from Rubber Guard Bottom	Submission
184	Transition to Up/Down Bottom	Transition
187	Transition to Mount Down Top	Transition
190	D'arce Choke	Submission
208	Arm Triangle Choke from Mount Top	Submission
212	Arm Triangle Choke from Mount Top	Submission
228	North/South Choke from North/South Top	Submission
233	Strike Catch to Triangle Choke	Submission
240	Triangle Choke	Submission
243	Achilles Lock	Submission
231	Strike Catch to Kimura	Submission
236	Kimura	Submission
188	Transition to Side Control Top	Transition
200	Transition to Mount Down Top	Transition
133	Right Muay Thai Push Kick	Kick
134	Right Muay Thai Snap Kick	Kick
138	Right Spinning Back Kick	Kick
150	Strong Left Leg Kick	Kick
151	Strong Right Leg Kick	Kick
152	Switch Left Head Kick	Kick
155	Two Step Right Middle Kick	Kick
41	Left Muay Thai Elbow	Strike
43	Right Chopping Hook	Strike
58	Ducking Right Hook	Strike
47	Right Short Uppercut from Sway Forward	Strike
50	Backstep Right Hook from Switch Stance	Strike
46	Right Muay Thai Elbow	Strike
57	Ducking Left Hook	Strike
70	Left Guarded Hook	Strike
73	Left Hook from Sway Back	Strike
74	Left Hook from Sway Forward	Strike
76	Left Hook from Sway Right	Strike
83	Left Over Hook	Strike
84	Left Over Strong Hook	Strike
89	Left Sidestepping Upper Jab	Strike
92	Left Strong Uppercut	Strike
201	Transition to Mount Top	Transition
202	Transition to Side Control Top	Transition
203	Transition to Half Guard Bottom	Transition
204	Transition to Mount Down Bottom	Transition
206	Transition to Half Guard Down Bottom	Transition
229	Transition to Mount Down Top	Transition
234	Transition to Open Guard Down Bottom	Transition
235	Transition to Up/Down Bottom	Transition
238	Transition to Rubber Guard Down Bottom	Transition
239	Transition to Up/Down Bottom	Transition
241	Transition to Half Guard Down Top	Transition
242	Transition to Side Control Top	Transition
253	Transition to Half Guard Down Top	Transition
254	Transition to Half Guard Top	Transition
255	Transition to Side Control Top	Transition
273	Transition to Both Standing	Transition
274	Transition to Butterfly Guard Bottom	Transition
275	Transition to Half Guard Down Bottom	Transition
93	Left Undercut	Strike
95	Left Uppercut	Strike
94	Left Upper Jab	Strike
96	Lunging Left Hook	Strike
97	Lunging Right Hook	Strike
103	Overhand Left from Sway Forward	Strike
232	Strike Catch to Omoplata	Submission
237	Omoplata	Submission
157	Gogoplata from Butterfly Guard	Submission
245	Kneebar	Submission
265	Transition to Half Guard Down Top	Transition
266	Transition to Open Guard Top	Transition
268	Transition to Both Standing	Transition
271	Transition to Mount Top	Transition
1	German Suplex to Back Side Control Offense	Takedown
6	German Suplex to Back Side Control Offense	Takedown
2	Lift Up Slam to Side Control Offense	Takedown
164	Slam to Open Guard Down Offense	Takedown
7	Pull to Side Control	Takedown
5	Back Throw to Side Control Right Offense	Takedown
144	Shoot to Double Leg Takedown	Takedown
71	Left Head Kick	Kick
72	Left High Front Kick	Kick
114	Right Flying Knee	Kick
145	Step Right Knee	Kick
153	Two Step Left Flying Knee	Kick
154	Two Step Right Flying Knee	Kick
62	Hendo's Right Back Fist	Strike
64	Jardine's Right Superman Punch	Strike
65	Jon Jones' Right Back Fist	Strike
77	Left Jab to Sway Back	Strike
99	Lyoto's Right Straight	Strike
100	Lyoto's Stepping Straight	Strike
104	Overhand Right	Strike
105	Overhand Right from Sway Forward	Strike
106	Overhand Right Hook from Sway Forward	Strike
112	Right Ducking Uppercut to Head	Strike
116	Right Guarded Hook	Strike
120	Right Hook from Sway Back	Strike
121	Right Hook from Sway Left	Strike
122	Right Hook From Sway Right	Strike
125	Right Karate Straight	Strike
126	Right Long Straight	Strike
128	Right Long Uppercut	Strike
129	Right Over Hook	Strike
136	Right Spinning Back Elbow	Strike
139	Right Strong Straight	Strike
140	Right Strong Uppercut	Strike
142	Right Uppercut	Strike
143	Shogun's Stepping Left Hook	Strike
146	Stepping Heavy Jab	Strike
147	Stepping Over Left Hook	Strike
148	Stepping Right Undercut	Strike
149	Stepping Right Uppercut	Strike
156	Weaving Overhand Right	Strike
26	Peruvian Neck Tie	Submission
9	Arm Trap Rear Naked Choke	Submission
16	Arm Trap Rear Naked Choke	Submission
22	Arm Trap Rear Naked Choke	Submission
24	Arm Trap Rear Naked Choke	Submission
262	Gogoplata from Rubber Guard Bottom	Submission
263	Omoplata from Rubber Guard Bottom	Submission
269	Americana from Side Control Top	Submission
267	Armbar from Salaverry Top	Submission
258	Takedown to Half Guard Down Offense	Takedown
259	Hip Throw to Side Control Offense	Takedown
260	Pull Guard to Open Guard Down Defense	Takedown
256	Ouchi Gari to Open Guard Down Offense	Takedown
78	Left Jumping Front Kick	Kick
80	Left Muay Thai Head Kick	Kick
81	Left Muay Thai Leg Kick	Kick
82	Left Muay Thai Push Kick	Kick
87	Left Side Kick	Kick
88	Left Side Kick to Body	Kick
91	Left Spinning Back Kick	Kick
98	Lyoto's Left Head Kick	Kick
42	Left Short Uppercut From Sway Forward	Strike
67	Left Back Fist	Strike
90	Left Spinning Back Fist	Strike
109	Right Back Fist	Strike
137	Right Spinning Back Fist	Strike
59	Forrest's Left Front Kick	Kick
60	Forrest's Left Head Kick	Kick
247	Achilles Lock from Open Guard Top	Submission
250	Kneebar from Open Guard Top	Submission
10	Armbar from Back Mount Face Up Top	Submission
17	Armbar from Back Mount Top	Submission
25	Armbar from Back Side Control Top	Submission
11	Rear Naked Choke	Submission
15	Rear Naked Choke from Back Mount Rocked	Submission
18	Rear Naked Choke Facing Downward	Submission
23	Rear Naked Choke	Submission
27	Rear Naked Choke	Submission
175	Strike Catch to Armbar	Submission
211	Armbar from Mount Rocked Top	Submission
213	Armbar from Mount Top	Submission
227	Armbar from North/South Top	Submission
230	Strike Catch to Armbar	Submission
278	Armbar from Side Control Rocked Top	Submission
38	Inside Left Uppercut	Strike
39	Inside Right Uppercut	Strike
51	Backstepping Right Straight	Strike
52	Brock's Right Straight	Strike
56	Chuck's Right Straight	Strike
63	Hendo's Right Strong Straight	Strike
69	Left Flicking Jab	Strike
75	Left Hook from Sway Left	Strike
79	Left Long Superman Punch	Strike
85	Left Punch from Kick Catch	Strike
86	Left Quick Superman Punch	Strike
127	Right Long Superman Punch	Strike
135	Right Punch from Kick Catch	Strike
277	Americana from Side Control Top	Submission
279	Americana from Side Control Top	Submission
246	Toe Hold	Submission
252	Toe Hold from Open Guard Top	Submission
276	Transition to Open Guard Down Bottom	Transition
8	Transition to Both Standing	Transition
13	Transition to Back Mount Face Up Body Triangle Top	Transition
14	Transition to Mount Top	Transition
20	Transition to Both Standing	Transition
21	Transition to Open Guard Bottom	Transition
30	Transition to Back Mount Face Up Top	Transition
31	Transition to Back Mount Top	Transition
177	Transition to Half Guard Down Bottom	Transition
178	Transition to Open Guard Bottom	Transition
179	Transition to Up/Down Bottom	Transition
182	Transition to Butterfly Guard Bottom	Transition
183	Transition to Open Guard Down Bottom	Transition
219	Pummel to Over/Under Hook	Clinch Transition
257	Pummel to Double Underhook Cage Offense	Clinch Transition
261	Pummel to Double Underhook Offense	Clinch Transition
180	Cage Transition to Half Guard Down Bottom	Transition
40	Left Leg Kick	Kick
44	Right Dodge Knee to the Body	Kick
45	Right Leg Kick	Kick
48	Strong Left Leg Kick	Kick
49	Strong Right Leg Kick	Kick
53	Caol's Back Spin Kick	Kick
54	Caol's Left Side Kick	Kick
55	Check Head Kick	Kick
61	GSP's Head Kick	Kick
66	Left Axe Kick	Kick
68	Left Front Upward Kick	Kick
101	Napao's Right Head Kick	Kick
102	One Feint Head Kick	Kick
107	Quick Head Kick	Kick
108	Right Axe Kick	Kick
110	Right Back Kick	Kick
111	Right Brazilian Head Kick	Kick
113	Right Flying Head Kick	Kick
115	Right Front Upper Kick	Kick
117	Right Head Kick	Kick
118	Right High Front Kick	Kick
119	Right High Kick	Kick
123	Right Karate Back Spin Kick	Kick
141	Right Superman Punch	Strike
244	Heel Hook	Submission
249	Heel Hook from Open Guard Top	Submission
19	Strong Hook	Ground Strike
28	Strong Hook	Ground Strike
29	Strong Knee to Abdomen	Ground Strike
12	Strong Right Hook	Ground Strike
251	Strong Hook	Ground Strike
198	Strong Hook	Ground Strike
215	Strong Hook	Ground Strike
196	Kneebar from Half Guard Top	Submission
185	Americana from Half Guard Top	Submission
189	Americana from Half Guard Rocked Top	Submission
192	Americana from Half Guard Top	Submission
199	Toe Hold from Half Guard Top	Submission
176	Strike Catch to Kimura	Submission
181	Kimura	Submission
186	Kimura from Half Guard Top	Submission
191	Kimura from Half Guard Top	Submission
195	Kimura from Half Guard Top	Submission
170	Pummel to Double Underhook Offense	Clinch Transition
171	Pummel to Single Collar Tie	Clinch Transition
218	Pummel to Muay Thai Clinch Offense	Clinch Transition
166	Clinch to Body Lock Cage Offense	Clinch Transition
172	Clinch to Body Lock Offense	Clinch Transition
165	Left Turn Off to Double Underhook Defense	Clinch Transition
168	Suplex to Side Control Offense	Takedown
174	Suplex to Side Control Offense	Takedown
169	Judo Hip Throw to Side Control Offense	Takedown
167	Pull Guard to Open Guard Down Defense	Takedown
173	Pull Guard to Open Guard Down Defense	Takedown
223	Pull Guard to Open Guard Down Defense	Takedown
248	Elbow	Ground Strike
270	Elbow	Ground Strike
193	Elbow	Ground Strike
194	Hammer Fist	Ground Strike
209	Ground Buster from Mount Down Top	Ground Strike
214	Elbow	Ground Strike
216	Rear Leg Knee	Clinch Strike
217	Strong Knee	Clinch Strike
220	Arcing Elbow	Clinch Strike
221	Knee	Clinch Strike
222	Knee to Body	Clinch Strike
224	Rear Leg Knee	Clinch Strike
225	Strong Knee	Clinch Strike
226	Uppercut	Clinch Strike
304	Peruvian Neck Tie from Sprawl Top	Submission
280	Arm Triangle Choke	Submission
301	Guillotine Choke from Sprawl Rocked	Submission
302	Anaconda Choke from Sprawl Top	Submission
303	Guillotine Choke from Sprawl Top	Submission
311	Achilles Lock from Up/Down Near Top	Submission
309	Kneebar from Up/Down Near Bottom	Submission
313	Kneebar from Up/Down Near Top	Submission
317	Toe Hold from Up/Down Near Top	Submission
282	Kimura from Side Control Top	Submission
287	Transition to Salaverry Top	Transition
285	Transition to Mount Down Top	Transition
286	Transition to Mount Top	Transition
299	Transition to Both Standing	Transition
300	Transition to Open Guard Down Bottom	Transition
306	Transition to Back Mount Top	Transition
33	Suplex to Side Control Offense	Takedown
36	Suplex to Half Guard Down Offense	Takedown
37	Suplex to Side Control Offense	Takedown
34	Judo Hip Throw to Side Control Offense	Takedown
32	Pull Guard to Open Guard Down Defense	Takedown
35	Pull Guard to Open Guard Down Defense	Takedown
297	Slam to Open Guard Down Offense	Takedown
298	Slam to Side Control Offense	Takedown
294	Pull Guard to Open Guard Down Defense	Takedown
312	Heel Hook from Up/Down Near Top	Submission
281	Elbow	Ground Strike
283	Strong Left Knee to Abdomen	Ground Strike
284	Strong Right Knee to Abdomen	Ground Strike
305	Strong Hook	Ground Strike
307	Left Superman Punch	Ground Strike
308	Right Superman Punch	Ground Strike
314	Left Axe Kick to Body	Ground Strike
315	Left Superman Punch	Ground Strike
316	Right Superman Punch	Ground Strike
310	Up-Kick	Ground Strike
289	Downward Arcing Elbow	Clinch Strike
290	Strong Hook	Clinch Strike
291	Strong Knee to Abdomen	Clinch Strike
293	Uppercut to Body	Clinch Strike
295	Strong Hook	Clinch Strike
296	Uppercut	Clinch Strike
288	Crushing Knee	Clinch Strike
292	Strong Uppercut	Clinch Strike
\.


--
-- Data for Name: moves_camps; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: positions; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: positions_moves; Type: TABLE DATA; Schema: public; Owner: -
--

COPY positions_moves (position_id, move_id, end_position_id) FROM stdin;
24	180	24
1	1	10
1	2	50
2	4	15
3	5	50
3	6	10
4	8	15
5	13	5
5	14	32
8	21	38
10	30	5
11	32	38
11	33	50
12	34	50
13	36	25
13	37	50
15	144	39
16	159	58
17	161	25
17	163	50
18	164	39
19	165	21
20	167	38
20	168	50
21	169	50
21	171	52
22	172	13
22	174	50
23	177	24
23	178	37
24	182	16
24	183	38
25	187	30
25	188	50
27	201	32
27	202	50
28	203	23
29	205	30
29	206	24
29	207	39
34	218	35
34	219	43
5	10	5
5	9	5
5	11	5
6	15	6
7	17	7
7	16	7
7	19	7
9	22	9
10	25	10
10	24	10
10	26	10
10	28	10
10	29	10
14	38	14
14	40	14
14	41	14
14	43	14
14	44	14
14	45	14
14	47	14
14	48	14
14	49	14
15	50	15
2	3	21
3	7	50
8	20	15
10	31	7
13	35	38
16	158	38
17	162	41
20	166	11
21	170	22
22	173	38
23	179	58
24	184	58
27	200	30
28	204	29
35	223	38
36	229	30
37	234	38
37	235	58
38	238	44
38	239	58
39	241	25
39	242	50
41	253	25
41	254	27
41	255	50
42	256	39
42	257	20
42	258	25
43	259	50
43	260	38
43	261	22
45	265	25
45	266	41
46	268	15
47	271	32
48	272	50
48	273	15
48	274	16
48	275	24
48	276	38
50	285	30
50	286	32
50	287	47
52	294	38
53	297	39
53	298	50
54	299	15
54	300	38
56	306	7
5	12	5
7	18	7
9	23	9
10	27	10
14	39	14
14	42	14
14	46	14
15	51	15
15	52	15
15	53	15
15	54	15
15	55	15
15	56	15
15	57	15
15	58	15
15	59	15
15	60	15
15	61	15
15	62	15
15	63	15
15	64	15
15	65	15
15	66	15
15	67	15
15	69	15
15	68	15
15	70	15
15	71	15
15	72	15
15	73	15
15	74	15
15	75	15
15	76	15
15	77	15
15	78	15
15	79	15
15	80	15
15	81	15
15	82	15
15	83	15
15	84	15
15	85	15
15	86	15
15	87	15
15	88	15
15	89	15
15	90	15
15	91	15
15	92	15
15	93	15
15	95	15
15	94	15
15	96	15
15	97	15
15	98	15
15	99	15
15	100	15
15	101	15
15	102	15
15	103	15
15	104	15
15	105	15
15	106	15
15	107	15
15	108	15
15	109	15
15	110	15
15	111	15
15	112	15
15	113	15
15	114	15
15	115	15
15	116	15
15	117	15
15	118	15
15	119	15
15	120	15
15	121	15
15	122	15
15	123	15
15	124	15
15	125	15
15	126	15
15	127	15
15	128	15
36	228	36
37	230	37
37	231	37
37	233	37
38	236	38
38	237	38
40	243	40
40	244	40
40	246	40
41	247	41
41	248	41
41	250	41
41	251	41
41	252	41
44	263	44
44	264	44
47	269	47
47	270	47
49	277	49
50	279	50
50	280	50
50	281	50
50	283	50
50	284	50
51	289	51
51	290	51
51	291	51
51	293	51
52	295	52
52	296	52
56	302	56
56	303	56
56	305	56
57	307	57
57	308	57
58	310	58
59	311	59
59	312	59
59	314	59
59	315	59
59	317	59
15	130	15
15	131	15
15	132	15
15	133	15
15	134	15
15	129	15
15	135	15
15	136	15
15	137	15
15	138	15
15	139	15
15	140	15
15	141	15
15	142	15
15	143	15
15	146	15
15	147	15
15	148	15
15	149	15
15	145	15
15	150	15
15	151	15
15	152	15
15	153	15
15	154	15
15	155	15
15	156	15
16	157	16
16	160	16
23	175	23
23	176	23
24	181	24
25	185	25
25	186	25
26	189	26
26	190	26
26	191	26
27	192	27
27	193	27
27	194	27
27	195	27
27	196	27
27	198	27
27	199	27
30	208	30
30	209	30
31	211	31
32	213	32
32	212	32
32	214	32
32	215	32
33	216	33
33	217	33
35	220	35
35	221	35
35	222	35
35	224	35
35	225	35
35	226	35
36	227	36
37	232	37
38	240	38
40	245	40
41	249	41
44	262	44
46	267	46
49	278	49
50	282	50
51	288	51
51	292	51
55	301	55
56	304	56
58	309	58
59	313	59
59	316	59
\.


--
-- Data for Name: skillfocii; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: weightclass; Type: TABLE DATA; Schema: public; Owner: -
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
-- Name: abbr_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY buttons
    ADD CONSTRAINT abbr_unique UNIQUE (abbr);


--
-- Name: buttons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY buttons
    ADD CONSTRAINT buttons_pkey PRIMARY KEY (id);


--
-- Name: camps_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY camps
    ADD CONSTRAINT camps_name_key UNIQUE (name);


--
-- Name: camps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY camps
    ADD CONSTRAINT camps_pkey PRIMARY KEY (id);


--
-- Name: combo_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY combo
    ADD CONSTRAINT combo_pkey PRIMARY KEY (move_id, button_id, seq);


--
-- Name: country_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_pkey PRIMARY KEY (id);


--
-- Name: fighter_camps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fighter_camps
    ADD CONSTRAINT fighter_camps_pkey PRIMARY KEY (fighter_id, camp_id);


--
-- Name: fighter_moves_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fighter_moves
    ADD CONSTRAINT fighter_moves_pkey PRIMARY KEY (fighter_id, move_id);


--
-- Name: fightercontract_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fightercontract
    ADD CONSTRAINT fightercontract_pkey PRIMARY KEY (id);


--
-- Name: fightercountry_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fightercountry
    ADD CONSTRAINT fightercountry_pkey PRIMARY KEY (id);


--
-- Name: fighternickname_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fighternickname
    ADD CONSTRAINT fighternickname_pkey PRIMARY KEY (id);


--
-- Name: fighterrating_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fighterrating
    ADD CONSTRAINT fighterrating_pkey PRIMARY KEY (id);


--
-- Name: fighterrecords_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fighterrecords
    ADD CONSTRAINT fighterrecords_pkey PRIMARY KEY (id);


--
-- Name: fighters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fighters
    ADD CONSTRAINT fighters_pkey PRIMARY KEY (id);


--
-- Name: fightersource_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fightersource
    ADD CONSTRAINT fightersource_pkey PRIMARY KEY (id);


--
-- Name: move_move_requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY move_move_requirements
    ADD CONSTRAINT move_move_requirements_pkey PRIMARY KEY (move_id, req_move_id);


--
-- Name: moves_camps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY moves_camps
    ADD CONSTRAINT moves_camps_pkey PRIMARY KEY (move_id, camp_id);


--
-- Name: moves_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY moves
    ADD CONSTRAINT moves_pkey PRIMARY KEY (id);


--
-- Name: name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY country
    ADD CONSTRAINT name_unique UNIQUE (name);


--
-- Name: positions_moves_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY positions_moves
    ADD CONSTRAINT positions_moves_pkey PRIMARY KEY (position_id, move_id);


--
-- Name: positions_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT positions_name_key UNIQUE (name);


--
-- Name: positions_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT positions_name_unique UNIQUE (name);


--
-- Name: positions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (id);


--
-- Name: skillfocii_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY skillfocii
    ADD CONSTRAINT skillfocii_pkey PRIMARY KEY (skill_id, focus);


--
-- Name: skills_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY skills
    ADD CONSTRAINT skills_name_unique UNIQUE (name);


--
-- Name: skills_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- Name: source_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fightersource
    ADD CONSTRAINT source_unique UNIQUE (source);


--
-- Name: unique_name; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fighters
    ADD CONSTRAINT unique_name UNIQUE (name);


--
-- Name: weight_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY weightclass
    ADD CONSTRAINT weight_unique UNIQUE (name, lbs);


--
-- Name: weightclass_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY weightclass
    ADD CONSTRAINT weightclass_name_key UNIQUE (name);


--
-- Name: weightclass_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY weightclass
    ADD CONSTRAINT weightclass_pkey PRIMARY KEY (id);


--
-- Name: button_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY combo
    ADD CONSTRAINT button_id_fkey FOREIGN KEY (button_id) REFERENCES buttons(id);


--
-- Name: camp_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fighter_camps
    ADD CONSTRAINT camp_id_fkey FOREIGN KEY (camp_id) REFERENCES camps(id);


--
-- Name: end_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions_moves
    ADD CONSTRAINT end_position_id_fkey FOREIGN KEY (end_position_id) REFERENCES positions(id);


--
-- Name: fighter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fighter_camps
    ADD CONSTRAINT fighter_id_fkey FOREIGN KEY (fighter_id) REFERENCES fighters(id);


--
-- Name: fighter_moves_fighter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fighter_moves
    ADD CONSTRAINT fighter_moves_fighter_id_fkey FOREIGN KEY (fighter_id) REFERENCES fighters(id);


--
-- Name: fightercontract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fightercontract
    ADD CONSTRAINT fightercontract_id_fkey FOREIGN KEY (id) REFERENCES fighters(id);


--
-- Name: fightercountry_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fightercountry
    ADD CONSTRAINT fightercountry_country_fkey FOREIGN KEY (country) REFERENCES country(id);


--
-- Name: fightercountry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fightercountry
    ADD CONSTRAINT fightercountry_id_fkey FOREIGN KEY (id) REFERENCES fighters(id);


--
-- Name: fighternickname_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fighternickname
    ADD CONSTRAINT fighternickname_id_fkey FOREIGN KEY (id) REFERENCES fighters(id);


--
-- Name: fighterrating_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fighterrating
    ADD CONSTRAINT fighterrating_id_fkey FOREIGN KEY (id) REFERENCES fighters(id);


--
-- Name: fighterrecords_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fighterrecords
    ADD CONSTRAINT fighterrecords_id_fkey FOREIGN KEY (id) REFERENCES fighters(id);


--
-- Name: fighters_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fighters
    ADD CONSTRAINT fighters_source_id_fkey FOREIGN KEY (source_id) REFERENCES fightersource(id);


--
-- Name: move_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY move_skill_requirements
    ADD CONSTRAINT move_id_fkey FOREIGN KEY (move_id) REFERENCES moves(id);


--
-- Name: move_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY move_move_requirements
    ADD CONSTRAINT move_id_fkey FOREIGN KEY (move_id) REFERENCES moves(id);


--
-- Name: move_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY combo
    ADD CONSTRAINT move_id_fkey FOREIGN KEY (move_id) REFERENCES moves(id);


--
-- Name: move_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fighter_moves
    ADD CONSTRAINT move_id_fkey FOREIGN KEY (move_id) REFERENCES moves(id);


--
-- Name: position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions_moves
    ADD CONSTRAINT position_id_fkey FOREIGN KEY (position_id) REFERENCES positions(id);


--
-- Name: req_move_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY move_move_requirements
    ADD CONSTRAINT req_move_id_fkey FOREIGN KEY (req_move_id) REFERENCES moves(id);


--
-- Name: skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY skillfocii
    ADD CONSTRAINT skill_id_fkey FOREIGN KEY (skill_id) REFERENCES skills(id);


--
-- Name: skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY move_skill_requirements
    ADD CONSTRAINT skill_id_fkey FOREIGN KEY (skill_id) REFERENCES skills(id);


--
-- Name: valid_camp; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY moves_camps
    ADD CONSTRAINT valid_camp FOREIGN KEY (camp_id) REFERENCES camps(id);


--
-- Name: valid_move; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY moves_camps
    ADD CONSTRAINT valid_move FOREIGN KEY (move_id) REFERENCES moves(id);


--
-- Name: valid_move; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions_moves
    ADD CONSTRAINT valid_move FOREIGN KEY (move_id) REFERENCES moves(id);


--
-- Name: valid_weightclass; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fighters
    ADD CONSTRAINT valid_weightclass FOREIGN KEY (weightclass) REFERENCES weightclass(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

