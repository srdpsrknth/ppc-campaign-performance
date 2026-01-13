--Total rows
SELECT
  COUNT(*) AS row_count
FROM raw_ppc_campaign_performance;

--Distinct campaigns
SELECT
  COUNT(DISTINCT campaign_id) AS distinct_campaigns
FROM raw_ppc_campaign_performance;