--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.14
-- Dumped by pg_dump version 9.5.14

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: achievements; Type: TABLE; Schema: public
--

CREATE TABLE public.achievements (
    id integer NOT NULL,
    name character varying(128),
    description character varying(1024),
    icon character varying(128),
    points smallint
);


ALTER TABLE public.achievements OWNER TO frost;

--
-- Name: classes; Type: TABLE; Schema: public
--

CREATE TABLE public.classes (
    id integer NOT NULL,
    name character varying(32) NOT NULL
);


ALTER TABLE public.classes OWNER TO frost;

--
-- Name: factions; Type: TABLE; Schema: public
--

CREATE TABLE public.factions (
    id integer NOT NULL,
    name character varying(32) NOT NULL
);


ALTER TABLE public.factions OWNER TO frost;

--
-- Name: items; Type: TABLE; Schema: public
--

CREATE TABLE public.items (
    id integer NOT NULL,
    name character varying(128),
    icon character varying(128)
);


ALTER TABLE public.items OWNER TO frost;

--
-- Name: leaderboards; Type: TABLE; Schema: public
--

CREATE TABLE public.leaderboards (
    bracket character(3) NOT NULL,
    region character(2) NOT NULL,
    ranking integer NOT NULL,
    player_id integer NOT NULL,
    rating smallint NOT NULL,
    season_wins smallint,
    season_losses smallint,
    last_update timestamp without time zone DEFAULT now()
);


ALTER TABLE public.leaderboards OWNER TO frost;

--
-- Name: metadata; Type: TABLE; Schema: public
--

CREATE TABLE public.metadata (
    key character varying(32) NOT NULL,
    value character varying(512) DEFAULT ''::character varying NOT NULL,
    last_update timestamp without time zone DEFAULT now()
);


ALTER TABLE public.metadata OWNER TO frost;

--
-- Name: players; Type: TABLE; Schema: public
--

CREATE TABLE public.players (
    id integer NOT NULL,
    name character varying(32) NOT NULL,
    class_id integer,
    spec_id integer,
    faction_id integer,
    race_id integer,
    realm_id integer NOT NULL,
    guild character varying(64),
    gender smallint,
    achievement_points integer,
    honorable_kills integer,
    thumbnail character varying(128),
    last_update timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.players OWNER TO frost;

--
-- Name: players_achievements; Type: TABLE; Schema: public
--

CREATE TABLE public.players_achievements (
    player_id integer NOT NULL,
    achievement_id integer NOT NULL,
    achieved_at timestamp without time zone
);


ALTER TABLE public.players_achievements OWNER TO frost;

--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.players_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.players_id_seq OWNER TO frost;

--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.players_id_seq OWNED BY public.players.id;


--
-- Name: players_items; Type: TABLE; Schema: public
--

CREATE TABLE public.players_items (
    player_id integer NOT NULL,
    average_item_level integer,
    average_item_level_equipped integer,
    head integer,
    neck integer,
    shoulder integer,
    back integer,
    chest integer,
    shirt integer,
    tabard integer,
    wrist integer,
    hands integer,
    waist integer,
    legs integer,
    feet integer,
    finger1 integer,
    finger2 integer,
    trinket1 integer,
    trinket2 integer,
    mainhand integer,
    offhand integer
);


ALTER TABLE public.players_items OWNER TO frost;

--
-- Name: players_stats; Type: TABLE; Schema: public
--

CREATE TABLE public.players_stats (
    player_id integer NOT NULL,
    strength integer,
    agility integer,
    intellect integer,
    stamina integer,
    critical_strike integer,
    haste integer,
    mastery integer,
    versatility integer,
    leech real,
    dodge real,
    parry real
);


ALTER TABLE public.players_stats OWNER TO frost;

--
-- Name: players_talents; Type: TABLE; Schema: public
--

CREATE TABLE public.players_talents (
    player_id integer NOT NULL,
    talent_id integer NOT NULL
);


ALTER TABLE public.players_talents OWNER TO frost;

--
-- Name: races; Type: TABLE; Schema: public
--

CREATE TABLE public.races (
    id integer NOT NULL,
    name character varying(32) NOT NULL,
    side character varying(32) NOT NULL
);


ALTER TABLE public.races OWNER TO frost;

--
-- Name: realms; Type: TABLE; Schema: public
--

CREATE TABLE public.realms (
    id integer NOT NULL,
    slug character varying(64) NOT NULL,
    name character varying(64) NOT NULL,
    region character(2) NOT NULL,
    battlegroup character varying(64),
    timezone character varying(64),
    type character varying(16)
);


ALTER TABLE public.realms OWNER TO frost;

--
-- Name: realms_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.realms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.realms_id_seq OWNER TO frost;

--
-- Name: realms_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.realms_id_seq OWNED BY public.realms.id;


--
-- Name: specs; Type: TABLE; Schema: public
--

CREATE TABLE public.specs (
    id integer NOT NULL,
    class_id integer NOT NULL,
    name character varying(32) NOT NULL,
    role character varying(32),
    description character varying(1024),
    background_image character varying(128),
    icon character varying(128)
);


ALTER TABLE public.specs OWNER TO frost;

--
-- Name: talents; Type: TABLE; Schema: public
--

CREATE TABLE public.talents (
    id integer NOT NULL,
    spell_id integer NOT NULL,
    class_id integer NOT NULL,
    spec_id integer DEFAULT 0 NOT NULL,
    name character varying(128) NOT NULL,
    description character varying(1024),
    icon character varying(128),
    tier smallint,
    col smallint
);


ALTER TABLE public.talents OWNER TO frost;

--
-- Name: talents_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.talents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.talents_id_seq OWNER TO frost;

--
-- Name: talents_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.talents_id_seq OWNED BY public.talents.id;


--
-- Name: id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.players ALTER COLUMN id SET DEFAULT nextval('public.players_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.realms ALTER COLUMN id SET DEFAULT nextval('public.realms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.talents ALTER COLUMN id SET DEFAULT nextval('public.talents_id_seq'::regclass);


--
-- Name: achievements_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- Name: classes_name_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_name_key UNIQUE (name);


--
-- Name: classes_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);


--
-- Name: factions_name_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.factions
    ADD CONSTRAINT factions_name_key UNIQUE (name);


--
-- Name: factions_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.factions
    ADD CONSTRAINT factions_pkey PRIMARY KEY (id);


--
-- Name: items_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: leaderboards_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.leaderboards
    ADD CONSTRAINT leaderboards_pkey PRIMARY KEY (bracket, region, player_id);


--
-- Name: metadata_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.metadata
    ADD CONSTRAINT metadata_pkey PRIMARY KEY (key);


--
-- Name: players_achievements_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players_achievements
    ADD CONSTRAINT players_achievements_pkey PRIMARY KEY (player_id, achievement_id);


--
-- Name: players_items_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players_items
    ADD CONSTRAINT players_items_pkey PRIMARY KEY (player_id);


--
-- Name: players_name_realm_id_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_name_realm_id_key UNIQUE (name, realm_id);


--
-- Name: players_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: players_stats_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players_stats
    ADD CONSTRAINT players_stats_pkey PRIMARY KEY (player_id);


--
-- Name: players_talents_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players_talents
    ADD CONSTRAINT players_talents_pkey PRIMARY KEY (player_id, talent_id);


--
-- Name: races_name_side_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.races
    ADD CONSTRAINT races_name_side_key UNIQUE (name, side);


--
-- Name: races_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.races
    ADD CONSTRAINT races_pkey PRIMARY KEY (id);


--
-- Name: realms_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.realms
    ADD CONSTRAINT realms_pkey PRIMARY KEY (id);


--
-- Name: realms_slug_region_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.realms
    ADD CONSTRAINT realms_slug_region_key UNIQUE (slug, region);


--
-- Name: specs_class_id_name_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.specs
    ADD CONSTRAINT specs_class_id_name_key UNIQUE (class_id, name);


--
-- Name: specs_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.specs
    ADD CONSTRAINT specs_pkey PRIMARY KEY (id);


--
-- Name: talents_id_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.talents
    ADD CONSTRAINT talents_id_key UNIQUE (id);


--
-- Name: talents_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.talents
    ADD CONSTRAINT talents_pkey PRIMARY KEY (spell_id, spec_id);


--
-- Name: achievements_name_idx; Type: INDEX; Schema: public
--

CREATE INDEX achievements_name_idx ON public.achievements USING btree (name);


--
-- Name: leaderboards_ranking_idx; Type: INDEX; Schema: public
--

CREATE INDEX leaderboards_ranking_idx ON public.leaderboards USING btree (ranking);


--
-- Name: leaderboards_rating_idx; Type: INDEX; Schema: public
--

CREATE INDEX leaderboards_rating_idx ON public.leaderboards USING btree (rating);


--
-- Name: players_class_id_spec_id_idx; Type: INDEX; Schema: public
--

CREATE INDEX players_class_id_spec_id_idx ON public.players USING btree (class_id, spec_id);


--
-- Name: players_faction_id_race_id_idx; Type: INDEX; Schema: public
--

CREATE INDEX players_faction_id_race_id_idx ON public.players USING btree (faction_id, race_id);


--
-- Name: players_guild_idx; Type: INDEX; Schema: public
--

CREATE INDEX players_guild_idx ON public.players USING btree (guild);


--
-- Name: players_last_update_idx; Type: INDEX; Schema: public
--

CREATE INDEX players_last_update_idx ON public.players USING btree (last_update DESC);


--
-- Name: talents_class_id_spec_id_idx; Type: INDEX; Schema: public
--

CREATE INDEX talents_class_id_spec_id_idx ON public.talents USING btree (class_id, spec_id);


--
-- Name: talents_tier_col_idx; Type: INDEX; Schema: public
--

CREATE INDEX talents_tier_col_idx ON public.talents USING btree (tier, col);


--
-- Name: leaderboards_player_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.leaderboards
    ADD CONSTRAINT leaderboards_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: players_achievements_achievement_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players_achievements
    ADD CONSTRAINT players_achievements_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES public.achievements(id);


--
-- Name: players_achievements_player_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players_achievements
    ADD CONSTRAINT players_achievements_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: players_class_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id);


--
-- Name: players_faction_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_faction_id_fkey FOREIGN KEY (faction_id) REFERENCES public.factions(id);


--
-- Name: players_items_player_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players_items
    ADD CONSTRAINT players_items_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: players_race_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_race_id_fkey FOREIGN KEY (race_id) REFERENCES public.races(id);


--
-- Name: players_realm_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_realm_id_fkey FOREIGN KEY (realm_id) REFERENCES public.realms(id);


--
-- Name: players_spec_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_spec_id_fkey FOREIGN KEY (spec_id) REFERENCES public.specs(id);


--
-- Name: players_stats_player_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players_stats
    ADD CONSTRAINT players_stats_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: players_talents_player_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players_talents
    ADD CONSTRAINT players_talents_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: players_talents_talent_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.players_talents
    ADD CONSTRAINT players_talents_talent_id_fkey FOREIGN KEY (talent_id) REFERENCES public.talents(id);


--
-- Name: specs_class_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.specs
    ADD CONSTRAINT specs_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id);


--
-- Name: talents_class_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.talents
    ADD CONSTRAINT talents_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

