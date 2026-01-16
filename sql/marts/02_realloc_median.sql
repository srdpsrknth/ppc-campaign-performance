DROP VIEW IF EXISTS mart_reallocation_median_scenario;

CREATE VIEW mart_reallocation_median_scenario AS
WITH ordered AS (
  SELECT
    roas,
    ROW_NUMBER() OVER (ORDER BY roas) AS rn,
    COUNT(*) OVER () AS cnt
  FROM int_campaign_performance
  WHERE spend > 0
),
median AS (
  SELECT
    AVG(roas) AS median_roas
  FROM ordered
  WHERE rn IN (
    CAST((cnt + 1) / 2 AS INTEGER),
    CAST((cnt + 2) / 2 AS INTEGER)
  )
),
base AS (
  SELECT
    efficiency_segment,
    SUM(spend) AS base_spend,
    SUM(revenue) AS base_revenue
  FROM int_campaign_segments
  GROUP BY efficiency_segment
),
donors AS (
  -- campaigns below median, grouped by segment (so we reduce the right places)
  SELECT
    s.efficiency_segment,
    SUM(s.spend) AS donor_spend,
    SUM(s.revenue) AS donor_revenue
  FROM int_campaign_segments s
  CROSS JOIN median m
  WHERE s.spend > 0 AND s.roas < m.median_roas
  GROUP BY s.efficiency_segment
),
donor_total AS (
  SELECT
    SUM(donor_spend) AS freed_spend
  FROM donors
),
recipient_perf AS (
  SELECT
    efficiency_segment,
    SUM(revenue) * 1.0 / NULLIF(SUM(spend),0) AS seg_roas
  FROM int_campaign_segments
  WHERE efficiency_segment IN (
    'Scale (high ROAS, low CPA)',
    'Promising (high ROAS, low spend)'
  )
  GROUP BY efficiency_segment
),
weights AS (
  SELECT
    efficiency_segment,
    seg_roas / SUM(seg_roas) OVER () AS weight
  FROM recipient_perf
),
scenario AS (
  SELECT
    b.efficiency_segment,
    b.base_spend,
    b.base_revenue,

    COALESCE(d.donor_spend, 0) AS removed_spend,
    COALESCE(d.donor_revenue, 0) AS removed_revenue,

    COALESCE(w.weight, 0) * (SELECT freed_spend FROM donor_total) AS added_spend,
    COALESCE(w.weight, 0) * (SELECT freed_spend FROM donor_total)
      * (SELECT seg_roas FROM recipient_perf rp WHERE rp.efficiency_segment = b.efficiency_segment)
      AS added_revenue
  FROM base b
  LEFT JOIN donors d
    ON b.efficiency_segment = d.efficiency_segment
  LEFT JOIN weights w
    ON b.efficiency_segment = w.efficiency_segment
)
SELECT
  efficiency_segment,
  (base_spend - removed_spend + added_spend) AS new_spend,
  (base_revenue - removed_revenue + added_revenue) AS new_revenue,
  (base_revenue - removed_revenue + added_revenue) * 1.0
    / NULLIF((base_spend - removed_spend + added_spend), 0) AS new_roas
FROM scenario;
