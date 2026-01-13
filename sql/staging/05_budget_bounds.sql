SELECT
  MIN(duration) AS min_duration,
  MAX(duration) AS max_duration,
  AVG(duration) AS avg_duration
FROM raw_ppc_campaign_performance;

SELECT
  MIN(budget) AS min_budget,
  MAX(budget) AS max_budget,
  AVG(budget) AS avg_budget
FROM raw_ppc_campaign_performance;
