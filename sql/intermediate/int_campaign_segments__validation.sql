-- 1) row count should equal distinct campaigns in staging
SELECT
  (SELECT COUNT(DISTINCT campaign_id) FROM stg_ppc_campaigns) AS distinct_campaigns_stg,
  (SELECT COUNT(*) FROM int_campaign_performance) AS rows_in_int_campaign_performance;

-- 2) segment distribution
SELECT
  efficiency_segment,
  COUNT(*) AS campaigns,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_campaigns,
  ROUND(AVG(roas), 2) AS avg_roas,
  ROUND(AVG(cpa_spend), 2) AS avg_cpa_spend,
  ROUND(AVG(spend), 0) AS avg_spend
FROM int_campaign_segments
GROUP BY efficiency_segment
ORDER BY campaigns DESC;

-- 3) “Scale” candidates: high ROAS + low CPA (top examples)
SELECT
  campaign_id,
  platform,
  spend,
  revenue,
  ROUND(roas, 2) AS roas,
  ROUND(cpa_spend, 2) AS cpa_spend,
  efficiency_segment
FROM int_campaign_segments
WHERE efficiency_segment = 'Scale (high ROAS, low CPA)'
ORDER BY roas DESC
LIMIT 15;

-- 4) “Waste” candidates: high spend, low ROAS (top examples)
SELECT
  campaign_id,
  platform,
  spend,
  revenue,
  ROUND(roas, 2) AS roas,
  ROUND(cpa_spend, 2) AS cpa_spend,
  efficiency_segment
FROM int_campaign_segments
WHERE efficiency_segment = 'Waste (high spend, low ROAS)'
ORDER BY spend DESC
LIMIT 15;
