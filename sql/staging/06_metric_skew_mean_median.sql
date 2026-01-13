WITH base AS (
  SELECT 'spend' AS metric, spend AS val
  FROM raw_ppc_campaign_performance
  UNION ALL
  SELECT 'clicks', clicks
  FROM raw_ppc_campaign_performance
  UNION ALL
  SELECT 'conversions', conversions
  FROM raw_ppc_campaign_performance
  UNION ALL
  SELECT 'revenue', revenue
  FROM raw_ppc_campaign_performance
),
ranked AS (
  SELECT metric, val,
    ROW_NUMBER() OVER (PARTITION BY metric ORDER BY val) AS rn,
    COUNT(*) OVER (PARTITION BY metric) AS cnt
  FROM base
),
stats AS (
  SELECT metric, AVG(val) AS mean,
    AVG(
      CASE
        WHEN rn IN (CAST((cnt + 1) / 2 AS INTEGER), CAST((cnt + 2) / 2 AS INTEGER)) THEN val
      END
    ) AS median
  FROM ranked
  GROUP BY metric
)
SELECT metric, mean, median,
  CASE
    WHEN mean > median * 1.05 THEN 'Right Skewed'
    WHEN mean < median * 0.95 THEN 'Left Skewed'
    ELSE 'Symmetric (Not Skewed)'
  END AS skew_type
FROM stats
ORDER BY metric;
