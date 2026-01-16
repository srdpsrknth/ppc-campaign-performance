WITH campaign_appearance AS (
  SELECT
    campaign_id,
    COUNT(*) AS appearances
  FROM raw_ppc_campaign_performance
  GROUP BY campaign_id
),
summary AS (
  SELECT
    COUNT(*) AS total_campaigns,
    SUM(CASE WHEN appearances = 1 THEN 1 ELSE 0 END) AS single_appearance_campaigns,
    SUM(CASE WHEN appearances > 1 THEN 1 ELSE 0 END) AS multi_appearance_campaigns
  FROM campaign_appearance
),
performance_by_appearance AS (
  SELECT
    a.appearances,
    COUNT(*) AS campaigns,
    AVG(p.revenue * 1.0 / NULLIF(p.spend, 0)) AS avg_roas,
    AVG(p.revenue) AS avg_revenue_per_row
  FROM raw_ppc_campaign_performance p
  JOIN campaign_appearance a
    ON p.campaign_id = a.campaign_id
  GROUP BY a.appearances
)
SELECT
  s.total_campaigns,
  s.single_appearance_campaigns,
  s.multi_appearance_campaigns,
  ROUND(100.0 * s.single_appearance_campaigns / s.total_campaigns, 2) AS pct_single_appearance,
  p.appearances,
  p.campaigns,
  ROUND(p.avg_roas, 2) AS avg_roas,
  ROUND(p.avg_revenue_per_row, 0) AS avg_revenue
FROM summary s
JOIN performance_by_appearance p;
