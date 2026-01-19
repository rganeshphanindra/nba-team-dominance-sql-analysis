\set ON_ERROR_STOP on

-- Clean rerun
DROP TABLE IF EXISTS analytics.fact_team_game;
DROP TABLE IF EXISTS analytics.fact_game;
DROP TABLE IF EXISTS analytics.dim_season;
DROP TABLE IF EXISTS analytics.dim_team;

-- DIM: TEAM
CREATE TABLE analytics.dim_team AS
SELECT
  team_id,
  team_full_name,
  team_abbreviation,
  team_nickname,
  team_city,
  team_state,
  year_founded
FROM staging.team;

ALTER TABLE analytics.dim_team
  ADD CONSTRAINT pk_dim_team PRIMARY KEY (team_id);

-- DIM: SEASON (derived from staging.game)
-- season_id in this dataset is typically like 22022 (NBA season) or similar.
-- We keep season_id and also extract a readable season_year if possible.
CREATE TABLE analytics.dim_season AS
WITH s AS (
  SELECT DISTINCT season_id
  FROM staging.game
  WHERE season_id IS NOT NULL
)
SELECT
  season_id,
  CASE
    WHEN season_id BETWEEN 20000 AND 29999 THEN (season_id - 20000)  -- e.g., 22022 -> 2022
    ELSE NULL
  END AS season_year
FROM s;

ALTER TABLE analytics.dim_season
  ADD CONSTRAINT pk_dim_season PRIMARY KEY (season_id);

-- FACT: GAME (one row per game)
CREATE TABLE analytics.fact_game AS
SELECT
  g.game_id,
  g.season_id,
  g.season_type,
  COALESCE(g.game_date, ls.game_date_est, gi.game_date) AS game_date,
  g.home_team_id,
  g.away_team_id,
  g.home_pts,
  g.away_pts,
  CASE
    WHEN g.home_pts IS NOT NULL AND g.away_pts IS NOT NULL AND g.home_pts > g.away_pts THEN g.home_team_id
    WHEN g.home_pts IS NOT NULL AND g.away_pts IS NOT NULL AND g.away_pts > g.home_pts THEN g.away_team_id
    ELSE NULL
  END AS winner_team_id
FROM staging.game g
LEFT JOIN staging.line_score ls ON ls.game_id = g.game_id
LEFT JOIN staging.game_info gi  ON gi.game_id = g.game_id;

ALTER TABLE analytics.fact_game
  ADD CONSTRAINT pk_fact_game PRIMARY KEY (game_id);

-- FACT: TEAM_GAME (two rows per game: home + away)
CREATE TABLE analytics.fact_team_game AS
WITH base AS (
  SELECT
    g.game_id,
    g.season_id,
    g.season_type,
    COALESCE(g.game_date, ls.game_date_est, gi.game_date) AS game_date,
    g.home_team_id,
    g.away_team_id,
    g.home_pts,
    g.away_pts
  FROM staging.game g
  LEFT JOIN staging.line_score ls ON ls.game_id = g.game_id
  LEFT JOIN staging.game_info gi  ON gi.game_id = g.game_id
  WHERE g.home_team_id IS NOT NULL AND g.away_team_id IS NOT NULL
),
home AS (
  SELECT
    game_id, season_id, season_type, game_date,
    home_team_id AS team_id,
    away_team_id AS opponent_team_id,
    'H'::text AS home_away,
    home_pts AS pts_for,
    away_pts AS pts_against
  FROM base
),
away AS (
  SELECT
    game_id, season_id, season_type, game_date,
    away_team_id AS team_id,
    home_team_id AS opponent_team_id,
    'A'::text AS home_away,
    away_pts AS pts_for,
    home_pts AS pts_against
  FROM base
)
SELECT
  *,
  CASE
    WHEN pts_for IS NOT NULL AND pts_against IS NOT NULL AND pts_for > pts_against THEN 1
    WHEN pts_for IS NOT NULL AND pts_against IS NOT NULL AND pts_for < pts_against THEN 0
    ELSE NULL
  END AS is_win,
  (pts_for - pts_against) AS point_diff
FROM (
  SELECT * FROM home
  UNION ALL
  SELECT * FROM away
) x;

-- Helpful indexes (real-world signal)
CREATE INDEX IF NOT EXISTS ix_fact_team_game_team_season ON analytics.fact_team_game (team_id, season_id);
CREATE INDEX IF NOT EXISTS ix_fact_team_game_game_date ON analytics.fact_team_game (game_date);

-- QC
SELECT 'analytics.dim_team' AS table_name, COUNT(*) AS row_count FROM analytics.dim_team
UNION ALL SELECT 'analytics.dim_season', COUNT(*) FROM analytics.dim_season
UNION ALL SELECT 'analytics.fact_game', COUNT(*) FROM analytics.fact_game
UNION ALL SELECT 'analytics.fact_team_game', COUNT(*) FROM analytics.fact_team_game
ORDER BY table_name;
