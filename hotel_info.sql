CREATE TABLE hotel_info (
quarter TEXT,
year BIGINT,
value INT,
title VARCHAR (255),
quarter_number INT,
sort_id INT
)
-------------------------------------------------------------
SELECT * FROM hotel_info
--LIMIT(10)
-------------------------------------------------------------
-- GROWTH OF HOTEL APARTMENT OVER YEARS
SELECT 
year AS year,
SUM(value) AS total_apartments
FROM hotel_info
WHERE TRIM(LOWER(title)) LIKE '%number of hotel apartments%'
GROUP BY year
ORDER BY year 
---------------------------------------------------------------
--YEAR OVER YEAR GROWTH USING LAG 
WITH yearly_total AS( -- CTE COMMON TABLE EXPRESSION 
SELECT 
year,
SUM(value) AS total_apartments
FROM hotel_info
WHERE TRIM(LOWER(title)) LIKE '%number of hotel apartments%'
GROUP BY year
),
yoy_data AS(
SELECT 
year,
total_apartments,
LAG(total_apartments) OVER (ORDER BY year) AS prev_year_total
FROM yearly_total
)
SELECT
year,
total_apartments,
prev_year_total,
total_apartments - prev_year_total AS yoy_change,
ROUND(((total_apartments - prev_year_total)*100.0)/prev_year_total,2) AS yoy_growth_pct
FROM yoy_data
-------------------------------------------------------------------------------------------
WITH yearly_totals AS ( -- STANDARD DEVIATION OF YOY GROWTH 
    SELECT
        year,
        SUM(value) AS total_apartments
    FROM hotel_info
    WHERE LOWER(TRIM(title)) LIKE '%number of hotel apartments%'
    GROUP BY year
),
yoy_changes AS (
    SELECT
        year,
        total_apartments,
        total_apartments -
        LAG(total_apartments) OVER (ORDER BY year) AS yoy_change
    FROM yearly_totals
)
SELECT
    ROUND(STDDEV_SAMP(yoy_change), 2) AS std_dev_yoy_change
FROM yoy_changes
WHERE yoy_change IS NOT NULL
AND year NOT IN (2020,2021);
----------------------------------------------------------------------------------------------------------
-- EXCLUDING THE YEARS 2020 & 2021 AS AN EXPECTION OF PANDAMIC WE HAVE A STD OF 2632.18 FOR THE YOY GROWTH
--INDICATING RELATIVELY STABLE ANNUAL FLUCTUATIONS INCLUDING EXCEPTIONAL YEARS MAY SKEW THE STD FAR HIGH 
----------------------------------------------------------------------------------------------------------

-- YOY GROWTH OF HOTEL ROOMS
