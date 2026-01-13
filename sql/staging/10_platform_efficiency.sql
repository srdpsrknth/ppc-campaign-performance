SELECT
  platform,
  COUNT(*) AS rows,
  round(AVG(clicks * 1.0 / NULLIF(impressions,0)),4) AS ctr_calc_avg,
  round(AVG(spend * 1.0 / NULLIF(clicks,0)),4) AS cpc_spend_avg,
  round(AVG(budget * 1.0 / NULLIF(clicks,0)),4) AS cpc_budget_avg,
  round(AVG(revenue * 1.0 / NULLIF(spend,0)),4) AS roas_calc_avg,
  round(AVG(conversions * 1.0 / NULLIF(clicks,0)),4) AS cvr_calc_avg
FROM raw_ppc_campaign_performance
GROUP BY platform
ORDER BY cvr_calc_avg DESC;
