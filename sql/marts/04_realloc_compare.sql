-- Baseline totals
SELECT
  'Baseline' AS version,
  SUM(spend) AS spend,
  SUM(revenue) AS revenue,
  SUM(revenue) * 1.0 / NULLIF(SUM(spend),0) AS roas
FROM int_campaign_segments

UNION ALL

-- Median scenario totals
SELECT
  'Scenario: Reallocate below-median ROAS spend' AS version,
  SUM(new_spend) AS spend,
  SUM(new_revenue) AS revenue,
  SUM(new_revenue) * 1.0 / NULLIF(SUM(new_spend),0) AS roas
FROM mart_reallocation_median_scenario

UNION ALL

-- Quintile scenario totals
SELECT
  'Scenario: Reallocate bottom ROAS quintile spend' AS version,
  SUM(new_spend) AS spend,
  SUM(new_revenue) AS revenue,
  SUM(new_revenue) * 1.0 / NULLIF(SUM(new_spend),0) AS roas
FROM mart_reallocation_quintile_scenario;
