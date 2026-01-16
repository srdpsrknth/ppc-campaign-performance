DROP VIEW IF EXISTS mart_reallocation_quintile_scenario;

CREATE VIEW mart_reallocation_quintile_scenario AS
WITH ranked AS (
  SELECT
    s.*,
    NTILE(5) OVER (ORDER BY roas) AS roas_quintile
  FROM int_campaign_segments s
  WHERE spend > 0
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
  SELECT
    efficiency_segment,
    SUM(spend) AS donor_spend,
    SUM(revenue) AS donor_revenue
  FROM ranked
  WHERE roas_quintile = 1
  GROUP BY efficiency_segment
),
donor_total AS (
  SELECT SUM(donor_spend) AS freed_spend
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
    COALESCE(w.weight, 0)
    * (SELECT freed_spend FROM donor_total)
    * COALESCE(
        (SELECT seg_roas
        FROM recipient_perf rp
        WHERE rp.efficiency_segment = b.efficiency_segment),
        0
      ) AS added_revenue
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
