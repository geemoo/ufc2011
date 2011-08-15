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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: camps; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE camps (
    id integer NOT NULL,
    name character varying
);


ALTER TABLE public.camps OWNER TO jean;

--
-- Name: country; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE country (
    id integer NOT NULL,
    name character varying
);


ALTER TABLE public.country OWNER TO jean;

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
-- Name: fighter_camps; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE fighter_camps (
    fighter_id integer NOT NULL,
    camp_id integer NOT NULL
);


ALTER TABLE public.fighter_camps OWNER TO jean;

--
-- Name: fighters; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE fighters (
    id integer NOT NULL,
    name character varying,
    record character varying,
    nickname character varying,
    weightclass integer,
    country integer
);


ALTER TABLE public.fighters OWNER TO jean;

--
-- Name: weightclass; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE weightclass (
    id integer NOT NULL,
    name character varying,
    lbs integer
);


ALTER TABLE public.weightclass OWNER TO jean;

--
-- Name: fighter_view; Type: VIEW; Schema: public; Owner: jean
--

CREATE VIEW fighter_view AS
    SELECT fighters.name, fighters.record, fighters.nickname, camps.name AS camp, country.name AS country, weightclass.name AS weightclass, weightclass.lbs AS weight FROM ((((fighters LEFT JOIN fighter_camps ON ((fighters.id = fighter_camps.fighter_id))) LEFT JOIN camps ON ((camps.id = fighter_camps.camp_id))) LEFT JOIN country ON ((fighters.country = country.id))) LEFT JOIN weightclass ON ((fighters.weightclass = weightclass.id))) ORDER BY weightclass.id, camps.id;


ALTER TABLE public.fighter_view OWNER TO jean;

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

SELECT pg_catalog.setval('fighters_id_seq', 268, true);


--
-- Name: fightersource; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE fightersource (
    id integer NOT NULL,
    source character varying
);


ALTER TABLE public.fightersource OWNER TO jean;

--
-- Name: fightersource_fighters; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE fightersource_fighters (
    fightersource_id integer NOT NULL,
    fighter_id integer NOT NULL
);


ALTER TABLE public.fightersource_fighters OWNER TO jean;

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

SELECT pg_catalog.setval('fightersource_id_seq', 4, true);


--
-- Name: moves; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE moves (
    id integer NOT NULL,
    name character varying,
    reqskill character varying,
    reqskilllevel integer,
    reqmove integer,
    reqstring character varying
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
    name character varying
);


ALTER TABLE public.positions OWNER TO jean;

--
-- Name: positions_moves; Type: TABLE; Schema: public; Owner: jean; Tablespace: 
--

CREATE TABLE positions_moves (
    position_id integer NOT NULL,
    move_id integer NOT NULL,
    end_position_id integer
);


ALTER TABLE public.positions_moves OWNER TO jean;

--
-- Name: position_move_camp_view; Type: VIEW; Schema: public; Owner: jean
--

CREATE VIEW position_move_camp_view AS
    WITH RECURSIVE x(_move, _length, _count, _number, camp) AS (WITH y(_move, _length, _count, _number, camp) AS (WITH move_camp(move, camp) AS (SELECT moves_camps.move_id, camps.name FROM (moves_camps JOIN camps ON ((moves_camps.camp_id = camps.id)))) SELECT move_camp.move, 1, count(*) OVER (move_window) AS count, row_number() OVER (move_window) AS row_number, move_camp.camp FROM move_camp WINDOW move_window AS (PARTITION BY move_camp.move)) SELECT y._move, y._length, y._count, y._number, y.camp FROM y UNION SELECT x._move, (x._length + 1), x._count, x._number, (((x.camp)::text || ', '::text) || (y.camp)::text) FROM (x JOIN y ON (((y._move = x._move) AND (x._length = y._number))))) SELECT a.name AS start_position, moves.name AS move, b.name AS end_position, x.camp, x._length AS camp_count, moves.reqskill, moves.reqskilllevel, moves.reqmove, moves.reqstring FROM ((((positions_moves JOIN moves ON ((positions_moves.move_id = moves.id))) JOIN positions a ON ((positions_moves.position_id = a.id))) JOIN positions b ON ((positions_moves.end_position_id = b.id))) LEFT JOIN x ON ((moves.id = x._move))) WHERE ((x._count = x._length) AND (x._count = x._number)) ORDER BY a.id, moves.id, x._length;


ALTER TABLE public.position_move_camp_view OWNER TO jean;

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
\.


--
-- Data for Name: fighters; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY fighters (id, name, record, nickname, weightclass, country) FROM stdin;
5	Anderson Silva	13–0	The Spider	5	5
30	Kyle Noke	3–0	KO	5	2
46	Yves Edwards	8–5	Thugjitsu Master	3	3
3	Vitor Belfort	9–5	The Phenom	5	5
18	Wanderlei Silva	3–6	The Axe Murderer	5	5
22	Rousimar Palhares	5–2	Toquinho	5	5
29	Jorge Santiago	1–3	The Sandman	5	5
32	Rafael Natal	1–1–1	Sapo	5	5
44	Gleison Tibau	9–5	Tibau	3	5
79	Rafaello Oliveira	1–3	Tractor	3	5
82	Edson Barboza	2–0	Junior	3	5
10	Jason MacDonald	6–6	The Athlete	5	7
35	Nick Ring	2–0	The Promise	5	7
53	Sam Stout	6–5	Hands of Stone	3	7
38	Constantinos Philippou	1–1	Costa	5	11
2	Michael Bisping	11–3	The Count	5	15
66	Paul Taylor	4–5	Relentless	3	15
88	Paul Sass	1–0	Sassangle	3	15
76	Kamal Shalorus	3–1–1	Prince of Persia	3	19
9	Alessio Sakara	6–5 (1 NC)	Legionarius	5	20
7	Yushin Okami	10–2	Thunder	5	21
27	Yoshihiro Akiyama	1–3	Sexyama	5	21
41	Riki Fukuda	0–1	Killer Bee	5	21
39	Dongi Yang	1–1	The Ox	5	27
20	C.B. Dollaway	5–3	The Doberman	5	29
21	Steve Cantwell	4–4	The Robot	5	29
23	Tim Boetsch	4–3	The Barbarian	5	29
24	Nick Catone	3–2	The Jersey Devil	5	29
25	Tim Credeur	3–2	Crazy	5	29
26	Tom Lawlor	3–2	Filthy	5	29
28	Mike Massenzio	1–3	The Master of Disaster	5	29
33	Jared Hamman	1–2	The Messenger	5	29
34	Court McGee	2–0	The Crusher	5	29
36	Chris Weidman	2–0	The All-American	5	29
37	Jason Miller	1–1	Mayhem	5	29
40	Paul Bradley	0–1	The Gentleman	5	29
51	Jeremy Stephens	7–5	Lil' Heathen	3	29
52	Matt Wiman	7–4	Handsome	3	29
95	Georges St-Pierre	16–2	Rush	4	7
99	Thiago Alves	10–5	Pitbull	4	5
146	Erick Silva	0–0	Indio	4	5
160	Luiz Cane	4–3	Banha	6	5
162	Mauricio Rua	3–3	Shogun	6	5
168	Antonio Rogerio Nogueira	2–2	Little Nog	6	5
175	Ronny Markes	0–0	Markes	6	5
181	Junior Dos Santos	7–0	Cigano	7	5
176	Stanislav Nedkov	0–0	Staki	6	6
125	Rory MacDonald	3–1	Ares	4	7
129	Sean Pierson	1–1	Pimp Daddy	4	7
179	Mirko Cro Cop	4–5	Cro Cop	7	9
102	Martin Kampmann	8–4	Hitman	4	13
126	James Wilks	2–2	Lightning	4	15
140	Mark Scanlon	0–1	Scanno	4	15
178	Cheick Kongo	9–4–1	Kongo	7	16
136	Pascal Krauss	1–0	Panzer	4	17
180	Stefan Struve	5–3	Skyscraper	7	22
110	Dong Hyun Kim	5–1 (1 NC)	Stun Gun	4	27
141	Papy Abedi	0–0	Makambo	4	28
94	Chris Lytle	9–10	Lights Out	4	29
57	Joe Lauzon	7–3	J-Lau	3	29
62	Danny Castillo	6–3	Last Call	3	29
63	Cole Miller	6–3	Magrinho	3	29
68	Ben Henderson	6–1	Smooth	3	29
78	Charles Oliveira	2–1 (1 NC)	do Bronx	3	5
83	John Makdessi	2–0	The Bull	3	7
75	Ross Pearson	4–1	The Real Deal	3	15
81	Takanori Gomi	1–2	The Fireball Kid	3	21
59	Anthony Njokuani	6–4	The Assassin	3	24
42	Melvin Guillard	10–4	The Young Assassin	3	29
43	Clay Guida	9–5	The Carpenter	3	29
47	Spencer Fisher	7–6	The King	3	29
48	Donald Cerrone	8–3 (1 NC)	The Cowboy	3	29
49	Sean Sherk	8–4	The Muscle Shark	3	29
169	Anthony Perosh	1–3	The Hippo	6	2
154	Vladimir Matyushenko	7–3	The Janitor	6	4
130	Carlos Eduardo Rocha	1–1	Ta Danado	4	5
153	Lyoto Machida	9–2	The Dragon	6	5
127	Claude Patrick	3–0	The Prince	4	7
167	Igor Pokrajac	2–3	The Duke	6	9
174	Karlos Vemola	1–1	The Terminator	6	12
113	Dan Hardy	4–3	The Outlaw	4	15
115	John Hathaway	5–1	The Hitman	4	15
170	Cyrille Diabate	2–1	The Snake	6	16
157	Krzysztof Soszynski	6–2	The Polish Experiment	6	25
164	Alexander Gustafsson	4–1	The Mauler	6	28
55	Gray Maynard	8–0–1 (1 NC)	The Bully	3	29
69	Nik Lentz	5–0–1 (1 NC)	The Carny	3	29
61	George Sotiropoulos	7–2	\N	3	2
6	Royce Gracie	11–1–1	\N	5	5
11	Demian Maia	8–3	\N	5	5
70	Anthony Pettis	5–2	Showtime	3	29
77	Jacob Volkmann	3–2	Christmas	3	29
80	Dan Downes	1–2	Danny Boy	3	29
85	Cody McKenzie	1–1	Big Time	3	29
86	Edward Faaloloto	0–2	FaloFalo	3	29
96	Josh Koscheck	13–5	Kos	4	29
239	José Aldo	9–0	Junior	2	5
189	Minotauro Nogueira	3–2	Minotauro	7	5
219	Renan Barão	3–0	Barão	1	5
261	Yuri Alcantara	1–0	Marajó	2	5
265	Felipe Arantes	0–0	Sertanejo	2	5
145	Luis Ramos	0–0	Beicao	4	5
266	Antonio Carvalho	0–0	Pato	2	7
249	Javier Vazquez	3–3	Showtime	2	10
217	Ivan Menjivar	2–2	Pride of El Salvador	1	14
215	Brad Pickett	3–1	One-Punch	1	15
264	Jason Young	0–1	Shotgun	2	15
218	Yves Jabouin	1–3	Tiger	1	18
230	Norifumi Yamamoto	0–1	Kid	1	21
268	Hatsu Hioki	0–0	Iron Broom	2	21
195	Mark Hunt	1–1	Super Samoan	7	23
246	Bart Palaszewski	4–3	Bartimus	2	25
1	Chris Leben	12–6	The Crippler	5	29
4	Jorge Rivera	7–7	El Conquistador	5	29
8	Brian Stann	9–3	All American	5	29
101	Mike Swick	9–3	Quick	4	29
106	Anthony Johnson	6–3	Rumble	4	29
109	Dennis Hallman	3–5	Superman	4	29
114	Mike Pyle	4–3	Quicksand	4	29
117	DaMarques Johnson	3–3	Darkness	4	29
118	Daniel Roberts	3–3	Ninja	4	29
122	Duane Ludwig	3–2	Bang	4	29
128	Brian Ebersole	2–0	Bad Boy	4	29
132	TJ Waldburger	1–1	TJ	4	29
134	Chris Cope	1–0	C-Murder	4	29
135	Clay Harvison	1–0	Heavy Metal	4	29
137	Justin Edwards	0–1	Fast Eddie	4	29
139	David Mitchell	0–1	Daudi	4	29
143	Jorge Lopez	0–0	Lil' Monster	4	29
185	Pat Barry	3–3	HD	7	29
186	Matt Mitrione	5–0	Meathead	7	29
191	Roy Nelson	2–2	Big Country	7	29
193	Travis Browne	2–0–1	Hapa	7	29
196	Ben Rothwell	1–1	Big	7	29
198	Dave Herman	1–0	Pee-Wee	7	29
199	Aaron Rosa	0–1	Big Red	7	29
204	Scott Jorgensen	8–3	Young Guns	1	29
208	Joseph Benavidez	6–2	Joe-B-Wan Kenobi	1	29
213	Jeff Curran	1–5	Big Frog	1	29
214	Demetrious Johnson	4–1	Mighty Mouse	1	29
216	Chris Cariaso	2–2	Kamikaze	1	29
87	Tony Ferguson	1–0	El Cucuy	3	29
90	T.J. O'Brien	0–1	The Spider	3	29
93	B.J. Penn	12–6–2	The Prodigy	4	29
97	Diego Sanchez	12–4	The Dream	4	29
238	Manny Gamburyan	5–5	The Anvil	2	1
245	Diego Nunes	5–2	The Gun	2	5
240	Mark Hominick	6–3	The Machine	2	7
257	Tiequan Zhang	2–1	The Mongolian Wolf	2	8
197	Rob Broughton	1–0	The Bear	7	15
258	Chan Sung Jung	1–2	The Korean Zombie	2	27
100	Matt Serra	7–7	The Terror	4	29
103	Carlos Condit	9–1	The Natural Born Killer	4	29
107	Matt Brown	5–4	The Immortal	4	29
108	Rick Story	6–2	The Horror	4	29
120	Jake Ellenberger	4–1	The Juggernaut	4	29
121	Brian Foster	3–2	The Foster Boy	4	29
123	Rich Attonito	3–1	The Raging Bull	4	29
124	Charlie Brenneman	3–1	The Spaniard	4	29
147	Tito Ortiz	15–9–1	The Huntington Beach Bad Boy	6	29
183	Shane Carwin	4–2	The Engineer	7	29
187	Brendan Schaub	4–1	The Hybrid	7	29
188	Joey Beltran	3–2	The Mexicutioner	7	29
190	Heath Herring	2–3	The Texas Crazy Horse	7	29
203	Urijah Faber	9–4	The California Kid	1	29
212	Damacio Page	3–3	The Angel of Death	1	29
72	Aaron Riley	3–4	\N	3	29
89	Ramsey Nijem	0–1	\N	3	29
92	Matt Hughes	18–6	\N	4	29
98	Jon Fitch	13–1–1	\N	4	29
200	Philip De Fries	0–0	\N	7	15
73	Evan Dunham	4–2	3D	3	29
220	Michael McDonald	3–0	Mayday	1	29
222	Reuben Duran	1–1	Hurricane	1	29
226	Jeff Hougland	1–0	Hellbound	1	29
227	Cole Escovedo	0–1	Apache Kid	1	29
229	Donny Walker	0–1	Eagle Eye	1	29
234	Kenny Florian	12–4	KenFlo	2	29
236	Leonard Garcia	6–6–1	Bad Boy	2	29
242	Cub Swanson	5–3	Cub	2	29
247	Chad Mendes	6–0	Money	2	29
250	Erik Koch	4–1	New Breed	2	29
262	Alex Caceres	0–1	Bruce Leroy	2	29
267	Jimy Hettes	0–0	The Kid	2	29
156	Jon Jones	7–1	Bones	6	29
206	Dominick Cruz	8–1	Dominator	1	29
12	Alan Belcher	7–4	The Talent	5	29
14	Mark Muñoz	8–2	The Filipino Wrecking Machine	5	29
15	Nate Quarry	7–3	Rock	5	29
16	Ed Herman	5–5	Short Fuse	5	29
19	Aaron Simpson	6–2	A-Train	5	29
148	Rich Franklin	13–5	Ace	6	29
149	Rashad Evans	11–1–1	Suga	6	29
155	Rampage Jackson	7–2	Rampage	6	29
159	Ryan Bader	5–2	Darth	6	29
163	Phil Davis	5–0	Mr. Wonderful	6	29
165	Kyle Kingsbury	4–1	Kingsbu	6	29
56	Frankie Edgar	8–1–1	The Answer	3	29
84	Michael Johnson	1–1	The Menace	3	29
223	Ian Loveland	1–1	The Barn Owl	1	29
228	Edwin Figueroa	0–1	El Feroz	1	29
231	Mike Easton	0–0	The Hulk	1	29
244	Ricardo Lamas	5–2	The Bully	2	29
248	Josh Grispi	4–2	The Fluke	2	29
251	Mackens Semerzier	2–3	da Menace	2	29
252	Matt Grice	1–4	The Real One	2	29
253	Dustin Poirier	3–1	The Diamond	2	29
255	Darren Elkins	2–1	The Damage	2	29
256	Pablo Garza	2–1	The Scarecrow	2	29
151	Brandon Vera	7–5 (1 NC)	The Truth	6	29
152	Stephan Bonnar	7–6	The American Psycho	6	29
161	Jason Brilz	3–3	The Hitman	6	29
166	Eliot Marshall	3–2	The Fire	6	29
60	Thiago Tavares	5–4–1	\N	3	5
71	Rafael Dos Anjos	4–3	\N	3	5
91	Vagner Rocha	0–1	\N	3	5
64	Mark Bocek	5–4	\N	3	7
74	TJ Grant	3–3	\N	3	7
67	Terry Etim	5–3	\N	3	15
50	Dennis Siver	8–4	\N	3	26
31	Brad Tavares	2–1	\N	5	29
45	Nate Diaz	8–5	\N	3	29
54	Jim Miller	9–1	\N	3	29
119	Paulo Thiago	3–3	\N	4	5
158	Thiago Silva	5–2 (1 NC)	\N	6	5
171	Fabio Maldonado	1–1	\N	6	5
144	Che Mills	0–0	\N	4	15
173	James Te Huna	1–1	\N	6	23
58	Shane Roller	7–3	\N	3	29
65	Mac Danzig	4–5	\N	3	29
202	Oli Thompson	0–0	\N	7	15
211	Raphael Assunção	3–3	\N	1	5
232	Johnny Eduardo	0–0	\N	1	5
241	Rani Yahya	5–4	\N	2	5
233	Vaughan Lee	0–0	\N	1	15
210	Takeya Mizugaki	3–4	\N	1	21
254	Michihiro Omigawa	0–4	\N	2	21
184	Brock Lesnar	4–2	\N	7	29
104	Nick Diaz	6–4	\N	4	29
105	Johny Hendricks	8–1	\N	4	29
111	Matthew Riddle	5–2	\N	4	29
112	Amir Sadollah	5–2	\N	4	29
116	Mike Pierce	4–2	\N	4	29
131	Jake Shields	1–1	\N	4	29
133	Shamar Bailey	1–0	\N	4	29
138	James Head	0–1	\N	4	29
142	Lance Benoist	0–0	\N	4	29
172	Ricardo Romero	1–1	\N	6	29
177	Frank Mir	13–5	\N	7	29
192	Mike Russow	3–0	\N	7	29
194	Christian Morecraft	1–2	\N	7	29
201	Stipe Miocic	0–0	\N	7	29
205	Miguel Angel Torres	7–3	\N	1	29
207	Brian Bowles	7–1	\N	1	29
209	Eddie Wineland	5–3	\N	1	29
221	Nick Pace	1–2	\N	1	29
224	Jason Reinhardt	0–2	\N	1	29
225	Ken Stone	0–2	\N	1	29
235	Tyson Griffin	8–5	\N	2	29
237	Mike Brown	7–5	\N	2	29
243	George Roop	3–4–1	\N	2	29
259	Jonathan Brookins	1–1	\N	2	29
260	Nam Phan	0–2	\N	2	29
263	Mike Lullo	0–1	\N	2	29
182	Cain Velasquez	7–0	\N	7	29
13	Chael Sonnen	6–5	\N	5	29
17	Dan Miller	5–4	\N	5	29
150	Forrest Griffin	9–4	\N	6	29
\.


--
-- Data for Name: fightersource; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY fightersource (id, source) FROM stdin;
3	Game
4	Player
\.


--
-- Data for Name: fightersource_fighters; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY fightersource_fighters (fightersource_id, fighter_id) FROM stdin;
3	30
3	61
3	46
3	3
3	5
3	6
3	11
3	18
3	22
3	29
3	32
3	44
3	60
3	71
3	78
3	79
3	82
3	91
3	10
3	35
3	53
3	64
3	74
3	83
3	38
3	2
3	66
3	67
3	75
3	88
3	76
3	9
3	7
3	27
3	41
3	81
3	59
3	50
3	39
3	169
3	154
3	99
3	119
3	130
3	146
3	153
3	158
3	160
3	162
3	168
3	171
3	175
3	181
3	176
3	95
3	125
3	127
3	129
3	167
3	179
3	174
3	102
3	113
3	115
3	126
3	140
3	144
3	170
3	178
3	136
3	180
3	173
3	157
3	110
3	141
3	164
3	94
3	238
3	189
3	211
3	219
3	232
3	239
3	241
3	245
3	261
3	265
3	145
3	240
3	266
3	257
3	249
3	217
3	197
3	200
3	202
3	215
3	233
3	264
3	218
3	210
3	230
3	254
3	268
3	195
3	246
3	258
3	1
3	4
3	8
3	184
3	12
3	13
3	14
3	15
3	16
3	17
3	19
3	20
3	21
3	23
3	24
3	25
3	26
3	28
3	31
3	33
3	34
3	36
3	37
3	40
3	42
3	43
3	45
3	47
3	48
3	49
3	51
3	52
3	54
3	55
3	56
3	57
3	58
3	62
3	63
3	65
3	68
3	69
3	70
3	72
3	73
3	77
3	80
3	84
3	85
3	86
3	87
3	89
3	90
3	92
3	93
3	96
3	97
3	98
3	100
3	101
3	103
3	104
3	105
3	106
3	107
3	108
3	109
3	111
3	112
3	114
3	116
3	117
3	118
3	120
3	121
3	122
3	123
3	124
3	128
3	131
3	132
3	133
3	134
3	135
3	137
3	138
3	139
3	142
3	143
3	147
3	148
3	149
3	150
3	151
3	152
3	155
3	156
3	159
3	161
3	163
3	165
3	166
3	172
3	177
3	182
3	183
3	185
3	186
3	187
3	188
3	190
3	191
3	192
3	193
3	194
3	196
3	198
3	199
3	201
3	203
3	204
3	205
3	206
3	207
3	208
3	209
3	212
3	213
3	214
3	216
3	220
3	221
3	222
3	223
3	224
3	225
3	226
3	227
3	228
3	229
3	231
3	234
3	235
3	236
3	237
3	242
3	243
3	244
3	247
3	248
3	250
3	251
3	252
3	253
3	255
3	256
3	259
3	260
3	262
3	263
3	267
\.


--
-- Data for Name: moves; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY moves (id, name, reqskill, reqskilllevel, reqmove, reqstring) FROM stdin;
1	German Suplex to Back Side Control Offense	\N	\N	\N	Suplex to Side Control Offense
2	Lift Up Slam to Side Control Offense	\N	\N	\N	None
3	Pummel to Double Underhook Defense	\N	\N	\N	None
4	Transition to Both Standing	\N	\N	\N	None
5	Back Throw to Side Control Right Offense	\N	\N	\N	None
6	German Suplex to Back Side Control Offense	\N	\N	\N	Suplex to Side Control Offense
7	Pull to Side Control	\N	\N	\N	None
8	Transition to Both Standing	\N	\N	\N	None
9	Arm Trap Rear Naked Choke	\N	\N	\N	Submission Offense of 60
10	Armbar from Back Mount Face Up Top	\N	\N	\N	None
11	Rear Naked Choke	\N	\N	\N	None
12	Strong Right Hook	\N	\N	\N	None
13	Transition to Back Mount Face Up Body Triangle Top	\N	\N	\N	None
14	Transition to Mount Top	\N	\N	\N	None
15	Rear Naked Choke from Back Mount Rocked	\N	\N	\N	None
16	Arm Trap Rear Naked Choke	\N	\N	\N	Submission Offense of 60
17	Armbar from Back Mount Top	\N	\N	\N	None
18	Rear Naked Choke Facing Downward	\N	\N	\N	None
19	Strong Hook	\N	\N	\N	None
20	Transition to Both Standing	\N	\N	\N	None
21	Transition to Open Guard Bottom	\N	\N	\N	None
22	Arm Trap Rear Naked Choke	\N	\N	\N	Submission Offense of 60
23	Rear Naked Choke	\N	\N	\N	None
24	Arm Trap Rear Naked Choke	\N	\N	\N	Submission Offense of 60
25	Armbar from Back Side Control Top	\N	\N	\N	None
26	Peruvian Neck Tie	\N	\N	\N	Submission Offense of 60
27	Rear Naked Choke	\N	\N	\N	None
28	Strong Hook	\N	\N	\N	None
29	Strong Knee to Abdomen	\N	\N	\N	None
30	Transition to Back Mount Face Up Top	\N	\N	\N	None
31	Transition to Back Mount Top	\N	\N	\N	None
32	Pull Guard to Open Guard Down Defense	\N	\N	\N	Clinch to Body Lock Offense
33	Suplex to Side Control Offense	\N	\N	\N	Clinch to Body Lock Offense
34	Judo Hip Throw to Side Control Offense	\N	\N	\N	Clinch to Body Lock Offense
35	Pull Guard to Open Guard Down Defense	\N	\N	\N	Clinch to Body Lock Offense
36	Suplex to Half Guard Down Offense	\N	\N	\N	Clinch to Body Lock Offense
37	Suplex to Side Control Offense	\N	\N	\N	Clinch to Body Lock Offense
38	Inside Left Uppercut	\N	\N	\N	None
39	Inside Right Uppercut	\N	\N	\N	None
40	Left Leg Kick	\N	\N	\N	None
41	Left Muay Thai Elbow	\N	\N	\N	None
42	Left Short Uppercut From Sway Forward	\N	\N	\N	None
43	Right Chopping Hook	\N	\N	\N	None
44	Right Dodge Knee to the Body	\N	\N	\N	None
45	Right Leg Kick	\N	\N	\N	None
46	Right Muay Thai Elbow	\N	\N	\N	None
47	Right Short Uppercut from Sway Forward	\N	\N	\N	None
48	Strong Left Leg Kick	\N	\N	\N	None
49	Strong Right Leg Kick	\N	\N	\N	None
50	Backstep Right Hook from Switch Stance	\N	\N	\N	None
51	Backstepping Right Straight	\N	\N	\N	None
52	Brock's Right Straight	\N	\N	\N	None
53	Caol's Back Spin Kick	\N	\N	\N	None
54	Caol's Left Side Kick	\N	\N	\N	None
55	Check Head Kick	\N	\N	\N	None
56	Chuck's Right Straight	\N	\N	\N	None
57	Ducking Left Hook	\N	\N	\N	None
58	Ducking Right Hook	\N	\N	\N	None
59	Forrest's Left Front Kick	\N	\N	\N	None
60	Forrest's Left Head Kick	\N	\N	\N	None
61	GSP's Head Kick	\N	\N	\N	None
62	Hendo's Right Back Fist	\N	\N	\N	None
63	Hendo's Right Strong Straight	\N	\N	\N	None
64	Jardine's Right Superman Punch	\N	\N	\N	None
65	Jon Jones' Right Back Fist	\N	\N	\N	None
66	Left Axe Kick	\N	\N	\N	None
67	Left Back Fist	\N	\N	\N	None
68	Left Front Upward Kick	\N	\N	\N	None
69	Left Flicking Jab	\N	\N	\N	None
70	Left Guarded Hook	\N	\N	\N	None
71	Left Head Kick	\N	\N	\N	None
72	Left High Front Kick	\N	\N	\N	None
73	Left Hook from Sway Back	\N	\N	\N	None
74	Left Hook from Sway Forward	\N	\N	\N	None
75	Left Hook from Sway Left	\N	\N	\N	None
76	Left Hook from Sway Right	\N	\N	\N	None
77	Left Jab to Sway Back	\N	\N	\N	None
78	Left Jumping Front Kick	\N	\N	\N	None
79	Left Long Superman Punch	\N	\N	\N	None
80	Left Muay Thai Head Kick	\N	\N	\N	None
81	Left Muay Thai Leg Kick	\N	\N	\N	None
82	Left Muay Thai Push Kick	\N	\N	\N	None
83	Left Over Hook	\N	\N	\N	None
84	Left Over Strong Hook	\N	\N	\N	None
85	Left Punch from Kick Catch	\N	\N	\N	None
86	Left Quick Superman Punch	\N	\N	\N	None
87	Left Side Kick	\N	\N	\N	None
88	Left Side Kick to Body	\N	\N	\N	None
89	Left Sidestepping Upper Jab	\N	\N	\N	None
90	Left Spinning Back Fist	\N	\N	\N	None
91	Left Spinning Back Kick	\N	\N	\N	None
92	Left Strong Uppercut	\N	\N	\N	None
93	Left Undercut	\N	\N	\N	None
94	Left Upper Jab	\N	\N	\N	None
95	Left Uppercut	\N	\N	\N	None
96	Lunging Left Hook	\N	\N	\N	None
97	Lunging Right Hook	\N	\N	\N	None
98	Lyoto's Left Head Kick	\N	\N	\N	None
99	Lyoto's Right Straight	\N	\N	\N	None
100	Lyoto's Stepping Straight	\N	\N	\N	None
101	Napao's Right Head Kick	\N	\N	\N	None
102	One Feint Head Kick	\N	\N	\N	None
103	Overhand Left from Sway Forward	\N	\N	\N	None
104	Overhand Right	\N	\N	\N	None
105	Overhand Right from Sway Forward	\N	\N	\N	None
106	Overhand Right Hook from Sway Forward	\N	\N	\N	None
107	Quick Head Kick	\N	\N	\N	None
108	Right Axe Kick	\N	\N	\N	None
109	Right Back Fist	\N	\N	\N	None
110	Right Back Kick	\N	\N	\N	None
111	Right Brazilian Head Kick	\N	\N	\N	None
112	Right Ducking Uppercut to Head	\N	\N	\N	None
113	Right Flying Head Kick	\N	\N	\N	None
114	Right Flying Knee	\N	\N	\N	None
115	Right Front Upper Kick	\N	\N	\N	None
116	Right Guarded Hook	\N	\N	\N	None
117	Right Head Kick	\N	\N	\N	None
118	Right High Front Kick	\N	\N	\N	None
119	Right High Kick	\N	\N	\N	None
120	Right Hook from Sway Back	\N	\N	\N	None
121	Right Hook from Sway Left	\N	\N	\N	None
122	Right Hook From Sway Right	\N	\N	\N	None
123	Right Karate Back Spin Kick	\N	\N	\N	None
124	Right Karate Front Kick	\N	\N	\N	None
125	Right Karate Straight	\N	\N	\N	None
126	Right Long Straight	\N	\N	\N	None
127	Right Long Superman Punch	\N	\N	\N	None
128	Right Long Uppercut	\N	\N	\N	None
129	Right Over Hook	\N	\N	\N	None
130	Right MMA Back Spin Kick	\N	\N	\N	None
131	Right Muay Thai Head Kick	\N	\N	\N	None
132	Right Muay Thai Leg Kick	\N	\N	\N	None
133	Right Muay Thai Push Kick	\N	\N	\N	None
134	Right Muay Thai Snap Kick	\N	\N	\N	None
135	Right Punch from Kick Catch	\N	\N	\N	None
136	Right Spinning Back Elbow	\N	\N	\N	None
137	Right Spinning Back Fist	\N	\N	\N	None
138	Right Spinning Back Kick	\N	\N	\N	None
139	Right Strong Straight	\N	\N	\N	None
140	Right Strong Uppercut	\N	\N	\N	None
141	Right Superman Punch	\N	\N	\N	None
142	Right Uppercut	\N	\N	\N	None
143	Shogun's Stepping Left Hook	\N	\N	\N	None
144	Shoot to Double Leg Takedown	\N	\N	\N	None
145	Step Right Knee	\N	\N	\N	None
146	Stepping Heavy Jab	\N	\N	\N	None
147	Stepping Over Left Hook	\N	\N	\N	None
148	Stepping Right Undercut	\N	\N	\N	None
149	Stepping Right Uppercut	\N	\N	\N	None
150	Strong Left Leg Kick	\N	\N	\N	None
151	Strong Right Leg Kick	\N	\N	\N	None
152	Switch Left Head Kick	\N	\N	\N	None
153	Two Step Left Flying Knee	\N	\N	\N	None
154	Two Step Right Flying Knee	\N	\N	\N	None
155	Two Step Right Middle Kick	\N	\N	\N	None
156	Weaving Overhand Right	\N	\N	\N	None
157	Gogoplata from Butterfly Guard	\N	\N	\N	Transition to Butterfly Guard Bottom and Submission Offense 70
158	Transition to Open Guard Down Bottom	\N	\N	\N	Transition to Butterfly Guard Bottom
159	Transition to Up/Down Bottom	\N	\N	\N	Transition to Butterfly Guard Bottom
160	Triangle Choke from Butterfly Guard	\N	\N	\N	Transition to Butterfly Guard Bottom
161	Transition to Half Guard Down Top	\N	\N	\N	Transition to Butterfly Guard Bottom
162	Transition to Open Guard Top	\N	\N	\N	Transition to Butterfly Guard Bottom
163	Transition to Side Control Top	\N	\N	\N	Transition to Butterfly Guard Bottom
164	Slam to Open Guard Down Offense	\N	\N	\N	None
165	Left Turn Off to Double Underhook Defense	\N	\N	\N	None
166	Clinch to Body Lock Cage Offense	\N	\N	\N	None
167	Pull Guard to Open Guard Down Defense	\N	\N	\N	None
168	Suplex to Side Control Offense	\N	\N	\N	None
169	Judo Hip Throw to Side Control Offense	\N	\N	\N	None
170	Pummel to Double Underhook Offense	\N	\N	\N	None
171	Pummel to Single Collar Tie	\N	\N	\N	None
172	Clinch to Body Lock Offense	\N	\N	\N	None
173	Pull Guard to Open Guard Down Defense	\N	\N	\N	None
174	Suplex to Side Control Offense	\N	\N	\N	None
175	Strike Catch to Armbar	\N	\N	\N	None
176	Strike Catch to Kimura	\N	\N	\N	None
177	Transition to Half Guard Down Bottom	\N	\N	\N	None
178	Transition to Open Guard Bottom	\N	\N	\N	None
179	Transition to Up/Down Bottom	\N	\N	\N	None
180	Cage Transition to Half Guard Down Bottom	\N	\N	\N	None
181	Kimura	\N	\N	\N	None
182	Transition to Butterfly Guard Bottom	\N	\N	\N	None
183	Transition to Open Guard Down Bottom	\N	\N	\N	None
184	Transition to Up/Down Bottom	\N	\N	\N	None
185	Americana from Half Guard Top	\N	\N	\N	None
186	Kimura from Half Guard Top	\N	\N	\N	None
187	Transition to Mount Down Top	\N	\N	\N	None
188	Transition to Side Control Top	\N	\N	\N	None
189	Americana from Half Guard Rocked Top	\N	\N	\N	None
190	D'arce Choke	\N	\N	\N	None
191	Kimura from Half Guard Top	\N	\N	\N	None
192	Americana from Half Guard Top	\N	\N	\N	None
193	Elbow	\N	\N	\N	None
194	Hammer Fist	\N	\N	\N	None
195	Kimura from Half Guard Top	\N	\N	\N	None
196	Kneebar from Half Guard Top	\N	\N	\N	None
198	Strong Hook	\N	\N	\N	None
199	Toe Hold from Half Guard Top	\N	\N	\N	None
200	Transition to Mount Down Top	\N	\N	\N	None
201	Transition to Mount Top	\N	\N	\N	None
202	Transition to Side Control Top	\N	\N	\N	None
203	Transition to Half Guard Bottom	\N	\N	\N	None
204	Transition to Mount Down Bottom	\N	\N	\N	None
205	Cage Transition to Mount Down Top	\N	\N	\N	None
206	Transition to Half Guard Down Bottom	\N	\N	\N	None
207	Transition to Open Guard Down Top	\N	\N	\N	Ground Grapple Offense 60
208	Arm Triangle Choke from Mount Top	\N	\N	\N	None
209	Ground Buster from Mount Down Top	\N	\N	\N	None
210	Transition to Open Guard Down Top	\N	\N	\N	Ground Grapple Offense 60
211	Armbar from Mount Rocked Top	\N	\N	\N	None
212	Arm Triangle Choke from Mount Top	\N	\N	\N	None
213	Armbar from Mount Top	\N	\N	\N	None
214	Elbow	\N	\N	\N	None
215	Strong Hook	\N	\N	\N	None
216	Rear Leg Knee	\N	\N	\N	None
217	Strong Knee	\N	\N	\N	None
218	Pummel to Muay Thai Clinch Offense	\N	\N	\N	None
219	Pummel to Over/Under Hook	\N	\N	\N	None
220	Arcing Elbow	\N	\N	\N	None
221	Knee	\N	\N	\N	None
222	Knee to Body	\N	\N	\N	None
223	Pull Guard to Open Guard Down Defense	\N	\N	\N	None
224	Rear Leg Knee	\N	\N	\N	None
225	Strong Knee	\N	\N	\N	None
226	Uppercut	\N	\N	\N	None
227	Armbar from North/South Top	\N	\N	\N	None
228	North/South Choke from North/South Top	\N	\N	\N	None
229	Transition to Mount Down Top	\N	\N	\N	None
230	Strike Catch to Armbar	\N	\N	\N	None
231	Strike Catch to Kimura	\N	\N	\N	None
232	Strike Catch to Omoplata	\N	\N	\N	Submission Offense 60
233	Strike Catch to Triangle Choke	\N	\N	\N	None
234	Transition to Open Guard Down Bottom	\N	\N	\N	None
235	Transition to Up/Down Bottom	\N	\N	\N	None
236	Kimura	\N	\N	\N	None
237	Omoplata	\N	\N	\N	Submission Offense 60
238	Transition to Rubber Guard Down Bottom	\N	\N	\N	None
239	Transition to Up/Down Bottom	\N	\N	\N	None
240	Triangle Choke	\N	\N	\N	None
241	Transition to Half Guard Down Top	\N	\N	\N	None
242	Transition to Side Control Top	\N	\N	\N	None
243	Achilles Lock	\N	\N	\N	None
244	Heel Hook	\N	\N	\N	None
245	Kneebar	\N	\N	\N	None
246	Toe Hold	\N	\N	\N	None
247	Achilles Lock from Open Guard Top	\N	\N	\N	None
248	Elbow	\N	\N	\N	None
249	Heel Hook from Open Guard Top	\N	\N	\N	None
250	Kneebar from Open Guard Top	\N	\N	\N	None
251	Strong Hook	\N	\N	\N	None
252	Toe Hold from Open Guard Top	\N	\N	\N	None
253	Transition to Half Guard Down Top	\N	\N	\N	None
254	Transition to Half Guard Top	\N	\N	\N	None
255	Transition to Side Control Top	\N	\N	\N	None
256	Ouchi Gari to Open Guard Down Offense	\N	\N	\N	Suplex to Side Control Offense
257	Pummel to Double Underhook Cage Offense	\N	\N	\N	None
258	Takedown to Half Guard Down Offense	\N	\N	\N	Suplex to Side Control Offense
259	Hip Throw to Side Control Offense	\N	\N	\N	Suplex to Side Control Offense
260	Pull Guard to Open Guard Down Defense	\N	\N	\N	Suplex to Side Control Offense
261	Pummel to Double Underhook Offense	\N	\N	\N	None
262	Gogoplata from Rubber Guard Bottom	\N	\N	\N	Transition to Rubber Guard Down Bottom and Submission Offense 70
263	Omoplata from Rubber Guard Bottom	\N	\N	\N	Transition to Rubber Guard Down Bottom and Submission Offense 60
264	Triangle Choke from Rubber Guard Bottom	\N	\N	\N	Transition to Rubber Guard Down Bottom
265	Transition to Half Guard Down Top	\N	\N	\N	Transition to Rubber Guard Down Bottom
266	Transition to Open Guard Top	\N	\N	\N	Transition to Rubber Guard Down Bottom
267	Armbar from Salaverry Top	\N	\N	\N	Transition to Salaverry Top
268	Transition to Both Standing	\N	\N	\N	Transition to Salaverry Top
269	Americana from Side Control Top	\N	\N	\N	Transition to Salaverry Top
270	Elbow	\N	\N	\N	Transition to Salaverry Top
271	Transition to Mount Top	\N	\N	\N	Transition to Salaverry Top
272	Cage Transition to Side Control Top	\N	\N	\N	None
273	Transition to Both Standing	\N	\N	\N	None
274	Transition to Butterfly Guard Bottom	\N	\N	\N	None
275	Transition to Half Guard Down Bottom	\N	\N	\N	None
276	Transition to Open Guard Down Bottom	\N	\N	\N	None
277	Americana from Side Control Top	\N	\N	\N	None
278	Armbar from Side Control Rocked Top	\N	\N	\N	None
279	Americana from Side Control Top	\N	\N	\N	None
280	Arm Triangle Choke	\N	\N	\N	None
281	Elbow	\N	\N	\N	None
282	Kimura from Side Control Top	\N	\N	\N	None
283	Strong Left Knee to Abdomen	\N	\N	\N	None
284	Strong Right Knee to Abdomen	\N	\N	\N	None
285	Transition to Mount Down Top	\N	\N	\N	None
286	Transition to Mount Top	\N	\N	\N	None
287	Transition to Salaverry Top	\N	\N	\N	Ground Grapple Offense of 60
288	Crushing Knee	\N	\N	\N	None
289	Downward Arcing Elbow	\N	\N	\N	None
290	Strong Hook	\N	\N	\N	None
291	Strong Knee to Abdomen	\N	\N	\N	None
292	Strong Uppercut	\N	\N	\N	None
293	Uppercut to Body	\N	\N	\N	None
294	Pull Guard to Open Guard Down Defense	\N	\N	\N	None
295	Strong Hook	\N	\N	\N	None
296	Uppercut	\N	\N	\N	None
297	Slam to Open Guard Down Offense	\N	\N	\N	None
298	Slam to Side Control Offense	\N	\N	\N	None
299	Transition to Both Standing	\N	\N	\N	None
300	Transition to Open Guard Down Bottom	\N	\N	\N	None
301	Guillotine Choke from Sprawl Rocked	\N	\N	\N	None
302	Anaconda Choke from Sprawl Top	\N	\N	\N	None
303	Guillotine Choke from Sprawl Top	\N	\N	\N	None
304	Peruvian Neck Tie from Sprawl Top	\N	\N	\N	Submission Offense of 60
305	Strong Hook	\N	\N	\N	None
306	Transition to Back Mount Top	\N	\N	\N	None
307	Left Superman Punch	\N	\N	\N	None
308	Right Superman Punch	\N	\N	\N	None
309	Kneebar from Up/Down Near Bottom	\N	\N	\N	None
310	Up-Kick	\N	\N	\N	None
311	Achilles Lock from Up/Down Near Top	\N	\N	\N	None
312	Heel Hook from Up/Down Near Top	\N	\N	\N	None
313	Kneebar from Up/Down Near Top	\N	\N	\N	None
314	Left Axe Kick to Body	\N	\N	\N	None
315	Left Superman Punch	\N	\N	\N	None
316	Right Superman Punch	\N	\N	\N	None
317	Toe Hold from Up/Down Near Top	\N	\N	\N	None
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
21	0
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
197	3
197	17
197	18
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
210	1
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
-- Data for Name: positions_moves; Type: TABLE DATA; Schema: public; Owner: jean
--

COPY positions_moves (position_id, move_id, end_position_id) FROM stdin;
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
24	180	24
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
30	210	39
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
-- Name: fighter_camps_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY fighter_camps
    ADD CONSTRAINT fighter_camps_pkey PRIMARY KEY (fighter_id, camp_id);


--
-- Name: fightersource_fighters_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY fightersource_fighters
    ADD CONSTRAINT fightersource_fighters_pkey PRIMARY KEY (fightersource_id, fighter_id);


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
-- Name: positions_moves_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY positions_moves
    ADD CONSTRAINT positions_moves_pkey PRIMARY KEY (position_id, move_id);


--
-- Name: positions_name_key; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT positions_name_key UNIQUE (name);


--
-- Name: positions_pkey; Type: CONSTRAINT; Schema: public; Owner: jean; Tablespace: 
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (id);


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
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

