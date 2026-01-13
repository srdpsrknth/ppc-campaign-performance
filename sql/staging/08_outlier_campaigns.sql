-- Top spend campaigns
SELECT
  campaign_id,
  platform,
  date,
  spend,
  clicks,
  conversions,
  revenue,
  (revenue * 1.0 / NULLIF(spend,0)) AS roas_calc
FROM raw_ppc_campaign_performance
ORDER BY spend DESC
LIMIT 20;

-- Top revenue campaigns
SELECT
  campaign_id,
  platform,
  date,
  spend,
  clicks,
  conversions,
  revenue,
  (revenue * 1.0 / NULLIF(spend,0)) AS roas_calc
FROM raw_ppc_campaign_performance
ORDER BY revenue DESC
LIMIT 20;


SELECT campaign_id, platform, date, spend, revenue
FROM (SELECT * FROM raw_ppc_campaign_performance ORDER BY spend DESC LIMIT 20)
INTERSECT
SELECT campaign_id, platform, date, spend, revenue
FROM (SELECT * FROM raw_ppc_campaign_performance ORDER BY revenue DESC LIMIT 20);