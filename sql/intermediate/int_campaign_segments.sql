DROP VIEW IF EXISTS int_campaign_segments;

CREATE VIEW int_campaign_segments AS
WITH scored AS (
  SELECT
    *,
    NTILE(5) OVER (ORDER BY roas) AS roas_quintile,
    NTILE(5) OVER (ORDER BY cpa_spend) AS cpa_quintile, -- lower is better (so Q1 is best)
    NTILE(5) OVER (ORDER BY spend) AS spend_quintile
  FROM int_campaign_performance
  WHERE spend > 0
),
segmented AS (
  SELECT
    *,
    CASE
      WHEN roas_quintile = 5 AND cpa_quintile = 1 THEN 'Scale (high ROAS, low CPA)'
      WHEN roas_quintile = 5 AND cpa_quintile >= 3 THEN 'High ROAS but inefficient conversions'
      WHEN roas_quintile <= 2 AND spend_quintile >= 4 THEN 'Waste (high spend, low ROAS)'
      WHEN roas_quintile <= 2 AND spend_quintile <= 2 THEN 'Low impact (small spend, low ROAS)'
      WHEN roas_quintile >= 4 AND spend_quintile <= 2 THEN 'Promising (high ROAS, low spend)'
      ELSE 'Monitor'
    END AS efficiency_segment
  FROM scored
)
SELECT * FROM segmented;
