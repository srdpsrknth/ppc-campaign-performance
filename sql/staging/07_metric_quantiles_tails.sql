WITH base AS (
  SELECT 'spend' AS metric, spend AS val FROM raw_ppc_campaign_performance
  UNION ALL SELECT 'clicks', clicks FROM raw_ppc_campaign_performance
  UNION ALL SELECT 'conversions', conversions FROM raw_ppc_campaign_performance
  UNION ALL SELECT 'revenue', revenue FROM raw_ppc_campaign_performance
),
ranked AS (
  SELECT
    metric,
    val,
    NTILE(100) OVER (PARTITION BY metric ORDER BY val) AS pct
  FROM base
),
q AS (
  SELECT
    metric,
    MAX(CASE WHEN pct = 10 THEN val END) AS p10,
    MAX(CASE WHEN pct = 50 THEN val END) AS p50,
    MAX(CASE WHEN pct = 90 THEN val END) AS p90,
    MAX(CASE WHEN pct = 95 THEN val END) AS p95,
    MAX(CASE WHEN pct = 99 THEN val END) AS p99
  FROM ranked
  GROUP BY metric
),
tail AS (
  SELECT
    metric,
    SUM(CASE WHEN pct >= 95 THEN val ELSE 0 END) * 1.0 / NULLIF(SUM(val),0) AS share_top5pct
  FROM ranked
  GROUP BY metric
)
SELECT
  q.metric,
  q.p10, q.p50, q.p90, q.p95, q.p99, q.p99/q.p50 as p99_to_median_ratio,
  tail.share_top5pct
FROM q
JOIN tail USING(metric)
ORDER BY q.metric;
