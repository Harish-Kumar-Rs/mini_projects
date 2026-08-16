SELECT * FROM metro_ridership_clean
LIMIT (10)

SELECT 
MIN(year),
MAX(year)
FROM metro_ridership_clean

SELECT 
COUNT(*) 
FROM metro_ridership_clean

SELECT 
day_name,
COUNT(*) AS total_ridership
FROM metro_ridership_clean
WHERE LOWER(TRIM(txn_type)) ='check in'
GROUP BY day_name
ORDER BY total_ridership DESC	
-------------------------------------------------------------------
--Total number of taps (rows) in the table
SELECT COUNT(*)
FROM metro_ridership_clean
--Count of Check in vs Check out transactions
SELECT 
txn_type,
COUNT(*) AS total_transactions
FROM metro_ridership_clean
GROUP BY txn_type
--Date range covered (min and max txn_date)
SELECT 
MIN(year),
MAX(year)
FROM metro_ridership_clean
--Number of distinct line_name values
SELECT
COUNT(DISTINCT line_name)
FROM metro_ridership_clean
--Total check-ins per year
SELECT 
year,
COUNT(*) AS total_transactions
FROM metro_ridership_clean
WHERE LOWER(TRIM(txn_type)) = 'check in'
GROUP BY year
ORDER BY total_transactions desc
--Total check-ins per month (across all years) — to see overall seasonality
SELECT 
year,
month,
COUNT(*) AS total_transactions
FROM metro_ridership_clean
WHERE LOWER(TRIM(txn_type)) = 'check in'
GROUP BY year,month
ORDER BY year
----------------------------------------------------
SELECT line_name, COUNT(*) 
FROM metro_ridership_clean 
WHERE year = 2022 AND month BETWEEN 5 AND 12 
GROUP BY line_name;
------------------------------------------------------
SELECT year, month, COUNT(DISTINCT txn_date) AS days_with_data
FROM metro_ridership_clean 
WHERE (year=2022 AND month BETWEEN 5 AND 12)
GROUP BY year, month ORDER BY year, month;
----------------------------------------------------
SELECT year, month, COUNT(*) AS total_taps, 
       COUNT(*) / COUNT(DISTINCT txn_date) AS avg_taps_per_day
FROM metro_ridership_clean 
WHERE year = 2022
GROUP BY year, month ORDER BY month;

---------------------------------------------------------------------------------------------
--"May 2022–May 2023 shows a sustained ~90% drop in daily tap volume, consistent
--across both lines, with no gap in daily records. No corresponding real-world event
--(service disruption, system change) was identified through public sources. The
--anomaly's cause could not be confirmed from available data and may reflect either an
--actual ridership event or a change in the completeness of the open-data export for this
--period. This window is excluded from trend/regression analysis and flagged in the dashboard."
------------------------------------------------------------------------------------------------
--Which day of week (day_name) has the highest average check-ins?
SELECT day_name, 
       COUNT(*) AS total_checkins,
       COUNT(DISTINCT txn_date) AS num_days,
       COUNT(*)::numeric / COUNT(DISTINCT txn_date) AS avg_checkins_per_day
FROM metro_ridership_clean
WHERE txn_type = 'Check in'
GROUP BY day_name
ORDER BY avg_checkins_per_day DESC;
-----------------------------------------------------------------------------------------------
--Month-over-month change in check-ins (use LAG() window function

WITH monthly_transactions AS(
SELECT 
year,
month,
COUNT(*) AS total_transactions
FROM metro_ridership_clean
WHERE LOWER(TRIM(txn_type)) = 'check in'
GROUP BY year,month
)
SELECT
year,
month,
total_transactions,
LAG(total_transactions) OVER (ORDER BY year,month) AS prev_count,
total_transactions - LAG(total_transactions) OVER (ORDER BY year,month) AS diffrence,
   ROUND(
        (
            total_transactions
            - LAG(total_transactions) OVER (ORDER BY year, month)
        ) * 100.0
        / NULLIF(LAG(total_transactions) OVER (ORDER BY year, month), 0),
        2
    ) AS growth_pct
FROM monthly_transactions
---------------------------------------------------------------------------

