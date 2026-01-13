SELECT campaign_id, COUNT(*) AS rows_per_campaign
FROM raw_ppc_campaign_performance
GROUP BY campaign_id
HAVING COUNT(*) > 1
ORDER BY rows_per_campaign DESC;