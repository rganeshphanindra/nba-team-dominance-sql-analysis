# NBA Team Dominance — SQL Analysis (PostgreSQL)

## Overview

This project analyzes NBA team performance across seasons and eras using **SQL as the primary analytical tool**.

The objective is not just to count wins or rank teams, but to understand:

- how teams actually win  
- how performance evolves over time  
- which teams were truly dominant relative to their league context  

This is a **SQL-first project**.  
Python and Jupyter are used only for query execution and result visualization.  
All analytical logic, transformations, and metrics are implemented in SQL.

---

## Data Modeling Approach

Rather than querying raw data directly, this project follows a **three-layer analytics architecture**:

raw → staging → analytics

yaml
Copy code

This mirrors real-world data engineering and analytics workflows used in production environments.

---

## Raw Layer

The `raw` schema contains data exactly as received from the source.

**Characteristics:**
- No transformations  
- No cleaning  
- No assumptions  
- One-to-one mapping with the original dataset  

**Purpose:**  
The raw layer exists for **traceability**.  
If downstream results appear incorrect, this layer provides a reliable source of truth.

---

## Staging Layer

The `staging` schema standardizes and cleans the raw data.

**Responsibilities:**
- Data type casting (strings → integers, dates, booleans)  
- Handling nulls and invalid values  
- Column name normalization  
- Resolving inconsistent formats across tables  

No analysis is performed at this stage.  
The goal is to produce **clean, reliable, and reusable inputs** for analytics.

Handling data quality issues once in staging prevents logic duplication and downstream errors.

---

## Analytics Layer

The `analytics` schema contains **analysis-ready tables**.

This is where business logic lives:

- Fact tables defined at the correct grain  
- Dimension tables for teams and seasons  
- Reusable metrics designed for multiple analytical queries  

**Examples:**
- `fact_team_game`: one row per team per game  
- `dim_team`, `dim_season`: descriptive context tables  

By the time data reaches this layer:
- joins are simple  
- queries are readable  
- logic is reusable and consistent  

This separation makes the analysis scalable and easier to reason about.

---

## Key Analytical Questions

This project answers **seven focused analytical questions**.  
Each query is designed to demonstrate a specific SQL concept and analytical skill.

---

### Query 1 — Team Performance Over Time

**Question**  
How has each team performed season by season, and how is that performance trending?

**What this shows**
- Season-level win percentage  
- Year-over-year change using `LAG`  
- Short-term momentum via a 3-season rolling average  

**Why it matters**  
Single-season success can be noisy. Trends reveal sustained performance.

**SQL concepts used**
- CTEs  
- Window functions  
- Rolling averages  

---

### Query 2 — Home vs Away Performance

**Question**  
Is home-court advantage real, and how large is it?

**What this shows**
- Win percentage at home vs away  
- Home-minus-away performance gap per season  

**Why it matters**  
Some teams rely heavily on home advantage, while others perform consistently regardless of venue.

**SQL concepts used**
- Conditional aggregation  
- CASE-based pivot logic  

---

### Query 3 — Era-wise Improvements and Declines

**Question**  
Which teams experienced the biggest improvements or collapses across different eras?

**What this shows**
- Largest year-over-year performance jumps  
- Steepest declines  
- Grouping by decade (1940s, 1950s, etc.)  

**Why it matters**  
League pace, rules, and talent distribution change over time.  
This avoids unfair cross-era comparisons.

**SQL concepts used**
- Window functions  
- Ranking within partitions  
- Decade-based grouping  

---

### Query 4 — Sustained Dominance

**Question**  
Which teams remained elite across multiple seasons?

**What this shows**
- 5-season rolling win percentage  
- Performance stability measured using standard deviation  

**Why it matters**  
True dominance is sustained, not accidental.

**SQL concepts used**
- Rolling windows  
- Statistical aggregation  
- Ranking  

---

### Query 5 — Are Wins Backed by Control?

**Question**  
Are teams winning close games, or consistently dominating opponents?

**What this shows**
- Average point differential  
- Rolling 3-season point differential trends  

**Why it matters**  
Win percentage alone can mask underlying performance quality.

**SQL concepts used**
- Derived metrics  
- Rolling averages  

---

### Query 6 — Offense vs Defense

**Question**  
Are teams winning because they score more, or because they defend better?

**What this shows**
- Average points scored  
- Average points allowed  
- Net point differential  
- Defensive ranking based on points allowed  

**Why it matters**  
Teams succeed through very different strategic profiles.

**SQL concepts used**
- Aggregations  
- Ranking  
- Metric comparison  

---

### Query 7 — Era-Normalized Dominance

**Question**  
How dominant was a team relative to its own league, not historical extremes?

**What this shows**
- Team performance vs league average within the same season  
- Normalized point differential  
- Fair cross-era comparison  

**Why it matters**  
This avoids directly comparing fundamentally different eras of basketball.

**SQL concepts used**
- Subqueries  
- Joins between team-level and league-level aggregates  
- Normalization logic  

---

## Tools Used

- PostgreSQL  
- Advanced SQL  
- Jupyter Notebook (execution and visualization only)

---

## Repository Structure

nba-team-dominance-sql-analysis/
├── SQL/
│ ├── create_schema.sql
│ ├── create_raw_tables.sql
│ ├── create_staging_tables.sql
│ ├── create_analytics_tables.sql
│ ├── load_raw_tables.sql
│ └── all_queries.sql
│
├── notebooks/
│ └── NBA_SQL_Analysis.ipynb
│
├── README.md
└── .gitignore

yaml
Copy code

---

## Final Notes

This project is designed to be **read and reviewed**, not just executed.

Its purpose is to demonstrate:
- clear analytical thinking  
- strong SQL fundamentals  
- comfort with data modeling  
- the ability to turn raw data into meaningful insight  

This reflects how I would approach an analytics problem in a real production environment.
