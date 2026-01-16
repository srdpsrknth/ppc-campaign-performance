DROP VIEW IF EXISTS mart_platform_reallocation_median;

CREATE VIEW mart_platform_reallocation_median AS
WITH base AS (
  SELECT
    platform,
    efficiency_segment,
    SUM(spend) AS base_spend,
    SUM(revenue) AS base_revenue
  FROM int_campaign_segments
  GROUP BY platform, efficiency_segment
),
platform_median AS (
  SELECT
    platform,
    AVG(roas) AS median_roas
  FROM (
    SELECT
      platform,
      roas,
      ROW_NUMBER() OVER (PARTITION BY platform ORDER BY roas) AS rn,
      COUNT(*) OVER (PARTITION BY platform) AS cnt
    FROM int_campaign_segments
    WHERE spend > 0
  )
  WHERE rn IN (
    CAST((cnt + 1) / 2 AS INTEGER),
    CAST((cnt + 2) / 2 AS INTEGER)
  )
  GROUP BY platform
),
donors AS (
  SELECT
    s.platform,
    s.efficiency_segment,
    SUM(s.spend) AS donor_spend,
    SUM(s.revenue) AS donor_revenue
  FROM int_campaign_segments s
  JOIN platform_median m
    ON s.platform = m.platform
  WHERE s.roas < m.median_roas
  GROUP BY s.platform, s.efficiency_segment
),
donor_totals AS (
  SELECT
    platform,
    SUM(donor_spend) AS freed_spend
  FROM donors
  GROUP BY platform
),
recipient_perf AS (
  SELECT
    platform,
    efficiency_segment,
    SUM(revenue) * 1.0 / NULLIF(SUM(spend),0) AS seg_roas
  FROM int_campaign_segments
  WHERE efficiency_segment IN (
    'Scale (high ROAS, low CPA)',
    'Promising (high ROAS, low spend)'
  )
  GROUP BY platform, efficiency_segment
),
weights AS (
  SELECT
    platform,
    efficiency_segment,
    seg_roas / SUM(seg_roas) OVER (PARTITION BY platform) AS weight
  FROM recipient_perf
),
scenario AS (
  SELECT
    b.platform,
    b.efficiency_segment,
    b.base_spend,
    b.base_revenue,

    COALESCE(d.donor_spend,0) AS removed_spend,
    COALESCE(d.donor_revenue,0) AS removed_revenue,

    COALESCE(w.weight,0)
      * COALESCE(dt.freed_spend,0) AS added_spend,

    COALESCE(w.weight,0)
      * COALESCE(dt.freed_spend,0)
      * COALESCE(r.seg_roas,0) AS added_revenue
  FROM base b
  LEFT JOIN donors d
    ON b.platform = d.platform
   AND b.efficiency_segment = d.efficiency_segment
  LEFT JOIN donor_totals dt
    ON b.platform = dt.platform
  LEFT JOIN weights w
    ON b.platform = w.platform
   AND b.efficiency_segment = w.efficiency_segment
  LEFT JOIN recipient_perf r
    ON b.platform = r.platform
   AND b.efficiency_segment = r.efficiency_segment
)
SELECT
  platform,
  efficiency_segment,
  (base_spend - removed_spend + added_spend) AS new_spend,
  (base_revenue - removed_revenue + added_revenue) AS new_revenue,
  (base_revenue - removed_revenue + added_revenue) * 1.0
    / NULLIF((base_spend - removed_spend + added_spend),0) AS new_roas
FROM scenario;
