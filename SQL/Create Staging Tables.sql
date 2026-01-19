\set ON_ERROR_STOP on

-- Clean rerun (drop in correct dependency order)
DROP TABLE IF EXISTS staging.inactive_players;
DROP TABLE IF EXISTS staging.game_info;
DROP TABLE IF EXISTS staging.line_score;
DROP TABLE IF EXISTS staging.game;
DROP TABLE IF EXISTS staging.draft_history;
DROP TABLE IF EXISTS staging.common_player_info;
DROP TABLE IF EXISTS staging.player;
DROP TABLE IF EXISTS staging.team;

-- TEAM
CREATE TABLE staging.team AS
SELECT
  NULLIF(id,'')::numeric::bigint          AS team_id,
  NULLIF(full_name,'')                   AS team_full_name,
  NULLIF(abbreviation,'')                AS team_abbreviation,
  NULLIF(nickname,'')                    AS team_nickname,
  NULLIF(city,'')                        AS team_city,
  NULLIF(state,'')                       AS team_state,
  NULLIF(year_founded,'')::numeric::int  AS year_founded
FROM raw.team;

ALTER TABLE staging.team
  ADD CONSTRAINT pk_staging_team PRIMARY KEY (team_id);

-- PLAYER
CREATE TABLE staging.player AS
SELECT
  NULLIF(id,'')::numeric::bigint AS player_id,
  NULLIF(full_name,'')          AS full_name,
  NULLIF(first_name,'')         AS first_name,
  NULLIF(last_name,'')          AS last_name,
  CASE
    WHEN lower(NULLIF(is_active,'')) IN ('true','t','1','yes','y') THEN true
    WHEN lower(NULLIF(is_active,'')) IN ('false','f','0','no','n') THEN false
    ELSE NULL
  END                           AS is_active
FROM raw.player;

ALTER TABLE staging.player
  ADD CONSTRAINT pk_staging_player PRIMARY KEY (player_id);

-- COMMON PLAYER INFO (fix: 'Undrafted' -> NULL for draft fields)
CREATE TABLE staging.common_player_info AS
SELECT
  NULLIF(person_id,'')::numeric::bigint      AS player_id,
  NULLIF(first_name,'')                     AS first_name,
  NULLIF(last_name,'')                      AS last_name,
  NULLIF(birthdate,'')::date                AS birthdate,
  NULLIF(school,'')                         AS school,
  NULLIF(country,'')                        AS country,
  NULLIF(last_affiliation,'')               AS last_affiliation,
  NULLIF(height,'')                         AS height,
  NULLIF(weight,'')::numeric::int           AS weight,
  NULLIF(season_exp,'')::numeric::int       AS season_exp,
  NULLIF(jersey,'')                         AS jersey,
  NULLIF(position,'')                       AS position,
  NULLIF(rosterstatus,'')                   AS roster_status,
  NULLIF(team_id,'')::numeric::bigint       AS current_team_id,
  NULLIF(team_name,'')                      AS current_team_name,
  NULLIF(team_abbreviation,'')              AS current_team_abbreviation,
  NULLIF(team_city,'')                      AS current_team_city,
  NULLIF(from_year,'')::numeric::int        AS from_year,
  NULLIF(to_year,'')::numeric::int          AS to_year,
  CASE WHEN NULLIF(draft_year,'') ~ '^\d+(\.0)?$' THEN NULLIF(draft_year,'')::numeric::int END AS draft_year,
  CASE WHEN NULLIF(draft_round,'') ~ '^\d+(\.0)?$' THEN NULLIF(draft_round,'')::numeric::int END AS draft_round,
  CASE WHEN NULLIF(draft_number,'') ~ '^\d+(\.0)?$' THEN NULLIF(draft_number,'')::numeric::int END AS draft_number,
  CASE
    WHEN lower(NULLIF(greatest_75_flag,'')) IN ('true','t','1','yes','y') THEN true
    WHEN lower(NULLIF(greatest_75_flag,'')) IN ('false','f','0','no','n') THEN false
    ELSE NULL
  END                                       AS greatest_75_flag
FROM raw.common_player_info;

-- DRAFT HISTORY
CREATE TABLE staging.draft_history AS
SELECT
  NULLIF(person_id,'')::numeric::bigint        AS player_id,
  NULLIF(player_name,'')                      AS player_name,
  NULLIF(season,'')::numeric::int             AS draft_season_year,
  NULLIF(round_number,'')::numeric::int       AS round_number,
  NULLIF(round_pick,'')::numeric::int         AS round_pick,
  NULLIF(overall_pick,'')::numeric::int       AS overall_pick,
  NULLIF(draft_type,'')                       AS draft_type,
  NULLIF(team_id,'')::numeric::bigint         AS team_id,
  NULLIF(team_city,'')                        AS team_city,
  NULLIF(team_name,'')                        AS team_name,
  NULLIF(team_abbreviation,'')                AS team_abbreviation,
  NULLIF(organization,'')                     AS organization,
  NULLIF(organization_type,'')                AS organization_type,
  CASE
    WHEN lower(NULLIF(player_profile_flag,'')) IN ('true','t','1','yes','y') THEN true
    WHEN lower(NULLIF(player_profile_flag,'')) IN ('false','f','0','no','n') THEN false
    ELSE NULL
  END                                         AS player_profile_flag
FROM raw.draft_history;

-- GAME (fix: dedupe by game_id before PK)
CREATE TABLE staging.game AS
WITH g AS (
  SELECT
    NULLIF(game_id,'')::numeric::bigint             AS game_id,
    NULLIF(season_id,'')::numeric::int              AS season_id,
    NULLIF(season_type,'')                          AS season_type,
    CASE
      WHEN NULLIF(game_date,'') ~ '^\d{4}-\d{2}-\d{2}$' THEN game_date::date
      ELSE NULL
    END                                             AS game_date,
    NULLIF(team_id_home,'')::numeric::bigint        AS home_team_id,
    NULLIF(team_abbreviation_home,'')               AS home_team_abbr,
    NULLIF(team_name_home,'')                       AS home_team_name,
    NULLIF(wl_home,'')                              AS home_result,
    NULLIF(pts_home,'')::numeric::int               AS home_pts,
    NULLIF(team_id_away,'')::numeric::bigint        AS away_team_id,
    NULLIF(team_abbreviation_away,'')               AS away_team_abbr,
    NULLIF(team_name_away,'')                       AS away_team_name,
    NULLIF(wl_away,'')                              AS away_result,
    NULLIF(pts_away,'')::numeric::int               AS away_pts,
    NULLIF(min,'')::numeric::int                    AS minutes,
    NULLIF(plus_minus_home,'')::numeric::int        AS home_plus_minus,
    NULLIF(plus_minus_away,'')::numeric::int        AS away_plus_minus
  FROM raw.game
),
dedup AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY game_id ORDER BY game_date DESC NULLS LAST) AS rn
  FROM g
  WHERE game_id IS NOT NULL
)
SELECT
  game_id, season_id, season_type, game_date,
  home_team_id, home_team_abbr, home_team_name, home_result, home_pts,
  away_team_id, away_team_abbr, away_team_name, away_result, away_pts,
  minutes, home_plus_minus, away_plus_minus
FROM dedup
WHERE rn = 1;

ALTER TABLE staging.game
  ADD CONSTRAINT pk_staging_game PRIMARY KEY (game_id);

-- LINE SCORE
CREATE TABLE staging.line_score AS
SELECT
  NULLIF(game_id,'')::numeric::bigint             AS game_id,
  CASE
    WHEN NULLIF(game_date_est,'') ~ '^\d{4}-\d{2}-\d{2}$' THEN game_date_est::date
    ELSE NULL
  END                                             AS game_date_est,
  NULLIF(team_id_home,'')::numeric::bigint        AS home_team_id,
  NULLIF(pts_home,'')::numeric::int               AS home_pts,
  NULLIF(team_id_away,'')::numeric::bigint        AS away_team_id,
  NULLIF(pts_away,'')::numeric::int               AS away_pts
FROM raw.line_score;

-- GAME INFO
CREATE TABLE staging.game_info AS
SELECT
  NULLIF(game_id,'')::numeric::bigint    AS game_id,
  CASE
    WHEN NULLIF(game_date,'') ~ '^\d{4}-\d{2}-\d{2}$' THEN game_date::date
    ELSE NULL
  END                                    AS game_date,
  NULLIF(attendance,'')::numeric::int    AS attendance,
  NULLIF(game_time,'')                   AS game_time
FROM raw.game_info;

-- INACTIVE PLAYERS
CREATE TABLE staging.inactive_players AS
SELECT
  NULLIF(game_id,'')::numeric::bigint      AS game_id,
  NULLIF(player_id,'')::numeric::bigint    AS player_id,
  NULLIF(team_id,'')::numeric::bigint      AS team_id,
  NULLIF(jersey_num,'')                    AS jersey_num
FROM raw.inactive_players;

-- QC counts
SELECT 'staging.team' AS table_name, COUNT(*) AS row_count FROM staging.team
UNION ALL SELECT 'staging.player', COUNT(*) FROM staging.player
UNION ALL SELECT 'staging.common_player_info', COUNT(*) FROM staging.common_player_info
UNION ALL SELECT 'staging.draft_history', COUNT(*) FROM staging.draft_history
UNION ALL SELECT 'staging.game', COUNT(*) FROM staging.game
UNION ALL SELECT 'staging.line_score', COUNT(*) FROM staging.line_score
UNION ALL SELECT 'staging.game_info', COUNT(*) FROM staging.game_info
UNION ALL SELECT 'staging.inactive_players', COUNT(*) FROM staging.inactive_players
ORDER BY table_name;
