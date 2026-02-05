--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

-- Started on 2026-02-05 17:38:44

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 58871)
-- Name: contact_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contact_requests (
    id bigint NOT NULL,
    message character varying(2000) NOT NULL,
    read boolean NOT NULL,
    sent_at timestamp(6) without time zone,
    technician_email character varying(255) NOT NULL,
    user_email character varying(255) NOT NULL
);


ALTER TABLE public.contact_requests OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 58870)
-- Name: contact_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contact_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contact_requests_id_seq OWNER TO postgres;

--
-- TOC entry 4937 (class 0 OID 0)
-- Dependencies: 217
-- Name: contact_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contact_requests_id_seq OWNED BY public.contact_requests.id;


--
-- TOC entry 224 (class 1259 OID 58904)
-- Name: ratings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ratings (
    id bigint NOT NULL,
    comment character varying(1000),
    created_at timestamp(6) without time zone,
    score integer NOT NULL,
    updated_at timestamp(6) without time zone,
    technician_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.ratings OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 58903)
-- Name: ratings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ratings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ratings_id_seq OWNER TO postgres;

--
-- TOC entry 4938 (class 0 OID 0)
-- Dependencies: 223
-- Name: ratings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ratings_id_seq OWNED BY public.ratings.id;


--
-- TOC entry 220 (class 1259 OID 58880)
-- Name: technicians; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.technicians (
    id bigint NOT NULL,
    city character varying(255) NOT NULL,
    created_at timestamp(6) without time zone,
    description character varying(1000),
    domain character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    phone character varying(255) NOT NULL,
    profile_image_url character varying(255),
    rating double precision NOT NULL,
    review_count integer NOT NULL,
    role character varying(255) NOT NULL,
    CONSTRAINT technicians_role_check CHECK (((role)::text = ANY ((ARRAY['USER'::character varying, 'TECHNICIAN'::character varying, 'ADMIN'::character varying])::text[])))
);


ALTER TABLE public.technicians OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 58879)
-- Name: technicians_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.technicians_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.technicians_id_seq OWNER TO postgres;

--
-- TOC entry 4939 (class 0 OID 0)
-- Dependencies: 219
-- Name: technicians_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.technicians_id_seq OWNED BY public.technicians.id;


--
-- TOC entry 222 (class 1259 OID 58890)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone,
    email character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    role character varying(255) NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['USER'::character varying, 'TECHNICIAN'::character varying, 'ADMIN'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 58889)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 4940 (class 0 OID 0)
-- Dependencies: 221
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4757 (class 2604 OID 58874)
-- Name: contact_requests id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_requests ALTER COLUMN id SET DEFAULT nextval('public.contact_requests_id_seq'::regclass);


--
-- TOC entry 4760 (class 2604 OID 58907)
-- Name: ratings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratings ALTER COLUMN id SET DEFAULT nextval('public.ratings_id_seq'::regclass);


--
-- TOC entry 4758 (class 2604 OID 58883)
-- Name: technicians id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.technicians ALTER COLUMN id SET DEFAULT nextval('public.technicians_id_seq'::regclass);


--
-- TOC entry 4759 (class 2604 OID 58893)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4925 (class 0 OID 58871)
-- Dependencies: 218
-- Data for Name: contact_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contact_requests (id, message, read, sent_at, technician_email, user_email) FROM stdin;
1	Allo je voudrais un plombier je suis a yassa	f	2026-02-05 15:53:16.558141	test@gmail.com	doe@gmai.com
2	Hello world	f	2026-02-05 16:09:35.106432	tchoikuemel@gmail.com	mt@gmail.com
3	Ouvrez la console du navigateur (F12) pour voir les messages de debug et dites-moi ce qui s'affiche quand vous essayez de vous connecter.	f	2026-02-05 16:14:42.007955	tchoikuemel06@gmail.com	mt@gmail.com
4	hello je voudrais un blombier	f	2026-02-05 16:23:23.584914	tchoikuemel06@gmail.com	mt@gmail.com
5	Et retestez l'envoi d'email. Les messages doivent apparaître dans l'inbox Mailtrap, pas dans votre vrai email Gmail (c'est un faux SMTP pour le développement).	f	2026-02-05 16:32:31.929202	tchoikuemel06@gmail.com	mt@gmail.com
\.


--
-- TOC entry 4931 (class 0 OID 58904)
-- Dependencies: 224
-- Data for Name: ratings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ratings (id, comment, created_at, score, updated_at, technician_id, user_id) FROM stdin;
1	tres bon dans son travail	2026-02-05 17:10:42.91876	4	2026-02-05 17:10:42.91876	1	4
\.


--
-- TOC entry 4927 (class 0 OID 58880)
-- Dependencies: 220
-- Data for Name: technicians; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.technicians (id, city, created_at, description, domain, email, name, password, phone, profile_image_url, rating, review_count, role) FROM stdin;
2	Douala	2026-01-30 20:46:49.747525		Informatique	mel@gmail.com	Mel	$2a$10$0p.G7fqFr6qh/twbE.q/uOMsEOXGv.gjuRvHItVzHYduSjdwWFlaa	658800589	\N	0	0	TECHNICIAN
3	Douala yassa	2026-01-30 21:19:38.227702		Plombier	test@gmail.com	test	$2a$10$zmz14dvaAoYwFVom8Ioysed6inXsDWukAh.49dI3VHwEQ2d6B.lDy	650800577	\N	0	0	TECHNICIAN
4	Douala	2026-02-05 15:55:11.350926	Test	Ploberie	tchoikuemel@gmail.com	Mel turham	$2a$10$QS/P/bfLFab8YkFn9T8Mk..cwhpSSxu1JQaJHLu/vvLL0y.MW00QC	658800588	\N	0	0	TECHNICIAN
5	Yaoundé	2026-02-05 16:13:50.943274	Ouvrez la console du navigateur (F12) pour voir les messages de debug et dites-moi ce qui s'affiche quand vous essayez de vous connecter.	Électricien	tchoikuemel06@gmail.com	Watchou	$2a$10$1yskp/v8MfsTHjgdLLePjuYVcSjHglTStOerYLlz8oyHUNdlDjPA6	658800588	\N	0	0	TECHNICIAN
1	Douala	2026-01-30 20:23:04.332341	Je suis un ING en menuisier	Menuisier	brayan@gmail.com	Brayan	$2a$10$RgjaqTGFMTZcdXe7pXite./VRxM7FuYrORmC63v4nXgRMap66adAe	+237658800588	\N	4	1	TECHNICIAN
\.


--
-- TOC entry 4929 (class 0 OID 58890)
-- Dependencies: 222
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, email, name, password, role) FROM stdin;
1	2026-01-30 19:52:05.34868	melturham@gmail.com	Mel Turham	$2a$10$F1CO30/oeJbxkSNC7o0cqu6C9/yBPsvBEalGLiTv3IEG8PgeEYUfG	USER
2	2026-01-30 21:14:03.2577	john@gmail.com	Mel	$2a$10$s3tr1pOi.uOM55/aP07fCODGQ3j/719Cm9plihAWCqAc7i35ktI4i	USER
3	2026-02-05 15:52:43.420367	doe@gmai.com	Doe	$2a$10$sY62x9a9MKWiBUtucwAQ/eHzOIFphXauwppijf2cLB9S40WQvqpua	USER
4	2026-02-05 15:57:09.829611	mt@gmail.com	mt	$2a$10$lDeGG.uh2L2kKl1WSnkobO.vmR94pyby6kLi/trQzUxYa8DUU/2cu	USER
\.


--
-- TOC entry 4941 (class 0 OID 0)
-- Dependencies: 217
-- Name: contact_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contact_requests_id_seq', 5, true);


--
-- TOC entry 4942 (class 0 OID 0)
-- Dependencies: 223
-- Name: ratings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ratings_id_seq', 33, true);


--
-- TOC entry 4943 (class 0 OID 0)
-- Dependencies: 219
-- Name: technicians_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.technicians_id_seq', 5, true);


--
-- TOC entry 4944 (class 0 OID 0)
-- Dependencies: 221
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- TOC entry 4764 (class 2606 OID 58878)
-- Name: contact_requests contact_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_requests
    ADD CONSTRAINT contact_requests_pkey PRIMARY KEY (id);


--
-- TOC entry 4774 (class 2606 OID 58911)
-- Name: ratings ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (id);


--
-- TOC entry 4766 (class 2606 OID 58888)
-- Name: technicians technicians_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.technicians
    ADD CONSTRAINT technicians_pkey PRIMARY KEY (id);


--
-- TOC entry 4770 (class 2606 OID 58902)
-- Name: users uk_6dotkott2kjsp8vw4d0m25fb7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uk_6dotkott2kjsp8vw4d0m25fb7 UNIQUE (email);


--
-- TOC entry 4768 (class 2606 OID 58900)
-- Name: technicians uk_9miamdt1dkijdehwsr5kc4mgp; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.technicians
    ADD CONSTRAINT uk_9miamdt1dkijdehwsr5kc4mgp UNIQUE (email);


--
-- TOC entry 4776 (class 2606 OID 58913)
-- Name: ratings uk_user_technician_rating; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT uk_user_technician_rating UNIQUE (user_id, technician_id);


--
-- TOC entry 4772 (class 2606 OID 58898)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4777 (class 2606 OID 58919)
-- Name: ratings fkb3354ee2xxvdrbyq9f42jdayd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT fkb3354ee2xxvdrbyq9f42jdayd FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4778 (class 2606 OID 58914)
-- Name: ratings fkfra5vyn5j6krj4ftpuqcmdv1y; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT fkfra5vyn5j6krj4ftpuqcmdv1y FOREIGN KEY (technician_id) REFERENCES public.technicians(id);


-- Completed on 2026-02-05 17:38:44

--
-- PostgreSQL database dump complete
--

