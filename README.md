NBA Team Dominance — SQL Analysis (PostgreSQL)
Overview

This project analyzes NBA team performance across seasons and eras using SQL as the primary tool.
The goal is to understand how teams win, how performance changes over time, and which teams were truly dominant relative to their competition.

This is a SQL-first analytics project.
Python and Jupyter are only used to run queries and visualize results, not to replace SQL logic.

Key Questions Explored

This project focuses on seven core analytical questions:

How has each team performed season-by-season?
Win percentage, year-over-year change, and short-term performance trends using rolling windows.

Is there a real home-court advantage?
Comparison of home vs away performance and the size of the home-advantage gap.

Which teams improved or declined the most, era by era?
Biggest year-over-year jumps and drops in win percentage, grouped by decade.

Which teams showed sustained dominance over multiple seasons?
Five-season rolling win percentage combined with stability (low volatility).

Are wins backed by actual dominance?
Using average point differential and rolling averages to separate close wins from true control.

Are teams winning because of offense or defense?
Breaking down scoring vs points allowed to see what drives success.

Who were the most dominant teams relative to their league context?
Normalizing performance against league averages to compare teams across eras fairly.

Why This Matters

Raw stats don’t tell the full story in sports analytics.

A 1970s team and a 2010s team cannot be compared directly without context.

Win percentage alone doesn’t explain how teams win.

Era-normalized metrics help separate true dominance from inflated raw numbers.

This project explicitly addresses those problems using SQL.

Technical Stack

Database: PostgreSQL

Querying: Advanced SQL

Analysis Style: Analytics-engineering approach

Notebook: Jupyter (query execution + visualization only)

SQL Techniques Used

This project intentionally demonstrates production-level SQL skills:

Common Table Expressions (CTEs)

Window functions (LAG, AVG OVER, STDDEV)

Rolling metrics (3-season, 5-season windows)

Ranking and dense ranking

Conditional aggregation

Era / decade grouping

League-normalized comparisons

Clean schema separation (staging → analytics)

All analytical logic lives in SQL.

About the Data

The project uses a public NBA historical dataset (games, teams, scoring data).

Raw data files are not included in this repository due to size limits.
The focus here is on query logic and analytical thinking, not data hosting.

Instructions for sourcing the data are described inside the notebook.

How to Use This Project

Read the SQL files to understand the analytical logic.

Use the notebook to see:

how queries are executed

how results are interpreted

simple visualizations that support the SQL analysis
