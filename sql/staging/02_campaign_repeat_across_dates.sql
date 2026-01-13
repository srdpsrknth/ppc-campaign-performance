--Same campaigns across dates?
SELECT
  campaign_id,
  COUNT(DISTINCT date) AS distinct_dates
FROM raw_ppc_campaign_performance
GROUP BY campaign_id
HAVING COUNT(DISTINCT date) > 1
ORDER BY distinct_dates DESC;