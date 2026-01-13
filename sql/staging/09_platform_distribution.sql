WITH base AS (
  SELECT platform, 'spend' AS metric, spend AS val FROM raw_ppc_campaign_performance
  UNION ALL SELECT platform, 'revenue', revenue FROM raw_ppc_campaign_performance
  UNION ALL SELECT platform, 'clicks', clicks FROM raw_ppc_campaign_performance
  UNION ALL SELECT platform, 'conversions', conversions FROM raw_ppc_campaign_performance
),
ranked AS (
  SELECT
    platform, metric, val,
    NTILE(100) OVER (PARTITION BY platform, metric ORDER BY val) AS pct
  FROM base
),
p as (
SELECT
  platform,
  metric,
  MAX(CASE WHEN pct = 50 THEN val END) AS median,
  MAX(CASE WHEN pct = 90 THEN val END) AS p90,
  MAX(CASE WHEN pct = 95 THEN val END) AS p95,
  MAX(CASE WHEN pct = 95 THEN val END) - MAX(CASE WHEN pct = 50 THEN val END) AS p95_to_median_diff
FROM ranked
GROUP BY platform, metric
ORDER BY metric, platform
)
SELECT
  platform,
  metric,
  median,
  p90,
  p95,
  (p95 - median) AS spread_p95_minus_median
FROM p
ORDER BY metric, spread_p95_minus_median DESC;