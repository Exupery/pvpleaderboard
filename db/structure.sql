--
--
--

--
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
--
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
--
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
--
--

CREATE FUNCTION public.purge_old_players() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM players_achievements WHERE player_id NOT IN (SELECT player_id FROM leaderboards);
  DELETE FROM players_pvp_talents WHERE player_id NOT IN (SELECT player_id FROM leaderboards);
  DELETE FROM players_talents WHERE player_id NOT IN (SELECT player_id FROM leaderboards);
  DELETE FROM players_stats WHERE player_id NOT IN (SELECT player_id FROM leaderboards);
  DELETE FROM players_items WHERE player_id NOT IN (SELECT player_id FROM leaderboards);
  DELETE FROM players_legendaries WHERE player_id NOT IN (SELECT player_id FROM leaderboards);
  DELETE FROM players WHERE DATE_PART('day', NOW() - players.last_update) > 30 AND id NOT IN (SELECT player_id FROM leaderboards);
  DELETE FROM items WHERE DATE_PART('day', NOW() - items.last_update) > 30;
END; $$;




SET default_tablespace = '';

SET default_with_oids = false;

--
--
--

CREATE TABLE public.achievements (
    id integer NOT NULL,
    name character varying(128),
    description character varying(1024),
    icon character varying(128)
);




--
--
--

CREATE TABLE public.classes (
    id integer NOT NULL,
    name character varying(32) NOT NULL
);




--
--
--

CREATE TABLE public.conduits (
    id integer NOT NULL,
    spell_id integer NOT NULL,
    name character varying(128) NOT NULL
);




--
--
--

CREATE TABLE public.covenants (
    id integer NOT NULL,
    name character varying(32) NOT NULL,
    icon character varying(128)
);




--
--
--

CREATE TABLE public.factions (
    id integer NOT NULL,
    name character varying(32) NOT NULL
);




--
--
--

CREATE TABLE public.items (
    id integer NOT NULL,
    name character varying(128),
    quality character varying(64),
    last_update timestamp without time zone DEFAULT now()
);




--
--
--

CREATE TABLE public.leaderboards (
    region character(2) NOT NULL,
    bracket character(3) NOT NULL,
    player_id integer NOT NULL,
    ranking smallint NOT NULL,
    rating smallint NOT NULL,
    season_wins smallint,
    season_losses smallint,
    last_update timestamp without time zone DEFAULT now()
);




--
--
--

CREATE TABLE public.metadata (
    key character varying(32) NOT NULL,
    value character varying(512) DEFAULT ''::character varying NOT NULL,
    last_update timestamp without time zone DEFAULT now()
);




--
--
--

CREATE TABLE public.players (
    id integer NOT NULL,
    name character varying(32) NOT NULL,
    realm_id integer NOT NULL,
    blizzard_id integer NOT NULL,
    class_id integer,
    spec_id integer,
    faction_id integer,
    race_id integer,
    gender smallint,
    guild character varying(64),
    last_update timestamp without time zone DEFAULT now() NOT NULL,
    last_login timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    profile_id text
);




--
--
--

CREATE TABLE public.players_achievements (
    player_id integer NOT NULL,
    achievement_id integer NOT NULL
);




--
--
--

CREATE TABLE public.players_conduits (
    player_id integer NOT NULL,
    conduit_id integer NOT NULL
);




--
--
--

CREATE TABLE public.players_covenants (
    player_id integer NOT NULL,
    covenant_id integer NOT NULL
);




--
--
--

CREATE SEQUENCE public.players_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
--
--

ALTER SEQUENCE public.players_id_seq OWNED BY public.players.id;


--
--
--

CREATE TABLE public.players_items (
    player_id integer NOT NULL,
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




--
--
--

CREATE TABLE public.players_legendaries (
    player_id integer NOT NULL,
    spell_id integer NOT NULL,
    legendary_name character varying(256) NOT NULL
);




--
--
--

CREATE TABLE public.players_pvp_talents (
    player_id integer NOT NULL,
    pvp_talent_id integer NOT NULL
);




--
--
--

CREATE TABLE public.players_soulbinds (
    player_id integer NOT NULL,
    soulbind_id integer NOT NULL
);




--
--
--

CREATE TABLE public.players_stats (
    player_id integer NOT NULL,
    strength integer,
    agility integer,
    intellect integer,
    stamina integer,
    critical_strike integer,
    haste integer,
    versatility integer,
    mastery integer,
    leech integer,
    dodge integer,
    parry integer
);




--
--
--

CREATE TABLE public.players_talents (
    player_id integer NOT NULL,
    talent_id integer NOT NULL
);




--
--
--

CREATE TABLE public.pvp_talents (
    id integer NOT NULL,
    spell_id integer NOT NULL,
    spec_id integer NOT NULL,
    name character varying(128) NOT NULL,
    icon character varying(128)
);




--
--
--

CREATE TABLE public.races (
    id integer NOT NULL,
    name character varying(32) NOT NULL
);




--
--
--

CREATE TABLE public.realms (
    id integer NOT NULL,
    slug character varying(64) NOT NULL,
    name character varying(64) NOT NULL,
    region character(2) NOT NULL
);




--
--
--

CREATE TABLE public.soulbinds (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);




--
--
--

CREATE TABLE public.specs (
    id integer NOT NULL,
    class_id integer NOT NULL,
    name character varying(32) NOT NULL,
    role character varying(32),
    icon character varying(128)
);




--
--
--

CREATE TABLE public.talents (
    id integer NOT NULL,
    spell_id integer NOT NULL,
    class_id integer NOT NULL,
    spec_id integer,
    name character varying(128) NOT NULL,
    icon character varying(128),
    tier smallint,
    col smallint
);




--
--
--

ALTER TABLE ONLY public.players ALTER COLUMN id SET DEFAULT nextval('public.players_id_seq'::regclass);


--
--
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
--
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_name_key UNIQUE (name);


--
--
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);


--
--
--

ALTER TABLE ONLY public.conduits
    ADD CONSTRAINT conduits_pkey PRIMARY KEY (id);


--
--
--

ALTER TABLE ONLY public.covenants
    ADD CONSTRAINT covenants_pkey PRIMARY KEY (id);


--
--
--

ALTER TABLE ONLY public.factions
    ADD CONSTRAINT factions_name_key UNIQUE (name);


--
--
--

ALTER TABLE ONLY public.factions
    ADD CONSTRAINT factions_pkey PRIMARY KEY (id);


--
--
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
--
--

ALTER TABLE ONLY public.leaderboards
    ADD CONSTRAINT leaderboards_pkey PRIMARY KEY (region, bracket, player_id);


--
--
--

ALTER TABLE ONLY public.metadata
    ADD CONSTRAINT metadata_pkey PRIMARY KEY (key);


--
--
--

ALTER TABLE ONLY public.players_achievements
    ADD CONSTRAINT players_achievements_pkey PRIMARY KEY (player_id, achievement_id);


--
--
--

ALTER TABLE ONLY public.players_conduits
    ADD CONSTRAINT players_conduits_pkey PRIMARY KEY (player_id, conduit_id);


--
--
--

ALTER TABLE ONLY public.players_covenants
    ADD CONSTRAINT players_covenants_pkey PRIMARY KEY (player_id);


--
--
--

ALTER TABLE ONLY public.players_items
    ADD CONSTRAINT players_items_pkey PRIMARY KEY (player_id);


--
--
--

ALTER TABLE ONLY public.players_legendaries
    ADD CONSTRAINT players_legendaries_pkey PRIMARY KEY (player_id);


--
--
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
--
--

ALTER TABLE ONLY public.players_pvp_talents
    ADD CONSTRAINT players_pvp_talents_pkey PRIMARY KEY (player_id, pvp_talent_id);


--
--
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_realm_id_blizzard_id_key UNIQUE (realm_id, blizzard_id);


--
--
--

ALTER TABLE ONLY public.players_soulbinds
    ADD CONSTRAINT players_soulbinds_pkey PRIMARY KEY (player_id);


--
--
--

ALTER TABLE ONLY public.players_stats
    ADD CONSTRAINT players_stats_pkey PRIMARY KEY (player_id);


--
--
--

ALTER TABLE ONLY public.players_talents
    ADD CONSTRAINT players_talents_pkey PRIMARY KEY (player_id, talent_id);


--
--
--

ALTER TABLE ONLY public.pvp_talents
    ADD CONSTRAINT pvp_talents_pkey PRIMARY KEY (id);


--
--
--

ALTER TABLE ONLY public.races
    ADD CONSTRAINT races_pkey PRIMARY KEY (id);


--
--
--

ALTER TABLE ONLY public.realms
    ADD CONSTRAINT realms_pkey PRIMARY KEY (id);


--
--
--

ALTER TABLE ONLY public.realms
    ADD CONSTRAINT realms_slug_region_key UNIQUE (slug, region);


--
--
--

ALTER TABLE ONLY public.soulbinds
    ADD CONSTRAINT soulbinds_pkey PRIMARY KEY (id);


--
--
--

ALTER TABLE ONLY public.specs
    ADD CONSTRAINT specs_pkey PRIMARY KEY (id);


--
--
--

ALTER TABLE ONLY public.talents
    ADD CONSTRAINT talents_pkey PRIMARY KEY (id);


--
--
--

CREATE INDEX leaderboards_ranking_idx ON public.leaderboards USING btree (ranking);


--
--
--

CREATE INDEX leaderboards_rating_idx ON public.leaderboards USING btree (rating);


--
--
--

CREATE INDEX players_class_id_spec_id_idx ON public.players USING btree (class_id, spec_id);


--
--
--

CREATE INDEX players_faction_id_race_id_idx ON public.players USING btree (faction_id, race_id);


--
--
--

CREATE INDEX players_guild_idx ON public.players USING btree (guild);


--
--
--

CREATE INDEX pvp_talents_spec_id_idx ON public.pvp_talents USING btree (spec_id);


--
--
--

CREATE INDEX talents_class_id_spec_id_idx ON public.talents USING btree (class_id, spec_id);


--
--
--

CREATE INDEX talents_tier_col_idx ON public.talents USING btree (tier, col);


--
--
--

ALTER TABLE ONLY public.leaderboards
    ADD CONSTRAINT leaderboards_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
--
--

ALTER TABLE ONLY public.players_achievements
    ADD CONSTRAINT players_achievements_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES public.achievements(id);


--
--
--

ALTER TABLE ONLY public.players_achievements
    ADD CONSTRAINT players_achievements_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
--
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id);


--
--
--

ALTER TABLE ONLY public.players_conduits
    ADD CONSTRAINT players_conduits_conduit_id_fkey FOREIGN KEY (conduit_id) REFERENCES public.conduits(id);


--
--
--

ALTER TABLE ONLY public.players_conduits
    ADD CONSTRAINT players_conduits_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
--
--

ALTER TABLE ONLY public.players_covenants
    ADD CONSTRAINT players_covenants_covenant_id_fkey FOREIGN KEY (covenant_id) REFERENCES public.covenants(id);


--
--
--

ALTER TABLE ONLY public.players_covenants
    ADD CONSTRAINT players_covenants_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
--
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_faction_id_fkey FOREIGN KEY (faction_id) REFERENCES public.factions(id);


--
--
--

ALTER TABLE ONLY public.players_items
    ADD CONSTRAINT players_items_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
--
--

ALTER TABLE ONLY public.players_legendaries
    ADD CONSTRAINT players_legendaries_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
--
--

ALTER TABLE ONLY public.players_pvp_talents
    ADD CONSTRAINT players_pvp_talents_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
--
--

ALTER TABLE ONLY public.players_pvp_talents
    ADD CONSTRAINT players_pvp_talents_pvp_talent_id_fkey FOREIGN KEY (pvp_talent_id) REFERENCES public.pvp_talents(id);


--
--
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_race_id_fkey FOREIGN KEY (race_id) REFERENCES public.races(id);


--
--
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_realm_id_fkey FOREIGN KEY (realm_id) REFERENCES public.realms(id);


--
--
--

ALTER TABLE ONLY public.players_soulbinds
    ADD CONSTRAINT players_soulbinds_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
--
--

ALTER TABLE ONLY public.players_soulbinds
    ADD CONSTRAINT players_soulbinds_soulbind_id_fkey FOREIGN KEY (soulbind_id) REFERENCES public.soulbinds(id);


--
--
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_spec_id_fkey FOREIGN KEY (spec_id) REFERENCES public.specs(id);


--
--
--

ALTER TABLE ONLY public.players_stats
    ADD CONSTRAINT players_stats_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
--
--

ALTER TABLE ONLY public.players_talents
    ADD CONSTRAINT players_talents_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
--
--

ALTER TABLE ONLY public.players_talents
    ADD CONSTRAINT players_talents_talent_id_fkey FOREIGN KEY (talent_id) REFERENCES public.talents(id);


--
--
--

ALTER TABLE ONLY public.pvp_talents
    ADD CONSTRAINT pvp_talents_spec_id_fkey FOREIGN KEY (spec_id) REFERENCES public.specs(id);


--
--
--

ALTER TABLE ONLY public.specs
    ADD CONSTRAINT specs_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id);


--
--
--

ALTER TABLE ONLY public.talents
    ADD CONSTRAINT talents_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id);


--
--
--

ALTER TABLE ONLY public.talents
    ADD CONSTRAINT talents_spec_id_fkey FOREIGN KEY (spec_id) REFERENCES public.specs(id);


--
--
--

