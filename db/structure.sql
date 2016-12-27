--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.5
-- Dumped by pg_dump version 9.5.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: achievements; Type: TABLE; Schema: public; Owner: frost
--

CREATE TABLE achievements (
    id integer NOT NULL,
    name character varying(128),
    description character varying(1024),
    icon character varying(128),
    points smallint
);


ALTER TABLE achievements OWNER TO frost;

--
-- Name: classes; Type: TABLE; Schema: public; Owner: frost
--

CREATE TABLE classes (
    id integer NOT NULL,
    name character varying(32) NOT NULL
);


ALTER TABLE classes OWNER TO frost;

--
-- Name: factions; Type: TABLE; Schema: public; Owner: frost
--

CREATE TABLE factions (
    id integer NOT NULL,
    name character varying(32) NOT NULL
);


ALTER TABLE factions OWNER TO frost;

--
-- Name: leaderboards; Type: TABLE; Schema: public; Owner: frost
--

CREATE TABLE leaderboards (
    bracket character(3) NOT NULL,
    region character(2) NOT NULL,
    ranking integer NOT NULL,
    player_id integer NOT NULL,
    rating smallint NOT NULL,
    season_wins smallint,
    season_losses smallint,
    last_update timestamp without time zone DEFAULT now()
);


ALTER TABLE leaderboards OWNER TO frost;

--
-- Name: metadata; Type: TABLE; Schema: public; Owner: frost
--

CREATE TABLE metadata (
    key character varying(32) NOT NULL,
    value character varying(512) DEFAULT ''::character varying NOT NULL,
    last_update timestamp without time zone DEFAULT now()
);


ALTER TABLE metadata OWNER TO frost;

--
-- Name: players; Type: TABLE; Schema: public; Owner: frost
--

CREATE TABLE players (
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


ALTER TABLE players OWNER TO frost;

--
-- Name: players_achievements; Type: TABLE; Schema: public; Owner: frost
--

CREATE TABLE players_achievements (
    player_id integer NOT NULL,
    achievement_id integer NOT NULL,
    achieved_at timestamp without time zone
);


ALTER TABLE players_achievements OWNER TO frost;

--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: frost
--

CREATE SEQUENCE players_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE players_id_seq OWNER TO frost;

--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: frost
--

ALTER SEQUENCE players_id_seq OWNED BY players.id;


--
-- Name: players_talents; Type: TABLE; Schema: public; Owner: frost
--

CREATE TABLE players_talents (
    player_id integer NOT NULL,
    talent_id integer NOT NULL
);


ALTER TABLE players_talents OWNER TO frost;

--
-- Name: races; Type: TABLE; Schema: public; Owner: frost
--

CREATE TABLE races (
    id integer NOT NULL,
    name character varying(32) NOT NULL,
    side character varying(32) NOT NULL
);


ALTER TABLE races OWNER TO frost;

--
-- Name: realms; Type: TABLE; Schema: public; Owner: frost
--

CREATE TABLE realms (
    id integer NOT NULL,
    slug character varying(64) NOT NULL,
    name character varying(64) NOT NULL,
    region character(2) NOT NULL,
    battlegroup character varying(64),
    timezone character varying(64),
    type character varying(16)
);


ALTER TABLE realms OWNER TO frost;

--
-- Name: realms_id_seq; Type: SEQUENCE; Schema: public; Owner: frost
--

CREATE SEQUENCE realms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE realms_id_seq OWNER TO frost;

--
-- Name: realms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: frost
--

ALTER SEQUENCE realms_id_seq OWNED BY realms.id;


--
-- Name: specs; Type: TABLE; Schema: public; Owner: frost
--

CREATE TABLE specs (
    id integer NOT NULL,
    class_id integer NOT NULL,
    name character varying(32) NOT NULL,
    role character varying(32),
    description character varying(1024),
    background_image character varying(128),
    icon character varying(128)
);


ALTER TABLE specs OWNER TO frost;

--
-- Name: talents; Type: TABLE; Schema: public; Owner: frost
--

CREATE TABLE talents (
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


ALTER TABLE talents OWNER TO frost;

--
-- Name: talents_id_seq; Type: SEQUENCE; Schema: public; Owner: frost
--

CREATE SEQUENCE talents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE talents_id_seq OWNER TO frost;

--
-- Name: talents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: frost
--

ALTER SEQUENCE talents_id_seq OWNED BY talents.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: frost
--

ALTER TABLE ONLY players ALTER COLUMN id SET DEFAULT nextval('players_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: frost
--

ALTER TABLE ONLY realms ALTER COLUMN id SET DEFAULT nextval('realms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: frost
--

ALTER TABLE ONLY talents ALTER COLUMN id SET DEFAULT nextval('talents_id_seq'::regclass);


--
-- Name: achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- Name: classes_name_key; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY classes
    ADD CONSTRAINT classes_name_key UNIQUE (name);


--
-- Name: classes_pkey; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);


--
-- Name: factions_name_key; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY factions
    ADD CONSTRAINT factions_name_key UNIQUE (name);


--
-- Name: factions_pkey; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY factions
    ADD CONSTRAINT factions_pkey PRIMARY KEY (id);


--
-- Name: leaderboards_bracket_region_player_id_key; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY leaderboards
    ADD CONSTRAINT leaderboards_bracket_region_player_id_key UNIQUE (bracket, region, player_id);


--
-- Name: leaderboards_pkey; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY leaderboards
    ADD CONSTRAINT leaderboards_pkey PRIMARY KEY (bracket, region, ranking);


--
-- Name: metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY metadata
    ADD CONSTRAINT metadata_pkey PRIMARY KEY (key);


--
-- Name: players_achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY players_achievements
    ADD CONSTRAINT players_achievements_pkey PRIMARY KEY (player_id, achievement_id);


--
-- Name: players_name_realm_id_key; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY players
    ADD CONSTRAINT players_name_realm_id_key UNIQUE (name, realm_id);


--
-- Name: players_pkey; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: players_talents_pkey; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY players_talents
    ADD CONSTRAINT players_talents_pkey PRIMARY KEY (player_id, talent_id);


--
-- Name: races_name_side_key; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY races
    ADD CONSTRAINT races_name_side_key UNIQUE (name, side);


--
-- Name: races_pkey; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY races
    ADD CONSTRAINT races_pkey PRIMARY KEY (id);


--
-- Name: realms_pkey; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY realms
    ADD CONSTRAINT realms_pkey PRIMARY KEY (id);


--
-- Name: realms_slug_region_key; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY realms
    ADD CONSTRAINT realms_slug_region_key UNIQUE (slug, region);


--
-- Name: specs_class_id_name_key; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY specs
    ADD CONSTRAINT specs_class_id_name_key UNIQUE (class_id, name);


--
-- Name: specs_pkey; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY specs
    ADD CONSTRAINT specs_pkey PRIMARY KEY (id);


--
-- Name: talents_id_key; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY talents
    ADD CONSTRAINT talents_id_key UNIQUE (id);


--
-- Name: talents_pkey; Type: CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY talents
    ADD CONSTRAINT talents_pkey PRIMARY KEY (spell_id, spec_id);


--
-- Name: achievements_name_idx; Type: INDEX; Schema: public; Owner: frost
--

CREATE INDEX achievements_name_idx ON achievements USING btree (name);


--
-- Name: leaderboards_rating_idx; Type: INDEX; Schema: public; Owner: frost
--

CREATE INDEX leaderboards_rating_idx ON leaderboards USING btree (rating);


--
-- Name: players_class_id_spec_id_idx; Type: INDEX; Schema: public; Owner: frost
--

CREATE INDEX players_class_id_spec_id_idx ON players USING btree (class_id, spec_id);


--
-- Name: players_faction_id_race_id_idx; Type: INDEX; Schema: public; Owner: frost
--

CREATE INDEX players_faction_id_race_id_idx ON players USING btree (faction_id, race_id);


--
-- Name: players_guild_idx; Type: INDEX; Schema: public; Owner: frost
--

CREATE INDEX players_guild_idx ON players USING btree (guild);


--
-- Name: players_last_update_idx; Type: INDEX; Schema: public; Owner: frost
--

CREATE INDEX players_last_update_idx ON players USING btree (last_update DESC);


--
-- Name: talents_class_id_spec_id_idx; Type: INDEX; Schema: public; Owner: frost
--

CREATE INDEX talents_class_id_spec_id_idx ON talents USING btree (class_id, spec_id);


--
-- Name: talents_tier_col_idx; Type: INDEX; Schema: public; Owner: frost
--

CREATE INDEX talents_tier_col_idx ON talents USING btree (tier, col);


--
-- Name: leaderboards_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY leaderboards
    ADD CONSTRAINT leaderboards_player_id_fkey FOREIGN KEY (player_id) REFERENCES players(id);


--
-- Name: players_achievements_achievement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY players_achievements
    ADD CONSTRAINT players_achievements_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES achievements(id);


--
-- Name: players_achievements_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY players_achievements
    ADD CONSTRAINT players_achievements_player_id_fkey FOREIGN KEY (player_id) REFERENCES players(id);


--
-- Name: players_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY players
    ADD CONSTRAINT players_class_id_fkey FOREIGN KEY (class_id) REFERENCES classes(id);


--
-- Name: players_faction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY players
    ADD CONSTRAINT players_faction_id_fkey FOREIGN KEY (faction_id) REFERENCES factions(id);


--
-- Name: players_race_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY players
    ADD CONSTRAINT players_race_id_fkey FOREIGN KEY (race_id) REFERENCES races(id);


--
-- Name: players_realm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY players
    ADD CONSTRAINT players_realm_id_fkey FOREIGN KEY (realm_id) REFERENCES realms(id);


--
-- Name: players_spec_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY players
    ADD CONSTRAINT players_spec_id_fkey FOREIGN KEY (spec_id) REFERENCES specs(id);


--
-- Name: players_talents_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY players_talents
    ADD CONSTRAINT players_talents_player_id_fkey FOREIGN KEY (player_id) REFERENCES players(id);


--
-- Name: players_talents_talent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY players_talents
    ADD CONSTRAINT players_talents_talent_id_fkey FOREIGN KEY (talent_id) REFERENCES talents(id);


--
-- Name: specs_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY specs
    ADD CONSTRAINT specs_class_id_fkey FOREIGN KEY (class_id) REFERENCES classes(id);


--
-- Name: talents_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: frost
--

ALTER TABLE ONLY talents
    ADD CONSTRAINT talents_class_id_fkey FOREIGN KEY (class_id) REFERENCES classes(id);


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
