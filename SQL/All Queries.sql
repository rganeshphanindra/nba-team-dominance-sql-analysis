Query 1/7: Team season performance + YoY change + 3-season rolling win%

WITH team_season AS (
  SELECT
    ftg.team_id,
    dt.team_full_name,
    ftg.season_id,
    ds.season_year,
    COUNT(*) AS games_played,
    SUM(ftg.is_win) AS wins,
    COUNT(*) - SUM(ftg.is_win) AS losses,
    ROUND((SUM(ftg.is_win)::numeric / COUNT(*)) * 100, 2) AS win_pct
  FROM analytics.fact_team_game ftg
  JOIN analytics.dim_team dt
    ON dt.team_id = ftg.team_id
  LEFT JOIN analytics.dim_season ds
    ON ds.season_id = ftg.season_id
  WHERE ftg.is_win IS NOT NULL
  GROUP BY 1,2,3,4
),
trend AS (
  SELECT
    *,
    ROUND(win_pct - LAG(win_pct) OVER (PARTITION BY team_id ORDER BY season_id), 2) AS yoy_win_pct_change,
    ROUND(AVG(win_pct) OVER (
      PARTITION BY team_id
      ORDER BY season_id
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_3_season_win_pct
  FROM team_season
)
SELECT *
FROM trend
ORDER BY team_full_name, season_id;


Query 2/7: Home vs Away split by season (with “home advantage gap”)

WITH split AS (
  SELECT
    ftg.team_id,
    dt.team_full_name,
    ftg.season_id,
    ds.season_year,
    ftg.home_away,
    COUNT(*) AS games_played,
    SUM(ftg.is_win) AS wins,
    ROUND((SUM(ftg.is_win)::numeric / COUNT(*)) * 100, 2) AS win_pct
  FROM analytics.fact_team_game ftg
  JOIN analytics.dim_team dt
    ON dt.team_id = ftg.team_id
  LEFT JOIN analytics.dim_season ds
    ON ds.season_id = ftg.season_id
  WHERE ftg.is_win IS NOT NULL
  GROUP BY 1,2,3,4,5
),
pivoted AS (
  SELECT
    team_id,
    team_full_name,
    season_id,
    season_year,
    MAX(CASE WHEN home_away = 'H' THEN games_played END) AS home_games,
    MAX(CASE WHEN home_away = 'H' THEN wins END)        AS home_wins,
    MAX(CASE WHEN home_away = 'H' THEN win_pct END)     AS home_win_pct,
    MAX(CASE WHEN home_away = 'A' THEN games_played END) AS away_games,
    MAX(CASE WHEN home_away = 'A' THEN wins END)        AS away_wins,
    MAX(CASE WHEN home_away = 'A' THEN win_pct END)     AS away_win_pct
  FROM split
  GROUP BY 1,2,3,4
)
SELECT
  *,
  ROUND(home_win_pct - away_win_pct, 2) AS home_minus_away_win_pct
FROM pivoted
ORDER BY team_full_name, season_id;

Query 3/7: Era Wise Top 10 biggest YoY improvements + Top 10 biggest declines (league-wide)

WITH team_season AS (
  SELECT
    ftg.team_id,
    dt.team_full_name,
    ftg.season_id,
    ds.season_year,
    COUNT(*) AS games_played,
    ROUND((SUM(ftg.is_win)::numeric / COUNT(*)) * 100, 2) AS win_pct
  FROM analytics.fact_team_game ftg
  JOIN analytics.dim_team dt
    ON dt.team_id = ftg.team_id
  LEFT JOIN analytics.dim_season ds
    ON ds.season_id = ftg.season_id
  WHERE ftg.is_win IS NOT NULL
    AND ds.season_year IS NOT NULL
  GROUP BY 1,2,3,4
),
yoy AS (
  SELECT
    *,
    ROUND(win_pct - LAG(win_pct) OVER (PARTITION BY team_id ORDER BY season_id), 2) AS yoy_win_pct_change
  FROM team_season
),
filtered AS (
  SELECT *
  FROM yoy
  WHERE yoy_win_pct_change IS NOT NULL
    AND games_played >= 60
),
decades AS (
  SELECT
    *,
    (season_year / 10) * 10 AS decade
  FROM filtered
),
ranked AS (
  SELECT
    decade,
    team_full_name,
    season_year,
    season_id,
    games_played,
    win_pct,
    yoy_win_pct_change,
    DENSE_RANK() OVER (PARTITION BY decade ORDER BY yoy_win_pct_change DESC) AS improve_rnk,
    DENSE_RANK() OVER (PARTITION BY decade ORDER BY yoy_win_pct_change ASC)  AS decline_rnk
  FROM decades
)
SELECT
  decade,
  'TOP_IMPROVEMENTS' AS bucket,
  team_full_name,
  season_year,
  games_played,
  win_pct,
  yoy_win_pct_change,
  improve_rnk AS rnk
FROM ranked
WHERE improve_rnk <= 3

UNION ALL

SELECT
  decade,
  'TOP_DECLINES' AS bucket,
  team_full_name,
  season_year,
  games_played,
  win_pct,
  yoy_win_pct_change,
  decline_rnk AS rnk
FROM ranked
WHERE decline_rnk <= 3

ORDER BY decade, bucket, rnk;


Query 4/7: Sustained dominance (best 5-season rolling win% + stability)

WITH team_season AS (
  SELECT
    ftg.team_id,
    dt.team_full_name,
    ftg.season_id,
    ds.season_year,
    COUNT(*) AS games_played,
    ROUND((SUM(ftg.is_win)::numeric / COUNT(*)) * 100, 2) AS win_pct
  FROM analytics.fact_team_game ftg
  JOIN analytics.dim_team dt
    ON dt.team_id = ftg.team_id
  LEFT JOIN analytics.dim_season ds
    ON ds.season_id = ftg.season_id
  WHERE ftg.is_win IS NOT NULL
    AND ds.season_year IS NOT NULL
  GROUP BY 1,2,3,4
),
roll AS (
  SELECT
    *,
    ROUND(AVG(win_pct) OVER (
      PARTITION BY team_id
      ORDER BY season_id
      ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_5_season_win_pct,
    ROUND(STDDEV_SAMP(win_pct) OVER (
      PARTITION BY team_id
      ORDER BY season_id
      ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_5_season_win_pct_stddev
  FROM team_season
),
filtered AS (
  SELECT *
  FROM roll
  WHERE games_played >= 60
    AND rolling_5_season_win_pct IS NOT NULL
)
SELECT
  team_full_name,
  season_year,
  season_id,
  win_pct,
  rolling_5_season_win_pct,
  rolling_5_season_win_pct_stddev,
  RANK() OVER (ORDER BY rolling_5_season_win_pct DESC) AS rnk
FROM filtered
ORDER BY rolling_5_season_win_pct DESC
LIMIT 15;


Query 5/7 — Are wins backed by dominance?

WITH team_season_margin AS (
  SELECT
    ftg.team_id,
    dt.team_full_name,
    ftg.season_id,
    ds.season_year,
    COUNT(*) AS games_played,
    ROUND(AVG(ftg.point_diff), 2) AS avg_point_diff
  FROM analytics.fact_team_game ftg
  JOIN analytics.dim_team dt
    ON dt.team_id = ftg.team_id
  LEFT JOIN analytics.dim_season ds
    ON ds.season_id = ftg.season_id
  WHERE ftg.point_diff IS NOT NULL
    AND ds.season_year IS NOT NULL
  GROUP BY 1,2,3,4
),
rolling AS (
  SELECT
    *,
    ROUND(
      AVG(avg_point_diff) OVER (
        PARTITION BY team_id
        ORDER BY season_id
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
      ),
      2
    ) AS rolling_3yr_avg_point_diff
  FROM team_season_margin
),
filtered AS (
  SELECT *
  FROM rolling
  WHERE games_played >= 60
    AND rolling_3yr_avg_point_diff IS NOT NULL
)
SELECT
  team_full_name,
  season_year,
  avg_point_diff,
  rolling_3yr_avg_point_diff,
  RANK() OVER (ORDER BY rolling_3yr_avg_point_diff DESC) AS rnk
FROM filtered
ORDER BY rolling_3yr_avg_point_diff DESC
LIMIT 15;


Query 6/7 — Are teams winning because of offense or defense?

WITH team_season_scoring AS (
  SELECT
    ftg.team_id,
    dt.team_full_name,
    ftg.season_id,
    ds.season_year,
    COUNT(*) AS games_played,
    ROUND(AVG(ftg.pts_for), 2)     AS avg_points_for,
    ROUND(AVG(ftg.pts_against), 2) AS avg_points_against
  FROM analytics.fact_team_game ftg
  JOIN analytics.dim_team dt
    ON dt.team_id = ftg.team_id
  LEFT JOIN analytics.dim_season ds
    ON ds.season_id = ftg.season_id
  WHERE ds.season_year IS NOT NULL
  GROUP BY 1,2,3,4
),
metrics AS (
  SELECT
    *,
    ROUND(avg_points_for - avg_points_against, 2) AS net_point_diff
  FROM team_season_scoring
),
filtered AS (
  SELECT *
  FROM metrics
  WHERE games_played >= 60
)
SELECT
  team_full_name,
  season_year,
  avg_points_for,
  avg_points_against,
  net_point_diff,
  RANK() OVER (ORDER BY avg_points_against ASC) AS defensive_rank
FROM filtered
ORDER BY defensive_rank
LIMIT 15;


Query 7/7: Era-normalized dominance (vs league average in the same season)

WITH team_season AS (
  SELECT
    ftg.team_id,
    dt.team_full_name,
    ftg.season_id,
    ds.season_year,
    COUNT(*) AS games_played,
    ROUND(AVG(ftg.pts_for), 2)      AS avg_pts_for,
    ROUND(AVG(ftg.pts_against), 2)  AS avg_pts_against,
    ROUND(AVG(ftg.point_diff), 2)   AS avg_point_diff,
    ROUND((SUM(ftg.is_win)::numeric / COUNT(*)) * 100, 2) AS win_pct
  FROM analytics.fact_team_game ftg
  JOIN analytics.dim_team dt
    ON dt.team_id = ftg.team_id
  LEFT JOIN analytics.dim_season ds
    ON ds.season_id = ftg.season_id
  WHERE ds.season_year IS NOT NULL
    AND ftg.is_win IS NOT NULL
  GROUP BY 1,2,3,4
),
league_baseline AS (
  SELECT
    season_id,
    season_year,
    ROUND(AVG(avg_pts_for), 2)     AS lg_avg_pts_for,
    ROUND(AVG(avg_pts_against), 2) AS lg_avg_pts_against,
    ROUND(AVG(avg_point_diff), 2)  AS lg_avg_point_diff
  FROM team_season
  WHERE games_played >= 60
  GROUP BY 1,2
),
normalized AS (
  SELECT
    ts.team_full_name,
    ts.season_year,
    ts.season_id,
    ts.games_played,
    ts.win_pct,
    ts.avg_pts_for,
    ts.avg_pts_against,
    ts.avg_point_diff,
    lb.lg_avg_pts_for,
    lb.lg_avg_pts_against,
    lb.lg_avg_point_diff,
    ROUND(ts.avg_pts_for - lb.lg_avg_pts_for, 2)           AS pts_for_vs_lg,
    ROUND(ts.avg_pts_against - lb.lg_avg_pts_against, 2)   AS pts_against_vs_lg,
    ROUND(ts.avg_point_diff - lb.lg_avg_point_diff, 2)     AS point_diff_vs_lg
  FROM team_season ts
  JOIN league_baseline lb
    ON lb.season_id = ts.season_id
  WHERE ts.games_played >= 60
)
SELECT
  team_full_name,
  season_year,
  win_pct,
  avg_point_diff,
  point_diff_vs_lg,
  pts_for_vs_lg,
  pts_against_vs_lg,
  RANK() OVER (ORDER BY point_diff_vs_lg DESC) AS rnk
FROM normalized
ORDER BY rnk
LIMIT 20;

