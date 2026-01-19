-- RAW TABLES (mirror CSV columns, keep as TEXT)

DROP TABLE IF EXISTS raw.inactive_players;
DROP TABLE IF EXISTS raw.draft_history;
DROP TABLE IF EXISTS raw.common_player_info;
DROP TABLE IF EXISTS raw.player;
DROP TABLE IF EXISTS raw.game_info;
DROP TABLE IF EXISTS raw.line_score;
DROP TABLE IF EXISTS raw.game;
DROP TABLE IF EXISTS raw.team;

CREATE TABLE raw.game (
  season_id TEXT,
  team_id_home TEXT,
  team_abbreviation_home TEXT,
  team_name_home TEXT,
  game_id TEXT,
  game_date TEXT,
  matchup_home TEXT,
  wl_home TEXT,
  min TEXT,
  fgm_home TEXT,
  fga_home TEXT,
  fg_pct_home TEXT,
  fg3m_home TEXT,
  fg3a_home TEXT,
  fg3_pct_home TEXT,
  ftm_home TEXT,
  fta_home TEXT,
  ft_pct_home TEXT,
  oreb_home TEXT,
  dreb_home TEXT,
  reb_home TEXT,
  ast_home TEXT,
  stl_home TEXT,
  blk_home TEXT,
  tov_home TEXT,
  pf_home TEXT,
  pts_home TEXT,
  plus_minus_home TEXT,
  video_available_home TEXT,
  team_id_away TEXT,
  team_abbreviation_away TEXT,
  team_name_away TEXT,
  matchup_away TEXT,
  wl_away TEXT,
  fgm_away TEXT,
  fga_away TEXT,
  fg_pct_away TEXT,
  fg3m_away TEXT,
  fg3a_away TEXT,
  fg3_pct_away TEXT,
  ftm_away TEXT,
  fta_away TEXT,
  ft_pct_away TEXT,
  oreb_away TEXT,
  dreb_away TEXT,
  reb_away TEXT,
  ast_away TEXT,
  stl_away TEXT,
  blk_away TEXT,
  tov_away TEXT,
  pf_away TEXT,
  pts_away TEXT,
  plus_minus_away TEXT,
  video_available_away TEXT,
  season_type TEXT
);

CREATE TABLE raw.team (
  id TEXT,
  full_name TEXT,
  abbreviation TEXT,
  nickname TEXT,
  city TEXT,
  state TEXT,
  year_founded TEXT
);

CREATE TABLE raw.line_score (
  game_date_est TEXT,
  game_sequence TEXT,
  game_id TEXT,
  team_id_home TEXT,
  team_abbreviation_home TEXT,
  team_city_name_home TEXT,
  team_nickname_home TEXT,
  team_wins_losses_home TEXT,
  pts_qtr1_home TEXT,
  pts_qtr2_home TEXT,
  pts_qtr3_home TEXT,
  pts_qtr4_home TEXT,
  pts_ot1_home TEXT,
  pts_ot2_home TEXT,
  pts_ot3_home TEXT,
  pts_ot4_home TEXT,
  pts_ot5_home TEXT,
  pts_ot6_home TEXT,
  pts_ot7_home TEXT,
  pts_ot8_home TEXT,
  pts_ot9_home TEXT,
  pts_ot10_home TEXT,
  pts_home TEXT,
  team_id_away TEXT,
  team_abbreviation_away TEXT,
  team_city_name_away TEXT,
  team_nickname_away TEXT,
  team_wins_losses_away TEXT,
  pts_qtr1_away TEXT,
  pts_qtr2_away TEXT,
  pts_qtr3_away TEXT,
  pts_qtr4_away TEXT,
  pts_ot1_away TEXT,
  pts_ot2_away TEXT,
  pts_ot3_away TEXT,
  pts_ot4_away TEXT,
  pts_ot5_away TEXT,
  pts_ot6_away TEXT,
  pts_ot7_away TEXT,
  pts_ot8_away TEXT,
  pts_ot9_away TEXT,
  pts_ot10_away TEXT,
  pts_away TEXT
);

CREATE TABLE raw.game_info (
  game_id TEXT,
  game_date TEXT,
  attendance TEXT,
  game_time TEXT
);

CREATE TABLE raw.player (
  id TEXT,
  full_name TEXT,
  first_name TEXT,
  last_name TEXT,
  is_active TEXT
);

CREATE TABLE raw.common_player_info (
  person_id TEXT,
  first_name TEXT,
  last_name TEXT,
  display_first_last TEXT,
  display_last_comma_first TEXT,
  display_fi_last TEXT,
  player_slug TEXT,
  birthdate TEXT,
  school TEXT,
  country TEXT,
  last_affiliation TEXT,
  height TEXT,
  weight TEXT,
  season_exp TEXT,
  jersey TEXT,
  position TEXT,
  rosterstatus TEXT,
  games_played_current_season_flag TEXT,
  team_id TEXT,
  team_name TEXT,
  team_abbreviation TEXT,
  team_code TEXT,
  team_city TEXT,
  playercode TEXT,
  from_year TEXT,
  to_year TEXT,
  dleague_flag TEXT,
  nba_flag TEXT,
  games_played_flag TEXT,
  draft_year TEXT,
  draft_round TEXT,
  draft_number TEXT,
  greatest_75_flag TEXT
);

CREATE TABLE raw.draft_history (
  person_id TEXT,
  player_name TEXT,
  season TEXT,
  round_number TEXT,
  round_pick TEXT,
  overall_pick TEXT,
  draft_type TEXT,
  team_id TEXT,
  team_city TEXT,
  team_name TEXT,
  team_abbreviation TEXT,
  organization TEXT,
  organization_type TEXT,
  player_profile_flag TEXT
);

CREATE TABLE raw.inactive_players (
  game_id TEXT,
  player_id TEXT,
  first_name TEXT,
  last_name TEXT,
  jersey_num TEXT,
  team_id TEXT,
  team_city TEXT,
  team_name TEXT,
  team_abbreviation TEXT
);

-- Confirm tables exist
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema='raw'
ORDER BY table_name;
