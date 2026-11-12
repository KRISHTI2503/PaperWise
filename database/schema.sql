--
-- PaperWise Production Database Schema
-- Target: PostgreSQL 14+ (Neon)
--
-- How to load:
-- 1. Paste this entire file into Neon's SQL Editor (new tab)
-- 2. Or use psql: psql -f database/schema.sql -d your_database_url
--

--
-- Name: announcements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.announcements (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    body text NOT NULL,
    created_by character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    expires_at date,
    is_pinned boolean DEFAULT false
);

--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.announcements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.announcements_id_seq OWNED BY public.announcements.id;

--
-- Name: difficulty_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.difficulty_votes (
    id integer NOT NULL,
    paper_id integer NOT NULL,
    user_id integer NOT NULL,
    difficulty_level character varying(10) NOT NULL,
    CONSTRAINT difficulty_votes_difficulty_level_check CHECK (((difficulty_level)::text = ANY ((ARRAY['easy'::character varying, 'medium'::character varying, 'hard'::character varying])::text[])))
);

--
-- Name: difficulty_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.difficulty_votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.difficulty_votes_id_seq OWNED BY public.difficulty_votes.id;

--
-- Name: exam_schedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exam_schedule (
    id integer NOT NULL,
    subject_code character varying(50) NOT NULL,
    subject_name character varying(100) NOT NULL,
    exam_type character varying(50) NOT NULL,
    exam_date date NOT NULL,
    created_by character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);

--
-- Name: exam_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exam_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.exam_schedule_id_seq OWNED BY public.exam_schedule.id;

--
-- Name: marks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marks (
    mark_id integer NOT NULL,
    user_id integer NOT NULL,
    paper_id integer NOT NULL,
    marked_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: marks_mark_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.marks_mark_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.marks_mark_id_seq OWNED BY public.marks.mark_id;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    message character varying(255) NOT NULL,
    link character varying(255),
    is_read boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;

--
-- Name: paper_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paper_comments (
    comment_id integer NOT NULL,
    paper_id integer NOT NULL,
    user_id integer NOT NULL,
    comment_text text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    parent_comment_id integer
);

--
-- Name: paper_comments_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.paper_comments_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.paper_comments_comment_id_seq OWNED BY public.paper_comments.comment_id;

--
-- Name: paper_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paper_requests (
    request_id integer NOT NULL,
    user_id integer NOT NULL,
    subject_name character varying(150) NOT NULL,
    subject_code character varying(50),
    year integer NOT NULL,
    description text,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    requested_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    admin_message text,
    admin_message_updated_at timestamp without time zone,
    CONSTRAINT paper_requests_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying, 'completed'::character varying])::text[]))),
    CONSTRAINT paper_requests_year_check CHECK (((year >= 2000) AND (year <= 2100)))
);

--
-- Name: paper_requests_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.paper_requests_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.paper_requests_request_id_seq OWNED BY public.paper_requests.request_id;

--
-- Name: papers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.papers (
    paper_id integer NOT NULL,
    subject_name character varying(150) NOT NULL,
    subject_code character varying(50) NOT NULL,
    year integer NOT NULL,
    chapter character varying(100),
    file_url character varying(255) NOT NULL,
    uploaded_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    exam_type character varying(100),
    description text,
    CONSTRAINT papers_year_check CHECK ((year >= 2000))
);

--
-- Name: papers_paper_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.papers_paper_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.papers_paper_id_seq OWNED BY public.papers.paper_id;

--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    password character varying(255) NOT NULL,
    role character varying(20) DEFAULT 'student'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    firebase_uid character varying(128),
    auth_provider character varying(20) DEFAULT 'local'::character varying,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['admin'::character varying, 'student'::character varying])::text[])))
);

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;

--
-- Name: votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.votes (
    id integer NOT NULL,
    paper_id integer NOT NULL,
    user_id integer NOT NULL
);

--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.votes_id_seq OWNED BY public.votes.id;

--
-- Name: announcements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements ALTER COLUMN id SET DEFAULT nextval('public.announcements_id_seq'::regclass);

--
-- Name: difficulty_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.difficulty_votes ALTER COLUMN id SET DEFAULT nextval('public.difficulty_votes_id_seq'::regclass);

--
-- Name: exam_schedule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_schedule ALTER COLUMN id SET DEFAULT nextval('public.exam_schedule_id_seq'::regclass);

--
-- Name: marks mark_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marks ALTER COLUMN mark_id SET DEFAULT nextval('public.marks_mark_id_seq'::regclass);

--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);

--
-- Name: paper_comments comment_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paper_comments ALTER COLUMN comment_id SET DEFAULT nextval('public.paper_comments_comment_id_seq'::regclass);

--
-- Name: paper_requests request_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paper_requests ALTER COLUMN request_id SET DEFAULT nextval('public.paper_requests_request_id_seq'::regclass);

--
-- Name: papers paper_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papers ALTER COLUMN paper_id SET DEFAULT nextval('public.papers_paper_id_seq'::regclass);

--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);

--
-- Name: votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes ALTER COLUMN id SET DEFAULT nextval('public.votes_id_seq'::regclass);

--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);

--
-- Name: difficulty_votes difficulty_votes_paper_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.difficulty_votes
    ADD CONSTRAINT difficulty_votes_paper_id_user_id_key UNIQUE (paper_id, user_id);

--
-- Name: difficulty_votes difficulty_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.difficulty_votes
    ADD CONSTRAINT difficulty_votes_pkey PRIMARY KEY (id);

--
-- Name: exam_schedule exam_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_schedule
    ADD CONSTRAINT exam_schedule_pkey PRIMARY KEY (id);

--
-- Name: marks marks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marks
    ADD CONSTRAINT marks_pkey PRIMARY KEY (mark_id);

--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);

--
-- Name: paper_comments paper_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paper_comments
    ADD CONSTRAINT paper_comments_pkey PRIMARY KEY (comment_id);

--
-- Name: paper_requests paper_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paper_requests
    ADD CONSTRAINT paper_requests_pkey PRIMARY KEY (request_id);

--
-- Name: papers papers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papers
    ADD CONSTRAINT papers_pkey PRIMARY KEY (paper_id);

--
-- Name: difficulty_votes unique_difficulty_vote; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.difficulty_votes
    ADD CONSTRAINT unique_difficulty_vote UNIQUE (paper_id, user_id);

--
-- Name: papers unique_paper_per_year; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papers
    ADD CONSTRAINT unique_paper_per_year UNIQUE (subject_code, year);

--
-- Name: marks unique_user_paper; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marks
    ADD CONSTRAINT unique_user_paper UNIQUE (user_id, paper_id);

--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);

--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);

--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);

--
-- Name: votes votes_paper_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_paper_id_user_id_key UNIQUE (paper_id, user_id);

--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);

--
-- Name: idx_marks_paper; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_marks_paper ON public.marks USING btree (paper_id);

--
-- Name: idx_marks_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_marks_user ON public.marks USING btree (user_id);

--
-- Name: idx_paper_requests_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_paper_requests_status ON public.paper_requests USING btree (status);

--
-- Name: idx_paper_requests_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_paper_requests_user ON public.paper_requests USING btree (user_id);

--
-- Name: idx_papers_subject_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_papers_subject_code ON public.papers USING btree (subject_code);

--
-- Name: idx_papers_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_papers_year ON public.papers USING btree (year);

--
-- Name: idx_users_auth_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_auth_provider ON public.users USING btree (auth_provider);

--
-- Name: idx_users_firebase_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_firebase_uid ON public.users USING btree (firebase_uid) WHERE (firebase_uid IS NOT NULL);

--
-- Name: unique_firebase_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_firebase_uid ON public.users USING btree (firebase_uid) WHERE (firebase_uid IS NOT NULL);

--
-- Name: difficulty_votes difficulty_votes_paper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.difficulty_votes
    ADD CONSTRAINT difficulty_votes_paper_id_fkey FOREIGN KEY (paper_id) REFERENCES public.papers(paper_id) ON DELETE CASCADE;

--
-- Name: difficulty_votes difficulty_votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.difficulty_votes
    ADD CONSTRAINT difficulty_votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;

--
-- Name: marks fk_mark_paper; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marks
    ADD CONSTRAINT fk_mark_paper FOREIGN KEY (paper_id) REFERENCES public.papers(paper_id) ON DELETE CASCADE;

--
-- Name: marks fk_mark_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marks
    ADD CONSTRAINT fk_mark_user FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;

--
-- Name: paper_requests fk_request_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paper_requests
    ADD CONSTRAINT fk_request_user FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;

--
-- Name: papers fk_uploaded_by; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papers
    ADD CONSTRAINT fk_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES public.users(user_id) ON DELETE SET NULL;

--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);

--
-- Name: paper_comments paper_comments_paper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paper_comments
    ADD CONSTRAINT paper_comments_paper_id_fkey FOREIGN KEY (paper_id) REFERENCES public.papers(paper_id) ON DELETE CASCADE;

--
-- Name: paper_comments paper_comments_parent_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paper_comments
    ADD CONSTRAINT paper_comments_parent_comment_id_fkey FOREIGN KEY (parent_comment_id) REFERENCES public.paper_comments(comment_id) ON DELETE CASCADE;

--
-- Name: paper_comments paper_comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paper_comments
    ADD CONSTRAINT paper_comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;

--
-- Name: votes votes_paper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_paper_id_fkey FOREIGN KEY (paper_id) REFERENCES public.papers(paper_id) ON DELETE CASCADE;

--
-- Name: votes votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;

--
-- Create the first admin after loading the schema (choose your own password):
-- INSERT INTO public.users (username, email, password, role)
-- VALUES ('admin', 'admin@example.com', 'CHOOSE_A_STRONG_PASSWORD', 'admin');
