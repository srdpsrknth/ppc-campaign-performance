-- CTR: clicks / impressions
SELECT
  COUNT(*) AS total_rows,
  SUM(
    CASE
      WHEN impressions > 0
       AND ctr IS NOT NULL
       AND ABS((clicks * 1.0 / impressions) - ctr) > 0.0001
      THEN 1 ELSE 0
    END
  ) AS ctr_mismatch_rows
FROM raw_ppc_campaign_performance;

-- CPC: spend / clicks
SELECT
  COUNT(*) AS total_rows,
  SUM(
    CASE
      WHEN clicks > 0
       AND cpc IS NOT NULL
       AND ABS((spend * 1.0 / clicks) - cpc) > 0.01
      THEN 1 ELSE 0
    END
  ) AS cpc_spend_mismatch_rows
FROM raw_ppc_campaign_performance;

-- ROAS: revenue / spend
SELECT
  COUNT(*) AS total_rows,
  SUM(
    CASE
      WHEN spend > 0
       AND roas IS NOT NULL
       AND ABS((revenue * 1.0 / spend) - roas) > 0.01
      THEN 1 ELSE 0
    END
  ) AS roas_mismatch_rows
FROM raw_ppc_campaign_performance;

-- CPC with budget: budget / clicks
SELECT
  COUNT(*) AS total_rows,
  SUM(
    CASE
      WHEN clicks > 0
       AND cpc IS NOT NULL
       AND ABS((budget * 1.0 / clicks) - cpc) > 0.01
      THEN 1 ELSE 0
    END
  ) AS cpc_budget_mismatch_rows
FROM raw_ppc_campaign_performance;